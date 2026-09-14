
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    vec2 resolution = iResolution.xy;
    float time = iTime;

    float RayDistance = 0.0;

    float scaleFactor = 0.0;

    float accumulatedScale = 0.0;

    for(int stepIndex = 0; stepIndex < 64; stepIndex++) 
    {

        vec2 uv = (fragCoord - 0.5 * resolution) / resolution.x * 0.4;

        uv += vec2(0.0, 1.5);

        vec3 position = vec3(uv, RayDistance - 1.0);

        float angle = time * 0.5;
        mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        position.zx *= rotationMatrix;

        accumulatedScale = 1.8;

        for(int fractalIter = 0; fractalIter < 18; fractalIter++) 
        {

            scaleFactor = 5.7 / dot(position, position * 0.5);

            accumulatedScale *= scaleFactor;

            vec3 foldOffset = vec3(2.4 - RayDistance, 3.99 + scaleFactor * 0.08, 3.8);
            position = vec3(0.0, 4.0, 0.7) - abs(abs(position) * scaleFactor - foldOffset);
        }

        RayDistance += position.y / accumulatedScale;

        accumulatedScale = log2(accumulatedScale) + RayDistance * RayDistance;

        float hue = 0.3 / position.y;

        float saturation = position.z * 0.1;

        float brightness = accumulatedScale / 1000.0;

        vec3 hsvOffset = vec3(0.0, 2.0 / 3.0, 1.0 / 3.0);
        vec3 colorMap = clamp(abs(fract(hue + hsvOffset) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
        vec3 rgbColor = brightness * mix(vec3(1.0), colorMap, saturation);

        fragColor.rgb += 0.019 - rgbColor;
    }
}
