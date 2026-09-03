// ==== Image (image) ====
#define L(a,b) w = b - a, d = min(d, length(p - a - w * clamp(dot(p - a, w) / dot(w, w), 0., 1.)) - .003)
#define C(q) d = min(d, length(p - q) - .015)

void mainImage(out vec4 O, vec2 U) {
    vec2 R = iResolution.xy,
         p = (U + U - R) / R.y, w;
    float d = 1., t = iTime * .6, a;
    
    for (float i = 0.; i < 6.28; i += .19) {
        a = t + i;
        vec2 D = vec2(sin(a), cos(a)),
             P0 = .425 * D,
             P1 = .85 * D,
             P2 = clamp(P1, -.6, .6);
        
        L(P1, P2);
        L(P0, P2);
        C(P0); C(P1); C(P2);
    }
    
    O = vec4(smoothstep(2. / R.y, 0., d));
}
