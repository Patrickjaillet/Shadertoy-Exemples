// ==== Image (image) ====
// Hash rapide pour le bruit
float hash12(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Bruit de Perlin 2D
float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float mapValue(float val, float inMin, float inMax, float outMin, float outMax) {
    return outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 color = vec3(39.0 / 255.0);

    vec2 noise_param = vec2(hash12(vec2(39.0, 1.0)) * 1000.0, hash12(vec2(39.0, 2.0)) * 1000.0);
    float frameNum = iTime * 25.0;
    float PI = 3.14159265359;
    float DEG_TO_RAD = PI / 180.0;

    float rRed = 3.0 / iResolution.y;
    float rBlack = 2.0 / iResolution.y;

    // Estimation du rayon pour cibler uniquement les anneaux voisins
    float rPixel = length(uv);
    float iEst = (rPixel * 720.0 - 50.0) / 10.0;
    int iStart = clamp(int(floor(iEst)) - 2, 0, 79);
    int iEnd = clamp(int(ceil(iEst)) + 2, 0, 79);

    for (int i = iStart; i <= iEnd; i++) {
        float fi = float(i);

        float noiseRot = valueNoise(vec2(noise_param.x, fi * 0.05 - frameNum * 0.025));
        float rotate_deg = mapValue(noiseRot, 0.0, 1.0, -20.0, 20.0);
        float rotRad = rotate_deg * DEG_TO_RAD;

        float radius = (50.0 + fi * 10.0) / 720.0;
        float noiseDeg = valueNoise(vec2(noise_param.y, fi * 0.01 - frameNum * 0.005));
        float degStart = mapValue(noiseDeg, 0.0, 1.0, 0.0, 1440.0);

        // Annulation sûre de la rotation Y sur les coordonnées UV
        float cosR = cos(rotRad);
        vec2 uvRot = vec2(uv.x / max(abs(cosR), 0.001), uv.y);

        // Calcul de l'angle UV ramené dans le repère local [0, 360]
        float anglePixel = atan(uvRot.y, uvRot.x) / DEG_TO_RAD;
        if (anglePixel < 0.0) anglePixel += 360.0;

        // Normalisation de degStart par rapport aux cycles de 360 deg
        float baseDeg = mod(degStart, 360.0);
        float deltaDeg = anglePixel - baseDeg;
        if (deltaDeg < 0.0) deltaDeg += 360.0;

        // Tester les différentes révolutions de l'arc (de 0 à 1440 deg = 4 tours)
        for (float rev = 0.0; rev < 1440.0; rev += 360.0) {
            float targetDeg = baseDeg + deltaDeg + rev;
            if (targetDeg >= degStart && targetDeg <= degStart + 180.0) { // 720 * 0.25deg = 180 deg d'arc
                float radAngle = targetDeg * DEG_TO_RAD;
                vec2 pointPos = vec2(radius * cos(radAngle), radius * sin(radAngle));

                // Projection de la distance re-mesurée
                vec2 projPoint = vec2(pointPos.x * cosR, pointPos.y);
                float d = length(uv - projPoint);

                // Dessin des cercles rouge et noir
                float circleRed = smoothstep(rRed, rRed - 1.0 / iResolution.y, d);
                color = mix(color, vec3(239.0 / 255.0, 39.0 / 255.0, 39.0 / 255.0), circleRed);

                float circleBlack = smoothstep(rBlack, rBlack - 1.0 / iResolution.y, d);
                color = mix(color, vec3(0.0), circleBlack);
            }
        }
    }

    fragColor = vec4(color, 1.0);
}
