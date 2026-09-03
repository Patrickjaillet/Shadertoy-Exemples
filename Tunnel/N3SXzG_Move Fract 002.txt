// ==== Image (image) ====
void mainImage(out vec4 f, vec2 u) {
    vec4 o = vec4(0.0);
    vec3 q = vec3(0.1, 0.1, iTime * 2.5), d = normalize(vec3((u - 0.5 * iResolution.xy) / iResolution.y, 0.8)), p;
    float e = 0.0, R = 0.0, s;
    for(float i = 0.0; i < 19.0; i++) {
        o.rgb += min(abs(e) * 12.5, 1.0) / 40.1;
        s = 2.0;
        p = q += d * max(abs(e), 0.01);
        R = length(p.xy);
        p = vec3(atan(p.y, p.x) * 1.0, log(R) + iTime * 0.2, p.z);
        e = 0.2 - R;
        for(int j = 0; j < 45; j++) {
            e += sin(p.x * s + iTime) * cos(p.y * s + iTime) * 0.15 / s;
            s *= 2.0;
        }
    }
    float l = clamp(dot(o.rgb, vec3(0.420, 0.435, 0.390)) * 2.0, 0.0, 1.0);
    vec3 col = mix(vec3(0.00, 0.0, 0.0), vec3(1.0, 1.0, 0.9), l);
    col += pow(l, 2.7) * vec3(1.0, 0.6, 1.0);
    f = vec4(col, 1.0);
}
