// ==== Image (image) ====
vec3 palette(in float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.26, 0.41, 0.66);
    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float t = iTime * 0.5;
    uv *= 1.5;
    
    float m = 0.0;
    float r = dot(uv, uv);
    
    for(int i = 0; i < 24; i++) {
        uv = abs(uv) - vec2(0.3, 0.4);
        
        if(uv.x < uv.y) uv = uv.yx;
        
        float k = 1.35 / max(dot(uv, uv), 0.01);
        uv *= k;
        uv -= vec2(0.5, 0.2) * (1.0 + sin(t));
        
        m += exp(-3.5 * dot(uv, uv));
    }
    
    vec3 col = palette(m * 0.12 + t);
    col *= 1.0 - exp(-2.0 * m);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
