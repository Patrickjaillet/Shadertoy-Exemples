// ==== Image (image) ====
float map(vec3 p) {
    const int ITERATIONS = 7;
    
    vec2 pathP = vec2(sin(p.z * 0.56) * 1.8, cos(p.z * 1.0) * 0.9);
    vec3 p_tunnel = p;
    p_tunnel.xy -= pathP;
    
    float tunnel = -(length(p_tunnel.xy) - 3.8);
    
    float aRot = p.z * 0.3;
    float sR = sin(aRot), cR = cos(aRot);
    p_tunnel.xy = mat2(cR, -sR, sR, cR) * p_tunnel.xy;
    
    vec3 q = mod(p_tunnel, 2.9) - 1.5;
    vec3 q_bulb = q * 0.75;
    
    vec3 w = q_bulb;
    float m = dot(w, w);
    float dz = 1.0;
    float pwr = 8.0;
    
    for (int j = 0; j < ITERATIONS; j++) {
        dz = pwr * pow(sqrt(m), pwr - 1.0) * dz + 1.0;
        float r_mb = length(w);
        float b_mb = pwr * acos(w.y / r_mb);
        float a_mb = pwr * atan(w.x, w.z);
        w = q_bulb + pow(r_mb, pwr) * vec3(sin(b_mb) * sin(a_mb), cos(b_mb), sin(b_mb) * cos(a_mb));
        m = dot(w, w);
        if (m > 4.0) break;
    }
    float bulb = (0.25 * log(m) * sqrt(m) / dz) / 0.75;
    
    float h1 = clamp(0.5 + 0.5 * ((length(q) - 0.5) - bulb) / 0.2, 0.0, 1.0);
    float shapes = mix(length(q) - 0.5, bulb, h1) - 0.2 * h1 * (1.0 - h1);
    
    float h2 = clamp(0.5 + 0.5 * (shapes - tunnel) / 0.5, 0.0, 1.0);
    return mix(shapes, tunnel, h2) - 0.5 * h2 * (1.0 - h2);
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    const int MAX_STEPS = 160;
    const float MAX_DIST = 50.0;
    const float SURF_DIST = 0.0050;

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t_time = iTime * 1.5;
    
    vec3 ro = vec3(sin(t_time * 0.56) * 1.8, cos(t_time * 1.0) * 0.9, t_time);
    float lookZ = t_time + 1.0;
    vec3 lookAt = vec3(sin(lookZ * 0.56) * 1.8, cos(lookZ * 1.0) * 0.9, lookZ);
    
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);
    
    float t = 0.0;
    float d = 0.0;
    float accumGlow = 0.0;
    
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        
        accumGlow += exp(-abs(d) * 3.0) * 0.0009;
        
        if (abs(d) < SURF_DIST || t > MAX_DIST) break;
        t += d * 0.7;
    }
    
    vec3 col = vec3(0.0);
    
    if (t < MAX_DIST) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        
        vec3 l = normalize(vec3(1.0, 2.0, -1.0));
        float diff = max(dot(n, l), 0.0);
        float fog = exp(-0.75 * t);
        
        vec3 material = 1.0 + 1.0 * cos(t * 0.1 + vec3(0.0, 1.3, 3.5));
        col = material * diff;
        col += pow(max(dot(reflect(-l, n), -rd), 0.0), 32.0) * 0.3;
        col = mix(vec3(0.005, 0.01, 0.03), col, fog);
    }
    
    vec3 glowColor = vec3(0.2, 0.5, 1.0);
    col += accumGlow * glowColor;
    
    fragColor = vec4(pow(col, vec3(0.3700)), 1.0);
}
