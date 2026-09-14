// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 O = vec4(0.0);
    float i = 0.0, j, t = 0.0, v, s, T = iTime;
    vec3 p, q, r = normalize(vec3(fragCoord + fragCoord - iResolution.xy, iResolution.y));
    
    for (; i++ < 48.0; ) {
        p = r * t;
        p *= 0.95 + 0.05 * fract(sin(dot(fragCoord, vec2(12.9898, 78.233)) + T) * 43758.5453);
        p.z -= 0.8 * T;
        p.y += sin(floor(p.z * 0.2)) * 2.0;
        
        v = 0.0;
        s = 1.0;
        
        float jitter = sin(T * 0.05);
        float sj = sin(jitter), cj = cos(jitter);
        mat2 rot = mat2(cj, sj, -sj, cj);
        
        float jitter2 = cos(T * 0.03);
        float sj2 = sin(jitter2), cj2 = cos(jitter2);
        mat2 rot2 = mat2(cj2, sj2, -sj2, cj2);
        
        for (j = 1.0; j++ < 24.0; ) {
            p.xy *= rot;
            p.xz *= rot2;
            p *= 1.61803398875;
            s *= 1.61803398875;
            p += sin(p.zxy * 1.5 + vec3(T * 0.22, T * 0.33, T * 0.11)) * 0.4;
            q = abs(mod(p - 1.0, 2.0) - 1.0);
            float box = (0.85 - max(max(q.x, q.y), q.z)) / s;
            v = max(v, box);
        }
        
        v = max(v, 0.0001);
        t += max(v * 0.22, 0.001);
        
        vec4 logColor = exp(sin(i * 0.035 + vec4(0.0, 1.5708, 3.1416, 0.0) + T * 0.15)) * (1.0 / (1.0 + t * t * 0.04));
        O += logColor * (0.012 / v);
    }
    
    O = 1.0 - exp(-O * 0.005);
    fragColor = pow(O, vec4(0.454545));
}
