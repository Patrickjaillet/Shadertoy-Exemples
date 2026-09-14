
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float gyroid(vec3 p) {
    return dot(sin(p), cos(p.yzx));
}

float map(vec3 p) {
    float d = 100.0;

    p.z += iTime * 0.5; 

    p.xy *= rot(p.z * 0.1);

    float g = gyroid(p * 2.0) * 0.5;
    g += gyroid(p * 4.0) * 0.25;
    g += gyroid(p * 8.0) * 0.125;

    float thickness = 0.05 + 0.02 * sin(iTime * 0.5);

    d = abs(g) - thickness;

    d = max(d, 0.5 - length(p.xy));
    d = max(d, length(p.xy) - 2.0);

    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.z <= 0.0) m = vec2(0.0); 

    vec3 ro = vec3(0.0, 0.0, -2.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    ro.yz *= rot(m.y * 1.5);
    rd.yz *= rot(m.y * 1.5);
    ro.xz *= rot(-m.x * 1.5);
    rd.xz *= rot(-m.x * 1.5);

    float t = 0.0;
    vec3 p = ro;
    float d = 0.0;
    vec3 glow = vec3(0.0);

    for(int i = 0; i < 64; i++) {
        p = ro + rd * t;
        d = map(p);

        float dist_factor = 1.0 / (1.0 + d * d * 100.0);

        vec3 pal = 0.5 + 0.5 * cos(iTime * 0.2 + p.z * 0.1 + vec3(0.0, 0.33, 0.67));

        glow += pal * dist_factor * 0.05;

        t += max(d * 0.5, 0.01);
        if(t > 20.0) break;
    }

    vec3 color = glow;

    color *= 1.0 - length(uv) * 0.5;

    color = color / (1.0 + color);

    fragColor = vec4(color, 1.0);
}
