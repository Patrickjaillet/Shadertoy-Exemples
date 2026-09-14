
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(in vec2 p) {
    const float K1 = 0.366025404;
    const float K2 = 0.211324865;

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x);
    vec2 o = vec2(m, 1.0 - m);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

    return dot(n, vec3(70.0));
}

float fbm(vec2 uv) {
    float f = 0.0;
    uv *= 2.0;
    float w = 0.5;
    for (int i = 0; i < 6; i++) {
        f += w * noise(uv);

        uv *= mat2(1.6, 1.2, -1.2, 1.6);
        w *= 0.5;
    }
    return f;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    float t = iTime * 0.15;

    vec2 q = vec2(fbm(uv + vec2(0.0, t)), fbm(uv + vec2(1.0, t)));

    vec2 r = vec2(fbm(uv + 1.2 * q + vec2(1.7, 9.2) + 0.15 * t), 
                  fbm(uv + 1.2 * q + vec2(8.3, 2.8) + 0.126 * t));

    float f = fbm(uv + r);

    vec3 col = mix(vec3(0.15, 0.02, 0.35), vec3(0.02, 0.25, 0.1), clamp((f * f) * 4.0, 0.0, 1.0));
    col = mix(col, vec3(0.7, 0.5, 0.1), clamp(length(q) * 2.0 - 1.0, 0.0, 1.0));
    col = mix(col, vec3(0.9, 0.7, 0.2), clamp(length(r.x) * 3.0 - 1.5, 0.0, 1.0));

    float cell = fbm(uv * 6.0 + q * 3.0 - iTime * 0.1);
    float pattern = smoothstep(0.4, 0.45, cell) * smoothstep(0.55, 0.45, cell);

    vec3 goldTexture = vec3(0.8, 0.6, 0.1) * pattern * 2.5;

    col += goldTexture * clamp(sin(iTime * 0.3) * 0.5 + 0.5, 0.0, 1.0);

    col *= 1.2;
    col -= length(uv) * 0.1;

    fragColor = vec4(col, 1.0);
}
