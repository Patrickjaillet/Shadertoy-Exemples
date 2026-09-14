// ==== Image (image) ====
float sceneTrap(vec3 p, float t, out vec3 trap) {
    vec3 axis = normalize(vec3(0.0, 1.0, -0.2));
    float angle = 1.0 - cos(t * 0.8) * 0.2;
    float s = sin(angle);
    float c = cos(angle);

    float scale = 1.0;
    trap = vec3(1e5);
// https://www.youtube.com/watch?v=YUYbXfiL-mI
    for (int j = 0; j < 6; j++) {
        p = c * p + s * cross(axis, p) + (1.0 - c) * dot(axis, p) * axis;
        p = abs(p) - vec3(-0.5, 1.0, 0.7);

        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;

        p = p * 1.6 - vec3(0.5, 0.9, 0.0);
        scale *= 1.6;

        trap = min(trap, abs(p) + 0.015 * float(j));
    }

    float kifs = (length(p) - 1.0) / scale;
    float torus = (length(vec2(length(p.xz) - 1.8, p.y)) - 0.05) / scale;
    return min(kifs, torus);
}

vec3 acesTonemap(vec3 x) {
    float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 r = iResolution;
    float t = iTime;

    vec2 uv = (fragCoord * 2.0 - r.xy) / r.x;

    float fov = 1.2 + sin(t * 0.15) * 0.05;

    vec3 ro = vec3(0.0, 0.0, -6.2);
    vec3 rd = normalize(vec3(uv, fov));

    float ta = t * 0.42; 
    mat2 camRot = mat2(cos(ta), -sin(ta), sin(ta), cos(ta));
    ro.xz *= camRot;
    rd.xz *= camRot;

    vec3 accColor = vec3(0.0);
    float alphaAcc = 0.0;
    float tDist = 0.13;

    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * tDist;

        vec3 trap;
        float dScene = sceneTrap(p, t, trap);
        dScene = max(dScene, 0.0005);
        tDist += dScene;

        vec3 pal = 0.5 + 0.5 * cos(6.2831 * (trap * 0.5 + vec3(0.0, 0.33, 0.67)) + t * 0.15);

        float glow = exp(-dScene * 110.0) * 0.028;
        accColor += pal * glow;
        alphaAcc += glow;

        if (tDist > 12.0 || alphaAcc > 4.0) break;
    }

    vec3 bg = mix(vec3(0.02, 0.015, 0.05), vec3(0.0), length(uv) * 0.6);
    vec3 finalColor = mix(accColor, bg, exp(-0.55 * tDist * tDist));

    finalColor = acesTonemap(finalColor * 1.3);

    finalColor *= 1.0 - dot(uv, uv) * 0.35;

    fragColor = vec4(finalColor, 1.0);
}
