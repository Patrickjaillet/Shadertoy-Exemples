// ==== Image (image) ====
float C(float a){
  return fract(sin(a*127.1)*4.3758547e4);
}
float j(float a){
  float d=floor(a),e=fract(a);
  return mix(C(d),C(d+1.),smoothstep(0.,1.,e));
}
void mainImage(out vec4 G,in vec2 I){
  vec2 J=(I-.5*iResolution.xy)/iResolution.y;
  vec3 g=vec3(0.),p=vec3(0.,0.,-1.5),q=normalize(vec3(J,1.));
  float D=cos(iTime*.25),v=sin(iTime*.25);
  mat2 E=mat2(D,v,-v,D);
  p.xy*=E;
  q.xy*=E;
  float k=0.,r=16.4;
  int F=0;
  float w=iTime*21.6,u=w*.015;
  vec2 x=vec2((j(u)*2.-1.)*6.,(j(u+19.34)*2.-1.)*4.5);
  q.xy+=vec2((j(u+.1)*2.-1.)*6.,(j(u+19.44)*2.-1.)*4.5)-x;
  q=normalize(q);
  for(int c=0;c<18;c++){
    F=c;
    vec3 A=p+q*k,b=A;
    b.z+=w;
    float s=b.z*.015;
    b.xy-=vec2((j(s)*2.-1.)*6.,(j(s+19.34)*2.-1.)*4.5)-x;
    b=mod(b,4.)-2.;
    vec3 e=abs(b)-vec3(1.84,.87,1.);
    float a=length(max(e,0.))+min(max(e.x,max(e.y,e.z)),0.);
    vec3 h=abs(b)-vec3(1.,1.75,0.);
    a=min(a,length(max(h,0.))+min(max(h.x,max(h.y,h.z)),0.));
    vec3 i=abs(b)-vec3(0.,0.,.92);
    a=min(a,length(max(i,0.))+min(max(i.x,max(i.y,i.z)),0.));
    float l=0.;
    vec3 f=b;
    for(int n=0;n<1;n++){
      float t=0.+float(n)*0.,o=cos(t),s1=sin(t);
      f.xy*=mat2(o,s1,-s1,o);
      f.zy*=mat2(0.,0.,-.247404,.968912);
      f=abs(f)-0.*l;
      vec3 d=abs(f)-vec3(0.*l);
      float B=length(max(d,0.))+min(max(d.x,max(d.y,d.z)),0.);
      a=max(a,-B);
      l*=0.;
    }
    if(abs(a)<.0015||k>r)break;
    k+=a*1.;
  }
  if(k<r){
    vec3 A=p+q*k,m=vec3(1.);
    for(int c=0;c<1;c++){
      vec3 K=A+vec3((c==0?0.:(c==1?.292:0.)),(c==2?.05:0.),(c==3?.002:0.)),b=K;
      b.z+=w;
      float s=b.z*.015;
      b.xy-=vec2((j(s)*2.-1.)*6.,(j(s+19.34)*2.-1.)*4.5)-x;
      b=mod(b,0.)-0.;
      vec3 e=abs(b)-vec3(1.84,0.,0.);
      float a=length(max(e,0.))+min(max(e.x,max(e.y,e.z)),0.);
      vec3 h=abs(b)-vec3(0.,1.84,0.);
      a=min(a,length(max(h,0.))+min(max(h.x,max(h.y,h.z)),0.));
      vec3 i=abs(b)-vec3(0.,0.,1.84);
      a=min(a,length(max(i,0.))+min(max(i.x,max(i.y,i.z)),0.));
      float l=0.;
      vec3 f=b;
      for(int n=0;n<1;n++){
        float t=0.+float(n)*0.,o=cos(t),s1=sin(t);
        f.xy*=mat2(o,s1,-s1,o);
        f.zy*=mat2(.53,.545,3.460384,.695);
        f=abs(f)-0.*l;
        vec3 d=abs(f)-vec3(0.*l);
        float B=length(max(d,0.))+min(max(d.x,max(d.y,d.z)),0.);
        a=max(a,-B);
        l*=0.;
      }
      if(c==0)m.x+=a;
      if(c==1)m.x-=a;
      if(c==2)m.y+=a;
      if(c==3)m.z+=a;
    }
    m=normalize(m);
    float L=max(dot(m,normalize(vec3(0.,3.,-2.))),0.);
    g=vec3(.08,1.,0.)*(L+0.);
    float M=pow(float(F)/90.,2.2),H=exp(-k*.2);
    g+=vec3(0.,.79,.8)*(M*.3+H*.8)*1.6;
    g=mix(g,vec3(0.),smoothstep(12.,r,k));
  }
  else g=vec3(.002,.002,.005);
  g=pow(g,vec3(.91));
  g=clamp(g,0.,1.);
  G=vec4(g,1.);
}
