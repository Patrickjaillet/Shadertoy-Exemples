// ==== Image (image) ====
void mainImage(out vec4 v, in vec2 w) {
    vec2 k = (w - .5 * iResolution.xy) / iResolution.y;
    float s = length(k);
    float x = atan(k.y, k.x);
    float e = log(s) - iTime * .4;
    vec3 b = vec3(0.);
    vec3 h = vec3(0.);
    float f = 0.;
    const int y = 40;
    float l = .08;
    vec3 z = vec3(1., 6., .9);
    vec3 A = vec3(1.2, -3.8, .8);
    for(int t = 0; t < y; t++) {
        float g = iTime * .5 + f * 1.;
        float d = 1.5;
        float i = 1.;
        vec3 noise3 = vec3(0.);
        vec3 a = x * z + iTime * A;
        for(int u = 0; u < 12; u++) {
            vec3 m = vec3(cos(a.x) * 2., sin(a.x) * 2., e * 4.) * d;
            vec3 n = vec3(cos(a.y) * 2., sin(a.y) * 2., e * 4.) * d;
            vec3 o = vec3(cos(a.z) * 2., sin(a.z) * 2., e * 4.) * d;
            m.z += g * d;
            n.z += g * d;
            o.z += g * d;
            noise3.x += dot(sin(m), cos(m.zxy)) * i;
            noise3.y += dot(sin(n), cos(n.zxy)) * i;
            noise3.z += dot(sin(o), cos(o.zxy)) * i;
            d *= 2.;
            i *=.5;
        }
        vec3 c = max(vec3(0.), 1. - abs(noise3));
        c = pow(c, vec3(4.4));
        if(max(c.x, max(c.y, c.z)) > .01) {
            vec3 p = vec3(cos(a.x) * 2., sin(a.x) * 2., e * 4.) + vec3(0., 0., g);
            vec3 q = vec3(cos(a.y) * 2., sin(a.y) * 2., e * 4.) + vec3(0., 0., g);
            vec3 r = vec3(cos(a.z) * 2., sin(a.z) * 2., e * 4.) + vec3(0., 0., g);
            float B = dot(sin(p * 4.), cos(p.zxy * 4.));
            float C = dot(sin(q * 4.), cos(q.zxy * 4.));
            float D = dot(sin(r * 4.), cos(r.zxy * 4.));
            vec3 E = vec3(B, C, D);
            vec3 F = vec3(p.z, q.z, r.z);
            vec3 G = 1. + 1. * cos(vec3(0., 1., 2.) + F * 1. + noise3 * 1.3);
            vec3 H = vec3(1., .6, 0.) * max(vec3(0.), E);
            vec3 I = G * c + H * pow(c, vec3(2.));
            float J = 1. / (1. + f * f * .1);
            b += I * J * l;
            h += c * l;
            if(min(h.x, min(h.y, h.z)) >= .95) break;
        }
        f += l;
    }
    b *= 1.7;
    b = mix(b, vec3(0.), 1. - exp(-.05 * f * f));
    b = pow(b, vec3(.4545));
    b = clamp(b * 1.2, 0., 1.);
    float j = s * .6;
    j = .9 - j * j;
    b *= clamp(j, 0., 1.);
    v = vec4(b, 1.);
}
