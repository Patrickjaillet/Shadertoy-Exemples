// ==== Image (image) ====
#define Z(f) max(0,-f)
struct C{float t;vec2 r;int f;};
float H(vec3 u){return fract(sin(u.x+u.y*37.+u.z*521.)*110003.9);}
float M(float a,float b,float t){return mix(a,b,t*t*(3.-2.*t));}
float N(vec3 u){
    vec3 i=floor(u),f=fract(u);
    vec2 e=vec2(0,1);
    return M(M(M(H(i),H(i+e.yxx),f.x),M(H(i+e.xyx),H(i+e.yyx),f.x),f.y),
             M(M(H(i+e.xxy),H(i+e.yxy),f.x),M(H(i+e.xyy),H(i+e.yyy),f.x),f.y),f.z);
}
float B(vec3 p){float n=0.,s=1.;for(int i=0;i<4;i++){n+=abs(N(p*s)-.5)*2./s;s*=2.15;}return n;}
vec2 S(vec2 u){
    float l=length(u),a=atan(u.x,u.y)/3.14;
    return vec2(abs((fract(log(l)+a*.5)-.5)*2.),abs(fract(a*2.)*2.-1.));
}
float D(vec3 p,C c,inout float g,inout float g3){
    vec3 o=p;p.yz=S(p.yz);
    float l=length(p.xy),f=max(l-3.8,-(l-3.));
    vec3 r=fract(p)-.5;float s=1.;
    for(int i=0;i<3;i++){
        if(i<Z(c.f))continue;
        f=max(f,-min(length(r.xz/s)-.35/s,length(r.xy/s)-.35/s));
        s*=2.1;r=fract(r*s)-.5;
    }
    vec3 sp=p;sp.x=abs(sp.x)-5.4;sp.z=fract(sp.z)-.5;
    f=min(f,max(abs(sp.x+3.)-1.5,max(abs(sp.y+.1-sin(sp.x)*.5)-.08,abs(sp.z)-.04))*.5);
    float k=max(0.,sin(length(o.yz)+c.t*5.))*.5;
    float x=max(abs(r.x)-(.005+k),max(abs(r.y*cos(c.t)+r.z*sin(c.t))-1.2,abs(-r.y*sin(c.t)+r.z*cos(c.t))-.01));
    g3+=3e-4/max(.005,x);g+=.03/length(o.yz);
    return f;
}
//*====================================================================================*//
//:: Processeur: AMD Ryzen 9 9950X3D2 ::                                                //
//:: RAM installée 256,0 Go DDR5      ::                                                //
//:: Stockage: Sabrent 16 TB SSD      ::                                                //
//:: Video: NVIDIA GeForce RTX 5090   ::                                                //
//:: Systeme: Kubuntu/Win11           ::                                                //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  URL     : https://lside.xo.je                                                   //
//*====================================================================================*//
vec3 R(vec2 d,C c){
    float g=0.,g3=0.,t=0.;
    vec2 u=(d/c.r*2.-1.)*vec2(c.r.x/c.r.y,1);
    vec3 p=vec3(cos(c.t*.2)*8.,sin(c.t*.1)*2.,sin(c.t*.2)*8.),
         fw=normalize(-p),
         rt=normalize(cross(vec3(0,1,0),fw)),
         up=cross(fw,rt),
         rd=normalize(fw + u.x*rt + u.y*up); 
    for(int i=0;i<100;i++){
        float d=D((p+rd*t).yzx,c,g,g3);
        if(d<1e-3||t>40.)break;t+=d;
    }
    vec3 o=vec3(0),v=(p+rd*t).yzx;
    if(t<40.){
        vec3 e=vec3(.001,0,0);float a,b;
        vec3 n=normalize(vec3(D(v+e.xyy,c,a,b)-D(v-e.xyy,c,a,b),D(v+e.yxy,c,a,b)-D(v-e.yxy,c,a,b),D(v+e.yyx,c,a,b)-D(v-e.yyx,c,a,b)));
        o=mix(vec3(.95,.95,.9),vec3(.8,.7,.5),B(v*2.)*.5)*max(0.,dot(n,vec3(.57)))+vec3(.8,.9,1.)*pow(1.-max(0.,dot(n,-rd)),4.)*.8;
    }
    return mix(o+vec3(.9,.8,.5)*g*.4+vec3(.4,.7,1.)*g3*.6,vec3(.95,.97,1.),1.-exp(-.02*t));
}
void mainImage(out vec4 k,vec2 f){
    C c=C(iTime,iResolution.xy,iFrame);
    vec3 l=R(f,c),b=vec3(0);
    for(float i=0.;i<8.;i++)b+=R(f+vec2(cos(i*.78),sin(i*.78))*2.,c);
    k=vec4(pow(l+b*.0037,vec3(1.1))*(1.-.4*length(f/c.r-.5)),1);
}
