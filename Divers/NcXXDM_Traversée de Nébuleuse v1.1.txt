// ==== Image (image) ====
const float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

#define BLOOM_BASE_INTENSITY 3.0
#define BLOOM_PULSE_AMOUNT 1.0
#define BLOOM_PULSE_SPEED 2.5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texelSize = 1.0 / iResolution.xy;

    vec3 blurredCol = texture(iChannel1, uv).rgb * weights[0];
    
    for(int i = 1; i < 5; i++) {
        float offset = float(i);
        blurredCol += texture(iChannel1, uv + vec2(0.0, texelSize.y * offset)).rgb * weights[i];
        blurredCol += texture(iChannel1, uv - vec2(0.0, texelSize.y * offset)).rgb * weights[i];
    }

    vec3 originalCol = texture(iChannel0, uv).rgb;

    float pulse = BLOOM_BASE_INTENSITY + BLOOM_PULSE_AMOUNT * sin(iTime * BLOOM_PULSE_SPEED);

    vec3 finalCol = originalCol + blurredCol * pulse;

    finalCol = clamp(finalCol, 0.0, 1.0);
    finalCol = pow(finalCol, vec3(0.4545));
    
    fragColor = vec4(finalCol, 1.0);
}

// ==== Buffer A (buffer) ====
#define STEPS 64 
#define FAR 8.0

float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = dot(i, vec3(1.0, 57.0, 113.0));
    return mix(mix(mix(fract(sin(n + 0.0) * 43758.5453), fract(sin(n + 1.0) * 43758.5453), f.x),
                   mix(fract(sin(n + 57.0) * 43758.5453), fract(sin(n + 58.0) * 43758.5453), f.x), f.y),
               mix(mix(fract(sin(n + 113.0) * 43758.5453), fract(sin(n + 114.0) * 43758.5453), f.x),
                   mix(fract(sin(n + 170.0) * 43758.5453), fract(sin(n + 171.0) * 43758.5453), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    float weight = 0.5;
    for (int i = 0; i < 3; i++) {
        f += weight * noise(p);
        p *= 2.02;
        weight *= 0.5;
    }
    return f;
}

vec3 pal(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

float density(vec3 p) {
    p.z += iTime * 0.4;
    p.x += sin(iTime * 0.2 + p.z * 0.5) * 0.5;
    vec3 q = vec3(fbm(p), fbm(p + 1.2), fbm(p + 2.4));
    float d = fbm(p + 1.2 * q);
    d = smoothstep(0.4, 0.9, d); 
    d *= max(0.0, 1.0 - length(p.xy) * 0.25);
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -iTime * 0.1);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    vec3 col = vec3(0.0);
    float T = 1.0; 
    float t = 0.0;
    float stepDist = FAR / float(STEPS);
    
    float jitter = hash(vec3(uv, iTime)) * stepDist;
    t += jitter;

    for (int i = 0; i < STEPS; i++) {
        if (T < 0.01) break;
        
        vec3 p = ro + t * rd;
        float den = density(p);

        if (den > 0.01) {
            vec3 sampleCol = pal(den + p.z * 0.1 - iTime * 0.05, 
                                 vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
            
            sampleCol *= den * 1.5;
            sampleCol += vec3(1.0, 0.6, 0.2) * exp(-length(p.xy) * 1.2) * 0.05;
            
            float alpha = den * 0.15; 
            col += T * sampleCol * alpha;
            T *= (1.0 - alpha);
        }
        t += stepDist;
    }
    
    vec3 bgCol = vec3(0.005, 0.005, 0.01) + pal(uv.y * 0.5, vec3(0.05), vec3(0.05), vec3(1.0), vec3(0.5, 0.1, 0.9));
    col += T * bgCol;
    
    col = clamp(col, 0.0, 1.0);
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer B (buffer) ====
const float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texelSize = 1.0 / iResolution.xy;
    
    vec3 col = texture(iChannel0, uv).rgb * weights[0];
    
    for(int i = 1; i < 5; i++) {
        float offset = float(i);
        col += texture(iChannel0, uv + vec2(texelSize.x * offset, 0.0)).rgb * weights[i];
        col += texture(iChannel0, uv - vec2(texelSize.x * offset, 0.0)).rgb * weights[i];
    }
    
    fragColor = vec4(col, 1.0);
}
