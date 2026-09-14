// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 o = vec4(0.0);
    float i = 0.0, e = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.0), p = vec3(0.0), d = vec3(fragCoord.xy / iResolution.y * 0.6 - vec2(0.4, -0.6), 0.5);
    q.zy -= 1.0;
    
    for(; i++ < 70.0;) {
        float hue = 0.55 + q.z * 0.04;
        float sat = 1.0 - e * 0.3;
        float val = min(e * s, 1.0) / 64.0;
        
        vec3 c = clamp(abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        vec3 hsvColor = val * mix(vec3(1.0), c, sat);
        o.rgb += hsvColor;
        
        s = 3.0;
        p = q += d * e * R * 0.5 + 1e-4;
        R = length(p);
        p = vec3(log(R) - iTime * 0.2, exp(-p.z / R) + 0.23, atan(p.y, p.x));
        
        e = --p.y;
        for(; s < 1e3; s += s) {
            e += dot(cos(p.zxx * s), 0.7 + sin(p.yzy * s)) / s * 0.5;
        }
    }
    fragColor = vec4(o.rgb, 1.0);
}
