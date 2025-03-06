<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import holographicVertexShader from '../shaders/holographic/vertex.glsl';
import { GUI } from 'dat.gui';
import holographicFragmentShader from '../shaders/holographic/fragment.glsl';

export default {
  name: 'SoldierScene',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.set(0, 2, 5);

      let renderer;
      try {
        // 创建渲染器
        renderer = new THREE.WebGLRenderer({ antialias: true });
        renderer.setSize(window.innerWidth, window.innerHeight);
        sceneContainer.value.appendChild(renderer.domElement);
      } catch (error) {
        console.error('WebGL context creation failed:', error);
        return;
      }

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // 添加光源
      const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
      scene.add(ambientLight);

      const pointLight = new THREE.PointLight(0xffffff, 1);
      pointLight.position.set(5, 5, 5);
      scene.add(pointLight);

      const materialParameters = {};
      materialParameters.color = '#70c1ff';

      const gui = new GUI;
      gui
        .addColor(materialParameters, 'color')
        .onChange(() => {
          material.uniforms.uColor.value.set(materialParameters.color)
        })

      // 创建 ShaderMaterial
      const material = new THREE.ShaderMaterial({
        vertexShader: holographicVertexShader,
        fragmentShader: holographicFragmentShader,
        uniforms: {
          uTime: new THREE.Uniform(0.0),
          uColor: new THREE.Uniform(new THREE.Color('red'))
        },
        transparent: true,
        side: THREE.DoubleSide,
        depthWrite: false,
        blending: THREE.AdditiveBlending
    });
      const geometry = new THREE.SphereGeometry(1, 32, 32);
      const mesh = new THREE.Mesh(geometry, material);
      scene.add(mesh);
      mesh.position.set(-2, 0, 0);
      // 加载 GLTF 模型
      const loader = new GLTFLoader();
      loader.load('./su.glb', (gltf) => {
        const model = gltf.scene;
        
        scene.add(model);
        model.traverse((child) => {
          if (child.isMesh) {
            child.material = material;
          }
        });

        animate();
      });

      // 监听窗口大小变化
      window.addEventListener('resize', onWindowResize, false);

      function onWindowResize() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
      }

      const clock = new THREE.Clock();
      // 渲染循环
      function animate() {
        requestAnimationFrame(animate);
        const elapsedTime = clock.getElapsedTime();
        material.uniforms.uTime.value = elapsedTime;

        // 更新控制器
        controls.update();

        renderer.render(scene, camera);
      }
    });

    return {
      sceneContainer
    };
  }
};
</script>

<style scoped>
.scene-container {
  width: 100%;
  height: 100vh; /* 设置高度为 100vh */
  overflow: hidden;
}
</style>
