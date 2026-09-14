// ==== Image (image) ====
#define S(a,b,t) smoothstep(a,b,t)
#define rot(a) mat2(cos(a+vec4(0,11,33,0)))

const vec3 L = normalize(vec3(5.0, 10.0, -5.0));
const vec3 MAT_STEEL = vec3(0.5, 0.52, 0.55); 
const vec3 MAT_CROOT = vec3(0.12, 0.14, 0.1);
const vec3 LASER_RED = vec3(1.2, 0.1, 0.02);
const vec3 LASER_BLUE = vec3(0.05, 0.4, 1.5);

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float sdCyl(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdSph(vec3 p, float r) { return length(p) - r; }

float sdSegment(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p-a, ba = b-a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return length(pa-ba*h);
}

vec2 computeFootPath(float phase) {
    float z = -cos(phase) * 3.5; 
    float y = max(0.0, sin(phase) * 1.8);
    if(y <= 0.0) z = clamp(z, -3.5, 3.5); 
    return vec2(y, z);
}

struct MechState {
    vec3 bodyPos;
    vec3 footL;
    vec3 footR;
    float impact;
    float firePulse;
    float blueFire;
    vec3 launcherPos;
    vec3 bLDir;
    float headYaw;
    float worldZ;
    float armPhase;
};

MechState getMechState(float time) {
    MechState s;
    float walkSpeed = 2.5;
    float speed = time * walkSpeed;
    s.worldZ = speed * 1.4; 
    s.armPhase = speed;
    
    vec2 fL = computeFootPath(speed);
    vec2 fR = computeFootPath(speed + 3.14159);
    
    s.footL = vec3(2.5, fL.x - 1.2, fL.y);
    s.footR = vec3(-2.5, fR.x - 1.2, fR.y);
    
    float bodyY = 5.0 + (fL.x + fR.x) * 0.15;
    s.bodyPos = vec3(0.0, bodyY, 0.0);
    
    s.impact = S(0.1, 0.0, fL.x) + S(0.1, 0.0, fR.x);
    s.firePulse = S(0.1, 0.0, abs(sin(time * 1.25)));
    float rnd = hash11(floor(time * 12.0));
    s.blueFire = S(0.75, 0.85, rnd) * (0.8 + 0.2 * sin(time * 120.0));
    s.launcherPos = s.bodyPos + vec3(0.0, 2.0, 0.0);
    s.headYaw = sin(time * 0.8) * 0.7;
    
    vec3 baseDir = vec3(0.0, 0.3 + 0.15*cos(time*0.8), 1.0);
    baseDir.xz *= rot(s.headYaw);
    s.bLDir = normalize(baseDir);
    return s;
}

float mID = 0.0;
float map(vec3 p, MechState ms) {
    mID = 0.0;
    float d = 1e5;
    
    vec3 q = p - ms.bodyPos;
    q.xy *= rot(sin(iTime*2.5)*0.05);
    float chassis = sdBox(q, vec3(2.2, 1.6, 2.5), 0.4);
    float reactor = sdCyl(q.xzy - vec3(0.0, -2.0, 1.0), 1.0, 0.8);
    chassis = min(chassis, reactor);
    
    vec3 lq = p - ms.launcherPos;
    lq.xy *= rot(sin(iTime*2.5)*0.05);
    float lBase = sdBox(lq - vec3(0.0, 0.4, 0.0), vec3(0.8, 0.3, 0.8), 0.1);
    vec3 tq = lq - vec3(0.0, 1.0, 0.0);
    tq.xz *= rot(ms.headYaw);
    tq.yx *= rot(sin(iTime*0.5));
    float turret = sdBox(tq, vec3(1.2, 0.5, 1.5), 0.1);
    for(int i=-1; i<=1; i+=2) {
        float fi = float(i);
        float tube = sdCyl((tq - vec3(0.6*fi, 0.0, 1.0)).xzy, 0.8, 0.25);
        turret = min(turret, tube);
    }
    float launcher = min(lBase, turret);
    chassis = min(chassis, launcher);
    if(chassis < d) { d = chassis; mID = 1.0; }
    
    for(int i=-1; i<=1; i+=2) {
        float fi = float(i);
        vec3 hPos = ms.bodyPos + vec3(2.6 * fi, 0.5, 0.5);
        float sw = sin(ms.armPhase + (fi > 0.0 ? 3.14159 : 0.0));
        vec3 shoulderP = p - hPos;
        float shoulder = sdSph(shoulderP, 0.7);
        
        vec3 elbowPos = hPos + vec3(0.8 * fi, -1.8, sw * 1.2 - 0.5);
        float upperArm = sdSegment(p, hPos, elbowPos) - 0.35;
        
        vec3 handPos = elbowPos + vec3(0.2 * fi, -0.2, 1.5 + sw * 0.5);
        float lowerArm = sdSegment(p, elbowPos, handPos) - 0.3;
        float hand = sdBox(p - handPos, vec3(0.4, 0.5, 0.6), 0.1);
        
        float arm = min(min(shoulder, upperArm), min(lowerArm, hand));
        if(arm < d) { d = arm; mID = 2.0; }
    }
    
    for(int i=-1; i<=1; i+=2) {
        float fi = float(i);
        vec3 fPos = (fi > 0.0) ? ms.footL : ms.footR;
        vec3 hPos = ms.bodyPos + vec3(2.1*fi, -1.2, 0.0);
        vec3 dir = fPos - hPos;
        vec3 kneePos = hPos + dir*0.5 + vec3(0.5*fi, 0.5, 1.0);
        
        float thighLen = length(kneePos - hPos);
        vec3 thighP = p - (hPos + normalize(kneePos - hPos) * (thighLen * 0.5));
        float thigh = sdBox(thighP, vec3(0.6, thighLen*0.5, 0.9), 0.1);
        if(thigh < d) { d = thigh; mID = 2.0; }
        
        vec3 kneeP = p - kneePos;
        float knee = min(sdSph(kneeP, 0.5), sdBox(kneeP - vec3(0.0, 0.0, 0.3), vec3(0.6, 0.4, 0.2), 0.1));
        if(knee < d) { d = knee; mID = 2.0; }
        
        float tibiaLen = length(fPos - kneePos);
        vec3 tibiaP = p - (kneePos + normalize(fPos - kneePos) * (tibiaLen * 0.5));
        float tibia = min(sdBox(tibiaP - vec3(0.0, 0.0, 0.2), vec3(0.7, tibiaLen*0.5, 0.6), 0.15), sdCyl(tibiaP - vec3(0.0, 0.0, -0.4), tibiaLen*0.45, 0.2));
        if(tibia < d) { d = tibia; mID = 2.0; }
        
        vec3 footP = p - fPos;
        float foot = min(sdBox(footP - vec3(0.0, -0.2, 0.0), vec3(1.2, 0.4, 1.8), 0.1), sdBox(footP - vec3(0.0, -0.2, 1.5), vec3(0.8, 0.2, 0.5), 0.05));
        if(foot < d) { d = foot; mID = 2.0; }
    }
    
    float ripple = sin(length(p.xz - ms.footL.xz)*3.0 - iTime*12.0) * 0.04 * exp(-length(p.xz - ms.footL.xz)*0.4) * S(0.1, 0.0, ms.footL.y + 1.2);
    ripple += sin(length(p.xz - ms.footR.xz)*3.0 - iTime*12.0) * 0.04 * exp(-length(p.xz - ms.footR.xz)*0.4) * S(0.1, 0.0, ms.footR.y + 1.2);
    
    float floorD = p.y + 1.2 + ripple; 
    if(floorD < d) { d = floorD; mID = 3.0; }
    return d;
}

vec3 getNormal(vec3 p, MechState ms) {
    vec2 e = vec2(0.002, 0.0);
    return normalize(vec3(map(p+e.xyy, ms)-map(p-e.xyy, ms), map(p+e.yxy, ms)-map(p-e.yxy, ms), map(p+e.yyx, ms)-map(p-e.yyx, ms)));
}

vec3 getEnv(vec3 rd) {
    return texture(iChannel3, vec2(atan(rd.z, rd.x) * 0.1591, acos(rd.y) * 0.3183)).rgb;
}

vec3 triplanar(sampler2D tex, vec3 p, vec3 n, float zOff) {
    vec3 tp = p;
    tp.z += zOff;
    vec3 m = pow(abs(n), vec3(10.0));
    vec3 v = (texture(tex, tp.yz * 0.2).rgb * m.x + texture(tex, tp.xz * 0.2).rgb * m.y + texture(tex, tp.xy * 0.2).rgb * m.z) / (m.x + m.y + m.z);
    return v;
}

vec3 renderLaserBeam(vec3 ro, vec3 rd, vec3 lp, vec3 ld, vec3 col, float power, float tMax) {
    float d = sdSegment(ro + rd * clamp(tMax, 0.0, 100.0), lp, lp + ld * 100.0);
    vec3 beam = col * (0.02 / (d + 0.015)) + col * exp(-d * 6.0) * 1.5 + vec3(1.0) * exp(-d * 80.0) * 4.0;
    return beam * power;
}

void mainImage( out vec4 o, in vec2 u ) {
    vec2 uv = (u - 0.5*iResolution.xy)/iResolution.y;
    vec3 ro = vec3(24.0*cos(iTime*0.1), 10.0, 24.0*sin(iTime*0.1));
    vec3 ta = vec3(0.0, 4.0, 0.0);
    vec3 cw = normalize(ta-ro), cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0))), cv = cross(cu,cw);
    vec3 rd = normalize(uv.x*cu + uv.y*cv + 1.8*cw);
    
    MechState ms = getMechState(iTime);
    float t=0.0, d;
    for(int i=0; i<160; i++) {
        d = map(ro + rd*t, ms);
        if(abs(d)<0.001 || t>100.0) break;
        t += d;
    }

    vec3 sky = getEnv(rd);
    vec3 col = sky * 0.25;
    
    if(t < 100.0) {
        vec3 p = ro + rd*t;
        vec3 n = getNormal(p, ms);
        vec3 r = reflect(rd, n);
        vec3 alb = MAT_STEEL;
        float spec = 60.0;
        
        if(mID < 1.5) alb = mix(MAT_CROOT, triplanar(iChannel1, p, n, 0.0), 0.4);
        else if(mID < 2.5) alb = mix(MAT_STEEL, triplanar(iChannel0, p, n, 0.0), 0.5);
        else {
            alb = mix(vec3(0.01, 0.02, 0.04), getEnv(r), 0.8);
            alb *= triplanar(iChannel0, p, n, ms.worldZ).r * 1.5; 
            spec = 200.0;
        }
        
        float ao = clamp(map(p + n*0.5, ms)/0.5, 0.0, 1.0);
        float diff = max(dot(n, L), 0.0);
        float sp = pow(max(dot(r, L), 0.0), spec);
        
        col = alb * (diff + 0.05) * ao;
        col += sp * 0.8 * ao;
        
        vec3 airS = ms.bodyPos + vec3(0.0, 2.6, -0.5); 
        vec3 gndS = ms.bodyPos + vec3(0.0, 0.6, 3.2);
        col += LASER_RED * ms.firePulse * (0.8 / (length(p - airS) + 0.5) + 0.8 / (length(p - gndS) + 0.5)) * ao;
        
        for(int i=-1; i<=1; i+=2) {
            vec3 eyeOff = vec3(0.6*float(i), 1.0, 2.2);
            eyeOff.xz *= rot(ms.headYaw); 
            vec3 bLEye = ms.launcherPos + eyeOff;
            float lAtt = 1.0 / (length(p - bLEye)*0.2 + 1.0);
            col += LASER_BLUE * ms.blueFire * lAtt * max(0.0, dot(n, normalize(bLEye - p))) * 2.0;
        }
    }

    float tLim = (t > 99.0) ? 100.0 : t;
    col += renderLaserBeam(ro, rd, ms.bodyPos + vec3(0.0, 2.6, -0.5), normalize(vec3(0.2*sin(iTime), 1.0, -0.1)), LASER_RED, ms.firePulse, tLim);
    col += renderLaserBeam(ro, rd, ms.bodyPos + vec3(0.0, 0.6, 3.2), normalize(vec3(0.4*sin(iTime*4.0), -0.5, 1.0)), LASER_RED, ms.firePulse, tLim);
    
    for(int i=-1; i<=1; i+=2) {
        vec3 eyeOff = vec3(0.6*float(i), 1.0, 2.2);
        eyeOff.xz *= rot(ms.headYaw); 
        col += renderLaserBeam(ro, rd, ms.launcherPos + eyeOff, ms.bLDir, LASER_BLUE, ms.blueFire, tLim);
    }

    col = mix(col, sky * 0.2, 1.0-exp(-0.0001*tLim*tLim));
    col = smoothstep(0.0, 1.1, col * 1.3);
    o = vec4(pow(col, vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
vec2 mainSound(int samp, float time) {
    float walkSpeed = 2.5;
    float speed = time * walkSpeed;
    
    float turbine = sin(time * 314.159 + sin(time * 157.07) * 0.5);
    turbine += sin(time * 628.318) * 0.3;
    turbine *= 0.04 + 0.01 * sin(time * 0.2);
    
    float gearPhase = time * 15.0;
    float gears = fract(sin(floor(gearPhase) * 123.456) * 789.012);
    gears *= exp(-3.0 * fract(gearPhase)) * 0.02;
    
    float velocity = abs(cos(speed));
    float jointFriction = fract(sin(time * 15000.0)) * velocity * 0.015;
    
    float hum = sin(time * 50.0) * 0.03;
    hum += sin(time * 100.0 + turbine * 10.0) * 0.01;
    
    float n = fract(sin(time * 43758.5453));
    float hiss = (n - 0.5) * 0.005;
    
    float core = turbine + gears + jointFriction + hum + hiss;
    
    float firePulse = smoothstep(0.1, 0.0, abs(sin(time * 1.25)));
    float plasma = sin(time * 800.0 + sin(time * 2500.0) * 5.0) * firePulse * 0.07;
    
    float phaseL = mod(speed, 6.28318);
    float phaseR = mod(speed + 3.14159, 6.28318);
    float impact = (exp(-15.0 * fract(phaseL/6.28318)) + exp(-15.0 * fract(phaseR/6.28318))) * 0.4;
    float lowThump = sin(40.0 * exp(-6.0 * fract(speed/3.14159)) * 10.0) * impact;

    float left = core + plasma + lowThump + (gears * 0.5);
    float right = core - plasma + lowThump - (gears * 0.5);

    return vec2(left, right) * clamp(time * 0.5, 0.0, 1.0) * 0.7;
}
