// ==== Image (image) ====
vec3 ACESFilm(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;

    float lum = dot(col, vec3(0.2126, 0.7152, 0.0722));
    vec3 bloom = col * smoothstep(0.7, 1.2, lum);
    col += bloom * 0.3;

    col = ACESFilm(col * 1.1);

    col = mix(col, pow(col, vec3(0.9, 1.0, 1.2)), 0.2);

    float n = hash(vec3(fragCoord, iTime));
    col += (n - 0.5) * 0.015;

    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    col *= 1.0 - dot(p, p) * 0.25;

    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}
//======================================================================================//
//:: [ Optimized for NVIDIA GeForce GeForce GTX 1080 Ti ] ::                            //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
// 1: https://www.shadertoy.com/view/scj3Dy
// 2: https://www.shadertoy.com/view/scXXWr

// ==== Common (common) ====
#define MAX_STEPS 180
#define SURF_DIST .001
#define MAX_DIST 140.

struct Frame {
    vec3 pos;
    vec3 T;
    vec3 N;
    vec3 B;
};

mat2 rot(float a) { float s=sin(a), c=cos(a); return mat2(c,-s,s,c); }

float hash(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

vec3 getPath(float t) {
    float T = t * 0.15; 
    float x = sin(T * 2.1) * 22.0 + cos(T * 0.9) * 11.0;
    float y = cos(T * 1.7) * 14.0 + sin(T * 1.2) * 9.0 + 15.0;
    float z = t * 10.0; 
    return vec3(x, y, z);
}
//======================================================================================//
//:: [ Optimized for NVIDIA GeForce GeForce GTX 1080 Ti ] ::                            //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
void getFrame(float t, out Frame f) {
    f.pos = getPath(t);
    float dt = 0.05;
    f.T = normalize(getPath(t + dt) - f.pos);
    vec3 up = vec3(0, 1, 0);
    vec3 side = normalize(cross(f.T, up));
    float banking = sin(t * 0.12) * 1.4; 
    up = normalize(up + side * banking); 
    f.B = normalize(cross(f.T, up));
    f.N = cross(f.B, f.T);
}

// ==== Buffer A (buffer) ====
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    return mix(mix(mix(hash(p+vec3(0,0,0)), hash(p+vec3(1,0,0)),f.x),
                   mix(hash(p+vec3(0,1,0)), hash(p+vec3(1,1,0)),f.x),f.y),
               mix(mix(hash(p+vec3(0,0,1)), hash(p+vec3(1,0,1)),f.x),
                   mix(hash(p+vec3(0,1,1)), hash(p+vec3(1,1,1)),f.x),f.y),f.z);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * noise(p);
        p = p * 2.5;
        a *= 0.5;
    }
    return v;
}

vec3 getSkyColor(vec3 rd, vec3 sunDir) {
    float sun = max(dot(rd, sunDir), 0.0);
    vec3 sky = vec3(0.1, 0.3, 0.6) - rd.y * 0.4;
    sky = mix(sky, vec3(0.5, 0.7, 0.9), pow(1.0 - max(rd.y, 0.0), 4.0));
    sky += vec3(1.0, 0.6, 0.3) * pow(sun, 12.0);
    sky += vec3(1.0, 0.9, 0.7) * pow(sun, 300.0);
    return sky;
}
//======================================================================================//
//:: [ Optimized for NVIDIA GeForce GeForce GTX 1080 Ti ] ::                            //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
float cloudDensity(vec3 p) {
    vec3 q = p * 0.1 + vec3(0.0, 0.0, iTime * 0.1);
    float d = fbm(q);
    d = smoothstep(0.4, 0.8, d);
    return d * smoothstep(10.0, 30.0, p.y) * smoothstep(80.0, 40.0, p.y);
}

