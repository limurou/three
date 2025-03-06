<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import smokeVertexShader from '../shaders/smoke/vertex.glsl';
import smokeFragmentShader from '../shaders/smoke/fragment.glsl';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';

export default {
  name: 'Smoke',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();
      scene.background = new THREE.Color(0x345345);

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.set(0, 0, 8);

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      const light = new THREE.AmbientLight(0xffffff, 1);
      scene.add(light);


      const loader = new GLTFLoader();
      loader.load('./cup.glb', (gltf) => {
        const model = gltf.scene;
        scene.add(model)
        model.scale.set(2,2,2);
        model.position.set(0, -3.2, 0);
        })

      // 创建一个平面
      const geometry = new THREE.PlaneGeometry(1,1,16,64);
        geometry.scale(1.3, 6, 1.5);

        const texture = new THREE.TextureLoader().load('./noise.png');
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;

      const material = new THREE.ShaderMaterial({
        vertexShader: smokeVertexShader,
        fragmentShader: smokeFragmentShader,
        uniforms: {
          uTime: { value: 0 },
          uTexture: { value: texture }
        },
      transparent: true,
      depthWrite: false,
      //wireframe: true,
      side: THREE.DoubleSide });
      const plane = new THREE.Mesh(geometry, material);
      
      scene.add(plane);

      // 添加光源
      const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
      scene.add(ambientLight);

      const pointLight = new THREE.PointLight(0xffffff, 1);
      pointLight.position.set(5, 5, 5);
      scene.add(pointLight);

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

      animate();
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
