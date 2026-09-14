
void mainImage(out vec4 k, in vec2 l) {
    vec2 m = l / iResolution.xy * .6 - vec2(.4, -.6);
    vec3 n = vec3(m, .3), f = vec3(.7, -8., -2.7), g = vec3(0.);
    float c = 0., d = 0., b = 0.;
    vec3 h[8] = vec3[8](
        vec3(.98, .7, .75), vec3(.98, .82, .65),
        vec3(.99, .96, .68), vec3(.72, .93, .78),
        vec3(.67, .88, .95), vec3(.73, .76, .96),
        vec3(.88, .72, .95), vec3(.95, .75, .87)
    );
    for (float e = 0.; e < 90.; ++e) {
        float o = clamp(min(c * b, .6) / 41.3, 0., 1.), i = mod(e * .15 + c * 2. + iTime * .2, 8.);
        int j = int(i), p = (j + 1) & 7;
        g += o * mix(h[j], h[p], smoothstep(0., 1., fract(i)));
        b = .7;
        f += n * c * d * .4 + 1e-4;
        vec3 a = f;
        d = max(length(a), 1e-4);
        a = vec3(log(d) - iTime * .7, exp(-a.z / d) + .23, atan(a.y, a.x));
        a.y -= 1.;
        c = a.y;
        for (; b < 1603.; b += b) {
            c += dot(sin(a.zxx * b), .9 - cos(a.yzy * b)) / b * .28;
        }
    }
    k = vec4(g, 1.);
}
