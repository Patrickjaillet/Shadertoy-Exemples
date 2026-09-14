// ==== Image (image) ====
mat2 rotate2D(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, s, -s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 color = vec3(0.0);
    
    float time = iTime;
    float rayDepth = 0.00;
    
    for (int i = 0; i < 82; i++) {
        vec3 p = vec3(uv * rayDepth, rayDepth - 1.0);
        
        p.yz *= rotate2D(4.0);
        
        float r = length(p);
        vec3 logP = vec3(
            log(r) - time,
            asin(p.z / r),
            atan(p.y, p.x) + time
        );
        
        float d = logP.y * 2.7 + 2.0;
        float scale = 1.0;
        
        for (int j = 0; j < 6; j++) {
            d -= abs(dot(cos(logP * scale), logP - logP + 0.4)) / scale;
            scale *= 3.0;
        }
        
        float glow = exp(-abs(d) * 29.4) + 0.00;
        vec3 glowColor = vec3(1.0, 0.1, 0.0) * (0.2 + 1.0 * cos(logP.y - vec3(0.9, 26.0, 0.0)));
        
        color += glow * glowColor * 0.010;
        
        rayDepth += max(abs(d) * r * 0.05, 0.000);
    }
    
    color = pow(color, vec3(0.12));
    color = clamp(color, 0.0, 1.0);
    
    fragColor = vec4(color, 0.0);
}
