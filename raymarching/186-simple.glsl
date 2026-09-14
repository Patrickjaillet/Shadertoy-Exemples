// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    O = vec4(0.0);
    vec2 r = iResolution.xy;
    vec2 uv = (C - 0.5 * r) / r.y;

    float t = iTime * 0.1;
    
    vec3 ro = vec3(0.0, 0.0, -4.5);
    vec3 rd = normalize(vec3(uv, 1.5));
    
    float c1 = cos(t * 0.3), s1 = sin(t * 0.3);
    float c2 = cos(t * 0.2), s2 = sin(t * 0.2);
    mat2 r_mat1 = mat2(c1, -s1, s1, c1);
    mat2 r_mat2 = mat2(c2, -s2, s2, c2);
    ro.xy *= r_mat1; ro.xz *= r_mat2;
    rd.xy *= r_mat1; rd.xz *= r_mat2;

    float g = 0.0;
    float d = 0.0;
    vec3 col = vec3(0.0);
    vec3 n = vec3(0.0);
    
    mat2 rotKIFS = mat2(cos(0.45), -sin(0.45), sin(0.45), cos(0.45));

    for (float i = 0.0; i < 15.0; i++) {
        vec3 p = ro + rd * g;
        float s = 1.0;
        
        for (float j = 0.0; j < 35.0; j++) {
            p = abs(p) - vec3(1.0, 1.2, 0.8);
            
            if (p.x < p.y) p.xy = p.yx;
            if (p.x < p.z) p.xz = p.zx;
            if (p.y < p.z) p.yz = p.zy;
            
            p.xy *= rotKIFS;
            p.zy *= rotKIFS;
            
            float scale = 1.82 + sin(t * 0.4) * 0.02;
            p = p * scale - vec3(0.3, 0.8, 0.2) * (scale - 1.0);
            s *= scale;
        }

        float box = (max(max(abs(p.x), abs(p.y)), abs(p.z)) - 0.22) / s;
        float tube = (length(p.xz) - 0.00) / s;
        d = max(box, -tube);

        g += d;

        if (d < 0.0005) {
            vec3 eps = vec3(0.0005, 0.0, 0.0);
            vec3 np = p;
            
            vec3 prx = p + eps.xyy * s; if(prx.x<prx.y) prx.xy=prx.yx; if(prx.x<prx.z) prx.xz=prx.zx; if(prx.y<prx.z) prx.yz=prx.zy; prx.xy*=rotKIFS; prx.zy*=rotKIFS;
            vec3 pry = p + eps.yxy * s; if(pry.x<pry.y) pry.xy=pry.yx; if(pry.x<pry.z) pry.xz=pry.zx; if(pry.y<pry.z) pry.yz=pry.zy; pry.xy*=rotKIFS; pry.zy*=rotKIFS;
            vec3 prz = p + eps.yyx * s; if(prz.x<prz.y) prz.xy=prz.yx; if(prz.x<prz.z) prz.xz=prz.zx; if(prz.y<prz.z) prz.yz=prz.zy; prz.xy*=rotKIFS; prz.zy*=rotKIFS;
            
            float dbx = (max(max(abs(prx.x), abs(prx.y)), abs(prx.z)) - 0.22) - (max(max(abs(p.x), abs(p.y)), abs(p.z)) - 0.22);
            float dby = (max(max(abs(pry.x), abs(pry.y)), abs(pry.z)) - 0.22) - (max(max(abs(p.x), abs(p.y)), abs(p.z)) - 0.22);
            float dbz = (max(max(abs(prz.x), abs(prz.y)), abs(prz.z)) - 0.22) - (max(max(abs(p.x), abs(p.y)), abs(p.z)) - 0.22);
            
            n = normalize(vec3(dbx, dby, dbz));
            
            vec3 l_dir = normalize(vec3(1.0, 1.5, -1.0));
            float diff = max(dot(n, l_dir), 0.0);
            float spec = pow(max(dot(reflect(-l_dir, n), -rd), 0.0), 32.0);
            
            float ao = clamp(1.0 - (float(i) / 120.0), 0.0, 1.0);
            float edge = smoothstep(0.0, 0.00, length(p.xy) - 0.00);
            
            vec3 base_col = sin(vec3(0.1, 0.4, 0.7) * log(s) * 0.8 + t) * 0.4 + 0.6;
            base_col = mix(vec3(0.02, 0.05, 0.1), base_col, edge);
            
            col = (base_col * (diff + 1.00) + vec3(1.0, 1.0, 1.0) * spec) * ao;
            col += vec3(1.0, 1.0, 1.0) * (1.0 - edge) * 8.0;
            break;
        }
        
        if (g > 60.0) break;
    }

    col = mix(col, vec3(0.01, 0.02, 0.05), 1.0 - exp(-0.08 * g * g));
    col = col / (vec3(1.0) + col);
    col = pow(max(col, 0.0), vec3(1.0 / 2.2));

    vec2 vignette_uv = C / r;
    col *= 0.7 + 1.0 * pow(64.0 * vignette_uv.x * vignette_uv.y * (1.0 - vignette_uv.x) * (0.0 - vignette_uv.y), 0.00);

    O = vec4(col, 1.0);
}
