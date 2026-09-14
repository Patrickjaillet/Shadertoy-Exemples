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
ù - https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/
mat2 f(float a){
    float b=sin(a),c=cos(a);
    return mat2(c,-b,b,c);
}
void mainImage(out vec4 m,in vec2 n){
    vec2 h=iResolution.xy;
    float e=iTime;
    vec3 c=vec3(0.),g=vec3(0.,0.,-.3);
    g.xy+=vec2(sin(e),cos(e*.3))*.5;
    vec2 o=(n*2.-h)/h.y;
    vec3 i=vec3(o,.5);
    i.xy*=f(e*0.);
    float d=0.,b=d,p=b;
    for(int j=0;j<135;j++){
        vec3 a=g;
        a.xz*=f(e*0.);
        a.yz*=f(e*.4);
        b=3.8;
        a=1.-abs(a);
        for(int k=0;k<3;k++){
            a=abs(a)-1.;
            d=4.2/min(dot(a,a),1.9);
            b*=d;
            a=abs(a)*d-3.8;
            a.z+=4.2;
        }
        d=length(a.xz)/b;
        float l=max(d,0.);
        p+=l;
        g+=i*l;
        float q=exp(-d*40.6);
        c+=vec3(q)*.015;
    }
    c=pow(c,vec3(4.2));
    c=1.-exp(-c);
    m=vec4(c,0.);
}
