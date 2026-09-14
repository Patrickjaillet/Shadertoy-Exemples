// ==== Image (image) ====
mat2 r2(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    p.xy *= r2(p.z * 0.0 + iTime * 0.1);
    p.xz *= r2(iTime * 0.2);
    
    float d = 10.0;
    for(int i = 0; i < 16; i++) {
        p = abs(p) - 1.5;
        p.xy *= r2(1.0);
        p.yz *= r2(1.0);
        d = min(d, length(p.xz) - 0.2);
    }
    return d;
}

void mainImage(out vec4 o, vec2 u) {
    vec2 uv = (u - 1.0 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, -6), rd = normalize(vec3(uv, 1.2)), p;
    float t = 0.0, d;
    
    for(int i = 0; i < 64; i++) {
        p = ro + rd * t;
        d = map(p);
        if(d < 0.001 || t > 80.0) break;
        t += d * 0.5;
    }
    
    vec3 col = vec3(0.0, 0.00, 0.0) * (t * 0.0);
    col += vec3(1.0, 0.1, 0.0) * (0.05 / (0.00 + d * d * 10.0));
    col += vec3(0.3, 0.7, 1.0) * (0.02 / (0.01 + abs(p.x) * 5.0));
    
    o = vec4(col, 0.0);
}
