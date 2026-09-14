// ==== Image (image) ====
#define AA 2.
#define I 1e3
#define P 3.14159

float H(vec2 p) {
    uvec2 x = floatBitsToUint(p);
    uint h = (x.x ^ (x.y >> 3u)) * 1103515245u + 12345u;
    return float(h & 0xFFFFFFu) / 16777216.0;
}

float N(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f *= f * (3. - 2. * f);
    vec4 v = vec4(H(i), H(i + vec2(1, 0)), H(i + vec2(0, 1)), H(i + vec2(1, 1)));
    return mix(mix(v.x, v.y, f.x), mix(v.z, v.w, f.x), f.y);
}

float F(vec2 p) {
    float v = 0.0, a = 0.5;
    mat2 r = mat2(1.6, 1.2, -1.2, 1.6);
    for(int i = 0; i < 8; i++) {
        v += a * N(p);
        p = r * p * 2.1;
        a *= 0.45;
    }
    return v;
}

vec3 C(float t) {
    return .5 + .5 * cos(2. * P * (vec3(1, 1, .8) * t + vec3(0, .15, .25) + (.5 + .5 * sin(iTime * .04)) * .4));
}

mat3 K(float t, out float p) {
    p = sin(t * .6) * .5;
    vec3 a = vec3(.5 * sin(t * .4), .15 * cos(t * .25), .1 * sin(t * .2));
    vec3 c = cos(a), s = sin(a);
    return mat3(c.x, 0, s.x, 0, 1, 0, -s.x, 0, c.x) * mat3(1, 0, 0, 0, c.y, s.y, 0, -s.y, c.y) * mat3(c.z, s.z, 0, -s.z, c.z, 0, 0, 0, 1);
}

vec3 R(vec2 c, float z, float t) {
    vec2 s = vec2(0), d = s;
    float m = 1e10, i = 0.;
    for(int j = 0; j < int(I); j++) {
        if(dot(s, s) > 131072.0) break;
        d = 2. * vec2(s.x * d.x - s.y * d.y, s.x * d.y + s.y * d.x) + vec2(1, 0);
        s = vec2(s.x * s.x - s.y * s.y, 2. * s.x * s.y) + c;
        m = min(m, abs(length(s) - .2));
        i++;
    }
    if(i >= I) return vec3(0);
    float de = .5 * sqrt(dot(s, s) / dot(d, d)) * log(dot(s, s));
    vec3 n = normalize(vec3(de, de, .5 / z)), 
         l = normalize(vec3(sin(t * .3), 1, cos(t * .3))),
         b = C((i - log2(log2(dot(s, s))) + 4.) * .008 + t * .01);
    float df = max(dot(n, l), 0.), 
          sp = pow(max(dot(reflect(-l, n), vec3(0, 0, 1)), 0.), 120.),
          fr = pow(1. - max(dot(n, vec3(0, 0, 1)), 0.), 4.);
    return (b * (df + .3) + sp * .8 + fr * .4 + C(m * .3 + t * .15) * exp(-m * 15.) * 4.5) * smoothstep(0., .05 / z, de);
}

void mainImage(out vec4 O, vec2 U) {
    vec3 ac = vec3(0);
    float t = iTime, pz;
    mat3 m = K(t, pz);
    float zm = (800. + 35000. * pow(.5 + .5 * cos(t * .05), 4.)) * (1. + pz * .8);
    for(float i = 0.; i < AA * AA; i++) {
        vec2 jt = vec2(H(U + i), H(U + i + 1.)) - .5,
             uv = (U + jt - .5 * iResolution.xy) / iResolution.y;
        vec3 rd = m * normalize(vec3(uv, 2.2 + pz * .5));
        vec2 p = rd.xy / max(rd.z, 1e-4);
        vec3 cl = R(vec2(-.7452, .1862) + p / zm, zm, t);
        ac += mix(cl, C(t * .1) * .5, smoothstep(0., 4., length(p)) * .2 * F(p * 2. + t * .1));
    }
    ac /= (AA * AA);
    vec2 s = U / iResolution.xy;
    ac += C(F(s * 4. - t * .05)) * .04;
    ac = clamp((ac * (2.51 * ac + .03)) / (ac * (2.43 * ac + .59) + .14), 0., 1.);
    ac *= mix(.3, 1., pow(16. * s.x * s.y * (1. - s.x) * (1. - s.y), .35));
    O = vec4(pow(ac + (vec3(H(s + t), H(s + t + 1.), 0.) - .5) * .02, vec3(.4545)), 1);
}
