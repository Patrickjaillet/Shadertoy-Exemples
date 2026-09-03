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
    vec2 r = iResolution.xy;

    vec2 letterboxUV = fragCoord / r;
    if (letterboxUV.y < 0.08 || letterboxUV.y > 0.92) {
        fragColor = vec4(0.0);
        return;
    }

    float bpm = 72.0;
    float period = 60.0 / bpm;
    float t = mod(iTime, period);

    float p1 = exp(-28.0 * t) * sin(6.283185 * 45.0 * t);
    float t2 = max(0.0, t - 0.22);
    float p2 = exp(-32.0 * t2) * sin(6.283185 * 38.0 * t2);
    float pulse = clamp(abs(p1 * 0.7 + p2 * 0.4), 0.0, 1.0);

    vec2 centerUV = (fragCoord - 0.5 * r) / r.y;
    float distFromCenter = length(centerUV);

    float pathT = iTime * 0.15;
    vec3 camPos = vec3(
        sin(pathT) * 0.6,
        cos(pathT * 0.8) * 0.4,
        -1.8 + sin(pathT * 0.5) * 0.3
    );

    vec3 target = vec3(0.0, 0.0, 0.0);

    vec3 forward = normalize(target - camPos);
    vec3 worldUp = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(worldUp, forward));
    vec3 up = cross(forward, right);

    float roll = sin(pathT * 0.4) * 0.08;
    mat2 rollMat = mat2(cos(roll), -sin(roll), sin(roll), cos(roll));
    right.xy = rollMat * right.xy;
    up.xy = rollMat * up.xy;

    vec2 u = vec2(2.5 + pulse * 3.0, 0.);
    vec2 coords[3];
    coords[0] = fragCoord;
    coords[1] = fragCoord + u.xy;
    coords[2] = fragCoord + u.yx;

    float heights[3];
    float sampleI = 0.0;

    for (int idx = 0; idx < 3; idx++) {
        vec2 d = coords[idx];
        vec2 uv = (d + d - r) / r.y;

        vec3 ray = normalize(uv.x * right + uv.y * up + forward * 2.2);
        vec2 p = ray.xy + camPos.xy;

        vec2 l = p * (.3696 + pulse * 0.05) + vec2(.4, -.7);
        vec2 a = l / 223.2 + vec2(-.5585395, .5424);
        vec2 b = vec2(0.);

        float m = length(l - a) * length(a);
        float f, g, h = 1., e = 0., i = 0., c = 0., s_val = 1e13, j = 0., t_val = 0.;

        for (float n = 0.; n < 256.; n++) {
            float r2 = dot(b, b) + .00117;
            float z = sin(2. / r2 + iTime * (1.0 + pulse)) * .0000109 * n;

            float q_sin = sin(z), a_cos = cos(z);
            mat2 rot = mat2(a_cos, -q_sin, q_sin, a_cos);
            vec2 A = rot * a;

            b = vec2(b.x * b.x - b.y * b.y, 2.0 * b.x * b.y) + A;

            c = dot(b, b);
            if (c > s_val) break;

            f = length(b - l + a);
            g = abs(f - m);
            float denom = f + m - g;
            if (denom != 0.) {
                e = h;
                h += (length(b) - g) / denom;
                i++;
            }
        }

        if (i > 0.) {
            h /= i;
            e /= i;
            if (c > 0.) {
                c = abs(log(c) / 2.612);
                if (c > 0.) t_val = (log(abs(log(s_val)) / 1.98) - log(c)) / log(1.088);
            }
            j = e + (h - e) * (t_val + 2.);
            j = j * (4.374 + pulse) / 1.7172 + .607;
        }
        heights[idx] = j;
        if (idx == 0) sampleI = i;
    }

    float o = heights[0];
    float C = heights[1];
    float D = heights[2];

    float bumpFactor = 12.0 + pulse * 8.0;
    vec3 normal = normalize(vec3((o - C) * bumpFactor, (o - D) * bumpFactor, 0.15));

    vec3 lightDir = normalize(vec3(-0.6 + sin(iTime * 0.3) * 0.4, 0.7 + cos(iTime * 0.2) * 0.3, 0.9));
    vec3 viewDir = vec3(0.0, 0.0, 1.0);

    float diff = max(dot(normal, lightDir), 0.0);
    float spec = pow(max(dot(reflect(-lightDir, normal), viewDir), 0.0), 32.0);
    float ambient = 0.15;

    vec4 color = vec4(o, .3425 - o, o - .328, 0.);
    color = fract(clamp(fract(color + .7215), .2545, 1.) + .252);
    color = .439 + .5 * cos(6.4935 * color * (2.004 - floor(color + color)));
    color.x = .854 - color.x;

    vec4 finalColor = color * (ambient + diff * 1.3) + vec4(spec * (1.2 + pulse * 0.8));

    float glowDensity = sampleI / 256.0;
    vec3 glowColor = vec3(0.2, 0.5, 1.0) * pow(glowDensity, 1.5) * (2.5 + pulse * 2.0);
    vec3 bloomSpec = vec3(1.0, 0.85, 0.6) * pow(glowDensity, 3.0) * 4.0;

    finalColor.rgb += glowColor + bloomSpec;

    float vignette = smoothstep(1.2, 0.4, distFromCenter);
    finalColor.rgb *= vignette;

    fragColor = finalColor;
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
    float bpm = 72.0;
    float period = 60.0 / bpm;
    float t = mod(time, period);

    float pulse1 = exp(-28.0 * t) * sin(6.283185 * 45.0 * t);
    
    float t2 = max(0.0, t - 0.22);
    float pulse2 = exp(-32.0 * t2) * sin(6.283185 * 38.0 * t2);

    float sig = (pulse1 * 0.7 + pulse2 * 0.4) * 0.8;

    return vec2(clamp(sig, -1.0, 1.0));
}
