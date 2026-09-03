// ==== Image (image) ====
mat2 a(float b) {
  float c=sin(b),d=cos(b);
  return mat2(d,-c,c,d);
} vec2 e(vec3 f) {
  vec2 g=vec2(f.z+.3,1.);
  vec2 h=abs(f.xy)-vec2(1.3,.7);
  float i=length(max(h,0.))+min(max(h.x,h.y),0.)-.15;
  vec2 j=abs(f.xy)-vec2(1.5,.9);
  float k=length(max(j,0.))+min(max(j.x,j.y),0.)-.05;
  float l=max(k,-i);
  vec2 m=vec2(l,abs(f.z)-.1);
  float n=min(max(m.x,m.y),0.)+length(max(m,0.));
  vec2 o=abs(f.xy)-vec2(1.38,.78);
  float p=length(max(o,0.))+min(max(o.x,o.y),0.);
  float q=abs(p-.02)-.015;
  float r=abs(f.z-.1)-.02;
  float s=max(q,r);
  n=min(n,s);
  n=max(n,-f.z-.15);
  g=g.x<n?g:vec2(n,2.);
  float t=iTime*2.5;
  float u=sin(iTime*1.3)*1.1;
  float v=-.45+abs(sin(t))*1.15;
  float w=mix(.2,-.15,(v+.45)/1.15);
  vec3 x=vec3(u,v,w);
  vec3 y=f-x;
  float z=smoothstep(.15,0.,v+.45);
  vec3 aa=vec3(1.+z*.4,1.-z*.3,1.+z*.4);
  y/=aa;
  float ab=length(y)*min(aa.x,min(aa.y,aa.z))-.25;
  g=g.x<ab?g:vec2(ab,3.);
  return g;
} vec3 ac(vec3 f) {
  vec2 m=vec2(.002,0.);
  return normalize(vec3(e(f+m.xyy).x-e(f-m.xyy).x,e(f+m.yxy).x-e(f-m.yxy).x,e(f+m.yyx).x-e(f-m.yyx).x));
} float ad(vec3 ae,vec3 af) {
  float ag=1.;
  float t=.02;
  for(int ah=0;ah<64;ah++) {
    float ai=e(ae+af*t).x;
    ag=min(ag,12.*ai/t);
    t+=clamp(ai,.02,.1);
    if(ai<.001||t>5.)break;
  } return clamp(ag,0.,1.);
} void mainImage(out vec4 fragColor,in vec2 fragCoord) {
  vec2 aj=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec3 ae=vec3(0.,0.,2.5);
  vec3 af=normalize(vec3(aj,-1.));
  float t=0.;
  vec2 ak=vec2(0.);
  for(int ah=0;ah<150;ah++) {
    vec3 f=ae+af*t;
    ak=e(f);
    if(ak.x<.001||t>10.)break;
    t+=ak.x*.85;
  } vec3 al=vec3(.01,.01,.015);
  if(t<10.) {
    vec3 f=ae+af*t;
    vec3 am=ac(f);
    vec3 an=normalize(vec3(.8,1.,1.5));
    vec3 ao=-af;
    vec3 ai=normalize(an+ao);
    float ap=clamp(dot(am,an),0.,1.);
    float aq=pow(clamp(dot(am,ai),0.,1.),32.);
    float ar=pow(clamp(1.-dot(am,ao),0.,1.),5.);
    float as=ad(f+am*.005,an);
    vec3 at=reflect(af,am);
    float au=smoothstep(-.2,.2,at.y);
    vec3 av=mix(vec3(.02,.04,.08),vec3(.4,.5,.7),au);
    vec3 aw=vec3(1.);
    if(ak.y==1.) {
      vec2 ax=f.xy*2.5;
      float ay=mod(floor(ax.x)+floor(ax.y),2.);
      aw=mix(vec3(.06,.08,.12),vec3(.03,.04,.06),ay);
      aq*=.1;
    } else if(ak.y==2.) {
      aw=vec3(.7,.45,.15);
      aw+=av*.3;
      aq=pow(clamp(dot(am,ai),0.,1.),64.)*1.5;
      aw*=.8+.2*cos(f.x*25.)*sin(f.y*25.);
    } else if(ak.y==3.) {
      aw=vec3(.85,.05,.05);
      aw+=av*.15;
      aq=pow(clamp(dot(am,ai),0.,1.),128.)*3.;
      aw=mix(aw,vec3(1.,.9,.9),ar*.7);
    } vec3 az=vec3(0.);
    az+=1.6*ap*as*vec3(1.,.95,.85);
    az+=.4*vec3(.2,.3,.5);
    az+=.5*ar*as*vec3(1.);
    al=aw*az+aq*as;
    float aaa=clamp(1.-t*.05,0.,1.);
    al*=aaa;
  } al=pow(al,vec3(.4545));
  fragColor=vec4(al,1.);
}
