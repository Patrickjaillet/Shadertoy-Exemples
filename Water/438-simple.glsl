// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime * 0.6;

    vec3 ro = vec3(0.0, 0.0, time * 2.5);
    ro.x += sin(time * 0.4) * 0.8;
    ro.y += cos(time * 0.3) * 0.8;

    vec3 ta = ro + vec3(sin(time * 0.2) * 0.4, cos(time * 0.25) * 0.4, 3.0);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = cross(uu, ww);
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);

    float t = 0.0;
    vec3 col = vec3(0.002, 0.004, 0.01);
    vec3 accumGlow = vec3(0.0);

    vec3 scale = vec3(1.8, 1.8, 2.2);

    for (int stepIdx = 0; stepIdx < 40; stepIdx++) {
        vec3 p = ro + rd * t;
        
        vec3 p_w = p;
        p_w.x += sin(p.z * 0.5 + time) * 0.3;
        p_w.y += cos(p.z * 0.4 - time) * 0.3;

        vec3 baseCell = floor(p_w / scale);

        float dSpatial = 1e4;
        float dCausal = 1e4;
        float dNodes = 1e4;

        for (int k = -1; k <= 0; k++) {
            for (int j = -1; j <= 0; j++) {
                for (int i = -1; i <= 0; i++) {
                    vec3 c = baseCell + vec3(float(i), float(j), float(k));
                    
                    vec3 h0 = fract(sin(vec3(dot(c, vec3(127.1, 311.7, 74.7)), dot(c, vec3(269.5, 183.3, 246.1)), dot(c, vec3(113.5, 271.9, 124.6)))) * 43758.5453);
                    vec3 v0 = (c + 0.5 + (h0 - 0.5) * 0.7) * scale;
                    v0 += vec3(sin(time * 2.0 + h0.x * 6.28), cos(time * 1.7 + h0.y * 6.28), sin(time * 1.3 + h0.z * 6.28)) * 0.2;

                    float dn = length(p_w - v0) - 0.06;
                    dNodes = min(dNodes, dn);

                    vec3 offsets[2];
                    offsets[0] = vec3(1.0, 0.0, 0.0);
                    offsets[1] = vec3(0.0, 0.0, 1.0);

                    for (int n = 0; n < 2; n++) {
                        vec3 c1 = c + offsets[n];
                        vec3 h1 = fract(sin(vec3(dot(c1, vec3(127.1, 311.7, 74.7)), dot(c1, vec3(269.5, 183.3, 246.1)), dot(c1, vec3(113.5, 271.9, 124.6)))) * 43758.5453);
                        vec3 v1 = (c1 + 0.5 + (h1 - 0.5) * 0.7) * scale;
                        v1 += vec3(sin(time * 2.0 + h1.x * 6.28), cos(time * 1.7 + h1.y * 6.28), sin(time * 1.3 + h1.z * 6.28)) * 0.2;

                        vec3 pa = p_w - v0, ba = v1 - v0;
                        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                        float dSeg = length(pa - ba * h);

                        if (n == 0) {
                            dSpatial = min(dSpatial, dSeg);
                        } else {
                            dCausal = min(dCausal, dSeg);
                        }
                    }
                }
            }
        }

        dSpatial -= 0.022;
        dCausal -= 0.018;

        float dMesh = min(min(dSpatial, dCausal), dNodes);

        float rad = length(p_w.xy);
        float fade = smoothstep(4.5, 1.5, rad);

        float nodeGlow = (0.015 / (max(dNodes, 0.0) * max(dNodes, 0.0) + 0.002)) * fade;
        float spatialGlow = (0.008 / (max(dSpatial, 0.0) * max(dSpatial, 0.0) + 0.003)) * fade;
        float causalGlow = (0.008 / (max(dCausal, 0.0) * max(dCausal, 0.0) + 0.003)) * fade;

        accumGlow += vec3(0.1, 0.5, 1.0) * spatialGlow;
        accumGlow += vec3(1.0, 0.5, 0.1) * causalGlow;
        accumGlow += vec3(1.0, 0.95, 0.8) * nodeGlow;

        float dStep = max(dMesh, 0.04);
        t += dStep * 0.6;

        if (t > 25.0) break;
    }

    col += accumGlow * 0.04;

    col = col / (col + vec3(1.0));
    col = pow(col, vec3(0.4545));

    vec2 q = fragCoord / iResolution.xy;
    col *= pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.25);

    fragColor = vec4(col, 1.0);
}
