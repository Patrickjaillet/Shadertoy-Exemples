// ==== Image (image) ====
#define AA 1

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.2831853 * (c * t + d));
}

vec4 map(vec3 p) {
    p.z = mod(p.z - iTime * 5.5, 16.0) - 8.0;
    float s = 1.0;
    vec3 q = p;
    vec3 orbit = vec3(0.0);
    
    for(int i = 0; i < 11; i++) {
        q = abs(q) - vec3(1.4, 0.9, 1.2);
        q.xy *= rot(0.618);
        q.xz *= rot(0.785398);
        
        float r2 = dot(q, q);
        orbit = max(orbit, abs(q));
        
        float k = clamp(1.85 / max(r2, 0.04), 0.15, 2.85);
        q *= k;
        s *= k;
    }
    
    float d = (length(q.xz) - 0.04) / s;
    float tunnel = length(p.xy) - 3.2;
    d = max(d, -tunnel);
    
    return vec4(d * 0.55, orbit);
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy).x - map(p - e.xyy).x,
        map(p + e.yxy).x - map(p - e.yxy).x,
        map(p + e.yyx).x - map(p - e.yyx).x
    ));
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 3; i++) {
        float hr = 0.02 + 0.15 * float(i) / 2.0;
        vec3 aopos = n * hr + p;
        float dd = map(aopos).x;
        occ += -(dd - hr) * sca;
        sca *= 1.0;
    }
    return clamp(1.0 - 3.5 * occ, 0.0, 1.0);
}

vec3 render(vec2 fragCoord, vec2 res, float time) {
    vec2 uv = (fragCoord - 0.5 * res) / res.y;
    
    float distFromCenter = length(uv);
    float ripple = sin(distFromCenter * 120.0 - time * 8.4) * exp(-distFromCenter * 1.5) * 0.015;
    uv += (distFromCenter > 0.001) ? (uv / distFromCenter) * ripple : vec2(0.0);
    
    vec3 ro = vec3(0.0, 0.0, -1.0);
    ro.x += sin(time * 0.4) * 0.6;
    ro.y += cos(time * 0.25) * 0.4;
    
    vec3 rd = normalize(vec3(uv, 0.12));
    rd.xy *= rot(sin(time * 0.2) * 0.3);
    rd.xz *= rot(time * 0.15);
    
    float t = 0.00;
    vec4 m = vec4(0.0);
    vec3 p;
    float glow = 0.0;
    bool hit = false;
    
    for(int i = 0; i < 35; i++) {
        p = ro + rd * t;
        m = map(p);
        float err = 0.0004 * (0.0 + t * 0.0);
        if(m.x < err) {
            hit = true;
            break;
        }
        if(t > 120.0) break;
        t += m.x;
        glow += exp(-max(m.x, 0.0) * 14.0) * (1.0 + sin(m.y * 4.0 + time * 2.0));
    }
    
    vec3 col = vec3(0.002, 0.004, 0.01);
    
    if(hit) {
        vec3 n = calcNormal(p);
        vec3 r = reflect(rd, n);
        
        vec3 l1 = normalize(vec3(5.0, 8.0, -4.0));
        vec3 l2 = normalize(vec3(-6.0, -4.0, 2.0));
        
        float dif1 = max(dot(n, l1), 0.0);
        float dif2 = max(dot(n, l2), 0.0);
        float spe = pow(max(dot(r, l1), 0.0), 32.0);
        float ao = calcAO(p, n);
        
        vec3 mat = pal(length(m.yzw) * 0.12 - time * 0.1, 
                       vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.0, 0.33, 0.67));
        
        col = mat * dif1 * vec3(1.0, 1.00, 1.0) * 1.8;
        col += mat * dif2 * vec3(0.3, 0.55, 0.9) * 1.2;
        col += spe * vec3(1.0) * ao;
        col += mat * 0.11 * ao;
        
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 4.0);
        col += fre * pal(m.z * 0.15 + time * 0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.1, 0.4, 0.7)) * 8.0 * ao;
    }
    
    vec3 glowCol = pal(time * 1.0 + t * 0.05, vec3(0.5), vec3(0.5), vec3(0.8, 1.0, 0.4), vec3(0.5, 0.15, 0.4));
    col += glowCol * glow * 0.035;
    
    col = mix(col, vec3(0.004, 0.008, 0.02), 1.0 - exp(-0.004 * t * t));
    
    return col;
}

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 col = render(fragCoord, iResolution.xy, iTime);
    col = aces(col);
    col = pow(col, vec3(0.454545));
    fragColor = vec4(col, 1.0);
}
