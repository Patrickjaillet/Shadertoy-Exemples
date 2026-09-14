
void mainImage(out vec4 l,in vec2 m){
  vec2 n=iResolution.xy;
  float b=iTime*.3;
  const float o=1./3.14159265359;
  float h=b*.1,i=sin(h),ka=cos(h);
  mat2 j=mat2(ka,-i,i,ka);
  float p=sin(b*.5)*.4+cos(b*.25)*.2,q=cos(b*.4)*.3+sin(b*1.)*.1,r=b*o,e=0.,c=0.,d=0.,f=0.;
  const int s=117;
  for(int g=0;g<s;g++){
    float t=float(g);
    vec3 a=vec3(m/n.y*e,e);
    a.xz*=j;
    a.yz*=j;
    a.x-=p;
    a.y-=q;
    a.z+=r;
    a+=.9-t/20000.;
    a.xy=mod(a.xy-1.,8.)-1.;
    d=4.;
    for(int k=0;k<5;k++){
      a=mod(a-.9,2.)-1.;
      c=length(a*a)*.8;
      d/=c;
      a=abs(a)/c;
      a.y+=.2;
    }
    c=a.x/d;
    e+=abs(c);
    f+=.0001/(.012+abs(c)*4.8);
    if(f>=1.)break;
  }
  vec3 u=pow(clamp(vec3(f),0.,1.),vec3(3.3));
  l=vec4(u,1.);
}
