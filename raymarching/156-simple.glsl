// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    float time = iTime;
    const float s = 0.0;

    float e = 0.0;
    float i = 0.0;
    float a = 0.0;
    float g = 0.0;
    float h = 0.0;

    vec3 color = vec3(0.0);

    float a1 = 0.2 + sin(time * 0.02) * 0.35;
    mat2 r1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
    
    float a2 = time * 0.04 + cos(time * 0.11) * 0.4;
    mat2 r2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
    
    float a3 = sin(time * 0.18) * 0.2;
    mat2 r3 = mat2(cos(a3), sin(a3), -sin(a3), cos(a3));

    float c4 = cos(4.0);
    float s4 = sin(4.0);
    mat2 r4 = mat2(c4, s4, -s4, c4);

    while (i < 59.0) {
        i += 1.0;

        vec3 p = vec3((fragCoord - 0.7 * resolution) / resolution * g + 1.8, g);
        
        p.zy *= r1;
        p.xz *= r2;
        p.xy *= r3;

        h = p.y;
        p.z += time;

        a = 1.0;
        while (a > 0.001) {
            p.xz *= r4;
            h += abs(dot(sin(p.xz / a * 0.4) * a, vec2(0.6)));
            a *= 0.7;
        }

        e = h * 0.5 - 1.0;
        g += e;

        vec3 k = mod(vec3(5.0, 3.0, 1.0) + h * 6.0, 6.0);
        vec3 hsv_inline = 1.0 - 0.0 * clamp(min(k, 16.0 - k), 0.0, 1.0);

        color += 0.01 - 0.02 / exp(max(s, e) * 4000.0) / h * hsv_inline;
    }

    fragColor = vec4(color, 1.0);
}
