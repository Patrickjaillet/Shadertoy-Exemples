// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash(float n) { 
    return fract(sin(n) * 43758.5453123); 
}

vec3 hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453123, 22578.1459123, 19642.3490423));
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 57.0 + 113.0 * i.z;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    vec3 shift = vec3(100.0);
    for (int i = 0; i < 4; ++i) {
        v += a * noise(p);
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

void getPressAnimation(float t, out float height, out float squash, out float sparkIntensity) {
    float cycle = fract(t * 0.6);
    if (cycle < 0.1) {
        float idx = cycle / 0.1;
        height = mix(2.8, 0.4, idx * idx);
        squash = 1.0;
        sparkIntensity = 0.0;
    } else if (cycle < 0.25) {
        float idx = (cycle - 0.1) / 0.15;
        height = 0.4;
        squash = 1.0 - 0.4 * sin(idx * 3.14159265);
        sparkIntensity = exp(-idx * 6.0);
    } else {
        float idx = (cycle - 0.25) / 0.75;
        height = mix(0.4, 2.8, smoothstep(0.0, 1.0, idx));
        squash = 1.0;
        sparkIntensity = 0.0;
    }
}

vec3 getCameraShake(float t) {
    float cycle = fract(t * 0.6);
    float strikeTime = cycle - 0.1;
    if (strikeTime < 0.0 || strikeTime > 0.4) return vec3(0.0);
    float amp = exp(-14.0 * strikeTime) * 0.28;
    float freq = 160.0;
    return vec3(
        sin(strikeTime * freq),
        cos(strikeTime * freq * 1.2),
        sin(strikeTime * freq * 0.9)
    ) * amp;
}

vec2 map(vec3 p, float height, float squash) {
    float d = 1e5;
    float mat = 0.0;
    
    float floorD = p.y + 2.0;
    if (floorD < d) { d = floorD; mat = 1.0; }
    
    vec3 pBase = p - vec3(0.0, -1.0, 0.0);
    float baseD = sdBox(pBase, vec3(2.5, 1.0, 2.5));
    baseD = max(baseD, -sdCylinder(pBase - vec3(0.0, 0.6, 0.0), 0.5, 2.2));
    float anvil = sdCylinder(pBase - vec3(0.0, 1.0, 0.0), 0.2, 1.2);
    baseD = min(baseD, anvil);
    if (baseD < d) { d = baseD; mat = 2.0; }
    
    vec3 pPillars = p;
    pPillars.xz = abs(pPillars.xz) - vec2(2.0, 2.0);
    float pillarsD = sdCylinder(pPillars, 4.0, 0.3);
    float frameTop = sdBox(p - vec3(0.0, 4.0, 0.0), vec3(2.6, 0.4, 2.6));
    float frameD = min(pillarsD, frameTop);
    if (frameD < d) { d = frameD; mat = 2.0; }
    
    vec3 pHead = p - vec3(0.0, height + 1.2, 0.0);
    float headD = sdBox(pHead, vec3(1.1, 1.0, 1.1));
    float shaftD = sdCylinder(p - vec3(0.0, height + 3.0, 0.0), 2.0, 0.4);
    float totalPress = min(headD, shaftD);
    if (totalPress < d) { d = totalPress; mat = 3.0; }
    
    vec3 pBillet = p - vec3(0.0, 0.2 * squash, 0.0);
    float billetD = sdBox(pBillet, vec3(0.6 / sqrt(squash), 0.2 * squash, 0.6 / sqrt(squash))) - 0.05;
    if (billetD < d) { d = billetD; mat = 4.0; }
    
    return vec2(d, mat);
}

vec3 getNormal(vec3 p, float h, float s) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, h, s).x - map(p - e.xyy, h, s).x,
        map(p + e.yxy, h, s).x - map(p - e.yxy, h, s).x,
        map(p + e.yyx, h, s).x - map(p - e.yyx, h, s).x
    ));
}

