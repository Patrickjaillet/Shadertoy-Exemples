// ==== Image (image) ====
#define B F(iChannel3,.05)
#define M F(iChannel3,.5)
#define H F(iChannel3,.9)
void mainImage(out vec4 O, vec2 U){
    vec2 u=U/R,d=u;
    float f=mod(floor(T*.6),30.),h=fract(sin(f)*4e4);
    if(h<.1)d.x+=sin(d.y*50.+T*10.)*.05*B;
    if(h>.1&&h<.2)d=floor(d*(32.+M*64.))/(32.+M*64.);
    if(h>.8)d=(d-.5)*rot(B*.2)+.5;
    vec4 A=texture(iChannel0,d),B_=texture(iChannel1,d),C=texture(iChannel2,u);
    vec3 c=A.rgb;
    if(B_.a<10.)c=mix(c,B_.rgb,step(.1,length(B_.rgb)));
    c=mix(c,C.rgb,C.a);
    if(h>.7)c.r=texture(iChannel0,d+vec2(.04*H,0)).r,c.b=mix(c.b,texture(iChannel1,d-vec2(.04*H,0)).b,step(.1,length(B_.rgb)));
    if(h>.9)c=1.-c;
    c-=sin(u.y*R.y)*.05*M;
    O=vec4(c*pow(u.x*u.y*(1.-u.x)*(1.-u.y)*15.,.2)*(1.+B*.6+H*.4),1);
}

// ==== Common (common) ====
#define T iTime
#define R iResolution.xy
#define F(c,f) texture(c,vec2(f,.25)).x
#define V(h,s,v) ((clamp(abs(fract(h+vec3(3,2,1)/3.)*6.-3.)-1.,0.,1.)-1.)*s+1.)*v
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

// ==== Buffer A (buffer) ====
#define B F(iChannel0,.05)
#define M F(iChannel0,.5)
#define H F(iChannel0,.9)
void mainImage(out vec4 O, vec2 U){
    vec2 u=(U-.5*R)/R.y;u*=1.+B*.3;
    float s=mod(floor(T*.3),50.),h=fract(sin(s)*4e4);
    vec3 c=vec3(0);
    if(h<.3)c=vec3(u.y*.5+T,1.,smoothstep(.8,1.,sin(u.y*15.+T*5.)*sin(u.y*5.-T))+M);
    else if(h<.6)c=vec3(h+B,1.,1.)*mod(floor(u.x*5.+T*2.+M)+floor(u.y*5.+H*2.),2.);
    else if(h<.8){float v=sin(u.x*10.+T*3.+B)+cos(u.y*10.+T*1.5);c=vec3(v*.2+T*.1,.8,sin(v*3.)*.5+.5+H*.5);}
    else{vec2 q=u/(mod(T*2.+M,1.));c=vec3(step(.98,fract(sin(dot(floor(q*20.),vec2(12,31)))*4e4))*(1.-mod(T*2.,1.))*(1.+B));}
    O=vec4(V(c.x,c.y,c.z),1);
}

// ==== Buffer B (buffer) ====
#define B F(iChannel0,.05)
#define M F(iChannel0,.5)
#define H F(iChannel0,.9)
float map(vec3 p){
    p.xy*=rot(T*.7+B*2.);p.xz*=rot(T*.4+M);
    float I=mod(floor(T*.5),25.),m=smoothstep(.2,.8,fract(T*.5));
    vec3 q=abs(p);
    float d1=length(p)-1.2-B*.3,d2=length(max(q-.9-M*.2,0.))+min(max(q.x,max(q.y,q.z)),0.),
    d3=length(vec2(length(p.xz)-1.,p.y))-.3-H*.2,d4=(q.x+q.y+q.z-1.5)*.577,
    S1=mix(mix(d1,d2,step(1.,mod(I,4.))),mix(d3,d4,step(3.,mod(I,4.))),step(2.,mod(I,4.))),
    S2=mix(mix(d1,d2,step(1.,mod(I+1.,4.))),mix(d3,d4,step(3.,mod(I+1.,4.))),step(2.,mod(I+1.,4.))),
    F=mix(S1,S2,m);
    return fract(sin(I)*4e4)>.5?max(F,-(length(q-.9)-.05-H*.05)):F;
}
void mainImage(out vec4 O, vec2 U){
    vec2 u=(U-.5*R)/R.y;
    vec3 o=vec3(0,0,-3.5),d=normalize(vec3(u,1)),p,c=vec3(0);
    float t=0.,i;
    for(i=0.;i<60.;i++){
        p=o+d*t;
        float sd=map(p);
        if(sd<.001||t>10.)break;
        t+=sd;
    }
    if(t<10.){
        vec2 e=vec2(.01,0);
        vec3 n=normalize(map(p)-vec3(map(p-e.xyy),map(p-e.yxy),map(p-e.yyx)));
        float l=max(dot(n,normalize(vec3(1,1,-1))),0.);
        c=V(fract(sin(mod(floor(T*.5),25.))*4e4)+T*.05,.8,1.)*(l+M*.5)+pow(max(dot(reflect(-normalize(vec3(1,1,-1)),n),-d),0.),32.+H*64.)*(1.+H);
    }
    O=vec4(c,step(.5,t));
}

// ==== Buffer C (buffer) ====
#define B F(iChannel1,.05)
#define M F(iChannel1,.5)
#define H F(iChannel1,.9)
void mainImage(out vec4 O, vec2 U){
    vec2 u=U/R.y;
    u.y-=.15+sin(u.x*3.+T*2.5+B*.5)*.08+cos(u.x*5.-T*3.)*.04;
    float c=0.;
    if(u.y>0.&&u.y<.2){
        vec2 p=u*vec2(8,5);p.x-=T*7.5+M*3.;
        int i=int(floor(p.x)),a=65+int(mod(float(i)*40.,26.));
        if(mod(float(i),5.)==0.)a=32;
        c=textureGrad(iChannel0,fract(p)/16.+fract(vec2(a,15-a/16)/16.),dFdx(p/16.),dFdy(p/16.)).x;
    }
    O=vec4(V(u.x*.5-T*.2,1.,1.)*c*(1.+H*3.),c);
}