vec3 renderClouds(vec3 col, vec3 ro, vec3 rd, vec3 sunDir) {
    float stepL = 1.5;
    float t = 0.0;
    float transmittance = 1.0;
    vec3 cloudCol = vec3(0.0);
    if(rd.y > 0.0) {
        float max_t = 150.0;
        for(int i=0; i<32; i++) {
            vec3 p = ro + rd * t;
            float d = cloudDensity(p);
            if(d > 0.01) {
                float shadow = cloudDensity(p + sunDir * 1.5);
                float light = smoothstep(0.0, 1.0, d - shadow);
                vec3 ambient = mix(vec3(0.4, 0.5, 0.6), vec3(1.0), light);
                cloudCol += transmittance * d * ambient;
                transmittance *= 1.0 - d * 0.5;
                if(transmittance < 0.02) break;
            }
            t += stepL;
            if(t > max_t) break;
        }
    }
    return mix(col, cloudCol + col * transmittance, 1.0 - transmittance);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
    float t = p.z / 10.0; 
    Frame f;
    for(int i=0; i<3; i++) {
        getFrame(t, f);
        t += dot(p - f.pos, f.T) / 10.0;
    }
    float terrainHeight = f.pos.y - 18.0 + cos(p.x*0.15)*sin(p.z*0.12)*4.0;
    float terrain = p.y - terrainHeight;
    vec3 q = p - f.pos;
    vec3 pL = vec3(dot(q, f.B), dot(q, f.N), dot(q, f.T));
    float rLeft = length(pL.xy - vec2(0.8, 0.0)) - 0.15;
    float rRight = length(pL.xy - vec2(-0.8, 0.0)) - 0.15;
    float rails = min(rLeft, rRight);
    vec3 pS = pL;
    float stepZ_S = 3.0; 
    pS.z = mod(pS.z + stepZ_S*0.5, stepZ_S) - stepZ_S*0.5;
    float sleepers = sdBox(pS - vec3(0.0, -0.25, 0.0), vec3(1.2, 0.1, 0.4));
    float pDist = 50.0; 
    float tIdx = floor((p.z + pDist*0.5) / pDist) * pDist / 10.0;
    Frame fP;
    getFrame(tIdx, fP);
    vec3 qP = p - fP.pos;
    vec3 pLP = vec3(dot(qP, fP.B), dot(qP, fP.N), dot(qP, fP.T));
    float beam = sdBox(pLP - vec3(0.0, -0.8, 0.0), vec3(2.5, 0.4, 0.8));
    float column = length(p.xz - fP.pos.xz) - 0.7;
    column = max(column, p.y - (fP.pos.y - 1.2)); 
    float structural = min(column, beam);
    float track = min(rails, sleepers);
    return min(terrain, min(track, structural));
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.005, 0);
    return normalize(vec3(
        map(p+e.xyy) - map(p-e.xyy),
        map(p+e.yxy) - map(p-e.yxy),
        map(p+e.yyx) - map(p-e.yyx)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float jitter = hash(vec3(fragCoord, iFrame)) * 0.015;
    float speedMult = (iMouse.z > 0.5) ? clamp((iMouse.y / iResolution.y - 0.1) / 0.8, 0.0, 1.0) : 0.5;
    float speed = mix(5.0, 10.0, speedMult);
    float time = (iTime + jitter) * speed; 

    Frame f;
    getFrame(time, f);
    vec3 ro = f.pos + f.N * 1.6;
    vec3 rd = normalize(f.T * 1.2 + uv.x * f.B + uv.y * f.N);
    vec3 sunDir = normalize(vec3(0.5, 0.7, -0.4));
    
    vec3 sky = getSkyColor(rd, sunDir);
    vec3 col = renderClouds(sky, ro, rd, sunDir);
    
    float d = 0.0;
    for(int i=0; i<MAX_STEPS; i++) {
        float res = map(ro + rd * d);
        if(res < SURF_DIST || d > MAX_DIST) break;
        d += res;
    }
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        float dif = clamp(dot(n, sunDir), 0.0, 1.0);
        float spe = pow(clamp(dot(reflect(-sunDir, n), -rd), 0.0, 1.0), 40.0);
        float occ = clamp(map(p + n * 0.8) / 0.8, 0.0, 1.0);
        
        float tVal = p.z / 10.0;
        Frame fSurf;
        getFrame(tVal, fSurf);
        vec3 q = p - fSurf.pos;
        vec3 pL = vec3(dot(q, fSurf.B), dot(q, fSurf.N), dot(q, fSurf.T));
        
        vec3 albedo = vec3(0.2); 
        if(p.y < fSurf.pos.y - 5.0) {
            albedo = vec3(0.1, 0.15, 0.05);
        } else {
            float stepZ = 3.0;
            float zMod = abs(mod(pL.z + stepZ*0.5, stepZ) - stepZ*0.5);
            if(zMod < 0.45 && pL.y < -0.1 && pL.y > -0.6) {
                albedo = vec3(0.12, 0.08, 0.05);
            } else if (abs(pL.x) > 0.6 && abs(pL.y) < 0.3) {
                albedo = vec3(0.4, 0.42, 0.45);
            } else {
                albedo = vec3(0.65, 0.1, 0.1);
            }
        }
        vec3 lighting = albedo * (dif + 0.2) * occ + spe * 0.4;
        col = mix(lighting, sky, 1.0 - exp(-0.00015 * d * d));
    }
    
    vec4 prev = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = mix(prev, vec4(col, 1.0), 0.35);
}

// ==== Sound (sound) ====
#define PI 3.14159265359

float hash(float n) { return fract(sin(n) * 43758.5453123); }

float tronHum(float freq, float t) {
    float sub = sin(2.0 * PI * (freq * 0.5) * t);
    float base = sin(2.0 * PI * freq * t + 0.3 * sin(2.0 * PI * 1.2 * t));
    float pulse = pow(0.5 + 0.5 * sin(2.0 * PI * (freq / 64.0) * t), 2.0);
    return tanh(mix(base, sub, 0.8) * pulse);
}

vec2 mainSound(int item, float time) {
    float speedMult = 0.5; 
    float speed = mix(5.0, 10.0, speedMult);
    float t = time * speed;
    float currentZ = t * 10.0;
    
    float fBase = 38.0 + (speed * 6.0);
    float motor = tronHum(fBase, time) * 0.2;
    
    float pDist = 50.0;
    float poleTrigger = fract((currentZ + pDist * 0.5) / pDist);
    
    float whiteNoise = hash(time * 44100.0) * 2.0 - 1.0;
    float poleWhoosh = 0.0;
    
    if(poleTrigger < 0.3) {
        float env = smoothstep(0.0, 0.15, poleTrigger) * smoothstep(0.3, 0.15, poleTrigger);
        float lowWind = sin(2.0 * PI * 10.0 * time) * 10.5;
        poleWhoosh = mix(whiteNoise, lowWind, 0.7) * env * 0.15;
        poleWhoosh = tanh(poleWhoosh * 2.0);
    }

    float railJoints = fract(currentZ / pDist);
    float impact = exp(-30.0 * railJoints) * sin(2.0 * PI * 50.0 * time) * 0.05;
    impact += exp(-30.0 * railJoints) * whiteNoise * 0.03;

    float finalMix = motor + poleWhoosh + impact;
    
    float lfo = 0.5 + 0.1 * sin(2.0 * PI * 0.1 * time);
    finalMix *= lfo;

    return clamp(vec2(finalMix), -0.9, 0.9);
}
