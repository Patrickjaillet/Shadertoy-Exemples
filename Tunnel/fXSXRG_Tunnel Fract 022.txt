// ==== Image (image) ====
void mainImage(out vec4 o, vec2 FC) {
    vec2 uv = (FC - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.3;
    
    vec3 ro = vec3(1.0, -1.8 - iTime * 1.5, 0.0);
    vec3 rd = normalize(vec3(uv, 0.1));
    rd.yz *= mat2(cos(1.2), -sin(1.2), sin(1.2), cos(1.2));
    
    float acc = 1.0;
    vec3 p;
    
    for(float i = 0.0; i < 80.0; i++) {
        p = ro + rd * (i * 0.3);
        p = mod(p, 4.0) - 2.0;
        
        float d = length(p.xy) - 1.0;
        d = abs(d) - 0.4;
        d = max(d, abs(p.z) - 0.3);
        
        float pulse = sin(t + i * 0.1) * 0.5 + 0.5;
        acc += 0.04 / (0.01 + d * d) * pulse;
        
        ro.z += 0.01;
    }
    
    vec3 col = vec3(1.0, 0.0, 0.0) * acc;
    col += vec3(1.0, 1.0, 0.4) * acc * 0.1;
    
    o = vec4(col * (0.6 - length(uv) * 0.4), 1.0);
}
