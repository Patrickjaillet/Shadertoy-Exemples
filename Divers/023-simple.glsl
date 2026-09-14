// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1136, 0.1377));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
               mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x), u.y);
}

float sdVesica(vec2 p, float r, float d) {
    p = abs(p);
    float b = sqrt(max(r * r - d * d, 0.0));
    return ((p.y - b) * d > p.x * b) ? length(p - vec2(0.0, b))
                                      : length(p - vec2(-d, 0.0)) - r;
}

float sdRoundCone(vec3 p, vec3 a, vec3 b, float r1, float r2) {
    vec3 ba = b - a;
    float l2 = dot(ba, ba);
    float rr = r1 - r2;
    float a2 = l2 - rr * rr;
    float il2 = 1.0 / l2;
    vec3 pa = p - a;
    float y = dot(pa, ba);
    float z = y - l2;
    float x2 = dot(pa * l2 - ba * y, pa * l2 - ba * y);
    float y2 = y * y * l2;
    float z2 = z * z * l2;
    float k = sign(rr) * rr * rr * x2;
    if (sign(z) * a2 * z2 > k) return sqrt(x2 + z2) * il2 - r2;
    if (sign(y) * a2 * y2 < k) return sqrt(x2 + y2) * il2 - r1;
    return (sqrt(x2 * a2 * il2) + y * rr) * il2 - r1;
}

