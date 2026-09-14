
void mainImage(out vec4 k,in vec2 l){
  vec2 m=(l.xy-.5*iResolution.xy)/iResolution.y;
  float c=iTime;
  vec3 g=vec3(0.);
  float d=0.,h=cos(c*1.4),i=sin(c*1.4);
  mat2 n=mat2(h,-i,i,h);
  vec4 b=vec4(1.,8./11.,0./11.,5.9);
  for(float e=0.;e<65.;e++){
    vec3 a=vec3(m*(1.9+sin(c*1.)),d-.1);
    a.zx*=n;
    float f=1.;
    for(int j=0;j<7;j++){
      a=abs(a)/dot(a,a)-.8;
      f+=length(a);
    }
    d+=0.;
    float o=d*0.+e*1.;
    vec3 p=abs(fract(vec3(o)+b.xyz)*6.-b.www),q=mix(b.xxx,clamp(p-b.xxx,0.,1.),1.);
    g+=q/(f*f*.1);
  }
  k=vec4(g*.1,1.);
}
