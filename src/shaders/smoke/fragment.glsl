uniform float uTime;
uniform sampler2D uTexture;

varying vec2 vUv;

void main () {
    vec2 smokeUv = vUv;
    smokeUv.x *=0.5;
    smokeUv.y *=0.5;
    smokeUv.y -= uTime * 0.1;


    float smoke = texture2D(uTexture, smokeUv).r;
    smoke = smoothstep(0.4, 1.0, smoke);

    smoke *= smoothstep(0.0, 0.2, vUv.x);
    smoke *= smoothstep(1.0, 0.8, vUv.x);
    smoke *= smoothstep(0.0, 0.1, vUv.y);
    smoke *= smoothstep(1.0, 0.4, vUv.y);

    gl_FragColor = vec4(1.0, 1.0, 1.0, smoke);
    
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}