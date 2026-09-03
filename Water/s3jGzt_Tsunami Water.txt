// ==== Image (image) ====
vec2 hash2(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.7300, 0.790, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}
//https://github.com/Patrickjaillet/Z-GL
vec3 noised(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    vec2 du = 6.0 * f * (1.0 - f);
    
    vec2 ga = hash2(i + vec2(0.0, 0.0));
    vec2 gb = hash2(i + vec2(1.0, 0.0));
    vec2 gc = hash2(i + vec2(0.0, 1.0));
    vec2 gd = hash2(i + vec2(1.0, 1.0));
    
    ga = -1.0 + 2.0 * ga;
    gb = -1.0 + 2.0 * gb;
    gc = -1.0 + 2.0 * gc;
    gd = -1.0 + 2.0 * gd;
    
    float va = dot(ga, f - vec2(0.0, 0.0));
    float vb = dot(gb, f - vec2(1.0, 0.0));
    float vc = dot(gc, f - vec2(0.0, 1.0));
    float vd = dot(gd, f - vec2(1.0, 1.0));
    
    return vec3(va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd),
                du * (vec2(vb - va, vc - va) + u.yx * (va - vb - vc + vd)) + (gb - ga) * u.x + (gc - ga) * u.y + (ga - gb - gc + gd) * u.x * u.y);
}

float waterHeight(vec2 p, float time) {
    float height = 0.0;
    
    vec2 d1 = vec2(cos(3.2), sin(2.0));
    float w1 = dot(p, d1) * 0.7 - time * 3.2;
    height += sin(w1) * 0.85;
    
    vec2 d2 = vec2(cos(2.1), sin(2.1));
    float w2 = dot(p, d2) * 0.75 - time * 2.4;
    height += sin(w2) * 0.58;
    
    float amplitude = 0.25;
    float frequency = 1.2;
    vec2 shift = vec2(0.0);
    
    for (int i = 0; i < 5; i++) {
        vec3 n = noised(p * frequency + time * 0.8 + shift);
        shift += n.yz * 0.35;
        height += (1.0 - abs(n.x)) * amplitude;
        p = mat2(0.8, 0.6, -0.6, 0.8) * p * 1.9;
        amplitude *= 0.35;
        frequency *= 1.7;
    }
    return height;
}

float cloudNoise(in vec2 p) {
    p += vec2(iTime * 0.05, iTime * 0.02);
    float f = 0.0;
    float a = 0.5;
    for(int i = 0; i < 4; i++) {
        f += a * noised(p).x;
        p = mat2(0.8, 0.6, -0.6, 0.8) * p * 2.02;
        a *= 0.5;
    }
    return clamp(f * 0.5 + 0.5, 0.0, 1.0);
}

vec3 getSkyColor(in vec3 rd, in vec3 l_dir) {
    vec3 bg = vec3(0.2, 0.45, 0.75) - rd.y * 0.4;
    bg += vec3(1.0, 0.7, 0.4) * pow(max(dot(rd, l_dir), 0.0), 24.0) * 0.6;
    
    if(rd.y > 0.0) {
        vec2 cloudUV = rd.xz / (rd.y + 0.01);
        float density = cloudNoise(cloudUV * 0.15);
        
        float c = smoothstep(0.4, 0.75, density);
        vec3 cloudColor = mix(vec3(0.9, 0.95, 1.0), vec3(0.4, 0.45, 0.5), smoothstep(0.4, 0.8, density));
        cloudColor += vec3(1.0, 0.7, 0.4) * pow(max(dot(rd, l_dir), 0.0), 8.0) * c * 0.5;
        
        bg = mix(bg, cloudColor, c * smoothstep(0.0, 0.15, rd.y));
    }
    return bg;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float camTime = iTime * 0.15;
    float radius = 9.0 + sin(iTime * 0.23) * 2.5;
    vec3 ro = vec3(cos(camTime) * radius, 1.8 + sin(iTime * 0.4) * 0.6, sin(camTime) * radius);
    vec3 ta = vec3(sin(camTime * 0.5) * 2.0, -0.4 + cos(iTime * 0.11) * 0.3, cos(camTime * 0.7) * 2.0);
    
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(iTime * 0.1) * 0.05, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.4 * cw);
    
    vec3 l_dir = normalize(vec3(1.0, 0.25, -0.8));
    vec3 bg = getSkyColor(rd, l_dir);
    
    if (rd.y >= 0.1) {
        fragColor = vec4(pow(clamp(bg * 1.2, 0.5, 1.0), vec3(0.7 / 2.2)), 1.0);
        return;
    }
    
    float t = -ro.y / rd.y;
    vec3 p = ro + rd * t;
    
    if (t > 60.0 || length(p.xz) > 35.0 || t < 0.0) {
        fragColor = vec4(pow(clamp(bg * 1.2, 0.0, 1.0), vec3(1.0 / 2.2)), 1.0);
        return;
    }
    
    float h = waterHeight(p.xz, iTime);
    p += rd * (h / (rd.y - 0.1));
    
    for(int i = 0; i < 5; i++) {
        h = waterHeight(p.xz, iTime);
        p.xz += rd.xz * (p.y - h) * 0.45;
        p.y = ro.y + rd.y * length(p - ro);
    }
    
    vec2 eps = vec2(0.005, 0.0);
    float hL = waterHeight(p.xz - eps.xy, iTime);
    float hR = waterHeight(p.xz + eps.xy, iTime);
    float hD = waterHeight(p.xz - eps.yx, iTime);
    float hU = waterHeight(p.xz + eps.yx, iTime);
    
    vec3 n = normalize(vec3(hL - hR, eps.x * 2.0, hD - hU));
    
    vec3 ref = reflect(rd, n);
    float fresnel = 0.02 + 0.98 * pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
    float spec = pow(max(dot(ref, l_dir), 0.0), 200.0) * 4.5;
    float diff = max(dot(n, l_dir), 0.0);
    
    vec3 water_deep = vec3(0.002, 0.03, 0.08);
    vec3 water_shallow = vec3(0.02, 0.38, 0.48);
    vec3 scatter_col = vec3(0.05, 0.55, 0.45);
    
    vec3 water_col = mix(water_deep, water_shallow, clamp(h * 0.4 + 0.6, 0.0, 1.0));
    water_col += scatter_col * diff * 0.5;
    
    vec3 sky_col = getSkyColor(ref, l_dir);
    
    vec3 color = mix(water_col, sky_col, fresnel) + vec3(1.0, 0.96, 0.85) * spec;
    color = mix(color, bg, smoothstep(20.0, 35.0, length(p.xz)));
    
    color = color * 1.35;
    color = clamp((color * (2.51 * color + 0.00)) / (color * (2.43 * color + 0.59) + 0.88), 0.0, 1.0);
    
    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}
