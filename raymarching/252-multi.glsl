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
vec3 acesToneMapping(vec3 color) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

vec3 getBufferWithCA(vec2 uv, float dist) {
    vec2 caOffset = vec2(0.003, 0.0015) * dist;
    float r = texture(iChannel0, uv + caOffset).r;
    float g = texture(iChannel0, uv).g;
    float b = texture(iChannel0, uv - caOffset).b;
    return vec3(r, g, b);
}

vec3 getBloom(vec2 uv) {
    vec3 bloom = vec3(0.0);
    vec2 texel = 1.0 / iResolution.xy;
    
    float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
    
    for (int i = 1; i < 5; i++) {
        vec2 offset = vec2(float(i) * 2.5) * texel;
        bloom += texture(iChannel0, uv + offset).rgb * weights[i];
        bloom += texture(iChannel0, uv - offset).rgb * weights[i];
        bloom += texture(iChannel0, uv + vec2(offset.x, -offset.y)).rgb * weights[i];
        bloom += texture(iChannel0, uv + vec2(-offset.x, offset.y)).rgb * weights[i];
    }
    return bloom;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 centeredUV = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float distFromCenter = length(centeredUV);

    vec3 col = getBufferWithCA(uv, distFromCenter);

    vec3 bloom = getBloom(uv);
    col += bloom * 0.45;

    float vignette = 1.0 - smoothstep(0.3, 0.8, distFromCenter);
    col *= mix(0.3, 1.0, vignette);

    float grain = (fract(sin(dot(uv + iTime * 0.05, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.035;
    col += grain;

    col = acesToneMapping(col);
    col = pow(col, vec3(1.0 / 2.2));

    fragColor = vec4(col, 1.0);
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

float getPattern(vec2 uv) {
    float dist = noise(uv * 3.0 + vec2(iTime * 0.5));
    uv += vec2(sin(uv.y * 20.0 + iTime * 3.0), cos(uv.x * 20.0 + iTime * 3.0)) * 0.02 * dist;

    vec2 st = uv * 4.0;
    vec2 grid_uv = fract(st) - 0.5;
    vec2 grid_id = floor(st);

    if (mod(grid_id.x + grid_id.y, 2.0) == 0.0) {
        return sdCordPattern(grid_uv);
    } else {
        return sdJomonSpiral(grid_uv);
    }
}

float heightMap(vec2 uv) {
    float p = getPattern(uv);
    float mask = smoothstep(0.12, 0.0, abs(p));
    float n = noise(uv * 25.0) * 0.15;
    return mask * 0.8 + n;
}

vec3 getNormal(vec2 uv) {
    vec2 e = vec2(0.003, 0.0);
    float h = heightMap(uv);
    float hx = heightMap(uv + e.xy);
    float hy = heightMap(uv + e.yx);
    return normalize(vec3((h - hx) / e.x, (h - hy) / e.x, 0.35));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float h = heightMap(uv);
    vec3 N = getNormal(uv);

    vec3 lightPos = vec3(cos(iTime * 0.8) * 0.8, sin(iTime * 0.6) * 0.8, 0.6);
    vec3 L = normalize(lightPos - vec3(uv, h));
    vec3 V = vec3(0.0, 0.0, 1.0);
    vec3 H = normalize(L + V);

    float diff = max(dot(N, L), 0.0);
    float spec = pow(max(dot(N, H), 0.0), 32.0);
    float ao = clamp(h * 1.5 + 0.2, 0.0, 1.0);

    float pattern = getPattern(uv);
    float pulse = sin(length(uv) * 10.0 - iTime * 4.0) * 0.5 + 0.5;
    float energyMask = (1.0 - smoothstep(0.0, 0.12, abs(pattern))) * pulse;

    vec3 clayBase = vec3(0.55, 0.24, 0.11);
    vec3 clayDark = vec3(0.12, 0.05, 0.02);
    vec3 energyColor = vec3(2.5, 0.5, 0.05);

    vec3 albedo = mix(clayDark, clayBase, smoothstep(0.0, 0.2, h));
    
    vec3 col = albedo * (diff * vec3(1.0, 0.9, 0.8) + 0.1) * ao;
    col += vec3(0.9, 0.8, 0.7) * spec * 0.4 * ao;
    col += energyColor * energyMask * 1.8;

    float subSurface = smoothstep(0.0, 0.1, energyMask) * 0.3;
    col += vec3(0.8, 0.2, 0.0) * subSurface;

    fragColor = vec4(col, 1.0);
}
