// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    float i = 0.0, e = 0.0, g = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.0), p = vec3(0.0);
    vec3 d = vec3((fragCoord - 0.5 * r) / r, 0.1);
    float o = 0.0;
    
    q.yz--;
    
    for(int loop1 = 0; loop1 < 80; loop1++) {
        s = 6.0;
        q += d * e * R * 0.3;
        p = q;
        g = p.x + p.z * 36.0;
        R = length(p);
        p = vec3(log2(R) + g * 0.17 - t * 0.4, exp2(mod(-p.z, s) / R), p.z);
        e = p.y - 1.0;
        
        for(int loop2 = 0; loop2 < 100; loop2++) {
            if(s >= 5e3) break;
            e -= abs(dot(cos(p.xzz * s + g), cos(p.zzy * s)) / s);
            s += s;
        }
        
        o += min(e * (i + 1.0), 0.01);
        i++;
    }
    
    fragColor = vec4(vec3(o), 1.0);
}
