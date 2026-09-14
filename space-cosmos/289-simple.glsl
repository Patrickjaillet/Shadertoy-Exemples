
void mainImage(out vec4 g, vec2 h) {
    vec2 u = iResolution.xy,
         a = abs(.5 - fract((h+h-u)/u.y * vec2(1.-.7*(2.*h.y-u.y)/u.y, 1))),
         b = a, c = u-u;

    for(int e=0; e<4; e++)
        b = abs(b) / clamp(abs(b.x*b.y), .1, 1.) - .8,
        c = min(c, abs(b)) + fract(vec2(b.x + iTime*.5, b.y*.2 + iTime));

    vec2 k = exp(-.9*c);
    g = vec4(k.x * 2.3 + exp(-5.1*length(a)), length(k) + exp(-5.1*length(a)), 
    k.y * 4.9 + exp(-5.1*length(a)), 1.);
}
