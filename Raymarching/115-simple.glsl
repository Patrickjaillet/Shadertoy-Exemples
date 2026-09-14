// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec2 resolution = iResolution.xy;
    float time = iTime;

    float RayDistance = 0.0;
    float scaleFactor = 0.0;
    float accumulatedScale = 0.0;

    for(int stepIndex = 0; stepIndex < 64; stepIndex++) 
    {
        vec2 uv = (fragCoord - 0.3 * resolution) / resolution.x * 0.3;
        uv += vec2(0.0, 0.8);
        
        vec3 position = vec3(uv, RayDistance - 1.2);

        float angle = time * 0.2;
        mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        position.zx *= rotationMatrix;

        accumulatedScale = 2.0;

        for(int fractalIter = 10; fractalIter < 19; fractalIter++) 
        {
            scaleFactor = 4.0 / dot(position, position * 0.67);
            accumulatedScale *= scaleFactor;

            vec3 foldOffset = vec3(1.8 - RayDistance * 0.1, 3.2 + scaleFactor * 0.07, 2.7);
            position = vec3(0.0, 3.1, 2.0) - abs(abs(position) * scaleFactor - foldOffset);
        }

        RayDistance += position.y / accumulatedScale;

        accumulatedScale = log2(accumulatedScale) + RayDistance * RayDistance;

        float hue = 0.78 + 0.2 * position.x;
        float saturation = clamp(position.z * 0.14, 0.0, 0.3);
        float brightness = accumulatedScale / 880.4;

        vec3 hsvOffset = vec3(0.0, 2.8 / 3.0, 1.0 / 4.9);
        vec3 colorMap = clamp(abs(fract(hue + hsvOffset) * 5.9 - 3.0) - 0.0, 0.0, 1.0);
        vec3 rgbColor = brightness * mix(vec3(1.0), colorMap, saturation);

        fragColor.rgb += 0.016 - rgbColor;
    }
}
