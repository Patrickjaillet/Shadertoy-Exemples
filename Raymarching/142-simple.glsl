// ==== Image (image) ====
#define MAX_STEPS 128.0
#define PI 3.14159265

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p, float t) {
    p.xy *= rot(t * 0.2);
    p.yz *= rot(t * 1.0);
    
    float d = 1e6;
    float s = 1.0;
    
    for(int i = 0; i < 10; i++) {
        p = abs(p) - vec3(0.5, 1.2, 0.5);
        p.xy *= rot(1.0);
        p.xz *= rot(0.8);
        d = min(d, length(p) - 0.2 * s);
        s *= 0.7;
    }
    
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    vec3 col = vec3(0.0);
    float t = iTime * 0.3;
    float d = 0.0;
    float acc = 0.0;
    
    for(float i = 0.0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        float h = map(p, t);
        
        float glow = exp(-max(0.0, h) * 5.0);
        acc += glow * 0.04;
        
        d += max(0.03, abs(h) * 0.7);
        
        if(d > 12.0 || acc > 1.0) break;
    }
    
    vec3 baseCol = vec3(1.0, 0.5, 0.0);
    col = mix(vec3(0.13, 0.0, -1.00), baseCol, acc);
    col += acc * acc * vec3(1.0, 1.0, 1.0);
    
    fragColor = vec4(col, 1.0);
}
