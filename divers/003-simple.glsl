// ==== Image (image) ====
vec4 q_from_axis_angle(vec3 axis, float angle) {
    float s = sin(angle * 0.5);
    return vec4(axis * s, cos(angle * 0.5));
}

vec3 rotate_vector(vec3 v, vec4 q) {
    return v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v);
}

vec3 bendX(vec3 p, float k) {
    float c = cos(k * p.x);
    float s = sin(k * p.x);
    mat2 m = mat2(c, -s, s, c);
    return vec3(m * vec2(p.x, p.y), p.z);
}

float damped_osc(float t, float A, float zeta, float omega) {
    return A * exp(-zeta * t) * cos(omega * t);
}

vec4 hex_grid(vec2 p) {
    vec2 s = vec2(1.0, 1.7320508);
    vec2 h = s * 0.5;
    vec2 a = mod(p, s) - h;
    vec2 b = mod(p - h, s) - h;
    vec2 g = dot(a, a) < dot(b, b) ? a : b;
    vec2 id = p - g;
    float d = max(abs(g.x) * 0.866025 + g.y * 0.5, -g.y); 
    return vec4(id, g.x, 0.5 - d);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x + p.y + p.z - s;
    vec3 q;
    if(3.0 * p.x < m) q = p.xyz;
    else if(3.0 * p.y < m) q = p.yzx;
    else if(3.0 * p.z < m) q = p.zxy;
    else return m * 0.57735027;
    float k = clamp(0.5 * (q.z - q.y + s), 0.0, s); 
    return length(vec3(q.x, q.y - s + k, q.z - k)); 
}

mat3 setCamera(vec3 ro, vec3 ta, float cr) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    return mat3(cu, cv, cw);
}

