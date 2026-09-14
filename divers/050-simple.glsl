// ==== Image (image) ====
#define PHOSPHOR_DECAY 0.28
#define CHROMATIC_ABERRATION 0.0065
#define CURVATURE 4.5
#define BLOOM_SAMPLES 12
#define SCANLINE_DENSITY 2.8
#define GLITCH_INTENSITY 0.004
#define JITTER_FREQ 32.0
#define VIGNETTE_STRENGTH 0.45
#define PINCUSHION_DIST 0.12
#define RF_INTERFERENCE 0.022
#define COLOR_BLEED 1.4

float gold_noise(vec2 p, float seed) {
    return fract(tan(distance(p * 1.61803398875, p) * seed) * p.x);
}

vec2 curve(vec2 uv) {
    vec2 cc = uv - 0.5;
    float r2 = dot(cc, cc);
    float r4 = r2 * r2;
    cc *= 1.0 + PINCUSHION_DIST * r2 + (PINCUSHION_DIST * 0.5) * r4;
    return cc + 0.5;
}

float sdRect(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float glyph(vec2 p, float id, float time) {
    p = (p - 0.5) * 1.45;
    float seed = floor(time * 18.0) + id;
    float h = gold_noise(vec2(seed, id), 1.234);
    float shape = 0.0;
    
    if(h > 0.9) {
        shape = smoothstep(0.12, 0.02, abs(sdRect(p, vec2(0.25, 0.35))));
    } else if(h > 0.78) {
        shape = smoothstep(0.12, 0.02, abs(length(p) - 0.28));
    } else if(h > 0.62) {
        shape = smoothstep(0.08, 0.01, abs(p.x * 1.5 + p.y) - 0.06) * step(abs(p.x), 0.3);
    } else if(h > 0.48) {
        shape = step(0.12, abs(p.x)) * step(abs(p.x), 0.22) * step(abs(p.y), 0.35);
        shape += step(0.12, abs(p.y)) * step(abs(p.y), 0.22) * step(abs(p.x), 0.35);
    } else {
        shape = step(0.85, gold_noise(p * 3.1 + seed, 0.9)) * smoothstep(0.45, 0.0, length(p));
    }
    
    float flicker = step(0.015, gold_noise(vec2(time * 0.92, id), 2.1));
    return shape * flicker;
}

vec3 getSignal(vec2 uv, float time) {
    float hSync = sin(time * 2.0 + uv.y * 1.5) * 0.001;
    float hSyncNoise = (gold_noise(vec2(time * 15.0, floor(uv.y * 10.0)), 3.14) - 0.5) * GLITCH_INTENSITY;
    uv.x += hSync + hSyncNoise * step(0.98, gold_noise(vec2(time, 1.0), 4.2));

    float rf = (sin(uv.y * 320.0 + time * 52.0) * 0.5 + 0.5) * RF_INTERFERENCE;
    uv.x += rf * step(0.85, gold_noise(vec2(time * 0.1), 5.5));

    vec2 grid = uv * vec2(80.0, 36.0);
    vec2 ipos = floor(grid);
    vec2 fpos = fract(grid);
    
    float rowTime = floor(time * (10.0 + gold_noise(vec2(ipos.y), 6.6) * 12.0));
    float rowHash = gold_noise(vec2(ipos.y, rowTime), 7.7);
    float textActivity = step(0.25, gold_noise(vec2(ipos.y, floor(time * 5.0)), 8.8));
    float charMask = step(gold_noise(ipos + floor(time * 0.05), 9.9), rowHash);
    
    float g = glyph(fpos, gold_noise(ipos, 10.1), time);
    float margin = smoothstep(0.0, 0.02, uv.x) * smoothstep(1.0, 0.98, uv.x) * smoothstep(0.0, 0.05, uv.y) * smoothstep(1.0, 0.95, uv.y);
    
    float val = g * charMask * textActivity * margin;
    
    vec3 amberPhosphor = vec3(1.0, 0.72, 0.2); 
    vec3 greenPhosphor = vec3(0.2, 1.0, 0.5);
    vec3 color = mix(greenPhosphor, amberPhosphor, 0.15) * val;
    
    color += vec3(0.01, 0.04, 0.035) * margin * (0.9 + 0.1 * sin(time * 0.8 + uv.y * 6.0));
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float time = iTime;

    vec2 dUV = curve(uv);
    if(dUV.x < 0.0 || dUV.x > 1.0 || dUV.y < 0.0 || dUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 color;
    color.r = getSignal(dUV + vec2(CHROMATIC_ABERRATION, 0.0), time).r;
    color.g = getSignal(dUV, time).g;
    color.b = getSignal(dUV - vec2(CHROMATIC_ABERRATION, 0.0), time).b;

    float scanline = sin(dUV.y * iResolution.y * SCANLINE_DENSITY + time * 2.0) * 0.15 + 0.85;
    
    vec3 mask = vec3(0.8);
    float x_mod = mod(fragCoord.x, 3.0);
    if(x_mod < 1.0) mask.r = 1.1;
    else if(x_mod < 2.0) mask.g = 1.1;
    else mask.b = 1.1;
    
    color *= scanline;
    color *= mask;

    vec3 bloom = vec3(0.0);
    float totalWeight = 0.0;
    for(int i = -BLOOM_SAMPLES; i <= BLOOM_SAMPLES; i++) {
        float weight = exp(-0.35 * pow(float(i) / (float(BLOOM_SAMPLES) * 0.5), 2.0));
        vec2 offset = vec2(float(i) * (2.2 / iResolution.x), 0.0);
        bloom += getSignal(dUV + offset, time) * weight;
        totalWeight += weight;
    }
    color += (bloom / totalWeight) * COLOR_BLEED;

    float vig = pow(16.0 * dUV.x * dUV.y * (1.0 - dUV.x) * (1.0 - dUV.y), VIGNETTE_STRENGTH);
    color *= vig;

    float reflectScale = 0.95;
    vec2 reflectUV = (dUV - 0.5) * reflectScale + 0.5;
    vec3 reflection = getSignal(reflectUV, time) * 0.08;
    color += reflection * vec3(0.5, 0.8, 1.0) * (1.0 - vig);

    float grain = gold_noise(dUV + fract(time), 13.37);
    color += (grain - 0.5) * 0.04;

    color = pow(max(color, 0.0), vec3(1.15));
    color = mix(color, vec3(dot(color, vec3(0.299, 0.587, 0.114))), -0.1);

    fragColor = vec4(color, 1.0);
}
