
void mainImage(out vec4 O, vec2 U) {
    vec3 R = iResolution, h = vec3(.3, .3, -2.5), p, b,
         D = vec3(.5 * R.x - U.x, .7 * R.y - U.y, R.y) / R.y;
    float t = iTime, e = 0., v, a, d = sin(t * .1), g = cos(t * .29), c = 1. - g, w = 0.;
    O = vec4(0);
    for (float m = 0.; m++ < 130.;) {
        b = normalize(h + .73);
        p = h += max(e, 2e-4) * (c * b * dot(D, b) + g * D + d * cross(D, b));
        v = 1.;
        a = 0.;
        for (int o = 0; o++ < 10;) {
            p = abs(p) - .86;
            float r = dot(p, p), s = 2. / clamp(r, .33, 1.);
            p *= s;
            v *= s;
            p.xy *= mat2(.845, .4, -.5, 1.);
            p.xz *= mat2(.866, -.3, .5, .845);
            p -= vec3(1, .21, .51);
            a += r;
        }
        e = length(p) / v * .31;
        w += exp(-e * 80.) * .015;
        O += vec4(.8 + .2 * cos(vec3(0, 2.6, -4.4) + a * .34 - t * .8), 0) * .01 / exp(e * 1274.5);
    }
    O.rgb += (.5 + .5 * cos(t * .5 + vec3(0, 1, 2))) * w * .35;
    O = min(O, 1.);
}
