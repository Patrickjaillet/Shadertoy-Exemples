
void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    float coordScale = 2.0;
    vec2 uv = (fragCoord * coordScale - iResolution.xy) / iResolution.y;
    float time = iTime;

    float rotSpeed1 = 0.2;
    float cosRot1 = cos(time * rotSpeed1);
    float sinRot1 = sin(time * rotSpeed1);
    mat2 rot1 = mat2(cosRot1, -sinRot1, sinRot1, cosRot1);

    float rotSpeed2 = 0.15;

    float rotOffset2 = 0.3;
    float cosRot2 = cos(time * rotSpeed2 + rotOffset2);
    float sinRot2 = sin(time * rotSpeed2 + rotOffset2);
    mat2 rot2 = mat2(cosRot2, -sinRot2, sinRot2, cosRot2);

    vec2 rotInnerVec = cos(3.14/2. + iTime*.1 + vec2(0,33));
    mat2 rotInner = mat2(rotInnerVec.x, -rotInnerVec.y, rotInnerVec.y, rotInnerVec.x);

    float initialFragColor = 0.1;
    fragColor = vec4(initialFragColor);

    float totalDistance = 0.0;

    float maxRaySteps = 32.0;
    for (float i = 0.0; i < maxRaySteps; i++) {
        vec3 rayPosition = vec3(uv * totalDistance, totalDistance);

        rayPosition.xz *= rot1;
        rayPosition.yz *= rot2;

        float cameraSpeed = 0.6;
        rayPosition.z += time * cameraSpeed;

        float spaceOffset = 1.0;
        rayPosition += spaceOffset;

        float baseOrbitDistance = 9.0;
        float minOrbitDistance = baseOrbitDistance;

        float baseFractalScale = 9.0;
        float fractalScale = baseFractalScale;

        float stepDistance = 0.0;

        int maxFractalIterations = 7;
        for (int j = 0; j < maxFractalIterations; j++) {

            float modPeriod = 2.0;

            float modOffset = 1.0;
            rayPosition = mod(rayPosition - modOffset, modPeriod) - modOffset;
            rayPosition.yz *= rotInner;

            minOrbitDistance = min(minOrbitDistance, length(rayPosition));

            float inversionFactor = 0.6;
            stepDistance = dot(rayPosition, rayPosition) * inversionFactor;

            fractalScale /= stepDistance;
            rayPosition /= stepDistance;
        }

        float scaleInversion = 1.0;
        stepDistance = scaleInversion / fractalScale;
        totalDistance += stepDistance;

        float hueScaleDistance = 0.08;

        float hueScaleTime = 0.04;
        float colorHue = fract(minOrbitDistance + totalDistance * hueScaleDistance + time * hueScaleTime);

        float redPhase = 1.0;

        float greenPhase = 2.0 / 3.0;

        float bluePhase = 1.0 / 3.0;
        vec3 phaseOffsets = vec3(redPhase, greenPhase, bluePhase);

        float waveFrequency = 20.0;

        float waveOffset = 3.0;
        vec3 p = abs(fract(colorHue + phaseOffsets) * waveFrequency - waveOffset);

        float clampMin = 0.2;

        float clampMax = 1.0;

        float mixFactor = 0.7;

        float colorIntensity = 2.6;
        vec3 rgbColor = colorIntensity * mix(vec3(1.0), clamp(p - 1.0, clampMin, clampMax), mixFactor);

        float glowIntensity = 0.014;

        float falloffStep = 1200.0;

        float falloffDistance = 0.15;
        fragColor.rgb += glowIntensity / exp(stepDistance * falloffStep + totalDistance * falloffDistance) * rgbColor;
    }

    vec3 x = fragColor.rgb;

    float aces_a = 2.51;

    float aces_b = 0.03;

    float aces_c = 1.68;

    float aces_d = 0.59;

    float aces_e = 0.14;

    float clampFloor = 0.0;

    float clampCeil = 1.0;

    fragColor.rgb = clamp((x * (aces_a * x + aces_b)) / (x * (aces_c * x + aces_d) + aces_e), clampFloor, clampCeil);

    float alphaChannel = 1.0;
    fragColor.a = alphaChannel;
}
