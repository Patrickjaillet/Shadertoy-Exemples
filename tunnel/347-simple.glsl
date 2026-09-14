// ==== Image (image) ====
const float sEPS = 0.002;
const float FAR = 31.0;
const int ITER = 160;

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdCylinder(vec3 p, float r) {
    return length(p.xy) - r;
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xy) - t.x, p.z);
    return length(q) - t.y;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 1.0 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 getPath(float z) {
    return vec3(sin(z * 0.18) * -1.9, cos(z * 0.5) * 0.9, z);
}

float map(vec3 p) {
    vec3 path = getPath(p.z);
    p.xy -= path.xy;
    p.xy *= rot(p.z * 0.08 + iTime * 0.05);
    
    float tunnel = -sdCylinder(p, 4.5);
    
    vec3 pR = p;
    float rId = floor((atan(pR.y, pR.x) / 6.2831853) * 8.0 + 0.5);
    pR.xy *= rot(-rId * (6.2831853 / 8.0));
    pR.x -= 4.0;
    float struts = sdCylinder(pR, 0.28);
    
    vec3 pT = p;
    float tRep = 3.5;
    float tId = floor(pT.z / tRep + 0.5);
    pT.z -= (tId * tRep);
    pT.xy *= rot(tId * 0.4);
    float rings = sdTorus(pT.xzy, vec2(14.0, 0.22));
    
    float web = smin(struts, rings, 0.45);
    float n = sin(p.x * 8.3 + iTime) * sin(p.y * 12.0) * sin(p.z * 6.0) * 0.04;
    web += n * (0.2 + 0.8 * smoothstep(0.0, 0.5, web));
    
    float finalSDF = smin(tunnel, web, 0.5);
    
    vec3 pB = p;
    pB.z -= iTime * 8.0;
    float bId = floor(pB.z / 6.0);
    pB.z = mod(pB.z, 6.0) - 3.0;
    pB.xy *= rot(bId * 1.5);
    pB.xy -= vec2(sin(iTime * 2.0) * 1.5, cos(iTime * 1.5) * 1.5);
    float bolts = length(pB) - 0.25;
    
    return smin(finalSDF, bolts, 0.4);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

vec3 getNebula(vec3 rd) {
    float d1 = sin(rd.x * 3.0 + iTime * 0.1) * cos(rd.y * 3.0) * sin(rd.z * 3.0);
    float d2 = cos(rd.x * 6.0) * sin(rd.y * 5.0 - iTime * 0.05) * cos(rd.z * 4.0);
    vec3 col1 = vec3(0.02, 0.4, 0.3) * max(0.0, d1);
    vec3 col2 = vec3(0.4, 0.05, 0.5) * max(0.0, d2);
    vec3 stars = vec3(pow(max(0.0, sin(rd.x * 120.0) * cos(rd.y * 120.0) * sin(rd.z * 120.0)), 32.0)) * 1.5;
    return col1 + col2 + stars;
}

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float zPos = iTime * 4.0;
    vec3 ro = getPath(zPos);
    vec3 target = getPath(zPos + 2.0);
    
    vec3 f = normalize(target - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);
    
    rd.xy *= rot(sin(iTime * 0.2) * 0.15);
    
    float t = 0.0;
    float d = 0.0;
    float beamGlow = 0.0;
    
    for(int i = 0; i < ITER; i++) {
        vec3 pCurr = ro + rd * t;
        d = map(pCurr);
        if(d < sEPS || t > FAR) break;
        
        vec3 pL = pCurr;
        pL.xy -= getPath(pL.z).xy;
        float rCore = length(pL.xy);
        beamGlow += exp(-0.6 * rCore) * exp(-0.02 * t);
        
        t += d * 0.65;
    }
    
    vec3 col = getNebula(rd);
    
    if(t < FAR) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 refl = reflect(rd, n);
        
        vec3 pL = p;
        pL.xy -= getPath(pL.z).xy;
        
        vec3 ld1 = normalize(vec3(0.0, 0.0, -1.0));
        vec3 ld2 = normalize(vec3(2.0, 3.0, 1.0));
        
        float diff1 = max(0.0, dot(n, ld1));
        float diff2 = max(0.0, dot(n, ld2));
        float spec1 = pow(max(0.0, dot(refl, ld1)), 128.0);
        float spec2 = pow(max(0.0, dot(refl, ld2)), 32.0);
        
        float ao = 0.0;
        float sca = 1.0;
        for(int i = 1; i <= 4; i++) {
            float hr = 0.05 + 0.15 * float(i);
            ao += (hr - map(p + n * hr)) * sca;
            sca *= 0.5;
        }
        ao = clamp(1.0 - ao * 4.0, 0.0, 1.0);
        
        vec3 gold = vec3(1.0, 0.65, 0.3) * (diff1 * 0.7 + spec1 * 3.0);
        vec3 chrome = vec3(0.7, 0.8, 1.0) * (diff2 * 0.4 + spec2 * 2.0);
        
        float matMix = smoothstep(-1.0, 1.0, sin(p.z * 0.3 + atan(pL.y, pL.x) * 3.0));
        vec3 metal = mix(gold, chrome, matMix);
        
        float laserGlow = exp(-0.3 * length(pL.xy));
        vec3 internalGlow = vec3(0.3, 0.7, 1.0) * pow(laserGlow, 2.0) * 4.0;
        
        col = (metal + internalGlow) * ao;
        col *= exp(-0.04 * t);
    }
    
    col += vec3(0.2, 0.5, 1.0) * beamGlow * 0.06;
    col += vec3(1.0, 0.6, 0.3) * pow(beamGlow * 0.03, 2.0);
    
    vec2 distUV = uv * (1.0 + 0.25 * length(uv));
    col.r = mix(col.r, col.r * 1.3, length(distUV) * 0.15);
    col.b = mix(col.b, col.b * 1.3, length(uv) * 0.2);
    
    vec2 vuv = fragCoord / iResolution.xy;
    float vignette = 16.0 * vuv.x * vuv.y * (1.0 - vuv.x) * (1.0 - vuv.y);
    col *= pow(vignette, 1.00);
    
    col = aces(col * 1.6);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
