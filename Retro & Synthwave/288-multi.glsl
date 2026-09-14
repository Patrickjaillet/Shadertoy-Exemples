// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float bass = texture(iChannel1, vec2(0.02, 0.25)).r;
    float kick = pow(texture(iChannel1, vec2(0.06, 0.25)).r, 2.2);
    float snare = pow(texture(iChannel1, vec2(0.25, 0.25)).r, 2.0);

    vec2 cc = fragCoord / iResolution.xy - 0.5;
    float distAmount = 0.12 + kick * 0.08 + snare * 0.05;
    vec2 distortedUV = 0.5 + cc * (1.0 + dot(cc, cc) * distAmount);

    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec2 quantUV = floor(distortedUV * vec2(320.0, 256.0)) / vec2(320.0, 256.0);

    float glitch = step(0.92, hash11(iTime * 12.0)) * (kick * 0.06 + snare * 0.04);
    vec2 uvR = quantUV + vec2(glitch + 0.006 * (1.0 + kick), 0.0);
    vec2 uvG = quantUV;
    vec2 uvB = quantUV - vec2(glitch + 0.006 * (1.0 + snare), 0.0);

    vec3 col;
    col.r = texture(iChannel0, uvR).r;
    col.g = texture(iChannel0, uvG).g;
    col.b = texture(iChannel0, uvB).b;

    vec3 bloom = vec3(0.0);
    float weightSum = 0.0;
    for(float i=-2.0; i<=2.0; i+=1.0) {
        for(float j=-2.0; j<=2.0; j+=1.0) {
            vec2 bUv = quantUV + vec2(i, j) * (0.0035 + kick * 0.002);
            bloom += texture(iChannel0, bUv).rgb;
            weightSum += 1.0;
        }
    }
    col += (bloom / weightSum) * (0.35 + kick * 0.65 + snare * 0.3);

    col.r = floor(col.r * 15.0 + 0.5) / 15.0;
    col.g = floor(col.g * 15.0 + 0.5) / 15.0;
    col.b = floor(col.b * 15.0 + 0.5) / 15.0;

    col *= sin(distortedUV.y * 256.0 * 3.14159) * 0.15 + 0.85;
    col *= 0.95 + 0.05 * sin(quantUV.x * 320.0 * 3.14159 * 2.0 + 1.57079);
    
    float scanline = sin(distortedUV.y * iResolution.y * 1.5 + iTime * 6.0);
    col *= 0.88 + 0.12 * scanline;

    float vignette = clamp(pow(16.0 * distortedUV.x * distortedUV.y * (1.0 - distortedUV.x) * (1.0 - distortedUV.y), 0.25), 0.0, 1.0);
    col = col * vignette + vec3(0.02, 0.03, 0.01) * vignette;

    fragColor = vec4(col, 1.0);
}

// ==== Common (common) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

mat3 rot3D(vec3 a) {
    float cx = cos(a.x), sx = sin(a.x);
    float cy = cos(a.y), sy = sin(a.y);
    float cz = cos(a.z), sz = sin(a.z);
    mat3 rx = mat3(1,0,0, 0,cx,-sx, 0,sx,cx);
    mat3 ry = mat3(cy,0,sy, 0,1,0, -sy,0,cy);
    mat3 rz = mat3(cz,-sz,0, sz,cz,0, 0,0,1);
    return rz * ry * rx;
}

float sdSegment(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void addLine(inout float d, vec3 p, vec3 a, vec3 b) {
    d = min(d, sdSegment(p, a, b));
}

void addSeg2D(inout float d, vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    d = min(d, length(pa - ba * h));
}

vec2 project3D(vec3 p, vec3 rotAng, vec3 pos, float fov) {
    p *= rot3D(rotAng);
    p += pos;
    return (p.xy / max(p.z + fov, 0.1));
}

// ==== Buffer A (buffer) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
void drawFaceDetails(inout float d, vec3 p, vec3 v0, vec3 v1, vec3 v2, vec3 v3, bool isPyramid) {
    vec3 c = (v0 + v1 + v2 + v3) * 0.25;
    if (isPyramid) {
        vec3 n = normalize(cross(v1 - v0, v2 - v0));
        vec3 apex = c + n * 0.6;
        addLine(d, p, v0, apex); addLine(d, p, v1, apex);
        addLine(d, p, v2, apex); addLine(d, p, v3, apex);
    } else {
        vec3 right = normalize(v1 - v0);
        vec3 up = normalize(v3 - v0);
        float r = 0.35; vec3 lastPt = vec3(0.0);
        for (int i = 0; i < 10; i++) {
            float angle = float(i) * 3.14159265 * 0.4;
            float rad = (i % 2 == 0) ? r : r * 0.4;
            vec3 pt = c + (right * cos(angle) + up * sin(angle)) * rad;
            if (i > 0) addLine(d, p, lastPt, pt);
            lastPt = pt;
        }
    }
}

float sceneSDF(vec3 p, float time) {
    float t = time * 1.2;
    p.xz *= rot(t * 0.7); p.xy *= rot(t * 0.9); p.yz *= rot(t * 0.5);
    vec3 v[8];
    v[0] = vec3(-0.6,-0.6,-0.6); v[1] = vec3( 0.6,-0.6,-0.6); v[2] = vec3( 0.6, 0.6,-0.6); v[3] = vec3(-0.6, 0.6,-0.6);
    v[4] = vec3(-0.6,-0.6, 0.6); v[5] = vec3( 0.6,-0.6, 0.6); v[6] = vec3( 0.6, 0.6, 0.6); v[7] = vec3(-0.6, 0.6, 0.6);
    float d = 1e5;
    addLine(d, p, v[0], v[1]); addLine(d, p, v[1], v[2]); addLine(d, p, v[2], v[3]); addLine(d, p, v[3], v[0]);
    addLine(d, p, v[4], v[5]); addLine(d, p, v[5], v[6]); addLine(d, p, v[6], v[7]); addLine(d, p, v[7], v[4]);
    addLine(d, p, v[0], v[4]); addLine(d, p, v[1], v[5]); addLine(d, p, v[2], v[6]); addLine(d, p, v[3], v[7]);
    drawFaceDetails(d, p, v[0], v[1], v[2], v[3], false); drawFaceDetails(d, p, v[5], v[4], v[7], v[6], false);
    drawFaceDetails(d, p, v[4], v[0], v[3], v[7], true);  drawFaceDetails(d, p, v[1], v[5], v[6], v[2], true);
    drawFaceDetails(d, p, v[3], v[2], v[6], v[7], false); drawFaceDetails(d, p, v[4], v[5], v[1], v[0], true);
    return d - 0.008;
}

vec3 renderCubeScene(vec2 fragCoord, vec2 res, float time) {
    vec2 uv = (fragCoord - 0.5 * res) / res.y;
    vec3 ro = vec3(0.0, 0.0, -3.2); vec3 rd = normalize(vec3(uv, 1.0));
    float t = 0.0; float minDist = 1e5;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t; float d = sceneSDF(p, time);
        minDist = min(minDist, d);
        if (d < 0.001 || t > 10.0) break;
        t += d * 0.5;
    }
    vec3 wireColor = 0.5 + 0.5 * cos(time * 2.0 + uv.xyx * 2.0 + vec3(0.0, 2.0, 4.0));
    vec3 col = wireColor * exp(-minDist * 18.0) * 1.2;
    if (minDist < 0.01) col += vec3(1.0) * smoothstep(0.01, 0.001, minDist);
    return col;
}

