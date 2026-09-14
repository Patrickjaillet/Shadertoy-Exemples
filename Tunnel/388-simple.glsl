// ==== Image (image) ====
mat2 a(in float b) {
    float c = cos(b), d = sin(b);
    return mat2(c, d, -d, c);
}

float e(in float f) {
    return abs((f - floor(f)) - .5);
}

vec3 g(in vec3 h) {
    return vec3(
        abs((h.z + abs((h.y - floor(h.y)) - .5) - floor(h.z + abs((h.y - floor(h.y)) - .5))) - .5),
        abs((h.z + abs((h.x - floor(h.x)) - .5) - floor(h.z + abs((h.x - floor(h.x)) - .5))) - .5),
        abs((h.y + abs((h.x - floor(h.x)) - .5) - floor(h.y + abs((h.x - floor(h.x)) - .5))) - .5)
    );
}

float i(in vec3 h, in float j) {
    float k = 1., l = .1;
    vec3 m = h;
    for (float n = 0.; n <= 2.; n++) {
        vec3 o = g(m);
        h += (o + iTime * j);
        m *= 2.;
        k *= 1.5;
        h *= 1.3;
        l += (e(h.z + e(h.x + e(h.y)))) / k;
        m += .14;
    }
    return l;
}

vec2 p(float k) {
    return vec2(
        sin(k * .12) * 3.5 + cos(k * .04) * 1.5,
        cos(k * .09) * 2.5 + sin(k * .07) * 1.2
    );
}

float q(vec3 h) {
    vec2 r = p(h.z);
    vec3 s = h;
    s.xy -= r;
    float t = 5.5 - length(s.xy);
    float u = i(h * .25, 0.);
    s.xy *= a(h.z * .1);
    float v = length(s.xy + vec2(sin(h.z), cos(h.z)) * 1.5) - .8;
    float w = min(t, v);
    return w - u * .5;
}

vec3 x(in vec3 h) {
    vec2 y = vec2(-1., 1.) * .01;
    return normalize(
        y.yxx * q(h + y.yxx) +
        y.xxy * q(h + y.xxy) +
        y.xyx * q(h + y.xyx) +
        y.yyy * q(h + y.yyy)
    );
}

vec3 z(float k) {
    return vec3(p(k), k);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 aa = fragCoord.xy / iResolution.xy;
    vec2 h = aa - .5;
    h.x *= iResolution.x / iResolution.y;

    float ab = iTime * 14.;
    vec3 ac = z(ab);
    vec3 ad = z(ab + 2.);

    float ae = sin(iTime * .2) * .5;
    vec3 af = normalize(ad - ac);
    vec3 ag = vec3(sin(ae), cos(ae), 0.);
    vec3 ah = normalize(cross(af, ag));
    vec3 ai = normalize(cross(ah, af));
    vec3 aj = normalize(h.x * ah + h.y * ai + 1.3 * af);

    float ak = 0., w = 0., al = 0.;
    for (int n = 0; n < 110; n++) {
        w = q(ac + aj * ak);
        if (abs(w) < .005 || ak > 50.) break;
        ak += w * .6;
        al += max(0., (.35 - w)) * .09;
    }

    vec3 am = vec3(.01, .03, .05);
    if (ak < 50.) {
        vec3 an = ac + aj * ak;
        vec3 ao = x(an);
        vec3 ap = normalize(vec3(.5, .8, -.2));
        float u = i(an * .1, 0.);
        float aq = clamp(dot(ao, ap), 0., 1.);
        float ar = pow(clamp(1. + dot(ao, aj), 0., 1.), 3.);
        float as = clamp(q(an + ao * 1.2), 0., 1.);

        am = mix(vec3(.05, .1, .25), vec3(.4, .6, .8), u);
        am = am * aq + ar * vec3(.7, .9, 1.) * as;
        am *= as;
    }

    float at = length(h) * .15;
    am += vec3(.5, .75, 1.) * al * (1. - at);
    am = sqrt(max(am, 0.));
    am *= .4 + .6 * pow(16. * aa.x * aa.y * (1. - aa.x) * (1. - aa.y), .35);

    fragColor = vec4(am * smoothstep(0., 2.5, iTime), 1.);
}
