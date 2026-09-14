// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    float RayDistance = 0.0;
    for(int stepIndex = 0; stepIndex < 64; stepIndex++){
        vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.x * 0.45;
        uv += vec2(sin(iTime * 0.2) * 0.1, 1.2 + cos(iTime * 0.15) * 0.2);
        float camZoom = sin(iTime * 0.15) * 0.35;
        vec3 position = vec3(uv, RayDistance - 1.2 + camZoom);
        float accumulatedScale = 2.0;
        for(int fractalIter = 0; fractalIter < 16; fractalIter++){
            float scaleFactor = 5.7 / dot(position, position * 0.48);
            accumulatedScale *= scaleFactor;
            vec3 foldOffset = vec3(2.1 - RayDistance * 0.8, 4.1 + scaleFactor * 0.06, 3.5);
            position = vec3(0.0, 3.8, 0.6) - abs(abs(position) * scaleFactor - foldOffset);}
        RayDistance += position.y / accumulatedScale;
        accumulatedScale = log2(accumulatedScale) + RayDistance * RayDistance * 0.8;
        fragColor.rgb += 0.022 - (accumulatedScale / 850.0);}}