vec3 renderAmigaScene(vec2 fragCoord, vec2 res, float time, float bass, float mid, float high, float kick) {
    float introDuration = 5.0;
    if (time < introDuration) {
        float t = mod(time, 5.0), s = floor(time / 5.0);
        float h = fract(sin(s * 17.31) * 43758.54);
        float r = h < 0.2 ? 0.7 : h < 0.5 ? 0.5 : h < 0.8 ? 0.35 : 0.6;
        float i = h < 0.2 ? 2.4 : h < 0.5 ? 1.6 : h < 0.8 ? 0.9 : 2.0;
        float sr = h < 0.2 ? 12.0 : h < 0.5 ? 28.0 : h < 0.8 ? 50.0 : 18.0;
        float st = mod(t, i), ls = s * 100.0 + floor(t / i);
        float is = step(0.1, st) * (1.0 - step(i * r, st));
        float sm = mix(0.5, 2.5, is) * (sr / 24.0);
        float lsn = floor(fragCoord.y * 0.25) + floor(time * 60.0 * sm);
        float id = mod(floor(fract(sin(lsn) * 43758.54) * 16.0), 16.0);
        vec3 col = vec3(0.9, 0.5, 0.5);
        if (id < 1.0) col = vec3(0.0); else if (id < 2.0) col = vec3(0.0, 0.0, 0.4);
        else if (id < 3.0) col = vec3(0.8, 0.0, 0.0); else if (id < 4.0) col = vec3(0.0, 0.6, 0.8);
        else if (id < 5.0) col = vec3(0.8, 0.4, 0.0); else if (id < 6.0) col = vec3(0.0, 0.8, 0.2);
        else if (id < 7.0) col = vec3(0.9, 0.8, 0.0); else if (id < 8.0) col = vec3(0.2, 0.2, 0.8);
        else if (id < 9.0) col = vec3(0.9, 0.0, 0.9); else if (id < 10.0) col = vec3(0.0, 0.9, 0.9);
        else if (id < 11.0) col = vec3(0.9); else if (id < 12.0) col = vec3(0.4);
        else if (id < 13.0) col = vec3(0.6, 0.0, 0.4); else if (id < 14.0) col = vec3(0.2, 0.7, 0.4);
        vec2 p = floor(fragCoord / res * vec2(320.0, 256.0));
        if (step(0.0, st) * (1.0 - step(0.1, st)) > 0.5) {
            float f = fract(sin(p.x + p.y * 31.0 + time * 150.0) * 43758.54);
            col = mix(col, vec3(1.0), fract(sin(ls) * 43758.54) * 0.6 * step(0.5, f));
        }
        if (fract(st * sr * (0.8 + 0.4 * fract(sin(ls * 2.7) * 43758.54))) < 0.15 && is > 0.5) col += 0.2;
        col += sin(fragCoord.y * 0.5 + time * 40.0 * sm) * 0.12;
        vec2 q = fragCoord / res;
        col *= pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15);
        return col * smoothstep(introDuration, introDuration - 0.5, time);
    }
    float mainTime = time - introDuration;
    vec2 uv = (fragCoord - 0.5 * res) / res.y;
    float r = length(uv), a = atan(uv.y, uv.x);
    a += kick * 3.14159 * (1.0 - smoothstep(0.0, 0.6, r));
    float tau = 6.2831853; a = mod(a, tau / 6.0); a = abs(a - tau / 12.0);
    vec2 logPolar = vec2(log(r + 1e-5), a);
    logPolar.x += mainTime * 0.8 + kick * 0.5; logPolar.y += sin(mainTime * 0.5) * 0.2;
    float pattern = sin(logPolar.x * 10.0) * cos(logPolar.y * 12.0);
    pattern += sin((logPolar.x + logPolar.y) * 8.0 - mainTime * 2.0 + high * 3.0);
    pattern = step(0.0, pattern);
    vec2 grid = floor(logPolar * 8.0);
    float copper = sin(grid.y * 0.5 + mainTime * 3.0 + kick * 2.0) * 0.5 + 0.5;
    vec3 pal = mix(vec3(1.0, 0.0, 0.4), vec3(0.0, 0.8, 1.0), copper);
    pal = mix(pal, vec3(1.0, 0.9, 0.0), sin(mainTime + grid.x * 0.2 + mid) * 0.5 + 0.5);
    vec3 finalColor = pal * pattern;
    vec3 amPal[8] = vec3[8](vec3(0), vec3(0,0,0.8), vec3(0.8,0,0), vec3(0.8,0,0.8), vec3(0,0.8,0), vec3(0,0.8,0.8), vec3(0.8,0.8,0), vec3(1));
    float minDst = 10.0; vec3 qCol = vec3(0.0);
    for(int i=0; i<8; i++) { float d = distance(finalColor, amPal[i]); if(d < minDst) { minDst = d; qCol = amPal[i]; } }
    return qCol;
}

float getCubeAlpha(float time, float startTime, float duration, float transDur) {
    if (time >= startTime && time < startTime + duration) {
        float localTime = time - startTime;
        if (localTime < transDur) return localTime / transDur;
        else if (localTime > duration - transDur) return (duration - localTime) / transDur;
        return 1.0;
    }
    return 0.0;
}

vec3 renderS0(vec2 fc, vec2 res, float time, float bass, float kick) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float globalTime = time * 1.6;
    float zoom = 9.0 + cos(globalTime * 0.5) * 3.0 - bass * 2.0;
    float phi = 2.58, tau = 1.2;
    float accDist = 0.0;
    vec3 ro = vec3(uv * zoom, accDist + 0.2);
    float a = globalTime / 8.0;
    ro.yz *= rot(a); ro.xy *= rot(a);
    vec3 q = ro; q.yz += 0.6;
    vec3 rd = normalize(vec3(uv, 0.1));
    float e = 0.01; vec3 o = vec3(0.0);
    for (int step = 0; step < 60; step++) {
        vec3 p = q + rd * accDist;
        vec3 axis = normalize(vec3(5.4, sin(globalTime) + 7.0, 1.0));
        float c = cos(0.0), s = sin(0.0);
        p = p * c - cross(axis, p) * s + axis * dot(axis, p) * (1.0 - c);
        for (int j = 0; j < 4; j++) { p = 7.3 * clamp(p, -vec3(0.1), vec3(0.1)) - p; p /= max(dot(p, p), 1e-4); }
        float boxDist = 1e5, v = max(length(p), 1e-4);
        for(float j = 0.7; j < 6.0; j++) { vec2 pabs = abs(p.xz) - 1.0; boxDist = min(boxDist, max(max(pabs.x, pabs.y), 2.3 - p.y) / v); }
        float lenP = length(p.xz) + 1e-4, angleP = atan(p.z, p.x);
        float spiral = (log(lenP) / log(phi)) * phi - angleP / tau - globalTime;
        float pattern = 0.4, S = 1.0;
        for (int i = 0; i < 8; i++) {
            float fI = float(i) + 1.0; float cell = 0.5 - 0.5 * cos(spiral * fI * tau);
            pattern += exp(-6.0 * abs(cell) / S) * (1.0 / fI);
            spiral = log(length(vec2(cell, lenP)) + 0.1) * phi + angleP * phi;
            S *= 0.185;
        }
        e = clamp(abs(boxDist) * 0.1, 0.01, 0.18); accDist += e;
        o += 0.005 / exp(e * pattern * (20.0 - kick * 10.0));
    }
    return clamp(o, 0.0, 1.0);
}

vec3 renderS1(vec2 fc, vec2 res, float time, float mid, float high) {
    vec2 u = (fc * 2.0 - res) / res.y; float t = time * 0.4;
    vec3 ro = vec3(0.0, 0.0, -2.5), rd = normalize(vec3(u * 0.8, 1.0));
    rd.xy *= rot(t * 0.3);
    float acc = 0.0, accD = 0.0;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * accD;
        p.xy *= rot(p.z * 0.4 + t);
        p = abs(p) - 0.4; p.xy *= rot(p.z * 0.4 + t);
        float safeY = max(abs(p.y), 0.0001), safeS = max(1.0 + length(p.xy), 0.0001);
        accD += mod(length(p.yy), safeY) / safeS * 0.5;
        float d = max(length(p.xy) - 0.15 + sin(p.z * 8.0 + t * 2.0) * 0.03, 0.002);
        acc += exp(-d * (12.0 - mid * 4.0)) * (1.0 / (1.0 + accD * accD * 0.1));
        if (accD > 10.0) break;
    }
    vec3 baseCol = 0.5 + 0.5 * cos(t + accD * 0.2 + vec3(0.0, 2.0, 4.0));
    vec3 col = acc * 0.02 * mix(baseCol, vec3(0.1, 0.5, 1.0) + high, sin(accD * 2.0) * 0.5 + 0.5);
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    return pow(clamp(col, 0.0, 1.0), vec3(1.0 / 2.2));
}

