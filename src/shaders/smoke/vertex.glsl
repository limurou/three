uniform float uTime;
uniform sampler2D uTexture;

varying vec2 vUv;

#include ../includes/rotate2D.glsl
void main () {
    vec3 newPosition = position;

    float twistPerlin = texture2D(uTexture,
                             vec2(0.5, uv.y * 0.2 -uTime * 0.005)
                             ).r;

    float angle = twistPerlin * 3.14159 * 2.0;
    newPosition.xz = rotate(newPosition.xz, angle);

    vec2 windOffset = vec2(texture2D(uTexture, vec2(0.5, uTime *0.001)).r - 0.5,
                           texture2D(uTexture, vec2(0.5, uTime *0.001 + 0.1)).r - 0.5);
    windOffset *= pow(uv.y, 4.0) * 10.0;
    newPosition.xz += windOffset;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
    vUv = uv;
}