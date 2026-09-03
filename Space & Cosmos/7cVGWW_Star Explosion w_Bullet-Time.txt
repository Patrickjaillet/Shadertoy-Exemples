// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    vec2 V = (U+U - iResolution.xy) / min(iResolution.x, iResolution.y);
    float T = mod(iTime, 5.5),
          t = T < 1.5 ? T * 0.8 : T < 3.5 ? 1.2 + (T - 1.5) * 0.05 : 1.3 + (T - 3.5) * 1.5,
          a = T < 1.5 ? -0.6 : T < 3.5 ? mix(-0.6, 0.6, smoothstep(0.0, 1.0, (T - 1.5) / 2.0)) : 0.6,
          C = cos(a * 0.5), S = sin(a * 0.5);
    mat2 Rbg = mat2(C, -S, S, C);
    vec3 Sbg = vec3(0);
    for(int k = 0; k < 3; k++) {
        float f = float(k + 1) * 123.45;
        vec2 uv = Rbg * V * (float(k) * 2.0 + 3.0) + vec2(sin(f), cos(f)) * 5.0 + vec2(0.0, t * 0.1);
        vec2 g = fract(uv) - 0.5;
        vec2 id = floor(uv);
        float h = fract(sin(dot(id, vec2(12.9898, 78.233) + float(k))) * 43758.5453);
        if(h > 0.8) {
            float d = length(g);
            float br = smoothstep(0.1, 0.0, d) * (sin(iTime * (h * 5.0 + 2.0) + h * 6.28) * 0.5 + 0.5);
            Sbg += vec3(0.8, 0.9, 1.0) * br * h * 0.3;
        }
    }
    U = (U+U - iResolution.xy) / min(iResolution.x, iResolution.y);
    float C_main = cos(a), S_main = sin(a);
    mat2 R = mat2(C_main, -S_main, S_main, C_main);
    vec3 o = vec3(0);
    for(int j = 0; j < 64; j++) {
        float A = float(j) * 0.098174778;
        vec3 P = vec3(cos(A) * t * 1.5, -0.2, sin(A) * t * 1.5);
        P.xz = R * P.xz;
        float D = P.z + 2.5;
        if(D > 0.1) {
            vec2 X = P.xy / D;
            float d = length(U - X);
            o += vec3(1, 0.5, 0.2) * (0.0002 / (d * d + 0.0001)) * max(0.0, 1.0 - t * 0.5) / D;
        }
    }
    for(int i = 0; i < 512; i++) {
        float id = float(i),
              f = fract(sin(id * 12.9898) * 43758.5453),
              p = f * 6.283185,
              c = fract(cos(id * 78.233) * 43758.5453) * 2.0 - 1.0,
              s = sqrt(max(0.0, 1.0 - c * c)),
              Sspd = mix(0.4, 2.8, fract(sin(id * 45.12) * 43758.5453));
        vec3 P3 = vec3(s * cos(p), s * sin(p), c) * (t * Sspd) - vec3(0, 0.25 * t * t, 0);
        P3.xz = R * P3.xz;
        float Z = P3.z + 2.5;
        if(Z > 0.1) {
            vec2 X = P3.xy / Z;
            float d = length(U - X),
                  pt = ((0.00015 / (d * d + 0.00003)) + (0.002 / (d + 0.008))) * max(0.0, 1.0 - t * 0.333333) / (Z * Z);
            o += mix(vec3(4, 1.8, 0.3), vec3(1, 0.15, 0.02), fract(id * 0.37)) * pt;
        }
    }
    vec3 CP = vec3(0);
    CP.xz = R * CP.xz;
    o += vec3(3, 1.5, 0.6) * exp(-length(U - CP.xy / (CP.z + 2.5)) * 4.0) * max(0.0, 1.0 - t * 2.5);
    O = vec4(o + Sbg, 1);
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
