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
    float t = mod(iTime, 5.0),
          s = floor(iTime / 5.0),
          h = fract(sin(s * 17.31) * 43758.54),
          r = h < 0.2 ? 0.7 : h < 0.5 ? 0.5 : h < 0.8 ? 0.35 : 0.6,
          i = h < 0.2 ? 2.4 : h < 0.5 ? 1.6 : h < 0.8 ? 0.9 : 2.0,
          sr = h < 0.2 ? 12.0 : h < 0.5 ? 28.0 : h < 0.8 ? 50.0 : 18.0,
          st = mod(t, i),
          ls = s * 100.0 + floor(t / i),
          is = step(0.1, st) * (1.0 - step(i * r, st)),
          sm = mix(0.5, 2.5, is) * (sr / 24.0),
          lsn = floor(fragCoord.y * 0.25) + floor(iTime * 60.0 * sm),
          id = mod(floor(fract(sin(lsn) * 43758.54) * 16.0), 16.0);

    vec3 col = vec3(0.9, 0.5, 0.5);
    if (id < 1.0) col = vec3(0.0);
    else if (id < 2.0) col = vec3(0.0, 0.0, 0.4);
    else if (id < 3.0) col = vec3(0.8, 0.0, 0.0);
    else if (id < 4.0) col = vec3(0.0, 0.6, 0.8);
    else if (id < 5.0) col = vec3(0.8, 0.4, 0.0);
    else if (id < 6.0) col = vec3(0.0, 0.8, 0.2);
    else if (id < 7.0) col = vec3(0.9, 0.8, 0.0);
    else if (id < 8.0) col = vec3(0.2, 0.2, 0.8);
    else if (id < 9.0) col = vec3(0.9, 0.0, 0.9);
    else if (id < 10.0) col = vec3(0.0, 0.9, 0.9);
    else if (id < 11.0) col = vec3(0.9);
    else if (id < 12.0) col = vec3(0.4);
    else if (id < 13.0) col = vec3(0.6, 0.0, 0.4);
    else if (id < 14.0) col = vec3(0.2, 0.7, 0.4);

    vec2 p = floor(fragCoord / iResolution.xy * vec2(320.0, 256.0));
    if (step(0.0, st) * (1.0 - step(0.1, st)) > 0.5) {
        float f = fract(sin(p.x + p.y * 31.0 + iTime * 150.0) * 43758.54),
              hl = fract(sin(ls) * 43758.54);
        col = mix(col, vec3(1.0), hl * 0.6 * step(0.5, f));
    }

    if (fract(st * sr * (0.8 + 0.4 * fract(sin(ls * 2.7) * 43758.54))) < 0.15 && is > 0.5) col += 0.2;

    col += sin(fragCoord.y * 0.5 + iTime * 40.0 * sm) * 0.12;
    vec2 q = fragCoord / iResolution.xy;
    col *= pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15);

    fragColor = vec4(col, 1.0);
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
