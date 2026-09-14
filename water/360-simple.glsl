
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    float t = iTime * 0.5;
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);

    float pattern = sin(10.0 * dist - t) * 0.5 + 0.5;
    pattern += sin(8.0 * angle + t) * 0.3;

    vec3 color1 = vec3(0.1, 0.3, 0.4);
    vec3 color2 = vec3(0.8, 0.6, 0.4);
    vec3 color3 = vec3(0.2, 0.5, 0.3);

    vec3 finalColor = mix(color1, color2, pattern);
    finalColor = mix(finalColor, color3, sin(dist * 3.0 - t) * 0.5 + 0.5);

    finalColor *= smoothstep(1.5, 0.2, dist);

    fragColor = vec4(finalColor, 1.0);
}
