<!-- filepath: /c:/Users/ZhuanZ/Desktop/webgl/src/views/webgl.vue -->
<template>
  <div ref="sceneContainer" class="scene-container" id="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

	

export default {
  name: 'WebGLScene',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.z = 5;

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true, });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // 创建一个立方体
      const geometry = new THREE.BoxGeometry();
      const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
      const cube = new THREE.Mesh(geometry, material);
      scene.add(cube);

      // 监听窗口大小变化
      window.addEventListener('resize', onWindowResize, false);

      function onWindowResize() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
      }

      // 渲染循环
      function animate() {
        requestAnimationFrame(animate);

        // 更新控制器
        controls.update();

        // 旋转立方体
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;

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
.body {
  margin: 0;
  padding: 0;
  overflow: hidden;
}
.scene-container {
  width: 100%;
  height: 100vh; /* 设置高度为 100vh */
  overflow: hidden;
}
</style>