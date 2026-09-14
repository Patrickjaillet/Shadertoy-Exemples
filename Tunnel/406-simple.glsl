// ==== Image (image) ====
void mainImage(out vec4 A, in vec2 B) {
    vec2 i = (B - .5 * iResolution.xy) / iResolution.y;
    float b = iTime * 3.;
    vec3 c = vec3(0., 0., b);
    c.x = sin(c.z * .15) * 5.2;
    c.y = cos(c.z * .1) * 4.;
    vec3 e = vec3(0., 0., b - 5.6);
    e.x = sin(e.z * .29) * 2.;
    e.y = cos(e.z * .5) * 4.;
    vec3 j = normalize(e - c);
    float n = sin(b * .2) * .5;
    vec3 C = vec3(sin(n), cos(n), 0.), o = normalize(cross(j, C)), D = normalize(cross(o, j)), E = normalize(i.x * o + i.y * D + 1.2 * j);
    float f = 0.;
    vec3 p = vec3(0.);
    for (int q = 0; q < 200; q++) {
        vec3 F = c + E * f, a = F;
        a.x -= sin(a.z * .15) * 4.;
        a.y -= cos(a.z * .1) * 4.;
        float rumble = sin(a.z * 5.0 + b * 20.0) * cos(a.y * 5.0 + b * 15.0) * 0.05;
        a.xy += rumble;
        float twist = sin(a.z * 0.1 + b * 0.5) * 0.5;
        float st = cos(twist), tt = sin(twist);
        a.xy *= mat2(st, -tt, tt, st);
        float r = a.z * .05 + b * .1, s = cos(r), t = sin(r);
        a.xy *= mat2(s, -t, t, s);
        vec3 u = a;
        float drop = sin(u.z * 2.0 - b * 4.0 + sin(u.x * 3.0) * 2.0);
        drop = smoothstep(0.8, 1.0, drop) * 0.4;
        a.z = abs(mod(a.z, 16.) - 8.) - 4.;
        float v = 1.;
        for (int k = 0; k < 10; k++) {
            a = abs(a) - 1.1;
            float w = float(k) * .25 + b * .05, g = cos(w), h = sin(w);
            a.xy *= mat2(g, -h, h, g);
            a.xz *= mat2(g, -h, h, g);
            a *= 1.4;
            v *= 1.4;
        }
        float G = (length(a) - 1. - drop) / v, H = 2.5 - length(u.xy), l = max(H, G), I = 1. / (.6 + abs(l) * 13.2);
        vec3 m = vec3(.1, .6, .9) * sin(u.z * .1 + b);
        m = abs(m) + vec3(.6, .2, 0.);
        p += m * I * .015 * exp(-f * .015);
        if (abs(l) < .001 || f > 150.) break;
        f += l * .45;
    }
    vec3 d = p;
    d = mix(d, vec3(0.), smoothstep(50., 140., f));
    d *= 1.2 - length(i);
    d = pow(clamp(d, 0., 1.), vec3(.4545));
    A = vec4(d, 1.);
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
