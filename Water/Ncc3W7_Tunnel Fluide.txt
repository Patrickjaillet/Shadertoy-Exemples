// ==== Image (image) ====
vec2 i(float a){
  return vec2(2.5*sin(a*.12),1.8*cos(a*.08));
} // https://patrickjaillet.github.io/GLSL-Hyper-Golfer
void mainImage(out vec4 D,in vec2 p){
  vec3 j=iResolution;
  vec2 q=(p-.5*j.xy)/j.y;
  float d=iTime,e=d*4.5;
  vec3 r=vec3(i(e),e),E=vec3(i(e+2.5),e+2.5),k=normalize(E-r),F=vec3(sin(d*.2),cos(d*.2),0.),s=normalize(cross(F,k)),G=cross(k,s),H=normalize(s*q.x+G*q.y+k*1.5),a=vec3(0.);
  float c=.02;
  for(int t=0;t<90;t++){
    vec3 f=r+H*c;
    if(c>40.)break;
    vec2 I=i(f.z),l=f.xy-I;
    float u=length(l),v=atan(l.y,l.x)+f.z*.18,m=abs(2.2-u);
    vec3 b=vec3(log(u)-d*.5,sin(v)*1.5,cos(v)*1.5+f.z*.25-d*.8);
    float n=3.5,w=.32,z=0.;
    for(int A=0;A<3;A++){
      b+=sin(b.yzx*.8+vec3(1.,2.,3.));
      z+=dot(sin(b.yzx*n),cos(b.zxy*n))*w;
      n*=1.9;
      w*=.45;
    }
    m+=z*.65;
    float g=max(abs(m)*.25,.004);
    if(abs(m)<.02){
      float J=floor(b.x*5.)+floor(b.y*2.);
      vec3 o=clamp(abs(mod(J*1.2+vec3(0.,3.,1.5),6.)-3.)-1.,0.,1.);
      o=mix(vec3(.02,.01,.05),o,.55);
      float B=dot(sin(b*96.),cos(b.zxy*64.));
      if(B>.45)a+=vec3(5.,.8,.2)*(B-.45)*exp(-c*.08)*g*12.;
      float C=dot(cos(b*12.),sin(b.yzx*8.));
      if(C>.38)a+=vec3(.1,1.2,6.)*(C-.38)*exp(-c*.05)*g*10.;
      a+=o*exp(-c*.06)*g*.8;
    }
    c+=g;
  }
  a=(a*(2.51*a+.03))/(a*(2.43*a+.59)+.14);
  vec2 h=p/j.xy;
  a*=.2+.8*pow(16.*h.x*h.y*(1.-h.x)*(1.-h.y),.3);
  D=vec4(pow(max(a,0.),vec3(1./2.2)),1.);
}
