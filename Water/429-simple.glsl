// ==== Image (image) ====
mat2 rotate2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

vec3 aces(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * r) / r.y;
    float t = iTime;
    vec3 col = vec3(0.0);
    
    float g = 0.05;
    
    for(float i = 0.0; i < 80.0; i++) {
        vec3 p = vec3(uv * 0.9, g - 0.8);
        p.xz *= rotate2D(t * 0.05);
        p.zy *= rotate2D(t * 0.05);
        
        float s = 0.5;
        float e = 0.5;
        
        for(int j = 0; j < 14; j++) {
            p = abs(p) - vec3(1.2, 2.5, 1.2);
            p = vec3(3.0, 5.0, 0.1) - abs(abs(p) - vec3(4.0));
            
            float d2 = dot(p, p);
            e = clamp(10.0 / max(d2, 0.001), 1.0, 15.0);
            
            p *= e;
            s *= e;
        }
        
        float dist = length(p.xz) / s;
        g += max(dist, 0.02);
        float intensity = pow(log2(s) / g, 2.0) * 0.00002;
        float hue = 0.1 + g * 1.;
        
        vec3 spectral = hsv(hue, 0.8, intensity);
        col += spectral * exp(-g * 0.4);
    }

    col *= 7.0;
    col = aces(col);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
