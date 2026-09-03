// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 u)
{// https://github.com/Patrickjaillet/Z-GL-Shadertoy
    float t = iTime * 2.0;
    vec3 ro = vec3(cos(t * 0.1) * 8.0, sin(t * 0.1) * 8.0, t);
    vec3 fw = normalize(vec3(cos((t + 2.0) * 0.1) * 8.0, sin((t + 2.0) * 0.1) * 8.0, t + 2.0) - ro);
    vec3 rt = normalize(vec3(fw.z, 1.0, -fw.x));
    vec3 up = cross(fw, rt);
    vec2 v = (u - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rd = normalize(fw * 1.8 + v.x * rt + v.y * up);
    float d = 0.0, s = 0.0;
    vec3 c = vec3(0.0);
    mat2 m = mat2(cos(t * 0.1 + vec4(0, 33, 11, 0)));
    for (int i = 0; i < 70; i++) {
        vec3 p = ro + rd * d;
        float l = 1.0 - length(p.xy - vec2(cos(p.z * 0.1) * 8.0, sin(p.z * 0.1) * 8.0));
        vec3 q = mod(p * 0.5, 2.0) - 1.0;
        float sc = 0.2;
        for (int j = 0; j < 6; j++) {
            q = abs(q) - 0.5;
            q.xy *= m;
            float r = dot(q, q);
            float k = 1.3 / clamp(r, 0.24, 1.0);
            q *= k;
            sc *= k;
        }
        s = length(q.xz) / sc;
        float st = max(l, s);
        d += st * 0.5;
        c += mix(vec3(0.1, 0.4, 0.8), vec3(0.9, 0.2, 0.5), sin(d * 0.2) * 0.5 + 0.5) * (exp(-d * 0.39) / (0.4 + st * 93.8)) * 0.08;
        if (d > 40.0 || c.b > 2.1) break;
    }
    o = vec4(pow(c * 3.2, vec3(0.4895)), 0.7);
}
