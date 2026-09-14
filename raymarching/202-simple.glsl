// ==== Image (image) ====
vec3 hsv(float h, float s, float v) {
    vec4 t = vec4(1.0, 0.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + t.xyz) * 6.0 - vec3(t.w));
    return v * mix(vec3(t.x), clamp(p - vec3(t.x), 0.0, 1.0), s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r  = iResolution.xy;
    vec2 FC = fragCoord;
    float t = iTime * 0.5;
    vec4 o  = vec4(0.0, 0.0, 0.0, 1.0);
    
    float e = 1.0;
    float R = 1.0;
    vec3 q = vec3(0.0, 0.0, -1.0);
    vec3 p;
    vec3 d = vec3((FC - 0.5 * r) / r.y, 0.7);
    
    float angle = cos(t) * 0.2;
    float ca = cos(angle);
    float sa = sin(angle);
    d.xy *= mat2(ca, -sa, sa, ca);
    
    for (int i = 0; i < 96; ++i) {
        o.rgb += hsv(sin(t * 0.0) * 0.04 - e * 0.01, 0.0, e / 90.0) + 0.002;
        p = q += d * max(e, 0.03) * R * 0.12;
        
        R = max(length(p), 0.0001);
        e = asin(clamp(-p.z / R, -1.0, 1.0));
        
        float a = atan(p.x, p.y);
        p = vec3(log2(R) - t, e, a) - 1.0;
        
        float s = 1.0;
        for (int j = 0; j < 8; ++j) {
            e += abs(dot(sin(p.zyx * s), cos(p.yxz * s))) / s * 0.75;
            s *= 2.0;
        }
    }
    
    o.rgb = pow(o.rgb, vec3(1.0));
    fragColor = o;
}
