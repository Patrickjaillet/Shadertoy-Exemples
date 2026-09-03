// ==== Image (image) ====
void mainImage(out vec4 O, in vec2 U) {
    vec2 R = iResolution.xy;
    vec2 u = (U - 0.5 * R) / R.y;
    
    vec3 lz = vec3(0.1);
    for(int i = 0; i < 30; i++) {
        lz += vec3(10.0 * (lz.y - lz.x), lz.x * (28.0 - lz.z) - lz.y, lz.x * lz.y - 2.66 * lz.z) * 0.015;
    }
    lz *= 0.04;
    
    float tm = mod(iTime, 4.0);
    vec3 kPos = vec3(-1.0, -1.0, 0.0) + vec3(1.5, 2.0, 0.0) * tm + 0.5 * vec3(0.0, -1.0, 0.0) * tm * tm;
    
    float r_bg = length(u);
    float a_bg = atan(u.y, u.x);
    float morph = smoothstep(0.2, 0.8, sin(iTime * 0.25) * 0.5 + 0.5);
    vec2 lp = vec2(log(r_bg + 0.0001) * 1.5 - iTime * 0.5, a_bg * (1.0 + morph));
    vec2 pBG = mix(u * 2.5, lp, morph);
    
    vec3 bgCol = vec3(0.0);
    for(int i = 0; i < 6; i++) {
        float fi = float(i);
        float tm_bg = mod(iTime * 0.5 + fi, 4.0);
        vec2 kPosBG = vec2(-1.0) + vec2(1.5, 2.0) * tm_bg + 0.5 * vec2(0.0, -1.0) * tm_bg * tm_bg;
        
        vec2 gF = normalize(pBG) * (0.05 / (dot(pBG, pBG) + 0.01));
        pBG += gF * 0.5;
        pBG += (vec2(0.0, 0.1) + vec2(-pBG.y, pBG.x)) * 0.04 * sin(iTime + fi);
        
        vec3 nBG = normalize(vec3(pBG, 1.0 - length(pBG) * 0.3));
        pBG += refract(normalize(vec3(pBG, -1.0)), nBG, 1.0 / 1.33).xy * 0.15;
        
        pBG += sin(length(pBG) * 12.0 - iTime * 5.0) * exp(-length(pBG) * 1.5) * 0.12;
        
        float heat = exp(-dot(pBG - kPosBG, pBG - kPosBG) * 2.5) + exp(-dot(pBG - (lz.xy * 1.25), pBG - (lz.xy * 1.25)) * 3.5);
        float isq = 0.012 / (dot(pBG, pBG) + 0.003);
        float fresBG = 0.04 + 0.96 * pow(max(0.0, 1.0 - dot(nBG, vec3(0.0, 0.0, 1.0))), 5.0);
        
        float c_ray = dot(normalize(pBG), vec2(0.0, 1.0));
        vec3 rayl = (1.0 + c_ray * c_ray) * vec3(0.178, 0.068, 0.050) * 6.0;
        
        pBG = abs(pBG) - 0.35 - morph * 0.15;
        float sBG = sin(iTime * 0.15 + fi), cBG = cos(iTime * 0.15 + fi);
        pBG *= mat2(cBG, -sBG, sBG, cBG);
        
        bgCol += (rayl * isq * (0.3 + heat) + fresBG * vec3(0.3, 0.7, 1.0)) * (0.5 + 0.5 * sin(fi * 1.1 + vec3(0.0, 2.0, 4.0)));
    }
    bgCol *= 0.15;
    
    vec3 ro = vec3(0.0, 0.0, 3.5);
    vec3 rd = normalize(vec3(u, -1.0));
    
    float s1 = sin(sin(iTime * 0.2) * 0.5), c1 = cos(sin(iTime * 0.2) * 0.5);
    mat2 rotYZ = mat2(c1, -s1, s1, c1);
    float s2 = sin(iTime * 0.15), c2 = cos(iTime * 0.15);
    mat2 rotXZ = mat2(c2, -s2, s2, c2);
    
    ro.yz *= rotYZ; rd.yz *= rotYZ;
    ro.xz *= rotXZ; rd.xz *= rotXZ;
    
    vec3 lPos2 = kPos + (vec3(1.0, 1.0, 0.0) + vec3(0.0, -0.9, 0.0) * iTime) * 0.01;
    
    float d = 0.0, t_ray = 0.0, g = 0.0;
    for(int i = 0; i < 70; i++) {
        vec3 p = ro + rd * t_ray;
        p -= normalize(p) * (0.05 / (dot(p, p) + 0.01));
        float l_m = length(p);
        float w_m = sin(l_m * 15.0 - iTime * 8.0) * exp(-l_m * 2.5) * 0.12;
        d = l_m - 1.2 + w_m + sin(p.x * 8.0 + iTime * 2.0) * sin(p.y * 8.0 - iTime) * sin(p.z * 8.0) * 0.03;
        
        if(abs(d) < 0.002 || t_ray > 6.0) break;
        t_ray += d * 0.7;
        g += 0.015 / (0.02 + abs(d));
    }
    
    vec3 col = bgCol;
    
    if(t_ray < 6.0) {
        vec3 p = ro + rd * t_ray;
        vec2 e = vec2(0.005, 0.0);
        vec3 n;
        for(int j = 0; j < 3; j++) {
            vec3 off = (j == 0) ? e.xyy : ((j == 1) ? e.yxy : e.yyx);
            vec3 p1 = p + off;
            vec3 p2 = p - off;
            
            p1 -= normalize(p1) * (0.05 / (dot(p1, p1) + 0.01));
            float l1 = length(p1);
            float d1 = l1 - 1.2 + sin(l1 * 15.0 - iTime * 8.0) * exp(-l1 * 2.5) * 0.12 + sin(p1.x * 8.0 + iTime * 2.0) * sin(p1.y * 8.0 - iTime) * sin(p1.z * 8.0) * 0.03;
            
            p2 -= normalize(p2) * (0.05 / (dot(p2, p2) + 0.01));
            float l2 = length(p2);
            float d2 = l2 - 1.2 + sin(l2 * 15.0 - iTime * 8.0) * exp(-l2 * 2.5) * 0.12 + sin(p2.x * 8.0 + iTime * 2.0) * sin(p2.y * 8.0 - iTime) * sin(p2.z * 8.0) * 0.03;
            
            n[j] = d1 - d2;
        }
        n = normalize(n);
        
        vec3 v = -rd;
        float fres = 0.04 + 0.96 * pow(max(1.0 - dot(n, v), 0.0), 5.0);
        vec3 rdIn = refract(rd, n, 1.0 / 1.35);
        
        vec3 vPos = p;
        vec3 vCol = vec3(0.0);
        float vStep = 0.04;
        
        for(int i = 0; i < 40; i++) {
            vPos += rdIn * vStep;
            if(length(vPos) > 1.3) break;
            
            float l_h = length(vPos);
            float w_h = sin(l_h * 15.0 - iTime * 8.0) * exp(-l_h * 2.5) * 0.12;
            float den = exp(-dot(vPos, vPos) * 5.0) * (0.5 + 0.5 * sin(iTime)) + max(0.0, w_h) * 8.0;
            
            vec3 dL1 = lz - vPos;
            float dist1 = length(dL1);
            vec3 lDir1 = normalize(dL1);
            
            vec3 dL2 = lPos2 - vPos;
            float dist2 = length(dL2);
            vec3 lDir2 = normalize(dL2);
            
            float c1_ray = dot(lDir1, -rdIn);
            vec3 rCol1 = (1.0 + c1_ray * c1_ray) * vec3(0.178, 0.068, 0.050) * (1.0 / (dist1 * dist1 + 0.01)) * vec3(1.0, 0.3, 0.1);
            
            float c2_ray = dot(lDir2, -rdIn);
            vec3 rCol2 = (1.0 + c2_ray * c2_ray) * vec3(0.178, 0.068, 0.050) * (1.0 / (dist2 * dist2 + 0.01)) * vec3(0.1, 0.5, 1.0);
            
            vCol += (rCol1 + rCol2) * den * vStep * 3.0;
        }
        col = mix(bgCol * 0.3 + vCol, vec3(1.0, 0.9, 0.8), fres);
    }
    
    col += vec3(0.1, 0.5, 1.0) * g * 0.012;
    
    float x = u.x * 6.0;
    for(int i = 0; i < 3; i++) {
        float f = float(i);
        float ph = iTime * 1.5 + f * 0.2 + lz.x * 3.0;
        
        float y = sin(x * (1.5 + f * 0.5) - ph) * 0.08;
        y += exp(-x * x * 1.5) * 0.08 * sin(ph * 2.0);
        y += pow(abs(sin(x * 0.8 + ph)), 5.0) * 0.04;
        y -= (0.015 / (x * x * 0.2 + 0.1)) * sin(ph);
        float tm2 = mod(ph * 0.15, 4.0);
        y += (-1.0 + 2.0 * tm2 - 0.5 * tm2 * tm2) * 0.015 * x;
        y += asin(clamp(sin(x * 1.2 - ph * 0.5) * 0.4, -1.0, 1.0)) * 0.04;
        y += (0.1 - x) * 0.02;
        
        float d_w = abs((u.y + 0.4) - y);
        float intn = 0.0015 / (d_w * d_w + 0.0005);
        
        vec3 lc = (i == 0) ? vec3(1.0, 0.1, 0.05) : ((i == 1) ? vec3(0.1, 1.0, 0.2) : vec3(0.05, 0.3, 1.0));
        col += lc * intn * (0.5 + 0.5 * pow(cos(x * 2.0 - ph), 2.0));
    }
    
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    O = vec4(pow(col, vec3(1.0 / 2.2)), 1.0);
}
