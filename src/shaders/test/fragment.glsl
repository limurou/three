
varying vec2 vUv;
uniform float uTime;

vec3 palette( float t ) {
      vec3 a = vec3(0.5, 0.5, 0.5);
      vec3 b = vec3(0.5, 0.5, 0.5);
      vec3 c = vec3(1.0, 1.0, 1.0);
      vec3 d = vec3(0.263, 0.416, 0.557);
      return a + b * cos( 6.28318*(c*t+d) );
}

void main()
{  
      vec2 cv = (vUv - 0.5) * 2.0;
      
      vec2 uv = vUv;
      vec3 finalColor = vec3(0.0);
      for (float i = 0.0; i< 3.0; i++){
            
      cv = fract(cv * 2.0) - 0.5;

      float d = length(cv) * exp(-length(uv));
      vec3 col = palette(length(uv) + i*0.4 + uTime * 0.4);

      d = sin(d * 8. + uTime )/8.;
      d = abs(d);
      d = 0.01/d;
      finalColor += col * d;
      };
      
      gl_FragColor = vec4(finalColor, finalColor.r);

}