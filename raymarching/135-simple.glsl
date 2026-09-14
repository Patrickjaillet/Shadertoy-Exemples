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
void mainImage(out vec4 G, in vec2 H) {
    vec2 R = iResolution.xy;
    vec2 uv = (H - .5 * R) / R.y;

    float t = iTime * .3;
    vec3 ro = vec3(1.1 * sin(t), 1.3, 1.1 * cos(t)); 
    vec3 ta = vec3(0.0, -0.1, 0.0);                
    
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0, 1, 0)));
    vec3 vv = cross(uu, ww);
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);

    float tp = -ro.y / rd.y;
    vec3 fC = vec3(0.01, 0.005, 0.015);

    if (tp > 0.0) {
        vec3 p = ro + rd * tp;
        vec2 z = p.xz;
        
        vec2 c = vec2(-.72 + .08 * sin(iTime * .4), .26 + .06 * cos(iTime * .4));
        float m = 1e5;
        mat2 r = mat2(cos(t * .2), -sin(t * .2), sin(t * .2), cos(t * .2));
        z = z * r;

        for (int i = 0; i < 24; i++) {
            if (dot(z, z) > 4.) break;
            z = vec2(z.x * z.x - z.y * z.y, 2. * z.x * z.y) + c;
            m = min(m, length(z - .5 * vec2(sin(t), cos(t))));
        }

        float h = sqrt(abs(z.x * z.y) + 1e-4);
        vec2 nUV = z * 2. + vec2(t * .2, -t * .3);

        float n = 0., a = .5;
        mat2 m2 = mat2(.8, .6, -.6, .8);
        for (int i = 0; i < 3; i++) {
            vec2 p2 = nUV, f = fract(p2), I = floor(p2);
            f *= f * (3. - 2. * f);
            n += a * mix(mix(fract(sin(dot(I, vec2(123.34, 456.21))) * 43758.5),
                            fract(sin(dot(I + vec2(1, 0), vec2(123.34, 456.21))) * 43758.5), f.x),
                        mix(fract(sin(dot(I + vec2(0, 1), vec2(123.34, 456.21))) * 43758.5),
                            fract(sin(dot(I + 1., vec2(123.34, 456.21))) * 43758.5), f.x), f.y);
            nUV = m2 * nUV * 2.02;
            a *= .5;
        }

        float e = .01;
        float nx = fract(sin(dot(floor(nUV + vec2(e, 0)), vec2(123.34, 456.21))) * 43758.5) -
                 fract(sin(dot(floor(nUV - vec2(e, 0)), vec2(123.34, 456.21))) * 43758.5);
        float ny = fract(sin(dot(floor(nUV + vec2(0, e)), vec2(123.34, 456.21))) * 43758.5) -
                 fract(sin(dot(floor(nUV - vec2(0, e)), vec2(123.34, 456.21))) * 43758.5);
        vec3 N = normalize(vec3(-nx, 0.4, -ny));

        vec3 L = normalize(vec3(sin(t), 1.5, cos(t)));
        float diff = max(dot(N, L), 0.);
        float spec = pow(max(dot(reflect(-L, N), -rd), 0.), 16.);
        float gP = (.08 / (h + .015)) * (.8 + .4 * n);

        fC = mix(vec3(.05, .01, .02), vec3(.9, .25, .05), smoothstep(0., 1., gP));
        fC = mix(fC, vec3(1, .7, .15), smoothstep(1., 2.5, gP));
        fC = mix(fC, vec3(1, .98, .9), smoothstep(2.5, 5., gP));

        fC += vec3(.2, .5, 1.) * (.03 / (m + .05));
        fC *= diff * .7 + .3;
        fC += vec3(1, .8, .5) * spec * .8;

        fC = mix(fC, vec3(0.01, 0.005, 0.015), smoothstep(1.2, 4.5, tp));
    }

    fC *= smoothstep(1.4, .3, length(uv));
    fC = clamp((fC * (2.51 * fC + .03)) / (fC * (2.43 * fC + .59) + .14), 0., 1.);
    fC = pow(fC, vec3(1. / 2.2));

    float grain = (fract(sin(dot(H + fract(iTime), vec2(12.9898, 78.233))) * 43758.5453) - .5) * .02;
    G = vec4(fC + grain, 1.);
}
