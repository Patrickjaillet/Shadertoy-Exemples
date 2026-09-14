
void mainImage(out vec4 O, vec2 U) {
    O = vec4(.08, .07, 0, 1);

    float d = 0., 
          t = iTime, 
          c = cos(t *= .25), 
          s = sin(t), 
          m, l;

    vec3 p, k = vec3(4.8, 1.1, 3.5);

    for (int i = 0; i++ < 35;) {
        p = vec3((U + U - iResolution.xy) / iResolution.y * (.52 + .13 * sin(t * 3.2)), d - .6);
        p.yz *= mat2(c, -s, s, c);
        m = .7;

        for (int j = 0; j++ < 39;)
            m *= l = max(1.02, 10.9 / dot(p, p)),
            p = vec3(-.2, k.z, 2.2) - abs(abs(p) * l - k);

        d += length(p.xy) / m;
        l = log2(m) / d / 13385.6;
        O.rgb += (vec3(.6, .45, .1) + clamp(l + l, 0., 1.) * vec3(.4, .4, .2)) * l;
    }
}
