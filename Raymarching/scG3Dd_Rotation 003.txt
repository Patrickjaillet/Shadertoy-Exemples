// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
void mainImage(out vec4 v, in vec2 w) {
    vec2 l = iResolution.rg, A = (w * 2. - l) / l.g;
    
 
    float b = iTime * .4, m = floor(b * .2), B = m + 1., C = smoothstep(0., 1., fract(b * .2)), f = floor(m), g = floor(B), c = 0.;
    vec3 D = vec3(fract(sin(f * .1031) * 43758.5453), fract(sin((f + 1.) * .1031) * 43758.5453), fract(sin((f + 2.) * .1031) * 43758.5453)) * 2. - 1., E = vec3(fract(sin(g * .1031) * 43758.5453), fract(sin((g + 1.) * .1031) * 43758.5453), fract(sin((g + 2.) * .1031) * 43758.5453)) * 2. - 1., h = mix(D, E, C), i = vec3(.02), F = vec3(0., 0., -3.), G = normalize(vec3(A, 1.));
    
    for (int n = 0; n < 120; n++) {
        vec3 a = F + G * (c + .2);
        float o = b * 1.4 + h.r, p = cos(o), s1 = sin(o);
        a.rb = mat2(p, -s1, s1, p) * a.rb;
        float q = b + h.g, s = cos(q), s2 = sin(q);
        a.rg = mat2(s, -s2, s2, s) * a.rg;
        
        vec3 t = a;
        
        // --- NOUVELLE BOUCLE DE FOLDING (Mandelbox / Spherical Inversion) ---
        float d = 1.0;
        for (int fractalIteration = 0; fractalIteration < 9; fractalIteration++) {
            float squaredDistanceToOrigin = dot(a, a);
            float currentScaleFactor = max(0.95, 9.0 / max(squaredDistanceToOrigin, 1e-4));
            d *= currentScaleFactor;
            vec3 scaledPosition = abs(a) * currentScaleFactor;
            vec3 foldedPosition = abs(scaledPosition - vec3(1.0, 1.2, 3.0));
            a = vec3(1.5, 4.0, 3.0) - foldedPosition;
        }
        
        float k = distance(a.rb, a.gr) / d;
        k = max(k, 1e-4);
        
        float e = k, H = length(t.gg), I = mod(H, t.g) / d * .5;
        e += I, c += e * .35;
        
        float J = .59, K = .4 - e, L = d / 4e3;
        vec3 M = mod(J * 6. + vec3(0., 4., 2.), 6.), N = clamp(abs(M - 3.) - 1., 0., 1.), O = L * mix(vec3(1.), N, K);
        float P = exp(-e * 45.) * exp(-c * .1);
        i += O * P;
        
        if (c > 30. || i.r > 15.) break;
    }
    v = vec4(i, 1.);
}
