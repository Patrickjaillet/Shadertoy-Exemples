// ==== Image (image) ====
#define OCTAVES 8
#define SHAKE_STR 0.015
#define MAX_SAMPLES 32.0 
#define WAVE_AMPLITUDE 0.04
#define WAVE_FREQUENCY 5.5
#define GOLDEN_RATIO 1.61803398875

float hash21(vec2 p) {
    uint x = floatBitsToUint(p.x);
    uint y = floatBitsToUint(p.y);
    x = x * 1103515245u + 12345u;
    y = y * 1103515245u + 12345u;
    uint h = x ^ (y >> 3u);
    return float(h * (1103515245u)) * (1.0 / 4294967296.0);
}

float voronoi(vec2 x) {
    vec2 n = floor(x);
    vec2 f = fract(x);
    float m = 8.0;
    for(int j=-1; j<=1; j++)
    for(int i=-1; i<=1; i++) {
        vec2 g = vec2(float(i),float(j));
        vec2 o = vec2(hash21(n + g), hash21(n + g + 13.5));
        vec2 r = g + o - f;
        float d = dot(r,r);
        m = min(m, d);
    }
    return sqrt(m);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    float freq = 1.0;
    mat2 r = mat2(1.6, 1.2, -1.2, 1.6);
    for (int i = 0; i < OCTAVES; i++) {
        v += a * voronoi(p * freq);
        p = r * p;
        a *= 0.5;
    }
    return v;
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

vec3 spectrum(float t) {
    vec3 c = 0.5 + 0.5 * cos(6.28318 * (vec3(1.0, 0.8, 0.5) * t + vec3(0.0, 0.15, 0.3)));
    return c * c * 1.5;
}

vec3 renderScene(vec2 uv, float time) {
    float dist = length(uv);
    float wave = sin(dist * WAVE_FREQUENCY - time * 3.2) * WAVE_AMPLITUDE;
    uv += (uv / (dist + 0.001)) * wave;

    vec2 p = uv;
    float p_len = length(p);
    
    float warp = fbm(uv * 0.8 + time * 0.08);
    float angle = atan(p.y, p.x);
    p *= rot(warp * 1.5 + angle * 0.2);

    vec3 color = vec3(0.0);
    
    for (float i = 0.0; i < 6.0; i++) {
        float z = fract(0.12 * time + i * 0.166);
        float scale = mix(10.0, 0.1, z);
        float fade = smoothstep(0.0, 0.2, z) * smoothstep(1.0, 0.8, z);
        
        float logR = log(length(uv) + 0.01) + time * 0.3;
        vec2 st = vec2(angle * 1.909, logR);
        st *= rot(i * GOLDEN_RATIO);
        
        vec2 gv = fract(st * 4.0) - 0.5;
        vec2 id = floor(st * 4.0);
        
        float n = hash21(id + i);
        gv *= rot(time * (n - 0.5) * 2.0);
        
        float d = sdHexagon(gv, 0.2 + 0.1 * sin(time * n));
        float thickness = 0.01 + 0.05 * z;
        
        vec3 col = spectrum(z + i * 0.3 + p_len * 0.5);
        
        float mask = smoothstep(thickness, 0.0, abs(d));
        float glow = exp(-20.0 * abs(d));
        
        color += col * mask * fade * 2.0;
        color += col * glow * fade * 0.8;
    }
    
    color += spectrum(p_len * 0.2) * (0.05 / (p_len + 0.01));
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 q = fragCoord / iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime;
    
    float dCentre = length(q - 0.5);
    float blurMap = pow(dCentre * 1.4, 2.5);
    float currentSamples = mix(1.0, MAX_SAMPLES, blurMap);
    float blurRadius = blurMap * 0.05;

    vec3 acc = vec3(0.0);
    float wAcc = 0.0;
    
    float ang = hash21(fragCoord + time) * 6.28318;
    
    for(float s = 0.0; s < MAX_SAMPLES; s++) {
        if (s >= ceil(currentSamples)) break;
        
        float r = sqrt((s + 0.5) / MAX_SAMPLES);
        float theta = s * GOLDEN_RATIO * 6.28318 + ang;
        vec2 jitter = vec2(cos(theta), sin(theta)) * r * blurRadius;
        
        float shakeT = time * 8.0;
        vec2 shake = vec2(
            fbm(vec2(shakeT, s * 0.11)),
            fbm(vec2(s * 0.13, shakeT + 10.0))
        ) * SHAKE_STR;
        
        vec3 samp = renderScene(uv + jitter + shake, time);
        
        float w = 1.0 - (s / currentSamples) * 0.5;
        acc += samp * w;
        wAcc += w;
    }
    
    vec3 color = acc / max(wAcc, 0.001);
    
    float vig = smoothstep(1.5, 0.3, length(uv));
    color *= pow(vig, 0.8);
    
    color = mix(color, 1.0 - exp(-color * 1.5), 0.5);
    color = pow(color, vec3(1.0 / 2.2));
    
    float noise = hash21(fragCoord + time) * 0.015;
    color += noise;
    
    fragColor = vec4(color, 1.0);
}
