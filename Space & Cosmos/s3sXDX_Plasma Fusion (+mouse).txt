// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}
// https://github.com/Patrickjaillet/Z-GL-Shadertoy
vec3 palette(float t) {
    return vec3(0.5) + vec3(0.5) * cos(6.2831853 * (vec3(1.0) * t + vec3(0.28, 0.18, 0.22)) + vec3(0.0, 1.3, 2.8));
}

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float star(vec2 uv, float flare) {
    float d = length(uv);
    float m = 0.04 / d;
    float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1200.0));
    m += rays * flare * 1.5;
    uv *= rot(0.78539816);
    rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1200.0));
    m += rays * 0.4 * flare;
    return m * smoothstep(0.4, 0.1, d);
}

vec3 GetBackground(vec3 rd, float time) {
    vec3 bgColor = vec3(0.002, 0.004, 0.015) * (1.0 - abs(rd.y)); 
    float noise = 0.0;
    vec3 p = rd * 4.0;
    float shift = time * 0.02;
    for(float i=1.0; i<=4.0; i++){
        p.xz *= rot(shift / i);
        noise += (sin(p.x + sin(p.y * 1.4) + p.z) * 0.5 + 0.5) / i;
        p *= 2.1;
    }
    bgColor += palette(noise * 0.35 + time * 0.05) * noise * 0.04;
    vec2 uv = rd.xy * 16.0;
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
    float flicker = hash21(id);
    float starSize = sin(time * 4.0 + flicker * 6.2831853) * 0.5 + 0.5;
    if(flicker > 0.95) {
        bgColor += vec3(0.9, 0.95, 1.0) * star(gv, starSize) * flicker * 1.2;
    }
    return bgColor;
}

float map(vec3 p, inout float g_glow, float time, inout float matID) {
    vec3 q = p; 
    float d = 1e5;
    
    vec3 p_env = p;
    p_env.z += time * 12.0; 
    p_env.xy *= rot(p_env.z * 0.005);

    vec3 id = floor((p_env + 8.0) / 16.0);
    p_env = mod(p_env + 8.0, 16.0) - 8.0;
    
    float box = length(max(abs(p_env) - vec3(3.5, 3.5, 16.0), 0.0));
    float t_cylinder = -length(p_env.xy) + 5.5 + sin(p_env.z * 0.25 + time) * 0.4;
    
    float g_ribs = sin(p_env.z * 2.5) * 0.2;
    box = max(box, t_cylinder + g_ribs); 
    d = box;
    matID = 0.0;
    
    vec3 p_frac = q;
    p_frac.xz *= rot(time * 0.12);
    p_frac.yz *= rot(time * 0.08);

    float scale = 1.0;
    float localGlow = 0.0;
    
    for(int i = 0; i < 7; i++) {
        p_frac = abs(p_frac) - vec3(0.65, 0.75 + float(i) * 0.05, 0.65); 
        p_frac.xz *= rot(0.78539816); 
        p_frac.yz *= rot(0.28 + float(i) * 0.04);
        
        scale *= 1.38;
        p_frac *= 1.38;
        p_frac -= vec3(1.05, 0.35, 1.05); 
        
        localGlow += exp(-length(p_frac) * 1.2) * (1.0 / scale);
    }
    
    float frac_d = (length(p_frac) - 0.012) / scale; 
    g_glow += localGlow * 0.35;
    
    if (frac_d < d) {
        d = smin(d, frac_d, 0.8);
        matID = 1.0;
    } else {
        d = smin(d, frac_d, 0.8);
    }
    
    return d;
}

vec3 GetNormal(vec3 p, float time) {
    float dummyGlow = 0.0;
    float dummyMat = 0.0;
    vec2 e = vec2(0.001, 0.0); 
    return normalize(vec3(
        map(p + e.xyy, dummyGlow, time, dummyMat) - map(p - e.xyy, dummyGlow, time, dummyMat),
        map(p + e.yxy, dummyGlow, time, dummyMat) - map(p - e.yxy, dummyGlow, time, dummyMat),
        map(p + e.yyx, dummyGlow, time, dummyMat) - map(p - e.yyx, dummyGlow, time, dummyMat)
    ));
}

float GetAO(vec3 p, vec3 n, float time) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        vec3 aopos = n * hr + p;
        float dummyGlow = 0.0;
        float dummyMat = 0.0;
        float dd = map(aopos, dummyGlow, time, dummyMat);
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 1.5 * occ, 0.0, 1.0);
}

