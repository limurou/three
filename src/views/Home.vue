<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass';

export default {
  name: 'Home',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 100);
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
      const pointLight = new THREE.PointLight(0xffffff, 1);
      scene.add(pointLight);

      // 加载 GLTF 模型
      const loader = new GLTFLoader();
      loader.load('./Soldier.glb', (gltf) => {
        const model = gltf.scene;
        scene.add(model);
        animate();
      });

      // 创建后期处理效果
      const composer = new EffectComposer(renderer);
      const renderPass = new RenderPass(scene, camera);
      composer.addPass(renderPass);

      const bloomPass = new UnrealBloomPass(new THREE.Vector2(window.innerWidth, window.innerHeight), 1.5, 0.4, 0.85);
      bloomPass.threshold = 0.5; // 辉光阈值
      bloomPass.strength = 10.0;  // 辉光强度
      bloomPass.radius = 10.0;    // 辉光范围
      composer.addPass(bloomPass);

      // 监听窗口大小变化
      window.addEventListener('resize', onWindowResize, false);

      function onWindowResize() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
        composer.setSize(window.innerWidth, window.innerHeight);
      }

      // 渲染循环
      function animate() {
        requestAnimationFrame(animate);
        composer.render();
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