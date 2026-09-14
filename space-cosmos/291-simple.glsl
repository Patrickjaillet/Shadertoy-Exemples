
#define STEPS 128
#define EPSILON 0.0005
#define FAR 30.0

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

void fold(inout vec3 p) {
    p = abs(p);
    if (p.x < p.y) p.xy = p.yx;
    if (p.x < p.z) p.xz = p.zx;
    if (p.y < p.z) p.yz = p.zy;
}

vec2 map(vec3 p) {
    float t = iTime * 0.15;
    vec3 p_orig = p;

    p.xy *= rot(t * 0.1);
    p.yz *= rot(t * 0.5);

    float scale = 1.0;
    float orb = 0.0;

    vec3 offset = vec3(1.1, 0.8, 1.05) + vec3(sin(t * 1.3), cos(t * 0.9), sin(t * 1.1)) * 0.15;

    for (int i = 0; i < 11; i++) {
        fold(p);
        p = p * 2.15 - offset * 1.15;
        p.xy *= rot(0.38);
        p.xz *= rot(0.25);
        scale *= 2.15;
        orb += exp(-length(p) * 0.46);
    }

    float d1 = (length(p) - 0.75) / scale;
    float d2 = (length(p.xz) - 0.12) / scale;
    float d = max(d1, -d2);

    return vec2(d * 0.75, orb);
}

vec3 normal(vec3 p) {
    vec2 e = vec2(EPSILON, 0.0);
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
        float h = 0.005 + 0.08 * float(i) / 4.0;
        float d = map(p + h * n).x;
        occ += (h - d) * sca;
        sca *= 0.85;
    }
    return clamp(1.0 - 2.8 * occ, 0.0, 1.0);
}

float softShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 24; i++) {
        float h = map(ro + rd * t).x;
        res = min(res, 12.0 * h / t);
        t += clamp(h, 0.01, 0.12);
        if (res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 palette(float t) {
    return vec3(0.5) + vec3(0.5) * cos(6.28318 * (vec3(1.0, 1.0, 0.8) * t + vec3(0.0, 0.33, 0.67)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float t = iTime * 0.2;
    vec3 ro = vec3(2.8 * sin(t), 1.2 * cos(t * 0.7), -2.8 * cos(t));
    vec3 target = vec3(0.0);

    vec3 ww = normalize(target - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.6 * ww);

    float d = 0.0;
    vec2 res = vec2(0.0);
    float glow = 0.0;

    for (int i = 0; i < STEPS; i++) {
        vec3 p = ro + rd * d;
        res = map(p);
        glow += exp(-res.x * 30.8) * 0.000;
        if (abs(res.x) < EPSILON || d > FAR) break;
        d += res.x;
    }

    vec3 col = vec3(0.01, 0.012, 0.02);

    if (d < FAR) {
        vec3 p = ro + rd * d;
        vec3 n = normal(p);
        vec3 ref = reflect(rd, n);

        vec3 l1 = normalize(vec3(3.0, 4.0, -2.0) - p);
        vec3 l2 = normalize(vec3(-2.0, -3.0, 2.0) - p);

        float shadow1 = softShadow(p + n * 0.001, l1, 0.01, 4.0);
        float ao = calcAO(p, n);

        float dif1 = max(dot(n, l1), 0.0) * shadow1;
        float dif2 = max(dot(n, l2), 0.0) * 0.0;

        float spec1 = pow(max(dot(ref, l1), 0.0), 0.0) * shadow1;
        float fresnel = pow(1.0 - max(dot(-rd, n), 1.0), 0.6);

        vec3 baseColor = palette(res.y * 1.00 + length(p) * 1.0);

        col = baseColor * (dif1 * vec3(1.0, 0.9, 1.0) + dif2 * vec3(0.4, 0.6, 1.0) + 0.05);
        col += spec1 * vec3(1.0, 0.95, 0.8) * 1.5;
        col += fresnel * palette(res.y * 0.1 + 0.5) * 1.2;
        col *= ao;
    }

    col += palette(glow * 0.1 + iTime * 0.05) * glow * 0.25;
    col = mix(col, vec3(0.01, 0.012, 0.02), 1.0 - exp(-0.02 * d * d));

    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