vec3 renderS2(vec2 fc, vec2 res, float time, float high, float kick) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    mat2 r1 = rot(time * 0.2), r2 = rot(time * 0.15 + 0.3), ri = mat2(0.707, -0.707, 0.707, 0.707);
    vec3 col = vec3(0.1); float tD = 0.0;
    for (int i = 0; i < 32; i++) {
        vec3 p = vec3(uv * tD, tD); p.xz *= r1; p.yz *= r2; p.z += time * 0.6; p += 1.0;
        float minO = 9.0, fS = 9.0, sD = 0.0;
        for (int j = 0; j < 6; j++) {
            p = mod(p - 1.0, 2.0) - 1.0; p.yz *= ri;
            minO = min(minO, length(p));
            sD = dot(p, p) * 0.6; fS /= sD; p /= sD;
        }
        sD = 1.0 / fS; tD += sD;
        vec3 rgb = (2.6 + kick) * mix(vec3(1.0), clamp(abs(fract(fract(minO + tD * 0.08 + time * 0.04) + vec3(1, 0.66, 0.33)) * 20.0 - 3.0) - 1.0, 0.2, 1.0), 0.7);
        col += (0.014 + high * 0.02) / exp(sD * 1200.0 + tD * 0.15) * rgb;
    }
    col = (col * (2.51 * col + 0.03)) / (col * (1.68 * col + 0.59) + 0.14);
    return clamp(col, 0.0, 1.0);
}

vec2 s3_cp5(vec2 z) { float x2 = z.x*z.x, y2 = z.y*z.y; return vec2(z.x*(x2*x2 - 10.*x2*y2 + 5.*y2*y2), z.y*(5.*x2*x2 - 10.*x2*y2 + y2*y2)); }
vec2 s3_cp4(vec2 z) { float x2 = z.x*z.x, y2 = z.y*z.y; return vec2(x2*x2 - 6.*x2*y2 + y2*y2, 4.*z.x*z.y*(x2 - y2)); }
float s3_map(vec3 p, float t, float bass) {
    vec3 p0 = p; p *= 1.4; p.xz *= rot(t*0.15); p.yz *= rot(t*0.1); p.xy *= rot(sin(t*0.12)*1.5);
    vec3 ax = normalize(vec3(-4.0, sin(t)+7.0, 0.0));
    p = p * cos(t*0.5) - cross(ax, p) * sin(t*0.5) + ax * dot(ax, p) * (1.0 - cos(t*0.5));
    float w = (sin(t*0.32)+sin(t*0.41)*0.5+cos(t*0.28)*0.25)*1.5;
    vec2 v = s3_cp5(p.xy) + s3_cp5(vec2(p.z, w)) - vec2(sin(t*0.2)*1.8*cos(t*0.1), cos(t*0.17)*1.8*sin(t*0.19));
    vec2 d1 = s3_cp4(p.xy)*-4.2, d2 = s3_cp4(vec2(p.z, w))*5.0;
    float d = 0.5 * length(v) / sqrt(dot(d1,d1)+dot(d2,d2)+1e-4);
    d = (abs(d) - (0.065 + sin(t*0.45)*0.045 + bass*0.05)) / 0.8;
    float b = length(p0) - 2.1, k=0.1, h = clamp(0.5+0.5*(d-b)/k, 0.0, 1.0);
    return mix(b, d, h) + k*h*(1.0-h);
}
vec3 renderS3(vec2 fc, vec2 res, float t, float bass) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 vol = vec3(0.0); float rD = 0.0;
    vec3 sh = vec3(sin(t*0.4)*0.3+0.5, cos(t*0.3)*0.3+0.7, sin(t*0.5)*0.3+0.9);
    for (int i = 0; i < 16; i++) {
        vec3 vp = vec3(uv*(4.0+sin(t)), rD+0.1); vp.xy*=rot(t*0.25); vp.yz*=rot(t*0.18);
        float sc = 1.0;
        for (int j=0; j<5; j++) { vp = abs(vp)-sh; float f = max(0.8, 2.0/dot(vp,vp)); vp*=f; sc*=f; }
        rD += (length(vp.xy)/sc)*0.4;
        vec3 rgb = sc*0.0002*(1.+bass*5.) * mix(vec3(1.0), clamp(abs(mod((0.6+sin(t*0.1)*0.1)*6.+vec3(0,4,2), 6.0)-3.0)-1.0, 0.0, 1.0), 0.5);
        vol += rgb;
    }
    vec3 ro = vec3(0.0, 0.0, 3.9); vec3 p = vec3(uv*3.0, 0.5); p.xy *= rot(t*0.2);
    vec3 rd = normalize(p - ro);
    float dt = 0.0, d = 0.0, g = 0.0, aD = 0.0, aS = 0.0;
    for(int i=0; i<80; i++) {
        d = s3_map(ro + rd * dt, t, bass);
        if(abs(d)<0.001 || dt>10.0) break;
        dt+=d*0.8; aD+=abs(d); aS+=1.0/(0.01+abs(d)); g+=0.17/(0.2+abs(d));
    }
    vec3 rgb = (aS/4000.0) * mix(vec3(1.0), clamp(abs(mod(0.59*6.+vec3(0,4,2),6.)-3.)-1., 0.0, 1.0), 0.4-aD*0.05);
    vec3 col = (rgb + vol) * (1.0 - length(uv)*0.5);
    col += vec3(0.7, 0.2, 0.9)*g*0.0015 + vec3(0.1, 0.4, 0.9)*g*g*0.00005;
    return pow(col/(1.0+col), vec3(0.4545));
}

vec3 renderS4(vec2 fc, vec2 res, float time, float bass, float mid) {
    vec2 uv = (fc - res * 0.5) / res.y;
    vec3 ro = vec3(time * 0.4, 0.2 * sin(time * 0.3), time * 0.8);
    vec3 cz = normalize((ro + vec3(sin(time*0.15)*0.3, cos(time*0.1)*0.2, 1.0)) - ro);
    vec3 cx = normalize(cross(vec3(sin(time*0.1), 1.0, 0.0), cz));
    vec3 rd = normalize(uv.x * cx + uv.y * cross(cz, cx) + 0.8 * cz);
    mat3 rotfbm = mat3(cos(time*.1), sin(time*.1), 0, -sin(time*.1), cos(time*.1), 0, 0, 0, 1) * mat3(1, 0, 0, 0, cos(time*.1), sin(time*.1), 0, -sin(time*.1), cos(time*.1));
    float d = 0.0, tD = 0.01, g = 0.0; vec3 p;
    for (int i = 0; i < 80; i++) {
        p = ro + rd * tD;
        float d_inf = min(length(fract(p.xz)-0.5)-0.06, 0.35-abs(p.y));
        float m = 1.0, nz = 0.0; vec3 q = p * 1.2;
        for (int j=0; j<6; j++) { q = rotfbm*q; nz += dot(sin(q*m+vec3(time*1.5,time,time*0.8)), vec3(0.333))/m; m*=1.85; }
        d_inf -= abs(nz)*0.14*(1.0-smoothstep(0.2, 0.5, abs(p.y)));
        g += exp(-max(d_inf, 0.0)*12.0) * (0.015 + 0.01*sin(time+p.z) + mid*0.02);
        if (d_inf < 0.001 || tD > 15.0) { d=tD; break; }
        tD += d_inf * 0.45;
    }
    vec3 col = vec3(0.002, 0.005, 0.012) * (1.0 - length(uv) * 0.5) + vec3(0.1, 0.4, 0.8) * g;
    if (d > 0.0) {
        vec3 mat = mix(vec3(0.05, 0.1, 0.18), vec3(0.7, 0.85, 1.0), smoothstep(-0.1, 0.1, sin(p.z*4.)*cos(p.x*4.)));
        col = mix(mat * 0.3 + g*0.1, vec3(0.01), smoothstep(4.0, 15.0, d));
    }
    col += vec3(0.9, 0.4, 0.2) * pow(max(0.0, dot(rd, normalize(vec3(0.5, 0.2, 1.0)))), 8.0) * (0.3+bass*0.2);
    return clamp(pow(col, vec3(0.4545))*1.1-0.05, 0.0, 1.0);
}

