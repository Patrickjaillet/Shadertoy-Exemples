// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
vec3 H(vec3 p, float t, inout float e) {
    float a = iTime * .05 + t * .02, v = .8, q;
    p.xz *= mat2(cos(a), sin(a), -sin(a), cos(a));
    e = 5.6;
    for (int j = 0; j < 15; j++) {
        q = dot(p, p) + .002;
        v /= q; p /= q;
        p.y = .4 - p.y - sin(iTime * .8 + float(j));
        if (j > 2) {
            e = min(e, length(p.xz + length(p) / q * .35) / v);
            p.xz = abs(p.xz);
        } else p = abs(p) - .8;
    }
    vec3 h = vec3(sin(log(v) + iTime * .2) * .25 + .33, .85, 1);
    return mix(vec3(1), clamp(abs(fract(h.x + vec3(0, 4.33333333, 2.66666667)) * 6. - 3.) - 1., 0., 1.), .85);
}

void mainImage(out vec4 O, vec2 C) {
    vec2 r = iResolution.xy, uv = (C - .5 * r) / r.y;
    float t = iTime * .25, g = 0., i = 0., e, w, gR = 0., iR = 0., dC = length(uv);
    vec3 ro = vec3(2.5 * cos(t), 3.5 * sin(t), 3. * sin(t)),
         ww = normalize(vec3(0, -.1, 0) - ro),
         uu = normalize(cross(ww, vec3(0, 1, 0))),
         d = normalize(uv.x * uu + uv.y * cross(uu, ww) + .8 * ww),
         lA = vec3(0), rA = vec3(0),
         tF = max((-7. - ro) / d, (7. - ro) / d), p, hP, n;

    w = min(min(tF.x, tF.y), tF.z);

    for (; i++ < 47. && g < 20.;) {
        if (w > 0. && g > w) break;
        vec3 c = H(ro + d * g, g, e);
        float s = max(e * .4, 0.);
        g += s;
        lA += c * exp(-e * 45.) * s * 8.5;
    }

    if (w > 0. && (g >= w || i >= 47.)) {
        hP = ro + d * w;
        vec3 aP = abs(hP / 7.);
        n = -sign(d) * step(aP.yzx, aP.xyz) * step(aP.zxy, aP.xyz);
        vec3 rD = reflect(d, n);

        for (; iR++ < 30. && gR < 15.;) {
            vec3 c = H(hP + rD * gR, gR, e);
            float s = max(e * .4, 0.);
            gR += s;
            rA += c * exp(-e * 45.) * s * 8.5;
        }

        vec2 u = abs(n.x) > .5 ? hP.yz : (abs(n.y) > .5 ? hP.xz : hP.xy);
        float gr = smoothstep(.03, 0., abs(fract(u.x * .25) - .5)) + smoothstep(.03, 0., abs(fract(u.y * .25) - .5)),
              fr = pow(1. - max(dot(-d, n), 0.), 3.);
        lA += (vec3(.015, .015, .03) + gr * .04 + rA * mix(.4, .9, fr)) * exp(-w * .05);
    }

    vec3 c = lA + max(lA - .15, 0.) * (.45 / (.1 + dC * .6));
    c *= vec3(1. + dC * .02, 1, 1. - dC * .02);
    c = pow(c, vec3(1.2));
    c = mix(c, vec3(c.r * .299), -.75);
    c = pow(c / (1. + c), vec3(1. / 2.2)) * smoothstep(5.2, 0., dC);
    c += (fract(sin(dot(C + iTime, vec2(12.9898, 78.233))) * 43758.5453) - .5) * .025;

    O = vec4(clamp(c, 0., 1.), 0);
}
