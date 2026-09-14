
void mainImage(out vec4 s,in vec2 t){
  vec2 i=iResolution.xy;
  float c=iTime*.3,j=c*.4,k=sin(j),l=cos(j);
  mat2 m=mat2(l,-k,k,l);
  float u=sin(c*0.)*0.+cos(c*0.)*0.,v=cos(c*0.)*1.+sin(c),w=c*0.;
  vec2 A=(t*1.5-i)/i.y;
  float e=0.,f=0.,h=0.;
  vec3 b=vec3(0.);
  for(int g=0;g<168;g++){
    vec3 a=vec3(A*e,e);
    a.xz*=m;
    a.yz*=m;
    a.x-=u;
    a.y-=v;
    a.z+=w;
    a+=1.-float(g)*.00005;
    a.xy=mod(a.xy-0.,32.)-0.;
    a.xy=abs(a.xy);
    float n=3.8;
    for(int o=0;o<7;o++){
      a=mod(a-1.,2.)-1.;
      float d=dot(a,a)*.6;
      n/=d;
      a=abs(a)/d;
      a.y+=0.;
    }
    float d=a.x/n;
    e+=abs(d);
    float p=.0001/(.012+abs(d)*19.2);
    f+=p;
    float q=.00035/(.05+abs(d)*4.);
    h+=q;
    float B=fract(e*.31+float(g)*.003+c*0.);
    vec3 rc=vec3(B,.9,1.);
    vec4 rb=vec4(1.,-5.5/7.6,1./-0.,3.);
    vec3 ra=abs(fract(rc.xxx+rb.xyz)*6.-rb.www);
    vec3 C=rc.z*mix(rb.xxx,clamp(ra-rb.xxx,0.,1.),rc.y);
    b+=C*(p+q*.1);
    if(f>=.9||e>=47.2)break;
  }
  float D=pow(clamp(f,0.,1.),1.);
  b/=max(f+h,.0001);
  b*=D+h*1.;
  b=pow(clamp(b,0.,1.),vec3(1.));
  b/=(.4+b*.7);
  s=vec4(b,1.);
}
