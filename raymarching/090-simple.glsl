// ==== Image (image) ====
// https://github.com/Patrickjaillet
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, 0.1);
    vec3 rd = normalize(vec3(uv, 1.0));
    vec3 p = ro;
    float totalDist = 0.0;
    vec3 col = vec3(0.0);
    float t = iTime;
    float s = sin(2.3), c = cos(2.3);
    mat2 rot = mat2(c, -s, s, c);
    for (int i = 0; i < 58; i++) {
        vec3 q = p;
        q.yz *= rot;
        float v = 0.5;
        for (int j = 0; j < 12; j++) {
            float l = length(q.xy);
            v *= l;
            q = vec3(
                log2(max(v, 0.0000)) - q.z / (l + 0.0000) * 1.0 - t,
                atan(q.y, q.x) * 8.0,
                q.z / (l + 0.01) + 0.2
            );
            q.xy = fract(q.xy + q.x) - 0.5;
        }
        float d = q.z * v;
        if (abs(d) < 0.0001 || totalDist > 10.0) break;
        p += rd * d;
        totalDist += d;
        col += vec3(0.3, 0.0, 0.6) * 0.05 / (0.9 + d * d);
    }
    fragColor = vec4(col, 1.0);
}
