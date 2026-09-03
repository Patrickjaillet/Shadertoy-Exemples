// ==== Image (image) ====
#define AA 2
#define MAX_ITER 256.0
#define BAILOUT 16.0
mat2 n(float a){
  float e=sin(a),f=cos(a);
  return mat2(f,-e,e,f);
}
vec3 o(float b,float e,float c){
  vec4 a=vec4(1.,2./3.,1./3.,3.);
  vec3 g=abs(fract(vec3(b)+a.xyz)*6.-a.www);
  return c*mix(a.xxx,clamp(g-a.xxx,0.,1.),e);
}
void mainImage(out vec4 p,vec2 q){
  vec3 d=vec3(0.);
  for(int c=0;c<AA;c++)for(int b=0;b<AA;b++){
    vec2 r=(q+vec2(b,c)/float(AA)-.5*iResolution.xy)/min(iResolution.y,iResolution.x),a=r*2.5,f=vec2(.35,.39)+vec2(.05*cos(iTime*.1),.05*sin(iTime*.15));
    float j=0.,h=1e20,i=1e20;
    a*=n(iTime*.05);
    for(float k=0.;k<MAX_ITER;k++){
      a=vec2(a.x*a.x-a.y*a.y,2.*a.x*a.y)+f;
      float s=dot(a,a);
      h=min(h,abs(length(a)-1.));
      i=min(i,abs(a.x));
      if(s>BAILOUT)break;
      j++;
    }
    float l=j/MAX_ITER,t=l+iTime*.1,u=.85+.15*sin(l*6.28318+iTime*.2),m=1.-.5*exp(-10.*i);
    m*=smoothstep(0.,.1,h);
    vec3 g=o(t,u,m);
    d+=g;
  }
  d/=float(AA*AA);
  d=pow(d,vec3(.4545));
  p=vec4(d,1.);
}