float sdEllipsoidBound(vec3 p, vec3 r) {
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

vec4 opU(vec4 a, vec4 b) { return (a.x < b.x) ? a : b; }

vec3 windTilt(vec3 p, float windT) {
    vec3 pivot = vec3(0.0, -1.3, 0.0);
    vec3 q = p - pivot;
    float swZ = sin(windT * 0.5) * 0.06 + (noise(vec2(windT * 0.15, 7.7)) - 0.5) * 0.05;
    float swX = sin(windT * 0.37 + 2.1) * 0.045 + (noise(vec2(windT * 0.13, 31.4)) - 0.5) * 0.04;
    q.xy = q.xy * rot(swZ);
    q.zy = q.zy * rot(swX);
    return q + pivot;
}

vec4 layerPetals(vec3 p, float idx, float numPetals, float fullLen, float halfWidth, float thick,
                  float attachH, float tilt, float curl, float rotOff, float seed, float windT) {
    vec3 lp = p;
    lp.y -= attachH;
    float ang = atan(lp.z, lp.x);
    float rad = length(lp.xz);
    float angleStep = 6.2831853 / numPetals;

    float petalId = floor((ang - rotOff) / angleStep + 0.5);
    float phase = hash12(vec2(petalId, seed)) * 6.2831853;
    float speed = 0.5 + hash12(vec2(petalId + 2.3, seed * 1.7)) * 0.6;
    float windAmp = 0.04 + fullLen * 0.06;
    float gust = sin(windT * speed + phase) * windAmp
               + (noise(vec2(windT * 0.4 + phase * 2.0, seed + petalId * 0.6)) - 0.5) * windAmp * 0.8;

    float angLocal = mod(ang - rotOff - gust + angleStep * 0.5, angleStep) - angleStep * 0.5;
    float wCoord = rad * sin(angLocal);
    float lCoord = rad * cos(angLocal);
    float xn = clamp(lCoord / fullLen, 0.0, 1.0);

    float heightOffset = fullLen * (tan(tilt) * xn * 0.6 + curl * xn * xn * 0.5);
    float ripple = sin(xn * 14.0 + petalId * 1.7 + windT * 0.6) * 0.006 * (1.0 - xn) * (wCoord / max(halfWidth, 0.001));
    float hLocal = lp.y - heightOffset - ripple;

    float b = fullLen * 0.5;
    float hw = max(halfWidth, 0.001);
    float r = (hw + b * b / hw) * 0.5;
    float d = (b * b / hw - hw) * 0.5;

    vec2 vp = vec2(wCoord, lCoord - b);
    float d2 = sdVesica(vp, r, d);

    float edgeThin = smoothstep(0.55, 1.0, abs(wCoord) / hw);
    float halfThick = thick * (1.0 - 0.45 * xn) * mix(1.0, 0.25, edgeThin);
    float d1 = abs(hLocal) - halfThick;

    vec2 w = vec2(d2, d1);
    float dist = min(max(w.x, w.y), 0.0) + length(max(w, 0.0));

    return vec4(dist, idx, xn, wCoord / hw);
}

vec4 map(vec3 pIn, float windT) {
    vec3 p = windTilt(pIn, windT);
    vec4 res = vec4(1e5, -9.0, 0.0, 0.0);

    res = opU(res, vec4(pIn.y + 1.32, -4.0, 0.0, 0.0));

    vec3 s0 = vec3(0.0, -1.3, 0.0), s1 = vec3(0.04, -0.85, 0.03), s2 = vec3(-0.03, -0.4, -0.02), s3 = vec3(0.0, 0.0, 0.0);
    float stemD = sdRoundCone(p, s0, s1, 0.045, 0.036);
    stemD = min(stemD, sdRoundCone(p, s1, s2, 0.036, 0.028));
    stemD = min(stemD, sdRoundCone(p, s2, s3, 0.028, 0.020));
    res = opU(res, vec4(stemD, -1.0, 0.0, 0.0));

    for (int lf = 0; lf < 2; lf++) {
        float side = lf == 0 ? 1.0 : -1.0;
        vec3 lp = p - vec3(0.0, -0.55, 0.0);
        float ca = cos(side * 0.9), sa = sin(side * 0.9);
        vec3 lq = vec3(lp.x * ca - lp.z * sa, lp.y, lp.x * sa + lp.z * ca);
        lq.y -= lq.x * 0.35;
        float lb = 0.28, lhw = 0.10;
        float lr = (lhw + lb * lb / lhw) * 0.5, ld = (lb * lb / lhw - lhw) * 0.5;
        vec2 lvp = vec2(lq.z, lq.x - lb);
        float ld2 = sdVesica(lvp, lr, ld);
        float ld1 = abs(lq.y) - 0.006;
        vec2 lw = vec2(ld2, ld1);
        float leafD = min(max(lw.x, lw.y), 0.0) + length(max(lw, 0.0));
        res = opU(res, vec4(leafD, -2.0, clamp(lq.x / lb, 0.0, 1.0), lq.z / lhw));
    }

    res = opU(res, layerPetals(p, 0.0, 15.0, 0.95, 0.170, 0.012, 0.000, -0.25, 0.90, 0.00, 3.1,  windT));
    res = opU(res, layerPetals(p, 1.0, 12.0, 0.80, 0.140, 0.011, 0.035, -0.05, 0.70, 0.35, 16.4, windT));
    res = opU(res, layerPetals(p, 2.0, 10.0, 0.66, 0.115, 0.010, 0.065, 0.15, 0.55, 0.70, 29.7, windT));
    res = opU(res, layerPetals(p, 3.0, 8.0,  0.52, 0.085, 0.009, 0.090, 0.40, 0.35, 1.05, 43.0, windT));
    res = opU(res, layerPetals(p, 4.0, 6.0,  0.40, 0.060, 0.008, 0.110, 0.65, 0.20, 1.40, 56.3, windT));

    float domeD = sdEllipsoidBound(p - vec3(0.0, 0.145, 0.0), vec3(0.15, 0.085, 0.15));
    res = opU(res, vec4(domeD, -3.0, 0.0, 0.0));

    return res;
}

vec3 calcNormal(vec3 p, float windT) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, windT).x - map(p - e.xyy, windT).x,
        map(p + e.yxy, windT).x - map(p - e.yxy, windT).x,
        map(p + e.yyx, windT).x - map(p - e.yyx, windT).x));
}

