// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float distToCenter = length(uv);
    float ripple = sin(distToCenter * 20.0 - iTime * 4.0) * 0.05;
    uv *= 1.0 + ripple;
    
    vec3 col = vec3(0.0);
    vec3 p = vec3(uv * -7.9, 0.1);
    
    float time = iTime * 0.15;
    mat2 r1 = rot(0.6 + 0.47 * sin(time));
    mat2 r2 = rot(0.4 + 0.58 * cos(time));
    
    vec3 acc = vec3(0.0);
    for(int i = 0; i < 60; i++) {
        p.xy *= r1;
        p.xz *= r2;
        
        p = abs(p) - vec3(1.0, 0.1, 0.1);
        
        float dist = length(p.xy);
        
        if (dist > 0.4 && dist < 0.6) {
            float d = length(p);
            float glow = 0.06 / (0.01 + d * d * 0.5);
            acc += glow * mix(vec3(0.1, 0.5, 0.9), vec3(0.9, 0.2, 0.5), sin(float(i)*0.1 + iTime) * 0.5 + 0.5) * (1.0 - float(i) / 60.0);
        }
    }
    
    col = acc * 0.15;
    col = 1.0 - exp(-col * 1.5);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
