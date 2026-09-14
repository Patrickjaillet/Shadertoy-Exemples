// ==== Image (image) ====
void mainImage(out vec4 v,in vec2 w){
    vec2 a=(w.xy-.5*iResolution.xy)/iResolution.y;
    float m=iTime*.8,n=exp(-fract(m)*4.)+exp(-fract(m+.4)*6.)*.4,x=1.-.03*n;
    a*=x;
    float y=.85+.15*sin(iTime*.6)+.05*cos(iTime*1.3),f=.08*sin(iTime*.25);
    mat2 z=mat2(cos(f),-sin(f),sin(f),cos(f));
    a=z*a*y;
    vec2 o=a,i=vec2(0.);
    for(int j=0;j<2;j++){
        vec2 p=a*(5.+float(j)*4.),A=floor(p),B=fract(p)-.5;
        for(int c=-1;c<=1;c++)for(int d=-1;d<=1;d++){
            vec2 q=vec2(float(d),float(c)),C=A+q;
            float g=fract(sin(dot(C,vec2(12.9898,78.233)))*43758.5453),h=fract(iTime*(.3+g*.2)+g);
            vec2 D=q+vec2(fract(g*34.23)-.5,fract(g*89.45)-.5),r=B-D;
            float E=length(r),F=smoothstep(0.,.1,h)*smoothstep(1.,.8,h),s=max(0.,E-h*1.5),G=sin(s*60.)*exp(-s*15.)*exp(-h*3.);
            i+=r*G*.12*F;
        }
    }
    a+=i;
    float k=dot(a,a);
    vec2 t=vec2(0.);
    vec3 e=vec3(0.);
    float u=1.,l=iTime*.5;
    for(int d=0;d<35;d++){
        a*=u;
        u*=.78;
        float g=sin(float(d)*.1+l*.5);
        mat2 h=mat2(cos(g),-sin(g),sin(g),cos(g));
        a=h*a;
        a+=t*.4;
        a+=sin(a.yx*10.8+l+k*5.2-n*.15);
        float c=length(a);
        vec2 j=vec2(.5,.9);
        float p=dot(vec2(sin(c*11.3),cos(c*10.4)),j)/(.01+c),q=.5+.5*cos(float(d)*.2+c*1.5-l*1.2+a.x*.5);
        vec3 r=vec3(q);
        e+=r*p;
        t+=.2*sin(c)*vec2(cos(a.x),sin(a.y*3.2));
        a=1.1*fract(a*.35)-1.;
    }
    e/=45.;
    e=e*3.2-.2;
    vec3 b=clamp(e,0.,1.);
    float H=1.-min(k,1.);
    b*=1.8/(1.+k*12.);
    b+=vec3(1.)*length(i)*3.*H;
    b=1.-exp(-b*2.5);
    float I=dot(b,vec3(.299,.587,.114));
    b=vec3(I);
    b=pow(b,vec3(.4545));
    b*=1.-.4*dot(o,o);
    v=vec4(b,1.);
}
/***********************************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____                       *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \                      *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |                     *
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |                     *
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/                      *
*            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]                                 *
************************************************************************************
* - Software:       https://patrickjaillet.github.io/sandefjord-software           *
* - Social Network: https://x.com/JailletPatrick                                   *
* - Music:          https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g       *
************************************************************************************
*           Software used for GLSL shader creation:                                *
*                ******************************                                    *
* GLSL shader design and value tweaking                                            *
* - Sliders-GL v1.0.1:                                                             *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl *
*                                                                                  *
* 100% safe Code Golfing                                                           *
* - µShader v3.0.1:                                                                *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader*
*                                                                                  *
* Formatting & Layout                                                              *
* - ShaderFmt v1.0.0:                                                              *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt  *
***********************************************************************************/
