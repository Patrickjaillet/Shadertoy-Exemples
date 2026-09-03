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
void mainImage(out vec4 n, in vec2 o) {
    vec2 p = iResolution.xy;
    float c = iTime, t = floor(c * .08), t2 = fract(c * .08);
    t2 = t2 * t2 * (3. - 2. * t2);
    float pulse = 1. + .25 * sin(c * 3.14159);
    float b = .4, g = 0., h = 1.;
    vec4 j = vec4(0.);
    vec3 a = vec3(0.), d = vec3(0., 0., -1.), k = .5 - vec3(o, 0.) / p.y;
    for (int i = 0; i < 54; i++) {
        if (h < .005) k = vec3(0.);
        a = (d += k * max(b, .001));
        float e = c * .15, f = c * .1;
        mat2 q = mat2(cos(e), -sin(e), sin(e), cos(e)), r = mat2(cos(f), -sin(f), sin(f), cos(f));
        a.zy *= q;
        a.xz *= r;
        a.z = fract(a.z + 0.5) - 0.5;
        g = 2.;
        a = -abs(a);
        float p1 = sin(t * 1.3) * .5, p2 = cos(t * 1.7) * .5, p3 = sin(t * 2.1) * .5;
        float np1 = sin((t + 1.) * 1.3) * .5, np2 = cos((t + 1.) * 1.7) * .5, np3 = sin((t + 1.) * 2.1) * .5;
        float cur1 = mix(p1, np1, t2), cur2 = mix(p2, np2, t2), cur3 = mix(p3, np3, t2);
        for (int l = 0; l < 14; l++) {
            a = abs(a) - (.3 + cur1 * .1);
            float s = dot(a, a);
            b = (5.5 + cur2 * 2.0) / max(s, 0.);
            g *= b;
            a = abs(a) * b - (2.5 + cur3 * .5);
        }
        h = length(d);
        b = min(abs(h), length(a.xz) / g);
        vec3 m = (.5 + .5 * cos(c * .6 + d.xyx * 1.2 + vec3(0., .8, 1.6) + length(a) * .05)) * (.6 + .4 * sin(c * 2.5 + float(i) * .1));
        j += vec4(m, 1.) * (0.07 * pulse) / exp(b * 220.0);
    }
    n = clamp(j * 1.2 + 0.05, 0., 1.);
}
