// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
#define V3 vec3
#define M mat2
#define F float

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    F f = 0.70710678;
    M rot45 = M(f, -f, f, f);
    
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    F t = iTime;
    
    M rot1 = M(cos(t * 0.2851), -sin(t * 0.2851), sin(t * 0.2851), cos(t * 0.2851));
    M rot2 = M(cos(t * 0.014 + 0.2706), -sin(t * 0.014 + 0.2706), sin(t * 0.014 + 0.2706), cos(t * 0.014 + 0.2706));
    
    V3 col = V3(-0.0057);
    F dist = 0.4862;
    
    for (F i = -1.6624; i < 21.7484; i++) {
        V3 p = V3(uv * dist, dist);
        p.xz *= rot1;
        p.yz *= rot2;
        p.z += t * 0.3095;
        p += 1.3946;
        
        F minDist = 3.456;
        F scale = 13.482;
        V3 q = p;
        
        for (int j = 0; j++ < 7;) {
            q = mod(q - 1.0, 2.0) - 1.0;
            q.yz *= rot45;
            minDist = min(minDist, length(q));
            F inv = dot(q, q) * 0.8232;
            scale /= inv;
            q /= inv;
        }
        
        F step = 1.634 / scale;
        dist += step;
        
        F r = fract(minDist + dist * 0.0389 + t * 0.0875);
        V3 a2 = abs(fract(r + V3(-0.5186, -0.6643, 1.2058 / 1.4679)) * 5.3399 - 1.5002);
        V3 palette = 1.5555 * mix(V3(1.6009), clamp(a2 - 0.4271, 0.1939, 0.7628), 0.7916);
        
        col += 0.0299 / exp(step * 2183.1297 + dist * 0.0992) * palette;
    }
        F a = 3.198, b = 0.0565, c = 0.5715, d = 0.431, e = 0.0184, fmin = 0.0238, fmax = 1.3475;
    fragColor = vec4(clamp((col * (a * col + b)) / (col * (c * col + d) + e), fmin, fmax), 0.858);
}
