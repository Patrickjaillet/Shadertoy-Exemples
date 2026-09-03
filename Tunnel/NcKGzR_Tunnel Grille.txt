// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 FC) {
    o = vec4(0.0);
    float e = 0.0, i = 0.0, s = 0.0, d = 0.0, t = iTime * 0.5;
    vec2 u = (FC * 1.8 - iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, t * 1.5);
    vec3 rd = normalize(vec3(u, 1.0));
    
    float a = t * 0.0;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    rd.xy *= R;

    for (; i++ < 150.0; ) {
        vec3 p = ro + rd * d;
        vec3 q = p;
        
        p.z = mod(p.z, 2.2) - 1.9;
        
        float ca = p.z * 0.00 + t;
        p.xy *= mat2(cos(ca), -sin(ca), sin(ca), cos(ca));
        
        s = 0.9;
        for (int j = 0; j < 5; j++) {
            p = abs(p) - vec3(0.0, 1.2, 1.0);
            float k = 4.3 / max(dot(p, p), 0.00);
            p = p * k - vec3(1.0, 1.0, 0.3);
            s *= k;
        }

        e = (length(p.xy) - 0.1) / s;
        e = max(e, 0.001);

        d += e * 0.6;

        vec3 c = 1.0 + 1.0 * cos(vec3(0.9, 1.0, 0.0) + log(s) * 0.0 + p.z * 0.0);
        o.rgb += c * (0.002 / (0.035 + e * e * 2000.0)) * exp(-d * 0.54);
    }

    o.a = 0.0;
}
