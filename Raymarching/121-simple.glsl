// ==== Image (image) ====
#define MAX_STEPS 200
#define SURF_DIST 0.001
#define MAX_DIST 20.
#define MAT_PLATE 1.
#define MAT_CAKE 2.
#define MAT_CREAM 3.

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdRoundCylinder(vec3 p, float h, float r, float round) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - round;
}

vec2 Scene(vec3 p, vec3 plateRot) {
    p.yz *= Rot(plateRot.x);
    p.xy *= Rot(plateRot.z);
    
    // Plate
    vec3 pPlate = p;
    pPlate.y += 0.05;
    float dPlateOuter = sdCylinder(pPlate, 0.025, 1.25);
    float dPlateInner = sdCylinder(pPlate + vec3(0., -0.015, 0.), 0.03, 1.08);
    float dPlate = max(dPlateOuter, -dPlateInner);
    
    // Soft gelatinous wobble
    float tilt = length(plateRot.xz);
    float wobble = tilt * 1.4;
    float t = iTime * 5.5;
    
    // Bottom sponge
    vec3 pCake = p;
    pCake.y -= 0.20;
    float hFactor = smoothstep(0.0, 0.4, pCake.y + 0.22);
    pCake.xz += sin(pCake.y * 10.0 + t) * wobble * 0.028 * hFactor;
    pCake.xz += cos(pCake.y * 7.5 + t * 1.2) * wobble * 0.022 * hFactor;
    float dCake = sdRoundCylinder(pCake, 0.20, 0.52, 0.04);
    
    // Cream
    vec3 pCream = p;
    pCream.y -= 0.42;
    pCream.xz += sin(pCream.y * 12.0 + t + 0.8) * wobble * 0.035;
    pCream.xz += cos(pCream.y * 9.0 + t * 1.1) * wobble * 0.025;
    float dCream = sdRoundCylinder(pCream, 0.035, 0.50, 0.02);
    
    // Top sponge
    vec3 pTop = p;
    pTop.y -= 0.52;
    pTop.xz += sin(pTop.y * 9.0 + t + 1.6) * wobble * 0.04;
    pTop.xz += cos(pTop.y * 6.5 + t * 0.9) * wobble * 0.03;
    float dTop = sdRoundCylinder(pTop, 0.11, 0.52, 0.04);
    
    float d = dPlate;
    float mat = MAT_PLATE;
    if (dCake < d) { d = dCake; mat = MAT_CAKE; }
    if (dCream < d) { d = dCream; mat = MAT_CREAM; }
    if (dTop < d) { d = dTop; mat = MAT_CAKE; }
    
    return vec2(d, mat);
}

vec2 RayMarch(vec3 ro, vec3 rd, vec3 plateRot) {
    float dO = 0.0;
    float mat = -1.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        vec2 res = Scene(p, plateRot);
        float dS = res.x;
        mat = res.y;
        dO += dS * 0.55;
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
    }
    return vec2(dO, mat);
}

vec3 GetNormal(vec3 p, vec3 plateRot) {
    float d = Scene(p, plateRot).x;
    vec2 e = vec2(0.001, 0);
    vec3 n = d - vec3(
        Scene(p - e.xyy, plateRot).x,
        Scene(p - e.yxy, plateRot).x,
        Scene(p - e.yyx, plateRot).x
    );
    return normalize(n);
}

vec3 GetEnvironment(vec3 rd) {
    float sky = smoothstep(-0.1, 0.55, rd.y);
    vec3 skyColor = mix(vec3(0.12, 0.14, 0.18), vec3(0.62, 0.72, 0.88), sky);
    
    vec3 sunDir = normalize(vec3(2.2, 3.8, -1.8));
    float sun = pow(max(dot(rd, sunDir), 0.0), 28.0);
    vec3 sunColor = vec3(1.0, 0.96, 0.88) * sun * 1.8;
    
    vec3 windowLight = vec3(0.0);
    if (rd.z > 0.0) {
        windowLight = vec3(0.75, 0.85, 0.98) * pow(clamp(rd.z, 0.0, 1.0), 3.5) * 0.7;
    }
    
    return skyColor + sunColor + windowLight;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec2 m = iMouse.xy / iResolution.xy;
    if(iMouse.z <= 0.) m = vec2(0.5, 0.5);
    
    vec3 plateRot = vec3((m.y - 0.5) * 0.75, 0., (m.x - 0.5) * -0.75);
    
    vec3 ro = vec3(0, 2.15, -3.4);
    vec3 lk = vec3(0, 0.1, 0);
    vec3 f = normalize(lk - ro);
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f * 1.5 + uv.x * r + uv.y * u);
    
    vec2 res = RayMarch(ro, rd, plateRot);
    float d = res.x;
    float mat = res.y;
    
    vec3 col = GetEnvironment(rd);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p, plateRot);
        vec3 rDir = reflect(rd, n);
        
        vec3 lPos = vec3(2.2, 3.8, -1.8);
        vec3 lDir = normalize(lPos - p);
        float dif = clamp(dot(n, lDir), 0.12, 1.0);
        float amb = 0.18;
        
        if (mat == MAT_PLATE) {
            vec3 plateBase = vec3(0.96, 0.96, 0.94);
            vec3 envRefl = GetEnvironment(rDir);
            col = mix(plateBase * (dif * 0.85 + amb), envRefl, 0.18);
            float spec = pow(clamp(dot(rDir, lDir), 0., 1.), 40.);
            col += vec3(1.0) * spec * 0.45;
        }
        else if (mat == MAT_CAKE) {
            // Soft sponge look
            vec3 cakeCol = vec3(0.93, 0.80, 0.58);
            float ao = 0.75 + 0.25 * n.y;
            col = cakeCol * (dif * 0.9 + amb) * ao;
            float spec = pow(clamp(dot(rDir, lDir), 0., 1.), 12.);
            col += vec3(1.0, 0.95, 0.85) * spec * 0.08;
        }
        else if (mat == MAT_CREAM) {
            vec3 creamCol = vec3(0.99, 0.97, 0.94);
            col = creamCol * (dif * 0.95 + amb);
            float spec = pow(clamp(dot(rDir, lDir), 0., 1.), 80.);
            col += vec3(1.0) * spec * 0.35;
            // subtle subsurface
            col += creamCol * 0.08 * (1.0 - dif);
        }
    }
    
    col = pow(col, vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
