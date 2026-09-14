// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.3;
    vec3 col = vec3(0.0);
    
    for (float i = 0.0; i < 40.0; i++) {
        float scale = pow(0.94, i + fract(t));
        float angle = i * 0.25 + t * 0.15;
        vec2 p = (uv / scale) * mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        
        float a = atan(p.y, p.x);
        float r = length(p);
        
        float petals = abs(sin(a * 11.5)) * abs(cos(a * 10.7));
        float inner = smoothstep(0.1, 0.3, r) * smoothstep(1.0, 0.4, r);
        float shape = petals * inner;
        
        float edge = smoothstep(0.28, 0.00, abs(shape - 0.22));
        
        vec3 layerCol = mix(vec3(0.0, 0.0, 0.5), vec3(1.0, 0.3, 0.3), sin(i * 0.5 - t + r * 6.0) * 0.5 + 0.5);
        layerCol = mix(layerCol, vec3(1.0, 0.8, 1.0), smoothstep(0.3, 0.0, r));
        
        col += edge * layerCol * smoothstep(1.0, 0.3, r) * pow(0.92, i) * 2.6;
    }
    
    col += vec3(1.0, 0.7, 0.3) * (0.01 / (length(uv) + 0.01));
    fragColor = vec4(tanh(col * 0.5), 0.0);
}
