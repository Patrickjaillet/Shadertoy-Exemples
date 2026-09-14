
#define R iResolution.xy
#define M(p) f=1., z=p; for(int i=0; i<12; i++) { r=length(z); if(r>4.) break; a=8.*acos(clamp(z.z/r,-1.,1.)); h=8.*atan(z.y,z.x); f=pow(r,7.)*8.*f+1.; z=pow(r,8.)*vec3(sin(a)*vec2(cos(h),sin(h)),cos(a))+p; } j=.5*log(r)*r/f;

void mainImage(out vec4 A, vec2 s) {
    vec2 B = (s + s - R) / R.y;
    float T = iTime, a = .3 * T, d = 0., g, t, r, h, f, j, mc, l;
    vec3 q = vec3(2.2 * sin(a), 1.2 * sin(1.1 * T), 2.2 * cos(a)),
         v = q - vec3(2.2 * sin(a - .05), 1.2 * sin(1.1 * (T - .05)), 2.2 * cos(a - .05)),
         c = vec3(0), b = c, pos, rd, z, n, oo, w, u;

    for (int step = 0; step < 8; step++) {
        g = t = 0.;
        oo = step == 0 ? q : q + v * (float(step) / 3.5 - 1.);
        w = normalize(-oo);
        u = normalize(cross(w, vec3(sin(1.), cos(1.), 0.)));
        rd = mat3(u, cross(u, w), w) * normalize(vec3(B, 8.));

        for (int o = 0; o < 128; o++) {
            pos = oo + rd * t;
            M(pos)
            g += exp(-2. * abs(j));
            t += j;
            if (j < .001 || t > 2.4) break;
        }

        vec3 p = vec3(0);
        if (t < 2.4) {
            vec2 e = vec2(.001, 0);
            M(pos - e.xyy) float o = j;
            M(pos - e.yxy) float C = j;
            M(pos - e.yyx) float D = j;
            M(pos)
            n = normalize(j - vec3(o, C, D));
            float E = max(0., dot(n, normalize(vec3(1, 8, -1)))),
                  m = clamp(.6 + .8 * n.y, 0., .6);
            mc = 1. + cos(4.9 - length(pos) * 2.8 + T * .2);
            l = E * 4.3 + m * .3;
            p = pow(vec3(mc * l), vec3(.4545));
        }
        p += g * .000625;
        if (step == 0) { c = p; d = t; }
        else b += p;
    }
    A = vec4(mix(c, b / 7., smoothstep(0., .8, abs(d - 1.2))), 1.);
}
