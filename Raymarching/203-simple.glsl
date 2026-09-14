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

mat2 q(float a){
    float b=cos(a),d=sin(a);
    return mat2(b,-d,d,b);
}
float k(vec2 a){
    a=fract(a*vec2(123.34,456.21));
    a+=dot(a,a+45.32);
    return fract(a.x*a.y);
}
float A(vec2 a){
    vec2 b=floor(a),c=fract(a),d=c*c*(3.-2.*c);
    return mix(mix(k(b+vec2(0.)),k(b+vec2(1.,0.)),d.x),mix(k(b+vec2(0.,1.)),k(b+vec2(1.)),d.x),d.y);
}
float r(vec2 a){
    float c=0.,d=.5;
    mat2 e=mat2(.8,.6,-.6,.8);
    for(int b=0;b<4;b++){
        c+=d*A(a);
        a=e*a*2.03;
        d*=.5;
    }
    return c;
}
void mainImage(out vec4 B,in vec2 C){
    vec2 s=(C-.5*iResolution.xy)/iResolution.y;
    vec3 l=normalize(vec3(s,1.)),D=vec3(0.,0.,-1.);
    float i=iTime;
    l.xy*=q(i*.05);
    l.xz*=q(sin(i*.1)*0.);
    vec3 a=D,c=vec3(0.);
    float g=0.,e=g;
    for(float b=0.;b<50.;b++){
        e=length(a);
        float t=atan(a.y,a.x);
        vec3 f=vec3(log(e)-i,exp(.7-a.z/e)-1.,t+i*.4);
        vec2 u=vec2(f.x, (sin(t)+1.)*2.);
        float E=r(u);
        vec2 F=vec2(sin(f.z*16.),cos(f.x*16.))*0.;
        float m=r(u+F*4.),d=1.,n=f.y+E*0.;
        for(int v=0;v<10;v++){
            vec3 G=f.yzz*d;
            n+=dot(sin(G)-1.,.3-sin(f.zxx*d))/d*.2;
            d*=2.;
        }
        g=n;
        float o=min(g*d,.7-g)/35.;
        o=clamp(o,0.,1.);
        float h=clamp(abs(n)*8.+m*.1,0.,.3);
        vec3 H=vec3(.04,.02,.02),w=vec3(.7,.02,0.),p=vec3(1.,.3,0.),I=vec3(1.,.9,.35),j;
        if(h<.25)j=mix(I,p,h*1.9);
        else if(h<.4)j=mix(p,w,(h-.25)*2.857);
        else j=mix(w,H,(h-.6)*2.5);
        float J=sin(f.z*0.-i*12.+m*25.12)*.7+1.;
        j+=p*J*(1.-h)*.6;
        float K=1./(.9+g*g*40.);
        c+=j*o*(1.2+m*.8)*K*(1.-b/120.);
        a+=l*max(g*e*.18,.002);
        if(e>25.)break;
    }
    c=mix(c,vec3(.02,.005,.002),1.-exp(-.89*e*e));
    c=pow(c,vec3(.4545));
    c=c*c*(3.-2.*c);
    c*=1.25-length(s)*.65;
    B=vec4(clamp(c,0.,1.),1.);
}
