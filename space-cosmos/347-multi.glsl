// ==== Image (image) ====
vec3 rotateX(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(p.x, c * p.y - s * p.z, s * p.y + c * p.z);
}

vec3 rotateY(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
}
// https://github.com/Patrickjaillet
vec3 rotateZ(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float mapSpaceDebris(vec3 p) {
    vec3 i = floor((p + 15.0) / 30.0);
    vec3 f = mod(p + 15.0, 30.0) - 15.0;
    float h = sin(dot(i, vec3(127.1, 311.7, 74.7))) * 43758.5453123;
    f += sin(f.yzx * 0.6 + h) * 4.0;
    return sdBox(rotateY(rotateX(f, h * 2.0), h * 1.5), vec3(0.2 + abs(sin(h)) * 0.6));
}

void getSceneData(vec3 p, float time, out float d, out int id, out vec3 tPos, out float speedPhase) {
    float cycle = mod(time, 24.0);
    speedPhase = 0.0;
    
    if (cycle < 6.0) {
        speedPhase = 0.0;
    } else if (cycle < 9.0) {
        speedPhase = smoothstep(0.0, 1.0, (cycle - 6.0) / 3.0);
    } else if (cycle < 15.0) {
        speedPhase = 1.0;
    } else if (cycle < 18.0) {
        speedPhase = 1.0 - smoothstep(0.0, 1.0, (cycle - 15.0) / 3.0);
    } else {
        speedPhase = 0.0;
    }
    
    float totalDist = (floor(time / 24.0) * 24.0) * 250.0;
    if (cycle < 6.0) totalDist += cycle * 20.0;
    else if (cycle < 9.0) totalDist += 6.0 * 20.0 + (cycle - 6.0) * 20.0 + smoothstep(0.0, 3.0, cycle - 6.0) * 690.0;
    else if (cycle < 15.0) totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + (cycle - 9.0) * 250.0;
    else if (cycle < 18.0) totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + (cycle - 15.0) * 250.0 - smoothstep(0.0, 3.0, cycle - 15.0) * 690.0;
    else totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + 3.0 * 250.0 - 690.0 + (cycle - 18.0) * 20.0;
    
    vec3 targetCenter = vec3(sin(totalDist * 0.005) * 25.0, cos(totalDist * 0.007) * 15.0, totalDist + 35.0);
    tPos = targetCenter;
    
    vec3 localP = p - targetCenter;
    localP.z += sin(localP.x * 0.4 + localP.y * 0.4 + time * 10.0) * speedPhase * 1.5;
    localP.xy *= 1.0 + speedPhase * (sin(localP.z * 0.5 - time * 15.0) * 0.25);
    
    vec3 pRot = rotateZ(rotateY(rotateX(localP, time * 1.5), time * 0.9), time * 0.4);
    float dTarget = sdBox(pRot, vec3(4.0));
    
    float dEnv = mapSpaceDebris(p);
    
    if (dTarget < dEnv) {
        d = dTarget;
        id = 1;
    } else {
        d = dEnv;
        id = 2;
    }
}

vec3 getNormal(vec3 p, float time) {
    vec2 e = vec2(0.01, 0.0);
    float d; int id; vec3 tp; float sp;
    getSceneData(p, time, d, id, tp, sp);
    vec3 n;
    float d1, d2, d3;
    getSceneData(p + e.xyy, time, d1, id, tp, sp);
    getSceneData(p + e.yxy, time, d2, id, tp, sp);
    getSceneData(p + e.yyx, time, d3, id, tp, sp);
    n.x = d1 - d;
    n.y = d2 - d;
    n.z = d3 - d;
    return normalize(n);
}

float getAO(vec3 p, vec3 n, float time) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float hr = 0.02 + 0.15 * float(i) / 4.0;
        vec3 aopos = n * hr + p;
        float d; int id; vec3 tp; float sp;
        getSceneData(aopos, time, d, id, tp, sp);
        occ += -(d - hr) * sca;
        sca *= 0.9;
    }
    return clamp(1.0 - 2.5 * occ, 0.0, 1.0);
}

vec3 renderTunnel(vec3 ro, vec3 rd, float time, float speedPhase) {
    float z = ro.z + rd.z * 2.0;
    vec3 tunnelColor = vec3(0.0);
    
    for(int i = 0; i < 4; i++) {
        float depth = float(i) * 8.0 - mod(time * 80.0, 8.0);
        if(depth < 0.1) depth += 32.0;
        
        vec3 p = ro + rd * depth;
        float angle = atan(p.y, p.x) + time * 0.5;
        float radius = length(p.xy);
        
        float tunnelWall = smoothstep(12.0, 10.0, radius) * smoothstep(8.0, 10.0, radius);
        float pattern = step(0.7, sin(angle * 12.0) * cos(radius * 0.4 + time * 5.0));
        
        vec3 c = mix(vec3(0.05, 0.2, 0.8), vec3(0.7, 0.1, 0.9), sin(depth * 0.05) * 0.5 + 0.5);
        tunnelColor += c * tunnelWall * pattern * (1.0 - depth / 32.0) * 1.5;
    }
    return tunnelColor * speedPhase;
}

