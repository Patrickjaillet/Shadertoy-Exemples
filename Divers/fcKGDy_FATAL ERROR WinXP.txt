// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 p) {
    vec2 q = p / iResolution.xy;
    float tMod = mod(iTime, 16.0);
    bool isFatalError = (tMod >= 8.0 && tMod < 12.0);
    
    if (isFatalError) {
        float flash = step(0.5, fract(iTime * 12.0));
        vec3 col = mix(vec3(0.0, 0.0, 0.8), vec3(0.9, 0.0, 0.0), flash);
        
        vec2 uv = p / iResolution.xy;
        vec2 gridPos = floor(uv * vec2(40.0, 25.0));
        float seed = fract(sin(dot(gridPos, vec2(12.9898, 78.233))) * 43758.5453);
        if (gridPos.y > 5.0 && gridPos.y < 20.0 && gridPos.x > 3.0 && gridPos.x < 37.0) {
            if (gridPos.y == 5.0 || gridPos.y == 8.0 || gridPos.y == 14.0 || gridPos.y == 18.0) {
                if (seed > 0.2) col = vec3(1.0);
            }
        }
        
        o = vec4(col, 1.0);
        return;
    }

    float beat = iTime * 4.4;
    float f = fract(beat);
    float bassBump = exp(-f * 6.0) * 0.2;
    q = (q - 0.5) * (1.0 - bassBump) + 0.5;
    
    float ang = sin(iTime * 1.1) * 0.2 * exp(-fract(beat * 0.5) * 3.0);
    mat2 rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    vec2 i = vec2(iResolution.x / iResolution.y, 1.0);
    vec2 r = (q - 0.5) * i;
    r = rot * r;
    r += 0.5 * i;
    vec3 j = vec3(mod(floor(beat * 2.0), 2.0) * 0.2, 0.32 + bassBump * 2.0, 0.63 - bassBump);
    float s = iTime * 2.2;
    float errEnvImg = exp(-fract(iTime * 1.1) * 12.0);
    for(int h = 0; h < 40; h++) {
        float t = float(h), e = max(0.0, s - t * 0.06);
        vec2 u = vec2(0.5 * i.x + 0.4 * sin(e * 1.3) + 0.2 * cos(e * 2.7), 0.5 + 0.3 * cos(e * 1.6) + 0.2 * sin(e * 3.1));
        u += vec2(sin(e * 15.0), cos(e * 15.0)) * 0.03 * exp(-fract(beat) * 3.0);
        vec2 v = vec2(0.52, 0.32);
        if(h == 0) {
            v += errEnvImg * 0.2;
            v *= (1.0 + bassBump * 2.0);
        }
        vec2 b = v * 0.5, a = r - u;
        if(abs(a.x) < b.x && abs(a.y) < b.y) {
            vec3 c = vec3(0.925, 0.914, 0.847);
            float k = 0.055, l = b.y, m = l - k;
            if(abs(a.x) > b.x - 0.003 || abs(a.y) > b.y - 0.003) c = vec3(0.0, 0.15, 0.6);
            else if(a.y > m) {
                float g = (a.y - m) / k;
                c = mix(vec3(0.0, 0.33, 0.88), vec3(0.0, 0.55, 1.0), g);
                if(mod(floor(beat * 4.0 - t * 0.5), 2.0) == 0.0) c = mix(c, vec3(1.0, 0.0, 0.0), 0.7);
                vec2 f = vec2(b.x - 0.038, l - 0.027);
                if(length(a - f) < 0.018) {
                    c = vec3(0.85, 0.2, 0.15);
                    vec2 d = abs(a - f);
                    if(abs(d.x - d.y) < 0.0025 && max(d.x, d.y) < 0.009) c = vec3(1.0);
                }
            } else {
                vec2 n = vec2(-b.x + 0.08, 0.01);
                if(length(a - n) < 0.038) {
                    c = vec3(0.82, 0.12, 0.12);
                    vec2 d = abs(a - n);
                    if(abs(d.x - d.y) < 0.004 && max(d.x, d.y) < 0.02) c = vec3(1.0);
                }
                if(a.x > -b.x + 0.15 && a.x < b.x - 0.06) if(abs(a.y - 0.03) < 0.004 || abs(a.y + 0.01) < 0.004) c = vec3(0.15);
                vec2 f = vec2(0.12, 0.045), w = vec2(0.0, -b.y + 0.055), zz = abs(a - w);
                if(zz.x < f.x * 0.5 && zz.y < f.y * 0.5) {
                    c = vec3(0.85, 0.85, 0.82);
                    if(zz.x > f.x * 0.5 - 0.0025 || zz.y > f.y * 0.5 - 0.0025) c = vec3(0.4);
                }
            }
            j = c;
        }
    }
    o = vec4(j, 1.0);
}

