// ==== Image (image) ====
#define R(a) mat2(cos(a),sin(a),-sin(a),cos(a))

void mainImage(out vec4 O, vec2 U) {
    vec2 r = iResolution.xy;
    vec3 p, d = vec3((U + U - r) / r.y, -2), o = vec3(0, 0, 7);
    float t = iTime, s, i;
    
    o.yz *= R(.35); d.yz *= R(.35);
    o.xz *= R(t);  d.xz *= R(t);
    o.xy *= R(t);  d.xy *= R(t);

    O -= O;
    for (s = 2.; s < 12.; s += .08) {
        p = o + d * s;
        for (i = 0.; i < 25.; i++) {
            vec3 C = vec3(sin(i + t), cos(i + t), tan(i + t)),
                 q = abs(p - C) - abs(C);
            if (max(q.x, max(q.y, q.z)) < 0.) {
                ivec2 I = ivec2((p - C) / abs(C) * 32. + 32.);
                if ((I.x & I.y) == 0) O += .015 * (cos(i + vec4(0, 2, 4, 0)) + 1.);
            }
        }
    }
}
