<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { GUI } from 'dat.gui';
import galaxyVertexShader from '../shaders/galaxy/vertex.glsl';
import galaxyFragmentShader from '../shaders/galaxy/fragment.glsl';


export default {
  name: 'Galaxy',
  setup() {
    const sceneContainer = ref(null);
    let gui;

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();
      scene.background = new THREE.Color(0x201919);

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.set(4, 2,5);

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // galaxy
      const parameters = {};
      parameters.count = 100000;
      parameters.size = 0.2;
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
        const scales = new Float32Array(parameters.count * 1);
        const randomness = new Float32Array(parameters.count * 3);

        const colorInside = new THREE.Color(parameters.insideColor);
        const colorOutside = new THREE.Color(parameters.outsideColor);

        colorInside.lerp(colorOutside, 0.5);

        for (let i = 0; i < parameters.count; i++) {
          const i3 = i * 3;

            const radius = Math.random() * parameters.radius;
            
            const branchAngle = ((i % parameters.branches) / parameters.branches) * Math.PI * 2;

           
          positions[i3 + 0] = Math.cos(branchAngle) * radius;
          positions[i3 + 1] = 0;
          positions[i3 + 2] = Math.sin(branchAngle) * radius;

           const randomX = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1) ;
            const randomY = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1) ;
            const randomZ = Math.pow(Math.random(), parameters.randomnessPower) * (Math.random() < 0.5 ? 1 : -1) ;

            randomness[i3 + 0] = randomX;
            randomness[i3 + 1] = randomY;
            randomness[i3 + 2] = randomZ;

          // Color
            const mixedColor = colorInside.clone();
            mixedColor.lerp(colorOutside, radius / parameters.radius);

            colors[i3 + 0] = mixedColor.r;
            colors[i3 + 1] = mixedColor.g;
            colors[i3 + 2] = mixedColor.b;

            //scale
            scales[i] = Math.random();
        
        }

        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.setAttribute('aScale', new THREE.BufferAttribute(colors, 1));
        geometry.setAttribute('aRandomness', new THREE.BufferAttribute(randomness, 3));


        material = new THREE.ShaderMaterial({
          
          depthWrite: false,
          blending: THREE.AdditiveBlending,
            vertexColors: true,
            vertexShader: galaxyVertexShader,
            fragmentShader: galaxyFragmentShader,
            uniforms: {
                uTime: { value: 0 },
              uSize: { value: 30 * renderer.getPixelRatio() },
              
            }
            
         });

        points = new THREE.Points(geometry, material);
        scene.add(points);
      };

      generateGalaxy();

      gui.add(parameters, 'count').min(100).max(100000).step(100).onFinishChange(generateGalaxy);
      gui.add(parameters, 'size').min(0.01).max(1).step(0.01).onFinishChange(generateGalaxy);
        gui.add(parameters, 'radius').min(1).max(20).step(1).onFinishChange(generateGalaxy); 
        gui.add(parameters, 'branches').min(2).max(20).step(1).onFinishChange(generateGalaxy);
        gui.add(parameters, 'spin').min(-5).max(5).step(0.001).onFinishChange(generateGalaxy);
        gui.add(parameters, 'randomness').min(0).max(2).step(0.001).onFinishChange(generateGalaxy);
        gui.add(parameters, 'randomnessPower').min(1).max(10).step(0.001).onFinishChange(generateGalaxy);
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
        const clock = new THREE.Clock();
      // 渲染循环
      function animate() {
        requestAnimationFrame(animate);
        const time = clock.getElapsedTime();
        material.uniforms.uTime.value = time;

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
