// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float i = 0.0, e = 0.0, R, s;
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 d = normalize(vec3(uv, 1.2));
    vec3 q = vec3(0.0, 1.4, -2.5);
    vec4 o = vec4(0.0);
    
    mat2 rotY = mat2(cos(iTime * 0.1), sin(iTime * 0.1), -sin(iTime * 0.1), cos(iTime * 0.1));
    d.xz *= rotY;
    
    for (; i++ < 180.0;) {
        float h = 0.25 - e;
        vec3 c = clamp(abs(mod(h * 15.0 + vec3(0.0, 2.0, 4.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        o.rgb += (vec3(0.1, 0.15, 0.25) + 0.8 * c) * max(0.0, (0.35 - e)) * (1.0 / (1.0 + R * R * 0.1)) / 40.0;
        
        s = 1.5;
        vec3 p = q += d * max(e, 0.005) * 0.23;
        R = length(p);
        
        float angle = atan(p.x, p.z);
        vec4 p_sph = vec4(log(R) - iTime * 0.3, (p.y / R) + 0.6, cos(angle), sin(angle));
        e = p_sph.y;
        
        float noise = 0.0;
        float amp = 0.6;
        for (int j = 0; j < 18; j++) {
            vec3 g = vec3(p_sph.xy, p_sph.z + p_sph.w) * s;
            noise += abs(dot(sin(g + iTime * 0.1), cos(g.zxy * 0.8))) * amp;
            s *= 1.7;
            amp *= 0.52;
        }
        e -= noise;
        
        if (e < 0.0005) {
            float fade = (180.0 - i) / 180.0;
            o.rgb += vec3(0.04, 0.08, 0.15) * fade * fade;
        }
    }
    
    o.rgb = pow(o.rgb, vec3(0.7));
    o.rgb = mix(o.rgb, vec3(0.05, 0.07, 0.1), 1.0 - exp(-0.0015 * dot(q, q)));
    
    vec2 n = fragCoord.xy / iResolution.xy;
    o.rgb *= 0.5 + 0.5 * pow(16.0 * n.x * n.y * (1.0 - n.x) * (1.0 - n.y), 0.1);
    
    fragColor = vec4(o.rgb, 1.0);
}
