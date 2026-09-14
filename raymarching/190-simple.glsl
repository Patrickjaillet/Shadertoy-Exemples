// ==== Image (image) ====
#define MAX_STEPS 256
#define MAX_DIST 80.0
#define SURF_DIST 0.0001

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float kifs(vec3 p) {
    float s = 1.0;
    float t = iTime * 0.15;
    
    for(int i = 0; i < 8; i++) {
        p = abs(p) - vec3(1.2, 1.8, 1.1);
        
        if(p.x < p.y) p.xy = p.yx;
        if(p.x < p.z) p.xz = p.zx;
        if(p.y < p.z) p.yz = p.zy;
        
        p.xy *= rot(0.45 + sin(t * 0.8 + float(i) * 0.5) * 0.12);
        p.yz *= rot(0.35);
        
        float scale = 1.55 + sin(t * 0.5) * 0.05;
        p *= scale;
        s *= scale;
        p -= vec3(0.3, 1.2, 0.5) * (sin(t) * 0.1 + 1.0);
    }
    return sdBox(p, vec3(0.5, 4.0, 0.2)) / s;
}

float map(vec3 p) {
    vec3 p_rot = p;
    p_rot.xz *= rot(iTime * 0.1);
    p_rot.zy *= rot(iTime * 0.05);
    
    float d = kifs(p_rot);
    
    float core = length(p) - 1.3;
    float pulse = sin(length(p) * 4.0 - iTime * 5.0) * 0.04;
    core += pulse;
    
    float rings = abs(length(p.xz) - 3.5) - 0.02;
    rings = max(rings, abs(p.y) - 0.01);
    
    float res = smin(d, core, 0.6);
    res = smin(res, rings, 0.1);
    
    return res;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.15 * float(i) / 4.0;
        float d = map(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.9;
    }
    return clamp(1.0 - 4.0 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, -10.0);
    vec3 rd = normalize(vec3(uv, 2.0));
    
    float r_ang = iTime * 0.1;
    ro.yz *= rot(sin(r_ang * 0.5) * 0.4);
    ro.xz *= rot(r_ang);
    rd.yz *= rot(sin(r_ang * 0.5) * 0.4);
    rd.xz *= rot(r_ang);
    
    float dO = 0.0;
    float dS;
    vec3 p;
    float glow = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        p = ro + rd * dO;
        dS = map(p);
        glow += 0.015 / (0.02 + abs(dS));
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
        dO += dS * 0.75;
    }
    
    vec3 col = vec3(0.0);
    
    if(dO < MAX_DIST) {
        vec3 n = getNormal(p);
        vec3 r = reflect(rd, n);
        
        vec3 env = texture(iChannel0, r).rgb;
        vec3 diff = textureLod(iChannel0, n, 4.0).rgb;
        
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 5.0);
        float occ = getAO(p, n);
        
        vec3 base = mix(vec3(0.01, 0.02, 0.05), vec3(0.7, 0.85, 1.0), fre);
        col = base * diff + env * (fre + 0.15);
        
        float spec = pow(max(dot(r, normalize(vec3(1.0, 3.0, -2.0))), 0.0), 256.0);
        col += spec * env * 2.0;
        col *= occ;
    } else {
        col = texture(iChannel0, rd).rgb * 0.4;
        col += pow(max(dot(rd, normalize(vec3(1, 1, -1))), 0.0), 64.0) * vec3(0.6, 0.7, 1.0);
    }
    
    vec3 gCol = mix(vec3(0.0, 0.3, 1.0), vec3(0.8, 0.1, 0.5), sin(iTime * 0.3) * 0.5 + 0.5);
    col += gCol * glow * 0.012;
    
    col = smoothstep(-0.02, 1.02, col);
    col = pow(col, vec3(0.4545));
    col *= 1.1 - length(uv) * 0.4;
    
    fragColor = vec4(col, 1.0);
}
