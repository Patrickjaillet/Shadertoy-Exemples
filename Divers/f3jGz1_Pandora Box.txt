// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float de(vec3 p, out vec4 col) {
    p.xz *= rot(iTime * 0.05);
    p.xy *= rot(iTime * 0.03);
    
    vec3 orbit = p;
    float scale = 1.0;
    float d = 1e10;
    
    for(int i = 0; i < 4; i++) {
        p = abs(p) - vec3(0.15, 0.45, 0.35);
        
        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;
        
        p.xy *= rot(0.25);
        
        p = p * 1.75 - vec3(0.1, 0.7, 0.2);
        scale *= 1.75;
        
        float box = sdBox(p, vec3(0.4, 0.1, 0.4)) / scale;
        d = min(d, box);
        
        if(i < 16) orbit = min(orbit, abs(p));
    }
// https://github.com/Patrickjaillet/Z-GL    
    col = vec4(sin(orbit * 2.6) * 0.5 + vec3(0.6), 1.0);
    return d;
}

vec3 getNormal(vec3 p) {
    vec4 dummy;
    vec2 e = vec2(0.0005, 0.0);
    return normalize(vec3(
        de(p + e.xyy, dummy) - de(p - e.xyy, dummy),
        de(p + e.yxy, dummy) - de(p - e.yxy, dummy),
        de(p + e.yyx, dummy) - de(p - e.yyx, dummy)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    vec4 dummy;
    for(int i = 0; i < 6; i++) {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        float d = de(p + n * hr, dummy);
        occ += (hr - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 4.0 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.xy.y;
    
    vec3 ro = vec3(0.0, 0.0, -3.6);
    vec3 rd = normalize(vec3(uv, 1.4));
    
    float t = 0.0;
    float maxD = 8.0;
    vec4 objCol = vec4(0.0);
    float d = 0.0;
    
    float glow = 0.0;
    
    for(int i = 0; i < 80; i++) {
        vec3 p = ro + rd * t;
        d = de(p, objCol);
        if(abs(d) < 0.0010 || t > maxD) break;
        t += d * 0.80;
        glow += exp(-d * 90.0);
    }
    
    vec3 sceneColor = vec3(0.0);
    
    if(t < maxD) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        
        vec3 l1 = normalize(vec3(1.5, -1.1, -2.0));
        vec3 l2 = normalize(vec3(-1.6, -1.5, -1.0));
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 1.0) * 1.0;
        
        vec3 r = reflect(rd, n);
        float spec = pow(max(dot(r, l1), 0.0), 40.0);
        
        float ao = getAO(p, n);
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 4.0);
        
        vec3 baseLight = objCol.rgb * (diff1 + diff2 + 0.93);
        sceneColor = baseLight + vec3(0.8) * spec + vec3(0.5, 1.0, 0.7) * fre;
        sceneColor *= ao;
        
        sceneColor = mix(sceneColor, vec3(0.005, 0.00, 0.00), 1.0 - exp(-0.1 * t * t));
    } else {
        sceneColor = vec3(0.002, 0.004, 0.008) * (1.0 - length(uv));
    }
    
    sceneColor += vec3(0.1, 0.5, 0.9) * glow * 0.012;
    sceneColor += vec3(1.0, 0.0, 0.0) * glow * 0.030 * (sin(iTime) * 0.5 + 0.5);
    
    sceneColor = pow(sceneColor, vec3(1.0 / 2.2));
    sceneColor = smoothstep(-0.02, 1.02, sceneColor);
    
    vec2 vignetteUV = fragCoord / iResolution.xy;
    sceneColor *= 0.5 + 0.5 * pow(16.0 * vignetteUV.x * vignetteUV.y * (1.0 - vignetteUV.x) * (1.0 - vignetteUV.y), 0.25);
    
    fragColor = vec4(sceneColor, 1.0);
}
