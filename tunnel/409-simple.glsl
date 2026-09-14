// ==== Image (image) ====
#define PI 3.14159265358979323846

vec3 hsv(float h, float s, float v) {
    vec3 rgb = clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return v * mix(vec3(1.0), rgb, s);
}

float fbm(vec3 p) {
    float e = 0.0;
    float s = 2.5;
    float a = 0.5;
    mat2 m = mat2(0.8, 0.6, -0.6, 0.8);
    for (int i = 0; i < 16; i++) {
        p.xy = m * p.xy;
        vec3 s1 = sin(p.zxx * s);
        vec3 c1 = vec3(1.0) - cos(p.yzy * s);
        e += a * dot(s1, c1) / s;
        s *= 1.85;
        a *= 0.65;
    }
    return e;
}

float stableHash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1136, 0.1378));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.4;
    
    float R = length(uv);
    float ang = atan(uv.y, uv.x);
    float logR = log(R + 1e-4);
    
    vec3 p1 = vec3(sin(ang) * 1.2, cos(ang) * 1.2, logR - t * 0.8);
    float n1 = fbm(p1 * 1.5);
    
    vec3 p2 = vec3(sin(ang + n1 * 0.5) * 1.5, cos(ang + n1 * 0.5) * 1.5, logR + t * 0.2);
    float n2 = fbm(p2 * 2.5);
    
    float d1 = abs(sin(ang * 3.0 + logR * 2.0 - t * 1.5 + n1 * 0.8));
    float spiral = smoothstep(0.15, 0.0, d1) * smoothstep(1.5, 0.1, R);
    
    float rDist = abs(mod(R * 12.0 - t * 2.0 + n2 * 0.4, 1.0) - 0.5);
    float rings = smoothstep(0.12, 0.0, rDist) * smoothstep(0.8, 0.2, R);
    
    vec2 gridUv = uv * 35.0;
    vec2 gridId = floor(gridUv);
    vec2 gridFc = fract(gridUv) - 0.5;
    float rand = stableHash(gridId);
    float starBlink = smoothstep(0.3, 1.0, sin(t * 5.0 + rand * PI * 2.0));
    float stars = smoothstep(0.08 * rand, 0.0, length(gridFc)) * starBlink * smoothstep(0.1, 0.4, R);
    
    float hue = 0.55 + 0.25 * sin(logR * 0.5 - t * 0.2 + n1 * 0.3);
    float sat = mix(0.9, 0.2, R);
    float val = spiral * 1.5 + rings * 0.8 + stars * 2.0;
    
    vec3 sceneColor = hsv(hue, sat, val);
    sceneColor += hsv(hue + 0.15, 0.8, spiral * 0.4) * 0.5;
    sceneColor += vec3(0.02, 0.01, 0.04) * (1.0 / (R + 0.05)) * (1.0 + n2 * 0.5);
    
    sceneColor *= smoothstep(1.4, 0.3, R);
    sceneColor = pow(sceneColor / (sceneColor + vec3(1.0)), vec3(1.0 / 2.2));
    
    fragColor = vec4(sceneColor, 1.0);
}
