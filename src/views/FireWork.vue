<!-- filepath: /c:/Users/ZhuanZ/Desktop/webgl/src/views/webgl.vue -->
<template>
  <div ref="sceneContainer" class="scene-container" id="scene-container"></div>
</template>

<script>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import GUI from 'lil-gui';
import gsap from 'gsap';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import fireworkVertexShader from '../shaders/firework/vertex.glsl';
import fireworkFragmentShader from '../shaders/firework/fragment.glsl';
import { Sky } from 'three/examples/jsm/objects/Sky';


export default {
  name: 'WebGLScene',
  setup() {
    const sceneContainer = ref(null);

    onMounted(() => {
      // 创建场景
      const scene = new THREE.Scene();
      

      // 创建相机
      const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      camera.position.z = 3;

      // 创建渲染器
      const renderer = new THREE.WebGLRenderer({ antialias: true, });
      renderer.setSize(window.innerWidth, window.innerHeight);
      sceneContainer.value.appendChild(renderer.domElement);

      // 创建控制器
      const controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true; // 启用阻尼效果

      //sky
      const sky = new Sky();
				sky.scale.setScalar( 450000 );
				scene.add( sky );

				const sun = new THREE.Vector3();

				/// GUI

				const effectController = {
					turbidity: 10,
					rayleigh: 3,
					mieCoefficient: 0.005,
					mieDirectionalG: 0.7,
					elevation: -2,
					azimuth: 180,
					exposure: renderer.toneMappingExposure
				};

				function guiChanged() {

					const uniforms = sky.material.uniforms;
					uniforms[ 'turbidity' ].value = effectController.turbidity;
					uniforms[ 'rayleigh' ].value = effectController.rayleigh;
					uniforms[ 'mieCoefficient' ].value = effectController.mieCoefficient;
					uniforms[ 'mieDirectionalG' ].value = effectController.mieDirectionalG;

					const phi = THREE.MathUtils.degToRad( 90 - effectController.elevation );
					const theta = THREE.MathUtils.degToRad( effectController.azimuth );

					sun.setFromSphericalCoords( 1, phi, theta );

					uniforms[ 'sunPosition' ].value.copy( sun );

					renderer.toneMappingExposure = effectController.exposure;
					renderer.render( scene, camera );

				}

				const gui = new GUI();

				gui.add( effectController, 'turbidity', 0.0, 20.0, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'rayleigh', 0.0, 4, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'mieCoefficient', 0.0, 0.1, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'mieDirectionalG', 0.0, 1, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'elevation', -3, 90, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'azimuth', - 180, 180, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'exposure', 0, 1, 0.0001 ).onChange( guiChanged );

				guiChanged();



      const textureLoader = new THREE.TextureLoader();
      const textures = [
        textureLoader.load('./star_01.png'),
        textureLoader.load('./star_02.png'),
        textureLoader.load('./star_03.png'),
        textureLoader.load('./star_04.png'),
        textureLoader.load('./star_05.png'),
        textureLoader.load('./star_06.png'),
        textureLoader.load('./star_07.png'),
        textureLoader.load('./star_08.png'),
        textureLoader.load('./star_09.png'),
        
        ];
      const sizes = {
        Width: window.innerWidth,
        Height: window.innerHeight,
        pixelRatio: (Math.min(window.devicePixelRatio, 2))
      };
      sizes.resolution = new THREE.Vector2(sizes.Width * sizes.pixelRatio, sizes.Height * sizes.pixelRatio);
      
      //fireworks 
      const creatFirework = (count, position, size, texture, redius, color) => {
        const positionsArray = new Float32Array(count * 3);
        const sizesArray = new Float32Array(count);
        const timeMultiplersArray = new Float32Array(count);

        for (let i = 0; i < count; i++) {
          const i3 = i * 3;
          const spherical = new THREE.Spherical(
            redius * (0.75 + Math.random() * 0.25),
            Math.random() * Math.PI,
            Math.random() * Math.PI * 2
          );
          const position = new THREE.Vector3().setFromSpherical(spherical);
          positionsArray[i3] = position.x;
          positionsArray[i3 + 1] = position.y;
          positionsArray[i3 + 2] = position.z;
          

          sizesArray[i] = Math.random();
          timeMultiplersArray[i] = 1 + Math.random();
        }

        const geometry = new THREE.BufferGeometry();
        geometry.setAttribute('position', new THREE.Float32BufferAttribute(positionsArray, 3));
        geometry.setAttribute('aSize', new THREE.Float32BufferAttribute(sizesArray, 1));
        geometry.setAttribute('aTimeMultiplier', new THREE.Float32BufferAttribute(timeMultiplersArray, 1));

        const material = new THREE.ShaderMaterial({
          vertexShader: fireworkVertexShader,
          fragmentShader: fireworkFragmentShader,
          transparent: true,
          uniforms: {
            uSize: new THREE.Uniform(size),
            uResolution: new THREE.Uniform(sizes.resolution),
            uTexture:  new THREE.Uniform(texture),
            uColor: new THREE.Uniform(color),
            uProgress: new THREE.Uniform(0),
          },
          transparent: true,
          blending: THREE.AdditiveBlending,
          depthWrite: false,
        });

        const firework = new THREE.Points(geometry, material);
        firework.position.copy(position);
        scene.add(firework);

        const destroy = () => {
          scene.remove(firework);
          geometry.dispose();
          material.dispose();
        };

        //animate
        gsap.to(material.uniforms.uProgress, {
          value: 1,
          duration: 3,
          ease: 'linear',
          onComplete: destroy,
        });
      };

      const createRandomFirework = () => {
        const count = Math.round(400 + Math.random() * 1000);
        const position = new THREE.Vector3(
          (Math.random() - 0.5) * 2,
          Math.random(),
          (Math.random() - 0.5) * 2
        );
        const size = 0.1 + Math.random() * 0.1;
        const texture = textures[Math.floor(Math.random() * textures.length)];
        const redius = 0.5 + Math.random();
        const color = new THREE.Color();
        color.setHSL(Math.random(), 1, 0.7);

        creatFirework(count, position, size, texture, redius, color);
      };
      createRandomFirework();

      window.addEventListener('click', createRandomFirework);
      // 监听窗口大小变化
      window.addEventListener('resize', onWindowResize, false);

      function onWindowResize() {
        sizes.Width = window.innerWidth;
        sizes.Height = window.innerHeight;
        sizes.pixelRatio = sizes.pixelRatio;
        sizes.resolution.set(sizes.Width * sizes.pixelRatio, sizes.Height * sizes.pixelRatio);

        camera.aspect = sizes.innerWidth / sizes.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(sizes.Width, sizes.Height);
        renderer.setPixelRatio(sizes.pixelRatio);
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