float shadow(vec3 ro, vec3 rd, float mint, float maxt, float time) {
    float res = 1.0;
    float t = mint;
    for(int i=0; i<32; i++) {
        float dummyGlow = 0.0;
        float dummyMat = 0.0;
        float h = map(ro + rd*t, dummyGlow, time, dummyMat);
        if(h < 0.001) return 0.0;
        res = min(res, 10.0 * h / t);
        t += clamp(h, 0.02, 0.2);
        if(t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.z <= 0.0) m = vec2(0.5, 0.45); 

    vec2 uvScene = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, -8.0); 
    vec3 rd = normalize(vec3(uvScene, 1.6)); 

    float pitch = (m.y - 0.5) * 2.2;
    float yaw = (m.x - 0.5) * 4.5;
    rd.yz *= rot(pitch);
    rd.xz *= rot(yaw);
    ro.yz *= rot(pitch * 0.3); 
    ro.xz *= rot(yaw * 0.3);
    
    float t = 0.0;
    float maxDist = 90.0;
    float g_glow = 0.0;
    float matID = 0.0;
    float activeMat = 0.0;
    
    for(int i = 0; i < 160; i++) {
        vec3 p = ro + rd * t;
        float d = map(p, g_glow, iTime, matID);
        t += d * 0.75; 
        if(d < 0.001 || t > maxDist) {
            activeMat = matID;
            break;
        }
    }
    // https://github.com/Patrickjaillet/Z-GL-Shadertoy
    vec3 col = vec3(0.0);
    vec3 bgCol = GetBackground(rd, iTime);

    if(t < maxDist) {
        vec3 p = ro + rd * t;
        vec3 n = GetNormal(p, iTime);
        vec3 r = reflect(rd, n);
        
        float ao = GetAO(p, n, iTime);
        
        vec3 l1 = normalize(vec3(8.0, 15.0, p.z - 6.0) - p);
        vec3 l2 = normalize(vec3(-8.0, -12.0, p.z + 6.0) - p);
        
        float sh1 = shadow(p, l1, 0.05, 6.0, iTime);
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0) * 0.4;
        
        float spec1 = pow(max(dot(r, l1), 0.0), 40.0);
        float spec2 = pow(max(dot(r, l2), 0.0), 18.0);
        
        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        
        vec3 objColor = palette(length(p.xy) * 0.06 + p.z * 0.012);
        if(activeMat > 0.5) {
            objColor = mix(objColor, vec3(1.0, 0.8, 0.25), 0.4);
        }
        
        vec3 p_spec = sin(p * 50.0);
        float specNoise = smoothstep(0.25, 0.35, p_spec.x * p_spec.y * p_spec.z);
        
        col = objColor * (diff1 * sh1 * vec3(1.0, 0.88, 0.7) + diff2 * vec3(0.2, 0.4, 0.95));
        col += vec3(1.0, 0.96, 0.88) * spec1 * sh1 * (2.0 + specNoise * 3.0); 
        col += vec3(0.3, 0.7, 1.0) * spec2 * 0.6; 
        col += bgCol * fresnel * 4.0; 
        col *= ao;
        
        col = mix(col, bgCol, 1.0 - exp(-t * t * 0.00005));
    } else {
        col = bgCol;
        g_glow += 1.8; 
    }
    
    vec3 glowColor = mix(vec3(0.05, 0.4, 1.0), vec3(1.0, 0.1, 0.02), smoothstep(0.0, 5.0, g_glow));
    vec3 baseScene = col + glowColor * g_glow * 0.07;

    vec3 bloom = vec3(0.0);
    vec2 blurOffsets[8];
    blurOffsets[0] = vec2(-1.5, -1.5); blurOffsets[1] = vec2(1.5, -1.5);
    blurOffsets[2] = vec2(-1.5, 1.5);  blurOffsets[3] = vec2(1.5, 1.5);
    blurOffsets[4] = vec2(0.0, -2.0);  blurOffsets[5] = vec2(0.0, 2.0);
    blurOffsets[6] = vec2(-2.0, 0.0);  blurOffsets[7] = vec2(2.0, 0.0);
    
    float dummyMat = 0.0;
    for(int i = 0; i < 8; i++) {
        vec2 blurUv = uvScene + (blurOffsets[i] * 6.5) / iResolution.y;
        float bGlow = 0.0;
        float bt = 0.0;
        for(int j = 0; j < 24; j++) {
            vec3 bp = ro + normalize(vec3(blurUv, 1.6)) * bt;
            float bd = map(bp, bGlow, iTime, dummyMat);
            bt += bd * 0.85;
            if(bd < 0.01 || bt > 40.0) break;
        }
        vec3 bCol = (bt < 40.0) ? palette(bt * 0.015) * 0.35 : bgCol;
        vec3 bGlowCol = mix(vec3(0.05, 0.4, 1.0), vec3(1.0, 0.1, 0.02), smoothstep(0.0, 5.0, bGlow));
        bloom += max((bCol + bGlowCol * bGlow * 0.07) - vec3(0.4), 0.0);
    }
    bloom *= 0.125 * 2.5;

    float caStrength = smoothstep(0.1, 1.2, length(uv - 0.5)) * 0.007;
    vec2 shift = (uv - 0.5) * caStrength;
    
    vec3 sceneSample = baseScene;
    vec2 uvR = uvScene - shift * 1.8;
    vec2 uvB = uvScene + shift * 1.8;
    float gR = 0.0, gB = 0.0;
    
    float tR = 0.0;
    for(int i = 0; i < 55; i++) {
        float d = map(ro + normalize(vec3(uvR, 1.6)) * tR, gR, iTime, dummyMat);
        tR += d * 0.8; if(d < 0.003 || tR > 60.0) break;
    }
    if (tR < 60.0) sceneSample.r = mix(sceneSample.r, palette(tR * 0.015).r, 0.5);

    float tB = 0.0;
    for(int i = 0; i < 55; i++) {
        float d = map(ro + normalize(vec3(uvB, 1.6)) * tB, gB, iTime, dummyMat);
        tB += d * 0.8; if(d < 0.003 || tB > 60.0) break;
    }
    if (tB < 60.0) sceneSample.b = mix(sceneSample.b, palette(tB * 0.015).b, 0.5);

    col = mix(baseScene, sceneSample, 0.5) + bloom * 0.5;
    
    col *= 0.95;
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    col = pow(col, vec3(0.45454545));

    vec2 vuv = uv * (1.0 - uv.yx);
    col *= mix(0.55, 1.0, pow(vuv.x * vuv.y * 15.0, 0.4));

    float grain = fract(sin(dot(uv + iTime * 0.08, vec2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.025;
    
    fragColor = vec4(smoothstep(-0.02, 1.02, col), 1.0);
}
