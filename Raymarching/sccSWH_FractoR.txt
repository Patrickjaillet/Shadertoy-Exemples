// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U)
{
    O = vec4(0, 0, 0, 1);
    vec2 R = iResolution.xy, p = U/R - .5, d = p * (1. + .04 * dot(p, p)), u = .5 + d;
    if (max(abs(d.x), abs(d.y)) > .5) return;

    float coc = smoothstep(.12, .55, length(d * vec2(1.2, .8))) * .018, W = 0.;
    vec3 C = vec3(0);

    for (float i = 0.; i < 16.; i++) {
        vec2 sU = u + vec2(cos(i * 2.4), sin(i * 2.4)) * sqrt(i + .5) / 4. * coc,
             o = (sU - .5) * length(sU - .5) * .0025;
        vec3 sC = vec3(texture(iChannel0, sU - o).r, texture(iChannel0, sU).g, texture(iChannel0, sU + o).b);
        float w = max(1., 2. * max(sC.r, max(sC.g, sC.b)));
        C += sC * w;
        W += w;
    }
    C /= W;

    vec3 B = vec3(1.5);
    float bW = 0.;
    for (float i = -3.; i <= 3.; i++) {
        float e = exp(-abs(i) * .3);
        B += max(texture(iChannel0, u + vec2(i * 3., 0) / R).rgb - .2, 0.) * e;
        bW += e;
    }

    C += B / bW * .2;
    C /= 1. + C * .6;
    C = pow(C, vec3(1.04)) * pow(u.x * (1. - u.x) * u.y * (1. - u.y) * 16., .18) * (1. - smoothstep(0., .004, abs(u.y - .5) - .43));

    O = vec4(C, 1);
}

// ==== Common (common) ====
mat2 rot(float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 hsv2rgb(vec3 c)
{
    return c.z * mix(vec3(1), clamp(abs(fract(c.x + vec3(0, 2, 1) / 3.) * 6. - 3.) - 1., 0., 1.), c.y);
}

// ==== Buffer A (buffer) ====
void mainImage(out vec4 O, vec2 U)
{
    O = vec4(0);
    vec2 R = iResolution.xy, u = (U - .5 * R) / R.x * .4 + vec2(0, 1.35);
    float d = 0., a = iTime * .4;
    mat2 m = mat2(cos(a), sin(a), -sin(a), cos(a));

    for (int i = 0; i < 72; i++) {
        vec3 p = vec3(u, d - 1.05);
        p.zx *= m;
        float s = 1.85;

        for (int j = 0; j < 18; j++) {
            float k = 11. / dot(p, p);
            s *= k;
            p = vec3(0, 3.9, .8) - abs(abs(p) * k - vec3(2.25 - d * .03, 3.8 + k * .075, 3.5));
        }

        d += p.y / s;
        s = log2(s) + d * d;

        vec3 c = s / 980. * mix(vec3(1), clamp(abs(fract(.22 + .3 * p.y + vec3(0, 2., 1.) / 3.) * 6. - 3.) - 1., 0., 1.), clamp(p.z * .1, 0., 1.));
        O.rgb += max(vec3(0), .019 - c) * exp(-d * .12);
    }

    O.a = d;
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 O, vec2 U)
{
    vec4 tex = texture(iChannel0, U / iResolution.xy);
    vec3 col = tex.rgb;
    
    col *= 1.45;
    
    vec3 hsv = vec3(
        fract(atan(col.g - col.b, col.r - col.g) * 0.1591549 + iTime * 0.03),
        clamp(length(col.rgb) * 1.8, 0.4, 1.0),
        1.0
    );
    
    vec3 colorBoost = hsv2rgb(hsv);
    col = mix(col, col * colorBoost * 1.8, 0.55);
    col = pow(col, vec3(0.88));

    O = vec4(col, tex.a);
}
