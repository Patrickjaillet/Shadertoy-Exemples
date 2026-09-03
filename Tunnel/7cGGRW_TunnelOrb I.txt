// ==== Image (image) ====
const vec3 RAY_PARAMS = vec3(129, 0.003, 356);
const vec3 LIGHT_BASE = vec3(0.15, 0.10, 0.0);
const vec2 LOOP_PARAMS = vec2(-15, 25);

mat2 rot(float a) {
    vec2 s = sin(vec2(a, a + 1.5708));
    return mat2(s.y, -s.x, s.x, s.y);
}

float hash12(vec2 p) {
    vec3 p3 = fract(p.xyx * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float sStep(float x) {
    return x * x * x * (x * (x * 6. - 15.0) + 10.0);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 sf = vec2(sStep(f.x), sStep(f.y));
    return mix(mix(hash12(i), hash12(i+vec2(1,0)), sf.x),
               mix(hash12(i+vec2(0,1)), hash12(i+vec2(1,1)), sf.x), sf.y);
}

float fbmFastSeamless(vec2 p) {
    float val = (noise(p) * 2.0 - 1.0); p *= 2.1;
    val += 0.5 * (noise(p) * 2.0 - 1.0); p *= 2.1;
    val += 0.25 * (noise(p) * 2.0 - 1.0);
    return val;
}

struct Motion { float t, look, tilt; };

Motion getCinematicSequence(float time) {
    float phase = mod(time, LOOP_PARAMS.x) / LOOP_PARAMS.x;
    float t_p, look = 0., tilt = 0., p;
    
    if (phase < .25) {
        t_p = mix(0., 12., sStep(phase / .25));
    } else if (phase < .625) {
        p = (phase - .25) / .375;
        t_p = 12.;
        float s = sStep(p);
        look = sin(s * 6.2831) * 1.3;
        tilt = cos(s * 6.2831) * 0.4;
        float fade = smoothstep(0., .1, p) * smoothstep(1., .9, p);
        look *= fade; tilt *= fade;
    } else {
        t_p = mix(12., LOOP_PARAMS.y, sStep((phase - .625) / .375));
    }
    return Motion(floor(time / LOOP_PARAMS.x) * LOOP_PARAMS.y + t_p, look, tilt);
}

vec3 getPath(float z) {
    return vec3(sin(z * .12) * 7. + cos(z * .05) * 2., cos(z * .11) * 4. + sin(z * .08) * 3., z);
}

vec3 getOrbPos() {
    Motion m = getCinematicSequence(iTime);
    return getPath(m.t + 16.1 + sin(iTime * 2.) * 2.);
}

float map(vec3 p) {
    vec3 q = p;
    q.xy -= getPath(q.z).xy;
    q.xy *= rot(q.z * .04 + iTime * .05);
    
    float r = length(q.xy);
    if (r > 16.0) return r - 12.0;

    vec2 dir = q.xy / max(r, 0.0001);
    
    float nBase = fbmFastSeamless(vec2((dir.x + 1.0) * 1.2, q.z * 0.12));
    float nVein = (noise(vec2((dir.y + 1.0) * 3.0, q.z * 0.8)) * 2.0 - 1.0);
    float nBulge = fbmFastSeamless(vec2((dir.x - dir.y) * 1.5, q.z * 0.2));
    
    float baseR = 7.0;
    float R = baseR + nBase * 3.5 + nVein * 0.3;
    
    float d = (abs(r - R) - 1.00) * 1.00;
    
    float ringSpacing = 4.5;
    float zOff = mod(q.z + ringSpacing * 0.5, ringSpacing) - ringSpacing * 0.5;
    float ringR = 5.2 + noise(vec2(dir.x * 5.4 + -2.8, floor(q.z / ringSpacing))) * 2.0;
    float ringDist = length(vec2(r - ringR, zOff)) - 0.13;
    d = min(d, ringDist * 0.65);
    
    float bulge = smoothstep(0.0, 0.0, abs(nBulge - 1.0)) * 1.0;
    float bulgeDist = abs(r - (R - bulge)) - 0.0;
    d = min(d, bulgeDist * 0.65);
    
    return min(d, length(p - getOrbPos()) - .9);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(.008, 0);
    float d = map(p);
    return normalize(vec3(map(p + e.xyy) - d,
                          map(p + e.yxy) - d,
                          map(p + e.yyx) - d));
}

vec3 envColor(vec3 dir) {
    float y = dir.y * 0.5 + 0.5;
    return mix(vec3(1.0, 0.1, 1.0), vec3(0.8, 0.1, 1.0), y);
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    Motion m = getCinematicSequence(iTime);
    vec3 ro = getPath(m.t), 
         tar = getPath(m.t + 5.),
         cw = normalize(tar - ro),
         ri = normalize(cross(cw, vec3(0, 1, 0))),
         up = cross(ri, cw);
    
    cw = normalize(cw + ri * m.look + up * m.tilt);
    
    vec3 cu = normalize(cross(cw, vec3(0, 1, 0))), 
         cv = cross(cu, cw), 
         rd = normalize(uv.x * cu + uv.y * cv + cw * (0.6 - abs(m.look) * 0.0)),
         oP = getOrbPos(), col = vec3(0);
    float t = 0., d = 0., v = 0.;
    
    for (int i = 0; i < 30; i++) {
        vec3 p = ro + rd * t;
        float dO = length(p - oP);
        if (dO < 12.0) {
            v += exp(-dO * 0.45);
        }
        d = map(p);
        if (d < RAY_PARAMS.y || t > RAY_PARAMS.z) break;
        t += d;
    }
    v *= 0.36;
    
    if (t < RAY_PARAMS.z) {
        vec3 p = ro + rd * t, n = getNormal(p), r = reflect(rd, n);
        float dO = length(p - oP);
        if (dO < 1.) col = LIGHT_BASE * 15.;
        else {
            float fr = pow(1.0 + dot(rd, n), 5.), at = 47.4 / (1.0 + dO * dO * 0.6);
            vec3 reflCol = envColor(r);
            col = mix(vec3(.02), reflCol, fr * 0.3)
                  + LIGHT_BASE * (max(dot(n, normalize(oP - p)), 0.) * 1.0 
                  + pow(max(dot(r, normalize(oP - p)), 0.), 64.0) * 13.4) * at;
            col *= smoothstep(RAY_PARAMS.z, 0., t);
        }
    }
    
    col = mix(col + LIGHT_BASE * v * (.85 + .15 * hash12(fragCoord + iTime)), 
              vec3(.01, -0.00, 0.00), 1.0 - exp(-.025 * t));
    col = (col * (2.51 * col + .03)) / (col * (2.43 * col + .59) + .14);
    fragColor = vec4(pow(max(col, 0.), vec3(.4545)) * 1.15 * (1. - length(uv) * .55), 1);
}
