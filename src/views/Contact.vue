<!-- filepath: /c:/Users/ZhuanZ/Desktop/webgl/src/components/About.vue -->
<template>
  <div ref="sceneContainer" class="scene-container"></div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { GUI } from 'dat.gui';

export default {
  name: 'Contact',
  setup() {
    const sceneContainer = ref(null);
    let gui;

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.z = 1;

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      // 创建 GUI
      gui = new GUI();

      // 创建一个网格
      const texture = new THREE.TextureLoader().load('./1.jpg');
      const geometry = new THREE.PlaneGeometry(1, 1, 32, 32);
      const material = new THREE.ShaderMaterial({
        uniforms: {
          time: { value: 1.0 },
          uTexture: { value: texture },
          uFrequency: { value: new THREE.Vector2(10, 5) }
        },
        vertexShader: `
          uniform float time;
          uniform vec2 uFrequency;
          varying vec2 vUv;
          void main() {
            vUv = uv;
            vec4 modelPosition = modelMatrix * vec4(position, 1.0);
            modelPosition.z += sin(modelPosition.x * uFrequency.x - time) * 0.1;
            modelPosition.z += sin(modelPosition.y * uFrequency.y - time) * 0.1;

            vec4 viewPosition = viewMatrix * modelPosition;
            vec4 projectionPosition = projectionMatrix * viewPosition;

            gl_Position = projectionPosition;
          }
        `,
        fragmentShader: `
          uniform sampler2D uTexture;
          uniform float time;
          varying vec2 vUv;
          void main() {
            vec4 textureColor = texture2D(uTexture, vUv);
            gl_FragColor = textureColor;
          }
        `,
        side: THREE.DoubleSide, // 设置为双面渲染
        wireframe: false // 设置为非线框模式
      });
      const mesh = new THREE.Mesh(geometry, material);
      mesh.scale.y = 2 / 3;
      scene.add(mesh);

      // GUI 控制器
      const folder = gui.addFolder('Mesh Settings');
      folder.add(material.uniforms.uFrequency.value, 'x', 0, 20, 0.1).name('Frequency X');
      folder.add(material.uniforms.uFrequency.value, 'y', 0, 20, 0.1).name('Frequency Y');
      folder.open();

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