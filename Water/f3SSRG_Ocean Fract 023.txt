// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 o = vec4(0.0);
    float i = 0.0, e = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.0), p = vec3(0.0), d = vec3(fragCoord.x / iResolution.y * 0.8 - 0.7, (iResolution.y - fragCoord.y) / iResolution.y * 0.8 - 0.4, 0.6);
    q.zx -= 2.0;
    q.z += iTime * 2.0;
    
    for(; i++ < 90.0;) {
        float val = min(abs(e) * s, 1.0) / 93.3;
        o.rgb += vec3(val);
        
        s = 4.0;
        p = q += d * e * R * 0.4 + 1e-4;
        R = length(p);
        p = vec3(atan(p.z, p.x) + iTime * 0.35, log(R) + 0.5, exp(-p.y / R) + 0.15);
        
        e = --p.z;
        for(; s < 2e3; s += s) {
            e += dot(sin(p.xyz * s), 1.0 + cos(p.zxy * s - iTime * 1.5)) / s * 0.25;
        }
    }
    fragColor = vec4(vec3(dot(o.rgb, vec3(0.299, 0.587, 0.114))), 1.0);
}
