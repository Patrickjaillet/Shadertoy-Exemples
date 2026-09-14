// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    vec3 shift = vec3(100.0);
    for (int i = 0; i < 4; ++i) {
        v += a * (sin(p.x) * cos(p.y) * sin(p.z));
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float sdEllipsoid(vec3 p, vec3 r) {
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 getShipPosition(float t) {
    float cycle = mod(t, 10.0);
    vec3 pos = vec3(0.0);
    pos.x = sin(cycle * 0.8) * 0.4;
    pos.y = cos(cycle * 0.6) * 0.25;
    
    if (cycle > 5.0) {
        float jumpProgress = (cycle - 5.0) / 5.0;
        float accel = pow(jumpProgress, 4.0) * 350.0;
        pos.z += accel;
    } else {
        pos.z += sin(cycle * 0.5) * 0.2;
    }
    return pos;
}

mat3 getShipRotation(float t) {
    float cycle = mod(t, 10.0);
    float pitch = sin(cycle * 0.7) * 0.08;
    float roll = cos(cycle * 0.9) * 0.12;
    float yaw = sin(cycle * 0.4) * 0.05;

    if (cycle > 5.0) {
        float jumpProgress = (cycle - 5.0) / 5.0;
        pitch -= jumpProgress * 0.15;
    }

    float cp = cos(pitch), sp = sin(pitch);
    float cr = cos(roll), sr = sin(roll);
    float cy = cos(yaw), sy = sin(yaw);

    mat3 mPitch = mat3(1.0, 0.0, 0.0, 0.0, cp, -sp, 0.0, sp, cp);
    mat3 mRoll  = mat3(cr, -sr, 0.0, sr, cr, 0.0, 0.0, 0.0, 1.0);
    mat3 mYaw   = mat3(cy, 0.0, sy, 0.0, 1.0, 0.0, -sy, 0.0, cy);

    return mYaw * mPitch * mRoll;
}

vec2 map(vec3 p) {
    float cycle = mod(iTime, 10.0);
    vec3 shipPos = getShipPosition(iTime);
    mat3 shipRot = getShipRotation(iTime);

    p -= shipPos;
    p = shipRot * p;

    if (cycle > 5.0) {
        float stretch = 1.0 + pow((cycle - 5.0) / 5.0, 3.0) * 2.5;
        p.z /= stretch;
    }

    vec2 res = vec2(1e5, 0.0);
    vec3 pSym = vec3(abs(p.x), p.y, p.z);

    vec3 pSaucer = p - vec3(0.0, 0.25, 1.4);
    float dSaucerBase = sdEllipsoid(pSaucer, vec3(2.2, 0.22, 2.2));
    float dSaucerRim = sdEllipsoid(pSaucer, vec3(2.35, 0.08, 2.35));
    float dSaucer = max(dSaucerBase, -sdEllipsoid(pSaucer - vec3(0.0, -0.15, 0.0), vec3(2.0, 0.2, 2.0)));
    dSaucer = min(dSaucer, dSaucerRim);

    vec3 pBridge = pSaucer - vec3(0.0, 0.18, 0.0);
    float dBridge = sdEllipsoid(pBridge, vec3(0.55, 0.12, 0.55));
    float dDome = sdEllipsoid(pBridge - vec3(0.0, 0.08, 0.0), vec3(0.22, 0.08, 0.22));
    dBridge = min(dBridge, dDome);

    vec3 pImpulse = pSaucer - vec3(0.0, 0.02, -1.85);
    float dImpulse = sdBox(pImpulse, vec3(0.35, 0.05, 0.15));

    vec3 pNeck = p - vec3(0.0, -0.05, 0.25);
    pNeck.yz *= rot(0.25);
    float dNeck = sdBox(pNeck, vec3(0.08, 0.45, 0.55));
    dNeck = max(dNeck, -sdBox(pNeck - vec3(0.0, 0.0, -0.4), vec3(0.1, 0.6, 0.3)));

    vec3 pEng = p - vec3(0.0, -0.55, -0.35);
    float dEngHull = sdEllipsoid(pEng, vec3(0.52, 0.48, 1.6));

    vec3 pDish = pEng - vec3(0.0, 0.05, 1.35);
    float dDishOuter = sdEllipsoid(pDish, vec3(0.38, 0.38, 0.2));
    float dDishInner = sdEllipsoid(pDish - vec3(0.0, 0.0, 0.05), vec3(0.28, 0.28, 0.25));

    vec3 pPylons = pSym - vec3(0.35, -0.35, -0.8);
    pPylons.xy *= rot(-0.75);
    pPylons.yz *= rot(0.15);
    float dPylon = sdBox(pPylons, vec3(0.65, 0.05, 0.3));

    vec3 pNac = pSym - vec3(1.25, 0.38, -0.85);
    float dNacBody = sdEllipsoid(pNac, vec3(0.22, 0.22, 1.85));

    vec3 pBussard = pNac - vec3(0.0, 0.0, 1.6);
    float dBussard = sdEllipsoid(pBussard, vec3(0.21, 0.21, 0.3));

    vec3 pGlowStrip = pNac - vec3(0.12, 0.0, 0.1);
    float dGlowStrip = sdBox(pGlowStrip, vec3(0.12, 0.08, 1.1));

    float dHull = smin(dSaucer, dBridge, 0.05);
    dHull = min(dHull, dNeck);
    dHull = smin(dHull, dEngHull, 0.08);
    dHull = min(dHull, dPylon);
    dHull = min(dHull, dNacBody);
    dHull = max(dHull, -dDishInner);

    if (dHull < res.x) res = vec2(dHull, 1.0);
    if (dDishInner < res.x) res = vec2(dDishInner, 2.0);
    if (dBussard < res.x) res = vec2(dBussard, 3.0);
    if (dGlowStrip < res.x) res = vec2(dGlowStrip, 4.0);
    if (dImpulse < res.x) res = vec2(dImpulse, 5.0);

    return res;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy).x - map(p - e.xyy).x,
        map(p + e.yxy).x - map(p - e.yxy).x,
        map(p + e.yyx).x - map(p - e.yyx).x
    ));
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + h * n).x;
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float calcSoftShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 24; i++) {
        float h = map(ro + rd * t).x;
        res = min(res, 16.0 * h / t);
        t += clamp(h, 0.02, 0.2);
        if (res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 renderSpace(vec3 ro, vec3 rd) {
    float cycle = mod(iTime, 10.0);
    float warpIntensity = smoothstep(4.0, 8.0, cycle);
    
    vec3 streakRd = rd;
    if (warpIntensity > 0.0) {
        float stretchFactor = 1.0 + warpIntensity * 40.0;
        streakRd.z *= stretchFactor;
        streakRd = normalize(streakRd);
    }

    float starSeed = clamp(fract(sin(dot(streakRd, vec3(12.9898, 78.233, 45.164))) * 43758.5453), 0.0, 1.0);
    float stars = pow(starSeed, 180.0) * (2.5 + warpIntensity * 15.0);
    
    vec3 col = vec3(stars);

    float zOffset = (cycle > 5.0) ? pow((cycle - 5.0), 2.0) * 10.0 : 0.0;
    float neb1 = fbm(rd * 3.0 + vec3(0.0, 0.0, iTime * 0.02 + zOffset * 0.05));
    float neb2 = fbm(rd * 5.0 - vec3(iTime * 0.01));
    vec3 nebCol = mix(vec3(0.02, 0.05, 0.15), vec3(0.18, 0.04, 0.12), neb1);
    
    if (warpIntensity > 0.0) {
        nebCol = mix(nebCol, vec3(0.05, 0.35, 0.85), warpIntensity * 0.7);
    }
    
    col += nebCol * neb2 * (1.5 + warpIntensity * 3.0);
    
    if (warpIntensity > 0.0) {
        float tunnel = pow(abs(rd.z), 3.0) * warpIntensity;
        col += vec3(0.2, 0.5, 1.0) * tunnel * 2.0;
    }

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 mouse = iMouse.xy / iResolution.xy;
    float cycle = mod(iTime, 10.0);

    float angleY = (iMouse.z > 0.5) ? (mouse.x - 0.5) * 6.28 : iTime * 0.15;
    float angleX = (iMouse.z > 0.5) ? (mouse.y - 0.5) * 3.14 : 0.15 + 0.1 * sin(iTime * 0.1);

    vec3 ro = vec3(0.0, 0.0, 7.5);
    ro.yz *= rot(angleX);
    ro.xz *= rot(angleY);

    vec3 ta = getShipPosition(iTime);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));

    float fov = 1.8;
    if (cycle > 5.0) {
        fov += pow((cycle - 5.0) / 5.0, 2.0) * 0.8;
    }

    vec3 rd = normalize(uv.x * uu + uv.y * vv + fov * ww);

    vec3 col = renderSpace(ro, rd);

    float t = 0.1;
    float tmax = 200.0;
    vec2 res = vec2(-1.0);

    for (int i = 0; i < 160; i++) {
        vec3 p = ro + rd * t;
        res = map(p);
        if (abs(res.x) < 0.0012 || t > tmax) break;
        t += res.x * 0.55;
    }

    float warpEnergy = smoothstep(3.5, 6.0, cycle);

    if (t < tmax && res.y > 0.0) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        vec3 ref = reflect(rd, n);

        vec3 keyLightDir = normalize(vec3(0.8, 0.6, 0.9));
        vec3 fillLightDir = normalize(vec3(-0.8, -0.3, -0.5));
        vec3 keyLightCol = vec3(1.3, 1.25, 1.15);
        vec3 fillLightCol = vec3(0.2, 0.35, 0.55);

        float difKey = max(dot(n, keyLightDir), 0.0);
        float difFill = max(dot(n, fillLightDir), 0.0);
        float shadowKey = calcSoftShadow(p + n * 0.01, keyLightDir, 0.05, 4.0);
        float ao = calcAO(p, n);

        float spec = pow(max(dot(ref, keyLightDir), 0.0), 32.0) * shadowKey;

        vec3 matBase = vec3(0.82, 0.84, 0.88);
        vec3 emissive = vec3(0.0);

        float boost = 1.0 + warpEnergy * 4.0;

        if (res.y == 2.0) {
            emissive = vec3(0.1, 0.6, 1.2) * 2.5 * boost;
        } else if (res.y == 3.0) {
            emissive = vec3(1.5, 0.2, 0.05) * 3.0 * boost;
        } else if (res.y == 4.0) {
            emissive = vec3(0.15, 0.7, 1.4) * 2.8 * boost;
        } else if (res.y == 5.0) {
            emissive = vec3(1.6, 0.3, 0.05) * 3.0 * (1.0 + warpEnergy * 8.0);
        }

        vec3 ambient = renderSpace(p, ref) * 0.6;
        vec3 diffuse = keyLightCol * difKey * shadowKey + fillLightCol * difFill;

        col = matBase * (diffuse + ambient) * ao + vec3(spec) + emissive;
        col = mix(col, renderSpace(ro, rd), 1.0 - exp(-0.0003 * t * t));
    }

    if (cycle > 5.5) {
        float jumpFlash = smoothstep(5.5, 6.2, cycle) * (1.0 - smoothstep(6.2, 7.5, cycle));
        col += vec3(0.4, 0.7, 1.0) * jumpFlash * 3.5;
    }

    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
