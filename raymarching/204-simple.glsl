
void mainImage(out vec4 O, vec2 f) {
    vec3 c = vec3(0, .68, -1.6), R = iResolution, p;
    float a = 0., e = 0., v, u, g; 
    for (O *= a; a < 110.; a += .9) {
        p = c += e * vec3((f - .5*R.xy) / R.y, 1.27);
                p.xz *= mat2(cos(.52*iTime - vec4(0, 11, 33, 0)));
                p.xz += sin(iTime * 2.5 + p.y * 1.5 + vec2(0., 1.57)) * 0.06 * max(0., p.y);
        e = v = 4.5;
        for (g = 0.; g++ < 10.; )
            v /= u = dot(p,p),
            p /= u + .01,
            p.y = 1.68 - p.y,
            e = min(min(e, max(p.y, length(p.xz = abs(p.xz*mat2(1, -.1, .1, 1)) - .62) - .018/u) / v), c.y - .12);
        O += (2.3 + cos(v*1.52 + vec4(0, 2, 4, 0))) / exp(e*560. + a*.015 + 4.9);
    }
}
