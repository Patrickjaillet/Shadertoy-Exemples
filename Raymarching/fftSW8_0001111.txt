// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 red = vec4(0.9, 0.1, 0.2, 1.0);
    vec4 green = vec4(0.584, 0.901, 0.270, 1.0);
    vec4 green2 = vec4(0.254, 0.301, 0.211, 1.0);
    vec4 blue = vec4(0.631, 0.901, 0.901, 1.0);
    vec4 orange = vec4(0.901, 0.835, 0.270, 1.0);

    vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    float dither = fract(sin(dot((uv + fract(iTime)) * 0.1, vec2(324.654, 156.546))) * 46556.24);
    vec3 eye = vec3(0.0, 0.0, -8.0);
    vec3 ray = normalize(vec3(uv, 1.0));
    vec3 pos = eye;
    vec4 color = vec4(0.0);
    float t = iTime * 0.2;

    for (float i = 0.0; i <= 1.0; i += 1.0 / 30.0) {
        float shapeDist = 1000.0;
        vec4 shapeColor = vec4(1.0);

        float twist = 0.5;
        float count = 8.0;
        float interval = 2.0;
        float outter = 2.0;

        vec3 p = pos;
        float a1 = sin(pos.y * twist + t);
        p.xz = mat2(cos(a1), sin(a1), -sin(a1), cos(a1)) * p.xz;

        float ca1 = (2.0 * 3.14159) / count;
        float ang1 = atan(p.z, p.x) + ca1 * 0.5;
        float index = floor(ang1 / ca1);
        ang1 = mod(ang1, ca1) - ca1 * 0.5;
        p.xz = vec2(cos(ang1), sin(ang1)) * length(p.xz);

        float sens = mix(-1.0, 1.0, mod(index, 2.0));
        p.x -= outter;

        float stem = length(p.xz) - (0.04 + 0.02 * sin(p.y * 4.0 - iTime * sens));

        p.y = mod(p.y + index + t * sens, interval) - interval * 0.5;
        float a2 = 0.25 * sens;
        p.xy = mat2(cos(a2), sin(a2), -sin(a2), cos(a2)) * p.xy;
        float a3 = 0.15 * sens;
        p.yz = mat2(cos(a3), sin(a3), -sin(a3), cos(a3)) * p.yz;
        p.x -= 0.8;
        p.y -= sin(abs(p.z) * 3.0) * 0.1;
        p.y -= sin(abs(p.x - 0.7) * 3.0) * 0.1;
        float leaf = max(length(p.xz) - 0.7, abs(p.y) - 0.01);

        p = pos;
        float a4 = pos.y + sin(pos.y + t * 10.0) - t * 4.0;
        p.xz = mat2(cos(a4), sin(a4), -sin(a4), cos(a4)) * p.xz;

        float ca2 = (2.0 * 3.14159) / 3.0;
        float ang2 = atan(p.z, p.x) + ca2 * 0.5;
        index = floor(ang2 / ca2);
        ang2 = mod(ang2, ca2) - ca2 * 0.5;
        p.xz = vec2(cos(ang2), sin(ang2)) * length(p.xz);

        p.x -= 0.3 + 0.2 * (0.5 + 0.5 * sin(pos.y + t));
        float innerStem = length(p.xz) - 0.05;

        p = pos;
        interval = 0.6;
        p.y = mod(p.y + t * 4.0, interval) - interval * 0.5;
        float seed = length(p) - (0.3 * (0.5 + 0.5 * sin(pos.y + 0.5)));

        p = pos;
        float a5 = pos.y * 0.5 + t;
        p.xz = mat2(cos(a5), sin(a5), -sin(a5), cos(a5)) * p.xz;
        p.x -= 1.2;
        float a6 = pos.y * 0.5 - t * 9.0;
        p.xz = mat2(cos(a6), sin(a6), -sin(a6), cos(a6)) * p.xz;

        float ca3 = (2.0 * 3.14159) / 8.0;
        float ang3 = atan(p.z, p.x) + ca3 * 0.5;
        index = floor(ang3 / ca3);
        ang3 = mod(ang3, ca3) - ca3 * 0.5;
        p.xz = vec2(cos(ang3), sin(ang3)) * length(p.xz);

        p.x -= 0.1 + (0.5 * (0.5 + 0.5 * sin(pos.y + 3.0 * t)));
        float water = length(p.xz) - 0.04;

        float h1 = clamp(0.5 + 0.5 * (stem - leaf) / 0.3, 0.0, 1.0);
        float sceneLeaves = mix(stem, leaf, h1) - 0.3 * h1 * (1.0 - h1);
        float scene = min(seed, innerStem);

        float h2 = clamp(0.5 + 0.5 * (seed - innerStem) / 0.1, 0.0, 1.0);
        shapeColor = mix(red, orange, h2);

        float h3 = clamp(0.5 + 0.5 * (scene - stem) / 0.3, 0.0, 1.0);
        shapeColor = mix(shapeColor, green2, h3);

        scene = min(stem, scene);

        float h4 = clamp(0.5 + 0.5 * (scene - sceneLeaves) / 0.1, 0.0, 1.0);
        shapeColor = mix(shapeColor, green, h4);

        shapeColor = mix(shapeColor, blue, step(water, scene));

        shapeDist = min(water, min(sceneLeaves, scene));

        if (shapeDist < 0.01) {
            color = shapeColor * (1.0 - i);
            break;
        }
        shapeDist *= 0.9 + 0.1 * dither;
        pos += ray * shapeDist;
    }

    fragColor = color;
}
