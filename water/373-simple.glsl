// ==== Image (image) ====
void mainImage(out vec4 o, vec2 i) {
    vec3 r = vec3((i - .5 * iResolution.xy) / iResolution.y, 1), 
         p = vec3(0, 3, iTime), d;
    float t = 0., h = 0., e, s;
    for(int j = 0; j < 80; j++) {
        d = p + t * r;
        h = 0.;
        s = .5;
        for(int k = 0; k < 6; k++) {
            vec2 v = d.xz * s + iTime * .2;
            h += (1. - abs(sin(v.x + sin(v.y)))) * (1. / s);
            s *= 2.2;
        }
        e = d.y - h * .2;
        if(e < .001 || t > 40.) break;
        t += e * .6;
    }
    vec3 c = mix(vec3(.1, .4, .5), vec3(.7, .8, .9), smoothstep(0., 1., r.y + .2));
    float f = pow(1. - max(dot(normalize(vec3(0, 1, 0)), -r), 0.), 5.);
    o = vec4(mix(c, vec3(.5, .7, .8) * (1. + h), f + exp(-t * .05)), 1);
}
