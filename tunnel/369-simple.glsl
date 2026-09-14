// ==== Image (image) ====
mat2 r2d(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise3D(vec3 p) {
    vec3 s = vec3(7, 157, 113);
    vec3 ip = floor(p);
    p -= ip; 
    vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
    p = p * p * (3. - 2. * p);
    h = mix(fract(sin(h) * 43758.5453), fract(sin(h + s.x) * 43758.5453), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    mat3 m = mat3(0.0, 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
    for (int i = 0; i < 4; i++) {
        v += a * noise3D(p);
        p = m * p * 2.02;
        a *= 0.5;
    }
    return v;
}

vec3 getPath(float z) {
    return vec3(sin(z * 0.15) * 4.5 + cos(z * 0.08) * 2.5, cos(z * 0.12) * 3.0 + sin(z * 0.05) * 1.5, z);
}

float map(vec3 p, float T, out vec4 info) {
    vec2 par = vec2(0.001, 1.618);
    vec3 path = getPath(p.z);
    p.xy -= path.xy;
    p.xy *= r2d(p.z * 0.05 + T * 0.1);
    float d = 1e10, flow = 0.0;
    vec3 p_grid = mod(p + 6.0, 12.0) - 6.0;
    float h = hash12(floor((p + 6.0) / 12.0).xz);
    for(int i = 0; i < 4; i++) {
        float fi = float(i);
        vec3 sp = p_grid;
        float shift = fi * par.y + T * (0.2 + h * 0.5);
        sp.xy *= r2d(p.z * (0.05 + fi * 0.02) + shift);
        sp.xy += vec2(cos(shift), sin(shift)) * (2.5 + 1.5 * sin(p.z * 0.3 + shift));
        float geom = length(sp.xy) - (0.015 + 0.01 * sin(p.z * 8.0 + T * 12.0));
        flow += exp(-6.0 * geom) * (0.5 + step(0.98, sin(p.z * 0.5 - T * 8.0 + h * 3.14)) * 2.0);
        d = min(d, geom);
    }
    float tunnel = -(length(p.xy) - (7.0 + fbm(p * 0.3 + vec3(0, 0, T)) * 2.5));
    d = min(d, tunnel * 0.8);
    info = vec4(h, flow, tunnel, p.z);
    return d;
}

vec3 render(vec2 uv, float T) {
    vec4 cp = vec4(160.0, 0.001, 100.0, 1.2);
    vec3 ro = getPath(T * 8.0), ta = getPath(T * 8.0 + 1.0);
    vec3 fwd = normalize(ta - ro), rgt = normalize(cross(vec3(0, 1, 0), fwd)), up = cross(fwd, rgt);
    vec3 rd = normalize(uv.x * rgt + uv.y * up + fwd * (cp.w + sin(T * 0.4) * 0.2));
    rd.xy *= r2d(sin(T * 0.3) * 0.15);
    rd.xz *= r2d(cos(T * 0.2) * 0.1);
    float t = 0.0;
    vec3 col = vec3(0.0);
    vec4 info;
    for(int i = 0; i < int(cp.x); i++) {
        vec3 p = ro + rd * t;
        float d = map(p, T, info);
        if(d < cp.y || t > cp.z) break;
        vec3 hue = 0.5 + 0.5 * cos(vec3(0, 2, 4) + info.x * 6.28 + info.w * 0.05 + T);
        float att = exp(-0.04 * t);
        col += hue * info.y * 0.012 * att;
        col += vec3(0.05, 0.15, 0.4) * exp(-1.5 * abs(info.z)) * 0.008 * att;
        col += hue * pow(fbm(p * 0.15 + T * 0.5), 3.0) * 0.0015 * att;
        t += d * (0.4 + 0.1 * hash12(uv + T));
    }
    col = mix(col, vec3(0.002, 0.005, 0.01), 1.0 - exp(-0.01 * t));
    col = pow(col * 1.5 / (1.0 + col * 1.5), vec3(0.4545)) * smoothstep(1.5, 0.3, length(uv));
    return col;
}

void mainImage(out vec4 O, vec2 C) {
    vec2 uv = (C - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = render(uv, iTime);
    vec2 off = vec2(0.003 * (1.0 + sin(iTime)), 0.0);
    col.r = render(uv + off, iTime).r;
    col.b = render(uv - off, iTime).b;
    O = vec4(col + hash12(uv + iTime) * 0.03, 1.0);
}
