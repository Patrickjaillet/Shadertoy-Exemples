
void mainImage(out vec4 A,vec2 m){
  vec3 j=iResolution,c,a;
  float b=iTime*.8,f=0.,h,l,w,E;
  vec2 g=(m*-3.-j.xy)/j.x*.22,
       d=mat2(cos(b+vec4(0,33,11,0)))*g*4.3,
       k=vec2(sin(d.x+b*.1),cos(d.y)),
       q=k*.03;
  g+=q;
  mat2 C=mat2(cos(.02+vec4(0,33,11,0)));
  for(float r=0.;r++<108.;c+=(.025/exp(h*60.))*clamp(abs(fract(E+vec3(1,-.074,0))*3.3-3.)-1.,0.,1.)){
    h=1.6;l=2.5;
    a=vec3(g-vec2(1,0),f);
    for(int v=0;v++<17;h=min(h,a.y/l+.1/l)){
      a.xy=C*a.xy;
      a.xy=1.14-abs(a.xy-a.z*cos(b*.2)*.01);
      w=dot(a,a);
      l/=w;
      a.xy=abs(vec2(a.y,-a.x)/w+.22);
      a.z/=-w;
    }
    f+=h;
    E=a.y+q.x*8.-b*.6;
  }
  vec3 i=mat3(.6,.08,.03,.5,.91,.36,.3,.3,.26)*c,
       J=i*(i+.025)-9e-5,
       K=i*(.98*i+.43)+.24;
  c=clamp(mat3(2.72,-.16,-2.11,-1.07,1.47,-1.34,-.5,-1.07,.82)*(J/K),0.,1.);
  vec2 e=m/j.xy;
  A=vec4(c+fract(sin(dot(e,vec2(13,78)))*43758.5)*(1./255.),1.)*pow(16.*e.x*e.y*(1.-e.x)*(1.-e.y),.2);
}