vec3 getBackgroundStars(vec3 rd, float time, float speedPhase) {
    vec3 color = vec3(0.0);
    vec3 rdir = rd;
    
    for (int i = 0; i < 3; i++) {
        vec3 p = rdir * (float(i) * 15.0 + 40.0);
        p.z -= time * 12.0;
        
        vec3 st = floor(p);
        vec3 rf = fract(p) - 0.5;
        
        float h = sin(dot(st, vec3(12.13, 71.51, 93.73))) * 43758.5453;
        
        vec3 offset = vec3(fract(h), fract(h * 1.3), fract(h * 1.7)) - 0.5;
        float size = fract(h * 2.5);
        
        float d = length(rf - offset * 0.8);
        float star = smoothstep(0.06 * size, 0.0, d);
        
        vec3 starCol = mix(vec3(0.6, 0.8, 1.0), vec3(1.0, 0.9, 0.7), fract(h * 4.0));
        color += starCol * star * (1.0 - speedPhase);
    }
    return color;
}

vec3 scene(vec2 uv, float time, float speedPhase, vec3 camPos, vec3 targetPos, vec3 right, vec3 up, vec3 forward, float fov) {
    vec3 rd = normalize(forward * fov + uv.x * right + uv.y * up);
    
    float d = 0.0, t = 0.02, maxDist = 220.0;
    int objId = 0;
    vec3 hitTargetPos = vec3(0.0);
    
    for (int i = 0; i < 120; i++) {
        vec3 p = camPos + rd * t;
        float dScene;
        getSceneData(p, time, dScene, objId, hitTargetPos, speedPhase);
        if (abs(dScene) < 0.002 || t > maxDist) {
            d = dScene;
            break;
        }
        t += dScene * 0.8;
    }
    
    vec3 color = vec3(0.0);
    vec3 spaceColor = vec3(0.005, 0.008, 0.015) + getBackgroundStars(rd, time, speedPhase);
    vec3 tunnelBg = renderTunnel(camPos, rd, time, speedPhase);
    vec3 bg = spaceColor * (1.0 - speedPhase) + tunnelBg;
    
    if (t < maxDist) {
        vec3 p = camPos + rd * t;
        vec3 n = getNormal(p, time);
        vec3 lDir = normalize(hitTargetPos - p + vec3(8.0, 15.0, -8.0));
        float ao = getAO(p, n, time);
        
        if (objId == 1) {
            float diff = max(dot(n, lDir), 0.0);
            float spec = pow(max(dot(reflect(-lDir, n), -rd), 0.0), 64.0);
            vec3 cubeMat = mix(vec3(0.05, 0.5, 1.0), vec3(1.0, 0.1, 0.4), speedPhase);
            
            vec3 localP = p - hitTargetPos;
            float grid = step(0.94, max(max(abs(mod(localP.x, 0.4) - 0.20), abs(mod(localP.y, 0.4) - 0.20)), abs(mod(localP.z, 0.4) - 0.20))) * 6.0;
            vec3 glowColor = mix(vec3(0.0, 0.9, 1.0), vec3(2.5, 0.3, 0.1), speedPhase);
            
            color = (cubeMat * diff + spec * 1.2) * ao + grid * glowColor;
        } else if (objId == 2) {
            float diff = max(dot(n, lDir), 0.0);
            color = vec3(0.3, 0.35, 0.4) * diff * ao;
        }
        color = mix(color, bg, smoothstep(50.0, maxDist, t));
    } else {
        color = bg;
    }
    
    int streakCount = int(15.0 + speedPhase * 45.0);
    float streakIntensity = speedPhase * 1.8;
    
    for (int i = 0; i < 60; i++) {
        if (i >= streakCount) break;
        float fi = float(i);
        float h1 = sin(fi * 165.4) * 43758.545;
        float h2 = cos(fi * 294.3) * 31124.123;
        
        vec2 streakUV = uv;
        streakUV.x += sin(h1) * 3.0;
        streakUV.y += cos(h2) * 3.0;
        
        float currentSpeed = 30.0 + speedPhase * 280.0;
        float streakTime = time * currentSpeed * 0.04 + h1;
        float zf = mod(streakTime, 1.0);
        
        vec2 pProj = streakUV / (zf * 2.2);
        float dLine = length(pProj - normalize(vec2(h1, h2)) * (1.0 - zf));
        
        float lDist = length(streakUV);
        float factor = smoothstep(0.12, 0.0, dLine) * step(0.05, lDist);
        vec3 sCol = mix(vec3(0.3, 0.6, 1.0), vec3(1.0, 0.2, 0.8), zf);
        color += sCol * factor * streakIntensity * (1.0 - zf) * zf;
    }
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime;
    
    float cycle = mod(time, 24.0);
    float speedPhase = 0.0;
    if (cycle < 6.0) speedPhase = 0.0;
    else if (cycle < 9.0) speedPhase = smoothstep(0.0, 3.0, cycle - 6.0);
    else if (cycle < 15.0) speedPhase = 1.0;
    else if (cycle < 18.0) speedPhase = 1.0 - smoothstep(0.0, 3.0, cycle - 15.0);
    
    float totalDist = (floor(time / 24.0) * 24.0) * 250.0;
    if (cycle < 6.0) totalDist += cycle * 20.0;
    else if (cycle < 9.0) totalDist += 6.0 * 20.0 + (cycle - 6.0) * 20.0 + smoothstep(0.0, 3.0, cycle - 6.0) * 690.0;
    else if (cycle < 15.0) totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + (cycle - 9.0) * 250.0;
    else if (cycle < 18.0) totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + (cycle - 15.0) * 250.0 - smoothstep(0.0, 3.0, cycle - 15.0) * 690.0;
    else totalDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + 3.0 * 250.0 - 690.0 + (cycle - 18.0) * 20.0;
    
    vec3 accColor = vec3(0.0);
    int samples = 7;
    float blurScale = speedPhase * 0.045;
    
    for(int i = 0; i < samples; i++) {
        float fi = float(i) / float(samples - 1);
        float offsetTime = time - fi * blurScale;
        
        float c_cycle = mod(offsetTime, 24.0);
        float s_Phase = 0.0;
        if (c_cycle < 6.0) s_Phase = 0.0;
        else if (c_cycle < 9.0) s_Phase = smoothstep(0.0, 3.0, c_cycle - 6.0);
        else if (c_cycle < 15.0) s_Phase = 1.0;
        else if (c_cycle < 18.0) s_Phase = 1.0 - smoothstep(0.0, 3.0, c_cycle - 15.0);
        
        float tDist = (floor(offsetTime / 24.0) * 24.0) * 250.0;
        if (c_cycle < 6.0) tDist += c_cycle * 20.0;
        else if (c_cycle < 9.0) tDist += 6.0 * 20.0 + (c_cycle - 6.0) * 20.0 + smoothstep(0.0, 3.0, c_cycle - 6.0) * 690.0;
        else if (c_cycle < 15.0) tDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + (c_cycle - 9.0) * 250.0;
        else if (c_cycle < 18.0) tDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + (c_cycle - 15.0) * 250.0 - smoothstep(0.0, 3.0, c_cycle - 15.0) * 690.0;
        else tDist += 6.0 * 20.0 + 3.0 * 20.0 + 690.0 + 6.0 * 250.0 + 3.0 * 250.0 - 690.0 + (c_cycle - 18.0) * 20.0;
        
        vec3 cPos = vec3(sin(tDist * 0.005) * 25.0, cos(tDist * 0.007) * 15.0, tDist);
        vec3 tPos = vec3(sin((tDist + 35.0) * 0.005) * 25.0, cos((tDist + 35.0) * 0.007) * 15.0, tDist + 35.0);
        
        float shk = s_Phase * (sin(offsetTime * 65.0) * 0.04);
        cPos.xy += vec2(shk, -shk);
        
        vec3 fwd = normalize(tPos - cPos);
        vec3 rgt = normalize(cross(vec3(sin(offsetTime * 0.15) * 0.2, 1.0, 0.0), fwd));
        vec3 u_p = cross(fwd, rgt);
        
        float f_ov = 1.3 - s_Phase * 0.5;
        
        accColor += scene(uv, offsetTime, s_Phase, cPos, tPos, rgt, u_p, fwd, f_ov);
    }
    
    vec3 color = accColor / float(samples);
    
    vec2 vigUV = fragCoord / iResolution.xy;
    color *= 0.4 + 0.6 * pow(16.0 * vigUV.x * vigUV.y * (1.0 - vigUV.x) * (1.0 - vigUV.y), 0.3);
    
    color = pow(color, vec3(1.0 / 2.2));
    color = clamp(color, 0.0, 1.0);
    
    fragColor = vec4(color, 1.0);
}

