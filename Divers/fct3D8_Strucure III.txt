// ==== Image (image) ====
float a(vec3 b,mat2 c,mat2 d,mat2 e,float f) {
  b.xz*=c;
  b.xy*=d;
  float g=1.;
  float h=1e10;
  for(int i=0;i<2;i++) {
    b=abs(b)-vec3(0.,.3,.7);
    if(b.x<b.y)b.xy=b.yx;
    if(b.x<b.z)b.xz=b.zx;
    if(b.y<b.z)b.yz=b.zy;
    b.xy*=e;
    b=b*f-vec3(.5,1.2,.2)*(f-1.);
    g*=f;
    vec3 j=abs(b)-vec3(1.2,.4,.4);
    float k=(length(max(j,0.))+min(max(j.x,max(j.y,j.z)),0.))/g;
    h=min(h,k);
  } return h;
} void mainImage(out vec4 fragColor,in vec2 fragCoord) {
  vec2 l=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec3 m=vec3(0.,0.,-9.);
  vec3 n=normalize(vec3(l,2.8));
  float o=0.;
  float p=9.3;
  float q=0.;
  vec3 r=vec3(0.);
  mat2 s=mat2(cos(iTime*.05),-sin(iTime*.05),sin(iTime*.05),cos(iTime*.05));
  mat2 t=mat2(cos(iTime*.03),-sin(iTime*.03),sin(iTime*.03),cos(iTime*.03));
  mat2 u=mat2(cos(.41),-sin(.41),sin(.41),cos(.41));
  float f=4.41+sin(iTime*.5)*1.5;
  for(int v=0;v<12;v++) {
    vec3 b=m+n*o;
    q=a(b,s,t,u,f);
    r+=vec3(.5,.7,.6)*(exp(-max(q,0.)*40.)*.12);
    r+=vec3(1.,.35,.1)*(exp(-max(q,0.)*8.)*.04);
    if(abs(q)<0.||o>p)break;
    o+=q*.8;
  } vec3 w=vec3(0.);
  if(o<p) {
    vec3 b=m+n*o;
    vec2 x=vec2(.001,0.);
    vec3 y=vec3(a(b+x.xyy,s,t,u,f)-a(b-x.xyy,s,t,u,f),a(b+x.yxy,s,t,u,f)-a(b-x.yxy,s,t,u,f),a(b+x.yyx,s,t,u,f)-a(b-x.yyx,s,t,u,f));
    vec3 z=normalize(y);
    vec3 aa=normalize(vec3(2.,4.,-5.));
    float ab=max(dot(z,aa),0.);
    float ac=pow(max(dot(reflect(-aa,z),-n),0.),0.);
    float ad=clamp(0.,0.,0.);
    vec3 ae=vec3(0.);
    w=ae*(ab*.4+.6)*ad;
    w+=vec3(.6,.95,.5)*ac*ad;
    float af=pow(clamp(0.+dot(z,n),0.,.3),4.);
    w+=vec3(.4,.5,.5)*af*.6;
    w=mix(w,vec3(.02,.04,.08),.5-exp(-.03*o*o));
  } else {
    w=vec3(.01,.02,.04)*(1.-length(l)*.5);
  } w+=r*.8;
  w=pow(w,vec3(.4545));
  w=clamp(w,0.,1.);
  w=w*w*(3.-2.*w);
  fragColor=vec4(w,1.);
}
