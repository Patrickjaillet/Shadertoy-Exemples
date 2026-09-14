// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 R = iResolution.xy;
    vec2 u = (fragCoord * 2. - R) / R.y;
    vec2 p = u;
    vec3 c = vec3(0.);
    
    float t = iTime * 0.3;
    float s = sin(t * 0.2);
    float o = cos(t * 0.2);
    u *= mat2(o, -s, s, o);
    
    float morph = sin(iTime * 0.4) * 0.5 + 0.5;
    
    vec2 cM = vec2(-0.743643887, 0.131825904);
    vec2 cJ = vec2(-0.4, 0.6) + vec2(sin(t), cos(t * 0.7)) * 0.05;
    
    for(float i = 0.; i < 9.; i++) {
        vec2 uM = abs(u) / dot(u, u) + cM;
        
        vec2 uJ = u;
        uJ = vec2(uJ.x * uJ.x - uJ.y * uJ.y, 2.0 * uJ.x * uJ.y) + cJ;
        uJ = abs(uJ) / (dot(uJ, uJ) + 0.05) - vec2(0.9, 1.2);
        
        u = mix(uM, uJ, morph);
        
        u *= mat2(0.866, 0.5, -0.5, 0.866);
        
        float l = length(u);
        float d = length(p - u * 0.4);
        
        vec3 col = vec3(0.5 + 0.5 * sin(i * 1.2 + t), 0.3 + 0.4 * cos(i * 1.8 + t), 0.7 + 0.3 * sin(i * 2.2 + t));
        c += col * (abs(sin(l - t * 2.5)) + 0.15) / (d * d + 0.04) * 0.06;
    }
    
    c = pow(c * vec3(0.55, 0.5, 0.65) * (3.0 - dot(p, p) * 0.2), vec3(1.0));
    fragColor = vec4(c, 1.0);
}
