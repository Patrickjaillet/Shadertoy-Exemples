
#define H(p) fract(sin(dot(p, vec3(12.989, 78.233, 45.164))) * 43758.545)

#define M(a) mat2(cos(a), -sin(a), sin(a), cos(a))

float N(vec3 x) {

    vec3 i = floor(x), f = fract(x);

    f *= f * (3.0 - 2.0 * f);

    return mix(mix(mix(H(i), H(i + vec3(1,0,0)), f.x), mix(H(i + vec3(0,1,0)), H(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(H(i + vec3(0,0,1)), H(i + vec3(1,0,1)), f.x), mix(H(i + vec3(0,1,1)), H(i + vec3(1,1,1)), f.x), f.y), f.z);
}

float F(vec3 p) {

    float v = 0.0, a = 0.2;

    for (int i = 0; i < 6; i++) {

        v += a * N(p + sin(p.x * 0.5 + iTime * 1.2) * cos(p.z * 0.5 + iTime * 0.8));

        p = p * 2.4 + vec3(0.0, iTime * 0.04, iTime * -0.1);

        a *= 0.48;
    }

    return v;
}

float map(vec3 p) {

    vec3 nP = p * 1.8;

    nP.z += iTime * 0.6;

    float m = sin(p.x * 1.5 + iTime) * 0.5 + cos(p.z * 1.2 + iTime * 1.5) * 0.5;

    float disp = pow(F(nP + m * 0.2), 1.4) * 1.45 + m * 0.15;

    return length(p) - 2.8 + disp;
}

float calcAO(vec3 pos, vec3 nor) {

    float occ = 0.0;

    float sca = 1.0;

    for(int i = 0; i < 5; i++) {

        float h = 0.01 + 0.12 * float(i) / 4.0;

        float d = map(pos + h * nor);

        occ += (h - d) * sca;

        sca *= 0.95;

        if(occ > 0.35) break;
    }

    return clamp(1.0 - 3.0 * occ, 0.0, 1.0) * (0.5 + 0.5 * nor.y);
}

float calcSSS(vec3 pos, vec3 dir) {

    float sss = 0.0;

    float sca = 1.0;

    for(int i = 0; i < 4; i++) {

        float h = 0.1 + 0.2 * float(i);

        float d = map(pos + h * dir);

        sss += (h - d) * sca;

        sca *= 0.7;
    }

    return clamp(1.0 - sss * 0.5, 0.0, 1.0);
}

void mainImage(out vec4 O, vec2 U) {

    vec2 u = (U - 0.5 * iResolution.xy) / iResolution.y;

    float camTime = iTime * 0.12;

    vec3 ro = vec3(cos(camTime) * 8.5, sin(camTime * 0.4) * 4.5, sin(camTime) * 8.5);

    vec3 ta = vec3(0.0, 0.0, 0.0);

    vec3 cw = normalize(ta - ro);

    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));

    vec3 cv = cross(cu, cw);

    vec3 rd = normalize(u.x * cu + u.y * cv + 1.5 * cw);

    vec3 col = vec3(0.0);

    float t = 0.0, d, g = 0.0;

    for(int i = 0; i < 120; i++) {

        d = map(ro + rd * t);

        g += exp(-max(d, 0.0) * 3.2) * 0.12;

        if(d < 0.002 || t > 30.0) break;

        t += d * 0.45;
    }

    if (t < 30.0) {

        vec3 p = ro + rd * t;

        vec2 e = vec2(0.002, 0.0);

        vec3 n = normalize(vec3(map(p+e.xyy)-map(p-e.xyy), map(p+e.yxy)-map(p-e.yxy), map(p+e.yyx)-map(p-e.yyx)));

        float f = F(p * 0.6 - iTime * 0.4);

        vec3 alb = mix(mix(vec3(0.9, 0.02, 0.0), vec3(1.0, 0.45, 0.0), f * 2.4), vec3(1.0, 0.95, 0.6), pow(f, 3.5));

        float pbr = 0.05 + 0.95 * pow(1.0 - max(dot(n, -rd), 0.0), 5.0);

        float ao = calcAO(p, n);

        float sss = calcSSS(p, rd);

        vec3 lightDir = normalize(vec3(1.0, 1.5, -1.0));

        float diff = max(dot(n, lightDir), 0.0);

        vec3 backLight = vec3(0.1, 0.3, 0.8) * clamp(dot(n, -lightDir), 0.0, 1.0);

        col = alb * pbr * 3.5 * ao;

        col += alb * pow(f, 2.5) * 14.0 * sss;

        col += diff * vec3(1.0, 0.9, 0.8) * alb * 0.5 * ao;

        col += backLight * sss * 0.8;

        col *= exp(-0.02 * t);
    } else {

        vec3 brd = rd;

        brd.yz *= M(sin(iTime * 0.04) * 0.2);

        brd.xz *= M(iTime * 0.02);

        col = vec3(0.08, 0.01, 0.0) * F(brd * 3.0 + iTime * 0.03);

        for(float i = 1.0; i < 22.0; i++) {

            vec3 q = brd * (30.0 + i * 18.0);

            vec3 id = floor(q);

            vec3 fd = fract(q) - 0.5;

            float r = H(id);

            if(r > 0.97) {

                float pulse = sin(iTime * 3.5 * r + r * 25.0) * 0.5 + 0.5;

                col += pulse * vec3(1.0, 0.85, 0.7) * smoothstep(0.15, 0.0, length(fd) - 0.0025 * i) * 3.0;
            }
        }
    }

    col += vec3(1.0, 0.3, 0.02) * g * 1.1;

    vec3(1.0, 0.65, 0.15) * pow(g, 1.9) * 0.35;

    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);

    col *= 1.0 - 0.0 * pow(length(u), 2.5);

    O = vec4(pow(col * 0.95, vec3(0.4545)), 1.0);
}
