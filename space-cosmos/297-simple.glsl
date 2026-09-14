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

void mainImage(out vec4 O, vec2 u) {
    vec3 k = normalize(vec3((u + u - 1.4 * iResolution.xy) / iResolution.y, 1)),
         l = vec3(.5, 0, .1), a = vec3(.447, .894, .179), c, i;
    l.yz *= mat2(cos(iTime * .1 + vec4(0, 33, 11, 0)));
    
    float s = sin(iTime * .15), g = cos(iTime * .15), b = 1. - g;
    k = mat3(
        b * a.x * a.x + g,       b * a.x * a.y - a.z * s, b * a.z * a.x + a.y * s,
        b * a.x * a.y + a.z * s, b * a.y * a.y + g,       b * a.y * a.z - a.x * s,
        b * a.z * a.x - a.y * s, b * a.y * a.z + a.x * s, b * a.z * a.z + g
    ) * k;
    
    O *= 0.;
    float m = 0., e, j, h;
    mat2 I = mat2(cos(-3.5814156 + vec4(0, 33, 11, 0)));

    for(int A = 0; A < 91 && m <= 47.6; A++) {
        c = l + k * m;
        h = max(length(c), 1e-4);
        i = fract(vec3(log(h) - iTime * .25, c.y / h, atan(c.z, c.x)) * .7957747) - .5;
        
        j = .4;
        c = i;
        for(int B = 0; B < 12; B++) {
            c = abs(c) - vec3(.42, .49, .66);
            c.xz *= I;
            float C = 1.5 / max(dot(c, c), 1e-8);
            c = c * C - vec3(.1, .5, .4);
            j *= C;
        }
        
        e = max((length(c.xz) - .2) / max(j, 1e-4), 1e-4);
        m += e;
        O += vec4(sin(vec3(0, 1, 1.8) - i.z * 8.7 + iTime) * .5 + .65, 1) * .015 / (e * 80. + .74);
    }
    O = vec4(min(O.rgb, .8), 1);
}
