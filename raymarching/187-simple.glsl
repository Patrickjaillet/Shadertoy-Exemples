
#define R iResolution

#define r(a) mat2(cos(a+vec4(0,11,33,0)))

void mainImage(out vec4 O, vec2 I) {

    vec3 r = iResolution, p, g, st,
         ro = vec3(0, 0, -2.5), 
         rd = normalize(vec3((I - .5 * r.xy) / r.y, 1.2)),
         ink = vec3(.01, .02, .05);

    float t = sin(iTime * .05) * .3, a = 0., d, n = 0., j, k, m, sd, scl, h, ax;

    ro.xz *= r(t);

    rd.xz *= r(t);

    for (int i = 0; i < 90; i++) {

        p = ro + rd * a;

        vec3 q = p;

        q.z += iTime * .5;

        q = mod(q + 4., 8.) - 4.;

        scl = 1.; d = 1e10;

        for (j = 0.; j < 5.; j++) {

            q = abs(q) - .35;

            ax = iTime * .15 + j * .2;

            q.yz *= r(ax);

            q.xz *= r(iTime * .225);

            h = 1.8 / clamp(dot(q, q), .15, 1.);

            q *= h; 

            scl *= h;

            d = min(d, (length(q.xy) - .12 * abs(sin(q.z * 2. + iTime))) / scl);
        }

        d += sin(p.x * 4. + iTime * .15) * cos(p.y * 4. - iTime * .15) * sin(p.z * 4. + iTime) * .04;

        if (d < .01) { 

            n += (.01 - d) * 18.; 

            a += .01; 
        }

        else a += max(d * .45, .008);

        if (a > 14. || n > 4.5) break;
    }

    if (a < 14.) {

        for (int k = 0; k < 3; k++) {

            st = vec3(0); st[k] = .002;
            float d1, d2;

            for (int m = 0; m < 2; m++) {

                vec3 np = p + (m == 0 ? st : -st), q = np;

                q.z += iTime * .5;

                q = mod(q + 4., 8.) - 4.;

                scl = 1.; sd = 1e10;

                for (j = 0.; j < 5.; j++) {
                    q = abs(q) - .35;
                    ax = iTime * .15 + j * .2;
                    q.yz *= r(ax);
                    q.xz *= r(iTime * .225);
                    h = 1.8 / clamp(dot(q, q), .15, 1.);
                    q *= h; scl *= h;
                    sd = min(sd, (length(q.xy) - .12 * abs(sin(q.z * 2. + iTime))) / scl);
                }

                sd += sin(np.x * 4. + iTime * .15) * cos(np.y * 4. - iTime * .15) * sin(np.z * 4. + iTime) * .04;

                if (m == 0) d1 = sd; else d2 = sd;
            }

            g[k] = d1 - d2;
        }

        g = normalize(g);

        n += pow(1. - max(dot(-rd, g), 0.), 3.) * 1.275;

        ink += max(dot(g, normalize(vec3(1, 2, -2))), 0.) * vec3(.02, .05, .1);
    }

    O = vec4(pow(clamp(mix(ink, vec3(.96, .95, .92) - length((I - .5 * r.xy) / r.y) * .22, exp(-n)), 0., 1.), vec3(.95)), 1.);
}
