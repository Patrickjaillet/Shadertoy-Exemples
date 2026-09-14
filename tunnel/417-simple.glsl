// ==== Image (image) ====
#define R iResolution.xy
#define T (iTime * 0.2)

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yxz + 19.19);
    return fract((p.x + p.y) * p.z);
}

vec3 path(float z) {
    return vec3(sin(z * 0.15) * 6.0 + cos(z * 0.07) * 4.0, cos(z * 0.12) * 3.0 + sin(z * 0.05) * 2.0, z);
}

vec2 smin(vec2 a, vec2 b, float k) {
    float h = clamp(0.5 + 0.5 * (b.x - a.x) / k, 0.0, 1.0);
    return vec2(mix(b.x, a.x, h) - k * h * (1.0 - h), mix(b.y, a.y, h));
}

vec2 map(vec3 p, float t) {
    vec3 cp = p - path(p.z);
    float tun = length(cp.xy) - 3.8 + 0.3 * sin(cp.z * 2.0 + t) * cos(atan(cp.y, cp.x) * 4.0);
    
    vec3 id = floor(p * 1.5);
    vec3 q = fract(p * 1.5) - 0.5;
    float h = hash(id);
    q.xy *= rot(h * 6.283 + t * (h - 0.5));
    float r = length(q.xy);
    float a = atan(q.y, q.x);
    float petal = 0.18 + 0.12 * sin(a * 5.0 + h * 5.0) * cos(r * 15.0 - t * 2.0);
    float f = max(r - petal, abs(q.z) - 0.01);
    f = smin(vec2(f, 1.0), vec2(length(q) - 0.06, 2.0), 0.02).x / 1.5;
    
    float vine = length(vec2(length(cp.xy) - 3.5, cp.z * 0.5)) - 0.1;
    
    vec2 res = vec2(-tun, 0.0);
    res = f < res.x ? vec2(f, 1.0) : res;
    res = vine < res.x ? vec2(vine, 3.0) : res;
    return res;
}

vec3 normal(vec3 p, float t) {
    vec2 e = vec2(1.0, -1.0) * 0.001;
    return normalize(e.xyy * map(p + e.xyy, t).x + e.yyx * map(p + e.yyx, t).x + e.yxy * map(p + e.yxy, t).x + e.xxx * map(p + e.xxx, t).x);
}

