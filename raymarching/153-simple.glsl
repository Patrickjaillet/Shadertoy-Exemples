
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
