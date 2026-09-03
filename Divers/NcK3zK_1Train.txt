// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 opU(vec2 d1, vec2 d2) {
    return (d1.x < d2.x) ? d1 : d2;
}

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float path(float z) {
    return sin(z * 0.05) * 15.0;
}

float pathDeriv(float z) {
    return 0.05 * 15.0 * cos(z * 0.05);
}

float trainDist(vec3 p, float zOffset, bool isLoco) {
    float xC = path(zOffset);
    float a = atan(pathDeriv(zOffset));
    
    vec3 lp = p;
    lp.z -= zOffset;
    lp.x -= xC;
    lp.xz *= rot(a);
    
    vec3 bp = lp;
    bp.y -= 2.5;
    float d = length(max(abs(bp) - vec3(1.4, 1.2, 4.0), 0.0)) - 0.2;
    
    if (isLoco) {
        vec3 cp = lp;
        cp.y -= 4.0;
        cp.z += 2.0;
        float cab = length(max(abs(cp) - vec3(1.5, 1.2, 1.5), 0.0)) - 0.2;
        
        vec3 cy = lp;
        cy.y -= 3.0;
        cy.z -= 1.5;
        float boiler = max(length(cy.xy) - 1.2, abs(cy.z) - 2.5);
        
        vec3 ch = lp;
        ch.y -= 5.0;
        ch.z -= 3.0;
        float chim = max(length(ch.xz) - 0.4, abs(ch.y) - 1.0);
        
        d = min(d, min(cab, min(boiler, chim)));
    }
    
    vec3 wp = lp;
    float wheelBound = abs(lp.z) - 3.8;
    wp.z = mod(wp.z + 2.0, 4.0) - 2.0;
    wp.y -= 1.0;
    wp.x = abs(wp.x) - 1.2;
    float wheels = max(length(wp.yz) - 0.6, abs(wp.x) - 0.15);
    wheels = max(wheels, wheelBound);
    
    return min(d, wheels);
}

vec2 map(vec3 p, float t) {
    vec2 res = vec2(p.y + 1.0, 1.0);
    
    float px = path(p.z);
    float pDeriv = pathDeriv(p.z);
    
    float trackBase = length(max(abs(vec2(p.x - px, p.y - 0.1)) - vec2(2.5, 0.1), 0.0));
    
    vec3 sp = p;
    sp.z = mod(sp.z, 0.8) - 0.4;
    sp.x -= px;
    sp.xz *= rot(atan(pDeriv));
    float sleepers = length(max(abs(vec3(sp.x, p.y, sp.z)) - vec3(2.0, 0.15, 0.1), 0.0));
    
    float r1 = length(max(abs(vec2(sp.x - 1.2, p.y - 0.3)) - vec2(0.1, 0.1), 0.0));
    float r2 = length(max(abs(vec2(sp.x + 1.2, p.y - 0.3)) - vec2(0.1, 0.1), 0.0));
    
    res = opU(res, vec2(min(trackBase, min(sleepers, min(r1, r2))), 2.0));
    
    float tunZ = mod(p.z + 100.0, 200.0) - 100.0;
    vec3 tp = p;
    tp.x -= px;
    float tunIn = length(tp.xy) - 6.0;
    float tunOut = length(tp.xy) - 7.0;
    float tunnel = max(-tunIn, tunOut);
    tunnel = max(tunnel, -tp.y - 1.0);
    tunnel = max(tunnel, abs(tunZ) - 25.0);
    res = opU(res, vec2(tunnel, 3.0));
    
    float s = sign(p.x - px);
    float absX = abs(p.x - px);
    float idx = floor(absX / 8.0);
    float idz = floor(p.z / 8.0);
    float h = hash21(vec2(max(idx, 1.0), idz * s));
    
    vec3 trp = p;
    trp.z = mod(trp.z, 8.0) - 4.0;
    float cx = px + s * (max(idx, 1.0) * 8.0 + 4.0 + h * 4.0);
    trp.x -= cx;
    
    float trunk = max(length(trp.xz) - 0.3 - h * 0.2, abs(trp.y - 4.0) - 5.0);
    float leaves = length(trp - vec3(0.0, 6.0 + h * 2.0, 0.0)) - 4.1 - h;
    float treeSDF = min(trunk, leaves);
    
    treeSDF = max(treeSDF, -(abs(tunZ) - 30.0)); 
    treeSDF = max(treeSDF, 5.0 - absX);
    
    res = opU(res, vec2(treeSDF, 4.0));
    
    float speed = 25.0;
    float trainZ = t * speed;
    float t1 = trainDist(p, trainZ, true);
    float t2 = trainDist(p, trainZ - 9.0, false);
    float t3 = trainDist(p, trainZ - 18.0, false);
    
    res = opU(res, vec2(min(t1, min(t2, t3)), 5.0));
    
    return res;
}