float calcAO(vec3 p, vec3 n, float windT) {
    float occ = 0.0, sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + n * h, windT).x;
        occ += (h - d) * sca;
        sca *= 0.6;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float calcShadow(vec3 ro, vec3 rd, float windT) {
    float res = 1.0, t = 0.02;
    for (int i = 0; i < 12; i++) {
        float h = map(ro + rd * t, windT).x;
        res = min(res, 12.0 * h / t);
        if (h < 0.001 || t > 4.0) break;
        t += clamp(h, 0.01, 0.15);
    }
    return clamp(res, 0.0, 1.0);
}

vec3 background(vec3 rd, float windT) {
    vec3 sky = mix(vec3(0.015, 0.008, 0.018), vec3(0.35, 0.13, 0.03), pow(clamp(rd.y * -0.35 + 0.42, 0.0, 1.0), 1.4));
    vec2 sph = vec2(atan(rd.z, rd.x), rd.y);
    float embers = 0.0;
    for (int i = 1; i <= 5; i++) {
        float fi = float(i);
        float h = hash12(vec2(fi, 17.3));
        vec2 cell = sph * vec2(6.0 + fi * 2.0, 10.0 + fi * 3.0) + vec2(windT * (0.1 + h * 0.2), windT * 0.05 * h);
        vec2 gv = fract(cell) - 0.5;
        float id = hash12(floor(cell));
        float dsize = 0.15 + 0.25 * id;
        embers += smoothstep(dsize, 0.0, length(gv)) * (0.3 + 0.7 * id);
    }
    sky += vec3(1.0, 0.5, 0.1) * embers * 0.5;
    return sky;
}

