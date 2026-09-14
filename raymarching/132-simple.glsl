
void mainImage(out vec4 O, vec2 C) {
    vec2 r = iResolution.xy;
    vec2 u = (C - 0.5 * r) / r.y;
    O = vec4(0.0);

    float t = iTime * 0.15;
    float pulseBase = sin(iTime * 2.5) * 0.5 + 0.5;
    float pulseFast = sin(iTime * 8.0 + cos(iTime * 4.0)) * 0.5 + 0.5;
    float pulseComplex = mix(pulseBase, pulseFast, 0.35);

    float g = 0.0, i = 0.0, e, v, q;
    for (; i++ < 110.0 && g < 14.0;) {
        vec3 p = vec3(u.x, 11.0 - g, u.y);
        float a = t + pulseBase * 0.04, s = sin(a), c = cos(a);
        p.xz *= mat2(c, -s, s, c);

        e = 0.3;
        v = 1.6 + pulseComplex * 0.25;

        for (int j = 0; j < 11; j++) {
            q = dot(p, p) + 0.0008;
            v /= q;
            p /= q;
            p.y = (1.8 + pulseFast * 0.08) - p.y;

            if (j > 3) {
                float pulseMod = sin(float(j) * 1.5 + iTime * 5.0) * 0.5 + 0.5;
                e = min(e, length(p.xz) / v - (0.004 + pulseMod * 0.005));
                p.xz = abs(p.xz) - (0.2 + pulseComplex * 0.03);
            } else {
                p = abs(p) - (0.23 + pulseBase * 0.02);
            }
        }

        g += max(e, 0.0008);

        vec3 h = vec3(0.25 - log(v) * 0.65 + pulseComplex * 0.1, 0.85 + pulseFast * 0.15, 1.0),
             K = vec3(1.0, 0.33333, 0.66667),
             rgb = h.z * mix(K.xxx, clamp(abs(fract(h.xxx + vec3(0.0, K.yz)) * 6.0 - 3.0) - K.xxx, 0.0, 1.0), h.y);

        float accum = 0.025 * exp(-e * (180.0 - pulseFast * 40.0));
        O.rgb += rgb * accum * (1.0 + pulseFast * 0.5);
    }

    vec3 color = O.rgb / (1.0 + O.rgb);
    color = pow(color, vec3(0.4545));
    O = vec4(color, 1.0);
}
