
void mainImage(out vec4 O, vec2 U) {
    vec2 R = iResolution.xy;
    U = (U + U - R) / R.y * 0.5;
    O -= O;
    for (float t = iTime * 2., i, k, e, d, c, j = 9e2; j-- > 0.;) {
        i = j * 20. / 3.;
        k = 5. * cos(i / 44.);
        e = i / 506. - 15.;
        d = length(vec2(k, e)) / 3.;
        c = d / 2. - t / 3. + mod(i, 2.) * 3.;
        O.rgb += (.5 + .299 * cos(vec3(.1373, 1, .0039) + c + t)) * 2.34e-4 / (length(U - vec2((93.22 + d * d + k * k) * sin(c) + d * d * d / 4. * cos(t * 3. - d * d / 4.), -99. * cos(c / 2.) - 4. * sin(k + k) - i * k * e / 19481. / sin(e / 2.)) / 321.6) + 5e-4);
    }
    O = pow(O, vec4(1.7));
}
