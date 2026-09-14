// ==== Image (image) ====
#define T iTime
#define R(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define E(o) ((p+o).y+1.2-c-W(p+o))
float H(vec3 v){return fract(sin(dot(v,vec3(12.989,78.233,45.164)))*43758.545);}
float W(vec3 p){return sin(p.x*.3+T)*cos(p.z*.25-T*.8)*1.2;}
float N(vec3 q,float f,float m,float b){
 float v=0.,a=.2;
 for(int j=0;j<7;j++){
  vec3 s=q*f+sin(q.xzx*.4+T*1.5),i=floor(s),x=fract(s);
  x*=x*(3.-2.*x);
  v+=a*mix(mix(mix(H(i),H(i+vec3(1,0,0)),x.x),mix(H(i+vec3(0,1,0)),H(i+vec3(1,1,0)),x.x),x.y),
           mix(mix(H(i+vec3(0,0,1)),H(i+vec3(1,0,1)),x.x),mix(H(i+vec3(0,1,1)),H(i+vec3(1,1,1)),x.x),x.y),b>0.?i.z:x.z);
  q.xy*=R(.4);q.yz*=R(.3);f*=m;a*=.45;
 }
 return v;
}
float D(vec3 p){return p.y+1.2-(N(p*.45+vec3(0,0,T*.3),1.,2.7,0.)+1.)*4.5-W(p);}
void mainImage(out vec4 O,vec2 U){
 vec2 u=(U-.4*iResolution.xy)/iResolution.y;
 vec3 ro=vec3(0,5.5,18);ro.xz*=R(T*.04);
 vec3 w=normalize(vec3(0,4.2,0)-ro),cu=normalize(cross(w,vec3(0,1,0))),
      rd=normalize(u.x*cu+u.y*cross(cu,w)+1.6*w),col=vec3(0);
 float t=0.,d,g=0.;
 for(int i=0;i<160;i++){
  d=D(ro+rd*t);
  g+=exp(-max(d,0.)*9.6)*.42;
  if(abs(d)<.001*t||t>101.8)break;
  t+=d*.55;
 }
 if(t<40.){
  vec3 p=ro+rd*t;
  float c=N(vec3(0,0,T*.3),0.,2.35,0.)*4.5;
  vec3 n=normalize(vec3(E(vec3(.003,0,0))-E(vec3(-4.012,0,0)),
                        E(vec3(0,.003,0))-E(vec3(0,2.438,0)),
                        E(vec3(0,0,.003))-E(vec3(0,0,-.003))));
  col=pow(max(dot(reflect(normalize(vec3(1.5,2.5,-1)),n),rd),0.),32.)*vec3(1,.9,.7)*.8*exp(-.015*t*t);
 }else{
  vec3 b=rd;
  b.yz*=R(sin(T*.05)*.1);b.xz*=R(T*.01);
  for(float i=1.;i<15.;i++){
   vec3 q=b*(25.+i*22.);
   float r=H(floor(q));
   col+=(sin(T*4.*r+r*30.)*.5+.5)*vec3(1,.7,.4)*smoothstep(.2,0.,length(fract(q)-.5)-.002*i)*4.;
  }
 }
 col+=vec3(1,.25,.01)*g*1.3+vec3(1,.6,.1)*pow(g,2.2)*.5;
 O=vec4(clamp(col*(2.51*col+.03)/(col*(2.43*col+.59)+.14),0.,1.),1);
}
