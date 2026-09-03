// ==== Image (image) ====
void mainImage(out vec4 b,vec2 c){
  vec3 d=vec3((c-iResolution.xy*vec2(.5,.35))/iResolution.y,1),q=vec3(0,.7,1.5),o=q*0.,p;
  float f=0.,e=0.,R=0.,s,pulse=sin(iTime*.0035)*.05+.95;
  for(;f++<28.;){
    o+=.004/(.005+abs(e))*vec3(.1+.1*sin(iTime*.5+R),.04,.15*cos(R*.5));
    R=length(p=q+=d*e*R*.18);
    p=vec3(log(R)-iTime*.2,acos(p.z/R)*1.5,atan(p.y,p.x)+iTime*.375);
    e=p.y-1.2;
    s=1.5;
    for(int a=0;a<12;a++){
      p.xy=vec2(p.x-p.y,p.x+p.y)*.7;
      p=abs(p-vec3(0,.4,.2))-vec3(.5,0,1);
      s*=1.65*pulse;
      e+=dot(sin(p*s),cos(p.zxy*s))/s*.45;
    }
  }
  b=vec4(vec3(dot(pow(o,vec3(1.2)),vec3(.2126,.7152,.0722))),0);
}
/*
void mainImage(out vec4 b,vec2 c){
  vec3 d=vec3((c-iResolution.xy*vec2(.5,.35))/iResolution.y,1),q=vec3(0,.7,1.5),o=q*0.,p;
  float f=0.,e=0.,R=0.,s,pulse=sin(iTime*.0035)*.05+.95;
  for(;f++<28.;){
    o+=.004/(.005+abs(e))*vec3(.1+.1*sin(iTime*.5+R),.04,.15*cos(R*.5));
    R=length(p=q+=d*e*R*.18);
    p=vec3(log(R)-iTime*.2,acos(p.z/R)*1.5,atan(p.y,p.x)+iTime*.375);
    e=p.y-1.2;
    s=1.5;
    for(int a=0;a<12;a++){
      p.xy=vec2(p.x-p.y,p.x+p.y)*.7;
      p=abs(p-vec3(0,.4,.2))-vec3(.5,0,1);
      s*=1.65*pulse;
      e+=dot(sin(p*s),cos(p.zxy*s))/s*.45;
    }
  }
  b=vec4(vec3(dot(pow(o,vec3(1.2)),vec3(.2126,.7152,.0722))),0);
}
*/
