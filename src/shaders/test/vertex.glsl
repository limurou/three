varying vec2 vUv;
uniform float uTime;

void main() {
    vUv = uv;
    
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    modelPosition.z += sin(uTime * 2.0 + vUv.x * 20.0) * 0.5; // 修改 z 轴，形成 10 个起伏
    
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;

    gl_Position = projectedPosition;
}