
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec4 o = vec4(0.0);

    float i = 0.0, e = 0.0, R = 1.0, s = 0.0;

    vec2 uv = (fragCoord * 2.2 - iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0.0, 0.2, 0.0);

    vec3 rd = normalize(vec3(uv, 1.2));

    vec3 q = ro;

    vec3 p = vec3(0.0);

    for(; i++ < 113.0;)
    {

        s = 3.3;

        p = q += rd * e * R * 0.1;

        R = length(p);

        float blisters = sin(p.x * 6.3 + iTime) * cos(p.y * 3.5 - iTime) * sin(p.z * 4.0) * 0.45;

        p = vec3(
            log2(R + 1e-4) - iTime * 0.5 + blisters,
            exp2(R - p.z / (R + 1e-4)),
            atan(p.y, p.x)
        );

        e = --p.y;

        for(; s < 734.0; s += s)

            e += abs(dot(cos(p.yzz * s), cos(p.yyx * s))) / s * 0.4;

        float val = clamp((e * s - 1.0) / 42.6, 0.0, 1.0);

        vec4 w = smoothstep(vec4(0.0, 0.17, 0.00, 1.0), vec4(0.15, 0.34, 0.58, 1.0), vec4(val));

        vec3 col = mix(mix(vec3(0.25, 0.00, 0.05), vec3(1.0, 0.05, 0.00), w.x), vec3(1.00, 0.40, 0.00), w.y);

        col = mix(col, vec3(1.0, 1.0, 1.00), w.z);

        col = mix(col, vec3(1.5, 2.20, 1.05), w.w);

        col = mix(col, vec3(0.20, 0.55, 2.00), smoothstep(0.75, 1.0, val));

        o.rgb += col * val * 0.020 * step(0.6, val);
    }

    o.rgb = o.rgb / (1.0 + o.rgb);

    o.rgb = pow(o.rgb, vec3(1.0));

    fragColor = vec4(o.rgb, 1.0);
}