vec3 shade(vec3 p, vec3 nor, vec3 rd, vec4 hit, float windT) {
    float matId = hit.y;
    vec3 albedo = vec3(0.5);
    vec3 bumpN = nor;
    float gloss = 0.15;

    if (matId < -3.5) {
        albedo = mix(vec3(0.025, 0.018, 0.010), vec3(0.05, 0.035, 0.015), noise(p.xz * 3.0));
    } else if (matId < -2.5) {
        albedo = mix(vec3(0.85, 0.35, 0.05), vec3(1.0, 0.88, 0.35), 0.5 + 0.5 * nor.y);
        float sparkle = smoothstep(0.92, 1.0, hash12(floor(p.xz * 180.0) + floor(p.y * 180.0)));
        albedo += sparkle * vec3(1.0, 0.95, 0.7) * 0.6;
        gloss = 0.4;
        float bn = noise(p.xz * 60.0 + p.y * 60.0);
        bumpN = normalize(nor + vec3(bn - 0.5, 0.0, bn - 0.5) * 0.3);
    } else if (matId < -1.5) {
        float xn = hit.z;
        albedo = mix(vec3(0.05, 0.16, 0.025), vec3(0.11, 0.28, 0.05), xn);
        albedo += sin(hit.w * 20.0) * 0.04;
    } else if (matId < -0.5) {
        float xn = clamp((p.y + 1.3) / 1.3, 0.0, 1.0);
        albedo = mix(vec3(0.04, 0.10, 0.015), vec3(0.10, 0.20, 0.04), xn);
        albedo *= 0.85 + 0.3 * noise(p.xz * 40.0 + p.y * 10.0);
    } else {
        int idx = int(matId + 0.5);
        float xn = hit.z, wfrac = hit.w;
        vec3 cIn, cMid, cOut;
        if (idx == 0)      { cIn = vec3(0.42,0.04,0.015); cMid = vec3(0.92,0.32,0.03); cOut = vec3(1.0,0.70,0.22); }
        else if (idx == 1) { cIn = vec3(0.52,0.06,0.015); cMid = vec3(0.98,0.42,0.05); cOut = vec3(1.0,0.78,0.32); }
        else if (idx == 2) { cIn = vec3(0.64,0.09,0.02);  cMid = vec3(1.0, 0.52,0.09); cOut = vec3(1.0,0.84,0.42); }
        else if (idx == 3) { cIn = vec3(0.78,0.16,0.03);  cMid = vec3(1.0, 0.63,0.16); cOut = vec3(1.0,0.90,0.58); }
        else               { cIn = vec3(0.90,0.26,0.05);  cMid = vec3(1.0, 0.75,0.28); cOut = vec3(1.0,0.96,0.76); }

        albedo = mix(cIn, cMid, smoothstep(0.0, 0.55, xn));
        albedo = mix(albedo, cOut, smoothstep(0.45, 1.0, xn));

        float midrib = (1.0 - abs(wfrac)) * (1.0 - xn) * 0.5;
        float veins = sin(xn * 80.0 + wfrac * 20.0) * 0.03 * (1.0 - abs(wfrac));
        albedo += vec3(0.9, 0.35, 0.05) * midrib * 0.4 + vec3(1.0, 0.85, 0.5) * veins;

        float bumpAmt = (sin(xn * 80.0 + wfrac * 20.0) * 0.5 + sin(wfrac * 40.0) * 0.3) * 0.15;
        bumpN = normalize(nor + vec3(bumpAmt, 0.0, bumpAmt * 0.6));
        gloss = 0.2;
    }

    vec3 lightDir = normalize(vec3(0.5, 0.8, 0.35));
    float dif = clamp(dot(bumpN, lightDir), 0.0, 1.0);
    float sha = calcShadow(p + nor * 0.01, lightDir, windT);
    float ao = calcAO(p, nor, windT);
    float fres = pow(1.0 - clamp(dot(nor, -rd), 0.0, 1.0), 3.0);
    vec3 halfV = normalize(lightDir - rd);
    float spec = pow(clamp(dot(bumpN, halfV), 0.0, 1.0), 40.0) * gloss;
    float translucency = clamp(dot(-bumpN, lightDir), 0.0, 1.0) * 0.5;

    vec3 col = albedo * (0.18 * ao + dif * sha * 1.1 + translucency * vec3(1.0, 0.5, 0.15));
    col += spec * vec3(1.0, 0.95, 0.85) * sha;
    col += fres * vec3(1.0, 0.55, 0.15) * 0.25 * ao;

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    float windT = iTime;

    float period = 22.0;
    float ph = mod(iTime, period * 2.0) / period;
    float tri = ph < 1.0 ? ph : 2.0 - ph;
    float elevPhase = smoothstep(0.0, 1.0, tri);
    float elevAngle = mix(radians(8.0), radians(78.0), elevPhase);
    float orbitAngle = iTime * 0.12;
    float camDist = mix(2.6, 1.9, elevPhase);

    vec3 target = vec3(0.0, 0.55, 0.0);
    vec3 eye = target + camDist * vec3(cos(orbitAngle) * cos(elevAngle), sin(elevAngle), sin(orbitAngle) * cos(elevAngle));

    vec3 fwd = normalize(target - eye);
    vec3 right = normalize(cross(fwd, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, fwd);
    float fov = 1.35;
    vec3 rd = normalize(fwd * fov + uv.x * right + uv.y * up);
    vec3 ro = eye;

    float t = 0.0;
    vec4 res = vec4(1e5, -9.0, 0.0, 0.0);
    bool didHit = false;
    for (int i = 0; i < 59; i++) {
        vec3 p = ro + rd * t;
        res = map(p, windT);
        float eps = max(0.0015, t * 0.0015);
        if (res.x < eps) { didHit = true; break; }
        t += res.x * 0.7;
        if (t > 12.0) break;
    }

    vec3 col;
    if (didHit) {
        vec3 p = ro + rd * t;
        vec3 nor = calcNormal(p, windT);
        col = shade(p, nor, rd, res, windT);
    } else {
        col = background(rd, windT);
    }

    col = col / (col + vec3(1.0));
    col = pow(col, vec3(0.4545));
    col += hash12(fragCoord + iTime) * 0.004;

    fragColor = vec4(col, 1.0);
}
