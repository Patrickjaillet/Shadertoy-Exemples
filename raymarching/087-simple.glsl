// ==== Image (image) ====
vec2 hash22(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p * vec2(123.34, 456.21));
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(hash22(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float b = dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y) * 0.5 + 0.5;
}

float sdCordPattern(vec2 p) {
    float wave = sin(p.x * 10.0 + iTime * 2.0) * 0.1;
    return abs(p.y + wave) - 0.05;
}

float sdJomonSpiral(vec2 p) {
    float r = length(p);
    float a = atan(p.y, p.x);
    float spiral = abs(sin(r * 15.0 - a * 2.0 + iTime));
    return spiral - 0.2;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float dist = noise(uv * 3.0 + vec2(iTime * 0.5));
    uv += vec2(sin(uv.y * 20.0 + iTime * 3.0), cos(uv.x * 20.0 + iTime * 3.0)) * 0.02 * dist;

    vec2 st = uv * 4.0;
    vec2 grid_uv = fract(st) - 0.5;
    vec2 grid_id = floor(st);

    float pattern = 0.0;
    if (mod(grid_id.x + grid_id.y, 2.0) == 0.0) {
        pattern = sdCordPattern(grid_uv);
    } else {
        pattern = sdJomonSpiral(grid_uv);
    }

    float mask = smoothstep(0.08, 0.0, abs(pattern));

    vec3 terracotta = vec3(0.55, 0.27, 0.12);
    vec3 energyColor = vec3(1.0, 0.3, 0.0);
    vec3 bgColor = vec3(0.05, 0.03, 0.02);

    vec3 col = mix(bgColor, terracotta, mask);

    float pulse = sin(length(uv) * 10.0 - iTime * 4.0) * 0.5 + 0.5;
    col += energyColor * (1.0 - smoothstep(0.0, 0.15, abs(pattern))) * pulse;
    col += (noise(uv * 50.0) - 0.5) * 0.08;
    col *= 1.0 - length(uv) * 0.6;
    col = clamp(col, 0.0, 1.0);

    fragColor = vec4(col, 1.0);
}
