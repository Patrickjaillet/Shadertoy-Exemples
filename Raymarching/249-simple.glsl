// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p, float t) {
    p.z -= 150.0;
    p.xz *= vec2(2.5, 0.15);
    float d2 = dot(p, p);
    p *= 850.0 / max(d2, 1e-4);
    float s = 15.0 + dot(p - vec3(30, 0, 0), vec3(0.2, 0.5, 0.25));
    float a = 0.02;
    for(int i = 0; i < 8; i++) {
        p += sin(t * 1.5 - p.yzx * 1.8);
        s -= abs(dot(cos(t * 2.1 - 0.05 * p.z + 0.8 * p / a), vec3(a)));
        a += a;
    }
    float g = abs(min(s, abs(dot(fract(p / 80.0) * 80.0 - 40.0, vec3(0.08)))));
    return 0.15 + 0.3 * g;
}

void mainImage(out vec4 o, in vec2 u) {
    vec2 r = iResolution.xy;
    vec2 uv = (u + u - r) / r.y;
    float t = iTime;
    
    vec3 col = vec3(0);
    float dither = fract(sin(dot(u, vec2(12.9898, 78.233))) * 43758.5453);

    for(float j = 0.0; j < 1.0; j += 0.25) {
        float T = t + j * 0.015;
        vec3 rd = normalize(vec3(uv * mat2(cos(T * 0.1 - vec4(0, 11, 33, 0))), 1.5));
        float d = dither * 0.1;
        
        for(int i = 0; i < 115; i++) {
            vec3 p = rd * d;
            float s = map(p, T);
            
            float logFog = exp(-d * 0.012);
            float weight = (1.6 / max(s, 0.001)) * logFog;
            
            vec3 pCol = vec3(1.8, 0.7, 0.2);
            pCol.r += sin(d * 0.15) * 0.4;
            pCol.b += cos(d * 0.1) * 0.2;
            
            col += pCol * weight * 0.018;
            d += max(s * 0.5, 0.15);
            if(d > 250.0) break;
        }
    }
    
    col = smoothstep(0.0, 1.0, tanh(col / 18.0));
    
    vec3 final = col;
    final.g *= 0.95;
    final.b *= 1.1;
    
    vec3 bg = vec3(0, 0.04, 0.08);
    final = mix(bg + final, final, smoothstep(0.0, 0.3, final.r));
    
    float vig = 1.0 - dot(uv * 0.5, uv * 0.5);
    o = vec4(final * vig, 1.0);
}
