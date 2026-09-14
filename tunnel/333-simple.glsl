
void mainImage(out vec4 O, vec2 C) {
    vec3 D = vec3((C - iResolution.xy * .5) / iResolution.y, 1.0),
         Q = vec3(0.0, 0.0, -.6), P, H;
    O = vec4(0.0);
    float E = 0.0, R = 0.0, S, J;
    for(int i = 0; i < 100; i++) {
        S = 1.0;
        P = Q += D * E * R * .3;
        R = length(P);
        P = vec3(log2(max(R, 1e-5)) - iTime * .5, exp2(-P.z / max(R, 1e-5)), atan(P.y, P.x) - cos(iTime) * .09);
        E = P.y - .6;
        for(J = 0.; J < 8.; J++) {
            E += dot(sin(P.zyy * S), vec3(.59) - sin(P * S)) / S * .2;
            S += S;
        }
        H = clamp(abs(mod(vec3(.532, 1.732, 3.032), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        O.rgb += min(E * S, R) / 83.2 * mix(vec3(1.0), H, P.y);
    }
    O.a = 1.0;
}
