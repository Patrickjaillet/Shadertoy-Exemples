// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/

struct Frame { vec3 pos, T, N, B; };

mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

float hash(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

vec3 getPath(float t) {
    float T = t * 0.15, p = T * 0.25 * 6.2831853;
    return vec3(sin(T * 1.5) * 12.0, (1.0 - cos(p)) * 18.0 + 5.0, t * 10.0 + sin(p) * 14.4);
}

void getFrame(float t, out Frame f) {
    f.pos = getPath(t);
    f.T = normalize(getPath(t + 0.03) - f.pos);
    vec3 up = vec3(0, 1, 0), side = normalize(cross(f.T, up));
    up = normalize(up + side * sin(t * 0.12) * 1.2);
    f.B = normalize(cross(f.T, up));
    f.N = cross(f.B, f.T);
}

float noise(vec3 x) {
    vec3 p = floor(x), f = fract(x);
    f *= f * (3.0 - 2.0 * f);
    vec4 a = vec4(hash(p), hash(p + vec3(1,0,0)), hash(p + vec3(0,1,0)), hash(p + vec3(1,1,0)));
    vec4 b = vec4(hash(p + vec3(0,0,1)), hash(p + vec3(1,0,1)), hash(p + vec3(0,1,1)), hash(p + vec3(1,1,1)));
    return mix(mix(mix(a.x, a.y, f.x), mix(a.z, a.w, f.x), f.y), mix(mix(b.x, b.y, f.x), mix(b.z, b.w, f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * noise(p);
        p *= 2.5;
        a *= 0.5;
    }
    return v;
}

vec3 getSkyColor(vec3 rd, vec3 sunDir) {
    float sun = max(dot(rd, sunDir), 0.0);
    vec3 sky = mix(vec3(0.1, 0.3, 0.6) - rd.y * 0.4, vec3(0.5, 0.7, 0.9), pow(max(1.0 - max(rd.y, 0.0), 0.0), 4.0));
    return sky + vec3(1.0, 0.6, 0.3) * pow(sun, 12.0) + vec3(1.0, 0.9, 0.7) * pow(sun, 300.0);
}

float cloudDensity(vec3 p) {
    float d = smoothstep(0.4, 0.8, fbm(p * 0.1 + vec3(0, 0, iTime * 0.1)));
    return d * smoothstep(10.0, 30.0, p.y) * smoothstep(80.0, 40.0, p.y);
}

vec3 renderClouds(vec3 col, vec3 ro, vec3 rd, vec3 sunDir) {
    if (rd.y <= 0.0) return col;
    float t = 0.0, transmittance = 1.0;
    vec3 cloudCol = vec3(0);
    for (int i = 0; i < 32; i++) {
        vec3 p = ro + rd * t;
        float d = cloudDensity(p);
        if (d > 0.01) {
            float shadow = cloudDensity(p + sunDir * 1.5);
            cloudCol += transmittance * d * mix(vec3(0.4, 0.5, 0.6), vec3(1), smoothstep(0.0, 1.0, d - shadow));
            transmittance *= 1.0 - d * 0.5;
            if (transmittance < 0.02) break;
        }
        if ((t += 1.5) > 150.0) break;
    }
    return mix(col, cloudCol + col * transmittance, 1.0 - transmittance);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float map(vec3 p) {
    float t = p.z * 0.1;
    Frame f;
    for (int i = 0; i < 3; i++) {
        getFrame(t, f);
        t += dot(p - f.pos, f.T) * 0.1;
    }
    float terrain = p.y - (f.pos.y - 18.0 + cos(p.x * 0.15) * sin(p.z * 0.12) * 4.0);
    vec3 q = p - f.pos, pL = vec3(dot(q, f.B), dot(q, f.N), dot(q, f.T));
    float rails = min(length(pL.xy - vec2(0.8, 0)) - 0.15, length(pL.xy - vec2(-0.8, 0)) - 0.15);
    vec3 pS = pL;
    pS.z = mod(pS.z + 1.5, 3.0) - 1.5;
    float sleepers = sdBox(pS - vec3(0, -0.25, 0), vec3(1.2, 0.1, 0.4));
    Frame fP;
    getFrame(floor(p.z * 0.02 + 0.5) * 5.0, fP);
    vec3 qP = p - fP.pos, pLP = vec3(dot(qP, fP.B), dot(qP, fP.N), dot(qP, fP.T));
    float beam = sdBox(pLP - vec3(0, -0.8, 0), vec3(2.5, 0.4, 0.8));
    float column = max(length(p.xz - fP.pos.xz) - 0.7, p.y - (fP.pos.y - 1.2));
    return min(terrain, min(min(rails, sleepers), min(column, beam)));
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.005, 0);
    return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy), map(p + e.yyx) - map(p - e.yyx)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 R = iResolution.xy, uv = (fragCoord - 0.5 * R) / R.y;
    float loopAngle = iTime * 0.0225 * 6.2831853;
    float speedMult = (iMouse.z > 0.5) ? clamp((iMouse.y / R.y - 0.1) / 0.8, 0.0, 1.0) : 0.5;
    float time = iTime * mix(2.5, 5.0, speedMult) * (1.0 - 0.8 * sin(loopAngle * 0.5));

    Frame f;
    getFrame(time, f);
    vec3 ro = f.pos + f.N * 1.6, rd = normalize(f.T * 1.2 + uv.x * f.B + uv.y * f.N);
    vec3 sunDir = normalize(vec3(0.5, 0.7, -0.4));
    vec3 sky = getSkyColor(rd, sunDir), col = renderClouds(sky, ro, rd, sunDir);

    float d = 0.0;
    for (int i = 0; i < 180; i++) {
        float res = map(ro + rd * d);
        if (res < 0.001 || (d += res) > 140.0) break;
    }

    if (d < 140.0) {
        vec3 p = ro + rd * d, n = getNormal(p);
        float dif = clamp(dot(n, sunDir), 0.0, 1.0);
        float spe = pow(clamp(dot(reflect(-sunDir, n), -rd), 0.0, 1.0), 40.0);
        float occ = clamp(map(p + n * 0.8) / 0.8, 0.0, 1.0);

        float bestT = p.z * 0.1;
        Frame fSurf;
        for (int i = 0; i < 4; i++) {
            getFrame(bestT, fSurf);
            bestT += dot(p - fSurf.pos, fSurf.T) * 0.1;
        }
        vec3 q = p - fSurf.pos, pL = vec3(dot(q, fSurf.B), dot(q, fSurf.N), dot(q, fSurf.T));
        float distRails = min(length(pL.xy - vec2(0.8, 0)) - 0.15, length(pL.xy - vec2(-0.8, 0)) - 0.15);
        vec3 pS = pL;
        pS.z = mod(pS.z + 1.5, 3.0) - 1.5;
        float distSleepers = sdBox(pS - vec3(0, -0.25, 0), vec3(1.2, 0.1, 0.4));
        float distTerrain = p.y - (fSurf.pos.y - 18.0 + cos(p.x * 0.15) * sin(p.z * 0.12) * 4.0);

        vec3 albedo = vec3(0.55, 0.1, 0.1);
        if (distTerrain < distRails && distTerrain < distSleepers && distTerrain < 0.2) albedo = vec3(0.1, 0.15, 0.05);
        else if (distRails < distSleepers && distRails < 0.2) albedo = vec3(0.5, 0.52, 0.55);
        else if (distSleepers < 0.2) albedo = vec3(0.22, 0.14, 0.08);

        col = mix(albedo * (dif + 0.2) * occ + spe * 0.4, sky, 1.0 - exp(-0.00015 * d * d));
    }

    col += col * smoothstep(0.7, 1.2, dot(col, vec3(0.2126, 0.7152, 0.0722))) * 0.3;
    col = clamp((col * 1.1 * (2.51 * col * 1.1 + 0.03)) / (col * 1.1 * (2.43 * col * 1.1 + 0.59) + 0.14), 0.0, 1.0);
    col = mix(col, pow(col, vec3(0.9, 1.0, 1.2)), 0.2) + (hash(vec3(fragCoord, iTime)) - 0.5) * 0.015;

    fragColor = vec4(pow(col * (1.0 - dot(uv, uv) * 0.25), vec3(0.4545)), 1.0);
}
