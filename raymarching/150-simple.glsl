// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float an = iTime * 0.05;
    vec3 ro = vec3(sin(an) * 0.0, 0.1, cos(an) * -4.8);
    vec3 ta = vec3(0.0, 0.4, 0.0);
    
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.5 * ww);
    
    float t = 1.0;
    float acc = 0.0;
    
    for(int i = 0; i < 158; i++) {
        vec3 p = ro + rd * t;
        
        float scale = 1.0;
        for(int j = 0; j < 5; j++) {
            p.xyz = 2.0 * clamp(p.xyz, -1.0, 0.5) - p.xyz;
            float r2 = dot(p, p);
            float k = max(4.8 / r2, 1.0);
            p *= k;
            scale *= k;
        }
        
        float d = (length(p.xz) - 0.20) / abs(scale);
        
        if(d < 0.0005 || t > 8.0) break;
        
        t += d * 0.5;
        acc += exp(-4.0 * d);
    }
    
    vec3 col = vec3(0.19, 0.18, 0.5) * (acc * 0.04);
    col += vec3(1.0, 0.0, 0.0) * clamp(t * 0.1, 0.0, 1.0);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
