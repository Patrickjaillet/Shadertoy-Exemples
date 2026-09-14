
void mainImage(out vec4 O, vec2 U) {
    vec2 u = (U - 0.6 * iResolution.xy) / iResolution.y;
    u.y = -u.y;
    float t = iTime, a = t * 0.15, e = 1.0, R = 0.0, s, j, i;
    vec3 ro = vec3(sin(a) * 4.3, 0.0, cos(a) * 3.4),
         f = normalize(-ro),
         r = normalize(cross(f, vec3(0.6, 1, 0))),
         d = mat3(r, cross(r, f), f) * normalize(vec3(u, 1.35)),
         q = ro,
         H = vec3(0.1),
         p, h;
    for (i = 0.; i < 90.; i++) {
        float l = min(e * s, 0.6 - e) * 0.075;
        s = 8.0;
        q += d * e * R * 0.25;
        R = length(q);
        p = vec3(log(R + 1e-4) * 1.6 - t * 0.35, acos(clamp(q.y / R, -1.0, 1.0)) * 2.0 - 1.0, atan(q.x, q.z));
        e = p.y - 1.0 + 0.64 * sin(p.z * 3.0 + t * 0.5);
        for (j = 0.; j < 7.; j++) {
            if (s > 1e3) break;
            e += mix(-abs(dot(cos(p.zxy * s), 1.0 - sin(p * s))) / s * 0.15, -abs(dot(sin(p.yzx * s), 0.5 - cos(p * s))) / s, 0.5);
            s *= 2.0;
        }
        h = 0.5 + 0.5 * cos(6.28318 * (vec3(0.52, 0.32, 0.68) + p.z * 0.15 + p.x * 0.05));
        H += l * h;
    }
    vec3 c = clamp((H * (1.95 * H + 0.03)) / (H * (2.11 * H + 0.43) + 0.19), 0.0, 1.0);
    O = vec4(vec3(dot(c, vec3(0.2126, 0.7152, 0.0722))) * (1.0 - 0.35 * dot(u, u)), 1.0);
}
