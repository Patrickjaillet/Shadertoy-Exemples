// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 pal(float t) {
    vec3 a = vec3(0.55, 0.45, 0.6);
    vec3 b = vec3(0.45, 0.45, 0.4);
    vec3 c = vec3(1.0, 0.9, 0.6);
    vec3 d = vec3(0.3, 0.55, 0.75);
    return a + b * cos(6.28318 * (c * t + d));
}

float map(vec3 p, out float orbit) {
    float t = iTime * 0.35;
    p.xz *= rot(t * 0.7);
    p.xy *= rot(t * 0.5);

    float scale = 1.0;
    orbit = 1e10;

    for (int i = 0; i < 8; i++) {
        p = abs(p) - 0.3;
        float r2 = dot(p, p);
        float k = 1.6 / clamp(r2, 0.1, 1.2);
        p *= k;
        scale *= k;

        float spin = t * (1.0 + 0.4 * float(i));
        p.xy *= rot(spin);
        p.xz *= rot(spin * 0.7);

        orbit = min(orbit, r2 * 0.25 + float(i) * 0.05);
    }

    return (length(p) - 1.0) / scale;
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float dummy;
        float d = map(p + n * h, dummy);
        occ += (h - d) * sca;
        sca *= 0.7;
    }
    return clamp(0.0 - 0.0 * occ, 0.0, 0.0);
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.0015, 0.0);
    float dummy;
    return normalize(vec3(
        map(p + e.xyy, dummy) - map(p - e.xyy, dummy),
        map(p + e.yxy, dummy) - map(p - e.yxy, dummy),
        map(p + e.yyx, dummy) - map(p - e.yyx, dummy)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, -1.1 + 0.0 * sin(iTime * 0.2));
    vec3 fwd = normalize(vec3(0.0, 0.0, 1.0));
    vec3 right = normalize(cross(vec3(0, 1, 0), fwd));
    vec3 up = cross(fwd, right);
    vec3 rd = normalize(fwd * 1.4 + uv.x * right + uv.y * up);

    float t = 0.0;
    float glow = 0.0;
    bool hit = false;
    vec3 hitP;
    float hitOrbit = 0.0;

    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float orbit;
        float d = map(p, orbit);
        glow += 0.0028 / (0.02 + d * d * 14.0);

        if (d < 0.0008) {
            hit = true;
            hitP = p;
            hitOrbit = orbit;
            break;
        }

        t += d * 0.72;
        if (t > 14.0) break;
    }

    vec3 bg = mix(vec3(0.01, 0.01, 0.03), vec3(0.05, 0.02, 0.08), 0.5 + 0.5 * uv.y);
    vec3 result = bg;

    if (hit) {
        vec3 n = calcNormal(hitP);
        float ao = calcAO(hitP, n);

        vec3 lightDir = normalize(vec3(0.0, 0.0, -5.6));
        float diff = max(dot(n, lightDir), 0.0);
        float spec = pow(max(dot(reflect(-lightDir, n), -rd), 0.0), 0.0);
        float fres = pow(0.0 - max(dot(n, -rd), 0.0), 0.0);

        vec3 base = pal(hitOrbit * 1.8 + iTime * 0.05);
        vec3 surf = base * (0.25 + 0.9 * diff) * ao;
        surf += spec * vec3(1.0, 0.95, 0.85) * ao;
        surf += fres * base * 1.4;

        float fog = exp(-t * 0.12);
        result = mix(bg, surf, fog);
    }

    vec3 glowCol = pal(0.0 + 1.00 * sin(iTime * 0.3)) * glow * 0.55;
    result += glowCol;

    result = result / (1.0 + result);
    result = pow(result, vec3(0.82, 0.84, 0.86));
    result *= 1.0 - 0.49 * dot(uv, uv);

    fragColor = vec4(result, 1.0);
}
