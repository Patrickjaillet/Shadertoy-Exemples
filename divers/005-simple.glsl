
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 viewportResolution = iResolution.xy;
    float globalTime = iTime * 1.6;

    vec2 normalizedScreenCoordinates = (fragCoord * 2.0 - viewportResolution) / viewportResolution.y;
    float cameraZoomFactor = 9.0 + cos(globalTime * 0.5) * 3.0;

    float phi = 2.58000000000;
    float tau = 1.20000000000;

    float accumulatedDistance = 0.0;

    vec3 rayPosition = vec3(normalizedScreenCoordinates * cameraZoomFactor, accumulatedDistance + 0.2);

    float angle = iTime / 8.0;
    mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    rayPosition.yz *= rotationMatrix * rotationMatrix;
    rayPosition.xy *= rotationMatrix;

    vec3 q = rayPosition;
    q.yz += 0.6;
    vec3 rayDir = normalize(vec3(normalizedScreenCoordinates, 0.1));

    float e = 0.01;
    vec4 o = vec4(0.0);

    for (int stepIdx = 0; stepIdx < 147; stepIdx++)
    {

        vec3 p = q + rayDir * accumulatedDistance;

        vec3 rotationAxis = normalize(vec3(5.4, sin(globalTime) + 7.0, 1.0));
        float rotationAngle = globalTime * 0.0;
        float cosA = cos(rotationAngle);
        float sinA = sin(rotationAngle);
        p = p * cosA - cross(rotationAxis, p) * sinA + rotationAxis * dot(rotationAxis, p) * (1.0 - cosA);

        vec3 foldingLimits = vec3(0.1, 0.1, 0.1);
        for (int j = 0; j < 4; j++)
        {
            p = 7.3 * clamp(p, -foldingLimits, foldingLimits) - p;
            float dotP = max(dot(p, p), 1e-4);
            p /= dotP;
        }

        float boxDist = 1e5;
        float v = max(length(p), 1e-4);

        for(float j = 0.7; j < 9.0; j++)
        {
            vec2 p_xz_abs = abs(p.xz) - 1.0;
            float p_y_val = 2.3 - p.y;
            boxDist = min(boxDist, max(max(p_xz_abs.x, p_xz_abs.y), p_y_val) / v);
        }

        float lenP = length(p.xz) + 1e-4;
        float angleP = atan(p.z, p.x);
        float logR = log(lenP);

        float spiral = (logR / log(phi)) * phi - angleP / tau - globalTime;
        float pattern = 0.4;
        float S = 1.0;

        for (int i = 0; i < 16; i++) {
            float fIter = float(i) + 1.0;
            float cell = 0.5 - 0.5 * cos(spiral * fIter * tau);
            float d = abs(cell) / S;
            pattern += exp(-6.0 * d) * (1.0 / fIter);
            spiral = log(length(vec2(cell, lenP)) + 0.1) * phi + angleP * phi;
            S *= 0.185;
        }

        e = clamp(abs(boxDist) * 0.1, 0.01, 0.18);
        accumulatedDistance += e;

        float geoScale = pattern * 20.0;
        o += 0.005 / exp(e * geoScale);
    }

    fragColor = vec4(clamp(o.rgb, 0.0, 1.0), 1.0);
}