mat3 s5_rot3D(float a, vec3 axis) {
    vec3 v = normalize(axis); float s = sin(a), c = cos(a), k = 0.4 - c;
    return mat3(k*v.x*v.x+c, k*v.y*v.x+v.z*s, k*v.z*v.x-v.y*s, k*v.x*v.y-v.z*s, k*v.y*v.y+c, k*v.z*v.y+v.x*s, k*v.x*v.z+v.y*s, k*v.y*v.z-v.x*s, k*v.z*v.z+c);
}
vec3 renderS5(vec2 fc, vec2 res, float time, float bass, float mid) {
    vec3 col = vec3(0.0); float g = 1.0, e = 0.0, s;
    mat3 m = s5_rot3D(2.8, vec3(2, 29, 2));
    for(float i=0.0; i<80.0; i++) {
        vec3 p = vec3((fc - 0.5*res)/res.y*14.0 + vec2(2,-1), g - 4.0) * m;
        p.xz *= rot(time * 0.9); s = 24.0;
        for(int j=0; j<25; j++) { p = vec3(2, 4.03, 2) - abs(abs(p)*e - vec3(7,8,3)); s*=e = 7.5/dot(p, p*0.66); }
        float intensity = clamp(log2(s)/40.0, 0.0, 1.0);
        vec3 fire = mix(vec3(0.2,0.01,0), mix(vec3(1.0,0.2,0.05), vec3(1.5,0.9,0.2), smoothstep(0.5,0.9,intensity)), smoothstep(0.1,0.5,intensity));
        col += fire * (intensity / 18.0) * (1.0 + mid + bass);
        g += 0.02;
    }
    return pow(col * 1.4, vec3(0.85));
}

vec3 renderS6(vec2 fc, vec2 res, float time, float high, float kick) {
    float a = 0.5 + sin(time * 0.25); mat2 r = rot(a + 1.0 - cos(a));
    vec3 cp = vec3(12.0*sin(time*0.25), 4.0*cos(time*0.5), time*2.0);
    vec3 fd = normalize(vec3(0.0, 0.0, time*2.0+5.0) - cp);
    vec3 rt = normalize(cross(fd, vec3(0,1,0))); vec3 up = cross(rt, fd);
    vec2 uv = fc - 0.5 * res; vec3 rd = normalize(uv.x*rt + uv.y*up + 1.2*res.y*fd);
    float tD = 0.0; vec3 p = cp; vec3 acc = vec3(0.0);
    for (int i = 0; i < 40; i++) {
        vec3 q = p; q.z = mod(q.z, 10.0) - 5.0; float sc = 1.0;
        for (int j = 0; j < 4; j++) {
            q = abs(q) - 1.0; q.xy *= r;
            float k = 1.2 / clamp(dot(q, q), 0.2, 1.0); q *= k; sc *= k;
        }
        float d = max(length(q.xz) / sc, 0.005);
        tD += d; p += d * rd;
        acc += (0.555 / exp(tD/20.0) / (6.0 + d*502.0)) * (1.0 + high + kick);
        if (tD > 25.0) break;
    }
    return acc;
}

float s7_B(vec3 a) { float d=0., e=.5; for(int i=0;i<6;i++){ d+=e*abs(dot(sin(a),cos(a.zxy))); a*=3.98; e*=.4; } return d; }
vec4 s7_j(vec3 a, float c, float bass) {
    float r = log(length(a)), x = atan(a.y, a.x);
    float g = s7_B(vec3(r-c, acos(a.z/max(length(a),.0001)), x) * 2.0);
    a += vec3(cos(g*6.28), sin(g*6.28), cos(g*3.14)) * 0.15;
    for(int i=0; i<2; i++) {
        float h=length(a.xy), k=atan(a.y, a.x)+c*.1+float(i)*.4;
        a.xy = abs(vec2(h*cos(k), h*sin(k))) - vec2(0, -.8); a.xy *= rot(.523);
        float t=length(a.xz), l=atan(a.z, a.x)-h*.15;
        a.xz = vec2(t*cos(l), t*sin(l)); a.yz = abs(a.yz) - vec2(0, .5); a.yz *= rot(.785);
    }
    float u = length(max(abs(a)-vec3(0,1,.3),0.))+min(max(abs(a).x,max(abs(a).y,abs(a).z)-vec3(0,1,.3).y),0.);
    float n = length(a.xy)-.05-g*.08;
    return vec4(min(u,n)*.3, (.15+.1*g)/(.05+n*n*15.) + .02/(.01+abs(u)), atan(a.y, a.x)+g*.5, length(a));
}
vec3 renderS7(vec2 fc, vec2 res, float time, float bass, float mid) {
    vec2 uv = (fc - res*0.5)/res.y; float c = time * 0.5;
    vec3 ro = vec3(1,0,-5.5), rd = normalize(vec3(uv, 1.5));
    ro.xz *= rot(c*.15); rd.xz *= rot(c*.15); ro.yz *= rot(c*.08); rd.yz *= rot(c*.08);
    float k = 0.1, t = 0.0, o = 1.0; vec3 v = vec3(0.0); vec4 h = vec4(0.0);
    for(int i = 0; i < 40; i++) {
        h = s7_j(ro + rd * k, c, bass);
        t += h.y * (h.x + 0.21);
        v += (0.5+0.5*cos(vec3(0,1.5,3)+(h.z*0.4+c*0.3)*6.28)) * h.y * 0.012 * o * (1.0+mid);
        if(h.x < 0.001 || k > 40.0) break;
        k += max(h.x, 0.01);
    }
    vec3 col = vec3(.002,.004,.008)*(1.+uv.y) + v * 1.6 + (0.5+0.5*cos(vec3(1,3,5)+c*0.2*6.28))*t*0.035;
    col = pow(col, vec3(0.4545)); return col*col*(3.6-2.4*col);
}

float s8_h12(vec2 p) { vec3 p3 = fract(vec3(p.xyx)*0.1031); p3+=dot(p3, p3.yzx+33.33); return fract((p3.x+p3.y)*p3.z); }
vec3 renderS8(vec2 fc, vec2 res, float time, float bass, float high) {
    vec2 p = floor(fc / res * vec2(320.0, 200.0));
    vec3 col = mix(vec3(0.62, 0.20, 0.05), vec3(0.95, 0.58, 0.25), clamp(p.y/180.0, 0.0, 1.0)) * (1.0 + bass*0.5*sin(time*10.0));
    if(mod(p.y, 2.0)<1.0) col*=0.92;
    float fh = 45.0 + floor(sin(floor(p.x/8.0)*12.3)*15.0);
    if(p.y < fh) { col = vec3(0.42, 0.1, 0.03); if(mod(p.x, 2.)<1. && mod(p.y, 3.)<1. && s8_h12(floor(p/vec2(2,3)))>0.4) col = vec3(0.95, 0.58, 0.25) + high; }
    float mh = 65.0 + floor(s8_h12(vec2(floor(p.x/24.0), 3.14))*75.0), inX = mod(p.x, 24.0);
    if(p.y < mh && inX > 0.0 && inX < 23.0) { col = (inX>12.)?vec3(0.22,0.04,0.02):vec3(0.42,0.1,0.03); if(mod(p.x,3.)<1. && mod(p.y,5.)<2. && s8_h12(floor(p/vec2(3,5)))>0.35) col = vec3(0.82,0.38,0.1)+high; }
    if(p.x>80. && p.x<145. && p.y<200.) col = (p.x>110.)?vec3(0.08,0.01,0.01):vec3(0.22,0.04,0.02);
    if(abs(p.x-104.)<1. || abs(p.x-216.)<1.) col = vec3(0.28,0.58,0.82);
    vec2 pt = p - vec2(100, 42);
    if(pt.x>=0. && pt.x<=120. && pt.y>=0. && pt.y<=22.) {
        if(pt.y<=3.) col=vec3(0.98,0.78,0.42);
        else if(pt.x<=2. || pt.x>=118. || abs(pt.x-60.)<=1. || abs(pt.y-12.)<=1. || abs(pt.y-22.)<=1.) col=vec3(0.28,0.58,0.82);
        if(pt.x>=92. && pt.x<=112. && pt.y>=4. && pt.y<=16.) col=vec3(0.92);
    }
    vec2 grid = mod(p, vec2(32.0)); if(grid.x<2. || grid.y<2.) col*=0.25;
    return col;
}

vec3 renderS9(vec2 fc, vec2 res, float time, float bass, float mid) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float t = time * 2.0 + bass;
    float x = uv.x + sin(uv.y * 3.0 + t) * 0.3;
    float tw = sin(uv.y * 5.0 - t * 1.5) * 0.5 + 0.5;
    float w = 0.4 + mid * 0.1;
    float mask = smoothstep(w+0.01, w, abs(x));
    vec3 col = mix(vec3(0.0), mix(vec3(0.8,0.1,0.2), vec3(0.2,0.5,0.9), step(0.5, fract(uv.y * 4.0 + tw))), mask);
    col += vec3(1.0) * smoothstep(w-0.05, w, abs(x)) * mask;
    return col;
}

