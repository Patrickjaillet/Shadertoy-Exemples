// ==== Image (image) ====
vec3 rotateZ(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}
// https://github.com/Patrickjaillet/Z-GL
vec3 palette(float x, int p) {
    x = fract(x);
    if (p == 1) return vec3(x * 1.6, x * x * 0.8, 0.05);
    if (p == 2) return vec3(0.05 + x * 0.3, 0.4 + x * 0.5, 0.7 + x * 0.3);
    if (p == 3) return vec3(0.05 + x * 0.3, 0.3 + x * 0.7, 0.05 + x * 0.2);
    vec3 h = clamp(abs(fract(vec3(x, x + 0.333, x + 0.667)) * 3.0 - 1.5) - 0.5, 0.0, 1.0);
    return mix(vec3(0.9), h, 0.85);
}

float map(vec3 p, out float glow, float t) {
    float R = length(p) + 0.001;
    vec3 lp = vec3(log2(R) - t * 0.5, exp(1.0 - clamp(p.z / R, -0.3, 5.0)), atan(p.y, p.x) + cos(t * 0.7));

    float e = lp.y - 1.0;
    float s = 1.0;

    for (int j = 0; j < 22; j++) {
        if (s >= 512.0) break;
        e += sin(dot(sin(lp.zxy * s) - 1.0, 1.0 - cos(lp.yxz * s))) / s;
        s += s;
    }

    glow = abs(e * s);
    return e * R * 0.1;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float t = iTime * 0.8333;

    float c2 = cos(t * 0.12), s2 = sin(t * 0.12);
    uv = vec2(c2 * uv.x - s2 * uv.y, s2 * uv.x + c2 * uv.y);

    vec3 rd = normalize(vec3(uv, 0.8));
    vec3 p = vec3(0.9, 0.0, -1.2);
    vec3 accumColor = vec3(0.0);
    float glow = 0.0;
    float totalDist = 0.0;

    // 0 = Spectral, 1 = Yellow, 2 = Blue, 3 = Green
    int pal = 0;

    for (int step = 0; step < 64; step++) {
        float d = map(p, glow, t);
        float de = max(abs(d), 0.0001);
        p += rd * de;
        totalDist += de;

        // only the very edge of the surface glows
        float surface = exp(-abs(d) * 30.0);
        float shadow = smoothstep(-0.02, 0.08, d);
        float volume = clamp(glow * 0.25 - abs(d) * 1.5, 0.0, 1.0) * shadow;
        float hueShift = totalDist * 0.08 + t * 0.05 + float(step) * 0.012;
        vec3  col = palette(hueShift, pal);

        accumColor += col * surface * shadow * 0.07;
        accumColor += col * volume * 0.03;
    }

    vec3 color = accumColor * 1.8;
    color = color / (color + vec3(0.7));
    color = pow(color, vec3(1.0 / 2.2));

    vec2 uvVig = fragCoord / iResolution.xy;
    color *= 0.5 + 0.5 * pow(16.0 * uvVig.x * uvVig.y * (1.0 - uvVig.x) * (1.0 - uvVig.y), 0.25);

    fragColor = vec4(color, 1.0);
}