float softshadow(vec3 ro, vec3 rd, float t) {
    float res = 1.0, ph = 1e10, d = 0.05;
    for(int i = 0; i < 16; i++) {
        float h = map(ro + rd * d, t).x;
        float y = h * h / (2.0 * ph);
        float d2 = sqrt(max(0.0, h * h - y * y));
        res = min(res, 10.0 * d2 / max(0.001, d - y));
        ph = h; d += h;
        if(res < 0.01 || d > 12.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 render(vec3 ro, vec3 rd, float t, out float depth) {
    float d = 0.0;
    vec2 res;
    vec3 glow = vec3(0.0);
    
    for(int i = 0; i < 75; i++) {
        vec3 p = ro + rd * d;
        res = map(p, t);
        if(res.y == 1.0) glow += (0.5 + 0.5 * cos(hash(floor(p * 1.5)) * 12.0 + vec3(0.0, 2.0, 4.0))) * 0.0015 / (res.x * res.x + 0.001);
        if(res.y == 3.0) glow += vec3(0.1, 0.8, 0.2) * 0.0005 / (res.x * res.x + 0.002);
        if(abs(res.x) < 0.001 || d > 45.0) break;
        d += res.x * 0.8;
    }
    
    depth = d;
    vec3 col = vec3(0.005, 0.01, 0.03);
    
    if(d < 45.0) {
        vec3 p = ro + rd * d;
        vec3 n = normal(p, t);
        
        vec3 albedo = vec3(0.05);
        vec3 emiCol = vec3(0.0);
        
        if(res.y == 1.0) {
            albedo = 0.5 + 0.5 * cos(hash(floor(p * 1.5)) * 12.0 + vec3(0.0, 2.0, 4.0));
            if(length(fract(p * 1.5) - 0.5) < 0.08) emiCol = albedo * 5.0;
        } else if (res.y == 3.0) {
            albedo = vec3(0.05, 0.3, 0.1);
            emiCol = vec3(0.2, 1.0, 0.3) * (0.5 + 0.5 * sin(p.z * 10.0 - t * 5.0));
        } else {
            albedo = vec3(0.08, 0.08, 0.1) * (0.8 + 0.2 * hash(floor(p * 4.0)));
        }
        
        vec3 lig = normalize(vec3(sin(t), 1.5, cos(t * 0.8)));
        vec3 hal = normalize(lig - rd);
        
        float dif = clamp(dot(n, lig), 0.0, 1.0);
        float sha = softshadow(p, lig, t);
        float spe = pow(clamp(dot(n, hal), 0.0, 1.0), 32.0) * dif * sha;
        
        col = albedo * (dif * sha * vec3(2.5, 2.3, 2.1) + 0.1) + spe * 2.0 + emiCol;
        col = mix(col, vec3(0.005, 0.01, 0.03), 1.0 - exp(-0.008 * d * d));
    }
    return col + glow;
}

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 O, in vec2 U) {
    vec2 uv = (U - R * 0.5) / R.y;
    float t = T;
    vec3 ro = path(t * 6.0);
    ro.xy += sin(t * 10.0) * 0.01;
    vec3 ta = path(t * 6.0 + 1.2);
    
    vec3 fwd = normalize(ta - ro);
    float inc = (path(t * 6.0 + 0.5).x - ro.x) * 0.25;
    vec3 rgt = normalize(cross(vec3(sin(inc), cos(inc), 0.0), fwd));
    vec3 up = cross(fwd, rgt);
    
    vec3 col = vec3(0.0);
    float d1, d2, d3;
    
    float ab = 0.015 * length(uv);
    vec3 rdR = normalize((uv.x * (1.0 + ab)) * rgt + (uv.y * (1.0 + ab)) * up + fwd * 1.5);
    vec3 rdG = normalize(uv.x * rgt + uv.y * up + fwd * 1.5);
    vec3 rdB = normalize((uv.x * (1.0 - ab)) * rgt + (uv.y * (1.0 - ab)) * up + fwd * 1.5);
    
    col.r = render(ro, rdR, t, d1).r;
    col.g = render(ro, rdG, t, d2).g;
    col.b = render(ro, rdB, t, d3).b;
    
    vec2 sPos = vec2(sin(t * 0.5) * 0.8, cos(t * 0.3) * 0.8); 
    vec2 p = U / R * 2.0 - 1.0;
    vec2 dir = sPos - p;
    float dist = length(dir);
    vec2 nDir = normalize(dir);
    
    vec3 flare = vec3(0.0);
    float falloff = 1.0 - clamp(length(sPos), 0.0, 1.0);
    for (int i = 0; i < 5; i++) {
        float f = float(i);
        vec2 pf = p + nDir * dist * (1.1 + f * 0.25);
        float fr = pow(max(0.0, 1.0 - length(pf) * 2.5), 5.0);
        vec3 cf = vec3(0.1) * (f == 0.0 ? vec3(1.0, 0.3, 0.1) : (f == 1.0 ? vec3(0.6, 1.0, 0.3) : vec3(0.1, 0.6, 1.0)));
        flare += cf * fr * falloff;
    }
    
    col += flare * smoothstep(20.0, 40.0, d2);
    col *= 1.0 - 0.7 * dot(uv, uv);
    col = aces(col * 1.3);
    col = pow(col, vec3(0.4545));
    col += (hash(vec3(U, t)) - 0.5) * 0.04;
    
    O = vec4(col, 1.0);
}
