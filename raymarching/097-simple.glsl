// ==== Image (image) ====
void mainImage(out vec4 C, vec2 U) {
    vec3 R = iResolution,
         D = vec3((U+U-R.xy)/R.y, 2) * mat3(-67, 48, 0, 37, -87, 75, 0, 75, 66) * .01,
         p = vec3(0, -17, 1),
         a = vec3(0), L;
    float d = 1., r = 0., s, i = 0.;
    for (; i++ < 80.; p += D * d * r * .3) {
        a += min(d * s, .6 - d) * .075;
        r = length(p);
        L = vec3(log(r) - iTime * .5, exp(-p.y / r + .5), atan(p.x, p.z));
        d = L.y - 1.;
        for (s = 8.; s < 1e3; s += s)
            d -= abs(dot(sin(L.yzx * s), .5 - cos(L * s))) / s * .5;
    }
    C = vec4(a * (1.95 * a + .03) / (a * (2.11 * a + .43) + .19), 1);
}