float getAO(vec3 p, vec3 n, float h, float s) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        vec3 aopos = n * hr + p;
        float dd = map(aopos, h, s).x;
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float getShadow(vec3 ro, vec3 rd, float h, float s) {
    float res = 1.0;
    float t = 0.1;
    for (int i = 0; i < 32; i++) {
        float h_d = map(ro + rd * t, h, s).x;
        res = min(res, 10.0 * h_d / t);
        t += clamp(h_d, 0.02, 0.2);
        if (res < 0.005 || t > 15.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 BRDF(vec3 p, vec3 n, vec3 rd, vec3 lPos, vec3 lCol, float roughness, vec3 albedo, float metal) {
    vec3 l = normalize(lPos - p);
    vec3 v = -rd;
    vec3 h = normalize(l + v);
    
    float dotNL = clamp(dot(n, l), 0.0, 1.0);
    float dotNV = clamp(dot(n, v), 0.0, 1.0);
    float dotNH = clamp(dot(n, h), 0.0, 1.0);
    float dotLH = clamp(dot(l, h), 0.0, 1.0);
    
    vec3 f0 = mix(vec3(0.04), albedo, metal);
    vec3 f = f0 + (1.0 - f0) * pow(clamp(1.0 - dotLH, 0.0, 1.0), 5.0);
    
    float alpha = roughness * roughness;
    float alphaSq = alpha * alpha;
    float denom = dotNH * dotNH * (alphaSq - 1.0) + 1.0;
    float d = alphaSq / (3.14159265 * denom * denom);
    
    float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
    float g1l = dotNL / (dotNL * (1.0 - k) + k);
    float g1v = dotNV / (dotNV * (1.0 - k) + k);
    float g = g1l * g1v;
    
    vec3 spec = (f * d * g) / max(4.0 * dotNL * dotNV, 0.001);
    vec3 diff = (vec3(1.0) - f) * (1.0 - metal) * albedo / 3.14159265;
    
    return (diff + spec) * lCol * dotNL;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float h, s, sparkI;
    getPressAnimation(iTime, h, s, sparkI);
    vec3 shake = getCameraShake(iTime);
    
    vec3 ro = vec3(4.5 * sin(iTime * 0.15), 2.2, 4.5 * cos(iTime * 0.15)) + shake;
    vec3 ta = vec3(0.0, 0.6, 0.0) + shake * 0.2;
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.4 * cw);
    
    float t = 0.0;
    float maxT = 20.0;
    vec2 res = vec2(-1.0);
    
    for (int i = 0; i < 128; i++) {
        vec3 p = ro + rd * t;
        res = map(p, h, s);
        if (res.x < 0.001 || t > maxT) break;
        t += res.x * 0.65;
    }
    
    vec3 col = vec3(0.01, 0.012, 0.015) * (1.0 - 0.7 * length(uv));
    vec3 glowAcc = vec3(0.0);
    
    if (t < maxT) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p, h, s);
        float ao = getAO(p, n, h, s);
        
        vec3 albedo = vec3(0.2);
        float roughness = 0.4;
        float metal = 0.5;
        
        float nF = fbm(p * 4.0);
        
        if (res.y == 1.0) {
            albedo = vec3(0.12, 0.12, 0.14) + nF * 0.05;
            roughness = 0.6;
            metal = 0.1;
        } else if (res.y == 2.0) {
            albedo = vec3(0.22, 0.24, 0.25) * (0.6 + 0.4 * nF);
            roughness = 0.45;
            metal = 0.7;
        } else if (res.y == 3.0) {
            albedo = vec3(0.28, 0.3, 0.31) * (0.7 + 0.3 * nF);
            roughness = 0.35;
            metal = 0.8;
        } else if (res.y == 4.0) {
        // modification pour les etincelles et l'aspect du metal plus jaune
/* Modif 1 */
            float heat = smoothstep(0.0, 1.0, 1.0 - s * 0.5);
            albedo = mix(vec3(0.2, 0.15, 0.05), vec3(1.0, 0.72, 0.1), heat);
            roughness = 0.2;
            metal = 0.4;
        }
        
        vec3 lPos1 = vec3(4.0, 7.0, 3.0);
        vec3 lCol1 = vec3(1.2, 1.1, 0.9) * 2.5;
        vec3 lPos2 = vec3(-3.0, 4.0, -4.0);
        vec3 lCol2 = vec3(0.4, 0.5, 0.7) * 1.2;
        vec3 lPos3 = vec3(0.0, 0.2, 0.0);
/* Modif 2 */
        vec3 lCol3 = vec3(3.0, 1.8, 0.2) * (4.0 + 12.0 * sparkI);
        
        vec3 lin = vec3(0.0);
        
        float sha1 = getShadow(p, normalize(lPos1 - p), h, s);
        lin += BRDF(p, n, rd, lPos1, lCol1, roughness, albedo, metal) * sha1;
        
        float sha2 = getShadow(p, normalize(lPos2 - p), h, s);
        lin += BRDF(p, n, rd, lPos2, lCol2, roughness, albedo, metal) * sha2;
        
        lin += BRDF(p, n, rd, lPos3, lCol3, roughness, albedo, metal) * ao;
        
        vec3 amb = vec3(0.03, 0.04, 0.05) * albedo * ao;
        col = lin + amb;
        
        if (res.y == 4.0) {
/* Modif 3 */
        float heat = smoothstep(0.0, 1.0, 1.0 - s * 0.5);
            col += mix(vec3(2.0, 0.4, 0.0), vec3(6.0, 4.5, 0.8), heat) * 2.5;
        }
        
        col *= ao;
        col = mix(col, vec3(0.02, 0.02, 0.025), 1.0 - exp(-0.015 * t * t));
    }
    
    if (sparkI > 0.001) {
        float cX = fract(iTime * 0.6) - 0.1;
        if (cX > 0.0) {
/* Modif 4 */
        for (int i = 0; i < 56; i++) {
                vec3 h3 = hash3(float(i) * 143.51 + 71.13);
                float angle = h3.x * 6.28318530718;
                float radiusExplosion = 0.6 / sqrt(s);
                vec3 startPos = vec3(cos(angle), 0.0, sin(angle)) * radiusExplosion * h3.y;
                startPos.y = 0.1 + h3.z * 0.2;
                
                float speed = 5.0 + h3.y * 9.0;
                vec3 vSp = vec3(cos(angle) * 1.5, h3.z * 1.2 + 0.4, sin(angle) * 1.5) * speed;
                
/* Modif 5 */
               vec3 pA = startPos + vSp * cX + 0.5 * vec3(0.0, -9.81, 0.0) * cX * cX;
                vec3 currentVel = vSp + vec3(0.0, -9.81, 0.0) * cX;
                vec3 pB = pA - currentVel * 0.018;
                
                float dS = length(ro - pA);
                if (dS < t) {
                    vec3 q = ro + rd * dS;
                    vec3 ab = pB - pA;
                    vec3 aq = q - pA;
                    float hLink = clamp(dot(aq, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
                    float dL = length(aq - ab * hLink);
                    
/* Modif 6 */
                      vec3 sCol = mix(vec3(4.0, 0.6, 0.01), vec3(10.0, 8.5, 2.5), exp(-cX * 6.5));
                    glowAcc += sCol * (0.0045 / (dL + 0.0008)) * sparkI * exp(-dS * 0.08);
                }
            }
        }
    }
    
    float cFract = fract(iTime * 0.6);
    float bGlow = exp(-abs(cFract - 0.15) * 8.0) * 0.35;
/* Modif 7 */
    glowAcc += vec3(1.0, 0.4, 0.05) * bGlow * (1.0 / (0.4 + length(uv)));
    
    col += glowAcc;
    
    col = pow(col, vec3(0.4545));
    col *= 1.0 - 0.25 * dot(uv, uv);
    col = clamp(col, 0.0, 1.0);
    
    fragColor = vec4(col, 1.0);
}

// ==== Sound (sound) ====
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float audioNoise(float t) {
    return hash(t * 1337.137) * 2.0 - 1.0;
}
// All my Soft for Windows
// https://github.com/Patrickjaillet
vec2 mainSound(in int samp, in float time) {
    float period = 1.0 / 0.6;
    float cycleIndex = floor(time * 0.6);
    float strikeTime = (cycleIndex + 0.1) / 0.6;
    
    if (strikeTime > time) {
        cycleIndex -= 1.0;
        strikeTime = (cycleIndex + 0.1) / 0.6;
    }
    
    float dt = time - strikeTime;
    float cycle = fract(time * 0.6);
    
    float thudFreq = 32.0 + 90.0 * exp(-40.0 * dt);
    float thud = sin(6.28318530718 * thudFreq * dt) * exp(-3.8 * dt);
    thud *= smoothstep(0.0, 0.002, dt);
    
    float crackEnv = exp(-55.0 * dt);
    float crackFM = sin(6.28318530718 * 950.0 * dt + 16.0 * sin(6.28318530718 * 2800.0 * dt * crackEnv));
    float crack = crackFM * crackEnv * smoothstep(0.0, 0.0008, dt);
    
    float ringL = 0.0;
    float ringR = 0.0;
    float freqs[6] = float[](138.0, 276.0, 412.0, 680.0, 1050.0, 1720.0);
    float decays[6] = float[](4.0, 6.5, 9.0, 11.5, 14.0, 18.0);
    float amps[6] = float[](0.5, 0.35, 0.22, 0.14, 0.07, 0.03);
    
    for(int i = 0; i < 6; i++) {
        ringL += sin(6.28318530718 * freqs[i] * dt) * exp(-decays[i] * dt) * amps[i];
        ringR += sin(6.28318530718 * (freqs[i] * 1.005) * dt + 0.5) * exp(-decays[i] * dt) * amps[i];
    }
    ringL *= smoothstep(0.0, 0.003, dt);
    ringR *= smoothstep(0.0, 0.003, dt);
    
    float hissEnv = exp(-2.5 * dt) * (1.0 - exp(-25.0 * dt));
    float hissNL = audioNoise(time) * hissEnv * 0.25;
    float hissNR = audioNoise(time + 0.1337) * hissEnv * 0.25;
    
    float whine = 0.0;
    if (cycle < 0.1) {
        float progress = cycle / 0.1;
        float whineFreq = 80.0 + 220.0 * progress * progress;
        float whineEnv = progress * 0.15;
        whine = sin(6.28318530718 * whineFreq * time) * whineEnv;
        whine += audioNoise(time) * 0.025 * progress;
    }
    
    float drone = sin(6.28318530718 * 48.0 * time + sin(6.28318530718 * 0.4 * time)) * 0.05;
    drone += sin(6.28318530718 * 96.0 * time) * 0.015;
    
    float left = thud * 0.75 + crack * 0.55 + ringL * 0.45 + hissNL * 0.65 + whine * 0.4 + drone;
    float right = thud * 0.75 + crack * -0.45 + ringR * 0.45 + hissNR * 0.65 + whine * 0.4 + drone;
    
    vec2 signal = vec2(left, right) * 0.75;
    signal = clamp(signal, -1.2, 1.2);
    signal = signal - (signal * signal * signal) / 3.0;
    
    return signal;
}
