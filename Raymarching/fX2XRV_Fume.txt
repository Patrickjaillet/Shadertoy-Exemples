// ==== Image (image) ====
void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    vec2 uv = (2.0 * fragCoord - resolution) / resolution.y;
    
    vec3 finalColor = vec3(0.0);
    float time = iTime * 0.2;

    for (float i = 0.0; i < 16.0; i++) {
        vec2 p = uv * (2.0 + i * 0.5);
        float totalDistance = 0.0;

        for (float j = 1.0; j < 27.0; j++) {
            p += vec2(cos(p.y * j + time), sin(p.x * j + time)) * 0.8;
            totalDistance += abs(length(p) - 0.9) / j;
        }

        vec3 colorLayer = 1.0 + 0.9 * cos(4.66 * (totalDistance * 0.1 + i + time + vec3(0.3, 0.4, 0.6)));
        finalColor += colorLayer * (0.21 / totalDistance);
    }

    fragColor = vec4(pow(finalColor, vec3(0.45)), 1.0);
}

/*
Golf version:

void mainImage(out vec4 o, vec2 u) {
    vec2 r = iResolution.xy,
         v = (u + u - r) / r.y;
    vec3 c = vec3(0);
    float t = iTime * .2, i = 0., j, d, s;
    for (; i < 16.; i++) {
        vec2 p = v * (2. + i * .5);
        for (j = 1.; j < 27.; j++)
            p += vec2(cos(p.y * j + t), sin(p.x * j + t)) * .8,
            d += abs(length(p) - .9) / j;
        c += (1. + .9 * cos(4.66 * (d * .1 + i + t + vec3(.3, .4, .6)))) * (.21 / d);
        d = 0.;
    }
    o = vec4(pow(c, vec3(.45)), 1);
}
*/