float map(vec3 p) {
    float t_loop = mod(iTime, 4.0);
    float osc = damped_osc(t_loop, 1.2, 0.3, 12.0);
    
    vec4 q = q_from_axis_angle(normalize(vec3(1.0, 0.8, 0.5)), iTime * 0.4);
    vec3 p_obj = rotate_vector(p, q);
    p_obj = bendX(p_obj, osc * 0.4);
    
    float box = sdBox(p_obj, vec3(0.8)) - 0.15;
    float oct = sdOctahedron(p_obj, 1.4);
    float shape = mix(box, oct, sin(iTime) * 0.5 + 0.5);
    
    float interior = abs(shape) - 0.02;
    
    float noise = sin(p_obj.x * 20.0 + iTime * 4.0) * sin(p_obj.y * 20.0) * sin(p_obj.z * 20.0);
    float d_obj = max(interior, noise * 0.08);

    vec3 p_floor = p;
    p_floor.y += 2.8;
    vec4 h = hex_grid(p_floor.xz * 1.8 + sin(p_floor.zx * 0.5 + iTime));
    float d_hex = (h.w - 0.05) / 1.8;
    float d_floor = p_floor.y + d_hex * 0.15;
    
    return min(d_obj, d_floor);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0005, -0.0005);
    return normalize(e.xyy * map(p + e.xyy) + e.yyx * map(p + e.yyx) + e.yxy * map(p + e.yxy) + e.xxx * map(p + e.xxx));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float getShadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    float t = 0.01;
    for(int i = 0; i < 48; i++) {
        float h = map(ro + rd * t);
        res = min(res, 16.0 * h / t);
        t += clamp(h, 0.01, 0.2);
        if(res < 0.001 || t > 10.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 render(vec3 ro, vec3 rd) {
    float t = 0.0, d = 0.0;
    for(int i = 0; i < 256; i++) {
        d = map(ro + rd * t);
        if(abs(d) < 0.0001 || t > 30.0) break;
        t += d;
    }
    
    vec3 col = texture(iChannel0, rd).rgb * 0.2;
    
    if(t < 30.0) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 ref = reflect(rd, n);
        
        vec3 lig = normalize(vec3(0.8, 0.7, -0.6));
        vec3 lig2 = normalize(vec3(-0.8, 0.3, 0.5));
        vec3 hal = normalize(lig - rd);
        
        float occ = getAO(p, n);
        float sha = getShadow(p, lig);
        float amb = clamp(0.5 + 0.5 * n.y, 0.0, 1.0);
        float dif = clamp(dot(n, lig), 0.0, 1.0) * sha;
        float dif2 = clamp(dot(n, lig2), 0.0, 1.0) * 0.3;
        float bac = clamp(dot(n, normalize(vec3(-lig.x, 0.0, -lig.z))), 0.0, 1.0) * occ;
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 3.0);
        float spe = pow(clamp(dot(n, hal), 0.0, 1.0), 64.0) * dif * (0.04 + 0.96 * pow(clamp(1.0 + dot(hal, rd), 0.0, 1.0), 5.0));
        
        vec3 env = textureLod(iChannel0, ref, 2.0).rgb;
        
        vec3 mate = vec3(0.2);
        if(p.y < -2.5) {
            vec4 h = hex_grid(p.xz * 1.8 + sin(p.zx * 0.5 + iTime));
            
            mate = texture(iChannel1, reflect(rd, n)).rgb;
            mate *= smoothstep(0.0, 0.02, h.w);
            mate += 0.1 * smoothstep(0.48, 0.5, h.w);
            
            vec3 ro_refl = p + n * 0.01;
            vec3 rd_refl = reflect(rd, n);
            float t_refl = 0.0, d_refl = 0.0;
            for(int j = 0; j < 64; j++) {
                d_refl = map(ro_refl + rd_refl * t_refl);
                if(abs(d_refl) < 0.001 || t_refl > 10.0) break;
                t_refl += d_refl;
            }
            if(t_refl < 10.0) {
                vec3 p_refl = ro_refl + rd_refl * t_refl;
                if(p_refl.y > -2.5) {
                    vec3 n_refl = getNormal(p_refl);
                    vec3 refl_mate = mix(vec3(0.02, 0.3, 0.8), vec3(0.8, 0.05, 0.3), sin(p_refl.y * 3.0 + iTime * 2.0) * 0.5 + 0.5);
                    float refl_dif = clamp(dot(n_refl, lig), 0.0, 1.0);
                    mate += refl_mate * refl_dif * 0.25;
                }
            }
        } else {
            vec3 c1 = vec3(0.02, 0.3, 0.8);
            vec3 c2 = vec3(0.8, 0.05, 0.3);
            mate = mix(c1, c2, sin(p.y * 3.0 + iTime * 2.0) * 0.5 + 0.5);
            mate = mix(mate, env, 0.4);
            mate = mix(mate, vec3(0.9, 0.8, 0.4), pow(fre, 4.0));
        }
        
        col = mate * (dif * vec3(1.1, 1.0, 0.9) + dif2 * vec3(0.5, 0.6, 1.0));
        col += amb * 0.15 * mate * vec3(0.4, 0.5, 0.7);
        col += bac * 0.1 * mate;
        col += 3.5 * spe * vec3(1.0, 0.9, 0.7) + env * spe;
        col += 0.4 * fre * mate * occ;
        col *= occ;
        
        float refr = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 2.0);
        col += 0.15 * refr * env * occ;
    }
    
    col = mix(col, texture(iChannel0, rd).rgb * 0.1, 1.0 - exp(-0.002 * t * t));
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(6.0 * sin(iTime * 0.2), 3.0 + 1.5 * sin(iTime * 0.5), 6.0 * cos(iTime * 0.2));
    vec3 ta = vec3(0.0, -0.5, 0.0);
    mat3 ca = setCamera(ro, ta, 0.1 * sin(iTime * 0.3));
    vec3 rd = ca * normalize(vec3(uv, 2.0));
    
    vec3 col = render(ro, rd);
    
    col = pow(col, vec3(0.4545));
    
    vec2 q = fragCoord / iResolution.xy;
    col *= 0.4 + 0.6 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.2);
    col = clamp(col, 0.0, 1.0);
    
    fragColor = vec4(col, 1.0);
}
