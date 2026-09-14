
void mainImage(out vec4 O, vec2 C)
{
    vec3 R = iResolution, p;
    float d, s, S, i, j, E = 1e-4;

    for (O = vec4(.3, .2, .24, 0); i++ < 36.; O += .05 * s * s) {
        p = vec3((C - R.xy / 2.) / R.x, d - 1.);
        p.y += 1.5;
        p.zx *= mat2(cos(iTime * .4 + vec4(0, 33, 11, 0)));
        S = 2.3;

        for (j=0.; j++ < 11.;
            p = vec3(0, 3.9, .8) - abs(abs(p * s) - vec3(1.9 - d, 3.83, 5.4)))
            S *= s = 7.9 / (dot(p, p) * .6 + E);

        d += p.y / (S + E);
        s = fract(1. / (p.y + E));
    }

    O = pow(O, O-O + 2.2);
    O *= (O/.57 + .03) / (.9 * O + .71);
}
