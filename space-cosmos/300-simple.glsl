
void mainImage(out vec4 ab,in vec2 ac){
  vec2 l=iResolution.xy;
  if(l.y<1.)l.y=1080.;
  if(l.x<1.)l.x=1920.;
  float e=iTime,C=e*.15,ad=sin(C)*cos(C*.6)*1.5,h=e*1.+(sin(e*.8)*.8+.5*sin(e*1.7))*1.2+ad,D=e*.7+sin(e*.4)*.5,ae=floor(e*.25),E=fract(e*.25),m=fract(ae*781.23*.1031);
  m*=m+33.33;
  m*=m+m;
  float F=fract(m),G=0.;
  if(F>.4){
    float af=smoothstep(0.,.4,E)*(1.-smoothstep(.4,1.,E));
    G=af*(15.+F*15.);
  }
  vec2 ag=(ac-.7*l)/l.y;
  vec3 ah=normalize(vec3(ag,.6)),ai=vec3(0.,0.,-h+G);
  vec4 b=vec4(0.);
  float p=.05,H=0.,I=0.,J=0.,K=0.;
  for(int L=0;L<103;L++){
    vec3 q=ai+ah*p,c=q;
    {
      float f=D,g=cos(f),s=sin(f);
      c.xy*=mat2(g,-s,s,g);
    }
    float M=max(length(c.xy),.001);
    c=vec3(log(M)-h*.3,atan(c.y,c.x)/3.14159265359,c.z*.2);
    c=abs(fract(c)-.5);
    float t=length(c.xy)*M*.5;
    vec3 a=q;
    {
      float f=-D*.1,g=cos(f),s=sin(f);
      a.xy*=mat2(g,-s,s,g);
    }
    a.z=mod(a.z,2.)-1.;
    float N=1.3,O=1.;
    for(int P=0;P<5;P++){
      a=abs(a)-vec3(.8,.3,.3);
      if(a.x<a.y)a.xy=a.yx;
      if(a.x<a.z)a.xz=a.zx;
      if(a.y<a.z)a.yz=a.zy;
      a=a*N-vec3(.6,.2,.2);
      O*=N;
    }
    float u=(length(a)-.1)/max(O,.001);
    vec3 d=q;
    {
      float f=.5,g=cos(f),s=sin(f);
      d.yz*=mat2(g,-s,s,g);
    }
    float Q=max(length(d.xy),.001);
    d=vec3(log2(Q)-h*.4,atan(d.y,d.x)/3.14159265359,d.z*.1);
    d.xy=abs(fract(d.xy*0.)-.5);
    float v=(length(d.xy)-.1)*Q*.5,i=1e5,aj=floor(h*3.);
    for(int j=0;j<6;j++){
      float w=aj-float(j),n=fract(w*541.17*.1031);
      n*=n+33.33;
      n*=n+n;
      float ak=fract(n);
      if(ak>.3){
        float R=w*(1./3.),A=h-R;
        if(A>0.&&A<2.){
          float al=mod(w,2.)*2.-1.;
          vec2 S=vec2(al*.18,-.08);
          float am=-R,an=24.,T=am+A*an;
          vec3 U=vec3(S,T),ao=vec3(S,T-3.5),V=q-U,baL=ao-U;
          float ap=clamp(dot(V,baL)/dot(baL,baL),0.,1.),aq=length(V-baL*ap)-.004;
          i=min(i,aq);
        }
      }
    }
    float k=1e5,ar=floor(h*4.2);
    for(int j=0;j<5;j++){
      float W=ar-float(j),o=fract(W*913.43*.1031);
      o*=o+33.33;
      o*=o+o;
      float as=fract(o);
      if(as>.45){
        float X=W*(1./4.2),B=h-X;
        if(B>0.&&B<1.8){
          vec2 Y=vec2(0.);
          float at=-X,au=32.,Z=at+B*au;
          vec3 _=vec3(Y,Z),av=vec3(Y,Z-4.5),aa=q-_,baR=av-_;
          float aw=clamp(dot(aa,baR)/dot(baR,baR),0.,1.),ax=length(aa-baR*aw)-.006;
          k=min(k,ax);
        }
      }
    }
    H+=1./(1.+i*i*1200.);
    I+=1./(1.+i*i*45000.);
    J+=1./(1.+k*k*1000.);
    K+=1./(1.+k*k*35000.);
    float r=min(t,min(u,min(v,min(i,k))));
    r=clamp(r,.002,.24);
    vec4 ay=vec4(.6,.25,.05,1.)/(1.+t*t*400.),az=vec4(.05,.5,.6,0.)/(0.+u*u*200.),aA=vec4(0.,.1,0.,1.)/(1.+v*v*300.);
    float aB=exp(-p*.12);
    b+=(ay*.7+az*.2+aA*0.)*aB*(r*1.);
    p+=r*1.;
    if(p>48.)break;
  }
  vec3 aC=vec3(0.,.45,1.)*H*.045,aD=vec3(.75,.92,1.)*I*.12,aE=vec3(1.,.02,.05)*J*.055,aF=vec3(1.,.85,.8)*K*.14,aG=aC+aD+aE+aF;
  b=clamp(b,0.,1.);
  b.rgb=pow(b.rgb,vec3(.61));
  b.rgb=mix(b.rgb,vec3(0.),clamp(1.-exp(-.04*p),0.,1.));
  b.rgb+=aG;
  ab=vec4(b.rgb,1.);
}
