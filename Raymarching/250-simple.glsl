// ==== Image (image) ====
float e(vec2 d,vec4 j){
  vec2 c=d-j.xy,ba=j.zw-j.xy;
  return length(c-ba*clamp(dot(c,ba)/dot(ba,ba),0.,1.));
}// https://patrickjaillet.github.io/GLSL-Hyper-Golfer/
float o(int h,vec2 d){
  float c=1e5;
  if(h==83){
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(0.,.8,0.,.4)));
    c=min(c,e(d,vec4(0.,.4,.5,.4)));
    c=min(c,e(d,vec4(.5,.4,.5,0.)));
    c=min(c,e(d,vec4(0.,0.,.5,0.)));
  }
  if(h==65){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,.5,0.)));
    c=min(c,e(d,vec4(0.,.4,.5,.4)));
  }
  if(h==78){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,0.)));
    c=min(c,e(d,vec4(.5,0.,.5,.8)));
  }
  if(h==68){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.4,.8)));
    c=min(c,e(d,vec4(.4,.8,.5,.6)));
    c=min(c,e(d,vec4(.5,.6,.5,.2)));
    c=min(c,e(d,vec4(.5,.2,.4,0.)));
    c=min(c,e(d,vec4(.4,0.,0.,0.)));
  }
  if(h==69){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(0.,.4,.4,.4)));
    c=min(c,e(d,vec4(0.,0.,.5,0.)));
  }
  if(h==70){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(0.,.4,.4,.4)));
  }
  if(h==74){
    c=min(c,e(d,vec4(0.,.2,.2,0.)));
    c=min(c,e(d,vec4(.2,0.,.4,0.)));
    c=min(c,e(d,vec4(.4,0.,.4,.8)));
    c=min(c,e(d,vec4(.2,.8,.6,.8)));
  }
  if(h==79){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,.5,0.)));
    c=min(c,e(d,vec4(.5,0.,0.,0.)));
  }
  if(h==82){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,.5,.4)));
    c=min(c,e(d,vec4(.5,.4,0.,.4)));
    c=min(c,e(d,vec4(0.,.4,.5,0.)));
  }
  if(h==80){
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,.5,.4)));
    c=min(c,e(d,vec4(.5,.4,0.,.4)));
  }
  if(h==84){
    c=min(c,e(d,vec4(0.,.8,.6,.8)));
    c=min(c,e(d,vec4(.3,.8,.3,0.)));
  }
  if(h==67){
    c=min(c,e(d,vec4(.5,0.,0.,0.)));
    c=min(c,e(d,vec4(0.,0.,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
  }
  if(h==49){
    c=min(c,e(d,vec4(0.,.6,.3,.8)));
    c=min(c,e(d,vec4(.3,.8,.3,0.)));
  }
  if(h==50){
    c=min(c,e(d,vec4(0.,.6,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,.5,.4)));
    c=min(c,e(d,vec4(.5,.4,0.,.4)));
    c=min(c,e(d,vec4(0.,.4,0.,0.)));
    c=min(c,e(d,vec4(0.,0.,.5,0.)));
  }
  if(h==56){
    c=min(c,e(d,vec4(0.,0.,.5,0.)));
    c=min(c,e(d,vec4(.5,0.,.5,.8)));
    c=min(c,e(d,vec4(.5,.8,0.,.8)));
    c=min(c,e(d,vec4(0.,.8,0.,0.)));
    c=min(c,e(d,vec4(0.,.4,.5,.4)));
  }
  return smoothstep(.04,.01,c);
}
float C(vec2 d){
  return fract(sin(dot(d,vec2(12.9898,78.233)))*43758.5453);
}
float D(vec2 m){
  float i=0.;
  vec2 d=(m-vec2(-.45,.08))*11.;
  int j[10]=int[](83,65,78,68,69,70,74,79,82,68);
  float f=floor(d.x);
  if(f>=0.&&f<10.&&d.y>=0.&&d.y<=.8)i+=o(j[int(f)],vec2(fract(d.x),d.y));
  d=(m-vec2(-.36,-.15))*12.;
  int r[8]=int[](80,82,69,83,69,78,84,83);
  f=floor(d.x);
  if(f>=0.&&f<8.&&d.y>=0.&&d.y<=.8)i+=o(r[int(f)],vec2(fract(d.x),d.y));
  return clamp(i,0.,1.);
}
float s(vec2 m){
  float i=0.,c=iTime-4.;
  m*=4.+smoothstep(0.,.2,c);
  m.x+=(C(vec2(m.y*10.,c*10.))-.5)*smoothstep(2.,4.,c)*.1;
  vec2 d=(m-vec2(-1.2,.1));
  int j[5]=int[](70,82,65,67,84);
  float f=floor(d.x);
  if(f>=0.&&f<5.&&d.y>=0.&&d.y<=.8)i+=o(j[int(f)],vec2(fract(d.x),d.y));
  d=(m-vec2(-.7,-.9));
  int r[3]=int[](49,50,56);
  f=floor(d.x);
  if(f>=0.&&f<3.&&d.y>=0.&&d.y<=.8)i+=o(r[int(f)],vec2(fract(d.x),d.y));
  return clamp(i,0.,1.);
}
void mainImage(out vec4 i,in vec2 A){
  vec3 t=iResolution,d=vec3(2.*cos(iTime*.025),-15.+3.*sin(iTime*.0375),2.),u=vec3(4.*sin(iTime*.025),25.+5.*cos(iTime*.075),-20.+5.*sin(iTime*.05)),k=normalize(u-d),v=normalize(vec3(.1*sin(iTime*.05),1.,0.)),q=normalize(cross(k,v)),w=cross(q,k),b=vec3(0.),c=d;
  vec2 l=(A-.5*t.xy)/t.y;
  vec3 f=normalize(q*l.x+w*l.y+k*(1.2-.2*dot(l,l)));
  float n=1.,g=0.,h,y=.22;
  for(int x=0;x<50;x++){
    float B=min(n*h,.7-n);
    if(B>0.)b+=B*.045*(.5+.5*cos(h*.02+vec3(0.,1.3,2.6)+c.y*.05))*exp(-float(x)*.005);
    c+=f*(max(n,.01)*g*y+.002);
    g=length(c);
    vec3 c=vec3(log(g)-iTime*.2,exp(-c.y/(g+.001)+.5),atan(c.x,c.z)+sin(log(g)*.5-iTime*.05)*.3);
    n=c.y-1.;
    float j=.55;
    for(h=6.;h<1200.;h*=2.15){
      n-=abs(dot(sin(c.yzx*h+iTime*.25),.5-cos(c*h-c.y*.02)))/h*j;
      j*=.95;
    }
  }
  b=pow(b,vec3(1.1,1.,.95))+vec3(.01,.02,.04)*(1.-length(l));
  vec3 E=(b*(2.45*b+.05))/(b*(2.45*b+.63)+.14);
  vec2 p=A/t.xy;
  i=vec4(pow(E,vec3(1./2.2))*(.5+.5*pow(16.*p.x*p.y*(1.-p.x)*(1.-p.y),.25)),1.);
  if(iTime<4.){
    float F=D(l),v=smoothstep(0.,1.,iTime)*smoothstep(4.,3.,iTime);
    i.rgb=mix(i.rgb*(1.-v*.6),vec3(1.),F*v);
  }
  else if(iTime<8.){
    float c=iTime-4.,a=smoothstep(2.,4.,c)*.05,v=smoothstep(0.,.2,c)*smoothstep(4.,3.5,c);
    vec3 h=vec3(s(l+vec2(a,0.)),s(l),s(l-vec2(a,0.)));
    i.rgb=mix(i.rgb*(1.-v*.8),h+h.y*.5*vec3(1.,.8,1.2),v);
  }
}
