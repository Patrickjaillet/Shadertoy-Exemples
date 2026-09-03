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
    vec2 l = iResolution.xy;
    vec2 A = (w * 2. - l) / l.y;
    
    float b = iTime * .4;
    float m = floor(b * .2);
    float B = m + 1.;
    float C = smoothstep(0., 1., fract(b * .2));
    float f = floor(m);
    float g = floor(B);
    float c = 0.;
    
    vec3 D = vec3(
        fract(sin(f * .1031) * 43758.5453),
        fract(sin((f + 1.) * .1031) * 43758.5453),
        fract(sin((f + 2.) * .1031) * 43758.5453)
    ) * 2. - 1.;
    
    vec3 E = vec3(
        fract(sin(g * .1031) * 43758.5453),
        fract(sin((g + 1.) * .1031) * 43758.5453),
        fract(sin((g + 2.) * .1031) * 43758.5453)
    ) * 2. - 1.;
    
    vec3 h = mix(D, E, C);
    vec3 i = vec3(.02);
    vec3 F = vec3(0., 0., -3.);
    vec3 G = normalize(vec3(A, 1.));
    
    for (int n = 0; n < 120; n++) {
        vec3 a = F + G * (c + .2);
        
        float o = b * 1.4 + h.r;
        float p = cos(o);
        float s1 = sin(o);
        a.rb = mat2(p, -s1, s1, p) * a.rb;
        
        float q = b + h.g;
        float s = cos(q);
        float s2 = sin(q);
        a.rg = mat2(s, -s2, s2, s) * a.rg;
        
        vec3 t = a;
        float d = 1.1;
        float j = 1.;
        

        for (int u = 0; u < 5; u++) {
            a = vec3(5.5) - abs(a * j - h.b * .3);
            j = 2.67;                       
            d *= j;                             
        }
        
        float k = distance(a.rb, a.gr) / d;
        k = max(k, 1e-4);
        
        float e = k;
        float H = length(t.gg);
        float I = mod(H, t.g) / d * .5;
        
        e += I;
        c += e * .35;
        
        float J = .59;
        float K = .4 - e;
        float L = d / 4e3;
        
        vec3 M = mod(J * 6. + vec3(0., 4., 2.), 6.);
        vec3 N = clamp(abs(M - 3.) - 1., 0., 1.);
        vec3 O = L * mix(vec3(1.), N, K);
        
        float P = exp(-e * 45.) * exp(-c * .1);
        i += O * P;
        
        if (c > 30. || i.r > 15.) break;
    }
    
    v = vec4(i, 1.);
}
