// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCylinderX(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.yz), p.x)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCylinderZ(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xy), p.z)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCone(vec3 p, vec2 c, float h) {
    vec2 q = h * vec2(c.x / c.y, -1.0);
    vec2 w = vec2(length(p.xz), p.y);
    vec2 a = w - q * clamp(dot(w, q) / dot(q, q), 0.0, 1.0);
    vec2 b = w - q * vec2(clamp(w.x / q.x, 0.0, 1.0), 1.0);
    float k = sign(q.y);
    float d = min(dot(a, a), dot(b, b));
    float s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
    return sqrt(d) * sign(s);
}

float greebleNoise(vec3 p) {
    vec3 f = floor(p * 12.0);
    return sin(f.x * 13.0 + f.y * 37.0 + f.z * 51.0) * 0.5 + 0.5;
}

vec2 mapFalcon(vec3 p) {
    p.y *= 1.35;
    
    vec3 pHull = p;
    float hullCenter = length(pHull * vec3(1.0, 2.2, 0.95)) - 1.85;
    float topPillow = length(pHull * vec3(1.2, 3.5, 1.1) + vec3(0.0, 0.2, 0.0)) - 1.45;
    float hullMain = min(hullCenter, topPillow);
    
    vec3 pMand = p;
    pMand.x = abs(pMand.x);
    vec3 pProng = pMand - vec3(0.82, -0.05, 1.65);
    pProng.xy *= rot(0.05);
    float mandible = sdBox(pProng, vec3(0.38, 0.22, 1.25));
    
    vec3 pNotch = pMand - vec3(0.0, -0.05, 1.7);
    float notchCut = sdBox(pNotch, vec3(0.48, 0.5, 1.3));
    mandible = max(mandible, -notchCut);
    
    vec3 pMandSlope = pProng - vec3(0.0, 0.15, 0.4);
    pMandSlope.yz *= rot(-0.18);
    float mandBevel = sdBox(pMandSlope, vec3(0.4, 0.2, 1.0));
    mandible = max(mandible, -mandBevel);

    float body = min(hullMain, mandible);

    vec3 pCockpitArm = p - vec3(1.7, 0.05, 0.35);
    pCockpitArm.xz *= rot(-0.4);
    float tube = sdCylinderZ(pCockpitArm, 1.1, 0.32);

    vec3 pPod = p - vec3(2.15, 0.08, 0.95);
    float podBase = sdCylinderZ(pPod, 0.55, 0.38);
    
    vec3 pCone = pPod - vec3(0.0, 0.0, 0.55);
    float podCone = sdCone(pCone.xzy, vec2(0.38, 0.55), 0.55);
    float pod = min(podBase, podCone);

    vec3 pDishBase = p - vec3(-0.95, 0.62, -0.35);
    pDishBase.xz *= rot(0.35);
    float dishMount = sdCylinder(pDishBase, 0.18, 0.12);
    
    vec3 pDish = pDishBase - vec3(0.0, 0.22, 0.0);
    pDish.yz *= rot(-0.55);
    pDish.xy *= rot(0.2);
    float dishOuter = length(pDish * vec3(1.0, 2.5, 1.0)) - 0.52;
    float dishInner = length((pDish - vec3(0.0, 0.08, 0.0)) * vec3(1.0, 2.5, 1.0)) - 0.48;
    float dish = max(dishOuter, -dishInner);
    dish = min(dish, dishMount);

    vec3 pTurret = p;
    pTurret.y = abs(pTurret.y) - 0.52;
    pTurret.z += 0.1;
    float turretBase = sdCylinder(pTurret, 0.12, 0.38);
    vec3 pGun = pTurret;
    pGun.x = abs(pGun.x) - 0.12;
    float barrels = sdCylinderZ(pGun - vec3(0.0, 0.08, 0.25), 0.35, 0.035);
    float turret = min(turretBase, barrels);

    vec3 pDock = p;
    pDock.x = abs(pDock.x) - 1.75;
    pDock.z += 0.1;
    float dockRings = sdCylinderX(pDock, 0.15, 0.38);

    float structure = min(body, tube);
    structure = min(structure, pod);
    structure = min(structure, dish);
    structure = min(structure, turret);
    structure = min(structure, dockRings);

    vec3 pPanels = p;
    pPanels.x = abs(pPanels.x);
    float greeble = greebleNoise(pPanels) * 0.018;
    float panelLines = sin(pPanels.x * 24.0) * sin(pPanels.z * 24.0) * 0.008;
    
    structure -= (greeble + panelLines);

    vec3 pEngine = p - vec3(0.0, -0.02, -1.65);
    float engineBand = sdBox(pEngine, vec3(1.35, 0.11, 0.15));

    float matID = 1.0;
    if (engineBand < structure) {
        structure = engineBand;
        matID = 2.0;
    }

    return vec2(structure * 0.65, matID);
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        mapFalcon(p + e.xyy).x - mapFalcon(p - e.xyy).x,
        mapFalcon(p + e.yxy).x - mapFalcon(p - e.yxy).x,
        mapFalcon(p + e.yyx).x - mapFalcon(p - e.yyx).x
    ));
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = mapFalcon(p + h * n).x;
        occ += (h - d) * sca;
        sca *= 0.85;
    }
    return clamp(1.0 - 2.5 * occ, 0.0, 1.0);
}

float softShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 24; i++) {
        float h = mapFalcon(ro + rd * t).x;
        res = min(res, 12.0 * h / t);
        t += clamp(h, 0.02, 0.2);
        if (res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 renderSpace(vec3 rd) {
    float stars = pow(fract(sin(dot(rd, vec3(12.9898, 78.233, 45.164))) * 43758.5453), 32.0);
    stars *= step(0.985, stars);
    
    float nebula = sin(rd.x * 3.0 + iTime * 0.05) * cos(rd.y * 3.0) * sin(rd.z * 3.0);
    vec3 nebColor = mix(vec3(0.02, 0.05, 0.12), vec3(0.15, 0.04, 0.18), nebula * 0.5 + 0.5);
    
    return nebColor + vec3(stars * 1.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 m = iMouse.xy / iResolution.xy;

    float camDist = 6.5;
    float yaw = iTime * 0.35 + m.x * 6.28;
    float pitch = 0.35 + (m.y - 0.5) * 1.5;

    vec3 ro = vec3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * camDist;
    vec3 ta = vec3(0.0, 0.0, 0.2);

    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.6 * ww);

    float t = 0.0;
    float matID = 0.0;
    float engineGlowAcc = 0.0;

    for (int i = 0; i < 140; i++) {
        vec3 p = ro + rd * t;
        vec2 res = mapFalcon(p);
        
        vec3 pEng = p - vec3(0.0, -0.02, -1.65);
        float dEng = length(pEng) - 0.6;
        if (dEng < 1.2) {
            engineGlowAcc += (1.2 - dEng) * 0.015 / (1.0 + res.x * res.x * 20.0);
        }

        if (abs(res.x) < 0.0015 || t > 18.0) {
            matID = res.y;
            break;
        }
        t += res.x;
    }

    vec3 col = renderSpace(rd);

    if (t < 18.0) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        vec3 ref = reflect(rd, n);

        vec3 keyLightDir = normalize(vec3(1.2, 1.5, 0.8));
        vec3 fillLightDir = normalize(vec3(-1.0, -0.5, -0.5));

        float ao = calcAO(p, n);
        float shadow = softShadow(p + n * 0.01, keyLightDir, 0.05, 6.0);

        float NdotL = clamp(dot(n, keyLightDir), 0.0, 1.0);
        float NdotL_fill = clamp(dot(n, fillLightDir), 0.0, 1.0);
        float spec = pow(clamp(dot(ref, keyLightDir), 0.0, 1.0), 32.0);

        vec3 baseHullColor = vec3(0.72, 0.70, 0.66);
        
        float panelNoise = greebleNoise(p * 2.0);
        if (panelNoise > 0.65) baseHullColor *= vec3(0.65, 0.25, 0.2);
        else if (panelNoise < 0.2) baseHullColor *= vec3(0.45, 0.48, 0.52);

        if (matID == 2.0) {
            vec3 engineBlue = vec3(0.3, 0.75, 1.0) * 4.5;
            col = engineBlue;
        } else {
            vec3 ambient = vec3(0.04, 0.06, 0.1) * baseHullColor * ao;
            vec3 diffuse = keyLightDir.y * baseHullColor * NdotL * shadow * vec3(1.1, 1.05, 0.95);
            vec3 fill = baseHullColor * NdotL_fill * 0.25 * vec3(0.4, 0.5, 0.7) * ao;
            vec3 specular = vec3(1.0) * spec * shadow * 0.6;

            col = ambient + diffuse + fill + specular;

            vec3 env = renderSpace(ref);
            col += env * 0.12 * ao;
        }

        col = mix(col, renderSpace(rd), 1.0 - exp(-0.0003 * t * t * t));
    }

    col += vec3(0.2, 0.65, 1.0) * engineGlowAcc * 2.2;

    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
