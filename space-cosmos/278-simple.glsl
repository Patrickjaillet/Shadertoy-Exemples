// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    vec2 R = iResolution.xy;
    
    float lowFreq = 0.0;
    float midFreq = 0.0;
    float highFreq = 0.0;
    for(int i = 0; i < 10; i++) {
        lowFreq += texelFetch(iChannel0, ivec2(i, 0), 0).x;
        midFreq += texelFetch(iChannel0, ivec2(120 + i, 0), 0).x;
        highFreq += texelFetch(iChannel0, ivec2(400 + i, 0), 0).x;
    }
    float kick = pow(lowFreq * 0.1, 2.0);
    float snare = pow(midFreq * 0.1, 2.0);
    float hihat = pow(highFreq * 0.2, 3.0);
    
    vec2 u = (C - .5 * R) / R.y * mix(1., 1.6, 1. + .4 * sin(iTime * .025)) * (1.0 - kick * 0.15);
    vec2 m = iMouse.z > 0. ? (iMouse.xy - .5 * R) / R.y : vec2(0);
    vec2 c = vec2(.274, .84) + m * 0.0;
    vec2 t0 = vec2(1e20), t1 = t0, t2 = t0;
    
    float t = iTime * .05 + kick * 0.05;
    float n = 250.;
    
    for(int i = 0; i < 250; i++) {
        float a = sin(t + float(i) * .04) * .6 + snare * 0.02 * sin(float(i) * 0.1 + iTime);
        u = mat2(cos(a), -sin(a), sin(a), cos(a)) * u;
        u = vec2(u.x * u.x - u.y * u.y, -2. * u.x * u.y) + c;
        t0 = min(t0, vec2(abs(u.x + u.y + sin(t) * .5), abs(u.x - u.y + cos(t) * .5)));
        t1 = min(t1, vec2(length(u - vec2(.5 * sin(t), cos(t))), dot(u, u)));
        t2 = min(t2, vec2(abs(u.x), abs(u.y)));
        if(dot(u, u) > 16. + kick * 8.0) { n = float(i); break; }
    }
    
    vec3 c0 = vec3(.35, .1, .3), c1 = vec3(.8, .3, .1), c2 = vec3(.95, .85, .5), c3 = vec3(.1, .6, .7);
    c1 += vec3(0.4, 0.1, 0.2) * snare;
    c1.x += hihat * 0.6;
    c2 += vec3(0.2, 0.4, 0.1) * kick;
    
    vec3 o = mix(c0, c1, smoothstep(0., 1., log(.1 + 38.2 * t0.x))) +
             mix(c2, c3, smoothstep(0., 1., log(.1 + 46. * t0.y))) * .6 +
             c2 * smoothstep(0., 0., sin(t1.x * (28.4 + kick * 10.0) + t)) * .5 +
             c3 * exp(-2.3 * t1.y) * (2.3 + snare * 2.0) +
             vec3(.9, .6, 1.) * (exp(-20. * t2.x) + exp(-20. * t2.y)) * .4;
             
    o = mix(o, vec3(.01, .02, .05), step(249.5, n) * .2) + vec3(.4, .2, .6) * pow(n / 250., 3.);
    o = pow(o, vec3(1.1, 1., .9));
    o = mix(o, vec3(dot(o, vec3(1, 1, .215))), -.8);
    vec2 p = C / R;
    o *= .8 + .6 * pow(64. * p.x * p.y * (1. - p.x) * (1. - p.y), .67);
    O = vec4(pow(smoothstep(.3, 1., o), vec3(1. / 2.2)), 1.);
}
