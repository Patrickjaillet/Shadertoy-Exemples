// ==== Image (image) ====
vec3 ACESFilm(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    
    vec2 distVec = uv - 0.5;
    float dist = length(distVec);
    vec2 caOffset = distVec * dist * 0.015;
    
    float r = texture(iChannel0, uv + caOffset).r;
    float g = texture(iChannel0, uv).g;
    float b = texture(iChannel0, uv - caOffset).b;
    vec3 scene = vec3(r, g, b);
    
    vec3 verticalBloom = vec3(0.0);
    float weights[5];
    weights[0] = 0.227027;
    weights[1] = 0.1945946;
    weights[2] = 0.1216216;
    weights[3] = 0.054054;
    weights[4] = 0.016216;
    
    for (int i = 0; i < 5; i++) {
        vec2 offset = vec2(0.0, texel.y * float(i) * 2.5);
        vec4 b1 = texture(iChannel1, uv + offset);
        vec4 b2 = texture(iChannel1, uv - offset);
        verticalBloom += max(b1.rgb - vec3(0.25), vec3(0.0)) * weights[i];
        verticalBloom += max(b2.rgb - vec3(0.25), vec3(0.0)) * weights[i];
    }
    
    vec3 color = scene + verticalBloom * 2.2;
    
    color = ACESFilm(color);
    color = pow(color, vec3(1.0 / 2.2));
    
    float vignette = smoothstep(0.85, 0.25, dist);
    color *= vignette;
    
    float scanline = sin(fragCoord.y * 1.5) * 0.025;
    color -= scanline;
    
    fragColor = vec4(color, 1.0);
}

// ==== Buffer A (buffer) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCylinder(vec3 p, float r, float h) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdLightCycle(vec3 p, out float glow) {
    vec3 cp = p;
    cp.x = abs(cp.x);
    
    vec3 fp = cp - vec3(0.0, 1.1, 2.2);
    fp.xy *= rot(1.5708);
    float frontWheel = sdCylinder(fp, 1.1, 0.35);
    
    vec3 rp = cp - vec3(0.0, 1.1, -2.2);
    rp.xy *= rot(1.5708);
    float rearWheel = sdCylinder(rp, 1.1, 0.4);
    
    float wheels = min(frontWheel, rearWheel);
    
    float bodyMain = sdBox(p - vec3(0.0, 1.5, 0.0), vec3(0.7, 0.75, 2.8));
    float canopy = sdBox(p - vec3(0.0, 2.0, -0.4), vec3(0.5, 0.45, 1.6));
    float frontSlope = sdBox(p - vec3(0.0, 1.2, 2.6), vec3(0.6, 0.5, 0.8));
    
    float body = min(bodyMain, min(canopy, frontSlope));
    
    vec3 gp1 = cp - vec3(0.71, 1.1, 2.2);
    float g1 = length(vec2(length(gp1.yz) - 1.0, gp1.x)) - 0.06;
    
    vec3 gp2 = cp - vec3(0.76, 1.1, -2.2);
    float g2 = length(vec2(length(gp2.yz) - 1.0, gp2.x)) - 0.06;
    
    float g3 = sdBox(cp - vec3(0.71, 1.6, 0.0), vec3(0.05, 0.06, 2.2));
    float g4 = sdBox(p - vec3(0.0, 2.46, -0.4), vec3(0.2, 0.05, 1.4));
    
    glow = min(min(g1, g2), min(g3, g4));
    
    return min(body, wheels);
}

