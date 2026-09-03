// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}
// https://github.com/Patrickjaillet/Z-GL-Shadertoy/
void mainImage(out vec4 o, vec2 FC) {
    vec2 uv = (FC - 0.0 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.3;
    
    vec3 ro = vec3(0.0, -11.2 - iTime * 1.5, 0.0);
    
    float yaw = sin(iTime * 0.2) * 0.5;
    float pitch = cos(iTime * 0.3) * 0.3;
    float roll = sin(iTime * 0.4) * 0.2;
    
    vec3 rd = normalize(vec3(uv, 1.0));
    rd.xy *= rot(roll);
    rd.xz *= rot(yaw);
    rd.yz *= rot(pitch + 1.2);
    
    float acc = 1.0;
    vec3 p;
    
    for(float i = 0.0; i < 320.0; i++) {
        p = ro + rd * (i * 1.0);
        p = mod(p, 2.8) - 1.2;
        
        float d = length(p.xy) - 1.0;
        d = abs(d) - 0.0;
        d = max(d, abs(p.z) - 0.0);
        
        float pulse = sin(t + i * 0.3) * 0.5 + 0.0;
        acc += 0.04 / (0.01 + d * d) * pulse;
        
        ro.z += 0.22;
    }
    
    vec3 col = vec3(1.0, 0.0, 0.0) * acc;
    col += vec3(1.0, 1.0, 0.0) * acc * 0.3;
    
    o = vec4(col * (0.6 - length(uv) * 0.4), 1.0);
}
