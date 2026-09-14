// ==== Image (image) ====
void mainImage(out vec4 O, vec2 I) {
    vec3 r = iResolution, d = vec3(I - .5 * r.xy, r.y), q = vec3(0, .8, -.9), p;
    O = vec4(.1);
    for (float i = 0., e = 0., s, g, k; i++ < 24.;) {
        g = min(e * s, .4 - e) * .04;
        k = clamp(g * 15., 0., 1.);
        O.rgb += mix(mix(mix(mix(vec3(.01, .15, .95), vec3(.95, .08, .01), step(.2, k)), vec3(1, .45, .02), smoothstep(.18, .45, k)), vec3(1, .95, .35), smoothstep(.4, .85, k)), vec3(1), smoothstep(.8, 1., k)) * g * 4.2;
        p = q += normalize(d) * max(abs(e), .005) * .3;
        p = vec3(log(length(p) + 1.) - iTime * .5, exp(-p.y / (length(p) + .01) + .5), atan(p.x, p.z));
        e = length(p.yz * .5) - .2;
        for (s = 1.4; s < 1e3; s *= 2.) {
            p = abs(p) - vec3(.8, .2, .5);
            e += mix(-abs(dot(cos(p.zxy * s), .2 - sin(p * s))), -abs(dot(sin(p.yzx * s), .2 - cos(p * s))), sin(iTime * .52) * .5 + .5) / s * .4;
        }
    }
    O = pow(max(O, 0.), vec4(.45));
}