float sdRecognizer(vec3 p, out float glow) {
    vec3 sp = p;
    sp.x = abs(sp.x);
    
    float archOuter = sdBox(sp - vec3(0.0, 14.0, 0.0), vec3(14.0, 14.0, 5.0));
    float archInner = sdBox(sp - vec3(0.0, 9.0, 0.0), vec3(8.0, 10.0, 6.0));
    float body = max(archOuter, -archInner);
    
    float cockpit = sdBox(sp - vec3(0.0, 24.0, 0.0), vec3(12.0, 4.0, 4.4));
    float legCut = sdBox(sp - vec3(11.0, 9.0, 0.0), vec3(2.4, 10.0, 4.0));
    
    float d = min(body, cockpit);
    d = min(d, legCut);
    
    vec3 gp = sp - vec3(0.0, 23.0, 4.6);
    float glowStrip = sdBox(gp, vec3(10.0, 0.6, 0.4));
    float glowLeg = sdBox(sp - vec3(11.0, 10.0, 4.2), vec3(0.6, 8.0, 0.4));
    
    glow = min(glowStrip, glowLeg);
    
    return d;
}

float sdRectifier(vec3 p, out float glow) {
    vec3 sp = p;
    sp.xz *= rot(0.1);
    
    vec3 asp = sp;
    asp.x = abs(asp.x);
    
    vec3 wingP = asp;
    wingP.xz *= rot(-0.45);
    float wing = sdBox(wingP - vec3(30.0, 0.0, 0.0), vec3(32.0, 2.4, 10.0));
    
    float core = sdBox(sp, vec3(12.0, 5.0, 36.0));
    float bridge = sdBox(sp - vec3(0.0, 7.0, -8.0), vec3(6.0, 3.6, 16.0));
    
    float trench = sdBox(asp - vec3(16.0, 0.0, 0.0), vec3(1.0, 4.0, 24.0));
    
    float hull = min(wing, min(core, bridge));
    hull = max(hull, -trench);
    
    vec3 gp1 = asp - vec3(20.0, 0.0, 4.0);
    gp1.xz *= rot(-0.45);
    float g1 = sdBox(gp1, vec3(28.0, 0.2, 0.4));
    
    vec3 gp2 = sp - vec3(0.0, 8.4, -8.0);
    float g2 = sdBox(gp2, vec3(5.0, 0.2, 15.0));
    
    glow = min(g1, g2);
    
    return hull;
}

float map(vec3 p, out float mat, out float glowDist) {
    mat = 0.0;
    float floorDist = p.y;
    
    float cycleSpeed = iTime * 45.0;
    float cycleX = sin(iTime * 1.5) * 6.0;
    vec3 cyclePos = vec3(cycleX, 0.0, cycleSpeed);
    
    vec3 pCycle = p - cyclePos;
    pCycle.xy *= rot(sin(iTime * 1.5) * -0.15);
    
    float gCycle;
    float cycle = sdLightCycle(pCycle, gCycle);
    
    float shipSpeed = cycleSpeed * 0.85;
    vec3 shipPos1 = vec3(0.0, 35.0, shipSpeed + 120.0);
    vec3 shipPos2 = vec3(-60.0, 25.0, shipSpeed + 40.0);
    vec3 shipPos3 = vec3(60.0, 25.0, shipSpeed + 40.0);
    
    float g1, g2, g3;
    float carrier = sdRectifier(p - shipPos1, g1);
    float rec1 = sdRecognizer(p - shipPos2, g2);
    float rec2 = sdRecognizer(p - shipPos3, g3);
    
    float ships = min(carrier, min(rec1, rec2));
    float shipGlow = min(g1, min(g2, g3));
    
    float ribbon = 1e5;
    if (p.z < cyclePos.z && p.z > cyclePos.z - 120.0) {
        vec3 rp = p - vec3(cyclePos.x, 1.25, cyclePos.z - 60.0);
        ribbon = sdBox(rp, vec3(0.08, 1.25, 60.0));
    }
    
    float scene = min(cycle, min(ships, ribbon));
    glowDist = min(shipGlow, min(gCycle, ribbon));
    
    if (scene < floorDist) {
        if (scene == cycle) mat = 2.0;
        else if (scene == ribbon) mat = 3.0;
        else mat = 1.0;
        return scene;
    }
    
    return floorDist;
}

