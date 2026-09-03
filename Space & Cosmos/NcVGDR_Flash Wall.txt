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

void mainImage(out vec4 g, vec2 h) {
    vec2 u = iResolution.xy,
         a = abs(.5 - fract((h+h-u)/u.y * vec2(1.-.7*(2.*h.y-u.y)/u.y, 1))),
         b = a, c = u-u;
    
    for(int e=0; e<4; e++)
        b = abs(b) / clamp(abs(b.x*b.y), .1, 1.) - .8,
        c = min(c, abs(b)) + fract(vec2(b.x + iTime*.5, b.y*.2 + iTime));

    vec2 k = exp(-.9*c);
    g = vec4(k.x * 2.3 + exp(-5.1*length(a)), length(k) + exp(-5.1*length(a)), 
    k.y * 4.9 + exp(-5.1*length(a)), 1.);
}