vec2 mainSound(int samp, float time) {
    float tMod = mod(time, 16.0);
    bool isFatalError = (tMod >= 8.0 && tMod < 12.0);
    
    if (isFatalError) {
        float localT = tMod - 8.0;
        float alarmPulse = step(0.5, fract(time * 12.0));
        
        float tone1 = sin(time * 650.0);
        float tone2 = sin(time * 950.0);
        float siren = (tone1 + tone2) * 0.5 * alarmPulse;
        
        float glitch = (fract(sin(time * 1234.5) * 43758.5453) - 0.5) * 0.3;
        
        float env = smoothstep(0.0, 0.1, localT) * smoothstep(4.0, 3.8, localT);
        float finalSound = (siren + glitch) * env * 0.7;
        
        return vec2(clamp(finalSound, -1.0, 1.0));
    }

    float b = time * 4.4;
    float f = fract(b);
    float h = fract(b * 2.0);
    float kick = sin(150.0 * exp(-f * 8.0) * f) * exp(-f * 3.0);
    float hat = fract(sin(time * 12345.67) * 4321.0) * exp(-h * 15.0) * 0.3;
    float note = 30.0 + mod(floor(b * 0.5), 4.0) * 5.0;
    float bass = sin(note * time * 5.0) * exp(-f * 4.0) * 0.5;
    float errEnv = exp(-fract(time * 1.1) * 12.0);
    float errDing = (sin(1046.5 * time) + sin(1318.5 * time) + sin(1567.9 * time)) * errEnv * 0.5;
    float synthEnv = exp(-fract(b * 0.25) * 2.0);
    float synth = sin(time * 440.0 * (1.0 + mod(floor(b), 3.0) * 0.1)) * synthEnv * 0.2;
    float left = 0.0;
    float right = 0.0;
    float p = mod(time, 80.0);
    if (p < 16.0) {
        float fade = p / 16.0;
        left = hat * fade;
        right = hat * fade;
    } else if (p < 32.0) {
        left = kick + bass + hat * 0.5;
        right = kick + bass + hat * 0.5;
    } else if (p < 48.0) {
        left = kick + bass * 1.2 + hat + synth;
        right = kick + bass * 1.2 + hat + synth * 1.2;
    } else if (p < 64.0) {
        float breakBass = sin(note * 0.5 * time * 5.0) * exp(-f * 8.0) * 0.5;
        left = kick * 0.5 + breakBass + hat * 0.5;
        right = kick * 0.5 + breakBass + hat * 0.5;
    } else {
        float fade = max(0.0, 1.0 - (p - 64.0) / 16.0);
        left = synth * fade;
        right = synth * fade;
    }
    left += errDing;
    right += errDing;
    return vec2(clamp(left, -1.0, 1.0), clamp(right, -1.0, 1.0));
}

// ==== Sound (sound) ====
vec2 mainSound(int samp, float time) {
    float tMod = mod(time, 16.0);
    bool isFatalError = (tMod >= 8.0 && tMod < 12.0);
    
    if (isFatalError) {
        float localT = tMod - 8.0;
        float alarmPulse = step(0.5, fract(time * 12.0));
        float tone1 = sin(time * 650.0);
        float tone2 = sin(time * 950.0);
        float siren = (tone1 + tone2) * 0.5 * alarmPulse;
        float glitch = (fract(sin(time * 1234.5) * 43758.5453) - 0.5) * 0.3;
        float env = smoothstep(0.0, 0.1, localT) * smoothstep(4.0, 3.8, localT);
        float finalSound = (siren + glitch) * env * 0.7;
        return vec2(clamp(finalSound, -1.0, 1.0));
    }

    float t = time * 3.5;
    float f = fract(t);
    float step8 = floor(t * 2.0);
    
    float errPitch = 800.0 + mod(floor(step8 * 3.0), 5.0) * 250.0;
    float errEnv = exp(-f * 8.0);
    float errorBeep = (sin(errPitch * time) + cos(errPitch * 1.25 * time)) * errEnv * 0.4;
    
    float critEnv = exp(-fract(t * 0.5) * 4.0);
    float critErr = sin(300.0 * time + sin(time * 20.0) * 5.0) * critEnv * 0.5;

    float kick = sin(120.0 * exp(-f * 10.0) * f) * exp(-f * 4.0);
    float click = (fract(sin(time * 999.0) * 43758.5453) - 0.5) * exp(-f * 30.0) * 0.8;

    float note = 220.0 * pow(2.0, floor(mod(step8, 6.0)) / 12.0);
    float leadEnv = exp(-f * 3.0);
    float lead = (sin(note * time * 2.0) + sign(sin(note * time))) * 0.25 * leadEnv;

    float stutter = (mod(time, 4.0) > 3.0) ? sin(time * 2000.0) * 0.3 * step(0.5, fract(time * 20.0)) : 0.0;

    float left = kick + click + errorBeep + lead + critErr + stutter;
    float right = kick + click + errorBeep * 0.8 + lead * 1.2 + critErr * 0.7 + stutter;

    return vec2(clamp(left, -1.0, 1.0), clamp(right, -1.0, 1.0));
}
