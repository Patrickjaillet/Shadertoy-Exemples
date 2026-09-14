
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float t = iTime * 0.2;
    vec3 p = vec3(uv * 1.8, t);

    float a = t * 0.3;
    mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
    p.xy = rot * p.xy;

    float scale = 1.0;
    float trap = 0.0;

    float angle = 0.785398 + sin(t * 0.5) * 0.15;
    mat2 foldRot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));

    for (int i = 0; i < 7; i++)
    {

        p = abs(p) - vec3(0.28, 0.45, 0.35);

        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;

        p.xy = foldRot * p.xy;
        p.xz = foldRot * p.xz;

        float s = 1.65;
        p = p * s - vec3(0.4, 0.8, 0.2);
        scale *= s;

        float spiralPattern = sin(p.x * 3.0) * cos(p.y * 3.0) + sin(length(p.xy) * 4.0 - t * 2.0);
        trap += abs(spiralPattern) / scale;
    }

    float d = length(p) / scale;
    float field = smoothstep(0.0, 0.08, d);
    float lines = sin(p.z * 12.0 + p.x * 8.0) * 0.5 + 0.5;

    vec3 clayColor = vec3(0.18, 0.11, 0.07);
    vec3 terracotta = vec3(0.75, 0.38, 0.18);
    vec3 flameGold  = vec3(0.95, 0.65, 0.25);

    vec3 color = mix(clayColor, terracotta, clamp(trap * 8.0, 0.0, 1.0));
    color += flameGold * pow(clamp(lines, 0.0, 1.0), 3.0) * 0.4;
    color *= (0.2 + 0.8 * field);

    float vig = 1.0 - length(uv) * 0.6;
    color *= vig;

    fragColor = vec4(color, 1.0);
}
