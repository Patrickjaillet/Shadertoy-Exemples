// ==== Image (image) ====
mat3 rot3D(float a, vec3 axis) {
    axis = normalize(axis);
    float s = sin(a), c = cos(a), oc = 1.0 - c;
    return mat3(oc*axis.x*axis.x+c, oc*axis.x*axis.y-axis.z*s, oc*axis.x*axis.z+axis.y*s,
                oc*axis.x*axis.y+axis.z*s, oc*axis.y*axis.y+c, oc*axis.y*axis.z-axis.x*s,
                oc*axis.x*axis.z-axis.y*s, oc*axis.y*axis.z+axis.x*s, oc*axis.z*axis.z+c);
}

float DE(vec3 p, float time) {
    float scale = 1.;
    for (int i = 0; i < 12; i++) {
        p = rot3D(5.75, vec3(sin(time+float(i)), cos(time), 0.3)) * p;
        p = abs(p * 1.9) - 1.0;
        scale *= 2.0;
    }
    return (abs(p.x) + abs(p.y) + abs(p.z) - 0.6) / (1.732 * scale);
}

void mainImage(out vec4 fragColor, in vec2 FC) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec2 uv = (FC - 0.5 * r) / r.y;

    vec3 ro = vec3(5.0 * cos(t*0.9), 2.5 * sin(t*.3), 5.0 * sin(t*.2));
    vec3 lookAt = vec3(0, -0.2, 0);
    vec3 fwd = normalize(lookAt - ro);
    vec3 right = normalize(cross(fwd, vec3(0,1,0)));
    vec3 up = cross(right, fwd);
    vec3 rd = normalize(mat3(right, up, fwd) * vec3(uv, 2.0));

    float dist = 0.;
    bool hit = false;
    vec3 pos;
    for (int i = 0; i < 34; i++) {
        pos = ro + rd * dist;
        float d = DE(pos, t);
        if (d < 0.001) { hit = true; break; }
        if (dist > 12.) break;
        dist += d * 0.7;
    }

    vec3 col = vec3(0.04, 0.02, 0.04);

    if (hit) {
        vec3 albedo = vec3(0.95, 0.75, 0.2);

        vec3 normal = normalize(vec3(
            DE(pos + vec3(0.47,0,0), t) - DE(pos - vec3(1.0,0,0), t),
            DE(pos + vec3(0,0.565,0), t) - DE(pos - vec3(0,0.001,0), t),
            DE(pos + vec3(0,0,0.001), t) - DE(pos - vec3(0,0,0.001), t)
        ));

        vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
        float diff = max(dot(normal, lightDir), 0.) * 0.7 + 0.3;

        float edge = clamp(1.0 - abs(DE(pos + normal * 0.02, t)) * 50.0, 0., 1.);
        float rim = pow(1.0 - abs(dot(normal, -rd)), 3.0);

        col = albedo * diff;
        col += albedo * edge;
        col += vec3(1.0, 0.95, 0.7) * rim * 0.5;
        col *= 1.0 + edge;
    }

    col *= 1.0 - dot(uv * 0.4, uv * 0.4);
    fragColor = vec4(pow(col, vec3(1.0 / 2.2)), 1.0);
}