// ==== Sound (sound) ====
float hash(float n) { 
    return fract(sin(n) * 43758.5453123); 
}

float noise(float p) {
    float fl = floor(p);
    float fc = fract(p);
    return mix(hash(fl), hash(fl + 1.0), fc);
}

float brownNoise(inout float state, float time) {
    state = (state + (noise(time * 12000.0) * 2.0 - 1.0) * 0.15) * 0.98;
    return state;
}

float getSpeedPhase(float time) {
    float cycle = mod(time, 24.0);
    if (cycle < 6.0) return 0.0;
    if (cycle < 9.0) return smoothstep(0.0, 1.0, (cycle - 6.0) / 3.0);
    if (cycle < 15.0) return 1.0;
    if (cycle < 18.0) return 1.0 - smoothstep(0.0, 1.0, (cycle - 15.0) / 3.0);
    return 0.0;
}

vec2 mainSound(int samp, float time) {
    float cycle = mod(time, 24.0);
    float speedPhase = getSpeedPhase(time);
    
    float brownStateL = 0.0;
    float brownStateR = 0.0;
    float nL = brownNoise(brownStateL, time);
    float nR = brownNoise(brownStateR, time + 55.4);
    
    float f1 = mix(28.0, 68.0, speedPhase);
    float f2 = f1 * 1.5;
    float f3 = f1 * 2.0;
    
    float sub = sin(6.283185 * f1 * time + nL * 0.2);
    float mid1 = sin(6.283185 * f2 * time + nR * 0.1);
    float mid2 = sin(6.283185 * f3 * time + sin(6.283185 * 8.0 * time) * 0.2);
    
    float engineOsc = sub * 0.5 + mid1 * 0.3 + mid2 * 0.15;
    
    float rumbleFreq = mix(18.0, 45.0, speedPhase);
    float rMod = sin(6.283185 * rumbleFreq * time + nL * 0.4);
    float engineTexture = mix(nL, nR, 0.5) * (0.2 + speedPhase * 0.45) * abs(rMod);
    
    float engineL = engineOsc * 0.45 + engineTexture * 0.35;
    float engineR = engineOsc * 0.45 + engineTexture * 0.35;
    
    float transL = 0.0, transR = 0.0;
    if (cycle >= 5.5 && cycle <= 9.5) {
        float t = smoothstep(5.5, 8.0, cycle) * (1.0 - smoothstep(8.5, 9.5, cycle));
        float sweep = mix(45.0, 180.0, t);
        transL = sin(6.283185 * sweep * time + nL * 0.5) * t * 0.45;
        transR = sin(6.283185 * (sweep * 0.99) * time + nR * 0.5) * t * 0.45;
    }
    if (cycle >= 14.5 && cycle <= 18.5) {
        float t = smoothstep(14.5, 16.5, cycle) * (1.0 - smoothstep(17.5, 18.5, cycle));
        float sweep = mix(180.0, 35.0, t);
        transL = sin(6.283185 * sweep * time + nL * 0.6) * t * 0.5;
        transR = sin(6.283185 * (sweep * 1.01) * time + nR * 0.6) * t * 0.5;
    }
    
    float humL = 0.0, humR = 0.0;
    if (speedPhase > 0.01) {
        float hf1 = 90.0 + sin(time * 4.0) * 3.0;
        float hf2 = 135.0 + cos(time * 6.0) * 4.0;
        humL = (sin(6.283185 * hf1 * time) * 0.08 + sin(6.283185 * hf2 * time) * 0.04) * speedPhase;
        humR = (sin(6.283185 * (hf1 * 1.002) * time) * 0.08 + sin(6.283185 * (hf2 * 0.998) * time) * 0.04) * speedPhase;
        
        float lowPassSuno = mix(nL, nR, sin(time * 0.2) * 0.5 + 0.5);
        humL += lowPassSuno * 0.06 * speedPhase;
        humR += lowPassSuno * 0.06 * speedPhase;
    }
    
    float outL = engineL + transL + humL;
    float outR = engineR + transR + humR;
    
    if (speedPhase < 0.85) {
        float hTime = mod(time, 0.85);
        float hf = mix(42.0, 32.0, speedPhase);
        float hb = sin(6.283185 * hf * hTime) * exp(-16.0 * hTime);
        hb += sin(6.283185 * (hf * 0.9) * max(hTime - 0.18, 0.0)) * exp(-16.0 * max(hTime - 0.18, 0.0)) * step(0.18, hTime);
        float hbOut = hb * 0.28 * (1.0 - speedPhase);
        outL += hbOut;
        outR += hbOut;
    }
    
    outL = clamp(outL * 1.3, -1.0, 1.0);
    outR = clamp(outR * 1.3, -1.0, 1.0);
    
    outL = outL - 0.15 * (outL * outL * outL);
    outR = outR - 0.15 * (outR * outR * outR);
    
    return vec2(outL, outR);
}
