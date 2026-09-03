// ==== Image (image) ====
vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    vec2 uv = fragCoord.xy / r;
    
    float split = 4.0;
    vec2 grid = floor(uv * split);
    vec2 f_uv = fract(uv * split);
    
    float view_id = grid.x + grid.y * split;
    float t = iTime * 0.5;
    
    float i = 0.0, e = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.0), p = vec3(0.0);
    vec4 o = vec4(0.0);
    
    vec2 p_uv = (f_uv - 0.5) * 2.0;
    p_uv.x *= (r.x / r.y);
    
    float angle = view_id * 0.785398 + t;
    float cosA = cos(angle);
    float sinA = sin(angle);
    mat2 rot = mat2(cosA, -sinA, sinA, cosA);
    
    vec3 d = vec3(p_uv, 1.4);
    d.xz *= rot;
    d.yz *= rot;
    
    q.xz -= 1.0;
    q.z += sin(t + view_id) * 0.5;
    q.xy *= rot;

    float hue = fract(view_id * 0.159);

    for (int j = 0; j < 111; j++) {
        if (i > 104.0) {
            d = -sign(d);
        }
        e += i / 2e2;
        o.rgb += e * e * hsv(hue, 0.8, min(e * i, 1.4));
        s = 2.3;
        p = q += d * e * R * 0.2;
        R = length(p);
        p = vec3(log2(R) - 2.0, -p.z / R, atan(p.x, p.y));
        p.y -= 1.0;
        e = p.y;
        
        for (int k = 0; k < 9; k++) {
            if (s >= 1e3) break;
            e += cos(dot(cos(p.zyx * s), cos(p.xzy * s))) / s;
            s += s;
        }
        i++;
    }
    
    vec2 vig_uv = f_uv * (1.0 - f_uv.yx);
    float vig = vig_uv.x * vig_uv.y * 15.0;
    vig = pow(vig, 0.40);
    o.rgb *= vig;
    
    vec2 border = smoothstep(0.47, 0.5, abs(f_uv - 0.5));
    o.rgb *= (1.0 - max(border.x, border.y));
    
    fragColor = o;
}
