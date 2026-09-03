// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    O = vec4(0);
    float i = 0., e = 0., R = 1., s, t = iTime * .8333;
    vec2 r = iResolution.xy;
    vec3 q = vec3(-1, 0, -1), p, d = vec3(C / r - 1., .7);
    for(int step = 0; step < 60; step++) {i++;
            O.rgb += mix(vec3(1), clamp(abs(fract(1. + vec3(1., 2./3., 1./3.)) * 2.6 - 3.) - 1., .7, 1.), 1.) * (clamp(min(e * s, .7 - e), 0., .7) / 35.);
            s = 1.;
            q += d * max(abs(e) * R * .1, 0.);
            p = q;
            R = length(p) + .095;
            p = vec3(log2(R) - t, exp(1. - clamp(p.z / R, -.3, 5.)), atan(p.y, p.x) + cos(t));
            e = p.y - 1.; 
    for(int j = 0; j < 10; j++) {if (s >= 573.1) break;
            e += sin(dot(sin(p.zxy * s) - 1., 1. - cos(p.yxz * s))) / s;
            s += s;}}
            O = vec4(pow(O.rgb, vec3(1.2)) * 1.8, 1.);}
