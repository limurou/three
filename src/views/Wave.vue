<!-- filepath: /c:/Users/ZhuanZ/Desktop/webgl/src/components/About.vue -->
<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import waterVertexShader from '../shaders/water/vertex.glsl';
import waterFragmentShader from '../shaders/water/fragment.glsl';
import { GUI } from 'dat.gui';

export default {
  name: 'About',
  setup() {
    const sceneContainer = ref(null);
    let gui;

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.set(0, 1, 2);

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // color
      let debugObject = {};
      debugObject.depthColor = '#186691';
      debugObject.surfaceColor = '#9bd8ff';

      // 创建一个网格
      const geometry = new THREE.PlaneGeometry(2, 2, 512, 512);
      const material = new THREE.ShaderMaterial({
        uniforms: {
          uTime: { value: 1.0 },
          uBigWavesElevation: { value: 0.2 },
          uBigWavesFrequency: { value: new THREE.Vector2(4, 1.5) },
          uBigWavesSpeed: { value: 0.75 },

          uSmallWavesElevation: { value: 0.15 },
          uSmallWavesFrequency: { value: 3.0 },
          uSmallWavesSpeed: { value: 0.2 },
          uSmallWavesIterations: { value: 4.0 },

          uDepthColor: { value: new THREE.Color(debugObject.depthColor) },
          uSurfaceColor: { value: new THREE.Color(debugObject.surfaceColor) },
          uColorOffset: { value: 0.08 },
          uColorMultiplier: { value: 5 }
        },
        vertexShader: waterVertexShader,
        fragmentShader: waterFragmentShader,
        side: THREE.DoubleSide, // 设置为双面渲染
        wireframe: false // 设置为非线框模式
      });
      const mesh = new THREE.Mesh(geometry, material);
      mesh.rotation.x = Math.PI * -0.5;
      scene.add(mesh);

      // 创建 GUI
      gui = new GUI();
      gui.add(material.uniforms.uBigWavesElevation, 'value').min(0).max(1).step(0.01).name('uBigWavesElevation');
      gui.add(material.uniforms.uBigWavesFrequency.value, 'x').min(0).max(10).step(0.01).name('uBigWavesFrequencyX');
      gui.add(material.uniforms.uBigWavesFrequency.value, 'y').min(0).max(10).step(0.01).name('uBigWavesFrequencyY');
      gui.add(material.uniforms.uBigWavesSpeed, 'value').min(0).max(4).step(0.01).name('uBigWavesSpeed');
      gui.add(material.uniforms.uSmallWavesElevation, 'value').min(0).max(1).step(0.01).name('uSmallWavesElevation');
      gui.add(material.uniforms.uSmallWavesFrequency, 'value').min(0).max(30).step(0.01).name('uSmallWavesFrequency');
      gui.add(material.uniforms.uSmallWavesSpeed, 'value').min(0).max(4).step(0.01).name('uSmallWavesSpeed');
      gui.add(material.uniforms.uSmallWavesIterations, 'value').min(0).max(10).step(1).name('uSmallWavesIterations');

      gui.addColor(debugObject, 'depthColor').onChange(() => {
        material.uniforms.uDepthColor.value.set(debugObject.depthColor);
      });
      gui.addColor(debugObject, 'surfaceColor').onChange(() => {
        material.uniforms.uSurfaceColor.value.set(debugObject.surfaceColor);
      });
      gui.add(material.uniforms.uColorOffset, 'value').min(0).max(1).step(0.01).name('uColorOffset');
      gui.add(material.uniforms.uColorMultiplier, 'value').min(0).max(10).step(0.01).name('uColorMultiplier');
     
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
        const elapsedTime = clock.getElapsedTime();
        material.uniforms.uTime.value = elapsedTime;

        // 更新控制器
        controls.update();

        renderer.render(scene, camera);
      }

      animate();
    });

    onBeforeUnmount(() => {
      if (gui) {
        gui.destroy();
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