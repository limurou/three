
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
import { RGBELoader } from 'three/addons/loaders/RGBELoader.js';
import testVertexShader from '../shaders/test/vertex.glsl';
import testFragmentShader from '../shaders/test/fragment.glsl';


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

      let renderer,mixer;
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

      // 添加雾效果

const fog = new THREE.Fog(0x70c1ff, 1, 30); // 颜色为白色，近裁剪距离为1，远裁剪距离为15
scene.fog = fog;

        //环境贴图
        const rgbeLoader = new RGBELoader();
rgbeLoader.load('./hdr1.hdr', (texture)=> {
    
    texture.mapping = THREE.EquirectangularReflectionMapping
    scene.background = texture
    scene.environment = texture
})
//地板
const planeGeometry = new THREE.PlaneGeometry(100, 100);
const textLoader = new THREE.TextureLoader();
const texture = textLoader.load('./noiseTexture.png'); // 加载纹理
texture.wrapS = THREE.RepeatWrapping; // U 方向重复
texture.wrapT = THREE.RepeatWrapping; // V 方向重复
texture.repeat.set(32, 32);
const planeMaterial = new THREE.MeshBasicMaterial({ side: THREE.DoubleSide, map: texture }); 
const plane = new THREE.Mesh(planeGeometry, planeMaterial);

scene.add(plane);
plane.rotation.x = -Math.PI/2;
    const geometry2 = new THREE.PlaneGeometry(1 , 1);
    const material2 = new THREE.ShaderMaterial( { 
  uniforms:{
    
    uTime: {value:0}
  },
  vertexShader: testVertexShader,
  fragmentShader: testFragmentShader,
  side: THREE.DoubleSide,
  transparent: true,
  opacity: 0.2,
  blending: THREE.AdditiveBlending,
 
 } );
const plane2 = new THREE.Mesh( geometry2, material2 );
plane2.receiveShadow = true;
plane2.castShadow = true;
scene.add(plane2);

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

    function crossPlay(curAction,newAction) {
  curAction.fadeOut(0.3);
  
  newAction.reset();
  newAction.setEffectiveWeight(1);
  newAction.play();
  newAction.fadeIn(0.3);
};

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
        
        loader.load('./1.glb', (gltf) => {
        const model = gltf.scene;
        scene.add(model)
        });

        loader.load('./fireman.glb', (gltf) => {
        const model = gltf.scene;
        scene.add(model);
         mixer = new THREE.AnimationMixer(gltf.scene);
  

mixer.clipAction(gltf.animations[5]).play();

        })


        loader.load( './Xbot.glb', function (gltf){
  const model = gltf.scene;
 
  //model.add( camera );
  //camera.position.set(0,5,-2);
  //camera.lookAt( new THREE.Vector3(0,1,0))
  model.position.set(2,0,0);
	scene.add( model );
  model.traverse( function ( object ) {

						if ( object.isMesh ) object.castShadow = true;

						});

  

    mixer = new THREE.AnimationMixer(gltf.scene);
  const idea = mixer.clipAction(gltf.animations[0]);
  const walk = mixer.clipAction(gltf.animations[3]);

mixer.clipAction(gltf.animations[0]).play();


let prePos
window.addEventListener('mousemove', (e)=>{
    
    
    if (prePos){
      //model.rotateY(( prePos - e.clientX ) * 0.02)
    }
    prePos = e.clientX
});

let isChangeWalk = true;
window.addEventListener('keydown', (e) => {
  if (e.key === 'w') {
    model.translateZ(0.1);
    if(isChangeWalk) {
      crossPlay(idea,walk);
      isChangeWalk = false;

    }
  }
  if (e.key === 's') {
    model.translateZ(-0.1);
    if(isChangeWalk) {
      crossPlay(idea,walk);
      isChangeWalk = false;

    }
  }
  if (e.key === 'a') {
    model.translateX(0.1);
    if(isChangeWalk) {
      crossPlay(idea,walk);
      isChangeWalk = false;

    }
  }
  if (e.key === 'd') {
    model.translateX(-0.1);
    if(isChangeWalk) {
      crossPlay(idea,walk);
      isChangeWalk = false;

    }
  }

});
window.addEventListener('keyup', (e) =>{
  if(e.key ==='w'||'s'||'a'||'d') {
    crossPlay(walk,idea);
    isChangeWalk = true;
  }
})



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
        const delta = clock.getDelta();
        const elapsedTime = clock.getElapsedTime();
        material2.uniforms.uTime.value = elapsedTime;

        
    if(mixer) {
      mixer.update(delta);
    }
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
