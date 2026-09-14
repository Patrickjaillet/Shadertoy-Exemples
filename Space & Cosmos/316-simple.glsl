// ==== Image (image) ====
// ==========================================================
// NAME : PROCEDURAL ROBOTIC JUMP
// ==========================================================
// DESCRIPTION : A full 3D character render using raymarching. 
// Features a procedural jumping robot with a 4-stage gait 
// cycle (thigh, knee, arm, elbow), blinking eyes, 
// soft shadows, and ambient occlusion.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#if HW_PERFORMANCE==0
#define AA 1
#else
#define AA 2
#endif

// --- SDF Primitives & Operators ---

// Smooth Minimum: Blends two shapes together organically.
// 
float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0);
    return min(a, b) - h * h * 0.25 / k;
}

vec4 opU(vec4 d1, vec4 d2) {
    return (d1.x < d2.x) ? d1 : d2;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdSphere(vec3 p, float s) {
    return length(p) - s;
}

// Capsule: Perfect for bones and robotic limbs.
float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// --- Environment Utilities ---

float hash(float n) { return fract(sin(n) * 43758.5453123); }

// Procedural Starfield for the deep space background.
vec3 stars(vec3 rd) {
    vec3 col = vec3(0.0);
    for (int i = 0; i < 4; i++) {
        float fl = float(i);
        vec3 p = rd * (100.0 + fl * 50.0);
        float s = hash(dot(floor(p), vec3(12.9898, 78.233, 45.164)));
        if (s > 0.98) {
            col += vec3(1.0) * smoothstep(0.98, 1.0, s) * (0.5 + 0.5 * sin(iTime * 5.0 + s * 10.0));
        }
    }
    return col * 0.5;
}

#define ZERO (min(iFrame,0))

// --- Scene Distance Function (The Robot) ---

vec4 map(vec3 pos, float atime) {
    // 1. GAIT PARAMETERS
    // 
    float walkSpeed = 5.0;
    float walkT = atime * walkSpeed;
    float bounce = 0.04 * abs(sin(walkT)); // Up/Down movement during walk
    
    // Robot center position (moving forward along Z)
    vec3 cen = vec3(0.0, 0.52 + bounce, atime * 0.8 - 1.0);
    vec3 q = pos - cen;
    
    // 2. TORSO
    vec3 torso = q;
    float dTorso = sdRoundBox(torso, vec3(0.2, 0.25, 0.15), 0.04);
    // Carve out a chest plug for detail
    vec3 chestPlug = torso - vec3(0.0, 0.05, 0.18);
    float dChest = sdBox(chestPlug, vec3(0.1, 0.1, 0.02));
    dTorso = max(dTorso, -dChest);

    vec4 res = vec4(dTorso, 2.0, 0.0, 1.0); // ID 2: Main Body Metal
    
    // 3. GROUND PLANE
    {
        float fh = -0.25;
        // Simple grid calculation for the floor
        float gx = abs(fract(pos.x * 3.0) - 0.5);
        float gz = abs(fract(pos.z * 3.0) - 0.5);
        float grid = min(gx, gz);
        float dGround = pos.y - fh;
        if (dGround < res.x) {
            res = vec4(dGround, 1.0, grid, 1.0); // ID 1: Floor
        }
    }
    
    // 4. HEAD & FACE
    {
        vec3 neck = q - vec3(0.0, 0.32, 0.0);
        float dNeck = sdCylinder(neck, 0.06, 0.05);
        res = opU(res, vec4(dNeck, 3.0, 0.0, 1.0)); // ID 3: Dark Joints

        vec3 head = q;
        head.y -= 0.45;
        float dHead = sdRoundBox(head, vec3(0.12, 0.12, 0.12), 0.03);
        
        // Jaw blending
        vec3 jaw = head - vec3(0.0, -0.06, 0.05);
        float dJaw = sdRoundBox(jaw, vec3(0.13, 0.05, 0.1), 0.02);
        dHead = smin(dHead, dJaw, 0.03);
        res = opU(res, vec4(dHead, 2.0, 0.0, 1.0));
        
        // Blinking Eyes
        vec3 eyeL = head - vec3(-0.06, 0.04, 0.14);
        vec3 eyeR = head - vec3(0.06, 0.04, 0.14);
        float dEyeL = sdSphere(eyeL, 0.03);
        float dEyeR = sdSphere(eyeR, 0.03);
        float blink = step(0.97, fract(atime * 0.7 + 0.3)); 
        float eyeD = min(dEyeL, dEyeR) - 0.003 * (1.0 - blink);
        res = opU(res, vec4(eyeD, 4.0, blink, 1.0)); // ID 4: Glowing Orange Eyes
        
        // Mouth and Ears
        vec3 mouth = head - vec3(0.0, -0.06, 0.15);
        float dMouth = sdBox(mouth, vec3(0.05, 0.015, 0.02));
        dMouth += sin(mouth.x * 200.0) * 0.002; // Teeth detail
        res = opU(res, vec4(dMouth, 3.0, 0.0, 1.0));

        vec3 ear = vec3(abs(head.x), head.yz) - vec3(0.15, 0.0, 0.0);
        float dEar = sdCylinder(ear.zyx, 0.02, 0.04);
        res = opU(res, vec4(dEar, 3.0, 0.0, 1.0));
    }
    
    // 5. ARMS (Hierarchical Rotation)
    {
        vec3 sqAbs = vec3(abs(q.x), q.yz); // Symmetric rendering
        float armPhase = walkT + sign(q.x) * 3.14159 + 3.14159;
        float armRot = sin(armPhase) * 0.6;
        float elbowRot = max(0.0, sin(armPhase)) * 0.8;

        vec3 shoulderPos = vec3(0.28, 0.22, 0.0);
        float dShoulder = sdSphere(sqAbs - shoulderPos, 0.08);
        res = opU(res, vec4(dShoulder, 3.0, 0.0, 1.0));

        // Upper arm calculation
        vec3 elbow = shoulderPos + vec3(0.0, -0.2 * cos(armRot), 0.2 * sin(armRot));
        float dArm = sdCapsule(sqAbs, shoulderPos, elbow, 0.045);
        res = opU(res, vec4(dArm, 2.0, 0.5, 1.0));

        float dElbowSphere = sdSphere(sqAbs - elbow, 0.05);
        res = opU(res, vec4(dElbowSphere, 3.0, 0.0, 1.0));

        // Lower arm (inherits shoulder rotation)
        float totalArmRot = armRot + elbowRot;
        vec3 wrist = elbow + vec3(0.0, -0.2 * cos(totalArmRot), 0.2 * sin(totalArmRot));
        float dForearm = sdCapsule(sqAbs, elbow, wrist, 0.04);
        res = opU(res, vec4(dForearm, 2.0, 0.5, 1.0));

        float dFist = sdSphere(sqAbs - wrist, 0.05);
        res = opU(res, vec4(dFist, 3.0, 0.0, 1.0));
    }
    
    // 6. LEGS (Hierarchical Rotation)
    {
        vec3 sqAbs = vec3(abs(q.x), q.yz);
        float legPhase = walkT + sign(q.x) * 3.14159;
        float thighRot = sin(legPhase) * 0.7;
        float kneeRot = -max(0.0, cos(legPhase)) * 1.4;

        vec3 hipPos = vec3(0.12, -0.2, 0.0);
        vec3 knee = hipPos + vec3(0.0, -0.25 * cos(thighRot), 0.25 * sin(thighRot));

        float dThigh = sdCapsule(sqAbs, hipPos, knee, 0.06);
        res = opU(res, vec4(dThigh, 2.0, 0.0, 1.0));

        float dKneeSphere = sdSphere(sqAbs - knee, 0.065);
        res = opU(res, vec4(dKneeSphere, 3.0, 0.0, 1.0));

        float totalLegRot = thighRot + kneeRot;
        vec3 ankle = knee + vec3(0.0, -0.25 * cos(totalLegRot), 0.25 * sin(totalLegRot));

        float dShin = sdCapsule(sqAbs, knee, ankle, 0.05);
        res = opU(res, vec4(dShin, 2.0, 0.0, 1.0));

        vec3 footPos = ankle + vec3(0.0, -0.04, 0.06);
        float dFoot = sdRoundBox(sqAbs - footPos, vec3(0.06, 0.03, 0.1), 0.02);
        res = opU(res, vec4(dFoot, 3.0, 0.0, 1.0));
    }
    
    return res;
}

// --- Rendering Engine ---

vec4 raycast(vec3 ro, vec3 rd, float time) {
    vec4 res = vec4(-1.0, -1.0, 0.0, 1.0);
    float tmin = 0.3, tmax = 25.0;
    
    // Ceiling optimization
    float tp = (4.0 - ro.y) / rd.y;
    if (tp > 0.0) tmax = min(tmax, tp);
    
    float t = tmin;
    for (int i = 0; i < 300 && t < tmax; i++) {
        vec4 h = map(ro + rd * t, time);
        if (abs(h.x) < 0.0006 * t) {
            res = vec4(t, h.yzw);
            break;
        }
        t += h.x;
    }
    return res;
}

// 
float calcSoftshadow(vec3 ro, vec3 rd, float time) {
    float res = 1.0, t = 0.02;
    for (int i = 0; i < 40; i++) {
        float h = map(ro + rd * t, time).x;
        res = min(res, 10.0 * h / t);
        t += clamp(h, 0.04, 0.3);
        if (res < 0.005 || t > 15.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

// Tetrahedron normal calculation for efficiency
vec3 calcNormal(vec3 pos, float time) {
    vec3 n = vec3(0.0);
    for (int i = ZERO; i < 4; i++) {
        vec3 e = 0.5773 * (2.0 * vec3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
        n += e * map(pos + 0.001 * e, time).x;
    }
    return normalize(n);
}

// Ambient Occlusion: Simulates light trapped in crevices.
float calcOcclusion(vec3 pos, vec3 nor, float time) {
    float occ = 0.0, sca = 1.0;
    for (int i = ZERO; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(pos + h * nor, time).x;
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 2.0 * occ, 0.0, 1.0);
}

// Material Palette: Maps ID to RGB colors.
vec3 paletteMetal(float t, float mat) {
    if (mat < 1.5) return vec3(0.2, 0.22, 0.25);      // Floor
    if (mat < 2.5) return vec3(0.65, 0.65, 0.68);    // Brushed Steel
    if (mat < 3.5) return vec3(0.15, 0.15, 0.15);    // Rubber Joints
    if (mat < 4.5) return vec3(0.9, 0.7, 0.1);       // Glowing Eyes
    return vec3(0.4, 0.4, 0.4);
}

// --- Main Pipeline ---

vec3 render(vec3 ro, vec3 rd, float time, vec2 fragCoord) {
    vec3 col = vec3(0.0, 0.02, 0.05) + stars(rd); // Initial sky + stars
    vec4 res = raycast(ro, rd, time);
    
    if (res.y > -0.5) {
        float t = res.x;
        vec3 pos = ro + t * rd;
        vec3 nor = calcNormal(pos, time);
        
        col = paletteMetal(res.z, res.y);
        
        // Floor grid detail
        if (res.y < 1.5) {
            float gv = res.z;
            float gridLine = 1.0 - smoothstep(0.0, 0.04, gv);
            col += gridLine * vec3(0.1);
        }
        
        float occ = calcOcclusion(pos, nor, time) * res.w;
        
        // 3-Point Lighting Setup
        // 
        vec3 sun_lig = normalize(vec3(0.6, 0.7, -0.5));
        float sun_dif = clamp(dot(nor, sun_lig), 0.0, 1.0);
        float sun_sha = calcSoftshadow(pos, sun_lig, time);
        
        vec3 fill_lig = normalize(vec3(-0.6, 0.2, 0.5));
        float fill_dif = clamp(dot(nor, fill_lig), 0.0, 1.0);
        
        vec3 back_lig = normalize(vec3(0.0, 0.4, 1.0));
        float back_dif = clamp(dot(nor, back_lig), 0.0, 1.0);
        
        vec3 lin = vec3(0.0);
        lin += sun_dif * vec3(1.0, 0.95, 0.9) * sun_sha * 1.5;
        lin += fill_dif * vec3(0.4, 0.45, 0.5) * occ * 0.8;
        lin += back_dif * vec3(0.3, 0.3, 0.3) * occ * 0.5;
        lin += occ * vec3(0.1, 0.1, 0.12); // Ambient term
        
        col = col * lin;
        
        // Emission for eyes
        if (res.y > 3.5 && res.y < 4.5) col += vec3(0.9, 0.7, 0.1) * 0.5;
        
        // Distance Fog
        col = mix(col, vec3(0.0, 0.02, 0.05), 1.0 - exp(-0.001 * t * t));
    }
    
    return max(col, vec3(0.0));
}

mat3 setCamera(vec3 ro, vec3 ta, float cr) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    return mat3(cu, cv, cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 tot = vec3(0.0);

#if AA > 1
    for (int m = ZERO; m < AA; m++)
    for (int n = ZERO; n < AA; n++) {
        vec2 o = vec2(float(m), float(n)) / float(AA) - 0.5;
        vec2 p = (-iResolution.xy + 2.0 * (fragCoord + o)) / iResolution.y;
        float time = iTime;
#else
        vec2 p = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;
        float time = iTime;
#endif

        time *= 0.5; // Overall animation speed

        // Camera Tracking: Smoothly circles the target path
        float an = 1.57 + 0.4 * sin(0.12 * time);
        vec3 ta = vec3(0.0, 0.3, time * 0.8);
        vec3 ro = ta + vec3(1.8 * cos(an), 0.2, 1.8 * sin(an));
        
        // Subtle camera jitter for a "handheld" feel
        ro.xy += 0.004 * vec2(sin(time * 47.3 + 1.1), sin(time * 39.7 + 0.3));

        mat3 ca = setCamera(ro, ta, 0.0);
        vec3 rd = ca * normalize(vec3(p, 2.0));

        vec3 col = render(ro, rd, time, fragCoord);
        col = pow(col, vec3(0.4545)); // Gamma Correction
        tot += col;
#if AA > 1
    }
    tot /= float(AA * AA);
#endif

    tot = clamp(tot, 0.0, 1.0);

    // Post-Process: Vignetting
    vec2 q = fragCoord / iResolution.xy;
    float vig = 0.5 + 0.5 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.25);
    tot *= vig;
    
    fragColor = vec4(tot, 1.0);
}
