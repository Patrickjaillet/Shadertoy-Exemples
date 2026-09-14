
void mainImage(out vec4 O, vec2 C) {
    O = vec4(0);
    vec2 r = iResolution.xy;
    float g = 0., t = iTime, i, s, c, e, d;
    vec3 rd = normalize(vec3((C - r * .5) / r.y, 1)), p, 
         ax = vec3(.7071, .7071, 0), 
         ax1 = normalize(vec3(.5, .6, .5));
    rd = rd * cos(t * .2) + cross(ax1, rd) * sin(t * .2) + ax1 * dot(ax1, rd) * (1. - cos(t * .2));
    for(i = 0.; i < 29.; i++) {
        p = mod(vec3(0, 0, t * 1.5) + rd * g, 4.) - 2.;
        s = sin(t * .8 + g * .1); c = cos(t * .8 + g * .1);
        p = p * c + cross(ax, p) * s + ax * dot(ax, p) * (1. - c);
        e = abs(length(p) - (.8 + .5 * sin(t * 3.3 + g)));
        g += e * .5;
        O.rgb += (.5 + .5 * cos(t + vec3(0, .6, 6.5) + p.z * .5)) * exp(-e * 15.) / (1. + g * g * .1);
    }
    O = vec4(pow(O.rgb, vec3(.4545)), 1);
}
