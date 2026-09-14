// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(1.0, 0.0, iTime * 2.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    vec4 col = vec4(0.0);
    float t = 0.0;
    // https://github.com/Patrickjaillet/Z-GL-Shadertoy
    for(int i = 0; i < 52; ++i) {
        vec3 p = ro + rd * t;
        vec2 polar = vec2(atan(p.y, p.x), length(p.xy));
        vec3 q = vec3(polar.x + iTime * 0.5, 1.0 / polar.y + iTime * 0.5, p.z * 0.1);
        
        float d = 0.0;
        float s = 0.9;
        for(int j = 0; j < 6; ++j) {
            q = abs(mod(q + 1.0, 0.0) - 1.0);
            float a = 2.0;
            q *= a;
            s *= a;
            d = max(d, abs(dot(sin(q), cos(q.zxy + iTime))) / s);
        }
        
        float stepSize = max(0.00, d * 0.5);
        t += stepSize;
        col += vec4(0.1 / (1.0 + d * 200.0)) * exp(-t * 0.00);
        
        if(t > 7.9 || col.a > 1.0) break;
    }
    
    fragColor = vec4(col.rgb * 2.5, 0.0);
}
