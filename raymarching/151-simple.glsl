// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    vec3 R = iResolution, ro = vec3(0,0,533.8),
         rd = normalize(vec3((U-.5*R.xy)/R.y, -1.1)),
         c = mix(vec3(.02,.005,.005), vec3(.1,.03,.02), rd.y*.5+.5), g = vec3(0);
    float t = 1e4, f = 1., m = 0., tf = -104./rd.y;
    for(int j=-200; j<=0; j++) {
        float b = float(j), T = mod(iTime*9.+b*.038, 70.),
              a = b*(b-1.)*1.57, D = 5.+T*5.,
              Y = -104.+abs(sin(T*.2))*max(220.-T*.8, 0.),
              fd = clamp(1.-T*.01, 0., 1.), r = max(3.5-T*.03, .2),
              X = -D*cos(a), Z = 533.8+D*sin(a), y = -Y,
              B = X*rd.x+y*rd.y+Z*rd.z, Q = X*X+y*y+Z*Z, H = B*B-Q+r*r,
              s = -B-sqrt(max(H, 0.));
        g += fd/(1.+max(Q-B*B, 0.)*.1)*.0015*(.5+.5*cos(6.28*(b*.31+vec3(0,.33,.67)+T*.05)));
        if(H>0. && s>.001 && s<t) t = s, f = fd, m = b;
    }
    bool h = rd.y<0. && tf>0. && tf<t;
    if(h) t = tf;
    if(t<1e4) c = h ? vec3(smoothstep(900., 80., tf)) : mix(c, (.5+.5*cos(6.28*(m*.31+vec3(0,.33,.67))))*1.5, f);
    O = vec4(c+g, 1);
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