vec3 renderS10(vec2 fc, vec2 res, float time, float bass, float kick) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 ro = vec3(time, 2.0 + kick, time);
    vec3 rd = normalize(vec3(uv, 1.0));
    rd.xy *= rot(sin(time*0.5)*0.2);
    rd.xz *= rot(sin(time*0.3)*0.2);
    float d = 0.0;
    for(int i=0; i<40; i++) {
        vec3 p = ro + rd * d;
        float h = sin(p.x)*cos(p.z) + sin(p.x*0.5)*0.5;
        float dist = p.y - h;
        if(dist < 0.01) break;
        d += dist * 0.5;
    }
    vec3 p = ro + rd * d;
    vec3 col = mix(vec3(0.1, 0.8, 0.4), vec3(0.0, 0.2, 0.6), fract(floor(p.x)+floor(p.z))*0.5) * (1.0+bass);
    return col * exp(-d * 0.1);
}

vec3 renderS11(vec2 fc, vec2 res, float time, float bass, float high) {
    vec2 uv = fc / res * 4.0;
    float t = time + bass;
    float v = sin(uv.x + t) + sin(uv.y + t) + sin(uv.x * uv.y + t);
    v += sin(length(uv - vec2(2.0)) * 2.0 - t * 2.0);
    vec3 col = 0.5 + 0.5 * cos(3.14159 * v + vec3(0, 2, 4) + high);
    return col;
}

vec3 renderS12(vec2 fc, vec2 res, float time, float bass, float mid) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float a = atan(uv.y, uv.x);
    float r = length(uv);
    vec2 tuv = vec2(1.0 / r + time * 2.0 + bass, a / 3.14159);
    float c = mod(floor(tuv.x * 5.0) + floor(tuv.y * 8.0), 2.0);
    vec3 col = mix(vec3(0.8, 0.0, 0.4), vec3(0.1, 0.8, 0.9), c);
    return col * r * (1.0 + mid);
}

vec3 renderS13(vec2 fc, vec2 res, float time, float kick) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float z = sin(time * 0.5) * 0.5 + 1.0 - kick * 0.5;
    uv *= rot(time);
    uv *= z * 10.0;
    float c = mod(floor(uv.x) + floor(uv.y), 2.0);
    float c2 = mod(floor(uv.x*0.5) + floor(uv.y*0.5), 2.0);
    return mix(vec3(0.9, 0.4, 0.1), vec3(0.2, 0.1, 0.8), abs(c-c2));
}

vec3 renderS14(vec2 fc, vec2 res, float time, float bass, float high) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float v = 0.0;
    for(int i=0; i<5; i++) {
        float fi = float(i);
        vec2 p = vec2(sin(time + fi)*0.8, cos(time * 1.3 + fi * 2.0)*0.5);
        v += 0.05 / (length(uv - p) + 0.001);
    }
    float m = smoothstep(0.8, 0.9, v) - smoothstep(0.9, 1.0, v);
    vec3 col = mix(vec3(0.1,0.0,0.2), vec3(1.0,0.5,0.0)*(1.+bass), smoothstep(0.5, 1.0, v));
    col += m * vec3(1.0, 1.0, 1.0) * (1.0 + high);
    return col;
}

vec3 renderS15(vec2 fc, vec2 res, float time, float kick, float mid) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 col = vec3(0.0);
    for(float x=-1.0; x<=1.0; x+=0.5) {
        for(float y=-1.0; y<=1.0; y+=0.5) {
            for(float z=-1.0; z<=1.0; z+=0.5) {
                vec3 p = vec3(x, y, z);
                p.xy *= rot(time); p.xz *= rot(time * 0.7);
                float r = 0.05 + kick * 0.02;
                float d = length(uv - p.xy);
                col += vec3(0.2+p.x, 0.5+p.y, 0.8+p.z) * smoothstep(r, r*0.9, d) * exp(-p.z * 2.0) * (1.0 + mid);
            }
        }
    }
    return col;
}

vec3 renderS16(vec2 fc, vec2 res, float time, float bass) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec2 z = uv * (1.5 - bass*0.5);
    vec2 c = vec2(sin(time*0.5)*0.6, cos(time*0.3)*0.6);
    float i;
    for(i = 0.0; i < 32.0; i++) {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
        if(dot(z,z) > 4.0) break;
    }
    return 0.5 + 0.5 * cos(i * 0.2 + time + vec3(0,1,2));
}

vec3 renderS17(vec2 fc, vec2 res, float time, float high) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float d1 = length(uv - vec2(sin(time), cos(time))*0.3);
    float d2 = length(uv + vec2(sin(time*1.2), cos(time*0.8))*0.3);
    float m = sin(d1 * 40.0) + sin(d2 * 40.0);
    vec3 col = mix(vec3(0.1, 0.8, 0.2), vec3(0.9, 0.1, 0.5), smoothstep(-0.5, 0.5, m));
    return col * (1.0 + high);
}

vec3 renderS18(vec2 fc, vec2 res, float time, float kick, float mid) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 col = vec3(0.0);
    float d = abs(0.2 / uv.y);
    vec2 g = vec2(uv.x * d, d) + vec2(0.0, time * 2.0 + kick);
    float grid = mod(floor(g.x * 5.0) + floor(g.y * 5.0), 2.0);
    if(uv.y < 0.0) col = mix(vec3(0.0, 0.1, 0.3), vec3(0.8, 0.0, 0.8), grid) * exp(-d*0.5);
    else {
        float s = fract(sin(dot(floor(uv*100.0), vec2(12.9898, 78.233))) * 43758.5453);
        if(s > 0.98) col = vec3(1.0) * (1.0 + mid);
    }
    return col;
}

vec3 renderS19(vec2 fc, vec2 res, float time, float bass, float kick) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 ro = vec3(0.0, 0.0, -4.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    rd.xy *= rot(time * 0.3);
    float acc = 0.0;
    float tD = 0.0;
    for (int i = 0; i < 48; i++) {
        vec3 p = ro + rd * tD;
        p.xz *= rot(p.y * 0.5 + time);
        p.xy = abs(p.xy) - (0.8 + bass * 0.4);
        float d = length(p.xz) - (0.05 + kick * 0.08);
        tD += max(d, 0.02);
        acc += exp(-d * 8.0) * (0.02 + kick * 0.03);
    }
    vec3 col = mix(vec3(0.9, 0.1, 0.4), vec3(0.0, 0.8, 1.0), sin(tD * 2.0 + time) * 0.5 + 0.5);
    return acc * col;
}

vec3 renderS20(vec2 fc, vec2 res, float time, float mid, float high) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    float r = length(uv);
    float a = atan(uv.y, uv.x);
    vec2 st = vec2(log(r + 1e-4) - time * 0.8, a / 3.14159265);
    st.x += sin(st.y * 6.0 + time) * 0.2;
    float grid = sin(st.x * 20.0) * sin(st.y * 12.0 + high * 4.0);
    grid = smoothstep(0.0, 0.1, grid);
    vec3 col = mix(vec3(0.05, 0.0, 0.15), vec3(1.0, 0.5, 0.0), grid);
    col += vec3(0.2, 0.8, 0.9) * exp(-r * 3.0) * (1.0 + mid * 2.0);
    return col;
}

vec3 renderS21(vec2 fc, vec2 res, float time, float bass, float high) {
    vec2 uv = (fc * 2.0 - res) / res.y;
    vec3 col = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 z = uv * (1.0 + fi * 0.3);
        z *= rot(time * (0.2 + fi * 0.1));
        float d = length(abs(z) - (0.5 + bass * 0.3));
        float ring = smoothstep(0.08, 0.0, abs(d - 0.2));
        col += ring * mix(vec3(0.1, 0.9, 0.3), vec3(0.9, 0.1, 0.8), fi / 3.0);
    }
    return col * (1.0 + high * 1.5);
}

