// ==== Image (image) ====
mat2 m(float a){
    float b=sin(a),d=cos(a);
    return mat2(d,-b,b,d);
}
vec3 i(in float e,in vec3 a,in vec3 b,in vec3 d,in vec3 c){
    return a+b*cos(6.28318*(d*e+c));
}
void mainImage(out vec4 n,in vec2 j){
    vec3 o=vec3(.5),p=o,q=vec3(1.),r=vec3(0.,.33,.67),s=vec3(.8,.5,.4),t=vec3(.2,.4,.2),u=vec3(2.,1.,1.),v=vec3(0.,.25,.25),w=vec3(.8,.2,.05);
    vec2 g=iResolution.xy,x=(j.xy-.5*g)/g.y;
    float k=iTime;
    vec4 b=vec4(0.);
    float c=0.;
    for(float l=0.;l<80.;++l){
        vec3 a=vec3(x*c*1.2,c-6.);
        a.xz*=m(k*.2);
        float d=2.,e=d,f;
        for(int h=0;h<12;h++){
            f=dot(a,a)+.001;
            e/=f;
            a/=f;
            a.y=1.7-a.y;
            if(h>3){
                d=min(d,length(a.xz+length(a)/f*.55)/e-.006);
                a.xz=abs(a.xz)-.7;
            }
            else a=abs(a)-.86;
        }
        float step=max(d,.001);
        c+=step;
        if(c>30.)break;
        float z=log(e)*.1+k*.05;
        vec3 A=i(z,o,p,q,r),B=i(length(a.xz)*.5,s,t,u,v);
        b.rgb+=.01*exp(-d*1e2)*A;
        b.rgb+=w*.005/exp(a.y/e*2.)*B;
    }
    b.rgb=b.rgb/(1.+b.rgb);
    float C=1.-.3*length((j/g)-.5);
    b.rgb*=C;
    b.rgb=pow(b.rgb,vec3(1./2.2));
    n=vec4(b.rgb,1.);
}
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]             ù
ù**************************************************************ùùùùùùùùùùùùùùùù
ù - Logiciels:     https://patrickjaillet.github.io/sandefjord-software       ù
ù - réseau social: https://x.com/JailletPatrick                               ù
ù - Musiques:      https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
ù**************************************************************ùùùùùùùùùùùùùùùù
ù Logiciels utilisés pour la création de shaders GLSL:         ù
ù                -----------------------------                 ù
ù Conception de shaders GLSL et modification des valeurs       ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ù - Sliders-GL v1.0.1: https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl ù
ù Golfing Code 100% safe                                                                                ù
ù - µShader v3.0.1: https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader   ù
ù Formatage & Mise en page                                                                              ù
ù - ShaderFmt v1.0.0: https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*/
