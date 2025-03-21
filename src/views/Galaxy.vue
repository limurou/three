<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { GUI } from 'dat.gui';

export default {
  name: 'Galaxy',
  setup() {
    const sceneContainer = ref(null);
    let gui;

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.set(0, 4, 8);

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // galaxy
      const parameters = {};
      parameters.count = 10000;
      parameters.size = 0.02;
      parameters.radius = 5;
      parameters.branches = 3;
      parameters.spin = 1;
      parameters.randomness = 0.2;
      parameters.randomnessPower = 3;
      parameters.insideColor = '#ff6030';
      parameters.outsideColor = '#1b3984';

      let geometry = null;
      let material = null;
      let points = null;

      gui = new GUI({ width: 360 });

      const generateGalaxy = () => {
        if (points !== null) {
          geometry.dispose();
          material.dispose();
          scene.remove(points);
        }

        geometry = new THREE.BufferGeometry();

        const positions = new Float32Array(parameters.count * 3);
        const colors = new Float32Array(parameters.count * 3);

        const colorInside = new THREE.Color(parameters.insideColor);
        const colorOutside = new THREE.Color(parameters.outsideColor);

        for (let i = 0; i < parameters.count; i++) {
          const i3 = i * 3;

          const radius = Math.random() * parameters.radius;
          const spinAngle = radius * parameters.spin;
          const branchAngle = ((i % parameters.branches) / parameters.branches) * Math.PI * 2;

          const randomX = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);
          const randomY = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);
          const randomZ = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1);

          positions[i3 + 0] = Math.cos(branchAngle + spinAngle) * radius + randomX;
          positions[i3 + 1] = randomY;
          positions[i3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ;

          // Color
          const mixedColor = colorInside.clone();
          mixedColor.lerp(colorOutside, radius / parameters.radius);

          colors[i3 + 0] = mixedColor.r;
          colors[i3 + 1] = mixedColor.g;
          colors[i3 + 2] = mixedColor.b;
        }

        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

        material = new THREE.PointsMaterial({
          size: parameters.size,
          sizeAttenuation: true,
          depthWrite: false,
          blending: THREE.AdditiveBlending,
          vertexColors: true,
        });

        points = new THREE.Points(geometry, material);
        scene.add(points);
      };

      generateGalaxy();

      gui.add(parameters, 'count').min(100).max(100000).step(100).onFinishChange(generateGalaxy);
      gui.add(parameters, 'size').min(0.001).max(0.1).step(0.01).onFinishChange(generateGalaxy);
      gui.add(parameters, 'radius').min(1).max(20).step(1).onFinishChange(generateGalaxy);
      gui.add(parameters, 'branches').min(2).max(20).step(1).onFinishChange(generateGalaxy);
      gui.add(parameters, 'spin').min(-5).max(5).step(0.01).onFinishChange(generateGalaxy);
      gui.add(parameters, 'randomness').min(0).max(6).step(0.01).onFinishChange(generateGalaxy);
      gui.add(parameters, 'randomnessPower').min(1).max(10).step(0.01).onFinishChange(generateGalaxy);
      gui.addColor(parameters, 'insideColor').onFinishChange(generateGalaxy);
      gui.addColor(parameters, 'outsideColor').onFinishChange(generateGalaxy);

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

      // 渲染循环
      function animate() {
        requestAnimationFrame(animate);

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
