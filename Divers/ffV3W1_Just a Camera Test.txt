// ==== Image (image) ====
/*
I'm working on software for camera paths and keyframe FX timelines in Cpp/ASM/Python/Rust/glsl Ouch!.
this shader is just a positioning test.
*/

/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù                       PATRICK JAILLET                        ù
ù - https://patrickjaillet.github.io/sandefjord-software       ù
ù - https://x.com/JailletPatrick                               ù
ù - https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/
#define MAX_STEPS 64
#define SURF_DIST 0.002
#define MAX_DIST 60.0

mat2 rot2D(float angle) {
    float s = sin(angle), c = cos(angle);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float map(vec3 p, float time) {
    float cycle = mod(time, 4.0);
    float impactTime = 1.2;
    
    float ground = p.y + 1.0;
    
    float pyrFull = (max(abs(p.x), abs(p.z)) + p.y * 0.8333 - 1.5) * 0.768;
    float pyrBase = max(pyrFull, p.y - 0.5);
    
    if (cycle < impactTime) {
        float fallProgress = cycle / impactTime;
        float easeFall = fallProgress * fallProgress;
        vec3 cubePos = vec3(0.0, mix(6.0, 0.9, easeFall), 0.0);
        vec3 q = p - cubePos;
        q.xz *= rot2D(cycle * 3.0);
        q.xy *= rot2D(cycle * 2.0);
        float mainCube = sdBox(q, vec3(0.4));
        return min(ground, min(pyrFull, mainCube));
    }
    
    float tExplode = cycle - impactTime;
    float scene = min(ground, pyrBase);
    
    float dDebris = 1e5;
    for (int i = 0; i < 48; i++) {
        vec3 rnd = hash31(float(i) * 17.13);
        vec3 dir = normalize(rnd * 2.0 - 1.0);
        
        bool isPyramidShard = (i >= 24);
        if (isPyramidShard) {
            dir.y = abs(dir.y) + 0.3;
        } else {
            dir.y = abs(dir.y) + 0.5;
        }
        
        float speed = (isPyramidShard ? 1.5 : 2.0) + rnd.x * 4.0;
        vec3 originPos = isPyramidShard ? vec3(0.0, 0.9, 0.0) : vec3(0.0, 1.1, 0.0);
        
        vec3 pos = originPos + dir * speed * tExplode;
        pos.y -= 4.9 * tExplode * tExplode;
        
        float pyrHeightAtPos = max(-1.0, 1.5 - (abs(pos.x) + abs(pos.z)) * 0.833);
        if (pos.y < pyrHeightAtPos) {
            pos.y = pyrHeightAtPos;
            vec3 slideDir = normalize(vec3(pos.x, -0.5, pos.z) + 0.001);
            pos += slideDir * (tExplode * 0.5);
        }
        
        vec3 q = p - pos;
        q.xz *= rot2D(tExplode * 5.0 + float(i));
        q.xy *= rot2D(tExplode * 3.0 + float(i));
        
        vec3 size = isPyramidShard ? vec3(0.04 + rnd.z * 0.06) : vec3(0.03 + rnd.z * 0.05);
        float shard = sdBox(q, size);
        dDebris = min(dDebris, shard);
    }
    
    return min(scene, dDebris);
}

vec3 calcNormal(vec3 p, float time) {
    vec2 e = vec2(0.004, 0.0);
    return normalize(vec3(
        map(p + e.xyy, time) - map(p - e.xyy, time),
        map(p + e.yxy, time) - map(p - e.yxy, time),
        map(p + e.yyx, time) - map(p - e.yyx, time)
    ));
}

float calcAO(vec3 p, vec3 n, float time) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 3; i++) {
        float h = 0.02 + 0.1 * float(i) / 2.0;
        float d = map(p + h * n, time);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 2.5 * occ, 0.0, 1.0);
}

