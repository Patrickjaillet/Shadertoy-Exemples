// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    O = texture(iChannel0, U / iResolution.xy);
}

// ==== Buffer A (buffer) ====
float H(vec3 p){return fract(sin(dot(p,vec3(12.98,78.23,311.7)))*43758.54);}
float N(vec3 p){
    vec3 i=floor(p),f=fract(p);
    f*=f*(3.-2.*f);
    vec2 e=vec2(0,1);
    return mix(mix(mix(H(i),H(i+e.yxx),f.x),mix(H(i+e.xyx),H(i+e.yyx),f.x),f.y),
               mix(mix(H(i+e.xxy),H(i+e.yxy),f.x),mix(H(i+e.xyy),H(i+e.yyy),f.x),f.y),f.z);
}

void mainImage(out vec4 O, vec2 U) {
    ivec2 p = ivec2(U);
    if (p.x >= 90 || p.y >= 72) return;
    float W = iResolution.x;
    int id = p.x + p.y * 90, t0 = iFrame * 9, m = t0 % 6000;
    if (iFrame == 0 || (id >= m && id < m + 9)) {
        O = vec4(mod(float(t0 + id - m) * 99., W), 0, 0, 3);
        return;
    }
    O = texelFetch(iChannel0, p, 0);
    O.w *= .997;
    float n = N(vec3(O.xy / vec2(W, 9), float(t0) / W));
    if (n > .4) O.y += O.z += .5;
    else {
        O.z = 0.;
        O.x += mod(n, .1) > .05 ? 1. : -1.;
        O.y += .5;
    }
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 O, vec2 U) {
    vec2 r = iResolution.xy, C = vec2(U.x, r.y - U.y);
    O = vec4(0);
    for (int k = 0; k < 9; k++)
        O += texture(iChannel0, (U + vec2(k % 3 - 1, k / 3 - 1)) / r);
    O *= .9647 / 9.;

    for (int i = 0; i < 500; i++) { // change for more FPS
        vec4 p = texelFetch(iChannel1, ivec2(i % 90, i / 90), 0);
        if (abs(C.y - p.y) < p.w && length(C - p.xy) < p.w * .5) O = vec4(1);
    }
}
