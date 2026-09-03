// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    O = vec4(.08, .07, 0, 1);
    
    float d = 0., 
          t = iTime, 
          c = cos(t *= .25), 
          s = sin(t), 
          m, l;
          
    vec3 p, k = vec3(4.8, 1.1, 3.5);

    for (int i = 0; i++ < 35;) {
        p = vec3((U + U - iResolution.xy) / iResolution.y * (.52 + .13 * sin(t * 3.2)), d - .6);
        p.yz *= mat2(c, -s, s, c);
        m = .7;
        
        for (int j = 0; j++ < 39;)
            m *= l = max(1.02, 10.9 / dot(p, p)),
            p = vec3(-.2, k.z, 2.2) - abs(abs(p) * l - k);
            
        d += length(p.xy) / m;
        l = log2(m) / d / 13385.6;
        O.rgb += (vec3(.6, .45, .1) + clamp(l + l, 0., 1.) * vec3(.4, .4, .2)) * l;
    }
}
/* TWIGL.APP GEEKEST (300 es)
float d = 0., T = t / 4., c = cos(T), s = sin(T), m, l;vec3 p;for (int i = 0;
i++ < 35;) {p = vec3((FC.xy * 2. - r) / r.y * (.52 + .13 * sin(t * .8)), 
d - .6);p.yz *= mat2(c, -s, s, c);m = .7;for (int j = 0; 
j++ < 39;)m *= l = max(1.02, 11. / dot(p, p)),
p = vec3(-.2, 3.5, 2.2) - abs(abs(p) * l - vec3(4.8, 1.1, 3.5));
d += length(p.xy) / m;l = log2(m) / d / 1e4;o += l * vec4(1, .8, .2, 0);}
*/

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
