
void mainImage(out vec4 c, vec2 u){
    vec3 R = iResolution;
    u = (u - 0.5 * R.xy) / R.y;

    float zoom = 1.0 + 0.5 * sin(iTime * 1.5);
    u *= zoom;

    float a = atan(u.y, u.x);
    float d = length(u);

    vec2 p = u + vec2(sin(a * 4.0 + iTime * 3.0) * 0.05, cos(a * 5.0 - iTime * 4.0) * 0.05);
    float d2 = length(p);

    vec3 col = 0.5 + 0.5 * cos(vec3(0.0, 1.0, 2.0) + a + d2 * 4.0 - iTime * 2.0);

    c = vec4(col * (1.0 - u.y), 1.0) * step(0.0, sin(d2 * 60.0 - iTime * 8.0 + a * 3.0));
}
