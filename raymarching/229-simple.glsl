
vec3 hsv(float h, float s, float v) {
    vec3 c = vec3(h, s, v);
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

mat2 rotate2D(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    float time = iTime * 0.2;
    fragColor = vec4(0.0);

    vec3 camPos = vec3(sin(time) * 3.0, 0.5, cos(time) * 3.0);

    vec3 forward = normalize(-camPos);

    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(forward, up));
    vec3 camUp = cross(right, forward);

    vec2 uv = (fragCoord - 0.5 * res) / res.y * 2.0;
    vec3 rayDir = normalize(mat3(right, camUp, forward) * vec3(uv, 2.0));

    float dist = 0.0;
    float stepDist;
    float totalDensity = 0.0;

    for (float i = 0.0; i < 80.0; i++) {
        vec3 pos = camPos + rayDir * dist;

        for (int k = 0; k < 6; k++) {
            pos = abs(pos) - 1.2;
            pos.xz *= rotate2D(0.7);
            pos *= 1.7;
        }

        stepDist = length(pos) / pow(1.7, 6.0) * 0.5;
        totalDensity += stepDist;

        if (stepDist < 0.001 || dist > 10.0) break;
        dist += stepDist;
    }

    if (dist < 10.0) {
        vec3 hitPoint = camPos + rayDir * dist;

        float hue = length(hitPoint) * 0.2
                  + sin(hitPoint.x * 3.0) * 0.1
                  + cos(hitPoint.z * 3.0) * 0.1;
        vec3 surfaceColor = hsv(hue, 0.6, 1.0);

        float fog = exp(-totalDensity * 0.05);
        fragColor.rgb = surfaceColor * fog;
    } else {
        fragColor.rgb = vec3(0.0);
    }
}
