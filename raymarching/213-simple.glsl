// ==== Image (image) ====
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù                       PATRICK JAILLET                        ù
ù - https://patrickjaillet.github.io/sandefjord-software       ù
ù - https://x.com/JailletPatrick                               ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/

/*Quelques infos sur les modification du shader original:
- cCalcul d'éclairage 3D et du super-échantillonnage
- Integration du pavage Domaine/Log-Polaire
- Géométrie analytique (SDF)
- Distance Estimator
- Version golfé 100% safe.
*/
vec3 j(float c,vec3 b,vec3 a,vec3 d,vec3 e){
    return b+a*cos(6.2831855e0*(d*c+e));
}
mat2 s(float b){
    float a=sin(b),d=cos(b);
    return mat2(d,-a,a,d);
}
float t(vec2 c,vec2 a,float b){
    c=abs(c);
    if(c.y>c.x)c=c.yx;
    vec2 d=c-a;
    float h=max(d.x,d.y);
    vec2 e=max(d,0.);
    return length(e)+min(h,0.)-b;
}
vec2 f(vec2 c,float h,float e,float a){
    float b=length(c),i=atan(c.y,c.x);
    vec2 d=vec2(log(b+1e-6),i);
    d=mat2(1.,e,-e,1.)*d;
    d.x-=a*.4;
    d.y+=a*.1;
    return d*h;
}
float g(vec2 c,out vec4 u,float a){
    vec2 b=c,h=vec2(1.),d=vec2(.52+.08*cos(a*.2)+.22*sin(a*.96),.355+.08*sin(a*.19)+.03*cos(a*.53));
    float i=1e10,k=i,l=k,n=0.;
    mat2 v=s(a*.4);
    for(int e=0;e<150;e++){
        h=2.*vec2(b.x*h.x-b.y*h.y,b.x*h.y+b.y*h.x);
        b=vec2(b.x*b.x-b.y*b.y,2.*b.x*b.y)+d;
        float o=dot(b,b);
        vec2 w=v*b;
        float z=t(w,vec2(.8,0.),.02);
        i=min(i,z);
        float A=abs(length(b)-1.);
        k=min(k,A);
        float B=min(abs(b.x+b.y),abs(b.x-b.y))*.28;
        l=min(l,B);
        n+=exp(-o*.05);
        if(o>256.)break;
    }
    float p=length(b),C=sqrt(p/max(dot(h,h),1e-8))*log(p);
    u=vec4(i,k,l,n);
    return C;
}
vec3 m(vec2 c,float a){
    vec2 k=f(c,.63661977236,.5,a),l=asin(sin(k*3.1415927e0))*.63661977236;
    vec4 b;
    float i=g(l,b,a);
    vec2 e=vec2(5e-4,0.);
    vec4 h;
    vec2 n=f(c+vec2(e.x,0.),.63661977236,.5,a),o=f(c-vec2(e.x,0.),.63661977236,.5,a),p=f(c+vec2(0.,e.x),.63661977236,.5,a),u=f(c-vec2(0.,e.x),.63661977236,.5,a),v=asin(sin(n*3.1415927e0))*.63661977236,w=asin(sin(o*3.1415927e0))*.63661977236,z=asin(sin(p*3.1415927e0))*.63661977236,A=asin(sin(u*3.1415927e0))*.63661977236;
    float B=g(v,h,a)-g(w,h,a),C=g(z,h,a)-g(A,h,a);
    vec2 D=vec2(B,C)/(2.*e.x);
    vec3 E=normalize(vec3(-D,.05)),F=normalize(vec3(cos(a*.5),sin(a*.5),.8));
    float G=pow(max(0.,dot(reflect(-F,E),vec3(0.,0.,1.))),128.);
    vec3 H=vec3(.5),I=H,J=vec3(1.),K=vec3(0.,.33,.67),L=vec3(.8,.5,.4),M=vec3(.2,.4,.2),N=vec3(2.,1.,1.),O=vec3(0.,.25,.25),P=j(b.x*2.5-a*.1,H,I,J,K),Q=j(b.y*4.+a*.15,L,M,N,O),R=vec3(.95,.4,.15);
    float S=.002/(abs(b.x)+.001),T=.01/(abs(b.y)+.001),U=.045/(abs(b.z)+.001);
    vec3 d=vec3(0.);
    d+=P*pow(S,1.2)*.35;
    d+=Q*pow(T,1.1)*.25;
    d+=R*pow(U,1.3)*.05;
    float V=smoothstep(.0015,0.,i);
    vec3 W=j(b.w*.02+a*.05,vec3(.1),vec3(.4),vec3(1.),vec3(.1,.2,.3));
    d=mix(d,W+G*.8,V*.7);
    float X=smoothstep(.001,0.,abs(i));
    d+=vec3(.8,.95,1.)*X*.6;
    return d;
}
void mainImage(out vec4 l,in vec2 i){
    vec3 b=vec3(0.);
    vec2 d[4];
    d[0]=vec2(-.25,-.25);
    d[1]=vec2(.25,-.25);
    d[2]=vec2(-.25,.25);
    d[3]=vec2(.25);
    float a=iTime;
    for(int e=0;e<4;e++){
        vec2 n=i+d[e],c=(n-.5*iResolution.xy)/iResolution.y;
        b+=m(c,a);
    }
    b*=.25;
    vec2 h=i/iResolution.xy,k=h-.5,o=((i+k*2.)-.5*iResolution.xy)/iResolution.y,p=((i-k*2.)-.5*iResolution.xy)/iResolution.y;
    b.r=mix(b.r,m(o,a).r,.35);
    b.b=mix(b.b,m(p,a).b,.35);
    float u=pow(16.*h.x*h.y*(1.-h.x)*(1.-h.y),.25);
    b*=u;
    b/=(.6+b*.5);
    b=pow(b,vec3(1./2.2));
    l=vec4(b,1.);
}