vec3 getMegademoScene(int id, vec2 fc, vec2 res, float t, float b, float m, float h, float k) {
    if (id == 0) return renderS0(fc, res, t, b, k);
    if (id == 1) return renderS1(fc, res, t, m, h);
    if (id == 2) return renderS2(fc, res, t, h, k);
    if (id == 3) return renderS3(fc, res, t, b);
    if (id == 4) return renderS4(fc, res, t, b, m);
    if (id == 5) return renderS5(fc, res, t, b, m);
    if (id == 6) return renderS6(fc, res, t, h, k);
    if (id == 7) return renderS7(fc, res, t, b, m);
    if (id == 8) return renderS8(fc, res, t, b, h);
    if (id == 9) return renderS9(fc, res, t, b, m);
    if (id == 10) return renderS10(fc, res, t, b, k);
    if (id == 11) return renderS11(fc, res, t, b, h);
    if (id == 12) return renderS12(fc, res, t, b, m);
    if (id == 13) return renderS13(fc, res, t, k);
    if (id == 14) return renderS14(fc, res, t, b, h);
    if (id == 15) return renderS15(fc, res, t, k, m);
    if (id == 16) return renderS16(fc, res, t, b);
    if (id == 17) return renderS17(fc, res, t, h);
    if (id == 18) return renderS18(fc, res, t, k, m);
    if (id == 19) return renderS19(fc, res, t, b, k);
    if (id == 20) return renderS20(fc, res, t, m, h);
    return renderS21(fc, res, t, b, h);
}

float getObjGenericSDF(int objType, vec3 p, float morph, float bass, float high) {
    if (objType == 0 || objType == 4) {
        float s1 = max(abs(p.x), max(abs(p.y), abs(p.z))) - (0.7 + bass*0.2);
        float s2 = length(p) - (0.85 + bass*0.2);
        return mix(s1, s2, morph);
    } else if (objType == 1 || objType == 5) {
        float dTetra = max(max(p.x+p.y+p.z, p.x-p.y-p.z), max(-p.x+p.y-p.z, -p.x-p.y+p.z)) - (1.0 + bass*0.3);
        float dCyl = length(p.xz) - 0.6;
        return mix(dTetra, dCyl, morph);
    } else {
        float dOct = (abs(p.x) + abs(p.y) + abs(p.z)) - (1.1 + high*0.2);
        vec2 q = vec2(length(p.xz) - 0.7, p.y);
        float dTorus = length(q) - 0.25;
        return mix(dOct, dTorus, morph);
    }
}

