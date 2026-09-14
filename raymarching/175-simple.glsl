
void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 st = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    st.y = -st.y;

    vec3 color = vec3(0.035);
    float time = iTime * 1.5;

    const float totalPoints = 600.0;

    for (float idx = 0.0; idx < totalPoints; idx += 1.0) {

        float i = mix(0.0, 10000.0, idx / totalPoints);
        float y = i / 43.0;

        float k = 5.0 * cos(i / 14.0) * cos(y / 30.0);
        float e = y / 8.0 - 13.0;

        float d = (k * k + e * e) / 59.0 + 6.0;

        float angle = atan(k, e);
        float q = 90.0 - 5.0 * sin(angle * e) + k * (3.0 + sin(d * d - time * 2.0));
        float c = d / 2.0 - time / 18.0;

        vec2 p = vec2(
            (q = (90.0 - 5.0 * sin(angle * e) + k * (3.0 + sin(d * d - time * 2.0)))) * sin(c),
            (q + d * pow(d, sin(d * 2.0 - time / 3.0))) * cos(c)
        ) / 200.0;

        float dist = length(st - p);
        float pointShape = smoothstep(0.008, 0.001, dist);

        color += vec3(1.0, 1.0, 1.0) * pointShape * 0.15;
    }

    fragColor = vec4(color, 1.0);
}
