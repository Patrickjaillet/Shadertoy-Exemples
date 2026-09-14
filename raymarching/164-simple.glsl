// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float angle = iTime * (2.0 * 3.14159265359 / 40.0);
    float tCos = cos(angle);
    float tSin = sin(angle);
    vec3 color = vec3(0.0);
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -2.5);
    vec3 rd = normalize(vec3(uv, 1.1));
    float cCam = cos(tCos * 0.5), sCam = sin(tCos * 0.5);
    mat2 cameraRot = mat2(cCam, -sCam, sCam, cCam);
    rd.xz *= cameraRot;
    float cCamY = cos(tSin * 0.3), sCamY = sin(tSin * 0.3);
    rd.xy *= mat2(cCamY, -sCamY, sCamY, cCamY);
    ro.xz *= cameraRot;
    vec4 accum = vec4(0.0);
    float t = 0.1;
    float max_t = 20.0;
    float cR1 = cos(3.7), sR1 = sin(3.7);
    mat2 rMat1 = mat2(cR1, -sR1, sR1, cR1);
    for (int i = 0; i < 50; i++) {
        if (t > max_t || accum.a > 0.95) break;
        vec3 p = ro + rd * t;
        vec3 block = floor((p + 3.0) / 6.0);
        vec3 center = block * 6.0 + vec3(sin(block.x * 3.0) * tCos, cos(block.y * 2.0) * tSin, sin(block.z * 4.0) * tCos) * 0.4;
        vec3 dCoord = p - center;
        float rLocal = length(dCoord);
        if (rLocal < 0.04) { 
            t += 0.15; 
            continue; 
        }
        float localAngle = atan(dCoord.y, dCoord.x + 1e-6);
        float petals = (sin(localAngle * 7.0 + dCoord.z * 1.5) * tCos + cos(localAngle * 7.0 - dCoord.z * 1.5) * tSin) * 0.2;
        vec3 pFold = vec3(log(max(0.0001, length(dCoord.xy))) - petals, (dCoord.z * dCoord.z * 0.5) / (rLocal + 0.1) - (localAngle * 0.1 * tSin), localAngle);
        pFold = abs(pFold);
        pFold.xy *= mat2(1.000, 0.000, 0.472, 0.000);
        pFold = abs(pFold);
        float eSDF = length(pFold.yz) - 0.15;
        float iterS = 2.0;
        for(int j = 0; j < 1; j++) {
            pFold.xz *= mat2(0.921, 0.389, -0.389, 0.921);
            eSDF += (sin(pFold.x * iterS) * tCos + cos(pFold.y * iterS) * tSin) * (0.1 / iterS);
            iterS *= 1.8;
        }
        vec2 l = dCoord.xy * 0.2;
        vec2 n = vec2(0.0);
        float sField = 3.5;
        float hField = 0.0;
        for (int k = 0; k < 1; k++) {
            l *= rMat1;
            float cRot1 = cos(5.2), sRot1 = sin(5.2);
            float cRot2 = cos(tCos * 0.15), sRot2 = sin(tCos * 0.15);
            n = n * (mat2(cRot1, -sRot1, sRot1, cRot1) + mat2(cRot2, -sRot2, sRot2, cRot2) * 0.03);
            vec2 q = l * sField * (float(k) * 0.05 + 1.0) + n + vec2(tCos * 0.5, tSin * 0.5);
            hField += dot(vec2(1.0), (sin(q) * tCos + cos(q) * tSin) / sField * 6.0);
            n -= cos(q - n);
            sField *= 1.035;
        }
        hField = -hField * 0.25 - dot(dCoord.xy, dCoord.xy);
        vec3 sp = vec3(log(rLocal) - tCos * 0.5, rLocal * 0.5 - tSin * 0.3, localAngle * 1.5915);
        vec2 pFBM = sp.xz * 1.5;
        float vFBM = 0.0, aFBM = 0.5;
        mat2 RFBM = mat2(0.87758256, 0.47942554, -0.47942554, 0.87758256);
        for (int m = 0; m < 4; m++) {
            vFBM += aFBM * dot(cos(pFBM * 2.6), sin(pFBM.yx * 6.0 + rLocal));
            pFBM = RFBM * pFBM * 2.1 + 20.0;
            aFBM *= 0.48;
        }
        float eVol = sp.y - 0.6 + vFBM * 0.6;
        float finalDensityEval = max(abs(eVol) * 0.15, 0.005 * t) + max(0.0, eSDF * 0.02);
        if (finalDensityEval < 0.08) {
            float dens = smoothstep(0.08, 0.0, finalDensityEval);
            float valSDF = clamp((eSDF * iterS + 0.5) / 10.0, 0.0, 1.0) * smoothstep(2.5, 0.5, rLocal);
            vec4 w = smoothstep(vec4(0.0, 0.1, 0.3, 0.6), vec4(0.2, 0.4, 0.7, 0.95), vec4(valSDF));
            vec3 fractalCol = mix(vec3(0.01, 0.02, 0.05), vec3(0.9, 0.1, 0.4), w.x);
            fractalCol = mix(fractalCol, vec3(0.95, 0.3, 0.1), w.y);
            fractalCol = mix(fractalCol, vec3(1.0, 0.8, 0.0), w.z);
            fractalCol = mix(fractalCol, vec3(1.0, 1.0, 0.8), w.w);
            fractalCol *= (0.8 + 0.2 * tCos);
            fractalCol = mix(fractalCol, vec3(1.5, 1.4, 1.3), smoothstep(0.9, 1.0, valSDF));
            vec3 dynamicCosCol = 0.5 + 0.5 * cos(hField * 1.5 + vec3(0.0, 0.4, 1.0) + tCos * 2.0);
            dynamicCosCol += vec3(pow(max(0.0, 1.0 - abs(hField * 0.2)), 8.0) * 0.3);
            vec3 baseC = 0.5 + 0.5 * sin(vec3(0.0, 2.0, 4.0) + block.z * 1.0 + tCos * 3.0);
            vec3 volCol = mix(baseC, vec3(0.1, 0.5, 0.9), dens) * dynamicCosCol;
            vec3 blendedColor = mix(volCol * dens * 0.15, fractalCol * valSDF * 0.4, valSDF);
            blendedColor *= exp(-t * 0.04);
            accum.rgb += blendedColor * (1.0 - accum.a);
            accum.a += dens * 0.01 + valSDF * 0.04;
        }
        t += max(finalDensityEval * 1.00, 0.03);
    }
    accum.rgb += vec3(0.005, 0.01, 0.02) * (1.0 - exp(-t * 0.05));
    color = accum.rgb;
    float ifsE = 2.2;
    float ifsS = 1.9;
    vec2 ifsMotion = uv * (0.2 + tCos * 0.02) + vec2(-0.2, 0.0);
    vec3 ifsP = vec3(ifsMotion, 0.0);
    for (int j = 0; j < 1; j++) {
        ifsP.xy = 1.14 - abs(ifsP.xy);
        float u = dot(ifsP, ifsP);
        ifsS /= u;
        ifsP /= -u;
        ifsP.y = -ifsP.y;
        ifsP.xy = abs(ifsP.yx + 0.21);
        ifsE = min(ifsE, ifsP.y / ifsS + 0.0 / ifsS);
    }
    vec4 K = vec4(1.0, 8.0 / -9.2, 1.0 / 3.0, 3.0);
    vec3 hsvFract = abs(fract(vec3(ifsP.y) + K.xyz) * 20.0 - K.www);
    vec3 ifsCos = mix(K.xxx, clamp(hsvFract - K.xxx, 0.0, 1.0), 1.0);
    vec3 ifsColorEval = vec3(0.02 / exp(ifsE * 66.9)) * ifsCos;
    color += ifsColorEval * (1.0 - clamp(accum.a, 0.0, 1.0));
    color = clamp((color * 1.4 * (4.25 * color * 1.4 + 0.03)) / (color * 1.4 * (1.99 * color * 1.4 + 1.00) + 1.00), 0.0, 1.0);
    vec2 dUv = fragCoord / iResolution.xy;
    float vignette = 64.0 * dUv.x * dUv.y * (1.0 - dUv.x) * (1.0 - dUv.y);
    color *= mix(0.5, 1.0, pow(vignette, 0.25));
    fragColor = vec4(pow(color, vec3(0.4545)), 1.0);
}