float drawAmigaWireframeObject(int objType, vec2 uv, float time, float bass, float high, float kick, float morph, float session) {
    float d = 1e5;
    float seedX = hash11(session * 12.3 + 1.0);
    float seedY = hash11(session * 45.6 + 2.0);
    float seedZ = hash11(session * 78.9 + 3.0);
    float zTraj = sin(time * 1.5 + seedZ * 6.28);
    vec3 pathOffset = vec3(
        sin(time * 1.8 + seedX * 6.28) * (0.8 + kick * 0.4),
        cos(time * 1.4 + seedY * 6.28) * (0.6 + bass * 0.4),
        zTraj * 2.2 
    );
    vec3 rAng = vec3(
        time * (1.5 + seedX * 3.0) + kick * 1.2,
        time * (2.0 + seedY * 3.0) + bass * 1.0,
        time * (1.2 + seedZ * 3.0) + high * 0.8
    );
    float dynamicScale = mix(0.4, 2.2, sin(time * 1.2 + seedX * 3.14) * 0.5 + 0.5);
    dynamicScale *= (1.0 + kick * 0.5 + bass * 0.3);
    vec3 pos = vec3(pathOffset.xy, 3.5 + pathOffset.z);
    float fov = 1.0;
    float jitter = sin(time * 60.0) * high * 0.05;
    
    if (objType == 0) {
        vec3 p[8];
        float s = (0.7 * dynamicScale) + jitter;
        p[0]=vec3(-s,-s,-s); p[1]=vec3(s,-s,-s); p[2]=vec3(s,s,-s); p[3]=vec3(-s,s,-s);
        p[4]=vec3(-s,-s,s);  p[5]=vec3(s,-s,s);  p[6]=vec3(s,s,s);  p[7]=vec3(-s,s,s);
        vec2 proj[8];
        for(int i=0; i<8; i++) {
            vec3 v = mix(p[i], normalize(p[i]) * (1.0 * dynamicScale + bass*0.3), morph);
            proj[i] = project3D(v, rAng, pos, fov);
        }
        addSeg2D(d, uv, proj[0], proj[1]); addSeg2D(d, uv, proj[1], proj[2]); addSeg2D(d, uv, proj[2], proj[3]); addSeg2D(d, uv, proj[3], proj[0]);
        addSeg2D(d, uv, proj[4], proj[5]); addSeg2D(d, uv, proj[5], proj[6]); addSeg2D(d, uv, proj[6], proj[7]); addSeg2D(d, uv, proj[7], proj[4]);
        addSeg2D(d, uv, proj[0], proj[4]); addSeg2D(d, uv, proj[1], proj[5]); addSeg2D(d, uv, proj[2], proj[6]); addSeg2D(d, uv, proj[3], proj[7]);
        vec3 rAng2 = vec3(-time * 2.8, time * 1.8, -time * 2.2);
        s = 0.35 * dynamicScale;
        p[0]=vec3(-s,-s,-s); p[1]=vec3(s,-s,-s); p[2]=vec3(s,s,-s); p[3]=vec3(-s,s,-s);
        p[4]=vec3(-s,-s,s);  p[5]=vec3(s,-s,s);  p[6]=vec3(s,s,s);  p[7]=vec3(-s,s,s);
        for(int i=0; i<8; i++) proj[i] = project3D(p[i], rAng2, pos, fov);
        addSeg2D(d, uv, proj[0], proj[1]); addSeg2D(d, uv, proj[1], proj[2]); addSeg2D(d, uv, proj[2], proj[3]); addSeg2D(d, uv, proj[3], proj[0]);
        addSeg2D(d, uv, proj[4], proj[5]); addSeg2D(d, uv, proj[5], proj[6]); addSeg2D(d, uv, proj[6], proj[7]); addSeg2D(d, uv, proj[7], proj[4]);
        addSeg2D(d, uv, proj[0], proj[4]); addSeg2D(d, uv, proj[1], proj[5]); addSeg2D(d, uv, proj[2], proj[6]); addSeg2D(d, uv, proj[3], proj[7]);
    } 
    else if (objType == 1) {
        float rOut = (mix(0.9, 0.6, morph) + jitter) * dynamicScale;
        float rIn = mix(0.35, 0.75, morph) * dynamicScale;
        vec2 lastOuter = vec2(0), firstOuter = vec2(0);
        vec2 lastInner = vec2(0), firstInner = vec2(0);
        for(int i=0; i<5; i++) {
            float a1 = float(i) * 6.283185 / 5.0;
            float a2 = a1 + 3.14159 / 5.0;
            vec3 pOut = vec3(cos(a1)*rOut, sin(a1)*rOut, 0.0);
            vec3 pIn  = vec3(cos(a2)*rIn, sin(a2)*rIn, 0.0);
            vec2 prOut = project3D(pOut, rAng, pos, fov);
            vec2 prIn  = project3D(pIn, rAng, pos, fov);
            if(i > 0) {
                addSeg2D(d, uv, lastInner, prOut);
                addSeg2D(d, uv, prOut, prIn);
            } else {
                firstOuter = prOut;
            }
            lastOuter = prOut;
            lastInner = prIn;
            vec3 pBack = vec3(0.0, 0.0, -0.5 * dynamicScale);
            vec3 pFront = vec3(0.0, 0.0, 0.5 * dynamicScale);
            vec2 prBack = project3D(pBack, rAng, pos, fov);
            vec2 prFront = project3D(pFront, rAng, pos, fov);
            addSeg2D(d, uv, prOut, prBack);
            addSeg2D(d, uv, prOut, prFront);
        }
        addSeg2D(d, uv, lastInner, firstOuter);
    }
    else if (objType == 2) {
        int SEG_U = 10;
        int SEG_V = 6;
        float R = mix(0.75, 0.35, morph) * dynamicScale;
        float r = (mix(0.3, 0.55, morph) + jitter) * dynamicScale;
        vec2 grid[66];
        for(int i=0; i<10; i++) {
            float uA = float(i) * 6.283185 / float(SEG_U);
            for(int j=0; j<6; j++) {
                float vA = float(j) * 6.283185 / float(SEG_V);
                vec3 p = vec3((R + r*cos(vA))*cos(uA), (R + r*cos(vA))*sin(uA), r*sin(vA));
                grid[i*SEG_V + j] = project3D(p, rAng, pos, fov);
            }
        }
        for(int i=0; i<10; i++) {
            int iNext = (i + 1) % SEG_U;
            for(int j=0; j<6; j++) {
                int jNext = (j + 1) % SEG_V;
                addSeg2D(d, uv, grid[i*SEG_V + j], grid[iNext*SEG_V + j]);
                addSeg2D(d, uv, grid[i*SEG_V + j], grid[i*SEG_V + jNext]);
            }
        }
    }
    else if (objType == 3) {
        vec3 p[6];
        float s = (1.0 + jitter) * dynamicScale;
        p[0]=vec3(0,s,0); p[1]=vec3(0,-s,0); p[2]=vec3(-s,0,0);
        p[3]=vec3(s,0,0); p[4]=vec3(0,0,-s); p[5]=vec3(0,0,s);
        vec2 proj[6];
        for(int i=0; i<6; i++) {
            vec3 v = mix(p[i], p[i] * vec3(1.3, 0.4, 1.3), morph);
            proj[i] = project3D(v, rAng, pos, fov);
        }
        addSeg2D(d, uv, proj[0], proj[2]); addSeg2D(d, uv, proj[0], proj[3]); addSeg2D(d, uv, proj[0], proj[4]); addSeg2D(d, uv, proj[0], proj[5]);
        addSeg2D(d, uv, proj[1], proj[2]); addSeg2D(d, uv, proj[1], proj[3]); addSeg2D(d, uv, proj[1], proj[4]); addSeg2D(d, uv, proj[1], proj[5]);
        addSeg2D(d, uv, proj[2], proj[4]); addSeg2D(d, uv, proj[4], proj[3]); addSeg2D(d, uv, proj[3], proj[5]); addSeg2D(d, uv, proj[5], proj[2]);
    }
    else if (objType == 4) {
        vec3 p[4];
        float s = (1.1 + jitter) * dynamicScale;
        p[0] = vec3(s, s, s); p[1] = vec3(-s, -s, s);
        p[2] = vec3(-s, s, -s); p[3] = vec3(s, -s, -s);
        vec2 proj[4];
        for(int i=0; i<4; i++) {
            vec3 v = mix(p[i], normalize(p[i]) * s * 1.2, morph);
            proj[i] = project3D(v, rAng, pos, fov);
        }
        addSeg2D(d, uv, proj[0], proj[1]); addSeg2D(d, uv, proj[0], proj[2]); addSeg2D(d, uv, proj[0], proj[3]);
        addSeg2D(d, uv, proj[1], proj[2]); addSeg2D(d, uv, proj[1], proj[3]); addSeg2D(d, uv, proj[2], proj[3]);
    }
    else if (objType == 5) {
        float h = 0.9 * dynamicScale, r = 0.6 * dynamicScale;
        vec3 apex = vec3(0, h, 0);
        vec2 projApex = project3D(apex, rAng, pos, fov);
        vec2 firstP = vec2(0), lastP = vec2(0);
        for(int i=0; i<8; i++) {
            float a = float(i) * 6.283185 / 8.0;
            vec3 pt = vec3(cos(a)*r, -h, sin(a)*r);
            vec2 pr = project3D(pt, rAng, pos, fov);
            addSeg2D(d, uv, projApex, pr);
            if(i > 0) addSeg2D(d, uv, lastP, pr);
            else firstP = pr;
            lastP = pr;
        }
        addSeg2D(d, uv, lastP, firstP);
    }
    else {
        float r1 = 0.7 * dynamicScale, r2 = 0.35 * dynamicScale, h = 0.7 * dynamicScale;
        vec2 last1=vec2(0), first1=vec2(0), last2=vec2(0), first2=vec2(0);
        for(int i=0; i<6; i++) {
            float a = float(i) * 6.283185 / 6.0;
            vec3 pt1 = vec3(cos(a)*r1, h, sin(a)*r1);
            vec3 pt2 = vec3(cos(a)*r2, -h, sin(a)*r2);
            vec2 pr1 = project3D(pt1, rAng, pos, fov);
            vec2 pr2 = project3D(pt2, rAng, pos, fov);
            addSeg2D(d, uv, pr1, pr2);
            if(i > 0) { addSeg2D(d, uv, last1, pr1); addSeg2D(d, uv, last2, pr2); }
            else { first1 = pr1; first2 = pr2; }
            last1 = pr1; last2 = pr2;
        }
        addSeg2D(d, uv, last1, first1); addSeg2D(d, uv, last2, first2);
    }
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float bass_env = texture(iChannel0, vec2(0.02, 0.25)).r;
    float kick     = pow(texture(iChannel0, vec2(0.06, 0.25)).r, 2.2);
    float snare    = pow(texture(iChannel0, vec2(0.25, 0.25)).r, 2.0);
    float mid      = texture(iChannel0, vec2(0.45, 0.25)).r;
    float hihat    = pow(texture(iChannel0, vec2(0.85, 0.25)).r, 2.5);

    vec2 currentCoord = fragCoord;
    vec3 finalCol = vec3(0.0);

    if (iTime < 45.0) {
        if (iTime >= 43.0 && iTime < 45.0) {
            float e = (iTime - 43.0) / 2.0; float tInt = sin(e * 3.14159);
            vec2 uv = (currentCoord - 0.5 * iResolution.xy) / iResolution.y;
            float r = length(uv), a = atan(uv.y, uv.x) + tInt * 6.28 * (1.0 - smoothstep(0.0, 0.8, r));
            vec2 newUv = vec2(cos(a), sin(a)) * exp(log(r + 1e-5) + tInt * 2.0);
            currentCoord = (newUv * iResolution.y) + 0.5 * iResolution.xy;
        }
        float alpha = max(getCubeAlpha(iTime, 13.0, 8.0, 0.5), getCubeAlpha(iTime, 28.0, 8.0, 0.5));
        finalCol = renderAmigaScene(currentCoord, iResolution.xy, iTime, bass_env, mid, hihat, kick);
        if (alpha > 0.0) {
            vec2 gCoord = currentCoord; float gN = fract(sin(floor(currentCoord.y * 0.05) + iTime * 43.0) * 43758.54);
            if (gN < alpha * 0.6) gCoord.x += (fract(sin(iTime * 123.45 + currentCoord.y) * 43758.54) - 0.5) * 60.0 * alpha;
            finalCol += renderCubeScene(gCoord, iResolution.xy, iTime) * alpha;
            if (gN > 0.85 && alpha > 0.1) finalCol += vec3(step(0.5, fract(currentCoord.y * 0.1 + iTime * 10.0))) * alpha * 0.4;
        }
        if (iTime >= 43.0 && iTime < 45.0) {
            float cB = sin((iTime - 43.0) / 2.0 * 3.14159);
            finalCol = clamp(mix(pow(finalCol, vec3(1.0 + cB * 2.5)), (finalCol - 0.5) * (1.0 + cB * 1.5) + 0.5, cB), 0.0, 1.0);
        }
    } else {
        float mTime = iTime - 45.0;
        float bpm = 135.0;
        float beatProgression = mTime * (bpm / 60.0);
        float session = floor(beatProgression / 8.0); 
        float sProg = fract(beatProgression / 8.0);
        float beat_tick = fract(beatProgression);
        
        float hardKick = smoothstep(0.65, 1.0, kick);
        float hardSnare = smoothstep(0.6, 1.0, snare);
        float hatStrobe = smoothstep(0.75, 1.0, hihat);
        
        int id1 = int(hash11(session) * 22.0) % 22;
        int id2 = int(hash11(session + 1.0) * 22.0) % 22;
        
        vec2 fc1 = currentCoord;
        
        float zoomPulse = exp(-beat_tick * 4.0) * hardKick * 0.25;
        fc1 = (fc1 - iResolution.xy * 0.5) * (1.0 - zoomPulse) + iResolution.xy * 0.5;

        if (hardSnare > 0.4) {
            float shift = (hash11(mTime * 40.0) - 0.5) * 40.0 * hardSnare;
            fc1.x += shift;
        }

        if (hardKick > 0.5 && hash11(mTime * 12.0) > 0.6) {
            fc1.x += (hash11(mTime * 22.0) - 0.5) * 90.0 * hardKick;
            fc1.y += (hash11(mTime * 33.0) - 0.5) * 60.0 * hardKick;
        }

        if (bass_env > 0.8 && hash11(session * 2.4) > 0.5) {
            fc1.x = abs(fc1.x - iResolution.x * 0.5) + iResolution.x * 0.5;
            if (hash11(session * 1.1) > 0.5) fc1.y = abs(fc1.y - iResolution.y * 0.5) + iResolution.y * 0.5;
        }
        
        finalCol = getMegademoScene(id1, fc1, iResolution.xy, mTime + hardKick * 0.2, bass_env, mid, hihat, kick);

        float tFX = smoothstep(0.80, 1.0, sProg);
        if (tFX > 0.0) {
            vec2 fc2 = currentCoord;
            float fxType = floor(mod(hash11(session * 3.3) * 6.0, 6.0));
            
            if (fxType == 1.0) {
                fc2.x += sin(fc2.y * 0.08 + mTime * 25.0) * 120.0 * tFX; 
            } else if (fxType == 2.0) {
                fc2 = floor(fc2 / (1.0 + tFX * 40.0)) * (1.0 + tFX * 40.0);
            } else if (fxType == 3.0) {
                vec2 uvc = (fc2 - 0.5 * iResolution.xy) / iResolution.y;
                float ang = atan(uvc.y, uvc.x) + tFX * 3.14159 * (hardKick + 0.5);
                float len = length(uvc) * (1.0 - tFX * 0.5);
                fc2 = (vec2(cos(ang), sin(ang)) * len * iResolution.y) + 0.5 * iResolution.xy;
            } else if (fxType == 4.0) {
                vec2 uvc = (fc2 - 0.5 * iResolution.xy) / iResolution.y;
                uvc *= rot(tFX * 1.57);
                uvc = abs(uvc);
                fc2 = (uvc * iResolution.y) + 0.5 * iResolution.xy;
            } else if (fxType == 5.0) {
                fc2.y += (hash11(floor(fc2.x * 0.05) + mTime) - 0.5) * 150.0 * tFX;
            }
            
            vec3 col2 = getMegademoScene(id2, fc2, iResolution.xy, mTime, bass_env, mid, hihat, kick);
            if (fxType == 0.0) finalCol = mix(finalCol, col2, tFX);
            else if (fxType == 1.0) finalCol = mix(finalCol, col2, step(0.5, hash11(fc1.y + mTime))); 
            else if (fxType == 2.0 || fxType == 5.0) finalCol = mix(finalCol, col2, tFX);
            else if (fxType == 3.0) finalCol = mix(finalCol, col2 * 1.3, tFX * smoothstep(0.0, 0.5, beat_tick));
            else finalCol += col2 * tFX * (hardKick + hardSnare); 
        }

        float showObj = step(0.20, hash11(session * 4.7));
        if (showObj > 0.5) {
            float objIn = smoothstep(0.0, 0.10, sProg) * (1.0 - smoothstep(0.90, 1.0, sProg));
            vec2 uvVector = (currentCoord - 0.5 * iResolution.xy) / iResolution.y;
            if (sProg > 0.88 && hash11(mTime * 15.0) > 0.4) {
                uvVector.x += (hash11(mTime * 30.0) - 0.5) * 0.3;
            }

            int wireObjType = int(mod(floor(hash11(session * 9.1) * 7.0), 7.0));
            float morphVal = sin(mTime * 2.5 + hardSnare) * 0.5 + 0.5;
            float wireDist = drawAmigaWireframeObject(wireObjType, uvVector, mTime, bass_env, hihat, kick, morphVal, session);
            
            float lineThick = 0.0025 + hardKick * 0.005;
            float lineGlow = exp(-wireDist * (160.0 - hardKick * 60.0));
            float lineCore = smoothstep(lineThick, 0.0, wireDist);
            
            vec3 wirePal = 0.5 + 0.5 * cos(mTime * 4.0 + uvVector.xyx * 2.0 + vec3(0.0, 2.0, 4.0));
            float palSel = mod(session, 4.0);
            if (palSel < 1.0) wirePal = mix(vec3(1.0, 0.2, 0.0), vec3(0.0, 0.8, 1.0), sin(mTime * 3.0) * 0.5 + 0.5);
            else if (palSel < 2.0) wirePal = vec3(0.2, 1.0, 0.4);
            else if (palSel < 3.0) wirePal = mix(vec3(0.9, 0.8, 0.1), vec3(0.8, 0.1, 0.9), cos(mTime * 2.0) * 0.5 + 0.5);

            vec3 wireCol = (wirePal * lineGlow * (2.4 + kick * 1.8)) + (vec3(1.0) * lineCore);
            
            float isSolidPhase = step(0.55, hash11(session * 8.1));
            if (isSolidPhase > 0.5 && mid > 0.30) {
                vec3 roS = vec3(uvVector * 3.0, -3.0);
                vec3 rdS = vec3(0.0, 0.0, 1.0);
                rdS.xz *= rot(mTime * 1.5); rdS.yz *= rot(mTime * 0.9);
                float dS = getObjGenericSDF(wireObjType, roS, morphVal, bass_env, hihat);
                if (dS < 0.1) {
                    vec3 solidCol = wirePal * (0.6 + 0.4 * sin(uvVector.y * 40.0 + mTime * 10.0));
                    wireCol = mix(wireCol, solidCol * (1.2 + hardKick * 2.0), smoothstep(0.1, 0.0, dS));
                }
            }

            float wireAlpha = clamp(lineGlow + lineCore, 0.0, 1.0) * objIn;
            finalCol = mix(finalCol, finalCol + wireCol, wireAlpha);
        }

        if (hatStrobe > 0.6 && mod(mTime * 20.0, 1.0) > 0.5) {
            finalCol = 1.0 - finalCol; 
            finalCol.rg = finalCol.gr; 
        }

        finalCol += vec3(0.8, 0.9, 1.0) * pow(hardKick, 3.5);
        finalCol += vec3(1.0, 0.3, 0.5) * pow(hardSnare, 4.0);
        finalCol.r += smoothstep(0.5, 1.0, bass_env) * 0.35 * length(currentCoord / iResolution.xy - 0.5);
    }
    
    fragColor = vec4(finalCol, 1.0);
}

