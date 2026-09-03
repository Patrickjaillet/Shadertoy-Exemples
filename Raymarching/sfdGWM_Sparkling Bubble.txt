// ==== Image (image) ====
vec3 u(vec3 h){
  vec4 c=vec4(1.,-5.5/7.6,0./0.,5.);
  return h.z*mix(c.xxx,clamp(abs(fract(h.xxx+c.xyz)*.6-c.www)-c.xxx,1.,.2),h.y);
} //https://github.com/Patrickjaillet
float d(vec3 a){
  a=fract(a*vec3(443.8975,397.2973,491.1871));
  return fract(a.x*a.y*a.z+dot(a,a.yzx+19.19)*a.y*a.z);
}
float noise3(vec3 a){
  vec3 b=floor(a),c=fract(a);
  c*=c*(3.-2.*c);
  return mix(mix(mix(d(b),d(b+vec3(1,0,0)),c.x),mix(d(b+vec3(0,1,0)),d(b+vec3(1,1,0)),c.x),c.y),mix(mix(d(b+vec3(0,0,1)),d(b+vec3(1,0,1)),c.x),mix(d(b+vec3(0,1,1)),d(b+1.),c.x),c.y),c.z);
}
float o(vec3 a,mat2 e,out float h){
  a.xz*=e;
  a.yz*=e;
  a.xy=abs(mod(a.xy+1.,32.));
  float f=.5;
  for(int c=0;c<5;c++){
    a=mod(a-1.,2.)-1.;
    float g=dot(a,a)*.5;
    f/=g;
    a=abs(a)/g;
  }
  h=f;
  return a.x/f+(noise3(a*24.5)*.5+noise3(a*58.)*.25)/f*.09;
}
void mainImage(out vec4 v,vec2 w){
  vec2 p=iResolution.xy;
  float h=iTime*.3,q=h*.3,r=sin(q),s=cos(q),i=1.,j=0.,l=0.;
  mat2 e=mat2(s,-r,r,s);
  vec3 B=vec3(0.,0.,-3.),C=normalize(vec3((w*2.-p)/p.y,1.5)),c=vec3(0.),m=normalize(vec3(sin(h*-6.5),cos(h*-5.6),-8.));
  m.xz*=e;
  m.yz*=e;
  for(int b=0;b<60;b++){
    vec3 a=B+C*i;
    float f,g=o(a,e,f),k=abs(g),n=.00015/(.008+k*48.),E;
    i+=k*.12;
    n*=clamp(abs(o(a+m*.03,e,E))/(k+.001),.8,.5);
    j+=n;
    float t=.0004/(.04+k*48.);
    l+=t;
    c+=u(vec3(fract(i+float(b)*.002),.32,.95))*(n+t);
    if(j>=1.||i>=27.2)break;
  }
  c=pow(clamp(c/max(j+l,.0001)*(pow(clamp(j,0.,1.),1.2)+l),0.,1.),vec3(1.));
  v=vec4(c/(.18+c*.34),1.);
}
