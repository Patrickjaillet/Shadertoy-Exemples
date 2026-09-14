// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.5;

    vec3 ro = vec3(cos(t * 0.3) * 1.5, sin(t * 0.2) * 0.8, -2.0 + sin(t * 0.1) * 0.5);
    vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);

    vec2 skyUV = (rd.xy / (abs(rd.z) + 0.8)) * 1.8 + vec2(t * 0.03, t * 0.01);
    float cloud = 0.0;
    float amp = 0.5;
    vec2 pSky = skyUV;
    mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);

    for (int i = 0; i < 5; i++) {
        vec2 i_p = floor(pSky);
        vec2 f_p = fract(pSky);
        vec2 u = f_p * f_p * (3.0 - 2.0 * f_p);

        float n00 = fract(sin(dot(i_p + vec2(0.0, 0.0), vec2(127.1, 311.7))) * 43758.5453);
        float n10 = fract(sin(dot(i_p + vec2(1.0, 0.0), vec2(127.1, 311.7))) * 43758.5453);
        float n01 = fract(sin(dot(i_p + vec2(0.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);
        float n11 = fract(sin(dot(i_p + vec2(1.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);

        float nx0 = mix(n00, n10, u.x);
        float nx1 = mix(n01, n11, u.x);
        float n = mix(nx0, nx1, u.y);

        cloud += amp * n;
        pSky = rot * pSky * 2.08 + vec2(1.7, 9.2);
        amp *= 0.5;
    }

    float cloudDensity = smoothstep(0.35, 0.75, cloud);
    float cloudShadow = smoothstep(0.2, 0.8, cloud);

    vec3 skyBase = mix(vec3(0.55, 0.72, 0.95), vec3(0.2, 0.45, 0.85), clamp(rd.y + 0.4, 0.0, 1.0));
    vec3 cloudBaseColor = vec3(0.55, 0.6, 0.72);
    vec3 cloudLightColor = vec3(0.98, 0.98, 1.0);
    vec3 cloudCol = mix(cloudBaseColor, cloudLightColor, cloudShadow);

    vec3 skyCol = mix(skyBase, cloudCol, cloudDensity);
    vec3 col = skyCol;

    float denom = rd.z;
    if (abs(denom) > 0.0001) {
        float hitT = -ro.z / denom;
        if (hitT > 0.0) {
            vec3 pos = ro + rd * hitT;
            vec2 p2d = pos.xy;

            vec3 stemColAcc = vec3(0.0);
            float stemMaskAcc = 0.0;

            if (p2d.y < 0.0 && p2d.y > -1.2) {
                float stemCurve = sin(p2d.y * 3.0 + t) * 0.05;
                float stemDist = abs(p2d.x - stemCurve);
                float stemMask = smoothstep(0.025, 0.015, stemDist);
                vec3 stemCol = mix(vec3(0.1, 0.5, 0.1), vec3(0.2, 0.7, 0.2), p2d.y + 1.2);
                stemColAcc = stemCol;
                stemMaskAcc = stemMask;
            }

            vec2 l1 = p2d - vec2(-0.18, -0.4);
            l1 *= mat2(cos(0.8), -sin(0.8), sin(0.8), cos(0.8));
            float leaf1Dist = length(l1 * vec2(2.5, 1.0));
            float leaf1Mask = smoothstep(0.25, 0.23, leaf1Dist);

            vec2 l2 = p2d - vec2(0.18, -0.7);
            l2 *= mat2(cos(-0.7), -sin(-0.7), sin(-0.7), cos(-0.7));
            float leaf2Dist = length(l2 * vec2(2.5, 1.0));
            float leaf2Mask = smoothstep(0.22, 0.20, leaf2Dist);

            vec3 leafCol = vec3(0.15, 0.6, 0.15);
            float leavesMask = max(leaf1Mask, leaf2Mask);

            vec3 backgroundElements = mix(stemColAcc, leafCol, leavesMask);
            float backgroundMask = max(stemMaskAcc, leavesMask);

            vec3 flowerCol = vec3(0.0);
            for (float i = 0.0; i < 32.0; i++) {
                float scale = pow(0.98, i);
                float angle = i * 0.15;
                vec2 p = (p2d / scale) * mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

                float r = length(p);
                float a = atan(p.y, p.x);

                float wind = sin(a * 2.0 + t + i * 0.3) * sin(t * 0.7 + r * 3.0) * r * 0.08;
                a += wind;

                p += vec2(sin(r * 2.6 + i * 1.2 + sin(t * 0.4)), cos(r * 3.4 + cos(t * 0.3))) * 0.02;

                float petC = floor(3.0 + mod(i, 3.0));

                float petVal = mix(abs(sin(a)) * 0.5, sin(petC * a), 1.0) * (1.0 - r);

                float edge = smoothstep(0.2, 0.16, abs(petVal - 0.5));
                vec3 layerCol = mix(vec3(1.0, 0.2, 0.4), vec3(1.0, 0.7, 0.8), sin(i + r * 8.0));

                flowerCol += edge * layerCol * smoothstep(0.0, 0.0, 0.8 - r) * pow(0.98, i) * 1.5;
            }

            float flowerAlpha = clamp(length(flowerCol), 0.0, 1.0);
            vec3 objectCol = mix(backgroundElements * backgroundMask, flowerCol, flowerAlpha);
            objectCol = mix(objectCol, flowerCol, step(0.001, flowerAlpha));
            float objectMask = max(backgroundMask, step(0.001, flowerAlpha));

            col = mix(skyCol, objectCol, objectMask);
        }
    }

    fragColor = vec4(tanh(col * 0.3), 1.0);
}
