// ==== Image (image) ====
float q(float b){
  return(9.8696044*b)/(4.+sqrt(34.+39.4784176*b*b));
}
float m(float d,float b){
  float h=abs(b),k=abs(d);
  if(h>k){
    float e=q(d/b);
    return b<0.?(d<0.?e-3.14159265:e+3.14159265):e;
  }
  else{
    float e=q(b/d);
    return d<0.?-1.57079632-e:1.57079632-e;
  }
}
mat2 i(float e){
  float d=cos(e),s=sin(e);
  return mat2(d,-s,s,d);
}
float y(vec3 a,vec3 h){
  vec3 d=abs(a)-h;
  return length(max(d,0.))+min(max(d.x,max(d.y,d.z)),0.);
}
float A(vec3 a){
  return dot(sin(a),cos(a.zxy));
}
float B(vec3 a){
  float d=0.,e=.5;
  for(int f=0;f<7;f++){
    d+=e*abs(A(a));
    a*=3.98;
    e*=.4;
  }
  return d;
}
vec4 j(vec3 a,float c){
  float d=0.;
  vec3 o=a;
  float p=length(a),r=log(p),v=acos(a.z/max(p,.0001)),x=m(a.y,a.x);
  vec3 C=vec3(r-c*1.,v,x+c*0.);
  float G=exp(r),g=B(C*2.);
  a+=vec3(cos(g*6.28),sin(g*6.28),cos(g*3.14))*.15;
  for(int f=0;f<2;f++){
    float h=length(a.xy),k=m(a.y,a.x);
    k+=c*.1+float(f)*.4;
    a.x=h*cos(k);
    a.y=h*sin(k);
    a.xy=abs(a.xy)-vec2(0.,-.8);
    a.xy*=i(.523);
    float l=m(a.z,a.x),t=length(a.xz);
    l-=h*.15;
    a.x=t*cos(l);
    a.z=t*sin(l);
    a.yz=abs(a.yz)-vec2(0.,.5);
    a.yz*=i(.785);
  }
  float u=y(a,vec3(0.,1.,.3)),n=length(a.xy)-.05-g*.08,D=min(u,n);
  d+=(.15+.1*g)/(.05+n*n*15.);
  d+=.02*(1./(.01+abs(u)));
  float E=m(o.z,length(o.xy))+g*.5;
  return vec4(D*.3,d,E,length(a));
}
vec3 F(vec3 a,float c){
  vec2 d=vec2(1.,1.);
  return normalize(vec3(j(a+d.xyy,c).x-j(a-d.xyy,c).x,j(a+d.yxy,c).x-j(a-d.yxy,c).x,j(a+d.yyx,c).x-j(a-d.yyx,c).x));
}
void mainImage(out vec4 C,in vec2 D){
  vec2 r=(D-iResolution.xy*.5)/iResolution.y;
  float c=iTime*.5;
  vec3 n=vec3(1.,0.,-5.5),l=normalize(vec3(r,1.5));
  n.xz*=i(c*.15);
  l.xz*=i(c*.15);
  n.yz*=i(c*.08);
  l.yz*=i(c*.08);
  float k=.1,t=0.;
  vec4 h=vec4(0.);
  bool u=false;
  vec3 v=vec3(0.);
  float o=1.;
  for(int f=0;f<43;f++){
    vec3 a=n+l*k;
    h=j(a,c);
    float x=h.y;
    t+=x*(h.x*1.+.21);
    vec3 E=.5+.5*cos(vec3(0.,1.5,3.)+(h.z*.4+c*.3)*6.28318);
    v+=E*x*.012*o;
    o*=exp(-h.x*0.);
    if(h.x<.0005){
      u=true;
      break;
    }
    if(k>40.||o<.01)break;
    k+=max(h.x,.008);
  }
  vec3 d=vec3(0.);
  if(u){
    vec3 a=n+l*k,g=F(a,c),p=normalize(vec3(1.,2.,-3.));
    p.xz*=i(c);
    float G=max(dot(g,p),0.),H=pow(max(dot(reflect(-p,g),-l),0.),32.),I=clamp(h.w*.25,0.,1.),J=h.z*.5+c*.05;
    vec3 K=.5+.5*cos(vec3(0.,2.,4.)+J*6.28318);
    d=K*(G*.85+.15)+vec3(H*.7);
    d*=I;
    d=mix(d,vec3(.002,.005,.012),1.-exp(-.05*k*k));
  }
  else d=vec3(.002,.004,.008)*(1.+r.y*.5);
  d+=v*1.6;
  vec3 L=.5+.5*cos(vec3(1.,3.,5.)+(c*.2)*6.28318);
  d+=L*t*.035;
  d=pow(d,vec3(.4545));
  d=clamp(d,0.,1.);
  d=d*d*(3.6-2.4*d);
  C=vec4(d,1.);
}
