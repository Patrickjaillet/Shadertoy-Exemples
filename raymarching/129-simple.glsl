// ==== Image (image) ====
void mainImage(out vec4 o, vec2 f) {
    vec2 r = iResolution.xy,
         u = (f - 0.5 * r) / r.y;
    float t = iTime * 0.28, g = 0.0, e, k, R, a, s;
    vec3 col = vec3(0),
         p, q, w,
         ro = vec3(0.5 * sin(t * 0.6), 0.5 * cos(t * 0.45), -3.0),
         fwd = normalize(vec3(sin(t * 0.15) * 0.2, cos(t * 0.12) * 0.15, 1.0)),
         rgt = normalize(cross(fwd, vec3(0, 1, 0))),
         up = cross(rgt, fwd),
         rd = normalize(u.x * rgt + u.y * up + 1.6 * fwd);

    for (int i = 0; i < 64 && g < 140.0; i++) {
        p = ro + rd * g;
        q = p;
        
        float c = cos(t + 0.21 * p.z),
              sn = sin(t + 0.21 * p.z);
        q.xy *= mat2(c, sn, -sn, c);

        R = max(length(q.xy), 0.005);
        a = atan(q.y, q.x);

        w = vec3(mod(log(R) * 1.8 - t * 4.8, 8.0) - 2.0, a * 1.5, abs(fract(p.z - t) - 0.5) * 4.0 - 1.0);

        s = 1.0;
        for (int j = 0; j < 6; j++) {
            w = abs(w) - 0.5;
            k = 1.4 / dot(w, w);
            w *= k;
            s *= k;
        }

        e = abs(length(w) / s - 0.015);
        col += (0.02 / (0.001 + e * e * 246.6)) * (0.7 + 0.4 * sin(vec3(0, -1.8, -10.1) - a * 0.1 + p.z * 0.8)) * exp(0.02 * g);
        g += max(e * 0.55, 0.01);
    }

    col *= exp(-0.02 * g) * (1.0 - dot(f / r - 0.5, f / r - 0.5));
    o = vec4(clamp(col / (0.5 + col), 0.0, 1.0), 0.2);
}
