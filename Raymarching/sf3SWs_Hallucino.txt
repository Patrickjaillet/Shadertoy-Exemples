// ==== Image (image) ====
#define R iResolution
#define r(a) mat2(cos(a+vec4(0,33,11,0)))

float M(vec3 p) {
    p.z += iTime * .4;
    p.xy *= r(p.z * .1);
    vec3 q = p;
    float d = 100.;
    for(int i = 0; i < 5; i++) {
        p = abs(p) - vec3(.3, .8, .4);
        p.xy *= r(.8);
        p.xz *= r(.5);
        d = min(d, (length(p.xy) - .08) / 1.5);
    }
    return min(d, .6 - length(q.xy) + sin(atan(q.y, q.x) * 6. + q.z * 2.) * .1);
}

void mainImage(out vec4 O, vec2 U) {
    vec3 ro = vec3(vec2(cos(iTime * .5), sin(iTime * .3)) * .4, -2),
         rd = vec3((U + U - R.xy) / R.y, 1.2), col = vec3(0), p;
    rd.xy *= r(sin(iTime * .2) * .3);

    float t = 0., d, a = 0.;
    for(int i = 0; i < 90; i++) {
        p = ro + rd * t;
        d = M(p);
        if(d < .001 || t > 20.) break;
        t += d * .5;
        a += exp(-d * 8.) * .03;
    }

    if(t < 20.) {
        vec2 e = vec2(.002, 0);
        vec3 n = normalize(M(p) - vec3(M(p - e.xyy), M(p - e.yxy), M(p - e.yyx)));
        col = mix(vec3(.05, .02, .1), vec3(.9, .3, .1), max(0., dot(n, normalize(vec3(1, 2, -3)))))
            + vec3(.1, .5, .9) * pow(1. + dot(rd, n), 3.) * 2.
            + .5 + .5 * cos(iTime * 2. + p.z * 4. + atan(p.y, p.x) * 3. + vec3(0, 2, 4));
    }
    
    col += (.5 + .5 * sin(iTime * 3. + p.z * 2. + vec3(0, 2, 4))) * a * 2.;

    vec2 u = U / R.xy;
    float l = length(u - .5);
    col = mix(col, vec3(col.r * (1. + l * .3), col.g, col.b * (1. - l * .3)), smoothstep(0., .7, l));
    col = .5 + .5 * cos(iTime + col * 6.2831 + vec3(0, 2, 4));
    col = mix(col, col * col * (3. - 2. * col), .3) * vec3(1.08, .95, .98) * pow(16. * u.x * u.y * (1. - u.x) * (1. - u.y), .25);

    O = vec4(col, 1);
}
