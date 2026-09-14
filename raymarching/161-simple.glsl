// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    vec2 r = iResolution.xy, p = (C + C - r) / r.y;
    O = vec4(0);
    for(float i=1.; i<4.; i++) {
        p += 0.3 / i * cos(i * 3. * p.yx + iTime * 0.2 + vec2(1.57, 0));
        float d = length(p);
        O.xyz += pow(sin(iTime * 0.2 + vec3(0,1,2) + d * 4.), vec3(2)) * 0.1 / (abs(sin(d * 12.7 + iTime * 3.2)) + 0.1);
    }
}
