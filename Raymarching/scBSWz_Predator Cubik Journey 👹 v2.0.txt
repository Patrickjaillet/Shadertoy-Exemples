// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 o = vec3(0.0), q, p, d = normalize(vec3((fragCoord - 0.5 * iResolution.xy) / iResolution.y, 1.0));
    float i = 0.0, s, R, e = 0.0, lungeCycle = mod(iTime, 7.0), lungePulse = smoothstep(0.0, 0.4, lungeCycle) * smoothstep(2.0, 0.4, lungeCycle), pathTime = iTime * 0.15 + lungePulse * 0.45, segment = mod(pathTime, 4.0), t = smoothstep(0.0, 1.0, fract(segment)), microJerkTime = iTime * 37.0, macroScanTime = iTime * 4.5, jitterTrigger = step(0.92, fract(sin(floor(iTime * 11.0) * 43758.5453))), lungingJitter = lungePulse * step(0.4, fract(sin(floor(iTime * 30.0) * 92.1143))), totalJitter = max(jitterTrigger, lungingJitter), rollNoise = sin(iTime * 8.0) * cos(iTime * 5.0) * 0.12 * totalJitter, fovStretch = 1.0 + lungePulse * 0.95;
    d = normalize(vec3(d.xy, 0.4 - dot(d.xy, d.xy) * 0.25));
    vec4 cp[4] = vec4[](vec4(0,0,0,0), vec4(2,0,0,1), vec4(2,2,0,2), vec4(0,2,2,3));
    int id = int(segment);
    vec3 p1 = cp[id].xyz, p2 = cp[(id+1)%4].xyz, p3 = cp[(id+2)%4].xyz, p4 = cp[(id+3)%4].xyz;
    float idx1 = cp[id].w, idx2 = cp[(id+1)%4].w;
    vec3 laStart = p2 + (idx1==0. ? vec3(0,0.5,0.5) : idx1==1. ? vec3(-0.5,0,0.5) : idx1==2. ? vec3(-0.5,-0.5,0) : vec3(0.5,-0.5,-0.5)), laEnd = p3 + (idx2==0. ? vec3(0,0.5,0.5) : idx2==1. ? vec3(-0.5,0,0.5) : idx2==2. ? vec3(-0.5,-0.5,0) : vec3(0.5,-0.5,-0.5)), microJerk = vec3(sin(microJerkTime) * cos(microJerkTime * 1.7), cos(microJerkTime * 1.3) * sin(microJerkTime * 2.1), sin(microJerkTime * 1.9) * cos(microJerkTime * 1.2)), macroScan = vec3(sin(macroScanTime) * 0.4, cos(macroScanTime * 0.8) * 0.3, sin(macroScanTime * 1.2) * 0.2), glitchJitter = (vec3(fract(sin(floor(iTime * 40.0) * 12.9898)), fract(sin(floor(iTime * 40.0) * 78.2330)), fract(sin(floor(iTime * 40.0) * 37.7190))) - 0.5) * (0.25 * jitterTrigger + 0.5 * lungingJitter);
    vec3 ro = mix(p1, p2, t) + microJerk * 0.005 + glitchJitter * 0.2, lookAt = mix(laStart, laEnd, t) + microJerk * (0.015 + lungePulse * 0.08) + macroScan * (1.0 - lungePulse * 0.85) + glitchJitter, cw = normalize(lookAt - ro), upDir = vec3(sin(iTime * 0.1) * 0.1 + rollNoise, 1.0, 0.0), cu = normalize(cross(cw, upDir)), cv = cross(cu, cw);
    d = normalize(d.x * cu + d.y * cv + d.z * cw);
    d.z /= fovStretch;
    d = normalize(d);
    //https://github.com/Patrickjaillet
    vec3 targetOrb = p2;
    vec3 escapeOffset = (p3 - p2) * smoothstep(0.7, 1.0, t) * 1.1;
    vec3 orbPos = targetOrb + escapeOffset;
    float orbGlow = 0.0;
    
    float pulse = sin(iTime * 12.0) * 0.5 + 0.5;
    float currentRadius = 0.04 + 0.025 * pulse;
    
    q = ro;
    for (int iter = 0; iter < 90; iter++) {
        if (i >= 90.0) break;
        q += d * max(e, 0.001) * 0.4;
        p = q;
        R = max(abs(p.x), max(abs(p.y), abs(p.z)));
        float h = fract(sin(dot(floor((p + 1.0) * 0.5), vec3(12.9898, 78.233, 37.719))) * 43758.5453);
        p = mod(p + 0.5, 2.0) - 1.0;
        vec3 db = abs(p) - 0.71;
        float dMandel = max(db.x, max(db.y, db.z));
        s = 1.0;
        for (int j = 0; j < 4; j++) {
            p = abs(p) - 1.0;
            if (p.x < p.y) p.xy = p.yx;
            if (p.x < p.z) p.xz = p.zx;
            if (p.y < p.z) p.yz = p.zy;
            p = p * 1.7 - vec3(0.1, 0.5, 0.1);
            s *= 1.7;
            vec3 box = abs(p) - 1.0;
            dMandel = max(dMandel, -(max(box.x, max(box.y, box.z)) / s));
        }
        e = max(dMandel, -(0.51 - max(abs(p.x), abs(p.y))) * 0.3);
        
        float dOrb = length(q - orbPos) - currentRadius;
        orbGlow += (0.0035 + 0.002 * pulse) / (0.0005 + dOrb * dOrb);
        e = min(e, dOrb);
        
        o += (clamp(1.0 / (1.0 + e * e * 1600.0), 0.0, 1.0) * mix(vec3(1.0), clamp(abs(mod(fract(log(R + 1e-4) * 0.1 + h * 0.5 + iTime * 0.02) * 6.0 + vec3(0,4,2), 6.0) - 3.0) - 1.0, 0.0, 1.0), clamp(0.6 - e * 4.0, 0.0, 1.0))) * (1.0 / (1.0 + R * R * 0.01)) * 0.11;
        if (abs(e) < 0.0005) {
            d = reflect(d, sign(p) * step(db.yzx, db.xyz) * step(db.zxy, db.xyz));
            q += d * 0.01;
        }
        i++;
    }
    
    o += vec3(0.5, 0.9, 1.0) * orbGlow * (0.04 + 0.02 * pulse);
    fragColor = vec4(pow(mix(o, vec3(0), 0.4 - exp(-4.08 * i)) / (mix(o, vec3(0), 0.4 - exp(-4.08 * i)) + 1.0), vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
vec2 mainSound(in int S, float t) {
    float C = mod(t, 7.), P = smoothstep(0., .4, C) * smoothstep(2., .4, C),
          J = max(step(.92, fract(sin(floor(t * 11.) * 43758.55))), P * step(.4, fract(sin(floor(t * 30.) * 92.11)))),
          b = (sin(219.9 * t) * (.6 + .4 * sin(t * 12.)) + sin(110. * t) * .3) * (1. - P * .4),
          d = clamp(sin(282.7 * t + sin(565.5 * t) * .2) * 3., -1., 1.) * .25,
          c = fract(sin(t * 951.35) * 43758.55) * exp(-70. * fract(t * (1.5 + P * 3.))) * (.4 + .6 * P),
          g = (smoothstep(-.2, .2, sin(345.6 * t + sin(502.7 * t) * 4.)) * 2. - 1.) * P * .45,
          s = sin(5026.5 * t) * fract(sin(t * 123.46) * 43758.55) * J * .22,
          h = sin(282.7 * t) * exp(-6. * fract(t * 1.4)) * .5,
          f = clamp((b + d + c + g + s + h) * .8, -1., 1.);
    return vec2(f * (.6 + .4 * sin(t * 1.5 + J)), f * (.6 + .4 * cos(t * 1.5 - J)));
}
