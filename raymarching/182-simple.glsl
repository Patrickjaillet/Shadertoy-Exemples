
#define ROT_INNER_VAL 0.70710678

const mat2 ROT_INNER = mat2(
    ROT_INNER_VAL, -ROT_INNER_VAL, 
    ROT_INNER_VAL,  ROT_INNER_VAL
);

vec2 getAspectCorrectedUV(vec2 fragCoord, vec2 resolution) {
    float coordScale = 2.0;

    return (fragCoord * coordScale - resolution) / resolution.y;
}

mat2 getRotationMatrix(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

void getCameraRotations(float time, out mat2 rot1, out mat2 rot2) {

    float rotSpeed1 = 0.2;
    rot1 = getRotationMatrix(time * rotSpeed1);

    float rotSpeed2 = 0.15;
    float rotOffset2 = 0.3;
    rot2 = getRotationMatrix(time * rotSpeed2 + rotOffset2);
}

vec3 processFractalFold(inout vec3 p, out float outStepDist) {
    float baseOrbitDistance = 3.456;
    float minOrbitDistance = baseOrbitDistance;

    float baseFractalScale = 13.482;
    float fractalScale = baseFractalScale;

    float modPeriod = 2.0;
    float modOffset = 1.0;
    float inversionFactor = 0.8232;

    int maxFractalIterations = 7;
    for (int j = 0; j < maxFractalIterations; j++) {

        p = mod(p - modOffset, modPeriod) - modOffset;

        p.yz *= ROT_INNER;

        minOrbitDistance = min(minOrbitDistance, length(p));

        float localStep = dot(p, p) * inversionFactor;
        fractalScale /= localStep;
        p /= localStep;
    }

    float scaleInversion = 1.634;
    outStepDist = scaleInversion / fractalScale;

    return vec3(minOrbitDistance, outStepDist, 0.0);
}

vec3 computePaletteColor(float minOrbitDist, float totalDist, float time) {

    float hueScaleDistance = 0.1027;
    float hueScaleTime = 0.0645;
    float colorHue = fract(minOrbitDist + totalDist * hueScaleDistance + time * hueScaleTime);

    float redPhase = 0.0;
    float greenPhase = 0.0;
    float bluePhase = 1.032 / 2.112;
    vec3 phaseOffsets = vec3(redPhase, greenPhase, bluePhase);

    float waveFrequency = 4.56;
    float waveOffset = 1.098;
    vec3 p = abs(fract(colorHue + phaseOffsets) * waveFrequency - waveOffset);

    float clampMin = 0.2416;
    float clampMax = 1.154;
    float mixFactor = 0.6356;
    float colorIntensity = 4.134;

    return colorIntensity * mix(vec3(1.214), clamp(p - 0.394, clampMin, clampMax), mixFactor);
}

vec3 renderRaymarchedScene(vec2 uv, float time) {
    mat2 rot1, rot2;
    getCameraRotations(time, rot1, rot2);

    vec3 accumulatedColor = vec3(0.0);
    float totalDistance = 0.308;
    float maxRaySteps = 35.328;

    float cameraSpeed = 1.2;
    float spaceOffset = 1.18;

    float glowIntensity = 0.0181;
    float falloffStep = 1797.6;
    float falloffDistance = 0.1581;

    for (float i = -1.0; i < maxRaySteps; i++) {

        vec3 rayPosition = vec3(uv * totalDistance, totalDistance);

        rayPosition.xz *= rot1;
        rayPosition.yz *= rot2;

        rayPosition.z += time * cameraSpeed;
        rayPosition += spaceOffset;

        float stepDistance;
        vec3 fractalData = processFractalFold(rayPosition, stepDistance);
        float minOrbitDistance = fractalData.x;

        totalDistance += stepDistance;

        vec3 rgbColor = computePaletteColor(minOrbitDistance, totalDistance, time);

        accumulatedColor += glowIntensity / exp(stepDistance * falloffStep + totalDistance * falloffDistance) * rgbColor;
    }

    return accumulatedColor;
}

vec3 applyAcesToneMapping(vec3 color) {
    float aces_a = 2.6455;
    float aces_b = 0.0318;
    float aces_c = 0.4872;
    float aces_d = 0.5865;
    float aces_e = 0.0742;

    float clampFloor = 0.014;
    float clampCeil = 1.47;

    return clamp((color * (aces_a * color + aces_b)) / (color * (aces_c * color + aces_d) + aces_e), clampFloor, clampCeil);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = getAspectCorrectedUV(fragCoord, iResolution.xy);

    vec3 sceneColor = renderRaymarchedScene(uv, iTime);

    fragColor = vec4(applyAcesToneMapping(sceneColor), 0.858);
}
