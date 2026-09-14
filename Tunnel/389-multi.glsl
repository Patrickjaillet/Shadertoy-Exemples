// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    float amount = 0.005;
    vec3 col;
    col.r = texture(iChannel0, uv + vec2(amount, 0)).r;
    col.g = texture(iChannel0, uv).g;
    col.b = texture(iChannel0, uv - vec2(amount, 0)).b;
    
    vec3 bloom = vec3(0);
    float total = 0.0;
    for(float i = -4.0; i <= 4.0; i++) {
        for(float j = -4.0; j <= 4.0; j++) {
            vec2 offset = vec2(i, j) * 0.002;
            bloom += texture(iChannel0, uv + offset).rgb;
            total += 1.0;
        }
    }
    col += (bloom / total) * 0.6;
    
    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));
    
    float d = length(uv - 0.5);
    col *= smoothstep(0.8, 0.2, d);
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

mat2 rot(float a) {
    float s = cos(a), c = sin(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    p.z += iTime * 0.5;
    vec3 p2 = p;
    p2.xy *= rot(p.z * 0.1);
    vec2 q = vec2(length(p2.xy) - 2.0, p2.z);
    float tunnel = -(length(p2.xy) - 3.0);
    
    for(float i=0.0; i<3.0; i++) {
        p2.xy *= rot(iTime * 0.2 + i);
        p2.xy = abs(p2.xy) - 0.5;
    }
    
    float geometry = length(p2.xy) - 0.15 + sin(p.z * 5.0) * 0.05;
    return min(tunnel, geometry);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, -1);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    float t = 0.0;
    vec3 col = vec3(0);
    float glow = 0.0;

    for(int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        
        float g = 0.012 / (0.015 + abs(d));
        glow += g;
        
        if(d < 0.001 || t > 40.0) break;
        t += d * 0.5;
    }
    
    vec3 baseCol = palette(iTime * 0.1 + t * 0.05);
    col += baseCol * glow * 0.2;
    col += palette(t * 0.1) * (1.0 / (1.0 + t * t * 0.1));
    
    fragColor = vec4(col, t);
}
