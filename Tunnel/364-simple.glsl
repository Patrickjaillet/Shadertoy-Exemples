// ==== Image (image) ====
#define ITERATIONS 160
#define PI 3.14159265359
#define AMBIENT_OCCLUSION_STEPS 5
#define SHADOW_STEPS 30

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}
// https://github.com/Patrickjaillet/Z-GL
float sdCylinder(vec3 p, float r) {
    return length(p.xy) - r;
}

float pMod1(inout float p, float size) {
    float halfSize = size * 0.5;
    float c = floor((p + halfSize) / size);
    p = mod(p + halfSize, size) - halfSize;
    return c;
}

float gyroid(vec3 p) {
    return dot(sin(p), cos(p.zxy));
}

float fBm(vec3 p) {
    float d = 0.0;
    vec3 q = p * 1.2;
    float amplitude = 0.55;
    for(int i = 0; i < 5; i++) {
        d += amplitude * gyroid(q);
        q *= 1.95;
        q.xy *= rot(0.5);
        amplitude *= 0.48;
    }
    return d;
}

float map(vec3 p, out vec3 cellColor, out float matID) {
    float time = iTime * 0.25;
    
    float pathX = sin(p.z * 0.12) * 1.8 + cos(p.z * 0.05) * 1.2;
    float pathY = cos(p.z * 0.15) * 1.4 + sin(p.z * 0.07) * 0.9;
    p.x -= pathX;
    p.y -= pathY;
    
    p.xy *= rot(p.z * 0.04 + time * 0.08);
    
    float angle = atan(p.y, p.x);
    float sectorCount = 12.0;
    float sectorAngle = (2.0 * PI) / sectorCount;
    float sector = round(angle / sectorAngle);
    float diff = angle - sector * sectorAngle;
    
    vec3 pSub = p;
    pSub.xy = vec2(cos(diff), sin(diff)) * length(p.xy);
    
    float mainRadius = 4.5 + sin(p.z * 0.25 + time * 1.5) * 0.4;
    float mainTunnel = -sdCylinder(p, mainRadius);
    
    float disp = fBm(p * 0.55 + vec3(0.0, 0.0, -time * 0.8)) * 0.95;
    mainTunnel += disp;
    
    pSub.x -= mainRadius - 0.2;
    float cellZ = pMod1(pSub.z, 2.5);
    pSub.x -= sin(cellZ * 3.0 + time) * 0.15;
    
    float strut = length(pSub.xy) - 0.08;
    strut = max(strut, -mainTunnel - 0.2);
    
    float ringGeometry = length(pSub) - 0.28;
    ringGeometry = max(ringGeometry, -mainTunnel - 0.1);
    
    float d = min(mainTunnel, ringGeometry);
    d = min(d, strut);
    
    vec3 colDeep = vec3(0.01, 0.45, 1.0);
    vec3 colMid  = vec3(0.85, 0.02, 0.95);
    vec3 colHot  = vec3(1.0, 0.45, 0.0);
    
    float wave = sin(p.z * 0.15 - time * 2.0) * 0.5 + 0.5;
    vec3 baseColor = mix(colDeep, colMid, wave);
    baseColor = mix(baseColor, colHot, clamp(disp * 0.8 + 0.2, 0.0, 1.0));
    
    if (d == ringGeometry) {
        matID = 1.0;
        float pulse = sin(cellZ * 1.5 + p.z * 4.0 - time * 12.0) * 0.5 + 0.5;
        cellColor = mix(vec3(4.0, 0.8, 0.1), vec3(0.1, 2.5, 4.0), sin(cellZ) * 0.5 + 0.5) * pow(pulse, 4.0);
    } else if (d == strut) {
        matID = 2.0;
        cellColor = vec3(0.05, 0.08, 0.12);
    } else {
        matID = 0.0;
        cellColor = baseColor * (1.0 + abs(disp) * 3.0);
    }
    
    return d;
}

vec3 getNormal(vec3 p) {
    vec3 dummyCol; float dummyID;
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, dummyCol, dummyID) - map(p - e.xyy, dummyCol, dummyID),
        map(p + e.yxy, dummyCol, dummyID) - map(p - e.yxy, dummyCol, dummyID),
        map(p + e.yyx, dummyCol, dummyID) - map(p - e.yyx, dummyCol, dummyID)
    ));
}

float getShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t = mint;
    vec3 dummyCol; float dummyID;
    for(int i = 0; i < SHADOW_STEPS; i++) {
        float h = map(ro + rd * t, dummyCol, dummyID);
        if(h < 0.001) return 0.0;
        res = min(res, 8.0 * h / t);
        t += clamp(h, 0.02, 0.5);
        if(t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    vec3 dummyCol; float dummyID;
    for(int i = 1; i <= AMBIENT_OCCLUSION_STEPS; i++) {
        float hr = 0.06 * float(i);
        vec3 aopos = n * hr + p;
        float dd = map(aopos, dummyCol, dummyID);
        occ += -(dd - hr) * sca;
        sca *= 0.75;
    }
    return clamp(1.0 - occ * 0.85, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime * 0.25;
    
    vec3 ro = vec3(0.0, 0.0, time * 5.0);
    float currentPathX = sin(ro.z * 0.12) * 1.8 + cos(ro.z * 0.05) * 1.2;
    float currentPathY = cos(ro.z * 0.15) * 1.4 + sin(ro.z * 0.07) * 0.9;
    ro.x += currentPathX;
    ro.y += currentPathY;
    
    vec3 lookAt = vec3(0.0, 0.0, ro.z + 6.0);
    lookAt.x += sin(lookAt.z * 0.12) * 1.8 + cos(lookAt.z * 0.05) * 1.2;
    lookAt.y += cos(lookAt.z * 0.15) * 1.4 + sin(lookAt.z * 0.07) * 0.9;
    
    vec3 forward = normalize(lookAt - ro);
    vec3 right = normalize(cross(vec3(sin(time * 0.2) * 0.2, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);
    rd.xy *= rot(time * 0.05);
    
    float tMax = 65.0;
    float tDist = 0.02;
    
    vec3 accumGlow = vec3(0.0);
    vec3 hitColor = vec3(0.0);
    vec3 sceneColor = vec3(0.0);
    float matID = 0.0;
    bool hit = false;
    vec3 p = vec3(0.0);
    
    for(int i = 0; i < ITERATIONS; i++) {
        p = ro + rd * tDist;
        float d = map(p, hitColor, matID);
        
        float vGlow = exp(-abs(d) * 5.0);
        accumGlow += hitColor * vGlow * (1.0 / (1.0 + tDist * tDist * 0.015));
        
        if(abs(d) < 0.0008) {
            hit = true;
            break;
        }
        if(tDist > tMax) break;
        
        tDist += d * 0.52;
    }
    
    if(hit) {
        vec3 normal = getNormal(p);
        vec3 lightPos = ro + vec3(0.0, 0.0, 3.0);
        vec3 lightDir = normalize(lightPos - p);
        
        float diff = max(dot(normal, lightDir), 0.0);
        vec3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(-rd, reflectDir), 0.0), 40.0);
        
        float ao = getAO(p, normal);
        float shadow = getShadow(p, lightDir, 0.04, 4.0);
        float fresnel = pow(clamp(1.0 + dot(rd, normal), 0.0, 1.0), 4.5);
        
        if (matID == 1.0) {
            sceneColor = hitColor * 2.5;
        } else if (matID == 2.0) {
            sceneColor = hitColor * (diff * shadow + 0.1) * ao;
            sceneColor += vec3(0.8, 0.95, 1.0) * spec * shadow * 0.8;
            sceneColor += vec3(0.1, 0.5, 1.0) * fresnel * ao * 1.2;
        } else {
            sceneColor = hitColor * (diff * shadow * 0.7 + 0.15) * ao;
            sceneColor += vec3(1.0, 0.7, 0.9) * spec * shadow * 1.2;
            sceneColor += hitColor * fresnel * ao * 1.8;
        }
        
        sceneColor = mix(sceneColor, vec3(0.0), 1.0 - exp(-0.0004 * tDist * tDist * tDist));
    }
    
    sceneColor += accumGlow * 0.16;
    
    float centerGlow = exp(-length(uv) * 3.8);
    sceneColor += vec3(1.0, 0.65, 0.35) * centerGlow * 2.5;
    
    sceneColor = sceneColor / (sceneColor + vec3(1.0));
    sceneColor = pow(sceneColor, vec3(1.0 / 2.2));
    
    fragColor = vec4(sceneColor, 1.0);
}
