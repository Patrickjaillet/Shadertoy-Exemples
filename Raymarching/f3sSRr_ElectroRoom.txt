// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 FC) {
    vec3 r = iResolution;
    float t = iTime;
    vec2 uv = (FC - r.xy * 0.5) / r.y;
    
    vec3 ro = vec3(t * 0.4, 0.2 * sin(t * 0.3), t * 0.8);
    vec3 target = ro + vec3(sin(t * 0.15) * 0.3, cos(t * 0.1) * 0.2, 1.0);
    vec3 cz = normalize(target - ro);
    vec3 cx = normalize(cross(vec3(sin(t * 0.1), 1.0, 0.0), cz));
    vec3 cy = cross(cz, cx);
    vec3 rd = normalize(uv.x * cx + uv.y * cy + 0.8 * cz);
    
    float c = cos(t * 0.1), s = sin(t * 0.1);
    mat3 rz = mat3(c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);
    mat3 rx = mat3(1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c);
    mat3 rotfbm = rz * rx;

    float d = 0.0, t_dist = 0.01, max_d = 20.0;
    float glow = 0.0, d_inf = 1.0;
    vec3 p;
    
    for (int i = 0; i < 140; i++) {
        if (t_dist > max_d) break;
        p = ro + rd * t_dist;
        
        vec3 p_inf = vec3(fract(p.x) - 0.5, p.y, fract(p.z) - 0.5);
        d_inf = min(length(p_inf.xz) - 0.06, 0.35 - abs(p_inf.y));
        
        float m = 1.0, noise = 0.0;
        vec3 q = p * 1.2;
        for (int j = 0; j < 7; j++) {
            q = rotfbm * q;
            noise += dot(sin(q * m + vec3(t * 1.5, t, t * 0.8)), vec3(0.333)) / m;
            m *= 1.85;
        }
        
        d_inf -= abs(noise) * 0.14 * (1.0 - smoothstep(0.2, 0.5, abs(p.y)));
        glow += exp(-max(d_inf, 0.0) * 12.0) * (0.015 + 0.01 * sin(t + p.z));
        
        if (d_inf < 0.0008) {
            d = t_dist;
            break;
        }
        t_dist += d_inf * 0.45;
    }

    vec3 col = vec3(0.002, 0.005, 0.012) * (1.0 - length(uv) * 0.5);
    col += vec3(0.1, 0.4, 0.8) * glow;

    if (d > 0.0) {
        vec2 eps = vec2(0.001, 0.0);
        vec3 n = normalize(vec3(
            (min(length(fract((p + eps.xyy).xz) - 0.5) - 0.06, 0.35 - abs((p + eps.xyy).y))) - d_inf,
            (min(length(fract((p + eps.yxy).xz) - 0.5) - 0.06, 0.35 - abs((p + eps.yxy).y))) - d_inf,
            (min(length(fract((p + eps.yyx).xz) - 0.5) - 0.06, 0.35 - abs((p + eps.yyx).y))) - d_inf
        ));
        
        float occ = 0.0, sca = 1.0;
        for (int step = 1; step <= 5; step++) {
            float hr = 0.01 + 0.12 * float(step) / 5.0;
            vec3 aopos = p + n * hr;
            float ao_d = min(length(fract(aopos.xz) - 0.5) - 0.06, 0.35 - abs(aopos.y));
            occ += (hr - ao_d) * sca;
            sca *= 0.85;
        }
        float ao = clamp(1.0 - occ * 4.0, 0.0, 1.0);
        
        vec3 l_dir = normalize(vec3(sin(t), 1.5, cos(t)));
        float dif = clamp(dot(n, l_dir), 0.0, 1.0);
        float spe = pow(clamp(dot(reflect(rd, n), l_dir), 0.0, 1.0), 32.0);
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 4.0);
        
        vec3 mat = mix(vec3(0.05, 0.1, 0.18), vec3(0.7, 0.85, 1.0), smoothstep(-0.1, 0.1, sin(p.z * 4.0) * cos(p.x * 4.0)));
        mat += vec3(0.5, 0.1, 0.9) * (1.0 - smoothstep(0.0, 0.04, abs(p.y - 0.34)));
        
        col = mat * (dif * vec3(1.0, 0.9, 0.8) + 0.15) + spe * 0.4 + fre * vec3(0.3, 0.6, 1.0) * 0.5;
        col *= ao;
        col = mix(col, vec3(0.005, 0.01, 0.02), smoothstep(4.0, max_d, d));
    }

    col += vec3(0.9, 0.4, 0.2) * pow(max(0.0, dot(rd, normalize(vec3(0.5, 0.2, 1.0)))), 8.0) * 0.3;
    col = pow(col, vec3(0.4545));
    col = clamp(col * 1.1 - 0.05, 0.0, 1.0);
    
    o = vec4(col, 1.0);
}
