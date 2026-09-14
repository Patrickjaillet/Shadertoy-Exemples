// ==== Image (image) ====
mat2 rot(float a){ float c=cos(a), s=sin(a); return mat2(c,-s,s,c); }

vec3 palette(float t){
    vec3 a = vec3(0.52, 0.35, 0.64);
    vec3 b = vec3(0.42, 0.42, 0.48);
    vec3 c = vec3(1.0, 0.9, 0.65);
    vec3 d = vec3(0.15, 0.34, 0.58);
    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.5;

    float mrot  = (iMouse.x / iResolution.x - 0.5) * 2.6;
    float mtilt = (iMouse.y / iResolution.y - 0.5) * 1.1;

    vec3 rd = normalize(vec3(uv, 1.15));
    rd.yz *= rot(mtilt * 0.3);

    vec3 q = vec3(0.0);
    vec3 p;
    float y = 0.0, R = 0.0, a = 0.0;
    vec3 col = vec3(0.0);

    const float STEPS = 90.0;
    for (float i = 0.0; i < STEPS; i++){
        q += rd * max(-y, R) * 0.28;
        p = q;
        p.y -= 1.0;
        p.yx *= rot(cos(t) * 0.7 + mrot);
        y = p.y;

        float e = atan(p.x, p.z) + t;
        R = max(length(p), 1e-4);
        a = y / R;

        p = vec3(log(R) - t / 3.14159 * 2.4 + e / 3.14159, a * sin(5.0 * e), a) + 0.5;

        for (int j = 0; j < 7; j++){
            p -= floor(p + 0.5);
            a = dot(p, p) + 0.26;
            R *= a;
            p /= a;
        }

        float hue = fract(log(R + 1.0) * 0.35 - t * 0.12 + i * 0.0025);
        vec3 c = palette(hue);
        float falloff = 1.0 / (1.0 + R * R * 1.0);
        col += c * falloff * 0.05;
    }

    col = col / (1.0 + col * 0.6);
    col = pow(max(col, 0.0), vec3(0.82));

    float vig = 1.0 - dot(uv, uv) * 0.55;
    col *= vig;

    float grain = fract(sin(dot(fragCoord, vec2(12.9898, 78.233)) + iTime) * 43758.5453);
    col += (grain - 0.5) * 0.015;

    fragColor = vec4(col, 1.0);
}
