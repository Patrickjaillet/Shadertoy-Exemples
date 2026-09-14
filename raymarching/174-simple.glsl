
void mainImage(out vec4 l, vec2 n) {
    vec3 R = iResolution, q = vec3(0), A = q;
    float T = iTime, g = T / 3., m = fract(g), X = 0.;
    m *= m * (3. - 2. * m);
    vec2 o = ((n * 3.2 - R.xy) / R.y + vec2(sin(T * .15) * .5, 0.)) * (1. + .3 * sin(T * .2));

    for (float k = 0.; k < 2.; k++) {
        float d = mod(floor(g) + k, 52.), w = abs(k - 1. + m);
        X += d * w;
        vec3 e = vec3(o * 2.2, 0.), a = e * 0.;

        for (float b = 0.; b++ < 7.;) {
            vec3 h = 1. + mod(vec3(d + b * .2, (d + b) * .5, 0.), 2.);
            e = clamp(e, -h, h) * 2. - e;
            e = e / clamp(dot(e, e), .3, 8.) * (1.6 + mod(d * 2. + b, 4.) * .3) 
                + vec3(sin(d + b), cos(d * .7 + b), sin(d * .5)) * .4;

            float G = d * .6 + b * .4, C = cos(G), S = sin(G);
            mat2 M = mat2(C, -S, S, C);
            e.xy *= M;
            e.xz *= M;
            a += abs(e);
        }
        q += e * w;
        A += a * w;
    }

    vec3 c = .5 + .5 * sin(X * vec3(1.2, 1.8, 2.5) + vec3(0, .5, 1.) + A * .1);
    l = vec4(pow(c / (length(q) + c), vec3(.47)), 0.);
}
