// ==== Image (image) ====
/***********************************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____                       *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \                      *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |                     *
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |                     *
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/                      *
*            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]                                 *
************************************************************************************
* - Software:       https://patrickjaillet.github.io/sandefjord-software           *
* - Social Network: https://x.com/JailletPatrick                                   *
* - Music:          https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g       *
************************************************************************************
*           Software used for GLSL shader creation:                                *
*                ******************************                                    *
* GLSL shader design and value tweaking                                            *
* - Sliders-GL v1.0.1:                                                             *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl *
*                                                                                  *
* 100% safe Code Golfing                                                           *
* - µShader v3.0.1:                                                                *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader*
*                                                                                  *
* Formatting & Layout                                                              *                 
* - ShaderFmt v1.0.0:                                                              *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt  *
***********************************************************************************/
float bayer4x4(vec2 p) {
    vec4 m0 = vec4( 0.0,  8.0,  2.0, 10.0) / 16.0;
    vec4 m1 = vec4(12.0,  4.0, 14.0,  6.0) / 16.0;
    vec4 m2 = vec4( 3.0, 11.0,  1.0,  9.0) / 16.0;
    vec4 m3 = vec4(15.0,  7.0, 13.0,  5.0) / 16.0;
    ivec2 ip = ivec2(mod(p, 4.0));
    if(ip.y == 0) return (ip.x == 0) ? m0.x : (ip.x == 1) ? m0.y : (ip.x == 2) ? m0.z : m0.w;
    if(ip.y == 1) return (ip.x == 0) ? m1.x : (ip.x == 1) ? m1.y : (ip.x == 2) ? m1.z : m1.w;
    if(ip.y == 2) return (ip.x == 0) ? m2.x : (ip.x == 1) ? m2.y : (ip.x == 2) ? m2.z : m2.w;
    return (ip.x == 0) ? m3.x : (ip.x == 1) ? m3.y : (ip.x == 2) ? m3.z : m3.w;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 crt = uv - 0.5;
    crt *= 1.0 + dot(crt, crt) * 0.18;
    crt += 0.5;

    if(crt.x < 0.0 || crt.x > 1.0 || crt.y < 0.0 || crt.y > 1.0) {
        fragColor = vec4(0.02, 0.02, 0.025, 1.0);
        return;
    }

    vec2 lowRes = vec2(320.0, 224.0);
    vec2 pixelUV = (floor(crt * lowRes) + 0.5) / lowRes;

    vec3 col = vec3(0.0);
    col.r = texture(iChannel0, pixelUV + vec2(0.003, 0.0)).r;
    col.g = texture(iChannel0, pixelUV).g;
    col.b = texture(iChannel0, pixelUV - vec2(0.003, 0.0)).b;

    vec3 blur = vec3(0.0);
    blur += texture(iChannel0, pixelUV + vec2(-0.004, 0.0)).rgb * 0.25;
    blur += texture(iChannel0, pixelUV + vec2( 0.004, 0.0)).rgb * 0.25;
    col = mix(col, blur, 0.35);

    float dither = (bayer4x4(fragCoord) - 0.5) * (1.0 / 16.0);
    col += dither;
    col = floor(col * 15.0 + 0.5) / 15.0;

    float scanline = sin(crt.y * lowRes.y * 3.14159265);
    scanline = 0.65 + 0.35 * pow(abs(scanline), 1.5);
    col *= scanline;

    float subpixel = mod(fragCoord.x, 3.0);
    vec3 mask = vec3(1.2, 0.7, 0.7);
    if(subpixel > 1.0) mask = vec3(0.7, 1.2, 0.7);
    if(subpixel > 2.0) mask = vec3(0.7, 0.7, 1.2);
    col *= mask;

    vec3 bloom = vec3(0.0);
    for(float x = -2.0; x <= 2.0; x += 1.0) {
        for(float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * 0.005;
            bloom += max(texture(iChannel0, crt + offset).rgb - 0.6, 0.0);
        }
    }
    col += bloom * 0.18;

    float vig = 1.0 - pow(length(uv - 0.5) * 1.35, 3.5);
    col *= clamp(vig, 0.0, 1.0);

    col = pow(max(col, 0.0), vec3(0.4545));
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
float getPathX(float z) {
    return sin(z * 0.0035) * 180.0 + sin(z * 0.0012) * 280.0 + cos(z * 0.0022) * 110.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float btCycle = 13.0;
    float btSlot = floor(iTime / btCycle);
    float btLocal = mod(iTime, btCycle);
    float btHash = fract(sin(btSlot * 91.345) * 43758.5453);
    float btActive = (btHash > 0.45) ? smoothstep(1.5, 3.5, btLocal) * (1.0 - smoothstep(6.5, 8.5, btLocal)) : 0.0;

    float speedFactor = mix(150.0, 15.0, btActive);
    float speed = iTime * speedFactor;
    
    float posX = getPathX(speed);
    float posXNext = getPathX(speed + 15.0);
    float pathDx = (posXNext - posX) / 15.0;
    
    vec3 ro = vec3(posX, 18.0, speed);
    vec3 rd = normalize(vec3(uv, 0.85));
    
    float yaw = atan(pathDx * 0.95);
    float roll = sin(iTime * 1.2) * 0.35 - pathDx * 0.85;
    
    mat2 rY = mat2(cos(yaw), sin(yaw), -sin(yaw), cos(yaw));
    mat2 rZ = mat2(cos(roll), -sin(roll), sin(roll), cos(roll));
    
    rd.xz *= rY;
    rd.xy *= rZ;

    float t = 0.0;
    float matID = 0.0;
    for(int i = 0; i < 120; i++) {
        vec3 p = ro + rd * t;
        float cX = getPathX(p.z);
        float canyon = abs(p.x - cX) - 65.0 + sin(p.z * 0.015) * 20.0;
        float seaWaves = sin(p.x * 0.4 + iTime * 4.0) * cos(p.z * 0.2 + iTime * 3.0) * 0.6;
        float ground = p.y + 12.0 + seaWaves;
        float walls = p.y + 50.0 - canyon;
        float detail = sin(p.x * 0.25) * cos(p.z * 0.25) * 2.5 + sin(p.x * 0.7) * 0.6;
        float d = min(ground, walls + detail);
        if(d < 0.01 || t > 900.0) {
            matID = (ground < (walls + detail)) ? 1.0 : 2.0;
            break;
        }
        t += d * 0.55;
    }

    vec3 col = mix(vec3(0.9, 0.55, 0.3), vec3(0.2, 0.45, 0.85), clamp(uv.y + 0.35, 0.0, 1.0));
    vec3 sunDir = normalize(vec3(0.1, 0.25, 0.95));
    float sun = max(dot(rd, sunDir), 0.0);
    col += vec3(1.0, 0.75, 0.3) * pow(sun, 48.0) + vec3(1.0, 0.9, 0.6) * pow(sun, 256.0);

    if(t < 900.0) {
        vec3 p = ro + rd * t;
        vec2 e = vec2(0.1, 0.0);
        
        float c0 = abs(p.x - getPathX(p.z)) - 65.0 + sin(p.z * 0.015) * 20.0;
        float w0 = sin(p.x * 0.4 + iTime * 4.0) * cos(p.z * 0.2 + iTime * 3.0) * 0.6;
        float d0 = min(p.y + 12.0 + w0, p.y + 50.0 - c0 + sin(p.x * 0.25) * cos(p.z * 0.25) * 2.5);
        
        float c1 = abs((p.x + e.x) - getPathX(p.z)) - 65.0 + sin(p.z * 0.015) * 20.0;
        float w1 = sin((p.x + e.x) * 0.4 + iTime * 4.0) * cos(p.z * 0.2 + iTime * 3.0) * 0.6;
        float d1 = min(p.y + 12.0 + w1, p.y + 50.0 - c1 + sin((p.x + e.x) * 0.25) * cos(p.z * 0.25) * 2.5);
        
        float c2 = abs(p.x - getPathX(p.z + e.x)) - 65.0 + sin((p.z + e.x) * 0.015) * 20.0;
        float w2 = sin(p.x * 0.4 + iTime * 4.0) * cos((p.z + e.x) * 0.2 + iTime * 3.0) * 0.6;
        float d2 = min(p.y + 12.0 + w2, p.y + 50.0 - c2 + sin(p.x * 0.25) * cos((p.z + e.x) * 0.25) * 2.5);
        
        vec3 n = normalize(vec3(d1 - d0, e.x, d2 - d0));
        float diff = max(dot(n, sunDir), 0.05);
        float amb = 0.3 + 0.7 * max(n.y, 0.0);
        
        if(matID < 1.5) {
            float grid = abs(fract(p.z * 0.08) - 0.5);
            vec3 waterCol = vec3(0.04, 0.22, 0.55);
            if(grid < 0.04) waterCol += vec3(0.1, 0.4, 0.8);
            col = waterCol * (diff * vec3(1.1, 0.95, 0.8) + amb * vec3(0.25, 0.35, 0.5));
            float spec = pow(max(dot(reflect(-sunDir, n), rd), 0.0), 32.0);
            col += vec3(0.5, 0.7, 1.0) * spec;
        } else {
            vec3 rockCol = mix(vec3(0.45, 0.22, 0.1), vec3(0.85, 0.55, 0.25), step(0.4, fract(p.y * 0.12)));
            col = rockCol * (diff * vec3(1.1, 0.95, 0.8) + amb * vec3(0.25, 0.35, 0.5));
        }
        
        float fog = 1.0 - exp(-t * 0.0018);
        vec3 skyCol = mix(vec3(0.9, 0.55, 0.3), vec3(0.2, 0.45, 0.85), clamp(uv.y + 0.35, 0.0, 1.0));
        col = mix(col, skyCol, fog);
    }

    fragColor = vec4(col, t);
}

// ==== Buffer B (buffer) ====
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float getPathX(float z) {
    return sin(z * 0.0035) * 180.0 + sin(z * 0.0012) * 280.0 + cos(z * 0.0022) * 110.0;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdPlayer(vec3 p) {
    vec3 s = p;
    s.x = abs(s.x);
    float body = length(p.xy * vec2(1.2, 1.8)) - 0.5;
    body = max(body, abs(p.z) - 3.2);
    vec3 wp = s;
    wp.z -= 0.2;
    float wings = max(abs(wp.y) - 0.06, abs(wp.x) - (4.2 - wp.z * 0.7));
    wings = max(wings, abs(wp.z) - 1.6);
    vec3 tp = s;
    tp.x -= 0.9;
    tp.z += 2.2;
    tp.xy *= mat2(0.866, -0.5, 0.5, 0.866);
    float tails = sdBox(tp, vec3(0.05, 1.2, 0.7));
    return min(body, min(wings, tails));
}

float sdEnemy(vec3 p) {
    vec3 s = p;
    s.x = abs(s.x);
    float body = length(p.xy * vec2(1.4, 1.4)) - 0.6;
    body = max(body, abs(p.z) - 2.8);
    vec3 wp = s;
    wp.z += 0.5;
    float wings = max(abs(wp.y) - 0.06, abs(wp.x) - (3.5 + wp.z * 0.6));
    wings = max(wings, abs(wp.z) - 1.4);
    vec3 tp = s;
    tp.z += 2.0;
    float tail = sdBox(tp, vec3(0.06, 1.4, 0.8));
    return min(body, min(wings, tail));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 bg = texture(iChannel0, fragCoord / iResolution.xy);
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float btCycle = 13.0;
    float btSlot = floor(iTime / btCycle);
    float btLocal = mod(iTime, btCycle);
    float btHash = hash11(btSlot * 91.345);
    float btActive = (btHash > 0.45) ? smoothstep(1.5, 3.5, btLocal) * (1.0 - smoothstep(6.5, 8.5, btLocal)) : 0.0;

    float speedFactor = mix(150.0, 15.0, btActive);
    float speed = iTime * speedFactor;
    float posX = getPathX(speed);
    float posXNext = getPathX(speed + 15.0);
    float pathDx = (posXNext - posX) / 15.0;

    float yaw = atan(pathDx * 0.95);
    float camRoll = sin(iTime * 1.2) * 0.35 - pathDx * 0.85;
    
    mat2 rCamZ = mat2(cos(camRoll), -sin(camRoll), sin(camRoll), cos(camRoll));
    mat2 rCamY = mat2(cos(yaw), sin(yaw), -sin(yaw), cos(yaw));
    mat2 rCamYInv = mat2(cos(yaw), -sin(yaw), sin(yaw), cos(yaw));
    mat2 rCamZInv = mat2(cos(camRoll), sin(camRoll), -sin(camRoll), cos(camRoll));

    vec3 ro = vec3(0.0, 0.0, 0.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    rd.xz *= rCamY;
    rd.xy *= rCamZ;

    float cycle = 6.0;
    float slot = floor(iTime / cycle);
    float tLocal = mod(iTime, cycle);
    float randVal = hash11(slot * 43.123);
    
    float trickT = (randVal > 0.45) ? smoothstep(0.8, 3.2, tLocal) : 0.0;
    
    float rollAngle = sin(iTime * 1.2) * 0.35 - pathDx * 1.45 + trickT * 6.2831853;
    float pitchAngle = sin(iTime * 1.5) * 0.3 + sin(trickT * 3.1415926) * 0.7;

    mat2 rJetZ = mat2(cos(rollAngle), -sin(rollAngle), sin(rollAngle), cos(rollAngle));
    mat2 rJetX = mat2(cos(pitchAngle), -sin(pitchAngle), sin(pitchAngle), cos(pitchAngle));
    mat2 rJetZInv = mat2(cos(-rollAngle), -sin(-rollAngle), sin(-rollAngle), cos(-rollAngle));
    mat2 rJetXInv = mat2(cos(-pitchAngle), -sin(-pitchAngle), sin(-pitchAngle), cos(-pitchAngle));

    float pX = clamp(sin(iTime * 1.5) * 4.0 - pathDx * 5.0, -8.0, 8.0);
    float pY = clamp(-1.8 + sin(rollAngle) * 1.0 + sin(pitchAngle) * 1.2, -4.5, 3.0);
    vec3 pPos = vec3(pX, pY, 12.0);

    float orbitAngle = btActive * sin(iTime * 0.8) * 1.25;
    mat2 rOrbit = mat2(cos(orbitAngle), -sin(orbitAngle), sin(orbitAngle), cos(orbitAngle));
    ro -= pPos;
    ro.xz *= rOrbit;
    ro += pPos;
    rd.xz *= rOrbit;

    float t = 0.0;
    int mat = 0;
    vec3 hitP = vec3(0.0);
    float explProgress = 0.0;
    float trailGlow = 0.0;
    float enemyLaserGlow = 0.0;
    vec3 hudTargetGlow = vec3(0.0);

    for(int i = 0; i < 95; i++) {
        vec3 p = ro + rd * t;
        float d = 9999.0;
        int curMat = 0;

        vec3 pp = p - pPos;
        pp.xy *= rJetZ;
        pp.yz *= rJetX;
        float dP = sdPlayer(pp);
        if(dP < d) { d = dP; curMat = 1; }

        for(int k = 0; k < 3; k++) {
            float fk = float(k);
            float eSlot = floor((iTime + fk * 1.83) / 2.6);
            float r1 = hash11(eSlot * 12.34 + fk * 5.67);
            float r2 = hash11(eSlot * 45.67 + fk * 8.91);
            float r3 = hash11(eSlot * 89.12 + fk * 3.45);
            float r4 = hash11(eSlot * 23.45 + fk * 6.78);

            float eSpeed = (65.0 + r3 * 35.0) * mix(1.0, 0.1, btActive);
            float tE = mod(iTime + fk * 1.83, 2.6) - r4 * 0.6;
            float ez = 170.0 - tE * eSpeed;

            float ex = clamp((r1 * 2.0 - 1.0) * 22.0 - pathDx * 10.0, -22.0, 22.0);
            float ey = (r2 * 2.0 - 1.0) * 6.0;
            vec3 ePos = vec3(ex, ey, ez);

            float mSide = (mod(fk, 2.0) == 0.0) ? -2.2 : 2.2;
            vec3 mStartRel = vec3(mSide, -0.4, 1.0);
            mStartRel.yz *= rJetXInv;
            mStartRel.xy *= rJetZInv;
            vec3 mStart = pPos + mStartRel;

            float mProgress = clamp((160.0 - ez) / 120.0, 0.0, 1.0);
            vec3 mPos = mix(mStart, ePos, mProgress);

            if(ez > 40.0) {
                vec3 ep = p - ePos;
                float dE = sdEnemy(ep);
                if(dE < d) { d = dE; curMat = 2; }

                if(mProgress > 0.05 && mProgress < 0.98) {
                    vec3 mp = p - mPos;
                    float dM = length(mp) - 0.35;
                    if(dM < d) { d = dM; curMat = 3; }
                }

                float sTime = tE * 3.5;
                float sIndex = floor(sTime);
                float sPhase = fract(sTime);
                float mSeed1 = hash11(sIndex * 17.89 + fk * 9.12);
                float mSeed2 = hash11(sIndex * 33.45 + fk * 4.56);
                float missAngle = mSeed1 * 6.2831853;
                float missDist = 6.5 + mSeed2 * 7.5;
                vec3 missOffset = vec3(cos(missAngle) * missDist, sin(missAngle) * missDist, (mSeed1 - 0.5) * 8.0);
                vec3 targetPos = pPos + missOffset;
                vec3 laserPos = mix(ePos, targetPos, sPhase);
                vec3 laserDir = normalize(targetPos - ePos);
                vec3 p1 = laserPos;
                vec3 p2 = laserPos - laserDir * 8.0;
                vec3 ba = p2 - p1;
                vec3 pa = p - p1;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                float distELaser = length(pa - ba * h);
                enemyLaserGlow += exp(-distELaser * 1.8) * 0.22 * step(35.0, ez);

            } else if(ez <= 40.0 && ez > 5.0) {
                float explTime = (40.0 - ez) / 35.0;
                vec3 ep = p - ePos;
                float radius = explTime * 14.0;
                float dExpl = length(ep) - radius + sin(ep.x * 2.5 + iTime * 16.0) * sin(ep.y * 2.5) * sin(ep.z * 2.5) * 1.8;
                dExpl *= 0.55;
                if(dExpl < d) { d = dExpl; curMat = 4; explProgress = explTime; }
            }

            if(mProgress > 0.05 && mProgress < 0.98) {
                vec3 lineVec = mPos - mStart;
                float lineLen = length(lineVec);
                vec3 lineDir = lineVec / max(lineLen, 0.001);
                float proj = clamp(dot(p - mStart, lineDir), 0.0, lineLen);
                vec3 closest = mStart + lineDir * proj;
                float distToTrail = length(p - closest);
                trailGlow += exp(-distToTrail * 1.8) * 0.15 * (proj / max(lineLen, 0.001));
            }
        }

        if(d < 0.01) { mat = curMat; hitP = p; break; }
        if(t > 300.0 || t > bg.a) break;
        t += d;
    }

    for(int k = 0; k < 3; k++) {
        float fk = float(k);
        float eSlot = floor((iTime + fk * 1.83) / 2.6);
        float r1 = hash11(eSlot * 12.34 + fk * 5.67);
        float r2 = hash11(eSlot * 45.67 + fk * 8.91);
        float r3 = hash11(eSlot * 89.12 + fk * 3.45);
        float r4 = hash11(eSlot * 23.45 + fk * 6.78);

        float eSpeed = (65.0 + r3 * 35.0) * mix(1.0, 0.1, btActive);
        float tE = mod(iTime + fk * 1.83, 2.6) - r4 * 0.6;
        float ez = 170.0 - tE * eSpeed;
        float ex = clamp((r1 * 2.0 - 1.0) * 22.0 - pathDx * 10.0, -22.0, 22.0);
        float ey = (r2 * 2.0 - 1.0) * 6.0;
        vec3 ePos = vec3(ex, ey, ez);

        vec3 eCam = ePos;
        eCam.xz *= rCamYInv;
        eCam.xy *= rCamZInv;

        if(eCam.z > 2.0 && ez > 40.0 && ez < 165.0) {
            vec2 targetUV = eCam.xy / eCam.z;
            vec2 dUV = uv - targetUV;
            float distToTarget = length(dUV);

            float lockPhase = clamp((165.0 - ez) / 35.0, 0.0, 1.0);
            float boxSize = mix(0.08, 0.035, lockPhase);

            vec2 absDUV = abs(dUV);
            float boxEdge = max(absDUV.x, absDUV.y);
            float boxLine = abs(boxEdge - boxSize);
            float cornerMask = step(boxSize * 0.45, min(absDUV.x, absDUV.y));
            float bracket = exp(-boxLine * 450.0) * cornerMask;

            float rotAng = iTime * 4.0 * (2.0 - lockPhase);
            mat2 rRot = mat2(cos(rotAng), -sin(rotAng), sin(rotAng), cos(rotAng));
            vec2 rotDUV = rRot * dUV;
            float diamond = abs(rotDUV.x) + abs(rotDUV.y);
            float diamondRing = exp(-abs(diamond - boxSize * 1.35) * 320.0) * (1.0 - lockPhase * 0.5);

            float centerDot = exp(-distToTarget * 350.0);

            vec3 pCam = pPos;
            pCam.xz *= rCamYInv;
            pCam.xy *= rCamZInv;
            vec2 playerScreenPos = pCam.xy / max(pCam.z, 0.1);
            vec2 lineVec = targetUV - playerScreenPos;
            float lineLen = length(lineVec);
            vec2 lineDir = lineVec / max(lineLen, 0.001);
            float lineProj = clamp(dot(uv - playerScreenPos, lineDir), 0.0, lineLen);
            float lineDist = length((uv - playerScreenPos) - lineDir * lineProj);
            float leadLine = exp(-lineDist * 350.0) * step(0.02, lineProj) * step(lineProj, lineLen - 0.03) * 0.45;

            vec3 lockCol = mix(vec3(1.0, 0.75, 0.1), vec3(1.0, 0.15, 0.1), lockPhase);
            float lockFlash = (lockPhase > 0.95) ? (0.75 + 0.25 * sin(iTime * 25.0)) : 1.0;

            float totalReticle = (bracket + diamondRing + centerDot * 1.5 + leadLine) * lockFlash;
            hudTargetGlow += lockCol * totalReticle * 2.8;
        }
    }

    vec3 col = bg.rgb;
    if(mat > 0 && t < bg.a) {
        vec3 sunDir = normalize(vec3(0.1, 0.25, 0.95));
        if(mat == 1) {
            vec3 n = normalize(hitP - pPos);
            float diff = max(dot(n, sunDir), 0.15);
            col = vec3(0.75, 0.8, 0.85) * diff + vec3(0.2, 0.3, 0.4);

            vec3 ex1Rel = vec3(-0.6, 0.0, -3.2);
            vec3 ex2Rel = vec3(0.6, 0.0, -3.2);
            ex1Rel.yz *= rJetXInv; ex1Rel.xy *= rJetZInv;
            ex2Rel.yz *= rJetXInv; ex2Rel.xy *= rJetZInv;

            vec3 ep1 = hitP - (pPos + ex1Rel);
            vec3 ep2 = hitP - (pPos + ex2Rel);
            if(length(ep1) < 0.6 || length(ep2) < 0.6) {
                col += vec3(0.3, 0.7, 1.0) * 4.0;
            }
        } else if(mat == 2) {
            vec3 n = normalize(hitP);
            float diff = max(dot(n, sunDir), 0.15);
            col = vec3(0.4, 0.15, 0.15) * diff + vec3(0.1, 0.05, 0.05);
        } else if(mat == 3) {
            col = vec3(5.0, 4.0, 1.5);
        } else if(mat == 4) {
            col = mix(vec3(6.0, 3.5, 0.8), vec3(0.8, 0.1, 0.0), explProgress);
        }
        col = mix(col, mix(vec3(0.9, 0.55, 0.3), vec3(0.2, 0.45, 0.85), clamp(uv.y + 0.35, 0.0, 1.0)), 1.0 - exp(-t * 0.0018));
    }

    col += vec3(1.0, 0.6, 0.2) * trailGlow;
    col += vec3(4.5, 0.3, 0.4) * enemyLaserGlow;
    col += hudTargetGlow;

    col = mix(col, vec3(col.r * 0.4 + col.g * 0.5 + col.b * 0.1, col.g * 0.8, col.b * 1.5), btActive * 0.55);

    vec2 radarUV = uv - vec2(0.62, -0.31);
    float radarDist = length(radarUV);
    float radarRadius = 0.14;

    if(radarDist < radarRadius + 0.012) {
        float ring = abs(radarDist - radarRadius) - 0.002;
        float borderGlow = exp(-max(ring, 0.0) * 150.0);

        if(radarDist < radarRadius) {
            vec3 radarBg = vec3(0.01, 0.06, 0.03);

            float gridX = exp(-abs(radarUV.x) * 350.0);
            float gridY = exp(-abs(radarUV.y) * 350.0);
            float c1 = exp(-abs(radarDist - radarRadius * 0.66) * 220.0);
            float c2 = exp(-abs(radarDist - radarRadius * 0.33) * 220.0);
            radarBg += vec3(0.04, 0.4, 0.12) * (gridX + gridY + c1 + c2 + 0.12);

            float sweepAngle = mod(-iTime * 3.5, 6.2831853);
            float ang = atan(radarUV.y, radarUV.x);
            float diffAng = mod(ang - sweepAngle + 6.2831853, 6.2831853);
            float sweep = exp(-diffAng * 1.8) * 0.35;
            radarBg += vec3(0.05, 0.6, 0.2) * sweep;

            float pDist = length(radarUV);
            float pGlow = exp(-pDist * 220.0);
            radarBg += vec3(0.2, 0.8, 1.0) * pGlow * 2.5;

            for(int k = 0; k < 3; k++) {
                float fk = float(k);
                float eSlot = floor((iTime + fk * 1.83) / 2.6);
                float r1 = hash11(eSlot * 12.34 + fk * 5.67);
                float r3 = hash11(eSlot * 89.12 + fk * 3.45);
                float r4 = hash11(eSlot * 23.45 + fk * 6.78);

                float eSpeed = (65.0 + r3 * 35.0) * mix(1.0, 0.1, btActive);
                float tE = mod(iTime + fk * 1.83, 2.6) - r4 * 0.6;
                float ez = 170.0 - tE * eSpeed;
                float ex = clamp((r1 * 2.0 - 1.0) * 22.0 - pathDx * 10.0, -22.0, 22.0);

                if(ez > 15.0 && ez < 185.0) {
                    vec2 eBlipPos = vec2((ex - pPos.x) * 0.0035, (ez - pPos.z - 20.0) * 0.0008);
                    float eBlipDist = length(radarUV - eBlipPos);

                    float eGlow = exp(-eBlipDist * 160.0);
                    float pulse = 0.8 + 0.4 * sin(iTime * 14.0 + fk * 2.1);
                    float warnRing = exp(-abs(eBlipDist - (0.008 + 0.006 * sin(iTime * 16.0))) * 250.0);

                    radarBg += vec3(1.0, 0.1, 0.05) * (eGlow * 4.0 + warnRing * 1.5) * pulse;
                }
            }

            col = mix(col, radarBg, 0.88);
        }

        col = mix(col, vec3(0.15, 0.95, 0.45), borderGlow * 0.95);
    }

    fragColor = vec4(col, t);
}

// ==== Sound (sound) ====
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float audioNoise(float p) {
    float i = floor(p);
    float f = fract(p);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash11(i), hash11(i + 1.0), u) * 2.0 - 1.0;
}

float getPathX(float z) {
    return sin(z * 0.0035) * 180.0 + sin(z * 0.0012) * 280.0 + cos(z * 0.0022) * 110.0;
}

vec2 mainSound(int samp, float time) {
    float btCycle = 13.0;
    float btSlot = floor(time / btCycle);
    float btLocal = mod(time, btCycle);
    float btHash = hash11(btSlot * 91.345);
    float btActive = (btHash > 0.45) ? smoothstep(1.5, 3.5, btLocal) * (1.0 - smoothstep(6.5, 8.5, btLocal)) : 0.0;

    float engine = 0.0;
    float missiles = 0.0;
    float explosions = 0.0;
    float enemyShots = 0.0;
    float lockBeep = 0.0;

    float speedFactor = mix(150.0, 15.0, btActive);
    float speed = time * speedFactor;
    float posX = getPathX(speed);
    float posXNext = getPathX(speed + 15.0);
    float pathDx = (posXNext - posX) / 15.0;

    float cycle = 6.0;
    float slot = floor(time / cycle);
    float tLocal = mod(time, cycle);
    float randVal = hash11(slot * 43.123);
    float trickT = (randVal > 0.45) ? smoothstep(0.8, 3.2, tLocal) : 0.0;

    float turnPitch = (1.0 + abs(pathDx) * 0.75) * mix(1.0, 0.35, btActive);
    float jetPitch = (1.0 + sin(trickT * 3.1415926) * 0.55) * turnPitch;
    float n1 = audioNoise(time * 750.0 * jetPitch);
    float n2 = audioNoise(time * 2200.0 * jetPitch);
    float sub = sin(6.2831853 * 50.0 * jetPitch * time + sin(time * 35.0) * 2.5);
    engine = (n1 * 0.35 + n2 * 0.25 + sub * 0.4) * (0.22 + 0.18 * sin(trickT * 3.1415926) + abs(pathDx) * 0.25);

    for(int k = 0; k < 3; k++) {
        float fk = float(k);
        float eSlot = floor((time + fk * 1.83) / 2.6);
        float r3 = hash11(eSlot * 89.12 + fk * 3.45);
        float r4 = hash11(eSlot * 23.45 + fk * 6.78);

        float eSpeed = (65.0 + r3 * 35.0) * mix(1.0, 0.1, btActive);
        float tE = mod(time + fk * 1.83, 2.6) - r4 * 0.6;
        float ez = 170.0 - tE * eSpeed;

        if(ez > 40.0 && ez < 165.0) {
            float lockFreq = mix((ez < 125.0) ? 2400.0 : 1600.0, 800.0, btActive);
            float pulseSpeed = mix((ez < 125.0) ? 18.0 : 9.0, 4.0, btActive);
            float beepPulse = step(0.6, sin(time * pulseSpeed * 6.2831853));
            float tone = sin(6.2831853 * lockFreq * time);
            lockBeep += tone * beepPulse * 0.05;
        }

        if(ez > 40.0 && ez < 150.0) {
            float sTime = tE * 3.5;
            float sPhase = fract(sTime);
            if(sPhase < 0.22) {
                float envLaser = exp(-sPhase * 28.0);
                float laserFreq = mix(1400.0 - sPhase * 4200.0, 400.0, btActive);
                float eLaserTone = sin(6.2831853 * laserFreq * time);
                enemyShots += eLaserTone * envLaser * 0.16;
            }
        }

        float launchZ = 160.0;
        float explZ = 40.0;

        float dtLaunch = (launchZ - ez) / max(eSpeed, 0.001);
        if(dtLaunch > 0.0 && dtLaunch < 0.45) {
            float envM = exp(-dtLaunch * 9.0);
            float freqM = mix(250.0 + dtLaunch * 2800.0, 100.0, btActive);
            float mNoise = audioNoise(time * freqM);
            float mTone = sin(6.2831853 * freqM * dtLaunch);
            missiles += (mNoise * 0.6 + mTone * 0.4) * envM * 0.35;
        }

        float dtExpl = (explZ - ez) / max(eSpeed, 0.001);
        if(dtExpl > 0.0 && dtExpl < 0.85) {
            float envE = exp(-dtExpl * 4.2);
            float lowBoom = sin(6.2831853 * max(10.0, mix(150.0 - dtExpl * 200.0, 30.0, btActive)) * dtExpl);
            float explNoise = audioNoise(time * (700.0 * exp(-dtExpl * 2.2) * mix(1.0, 0.25, btActive)));
            float distNoise = clamp(explNoise * 3.5, -1.0, 1.0);
            explosions += (lowBoom * 0.65 + distNoise * 0.45) * envE * 0.55;
        }
    }

    float mixSound = engine + missiles + explosions + enemyShots + lockBeep;
    mixSound = clamp(mixSound, -1.0, 1.0);

    return vec2(mixSound);
}
