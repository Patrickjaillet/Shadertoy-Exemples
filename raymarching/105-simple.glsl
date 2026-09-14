
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec4 o = vec4(0.0);

    float i = 0.0, e = 0.0, R = 1.0, s = 0.0;

    vec3 q = vec3(0.0), p = vec3(0.0);

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    vec3 d = vec3(uv * 0.6, 1.0);

    q.z -= 1.0;

    for(; i++ < 80.0;)
    {

        s = 3.0;

        p = q += d * e * R * 0.52;

        float rSphere = length(p);

        float sphereMask = smoothstep(4.8, 1.0, rSphere);

        R = length(p * 1.7);

        p = vec3(
            log(R + 1e-4),
            exp2(-p.z / (R + 1e-4)),
            atan(p.y, p.x + 1e-4 * step(length(p.xy), 1e-6)) - iTime*0.3
        );

        e = --p.y;

        for(; s < 1000.0; s += s)

            e += cos(dot(sin(p*s), cos(p.yyz*s + iTime*0.9))) / s * 0.45;

        float val = clamp((e*s - 1.0) / 24.2, 0.1, 1.0);

        val *= sphereMask;

        vec4 w = smoothstep(vec4(0.0, 0.15, 0.35, 0.65), vec4(0.15, 0.35, 0.65, 0.88), vec4(val));

        vec3 col = mix(mix(vec3(0.30, 0.00, 0.00), vec3(1.00, 0.08, 0.00), w.x), vec3(1.00, 0.45, 0.00), w.y);

        col = mix(col, vec3(1.00, 0.95, 0.15), w.z);

        col = mix(col, vec3(1.20, 1.15, 1.05), w.w);

        col = mix(col, vec3(0.25, 0.60, 2.00), smoothstep(0.88, 1.0, val));

        float flicker = 0.9 + 0.6 * sin(iTime * 15.0 + q.z * 14.0 + e * 6.0);

        o.rgb += col * val * flicker * 0.03 * step(0.001, val);
    }

    o.rgb = o.rgb / (1.0 + o.rgb);

    o.rgb = pow(o.rgb, vec3(0.6750));

    fragColor = vec4(o.rgb, 1.0);
}
