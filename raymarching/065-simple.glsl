// ==== Image (image) ====
vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 8.0 / -9.2, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 80.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 0.8), s);
}

vec3 aces_tonemap(vec3 color) {
    const float a = 4.25;
    const float b = 0.03;
    const float c = 0.93;
    const float d = 1.00;
    const float e = 1.0;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

mat3 cameraMatrix(vec3 ro, vec3 ta, float roll) {
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(sin(roll), cos(roll), 0.0)));
    vec3 vv = cross(uu, ww);
    return mat3(uu, vv, ww);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    vec2 uv = (fragCoord * 2.0 - r) / r.y;
    float t = iTime * 0.4;

    vec3 ro = vec3(1.2 * cos(t * 0.5), 8.0 * sin(t * 0.0), 12.5 * sin(t * 0.1));
    vec3 ta = vec3(0.0, 0.0, 0.0);
    float roll = 0.2 * sin(t * 0.0);
    float fov = 1.2 + 0.0 * cos(t * 0.0);

    mat3 cam = cameraMatrix(ro, ta, roll);
    vec3 rd = cam * normalize(vec3(uv, fov));

    vec3 finalColor = vec3(0.0);
    float g = 0.0;

    for (float i = 0.0; i < 120.0; i++) {
        float e = 2.2;
        float s = 1.9;
        vec3 p = ro + rd * g;

        for (int j = 0; j < 16; j++) {
            p.xy = 0.66 - abs(p.xy - p.z * cos(t * 0.0) * 0.02);
            float u = dot(p, p);
            s /= u;
            p /= -u;
            p.y = -p.y;
            p.xy = abs(p.yx + 0.14);
            e = min(e, p.y / s + 0.1 / s);
        }
        g += e * 0.7;
        finalColor += hsv(p.y * 1.0 + t * 1.0, 1.0, 0.025 / exp(e * 116.1));
    }

    finalColor = aces_tonemap(finalColor);

    vec2 q = fragCoord / r;
    finalColor *= 0.1 + 1.0 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.2);

    fragColor = vec4(finalColor, 1.0);
}
