
mat2 r2(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float m(vec3 p) {

    p.xy *= r2(p.z * 0.05 + iTime * 0.1);

    float d = 2.8 - length(p.xy);

    float organic = sin(p.z * 2.0 + p.y * 1.5) * 0.3;
    organic += sin(p.x * 3.5 + p.z * 2.5) * 0.15;
    organic += (sin(p.x * 7.0) * sin(p.y * 8.0) * sin(p.z * 6.0)) * 0.08;

    d -= organic;

    return d * 0.6;
}

void mainImage(out vec4 O, in vec2 U) {
    vec2 R = iResolution.xy;
    vec2 uv = (U - 0.5 * R) / R.y;

    vec3 ro = vec3(0.0, 0.0, iTime * 4.0);

    vec3 rd = normalize(vec3(uv, 1.0));

    rd.xy *= r2(sin(iTime * 0.5) * 0.1);
    float pitch = cos(iTime * 0.25) * 1.2;
    float yaw = sin(iTime * 0.4) * 3.14159;
    rd.yz *= r2(pitch);
    rd.xz *= r2(yaw);

    float t = 0.0, d;
    vec3 p;
    for(int i = 0; i < 120; i++) {
        p = ro + rd * t;
        d = m(p);

        if(d < 0.001 || t > 60.0) break;
        t += d;
    }

    vec3 c = vec3(0.05, 0.01, 0.02);

    if(t < 60.0) {

        vec2 e = vec2(0.01, 0.0);
        vec3 n = normalize(vec3(
            m(p + e.xyy) - m(p - e.xyy),
            m(p + e.yxy) - m(p - e.yxy),
            m(p + e.yyx) - m(p - e.yyx)
        ));

        vec3 ld = normalize(ro - p);
        float dif = max(dot(n, ld), 0.1);

        float dripPattern = sin(p.y * 6.0 - iTime * 3.5 + sin(p.z * 1.5) * 4.0 + sin(p.x * 3.0) * 2.0);
        float ooze = smoothstep(0.3, 0.8, dripPattern);

        vec3 baseCol = vec3(0.4, 0.15, 0.1);
        vec3 wetCol = vec3(0.2, 0.02, 0.01);
        c = mix(baseCol, wetCol, ooze * 0.8) * dif;

        vec3 ref = reflect(-ld, n);
        float baseSpec = pow(max(dot(ref, -rd), 0.0), 4.0) * 0.2;
        float wetSpec = pow(max(dot(ref, -rd), 0.0), 64.0) * ooze * 2.5;

        c += vec3(1.0, 0.8, 0.7) * (baseSpec + wetSpec);
    }

    c = mix(c, vec3(0.08, 0.02, 0.03), 1.0 - exp(-t * 0.06));

    O = vec4(pow(c, vec3(0.4545)), 1.0);
}
