// ==== Image (image) ====
void mainImage(out vec4 O, vec2 f) {
    vec3 c = vec3(0, 1.00, -2.7), R = iResolution, p;
    float a = 0.0, e = 0.0, v, u, g; 

    float zoom = 1.50 + sin(iTime * 0.8) * 0.25;
    
    for (O *= a; a < 171.0; a += 1.0) {
        p = c += e * vec3((f - 0.5*R.xy) / R.y, zoom);
        
        p.xz *= mat2(cos(0.52*iTime - vec4(0, 11, 33, 0)));
        p.xz += sin(iTime * 2.5 + p.y * 1.5 + vec2(0., 1.57)) * 0.06 * max(0., p.y);
        e = v = 7.4;
        for (g = 0.; g++ < 10.; )
            v /= u = dot(p,p),
            p /= u + 0.04,
            p.y = 1.61 - p.y,
            e = min(min(e, max(p.y, length(p.xz = abs(p.xz*mat2(1, -0.4, 0.6, 1)) - 0.61) - 0.055/u) / v), c.y - 0.00);
        
        O += (2.3 + cos(v*0.01 + vec4(0, 2, 1, 0))) / exp(e*565.8 + a*0.015 + 4.9);
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
