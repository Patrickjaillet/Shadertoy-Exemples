// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.3;
    float PI = 3.14159265359;
    
    vec4 o = vec4(0.0);
    
    float g = 0.0;
    float e = 0.0;
    float s = 0.0;
    
    float depthDistort = sin(uv.y * 5.0 + t) * 0.03 + cos(uv.x * 4.0 - t * 0.7) * 0.03;
    uv += depthDistort;
    
    for (int i = 0; i < 50; i++) {
        float fi = float(i);
        
        vec3 p = vec3(uv, 0.0) * g;
        
        float a = t * 0.2;
        float sa = sin(a);
        float ca = cos(a);
        mat2 m = mat2(ca, -sa, sa, ca);
        p.xz *= m;
        p.yz *= m;
        
        p.z += t / PI;
        p += 1.0 - fi / 15000.0;

        s = 3.5;
        
        for (int j = 0; j < 8; j++) {
            if (p.x + p.y < 0.0) p.xy = -p.yx;
            if (p.x + p.z < 0.0) p.xz = -p.zx;
            if (p.y + p.z < 0.0) p.zy = -p.yz;
            
            p = abs(p - 0.9) - 0.9;
            
            e = dot(p, p) * 0.85; 
            s /= e;
            p = p / e;
            
            p.z += 0.15;
            p.x -= 0.05;
        }
        
        e = p.y / s;
        g += abs(e);
        
        float depthFactor = 1.0 - exp(-g * 0.5);
        vec4 baseCol = 0.5 + 0.5 * sin(vec4(1.5, 2.5, 4.0, 0.0) + log(s) * (0.25 + depthFactor * 0.1));
        
        o += 0.00035 / (0.012 + abs(e) * (1.0 - baseCol * 0.6));
    }

    vec3 color = o.rgb;
    
    color *= 1.5;
    
    float vignette = 1.0 - length(uv) * 0.2;
    color *= vignette;
    
    float depthFog = smoothstep(0.3, 0.2, length(uv));
    vec3 fogColor = vec3(0.15, 0.2, 0.5);
    color = mix(color, fogColor, depthFog * 0.1);
    
    color = pow(clamp(color, 0.0, 1.0), vec3(1.2));
    
    float lum = dot(color, vec3(0.299, 0.587, 0.114));
    color += pow(lum, 2.5) * vec3(0.3, 0.5, 0.8) * 0.15;
    
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(gray), color, 1.3);
    
    float centerGlow = 1.0 - length(uv) * 0.5;
    color += centerGlow * vec3(0.1, 0.05, 0.0) * 0.3;
    
    fragColor = vec4(color, 1.0);
}