vec3 calcNormal(vec3 p) {
    float m, g;
    vec2 e = vec2(0.003, 0.0);
    return normalize(vec3(
        map(p + e.xyy, m, g) - map(p - e.xyy, m, g),
        map(p + e.yxy, m, g) - map(p - e.yxy, m, g),
        map(p + e.yyx, m, g) - map(p - e.yyx, m, g)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float cycleSpeed = iTime * 45.0;
    float cycleX = sin(iTime * 1.5) * 6.0;
    
    vec3 ro = vec3(cycleX * 0.7 + sin(iTime * 0.5) * 4.0, 4.5 + cos(iTime * 0.3) * 1.5, cycleSpeed - 16.0);
    vec3 ta = vec3(cycleX, 1.5, cycleSpeed + 15.0);
    
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);
    
    float d = 0.0;
    float mat = 0.0;
    float glowAcc = 0.0;
    float glowDist = 0.0;
    vec3 p = ro;
    
    for (int i = 0; i < 130; i++) {
        p = ro + rd * d;
        float h = map(p, mat, glowDist);
        
        glowAcc += 0.015 / (0.02 + glowDist * glowDist * 3.0);
        
        if (abs(h) < 0.003 || d > 250.0) break;
        d += h * 0.6;
    }
    
    vec3 col = vec3(0.001, 0.002, 0.005);
    
    if (d < 250.0) {
        vec3 n = calcNormal(p);
        vec3 lightDir = normalize(vec3(0.3, 0.9, -0.4));
        
        if (mat < 0.5) {
            vec2 gUV = p.xz * 0.15;
            vec2 grid = abs(fract(gUV - 0.5) - 0.5) / fwidth(gUV);
            float line = min(grid.x, grid.y);
            float c = 1.0 - min(line, 1.0);
            
            vec3 gridCol = vec3(0.0, 0.5, 1.0);
            col = mix(vec3(0.001, 0.003, 0.008), gridCol * 5.0, c);
            
            float fres = pow(1.0 - max(dot(-rd, n), 0.0), 4.0);
            col += fres * vec3(0.0, 0.6, 1.0) * 0.8;
        } else if (mat > 2.5) {
            col = vec3(0.0, 0.8, 1.0) * 12.0;
        } else {
            float diff = max(dot(n, lightDir), 0.0);
            float fres = pow(1.0 - max(dot(-rd, n), 0.0), 3.0);
            
            float dummyMat, gD;
            map(p, dummyMat, gD);
            float isGlowNode = step(gD, 0.15);
            
            vec3 hullBase = vec3(0.01, 0.012, 0.018);
            vec3 glowColor = (mat > 1.5) ? vec3(0.0, 0.8, 1.0) * 10.0 : vec3(1.0, 0.15, 0.01) * 10.0;
            
            col = hullBase * (diff * 0.6 + 0.1) + fres * vec3(0.1, 0.4, 0.8);
            col = mix(col, glowColor, isGlowNode);
        }
    }
    
    col += vec3(0.0, 0.6, 1.0) * glowAcc * 0.06;
    col += vec3(1.0, 0.1, 0.01) * glowAcc * 0.04;
    
    float fog = 1.0 - exp(-d * 0.008);
    vec3 fogCol = vec3(0.001, 0.003, 0.01);
    col = mix(col, fogCol, fog);
    
    fragColor = vec4(col, d);
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    
    vec4 center = texture(iChannel0, uv);
    vec3 blur = vec3(0.0);
    
    float weights[5];
    weights[0] = 0.227027;
    weights[1] = 0.1945946;
    weights[2] = 0.1216216;
    weights[3] = 0.054054;
    weights[4] = 0.016216;
    
    blur += max(center.rgb - vec3(0.35), vec3(0.0)) * weights[0];
    
    for (int i = 1; i < 5; i++) {
        vec2 offset = vec2(texel.x * float(i) * 2.5, 0.0);
        vec3 c1 = texture(iChannel0, uv + offset).rgb;
        vec3 c2 = texture(iChannel0, uv - offset).rgb;
        blur += max(c1 - vec3(0.35), vec3(0.0)) * weights[i];
        blur += max(c2 - vec3(0.35), vec3(0.0)) * weights[i];
    }
    
    fragColor = vec4(center.rgb, length(blur));
}
