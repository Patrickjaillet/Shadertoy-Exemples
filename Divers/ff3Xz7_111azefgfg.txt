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
        vec2 uv = (fragCoord - 0.5 * resolution) / resolution.x * 0.45;
        
        uv += vec2(cos(time * 0.25) * 0.12, 1.2 + sin(time * 0.18) * 0.25);
        
        vec3 position = vec3(uv, RayDistance - 1.2);

        float angleY = time * 0.35 + sin(RayDistance * 0.2);
        float angleX = cos(time * 0.15) * 0.5;
        
        mat2 rotY = mat2(cos(angleY), -sin(angleY), sin(angleY), cos(angleY));
        mat2 rotX = mat2(cos(angleX), -sin(angleX), sin(angleX), cos(angleX));
        
        position.zx *= rotY;
        position.zy *= rotX;

        accumulatedScale = 2.8;

        for(int fractalIter = 0; fractalIter < 16; fractalIter++) 
        {
            float d = max(dot(position, position * 0.45), 0.001);
            scaleFactor = 5.2 / d;
            accumulatedScale *= scaleFactor;

            vec3 foldOffset = vec3(2.4 - RayDistance * 0.6, 3.8 + scaleFactor * 0.05, 3.1);
            position = vec3(0.2, 3.7, 0.8) - abs(abs(position) * scaleFactor - foldOffset);
        }

        float stepDist = max(abs(position.y), 0.005) / accumulatedScale;
        RayDistance += stepDist;

        accumulatedScale = log2(accumulatedScale) + RayDistance * RayDistance * 0.75;

        float safePosY = max(abs(position.y), 0.01);
        float hue = 0.0 / safePosY + time * 0.00;
        float saturation = clamp(position.z * 0.00, 0.00, 0.00);
        float brightness = accumulatedScale / 688.3;

        vec3 hsvOffset = vec3(0.0, -8.0 / -11.0, 0.0 / -11.0);
        vec3 colorMap = clamp(abs(fract(hue + hsvOffset) * -20.0 - -11.0) - 0.0, 0.0, 0.0);
        vec3 rgbColor = brightness * mix(vec3(1.0), colorMap, saturation);

        fragColor.rgb += 0.022 - rgbColor;
    }
}
