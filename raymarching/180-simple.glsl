// ==== Image (image) ====
vec3 hsv(float h, float s, float v) {
    vec3 c = vec3(h, s, v);
    vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

mat2 rotate2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

mat3 rotate3D(float a, vec3 axis) {
    axis = normalize(axis);
    float c = cos(a), s = sin(a);
    return mat3(
        c + axis.x*axis.x*(1.0-c),
        axis.x*axis.y*(1.0-c) - axis.z*s,
        axis.x*axis.z*(1.0-c) + axis.y*s,

        axis.y*axis.x*(1.0-c) + axis.z*s,
        c + axis.y*axis.y*(1.0-c),
        axis.y*axis.z*(1.0-c) - axis.x*s,

        axis.z*axis.x*(1.0-c) - axis.y*s,
        axis.z*axis.y*(1.0-c) + axis.x*s,
        c + axis.z*axis.z*(1.0-c)
    );
}

void mainImage(out vec4 o, in vec2 FC) {
    vec2 r = iResolution.xy;
    float t = iTime;

    o = vec4(0.0);
    float g = 0.0, e = 0.0, s = 0.0;

    for (float i = 0.0; i < 99.0; i++) {
        vec3 p = vec3((FC - 0.5*r)/r.y * 5.0 + vec2(-1.0, 1.0), g - 6.0);
        p *= rotate3D(2.0, vec3(6.0, 0.0, 6.0));
        p.xz *= rotate2D(t * 0.3);

        s = 3.0;

        for (int k = 0; k < 19; k++) {
            s *= (e = 7.5 / dot(p, p * 0.47));
            p = vec3(0.0, 4.03, -1.0) - abs(abs(p) * e - vec3(3.0, 4.0, 3.0));
        }

        g += p.y * p.y / s * 0.3;
        s = log2(s) - g;

        o.rgb += hsv(0.5 * e, 0.4, s / 700.0);
    }
}
