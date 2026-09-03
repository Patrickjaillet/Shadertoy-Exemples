// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdEllipsoid(vec3 p, vec3 r) {
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float sdCylinder(vec3 p, vec2 h) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - h;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float smin(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

float sdPetal(vec3 p, float scale, float ringIndex) {
    p.z -= 0.2 * scale;
    
    float bend = p.z * (0.8 + 0.4 * sin(ringIndex * 1.5));
    p.xy *= rot(bend);
    p.y -= bend * bend * 0.15;

    float pY = p.y * (1.0 + 0.5 * p.z);
    float thickness = 0.02 * (1.0 - smoothstep(0.0, 1.2, p.z));
    
    float d = sdEllipsoid(vec3(p.x, pY, p.z), vec3(0.18 * scale, thickness, 0.6 * scale));
    return d;
}

vec2 map(vec3 p) {
    vec2 res = vec2(1e5, 0.0);
    
    vec3 stp = p;
    float stemBend = stp.y * 0.15;
    stp.xz *= rot(stemBend);
    float stem = sdCylinder(stp - vec3(0.0, -1.0, 0.0), vec2(0.04, 1.0));
    res = vec2(stem, 3.0);
    
    vec3 rp = p;
    rp.y -= 0.05;
    float recept = sdEllipsoid(rp, vec3(0.25, 0.15, 0.25));
    res.x = smin(res.x, recept, 0.05);
    if(recept < res.x) res.y = 3.0;

    float stamenDensity = 12.0;
    vec3 sp = p;
    sp.y -= 0.15;
    float r = length(sp.xz);
    if (r < 0.22 && sp.y > -0.05 && sp.y < 0.15) {
        float a = atan(sp.z, sp.x);
        float id = floor(a * stamenDensity / 6.28318);
        float ma = (id + 0.5) * 6.28318 / stamenDensity;
        vec3 isp = sp;
        isp.xz *= rot(-ma);
        isp.x -= 0.04 + 0.12 * fract(sin(id * 45.12) * 100.0);
        float stamen = sdCylinder(isp, vec2(0.008, 0.08));
        if (stamen < res.x) res = vec2(stamen, 4.0);
    }

    const int rings = 4;
    for (int i = 0; i < rings; i++) {
        float fI = float(i);
        float ringScale = 1.0 - fI * 0.15;
        float petalCount = 8.0 + fI * 4.0;
        float angleOffset = fI * 0.75;
        
        vec3 ringP = p;
        ringP.y -= fI * 0.04;
        
        float rLength = length(ringP.xz);
        float rAngle = atan(ringP.z, ringP.x) + angleOffset;
        
        float petalId = floor(rAngle * petalCount / 6.28318);
        float sectorAngle = (petalId + 0.5) * 6.28318 / petalCount;
        
        vec3 pp = ringP;
        pp.xz *= rot(-sectorAngle);
        
        float tilt = 0.2 + fI * 0.18 + 0.08 * sin(iTime + fI);
        pp.zy *= rot(tilt);
        
        float dPetal = sdPetal(pp, ringScale, fI);
        
        if (dPetal < res.x) {
            res.x = smin(res.x, dPetal, 0.03);
            res.y = 1.0 + fI;
        }
    }
    
    return res;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy).x - map(p - e.xyy).x,
        map(p + e.yxy).x - map(p - e.yxy).x,
        map(p + e.yyx).x - map(p - e.yyx).x
    ));
}

float getShadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float h = map(ro + rd * t).x;
        if (h < 0.001) return 0.0;
        res = min(res, 8.0 * h / t);
        t += clamp(h, 0.02, 0.1);
        if (t > 4.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 getColor(float id, vec3 p, vec3 n) {
    vec3 col = vec3(0.0);
    
    if (id >= 1.0 && id <= 4.0) {
        float ringNorm = (id - 1.0) / 3.0;
        float dToCenter = length(p.xz);
        
        vec3 innerColor = mix(vec3(1.0, 0.1, 0.0), vec3(1.0, 0.5, 0.0), ringNorm);
        vec3 outerColor = mix(vec3(1.0, 0.4, 0.0), vec3(1.0, 0.85, 0.1), ringNorm);
        
        col = mix(innerColor, outerColor, smoothstep(0.1, 0.8, dToCenter));
        
        float veins = sin(atan(p.z, p.x) * 60.0) * sin(dToCenter * 20.0);
        col += vec3(0.12, 0.03, 0.0) * smoothstep(0.4, 1.0, veins) * (1.0 - ringNorm);
    } 
    else if (id == 3.0) {
        col = mix(vec3(0.1, 0.35, 0.05), vec3(0.3, 0.5, 0.1), smoothstep(-1.0, 0.1, p.y));
    } 
    else if (id == 4.0) {
        col = mix(vec3(1.0, 0.7, 0.0), vec3(0.9, 0.9, 0.2), step(0.08, p.y));
    }
    
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t = iTime * 0.4;
    vec3 ro = vec3(2.5 * cos(t), 1.2 + 0.6 * sin(t * 1.5), 2.5 * sin(t));
    vec3 ta = vec3(0.0, 0.2, 0.0);
    
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.8 * cw);
    
    vec3 col = mix(vec3(0.03, 0.01, 0.02), vec3(0.12, 0.05, 0.08), length(uv));
    
    float dMax = 6.0;
    float tMat = 0.0;
    vec2 res = vec2(-1.0);
    
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * tMat;
        res = map(p);
        if (abs(res.x) < 0.001 || tMat > dMax) break;
        tMat += res.x;
    }
    
    if (tMat < dMax && res.y > 0.0) {
        vec3 p = ro + rd * tMat;
        vec3 n = getNormal(p);
        vec3 matCol = getColor(res.y, p, n);
        
        vec3 lPos = vec3(3.0, 5.0, 2.0);
        vec3 lDir = normalize(lPos - p);
        vec3 viewDir = normalize(ro - p);
        vec3 hDir = normalize(lDir + viewDir);
        
        float diff = clamp(dot(n, lDir), 0.0, 1.0);
        float spec = pow(clamp(dot(n, hDir), 0.0, 1.0), 32.0);
        float bounce = clamp(dot(n, vec3(0.0, -1.0, 0.0)), 0.0, 1.0);
        float sh = getShadow(p, lDir);
        
        vec3 lCol = vec3(1.0, 0.95, 0.85);
        vec3 ambCol = vec3(0.08, 0.04, 0.06);
        vec3 bCol = vec3(0.2, 0.05, 0.02);
        
        vec3 diffuse = diff * lCol * sh;
        vec3 ambient = ambCol * (0.5 + 0.5 * n.y);
        vec3 specular = spec * vec3(1.0) * sh * 0.4;
        vec3 backlight = bounce * bCol * 0.25;
        
        col = matCol * (diffuse + ambient + backlight) + specular;
        col = mix(col, vec3(0.08, 0.03, 0.05), 1.0 - exp(-0.08 * tMat * tMat));
    }
    
    col = pow(col, vec3(0.4545));
    col = clamp(col, 0.0, 1.0);
    col = col * col * (3.0 - 2.0 * col);
    
    fragColor = vec4(col, 1.0);
}
