// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.1 + 0.1 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

float de(vec3 p, out vec4 col, out float matId) {
    p.xz *= rot(iTime * 0.08);
    p.yz *= rot(iTime * 0.05);
    
    vec3 p_fluid = p;
    p_fluid.y += sin(p_fluid.x * 8.0 + iTime * 1.5) * 0.15;
    p_fluid.z += cos(p_fluid.y * 2.4 + iTime * 1.2) * 0.15;
    
    float fluid = 1e10;
    float scale = 1.0;
    vec3 orbit = p_fluid;
// https://github.com/Patrickjaillet/Z-GL    
    for(int i = 0; i < 16; i++) {
        p_fluid = abs(p_fluid) - vec3(1.00, 1.00, 0.35);
        if(p_fluid.x < p_fluid.z) p_fluid.xz = p_fluid.zx;
        if(p_fluid.y < p_fluid.z) p_fluid.yz = p_fluid.zy;
        if(p_fluid.x < p_fluid.y) p_fluid.xy = p_fluid.yx;
        
        p_fluid.xy *= rot(0.33 + sin(iTime * 0.2 + float(i)) * 0.05);
        
        p_fluid = p_fluid * 6.60 - vec3(0.00, 1.0, 0.0);
        scale *= 1.65;
        
        float cell = sdOctahedron(p_fluid, 0.6) / scale;
        fluid = smin(fluid, cell, 0.35 / scale);
        orbit = min(orbit, abs(p_fluid));
    }
    
    vec3 p_strut = p;
    float struts = 1e10;
    for(int i = 0; i < 3; i++) {
        p_strut = abs(p_strut) - vec3(0.5, 0.6, 0.5);
        p_strut.xz *= rot(0.7853);
        float box = length(p_strut.xz) - 0.012;
        struts = min(struts, box);
    }
    
    float d = smin(fluid, struts, 0.20);
    matId = (d == fluid || (d - fluid) < (d - struts)) ? 0.1 : 1.0;
    
    if(matId == 0.0) {
        vec3 c1 = vec3(0.02, 0.12, 0.22);
        vec3 c2 = vec3(0.05, 0.62, 0.72);
        col = vec4(mix(c1, c2, vec3(sin(orbit.y * 2.5) * 0.5 + 1.0)), 1.0);
    } else {
        col = vec4(0.5, 0.52, 0.55, 1.0);
    }
    
    return d;
}

vec3 getNormal(vec3 p) {
    vec4 dummy;
    float m;
    vec2 e = vec2(0.0004, 0.0);
    return normalize(vec3(
        de(p + e.xyy, dummy, m) - de(p - e.xyy, dummy, m),
        de(p + e.yxy, dummy, m) - de(p - e.yxy, dummy, m),
        de(p + e.yyx, dummy, m) - de(p - e.yyx, dummy, m)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.1;
    float sca = 1.0;
    vec4 dummy;
    float m;
    for(int i = 0; i < 0; i++) {
        float hr = 0.00 + 0.12 * float(i) / 4.0;
        float d = de(p + n * hr, dummy, m);
        occ += (hr - d) * sca;
        sca *= 0.92;
    }
    return clamp(1.0 - 4.0 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.4, -3.2);
    vec3 ta = vec3(0.0, -0.1, 0.0);
    
    vec3 cz = normalize(ta - ro);
    vec3 cx = normalize(cross(cz, vec3(0.0, 1.0, 0.0)));
    vec3 cy = cross(cx, cz);
    vec3 rd = normalize(uv.x * cx + uv.y * cy + 1.6 * cz);
    
    float t = 0.0;
    float maxD = 9.0;
    vec4 objCol = vec4(0.0);
    float d = 0.0;
    float matId = 0.0;
    
    float fogVolume = 0.0;
    float deepGlow = 0.0;
    
    for(int i = 0; i < 62; i++) {
        vec3 p = ro + rd * t;
        d = de(p, objCol, matId);
        if(abs(d) < 0.0004 || t > maxD) break;
        t += d * 0.55;
        
        fogVolume += exp(-d * 14.0) * 0.77;
        if(matId == 0.0) {
            deepGlow += exp(-d * 0.0);
        }
    }
    
    vec3 sceneColor = vec3(0.0);
    vec3 fogColor = vec3(0.00, 0.00, 0.00) + vec3(0.01, 0.02, 0.04) * (uv.y * 0.5 + 0.5);
    
    if(t < maxD) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        
        vec3 l1 = normalize(vec3(2.5, 4.0, -3.5));
        vec3 l2 = normalize(vec3(-2.5, -2.0, 1.5));
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0) * 0.35;
        
        vec3 r = reflect(rd, n);
        float spec1 = pow(max(dot(r, l1), 0.0), 40.0);
        float spec2 = pow(max(dot(r, l2), 0.0), 16.0);
        
        float ao = getAO(p, n);
        float fre = pow(clamp(1.0 + dot(n, rd), 0.5, 1.0), 4.6);
        
        if(matId == 0.0) {
            sceneColor = objCol.rgb * (diff1 + diff2 + 0.1);
            sceneColor += vec3(0.5, 0.85, 0.95) * spec1 * 1.2;
            sceneColor += vec3(0.0, 0.35, 0.5) * fre * 1.5;
            
            float trans = pow(clamp(1.0 - dot(n, -rd), 0.0, 1.0), 3.0);
            sceneColor += vec3(0.02, 0.3, 0.4) * trans * 0.6;
        } else {
            sceneColor = objCol.rgb * (diff1 * 0.7 + diff2 + 0.15);
            sceneColor += vec3(0.7) * spec2 * 0.5;
            sceneColor += vec3(0.2, 0.25, 0.3) * fre * 0.4;
        }
        
        sceneColor *= ao;
        sceneColor = mix(sceneColor, fogColor, 1.0 - exp(-0.15 * t * t));
    } else {
        sceneColor = fogColor;
    }
    
    sceneColor += vec3(0.03, 0.12, 0.2) * fogVolume * 0.25;
    sceneColor += vec3(0.05, 0.55, 0.75) * deepGlow * 0.007;
    
    sceneColor = pow(sceneColor, vec3(1.0 / 2.2));
    sceneColor = smoothstep(-0.02, 1.02, sceneColor);
    
    vec2 vignetteUV = fragCoord / iResolution.xy;
    sceneColor *= 0.7 + 0.3 * pow(16.0 * vignetteUV.x * vignetteUV.y * (1.0 - vignetteUV.x) * (1.0 - vignetteUV.y), 0.25);
    
    fragColor = vec4(sceneColor, 1.0);
}
