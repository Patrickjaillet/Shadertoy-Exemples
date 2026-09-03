// ==== Image (image) ====
#define I 7
#define S 220
#define T .0008
#define M 60.
#define P 3.14159

mat2 r2(float a){float s=sin(a),c=cos(a);return mat2(c,-s,s,c);}

float map(vec3 p){
    p.xy*=r2(p.z*.15+iTime*.1);
    p.z+=iTime*1.2;
    vec3 q=mod(p+6.,12.)-6.,o=vec3(.18,.32,.22);
    float s=1.;
    for(int i=0;i<I;i++){
        q=abs(q)-o;
        if(q.x<q.y)q.xy=q.yx;
        if(q.x<q.z)q.xz=q.zx;
        if(q.y<q.z)q.yz=q.zy;
        float k=1.78/clamp(dot(q,q),.12,1.1);
        q*=k;s*=k;
        q-=vec3(.6,3.2,.52);
    }
    return max((length(q.xz)-.15)/s,1.4-length(p.xy));
}

vec3 ace(vec3 x){return clamp((x*(2.51*x+.03))/(x*(2.43*x+.59)+.14),0.,1.);}

void mainImage(out vec4 O,vec2 C){
    vec2 R=iResolution.xy,u=(C-.5*R)/R.y;
    float n=fract(sin(dot(u,vec2(12.9898,78.233)+iTime))*43758.5453),
          y=mod(iTime,32.),t=mod(y,8.)/8.,v=1.2,m,b,l,d,h=0.;
    vec3 o,a,f,r,k,p,c=vec3(1,.4,0),e=vec3(1,.2,.6),g=vec3(.4,1,.5);
    
    if(y<8.){o=vec3(.4*sin(t*P),.4*cos(t*P),-3.);a=vec3(0,0,-17.);}
    else if(y<16.){o=vec3(2.5*sin(t*P*.5),1.5*cos(t*P*.5),-2.+t*4.);a=vec3(0,0,o.z+10.);v=1.8;}
    else if(y<24.){o=vec3(sin(iTime*.5)*1.1,cos(iTime*.3)*1.1,-1.);a=vec3(0,0,20.);v=.7;}
    else {o=vec3(0,0,-5.+t*15.);a=vec3(sin(iTime),cos(iTime),o.z+5.);}
    
    f=normalize(a-o);
    r=normalize(cross(vec3(sin(iTime*.2),1,0),f));
    k=normalize(f*v+u.x*r+u.y*cross(f,r));
    
    for(int i=0;i<S;i++){
        p=o+h*k;d=map(p);
        float w=exp(-h*.04);
        m+=exp(-max(1.,d)*140.)*w;
        b+=.005/(.005+abs(length(p.xy)-1.1))*w;
        l+=.002/(.002+d*d)*w;
        h+=max(T,d*.45);
        if(h>M)break;
    }
    
    float x=sin(iTime*.4)*.5+.5,j=length(u);
    vec3 q=mix(c,mix(e,g,x),x),
    z=q*m*.18+vec3(.3,.1,1)*b*.05+q*l*.02;
    z+=vec3(1,.9,.7)*pow(.012/(j+.01),1.6)*(1.+.3*sin(iTime*20.));
    z=pow(ace(z*2.8),vec3(.4545))*smoothstep(1.6,.3,j)*(.92+.08*n);
    O=vec4(mix(z,vec3(0),smoothstep(.1,0.,abs(mod(y,8.)))),1);
}