vec3 calcNormal(vec3 p, float t) {
    vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.0005;
    return normalize(e.xyy * map(p + e.xyy, t).x + 
                     e.yyx * map(p + e.yyx, t).x + 
                     e.yxy * map(p + e.yxy, t).x + 
                     e.xxx * map(p + e.xxx, t).x);
}

float calcShadow(vec3 ro, vec3 rd, float t) {
    float res = 1.0;
    float t2 = 0.5;
    for(int i = 0; i < 32; i++) {
        float h = map(ro + rd * t2, t).x;
        res = min(res, 10.0 * h / t2);
        t2 += h;
        if(res < 0.01 || t2 > 30.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    float speed = 25.0;
    
    float camZ = t * speed - 30.0;
    vec3 ro = vec3(path(camZ) - 20.0, 20.0, camZ);
    vec3 ta = vec3(path(camZ + 30.0), 2.0, camZ + 30.0);
    
    vec3 w = normalize(ta - ro);
    vec3 u = normalize(cross(w, vec3(0.0, 1.0, 0.0)));
    vec3 v = cross(u, w);
    vec3 rd = normalize(uv.x * u + uv.y * v + 1.5 * w);
    
    vec3 col = vec3(0.5, 0.7, 0.9) - max(rd.y, 0.0) * 0.5;
    
    float d = 0.0;
    float m = -1.0;
    for(int i = 0; i < 150; i++) {
        vec2 p = map(ro + rd * d, t);
        if(p.x < 0.01) {
            m = p.y;
            break;
        }
        if(d > 250.0) break;
        d += p.x * 0.75;
    }
    
    if(d < 250.0) {
        vec3 pos = ro + rd * d;
        vec3 nor = calcNormal(pos, t);
        
        vec3 mate = vec3(0.2);
        if(m == 1.0) mate = vec3(0.15, 0.25, 0.1) * (1.0 + hash21(pos.xz) * 0.2);
        else if(m == 2.0) mate = vec3(0.2, 0.18, 0.15);
        else if(m == 3.0) mate = vec3(0.4, 0.4, 0.45);
        else if(m == 4.0) mate = pos.y > 2.0 ? vec3(0.1, 0.3, 0.1) : vec3(0.3, 0.15, 0.05);
        else if(m == 5.0) mate = vec3(0.6, 0.1, 0.1);
        
        vec3 sun = normalize(vec3(0.8, 0.6, -0.2));
        float dif = clamp(dot(nor, sun), 0.0, 1.0);
        float sha = calcShadow(pos, sun, t);
        float sky = clamp(0.5 + 0.5 * nor.y, 0.0, 1.0);
        
        float tunZ_light = mod(pos.z + 100.0, 200.0) - 100.0;
        float inTunnel = smoothstep(26.0, 20.0, abs(tunZ_light));
        
        dif *= (1.0 - inTunnel);
        sha *= (1.0 - inTunnel);
        sky *= mix(1.0, 0.05, inTunnel);
        
        vec3 lin = vec3(0.0);
        lin += dif * vec3(1.2, 1.1, 1.0) * sha;
        lin += sky * vec3(0.2, 0.3, 0.4);
        
        col = mate * lin;
        
        if(inTunnel > 0.0 && m == 5.0) {
             col += vec3(0.2, 0.0, 0.0) * inTunnel;
        }
        
        float fog = exp(-0.00005 * d * d);
        col = mix(vec3(0.5, 0.7, 0.9), col, fog);
    }
    
    col = pow(col, vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