// ==== Sound (sound) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
vec2 mainSound(int samp, float time) {
    if (time >= 5.0) {
        return vec2(0.0);
    }

    float t = mod(time, 5.0),
          s = floor(time / 5.0),
          p1 = fract(sin(s * 17.31) * 43758.54),
          r = p1 < 0.2 ? 0.7 : p1 < 0.5 ? 0.5 : p1 < 0.8 ? 0.35 : 0.6,
          i = p1 < 0.2 ? 2.4 : p1 < 0.5 ? 1.6 : p1 < 0.8 ? 0.9 : 2.0,
          sr = p1 < 0.2 ? 12.0 : p1 < 0.5 ? 28.0 : p1 < 0.8 ? 50.0 : 18.0,
          st = mod(t, i),
          sc = floor(t / i),
          kp = st / 0.07,
          kt = step(0.0, st) * (1.0 - step(0.1, st)),
          hk = (sin(691.15 * kp) * exp(-kp * 14.0) * 0.6 + sin(1382.3 * kp) * exp(-kp * 45.0) * 0.3 + (fract(sin(time * 8000.0) * 43758.54) * 2.0 - 1.0) * exp(-kp * 10.0) * 1.4) * kt * 1.95,
          hs = fract(sin((s * 100.0 + sc) * 2.7) * 43758.54),
          sp = fract(st * sr * (0.8 + 0.4 * hs)),
          is = step(0.1, st) * (1.0 - step(i * r, st)),
          lk = (sin(691.15 * sp) + (fract(sin(time * 25000.0) * 43758.54) * 2.0 - 1.0) * 0.5) * exp(-sp * 48.0) * 0.4,
          f = fract(sin(time * 16000.0) * 43758.54) * 2.0 - 1.0,
          kjj = ((f * 0.5 + sin(5529.2 * time + f * 2.5) * 0.5) * (0.6 + 0.4 * sin(345.575 * time))) * is * 0.5,
          m = sin(345.575 * time) * 0.05 + (fract(sin(time * 6000.0) * 43758.54) * 2.0 - 1.0) * 0.02,
          outSig = hk + lk * is + kjj + m;

    if (t > 4.8) outSig *= (5.0 - t) / 0.2;

    return vec2(clamp(outSig, -1.0, 0.0));
}
