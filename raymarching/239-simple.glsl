
void mainImage(out vec4 O, vec2 C) {

    O = vec4(0);

    vec3 d = normalize(vec3((C * 2. - iResolution.xy) / iResolution.y * .53, 1)), q = vec3(0, 0, -2.22), p;

    float i = 0., e = 0., R = 0., s, n, a, v;

    for (; i++ < 74.;) {

        p = q += d * e * R * .35;

        R = length(p * .21);

        p = vec3(log(R + 1e-4), exp2(-p.z / (R + 1e-4)), atan(p.y, p.x + 1e-4 * step(length(p.xy), 1e-6)) - iTime * .28);

        e = --p.y;

        for (s = 12., a = .45; s < 8192.; s *= 2., a *= .48)

            e += a * cos(dot(sin(p * s), cos(p.yyz * s + iTime * .92)));

        v = clamp(e * s, .1, .6) * smoothstep(5.2, .8, length(q));

        if (v > .001)

            O.rgb += mix(vec3(1, .12, 0), 
            vec3(1, .48, 0), smoothstep(.12, .32, v)) * v * (1. + sin(iTime * 14. + q.z * 18. + e * 8. + p.x * 6.)) * .12;
    }

    O.rgb = pow(O.rgb / (1. + O.rgb * .92), vec3(.68));
}
