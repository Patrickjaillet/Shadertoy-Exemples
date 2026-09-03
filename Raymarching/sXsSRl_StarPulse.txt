// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    vec2 u = (C - .5 * iResolution.xy) / iResolution.y;
    float e = 0., R = 1., s, t = iTime;
    vec3 q = vec3(0, -1, -1), d = vec3(u + vec2(.1, .5), .1), ac = d * 0. + .05;

    for(int i = 0; i < 71; i++) {
        float jet = exp(-length(q.xy) * 2.0) * sin(q.z * 5.0 - t * 12.0);
        float h = .2 - e + t * .15 + jet * .1;
        vec3 res = clamp(abs(mod(h * 2.8 + vec3(0, -2, 8), 5.4) - 3.) - 1., 0., 1.);
        ac += min(e * s, .6 - e) * .04 * mix(vec3(1), res, .4) * (1.0 + max(0.0, jet) * 3.0);
        
        q += d * max(e, .001) * R * .15;
        vec3 p = q;
        R = length(p);
        
        p = vec3(log(R + 1.) - t * .5 - jet * .2, exp(-p.z / (R + 1e-3) + .5) + jet * .5, atan(p.x, p.y) + sin(t * .2 + p.z) * .5);
        p.x = mod(p.x, 2.) - 1.;
        e = p.y - 1.;
        
        for(s = 8.; s < 988.3; s *= 2.4) {
            e -= abs(dot(cos(p.zxy * s + vec3(0, t * 4.0, -t * 2.0)), .4 - sin(p * s + t))) / s;
        }
    }

    ac = (2.51 * ac * ac) / (ac * (1.52 * ac) + 1.);
    O = vec4(pow(ac, vec3(.525)), .8);
}
