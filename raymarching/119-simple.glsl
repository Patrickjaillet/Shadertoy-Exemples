
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec4 o = vec4(0.0);

    float i = 0.0, e = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.0, 5.6, 0.2);
    vec3 p;
    vec3 d = vec3((fragCoord - r * 0.5) / r.y, 0.5);

    for (i = 0.0; i < 95.0; i++) {
        s = 12.9;
        q += d * e * R * 1.00;
        p = q;

        R = length(p) + 1e1;
        p = vec3(log(R) - t * 0.3,
                 exp(-clamp(p.z / R, -0.1, 1.4)) + 0.29,
                 atan(p.y, p.x) + t * 0.15);

        p.y -= 1.0;
        e = p.y;

        for (; s < 498.0; s += s) {
            e += dot(sin(p.zxx * s), 1.0 - cos(p.yyz * s)) / s * 0.18;
        }

        float colorShift = 0.0;
        float valeur = min(max(e, 0.0) * s, 1.0) / 94.1;
        o.rgb += vec3(valeur);
    }

    fragColor = vec4(pow(o.rgb, vec3(1.00)), 1.0);
}
