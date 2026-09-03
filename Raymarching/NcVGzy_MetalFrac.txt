// ==== Image (image) ====
/* TWIGL.APP GOLFING - https://twigl.app?ol=true&ss=-Oyu7NWk6DCcLbP11BIf
o=vec4(.1);o.a=1.;
float d=0.,s,A,a=t*.4;
vec3 q,c=clamp(abs(mod(t*.9+vec3(0,4,2),6.)-3.)-1.,0.,1.);
for(int i=0;i++<70;o.rgb+=log2(A)/(d+=length(q.xz)/A)/59e2*mix(c,vec3(1),clamp(q.y*.1,0.,1.))){
q=vec3((FC.xy-r*.5)/r.y*2.9,d-.5);
q.zx*=mat2(cos(a),-sin(a),sin(a),cos(a));
A=1.;
for(int j=0;j++<19;)A*=s=max(1.01,7.5/dot(q,q)),q=vec3(2.5,4,2.8)-abs(abs(q)*s-vec3(3.2,2.1,4));
}
*/
void mainImage(out vec4 O, vec2 U) {
    O = vec4(.1, .1, .1, 1);
    vec3 p, r = clamp(abs(fract(iTime * .15 + vec3(0, 2, 1) / 3.) * 6. - 3.) - 1., 0., 1.);
    float d = 0., a = iTime * .4, C = cos(a), S = sin(a), s, A;
    
    for(int i = 0; i < 70; i++) {
        p = vec3((U + U - iResolution.xy) / iResolution.y * 1.45, d - .5);
        p.zx *= mat2(C, -S, S, C);
        A = 1.;
        
        for(int j = 0; j < 19; j++)
            A *= s = max(1.01, 7.5 / dot(p, p)),
            p = vec3(2.5, 4, 2.8) - abs(abs(p) * s - vec3(3.2, 2.1, 4));
            
        d += length(p.xz) / A;
        O.rgb += log2(A) / d / 5900.1 * mix(vec3(1), r, clamp(1. - p.y * .1, 0., 1.));
    }
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
