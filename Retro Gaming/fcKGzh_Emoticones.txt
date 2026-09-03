// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// https://x.com/JailletPatrick
void mainImage(out vec4 q,in vec2 r){
    vec2 g=iResolution.xy,h=(r-.5*g)/g.y;
    float b=iTime,s=6.+sin(b*.5)*2.;
    vec2 i=h*s,c=floor(i),a=fract(i)-.5;
    float j=b*(.5+length(c)*.1),k=sin(j),l=cos(j);
    a=mat2(l,-k,k,l)*a;
    vec3 e=vec3(0.);
    float f=length(a),m=smoothstep(.46,.44,f),t=.15,u=.8,v=1.;
    vec3 w=clamp(abs(mod(t*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.),z=v*mix(vec3(1.),w,u);
    vec2 d=vec2(.15);
    d.y+=sin(b*5.+c.x)*.05;
    d.x+=cos(b*2.+c.y)*.05;
    float A=smoothstep(.08,.06,length(a-d))+smoothstep(.08,.06,length(a-vec2(-d.x,d.y))),n=atan(a.y,a.x),o=smoothstep(.3,.28,f)*smoothstep(.25,.27,f),p=smoothstep(-2.,-1.8,n)*smoothstep(0.,-.2,n),B=.5+.5*sin(b*3.+c.x+c.y);
    o*=mix(p,1.-p,B);
    float C=clamp(A+o,0.,1.);
    vec3 D=mix(z,vec3(0.),C);
    e=mix(vec3(.02),D,m);
    float E=b*.1+length(c)*.05,F=.7,G=.2;
    vec3 H=clamp(abs(mod(E*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.),I=G*mix(vec3(1.),H,F);
    e+=I*(1.-m);
    e*=smoothstep(1.5,.5,length(h));
    q=vec4(e,1.);
}
