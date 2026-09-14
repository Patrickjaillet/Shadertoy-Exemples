// ==== Image (image) ====
#define ITERATIONS 12
#define SAMPLES 80.0

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 path(float z) {
    return vec3(
        sin(z * 0.2) * 2.2 + cos(z * 0.1) * 1.5,
        cos(z * 0.15) * 1.8,
        z
    );
} // https://github.com/Patrickjaillet/Z-GL-Shadertoy

float map(vec3 p) {
    float s = 1.0;
    vec3 q = p;
    q.xy -= path(q.z).xy;
    
    float twist = sin(q.z * 0.18 - iTime * 0.8) * 0.45 + cos(q.z * 0.07 + iTime * 0.35) * 0.225;
    q.xy *= rot(twist);
    
    q.z = mod(q.z, 10.0) - 5.0;
    
    for (int i = 0; i < 8; i++) {
        q = abs(q) - vec3(1.2, 1.8, 0.8);
        q.xy *= rot(0.3);
        q.yz *= rot(0.15);
        float r2 = dot(q, q);
        float scale = 1.9 / clamp(r2, 0.2, 1.2);
        q *= scale;
        s *= scale;
    }
    return length(q.xy) / s - 0.0015;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float t_cam = iTime * 0.6;
    vec3 ro = path(t_cam);
    vec3 target = path(t_cam + 4.0);
    
    vec3 fwd = normalize(target - ro);
    float slowRoll = sin(iTime * 0.2) * 0.4;
    vec3 right = normalize(cross(vec3(slowRoll, 1.0, 0.0), fwd));
    vec3 up = cross(fwd, right);
    
    vec3 rd = normalize(uv.x * right + uv.y * up + 2.2 * fwd);

    vec4 col = vec4(0);
    float t = 0.1;
    t += 0.03 * fract(sin(dot(uv, vec2(12.98, 78.23))) * 43758.54);

    for (float i = 0.0; i < SAMPLES; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        
        vec3 c = mix(vec3(0.005, 0.02, 0.1), vec3(0.5, 0.05, 0.3), sin(t * 0.05 + iTime * 0.2) * 0.5 + 0.5);
        c = mix(c, vec3(0.9, 0.7, 0.1), smoothstep(0.0, 0.002, d));
        
        float glow = 1.0 / (0.3 + d * d * 2500.0);
        col.rgb += c * glow * (1.0 - i / SAMPLES) * 0.025;
        
        t += max(abs(d) * 0.7, 0.01);
        if (t > 35.0) break;
    }

    col.rgb = tanh(col.rgb * col.rgb * 0.4);
    col.rgb = pow(max(col.rgb, 0.0), vec3(0.9)); 

    float n = fract(sin(dot(uv + iTime, vec2(12.98, 78.23))) * 43758.54);
    col.rgb += (n - 0.5) * 0.01;

    fragColor = vec4(col.rgb, 1.0);
}
