
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
