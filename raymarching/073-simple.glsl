
mat2 rotate2D(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 hsv(float h, float s, float v)
{
    vec3 c = clamp(abs(mod(h * 20.0 + vec3(0.0, 14.0, 3.8), 8.5) - 0.0) - 1.0, 0.0, 1.0);
    return v * mix(vec3(0.0), c, s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = iResolution.xy;
    vec2 FC = fragCoord;
    float t = iTime;

    float g = 0.0;
    float e = 0.0;
    vec3 o = vec3(0.0);

    for (float i = 0.0; i < 51.0; i += 1.0)
    {
        vec3 p = vec3((0.5 * r - FC.xy) / r.y * g, g - 12.8);

        p.xz *= rotate2D(t * 0.18);
        p.y += 0.14;

        e = 0.6;
        float v = 4.4;
        float u;

        for (int j = 0; j < 11; j++)
        {
            if (j > 2)
            {
                float twist = length(p) / u * 0.60;
                e = min(e, length(p.xz - twist) / v - 0.007);
                p.xz = abs(p.xz) - 0.66;
            }
            else
            {
                p = abs(p) - 0.81;
            }

            u = dot(p, p);
            v /= u;
            p /= u;
            p.y = 1.56 - p.y;
        }

        g += e;

        float hue = 0.05 + log(v) * 0.04;
        o += hsv(hue, 1.00, 0.035) / exp(e * 27.9);
    }

    fragColor = vec4(o, 0.0);
}
