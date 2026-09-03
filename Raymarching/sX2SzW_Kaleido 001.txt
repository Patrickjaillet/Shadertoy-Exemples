// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec2 cDiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    return vec2(dot(a, b), a.y * b.x - a.x * b.y) / (d + 1e-6);
}

vec2 cMul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

float pNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = sin(dot(i + vec2(0.0, 0.0), vec2(127.1, 311.7))) * 43758.5453123;
    float b = sin(dot(i + vec2(1.0, 0.0), vec2(127.1, 311.7))) * 43758.5453123;
    float c = sin(dot(i + vec2(0.0, 1.0), vec2(127.1, 311.7))) * 43758.5453123;
    float d = sin(dot(i + vec2(1.0, 1.0), vec2(127.1, 311.7))) * 43758.5453123;
    return mix(mix(fract(a), fract(b), u.x), mix(fract(c), fract(d), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 r = rot(0.5);
    for (int i = 0; i < 4; ++i) {
        v += a * pNoise(p);
        p = r * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.3, 0.2, 0.2);
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 renderLayer(vec2 uv, float t) {
    vec2 z = uv;
    
    float amp = sin(t * 1.5) * 0.2 + 0.8;
    vec2 mNum = cMul(z, vec2(sin(t), cos(t))) + vec2(0.1, -0.2);
    vec2 mDen = z + vec2(cos(t * 0.5), sin(t * 0.5)) * 0.5;
    z = cDiv(mNum, mDen);
    
    float acc = 0.0;
    float minD = 1e9;
    
    for(int i = 0; i < 7; i++) {
        float fi = float(i);
        z = abs(z) / dot(z, z) - vec2(0.6 + sin(t * 0.2 + fi) * 0.1);
        z *= rot(t * 0.05 + fi * 0.3);
        z = sin(z * 2.0 + vec2(t, t * 1.3));
        
        float d = length(z);
        acc += exp(-d * 3.0);
        minD = min(minD, d);
    }
    
    float n = fbm(uv * 4.0 + vec2(t, -t * 0.5));
    acc += n * 0.4;
    
    vec3 col = palette(acc * 0.15 + t * 0.1);
    col += palette(minD * 2.5) * 0.3;
    
    col *= exp(-length(uv) * 0.4);
    return max(col, vec3(0.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 finalCol = vec3(0.0);
    float t = iTime * 0.4;
    
    for(int m = 0; m < 2; m++) {
        for(int n = 0; n < 2; n++) {
            vec2 offset = vec2(float(m), float(n)) / 2.0 - 0.25;
            vec2 uv = (fragCoord + offset - 0.5 * iResolution.xy) / iResolution.y;
            
            vec3 col = vec3(0.0);
            float shift = 0.004 * (1.0 + sin(t * 2.0));
            
            col.r = renderLayer(uv + vec2(shift, 0.0), t).r;
            col.g = renderLayer(uv, t).g;
            col.b = renderLayer(uv - vec2(shift, 0.0), t).b;
            
            finalCol += col;
        }
    }
    finalCol /= 4.0;
    
    finalCol = smoothstep(0.0, 1.0, finalCol);
    finalCol = pow(finalCol, vec3(0.4545));
    
    fragColor = vec4(finalCol, 1.0);
}
