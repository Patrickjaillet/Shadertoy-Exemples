// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime; 
    vec3 col = vec3(0.0);
    
    for (float i = 0.0; i < 32.0; i++) {
        float scale = pow(0.98, i);
        float angle = i * 0.15;
        vec2 p = (uv / scale) * mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        
        float r = length(p);
        float a = atan(p.y, p.x);
        
        float wind = sin(a * 4.0 + t * 10.0) * r * 0.1;
        a += wind;
        
        p += vec2(sin(r * 2.6 + i * 1.2), cos(r * 3.4)) * 0.02;
        
        float petC = floor(3.0 + mod(i, 3.0)); 
        
        float petVal = mix(abs(sin(a)) * 0.5, sin(petC * a), 1.0) * (1.0 - r);
        
        float edge = smoothstep(0.2, 0.16, abs(petVal - 0.5));
        vec3 layerCol = mix(vec3(1.0, 0.2, 0.4), vec3(1.0, 0.7, 0.8), sin(i + r * 8.0));
        
        col += edge * layerCol * smoothstep(0.0, 0.0, 0.8 - r) * pow(0.98, i) * 1.5;
    }
    
    fragColor = vec4(tanh(col * 0.3), 1.0);
}
