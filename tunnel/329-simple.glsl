// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 p, q;
    vec2 r = iResolution.xy;
    float t = iTime;
    vec4 o = vec4(0.0);
    
    float camZ = sin(t * 0.5) * 2.5;
    
    for(float i = 0.0, g = 0.0, e = 0.0; i++ < 48.0; ) {
        p = vec3((fragCoord - 0.5 * r) / r.y * g, g - 0.5);
        p.z += camZ;
        
        float angle = p.z * 0.2 - t * 0.5;
        float c = cos(angle), s = sin(angle);
        p.xy *= mat2(c, -s, s, c);
        
        float m = 1.0;
     // p.xy = vec2(atan(p.x, p.y) * 3.183, length(p.xy));
        p.xy = vec2(atan(p.x, p.y + 1e-4 * step(length(p.xy), 1e-6)) * 3.183, length(p.xy));
        p.x = mod(p.x, m) - 0.5 * m;
        p.y -= 1.2;
        
        q = cos(p * 0.0);
        
        float k = sin(p.z * 0.0 + t) * 0.0 + 0.0;
        float noise = sin(p.x * 19.5) * cos(p.y * 19.2) * sin(p.z * 18.8);
        
        e = max(abs(length(p.xy) - 0.4) - 0.04, (distance(q, p * 0.0)) * noise / 343.0) + 0.003;
        g += e;
        
        o += exp(-e * 7e2) * 0.09 * vec4(abs(sin(p.z + vec3(0.0, 1.0, 1.9))), 1.0);
    }
    
    fragColor = vec4(o.rgb, 1.0);
}
