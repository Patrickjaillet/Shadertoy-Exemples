
float hash(vec2 p) {
    p = fract(p * vec2(234.34, 435.346));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1, 0));
    float c = hash(i + vec2(0, 1));
    float d = hash(i + vec2(1, 1));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm2(vec2 p, int oct) {
    float v = 0.0, a = 0.5, f = 1.0;
    for (int i = 0; i < 8; i++) {
        if (i >= oct) break;
        v += a * noise2(p * f);
        a *= 0.5;
        f *= 2.0;
    }
    return v;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdTerrain(vec3 p) {
    return p.y - fbm2(p.xz * 2.46, 8) * 1.57 + 1.0;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

const int KF_N = 4;
float kfT[KF_N]  = float[KF_N](0.0, 1.666, 3.333, 5.0);
vec3 kfP[KF_N]   = vec3[KF_N](vec3(-2.871, 3.26, 5.259), vec3(-2.871, 3.26, -2.72), vec3(-10.0, 5.49, -1.97), vec3(-2.871, 3.26, 5.259));
vec3 kfTa[KF_N]  = vec3[KF_N](vec3(2.83, -0.119, 0.0), vec3(2.21, -0.119, 0.0), vec3(2.21, -0.119, 0.0), vec3(2.83, -0.119, 0.0));

vec3 getCam(float t) {
    if (t <= kfT[0]) return kfP[0];
    if (t >= kfT[KF_N-1]) return kfP[KF_N-1];
    for (int i = 0; i < KF_N-1; i++) {
        if (t >= kfT[i] && t <= kfT[i+1]) {
            float f = (t - kfT[i]) / (kfT[i+1] - kfT[i]);
            float s = f * f * (3.0 - 2.0 * f);
            return mix(kfP[i], kfP[i+1], s);
        }
    }
    return kfP[0];
}

vec3 getTar(float t) {
    if (t <= kfT[0]) return kfTa[0];
    if (t >= kfT[KF_N-1]) return kfTa[KF_N-1];
    for (int i = 0; i < KF_N-1; i++) {
        if (t >= kfT[i] && t <= kfT[i+1]) {
            float f = (t - kfT[i]) / (kfT[i+1] - kfT[i]);
            float s = f * f * (3.0 - 2.0 * f);
            return mix(kfTa[i], kfTa[i+1], s);
        }
    }
    return kfTa[0];
}

vec3 skyColor(vec3 rd) {
    vec3 sunDir = normalize(vec3(0.4, 0.38, -0.5));
    float ht = clamp(rd.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 sky = mix(vec3(1.0, 0.894, 0.69), vec3(0.529, 0.808, 0.922), pow(ht, 1.7));

    float sd = dot(rd, sunDir);
    sky += vec3(1.0, 0.969, 0.816) * step(0.982, sd);
    sky += vec3(1.0, 0.69, 0.376) * pow(max(sd, 0.0), 19.61) * 3.0 * (1.0 - step(0.982, sd));
    sky += vec3(1.0, 0.69, 0.376) * pow(max(sd, 0.0), 3.0) * 1.2 * (1.0 - ht);
    return sky;
}

struct Hit { float d; int mat; };
Hit map(vec3 p) {
    Hit h; h.d = 1e10; h.mat = 0;

    float td = sdTerrain(p); if (td < h.d) { h.d = td; h.mat = 3; }

    float cd = sdBox(p - vec3(0.0, 0.84, -0.54), vec3(0.896));
    if (cd < h.d) { h.d = cd; h.mat = 2; }

    return h;
}

vec3 calcNormal(vec3 p) {
    const float e = 0.0005;
    return normalize(vec3(
        map(p + vec3(e, 0, 0)).d - map(p - vec3(e, 0, 0)).d,
        map(p + vec3(0, e, 0)).d - map(p - vec3(0, e, 0)).d,
        map(p + vec3(0, 0, e)).d - map(p - vec3(0, 0, e)).d));
}

mat3 setCamera(vec3 ro, vec3 ta) {
    vec3 cw = normalize(ta - ro), cp = vec3(0, 1, 0);
    vec3 cu = normalize(cross(cw, cp));
    return mat3(cu, cross(cu, cw), cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float loopTime = mod(iTime, 5.0);

    vec3 ro = getCam(loopTime);
    vec3 camTar = getTar(loopTime);
    mat3 cam = setCamera(ro, camTar);
    vec3 rd = normalize(cam * vec3(uv, 0.5));

    vec3 col = skyColor(rd);
    float t = 0.0; bool hit = false; int hitMat = 0;

    for (int i = 0; i < 256; i++) {
        vec3 p = ro + rd * t;
        Hit h = map(p);
        if (h.d < 0.01) { hit = true; hitMat = h.mat; break; }
        t += h.d;
        if (t > 200.0) break;
    }

    if (hit) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        vec3 l = normalize(vec3(1.0, 0.61, -1.0));

        float diff = max(dot(n, l), 0.0);
        vec3 matCol = vec3(0.867, 0.0, 0.0);

        if (hitMat == 3) {
            float h2 = clamp((p.y + 1.0) / 1.57, 0.0, 1.0);
            matCol = mix(vec3(0.5, 0.25, 0.0), vec3(0.49, 0.39, 0.31), h2);
        }

        float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 32.0) * 0.3;
        col = matCol * (diff + 0.36) + spec;

        col = mix(col, skyColor(rd), 1.0 - exp(-0.04 * t * t));
    }

    col = pow(clamp(col, 0.0, 1.0), vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
