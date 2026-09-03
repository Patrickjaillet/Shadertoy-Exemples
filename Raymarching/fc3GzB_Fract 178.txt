// ==== Image (image) ====
mat2 l(float a){
  float b=sin(a),c=cos(a);
  return mat2(c,-b,b,c);
}
void mainImage(out vec4 m,in vec2 n){
  vec2 f=iResolution.xy;
  float o=iTime;
  vec4 g=vec4(0.);
  vec3 h=vec3(.9,.3,1.2),a;
  float b=0.;
  for(int c=0;c<60;c++){
    float p=float(c);
    a=vec3((n-.5*f)/f.y*b,b)-p/70687.7;
    mat2 d=l(o/8.);
    a.yz*=d*d;
    --a;
    a.yx*=d;
    float e=9.5;
    for(int i=0;i<7;i++){
      a=2.*clamp(a,-h,h)-a;
      float j=dot(a,a);
      a/=j;
      e/=j;
    }
    float k=a.z/e;
    b-=k;
    g+=exp(k*1097.8-sin(vec4(-3.5,2.7,8.,0.)*a.z-log(e)))/43.9;
  }
  m=g;
}
/*
mat2 rotate2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec4 o = vec4(0.0);
    
    vec3 f = vec3(0.9, 0.3, 1.2);
    vec3 p;
    float g = 0.0;
    
    for (int i_idx = 0; i_idx < 60; i_idx++) {
        float i = float(i_idx);
        p = vec3((fragCoord - 0.5 * r) / r.y * g, g) - i / 70687.7;
        
        mat2 M = rotate2D(t / 8.0);
        p.yz *= M * M;
        p -= 1.0;
        p.yx *= M;
        
        float S = 9.5;
        for (int j = 0; j < 7; j++) {
            p = 2.0 * clamp(p, -f, f) - p;
            float u = dot(p, p);
            p /= u;
            S /= u;
        }
        
        float e = p.z / S;
        g -= e;
        o += exp(e * 1097.8 - sin(vec4(-3.5, 2.7, 8.0, 0.0) * p.z - log(S))) / 43.9;
    }
    
    fragColor = o;
}
*/
