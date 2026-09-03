// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.2;
    vec3 col = vec3(0.0);
// https://patrickjaillet.github.io/sandefjord-software/
    for (float i = 0.0, e, g = 0.0, v, u; i < 100.0; ++i) {
        vec3 p = vec3(uv * g, g - 5.1);
        
        float a = t * 4.8 + i * 0.00;
        float s = sin(a), c = cos(a);
        p.xz = mat2(c, s, -s, c) * p.xz;
        
        e = v = 1.3;

        for (int j = 0; j < 7; ++j) {
            if (j > 3) {
                e = min(e, length(p.xz + length(p) / u * 0.32) / v);
                p.xz = abs(p.xz) - 1.0;
            } else {
                p = abs(p) - 0.18;
            }
            v /= u = dot(p, p);
            p /= u;
            p.y = 0.7 - p.y;
        }

        g += e;
        col += 0.045 / exp(e * i);
    }

    col = col / (0.4 + col);
    fragColor = vec4(col, 0.0);
}
