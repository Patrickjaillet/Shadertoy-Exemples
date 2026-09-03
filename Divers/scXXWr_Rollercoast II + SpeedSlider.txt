// ==== Image (image) ====
#define MAX_STEPS 180
#define SURF_DIST .001
#define MAX_DIST 140.

mat2 rot(float a) { float s=sin(a), c=cos(a); return mat2(c,-s,s,c); }

float hash(vec3 p) {
    p  = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

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

vec3 getPath(float t) {
    float T = t * 0.15; 
    float x = sin(T * 2.1) * 22.0 + cos(T * 0.9) * 11.0;
    float y = cos(T * 1.7) * 14.0 + sin(T * 1.2) * 9.0 + 15.0;
    float z = t * 10.0; 
    return vec3(x, y, z);
}

void getFrame(float t, out vec3 pos, out vec3 T, out vec3 N, out vec3 B) {
    pos = getPath(t);
    float dt = 0.05;
    T = normalize(getPath(t + dt) - pos);
    vec3 up = vec3(0, 1, 0);
    vec3 side = normalize(cross(T, up));
    float banking = sin(t * 0.12) * 1.4; 
    up = normalize(up + side * banking); 
    B = normalize(cross(T, up));
    N = cross(B, T);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
    float t = p.z / 10.0; 
    vec3 cPos, T, N, B;
    for(int i=0; i<3; i++) {
        getFrame(t, cPos, T, N, B);
        t += dot(p - cPos, T) / 10.0;
    }
    float terrainHeight = cPos.y - 18.0 + cos(p.x*0.15)*sin(p.z*0.12)*4.0;
    float terrain = p.y - terrainHeight;
    vec3 q = p - cPos;
    vec3 pL = vec3(dot(q, B), dot(q, N), dot(q, T));
    float rLeft = length(pL.xy - vec2(0.8, 0.0)) - 0.15;
    float rRight = length(pL.xy - vec2(-0.8, 0.0)) - 0.15;
    float rails = min(rLeft, rRight);
    vec3 pS = pL;
    float stepZ_S = 3.0; 
    pS.z = mod(pS.z + stepZ_S*0.5, stepZ_S) - stepZ_S*0.5;
    float sleepers = sdBox(pS - vec3(0.0, -0.25, 0.0), vec3(1.2, 0.1, 0.4));
    float pDist = 50.0; 
    float tIdx = floor((p.z + pDist*0.5) / pDist) * pDist / 10.0;
    vec3 cP, cT, cN, cB;
    getFrame(tIdx, cP, cT, cN, cB);
    vec3 qP = p - cP;
    vec3 pLP = vec3(dot(qP, cB), dot(qP, cN), dot(qP, cT));
    float beam = sdBox(pLP - vec3(0.0, -0.8, 0.0), vec3(2.5, 0.4, 0.8));
    float column = length(p.xz - cP.xz) - 0.7;
    column = max(column, p.y - (cP.y - 1.2)); 
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

float drawSlider(vec2 uv, float val) {
    float slider = 0.0;
    vec2 p = uv - vec2(-0.85, 0.0);
    float bg = smoothstep(0.01, 0.0, abs(p.x) - 0.005) * smoothstep(0.5, 0.49, abs(p.y));
    float handle = smoothstep(0.03, 0.02, length(p - vec2(0.0, mix(-0.4, 0.4, val))));
    return max(bg * 0.5, handle);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float speedMult = (iMouse.z > 0.5) ? clamp((iMouse.y / iResolution.y - 0.1) / 0.8, 0.0, 1.0) : 0.5;
    float speed = mix(5.0, 10.0, speedMult);
    float time = iTime * speed; 
    
    vec3 ro, T, N, B;
    getFrame(time, ro, T, N, B);
    ro += N * 1.6; 
    
    vec3 sunDir = normalize(vec3(0.5, 0.7, -0.4));
    vec3 rd = normalize(T * 1.2 + uv.x * B + uv.y * N);
    vec3 col = getSkyColor(rd, sunDir);
    col = renderClouds(col, ro, rd, sunDir);
    
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
        vec3 cP, cT, cN, cB;
        getFrame(tVal, cP, cT, cN, cB);
        vec3 q = p - cP;
        vec3 pL = vec3(dot(q, cB), dot(q, cN), dot(q, cT));
        
        vec3 albedo = vec3(0.2); 
        if(p.y < cP.y - 5.0) {
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
        col = mix(lighting, getSkyColor(rd, sunDir), 1.0 - exp(-0.00015 * d * d));
    }
    
    col = pow(col, vec3(0.4545)); 
    col *= 1.0 - dot(uv, uv) * 0.3;
    
    float s = drawSlider(uv, speedMult);
    col = mix(col, vec3(1.0), s);
    
    fragColor = vec4(col, 1.0);
}
