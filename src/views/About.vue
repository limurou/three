<!-- filepath: /c:/Users/ZhuanZ/Desktop/webgl/src/components/About.vue -->
<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

export default {
  name: 'About',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.z = 5;

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // 创建一个网格
      const geometry = new THREE.PlaneGeometry(3, 3);
      const material = new THREE.ShaderMaterial({
        uniforms: {
          time: { value: 1.0 }
        },
        vertexShader: `
          uniform float time;
          varying vec2 vUv;
          void main() {
            vUv = uv;
            gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
          }
        `,
        fragmentShader: `
          uniform float time;
          varying vec2 vUv;
          void main() {
            gl_FragColor = vec4(0.5 + 0.5 * cos(time), 0.5 + 0.5 * sin(time), 0.5 + 0.5 * cos(time), 1.0);
          }
        `,
        side: THREE.DoubleSide, // 设置为双面渲染
        wireframe: false // 设置为非线框模式
      });
      const mesh = new THREE.Mesh(geometry, material);
      scene.add(mesh);

      const clock = new THREE.Clock();

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
        const time = clock.getElapsedTime();
        material.uniforms.time.value = time;

        // 更新控制器
        controls.update();

        // 旋转网格
        mesh.rotation.x += 0.01;
        mesh.rotation.y += 0.01;

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