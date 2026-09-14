
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = iResolution.xy;
    vec2 FC = fragCoord;
    float t = iTime;

    float sT = sin(t);
    float cT = cos(t);
    mat2 rotTime = mat2(cT, -sT, sT, cT);      

    float sS = sin(24.8);
    float cS = cos(24.8);
    mat2 rotStep = mat2(cS, -sS, sS, cS);

    vec3 q = vec3(0.0, 0.45, -3.0);
    vec3 o = vec3(0.0);

    float e = 0.0;
    float v;
    float u;

    for (float i = 0.0; i < 100.0; i += 1.0)
    {
        vec3 p = q += vec3((FC.xy - 0.5 * r) / r.y, 1.6) * e;

        p.xz *= rotTime;

        e = 9.7;
        v = 2.6;

        float radius = 29.6;

        for (int j = 0; j < 9; j++)
        {
            p.xz *= rotStep;
            p.xz = abs(p.xz) - 0.5;

            u = dot(p, p);
            v /= u;
            p /= (u + 0.07);
            p.y = 1.71 - p.y;

            radius = min(radius, length(p.xz));
            e = min(e, max(length(p.xz) - 0.00 / u, p.y) / v);
        }

        float stemDist = q.y;
        e = min(e, stemDist);

        float stemMask = step(1.0, stemDist);
        float leafMask = smoothstep(0.43, 0.13, radius) * smoothstep(0.00, 0.31, stemDist) * (1.0 - stemMask);

        vec3 petalColor = vec3(2.8);          
        vec3 stemColor   = vec3(-0.4);         
        vec3 leafColor   = vec3(0.0, 0.15, 0.0); 

        vec3 mixedColor = mix(petalColor, stemColor, stemMask);
        mixedColor = mix(mixedColor, leafColor, leafMask);

        o += exp(-p.y / v - 5.5) * mixedColor;
    }

    fragColor = vec4(o, 1.0);
}
