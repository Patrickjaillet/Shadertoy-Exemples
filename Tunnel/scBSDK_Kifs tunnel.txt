// ==== Image (image) ====
#define ITERATIONS 20
#define SAMPLES 90.0

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    float s = 1.0;
    p.z = mod(p.z, 8.0) - 4.0; 
    p.xy *= rot(p.z * 0.2 + iTime * 0.3);
    
    for (int i = 0; i < 8; i++) {
        p = abs(p) - vec3(0.5, 1.2, 0.8);
        p.xy *= rot(0.4);
        p.yz *= rot(0.3);
        float scale = 1.8 / clamp(dot(p, p), 0.1, 1.0);
        p *= scale;
        s *= scale;
    }
    return length(p.xy) / s - 0.002;
}
// https://github.com/Patrickjaillet/Z-GL-Shadertoy
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    uv *= 1.0 + dot(uv, uv) * 0.15;

    vec3 ro = vec3(0, 0, iTime * 2.5);
    vec3 rd = normalize(vec3(uv, 1.2));
    rd.xy *= rot(iTime * 0.15);
    
    vec4 col = vec4(0);
    float t = 0.0;
    
    for (float i = 0.0; i < SAMPLES; i++) {
        vec3 p = ro + rd * t;
        
        for(float j = 0.01; j < 0.2; j += j) {
            p += abs(dot(sin(p * 0.8 + iTime), vec3(j))) * 0.1;
        }
        
        float d = map(p);
        
        vec3 c = mix(vec3(0.02, 0.1, 0.4), vec3(0.7, 0.05, 0.3), sin(t * 0.2) * 0.5 + 0.5);
        c = mix(c, vec3(0.9, 0.7, 0.2), smoothstep(0.0, 0.008, d));
        
        float glow = 1.0 / (0.08 + d * d * 1200.0);
        col.rgb += c * glow * (1.0 - i / SAMPLES) * 0.035;
        
        t += max(abs(d) * 0.4, 0.02);
        if (t > 20.0) break;
    }

    col.rgb = tanh(col.rgb * col.rgb * 0.25); 
    col.rgb = pow(col.rgb, vec3(1.15)); 

    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    col.rgb += (noise - 0.5) * 0.025;

    fragColor = vec4(col.rgb, 1.0);
}