float calcSoftShadow(vec3 ro, vec3 rd, float mint, float maxt, float k, float time) {
    float res = 1.0;
    float t = mint;
    for(int i = 0; i < 8; i++) {
        float h = map(ro + rd * t, time);
        res = min(res, k * h / t);
        t += clamp(h, 0.08, 0.3);
        if(res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

mat3 setCamera(vec3 ro, vec3 ta, float cr) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    return mat3(cu, cv, cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime;
    
    vec3 ro, ta; float roll, fov;
    getProceduralCamera(time, ro, ta, roll, fov);
    float bloomIntensity = eval_uBloom(time);
    
    mat3 ca = setCamera(ro, ta, roll);
    float focal = 1.0 / tan(radians(fov) * 0.5);
    vec3 rd = ca * normalize(vec3(uv, focal));
    
    float t = 0.0;
    float d = 0.0;
    vec3 p = ro;
    float glow = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        p = ro + rd * t;
        d = map(p, time);
        glow += 0.006 / (0.015 + abs(d));
        if(abs(d) < SURF_DIST || t > MAX_DIST) break;
        t += d * 0.9;
    }
    
    vec3 col = vec3(0.01, 0.015, 0.03);
    
    if(t < MAX_DIST) {
        vec3 n = calcNormal(p, time);
        vec3 lPos = vec3(8.0 * sin(time * 0.5), 12.0, 8.0 * cos(time * 0.5));
        vec3 lDir = normalize(lPos - p);
        
        float diff = max(dot(n, lDir), 0.0);
        float spec = pow(max(dot(reflect(-lDir, n), -rd), 0.0), 32.0);
        float ao = calcAO(p, n, time);
        float shadow = calcSoftShadow(p + n * 0.01, lDir, 0.02, 16.0, 12.0, time);
        
        vec3 albedo = mix(vec3(0.1, 0.4, 0.8), vec3(0.9, 0.3, 0.05), clamp(p.y * 0.5 + 0.5, 0.0, 1.0));
        vec3 ambient = vec3(0.02, 0.03, 0.05) * ao;
        vec3 direct = albedo * diff * vec3(1.0, 0.92, 0.8) * shadow;
        vec3 specular = vec3(1.0) * spec * shadow;
        
        col = ambient + direct + specular;
        col = mix(col, vec3(0.01, 0.015, 0.03), 1.0 - exp(-0.0003 * t * t * t));
    }
    
    vec3 bloomColor = vec3(0.2, 0.5, 1.0) * glow * 0.04 * bloomIntensity;
    col += bloomColor;
    
    col = vec3(1.0) - exp(-col * 1.6);
    col = pow(col, vec3(0.4545));
    
    vec2 q = fragCoord / iResolution.xy;
    col *= 0.5 + 0.5 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.25);
    
    fragColor = vec4(col, 1.0);
}

// ==== Common (common) ====
const float Camera_Position_TIMES[3] = float[3](.0, 5.0, 10.0);
const vec3 Camera_Position_VALUES[3] = vec3[3](vec3(.0, 3.0, 12.0), vec3(8.0, 5.0, .0), vec3(-8.0, 3.0, -12.0));

int Camera_Position_segment(float time) {
    int index = 0;
    index += int(step(Camera_Position_TIMES[1], time));
    index += int(step(Camera_Position_TIMES[2], time));
    return clamp(index - 1, 0, 1);
}

vec3 Camera_Position_basis(vec3 p0, vec3 p1, vec3 p2, vec3 p3, float t) {
    float t2 = t * t;
    float t3 = t2 * t;
    float w0 = -0.5 * t3 + t2 - 0.5 * t;
    float w1 = 1.5 * t3 - 2.5 * t2 + 1.0;
    float w2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
    float w3 = 0.5 * t3 - 0.5 * t2;
    return p0 * w0 + p1 * w1 + p2 * w2 + p3 * w3;
}

vec3 eval_Camera_Position(float time) {
    float remapped = mod(time, 10.0);
    int segment = Camera_Position_segment(remapped);
    int prev = clamp(segment - 1, 0, 2);
    int next = clamp(segment + 1, 0, 2);
    int nextNext = clamp(segment + 2, 0, 2);
    float t = (remapped - Camera_Position_TIMES[segment]) / max(Camera_Position_TIMES[next] - Camera_Position_TIMES[segment], 1.0e-6);
    return Camera_Position_basis(Camera_Position_VALUES[prev], Camera_Position_VALUES[segment], Camera_Position_VALUES[next], Camera_Position_VALUES[nextNext], clamp(t, 0.0, 1.0));
}

const float Camera_Target_TIMES[2] = float[2](.0, 10.0);
const vec3 Camera_Target_VALUES[2] = vec3[2](vec3(.0, .0, .0), vec3(1.0, .5, .0));

int Camera_Target_segment(float time) {
    int index = 0;
    index += int(step(Camera_Target_TIMES[1], time));
    return clamp(index - 1, 0, 0);
}

vec3 Camera_Target_basis(vec3 p0, vec3 p1, vec3 p2, vec3 p3, float t) {
    float t2 = t * t;
    float t3 = t2 * t;
    float w0 = -0.5 * t3 + t2 - 0.5 * t;
    float w1 = 1.5 * t3 - 2.5 * t2 + 1.0;
    float w2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
    float w3 = 0.5 * t3 - 0.5 * t2;
    return p0 * w0 + p1 * w1 + p2 * w2 + p3 * w3;
}

vec3 eval_Camera_Target(float time) {
    float remapped = mod(time, 10.0);
    int segment = Camera_Target_segment(remapped);
    int prev = clamp(segment - 1, 0, 1);
    int next = clamp(segment + 1, 0, 1);
    int nextNext = clamp(segment + 2, 0, 1);
    float t = (remapped - Camera_Target_TIMES[segment]) / max(Camera_Target_TIMES[next] - Camera_Target_TIMES[segment], 1.0e-6);
    return Camera_Target_basis(Camera_Target_VALUES[prev], Camera_Target_VALUES[segment], Camera_Target_VALUES[next], Camera_Target_VALUES[nextNext], clamp(t, 0.0, 1.0));
}

const float Field_of_View_TIMES[3] = float[3](.0, 5.0, 10.0);
const float Field_of_View_VALUES[3] = float[3](50.0, 60.0, 50.0);

int Field_of_View_segment(float time) {
    int index = 0;
    index += int(step(Field_of_View_TIMES[1], time));
    index += int(step(Field_of_View_TIMES[2], time));
    return clamp(index - 1, 0, 1);
}

float eval_Field_of_View(float time) {
    float remapped = mod(time, 10.0);
    int segment = Field_of_View_segment(remapped);
    int next = clamp(segment + 1, 0, 2);
    float t = (remapped - Field_of_View_TIMES[segment]) / max(Field_of_View_TIMES[next] - Field_of_View_TIMES[segment], 1.0e-6);
    return mix(Field_of_View_VALUES[segment], Field_of_View_VALUES[next], clamp(t, 0.0, 1.0));
}

const float uBloom_TIMES[3] = float[3](.0, 3.0, 7.0);
const float uBloom_VALUES[3] = float[3](.0, 1.0, .5);

int uBloom_segment(float time) {
    int index = 0;
    index += int(step(uBloom_TIMES[1], time));
    index += int(step(uBloom_TIMES[2], time));
    return clamp(index - 1, 0, 1);
}

float eval_uBloom(float time) {
    float remapped = mod(time, 10.0);
    int segment = uBloom_segment(remapped);
    int next = clamp(segment + 1, 0, 2);
    float t = (remapped - uBloom_TIMES[segment]) / max(uBloom_TIMES[next] - uBloom_TIMES[segment], 1.0e-6);
    return mix(uBloom_VALUES[segment], uBloom_VALUES[next], clamp(t, 0.0, 1.0));
}

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 hash31(float p) {
   vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
   p3 += dot(p3, p3.yzx + 33.33);
   return fract((p3.xxy + p3.yzz) * p3.zyx);
}

float getCinematicTime(float rawTime) {
    return rawTime + 0.8 * sin(rawTime * 0.4) + 0.4 * cos(rawTime * 0.9);
}

void getProceduralCamera(float rawTime, out vec3 ro, out vec3 ta, out float roll, out float fov) {
    float cTime = getCinematicTime(rawTime);
    
    float t1 = cTime * 0.25;
    float t2 = cTime * 0.15;
    float t3 = cTime * 0.35;
    
    vec3 p1 = vec3(cos(t1) * 12.0, 4.0 + sin(t2 * 1.5) * 2.0, sin(t1) * 12.0);
    vec3 t1_target = vec3(0.0, 0.5, 0.0);
    
    vec3 p2 = vec3(sin(t2 * 2.0) * 10.0, 2.5 + cos(t1) * 2.0, cos(t2 * 1.5) * 10.0);
    vec3 t2_target = vec3(0.0, 0.2, 0.0);
    
    vec3 p3 = vec3(sin(t3) * 8.5, 6.0 + sin(t1) * 2.5, cos(t3) * 8.5);
    vec3 t3_target = vec3(0.0, 0.0, 0.0);
    
    float blend1 = sin(cTime * 0.2) * 0.5 + 0.5;
    float blend2 = cos(cTime * 0.13) * 0.5 + 0.5;
    
    vec3 procRo = mix(mix(p1, p2, blend1), p3, blend2);
    vec3 procTa = mix(mix(t1_target, t2_target, blend1), t3_target, blend2);
    
    roll = sin(cTime * 0.3) * 0.1 * blend1;
    fov = 45.0 + sin(cTime * 0.25) * 5.0;
    
    vec3 baseTrackRo = eval_Camera_Position(cTime);
    vec3 baseTrackTa = eval_Camera_Target(cTime);
    float trackFov = eval_Field_of_View(cTime);
    
    float modeBlend = sin(cTime * 0.08) * 0.5 + 0.5;
    ro = mix(procRo, baseTrackRo, modeBlend);
    ta = mix(procTa, baseTrackTa, modeBlend);
    fov = mix(fov, trackFov, modeBlend);
}

float getFOV(float time) {
    vec3 ro, ta; float roll, fov;
    getProceduralCamera(time, ro, ta, roll, fov);
    return fov;
}

vec3 getCameraPosition(float time) {
    vec3 ro, ta; float roll, fov;
    getProceduralCamera(time, ro, ta, roll, fov);
    return ro;
}

float getAudioEnvelope(float time) {
    return 0.5 + 0.5 * sin(time * 3.14159 * 2.0);
}

float getTrigger(int index, float time) {
    float t = mod(time, 10.0);
    if (index == 0) return smoothstep(0.0, 0.2, sin(t * 12.566));
    if (index == 1) return step(5.0, t);
    return 0.0;
}

vec4 evaluateTimeline(float time) {
    vec3 ro, ta; float roll, fov;
    getProceduralCamera(time, ro, ta, roll, fov);
    return vec4(ro, fov);
}
