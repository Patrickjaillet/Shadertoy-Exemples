// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
void mainImage(out vec4 G,in vec2 H){
    vec2 d=(H-.5*iResolution.xy)/iResolution.y,L=d*1.5-vec2(.5,0.),a=vec2(0.);
    float t=iTime,s=1.+sin(t*.5)*.5,I=sin(t*.5),J=cos(t*.3),K=length(d),M=0.;
    vec3 e=vec3(0.);
    for(int u=0;u<16;u++){
        if(dot(a,a)>4.)break;
        a=vec2(a.x*a.x-a.y*a.y,2.*a.x*a.y)+L;
        ++M;
    }
    vec2 n=a;
    float h=abs(n.y+I*.7)*abs(n.x+J*.7);
    h=pow(h,.45);
    vec2 v=n*3.5+t*.2,i=floor(v),c=fract(v);
    c=c*c*(3.-2.*c);
    float N=fract(sin(dot(i,vec2(127.1,311.7)))*4.3758547e4),O=fract(sin(dot(i+vec2(1.,0.),vec2(127.1,311.7)))*4.3758547e4),P=fract(sin(dot(i+vec2(0.,1.),vec2(127.1,311.7)))*4.3758547e4),Q=fract(sin(dot(i+vec2(1.),vec2(127.1,311.7)))*4.3758547e4),R=mix(mix(N,O,c.x),mix(P,Q,c.x),c.y),w=.7+.3*sin(t*.8+K*1.5+R*2.),z=abs(s-2.)*.008,A=(.05/(h+.004+z))*w,B=(.09/(h+.025+z))*w,j=clamp(A+B,0.,3.);
    vec3 g=mix(vec3(.15,0.,0.),vec3(1.,.2,.02),smoothstep(0.,.5,j));
    g=mix(g,vec3(1.,.7,.1),smoothstep(.5,1.2,j)),g=mix(g,vec3(1.,.95,.6),smoothstep(1.2,2.2,j));
    vec2 C=d*1.5-vec2(0.,t*.4),k=floor(C),smh1=fract(C);
    smh1=smh1*smh1*(3.-2.*smh1);
    float D=mix(mix(fract(sin(dot(k,vec2(127.1,311.7)))*43758.5453),fract(sin(dot(k+vec2(1.,0.),vec2(127.1,311.7)))*43758.5453),smh1.x),mix(fract(sin(dot(k+vec2(0.,1.),vec2(127.1,311.7)))*43758.5453),fract(sin(dot(k+vec2(1.),vec2(127.1,311.7)))*43758.5453),smh1.x),smh1.y);
    vec2 E=d*3.-vec2(t*.1,t*.8),l=floor(E),smh2=fract(E);
    smh2=smh2*smh2*(3.-2.*smh2);
    float S=mix(mix(fract(sin(dot(l,vec2(127.1,311.7)))*43758.5453),fract(sin(dot(l+vec2(1.,0.),vec2(127.1,311.7)))*43758.5453),smh2.x),mix(fract(sin(dot(l+vec2(0.,1.),vec2(127.1,311.7)))*43758.5453),fract(sin(dot(l+vec2(1.),vec2(127.1,311.7)))*43758.5453),smh2.x),smh2.y),p=D*.6+S*.4,U=exp(-s*.12);
    vec3 T=mix(vec3(.05,.04,.04),vec3(.25,.18,.12),p);
    e+=g*(A+B)*U,e=mix(e,T*(1.2+j*.5),p*.65);
    float V=d.x*.8+d.y*.5-sin(t*.6)*1.2,F=exp(-V*V*12.);
    F*=(.4+.6*D);
    vec3 W=vec3(1.,.65,.3)*F*.8;
    e+=W*(1.-p*.5);
    vec3 q=e;
    q/=(1.+q*.2),G=vec4(q,1.);
}
