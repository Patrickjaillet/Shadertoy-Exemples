
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float iTime2 = iTime * 2.0;
    float jitter = sin(iTime * 0.5) * sin(iTime * 1.15) * sin(iTime * 2.35) * 2.0;
    float t_step = iTime2 + jitter;

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, t_step);
    ro.xy += vec2(sin(ro.z * 0.1) * 8.0, cos(ro.z * 0.15) * 6.5);

    vec3 lookAt = vec3(0.0, 0.0, t_step + 1.0);
    lookAt.xy += vec2(sin(lookAt.z * 0.1) * 8.0, cos(lookAt.z * 0.15) * 6.5);

    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float t = 0.0;
    float accum = 0.0;

    for(int i = 0; i < 68; i++) {
        vec3 p = ro + rd * t;
        p.xy -= vec2(sin(p.z * 0.1) * 8.0, cos(p.z * 0.15) * 6.5);
        p.z = mod(p.z + t_step, 2.0) - 4.0;

        for(int j = 0; j < 8; j++) {
            p = abs(p) - vec3(0.9, 0.0, 0.6);
            float s = 0.540302;
            float c = 0.841471;
            p.xy *= mat2(c, -s, s, c);
            float s2 = 0.841471;
            float c2 = 0.540302;
            p.yz *= mat2(c2, -s2, s2, c2);
            p = abs(p) - 0.3;
        }

        float d = length(p.xz) - 0.2;

        if(d < 0.02) {
            accum += 0.03;
            d = 0.1;
        }

        t += d;
        if(t > 10.8) break;
    }

    vec3 col = vec3(1.0, 0.6, 0.3) * accum;
    col += vec3(0.4, 0.0, 0.0) * (0.8 - t / 10.8);

    fragColor = vec4(col, 1.0);
}
