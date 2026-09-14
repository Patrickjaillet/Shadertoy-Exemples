// ==== Image (image) ====
#define TEMPS iTime
#define RES iResolution.xy

float hachage(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float bruit(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hachage(i), hachage(i + vec2(1, 0)), u.x),
               mix(hachage(i + vec2(0, 1)), hachage(i + vec2(1, 1)), u.x), u.y);
}

float sdEllipsoide(vec3 p, vec3 r) {
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * 0.25;
}

vec2 posCanard(float t) {
    return vec2(sin(t * 1.2) * 3.5, cos(t * 0.7) * 2.5);
}

float hauteurEau(vec2 p) {
    float h = sin(p.x * 1.5 + TEMPS * 2.0) * 0.05 + cos(p.y * 1.2 + TEMPS * 1.5) * 0.05;
    vec2 dp = posCanard(TEMPS);
    float dist = length(p - dp);
    h += sin(dist * 10.0 - TEMPS * 8.0) * exp(-dist * 0.5) * 0.2;
    h += bruit(p * 4.0 + TEMPS) * 0.03;
    return h;
}

vec2 map(vec3 p) {
    vec2 res = vec2(p.y - hauteurEau(p.xz), 4.0);
    
    vec2 pc = posCanard(TEMPS);
    vec2 dir = normalize(posCanard(TEMPS + 0.01) - pc);
    mat3 rot = mat3(dir.y, 0, -dir.x, 0, 1, 0, dir.x, 0, dir.y);
    
    vec3 q = p;
    q.xz -= pc;
    q = rot * q;
    
    float bob = sin(TEMPS * 4.0) * 0.1;
    q.y -= hauteurEau(pc) + 0.3 + bob;
    
    float corps = sdEllipsoide(q, vec3(0.6, 0.45, 0.5));
    float cou = sdEllipsoide(q - vec3(0, 0.4, 0.3), vec3(0.2, 0.4, 0.2));
    float tete = length(q - vec3(0, 0.7, 0.4)) - 0.25;
    float bec = sdEllipsoide(q - vec3(0, 0.65, 0.65), vec3(0.15, 0.07, 0.25));
    
    float dCanard = smin(corps, cou, 0.2);
    dCanard = smin(dCanard, tete, 0.1);
    
    res = (dCanard < res.x) ? vec2(dCanard, 1.0) : res;
    res = (bec < res.x) ? vec2(bec, 2.0) : res;
    
    return res;
}

vec3 calculerNormale(vec3 p) {
    vec2 e = vec2(0.001, 0);
    return normalize(vec3(map(p + e.xyy).x - map(p - e.xyy).x,
                          map(p + e.yxy).x - map(p - e.yxy).x,
                          map(p + e.yyx).x - map(p - e.yyx).x));
}

vec3 rendu(vec2 uv) {
    vec3 ro = vec3(cos(TEMPS * 0.2) * 8.0, 4.0, sin(TEMPS * 0.2) * 8.0);
    vec3 ta = vec3(0, 0, 0);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0, 1, 0)));
    vec3 vv = cross(uu, ww);
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 2.0 * ww);

    float t = 0.0;
    vec2 h;
    for(int i = 0; i < 150; i++) {
        h = map(ro + rd * t);
        if(h.x < 0.0001 || t > 40.0) break;
        t += h.x * 0.6;
    }

    if(t > 40.0) return vec3(0.02, 0.04, 0.08) + pow(max(dot(rd, vec3(0, 1, 0)), 0.0), 4.0) * vec3(0.5, 0.8, 1.0);

    vec3 p = ro + rd * t;
    vec3 n = calculerNormale(p);
    vec3 ref = reflect(rd, n);
    
    vec3 col = vec3(0);
    
    if(h.y == 4.0) {
        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        vec3 eauBase = mix(vec3(0.0, 0.1, 0.2), vec3(0.1, 0.5, 0.6), n.y);
        vec3 ciel = vec3(0.5, 0.7, 1.0) * max(ref.y, 0.0);
        col = mix(eauBase, ciel, fresnel);
        col += pow(max(dot(ref, normalize(vec3(1, 1, 1))), 0.0), 64.0);
        col += bruit(p.xz * 10.0 + TEMPS) * 0.1 * smoothstep(0.1, 0.0, h.x);
    } else {
        vec3 albedo = (h.y == 1.0) ? vec3(1.0, 0.8, 0.0) : vec3(1.0, 0.3, 0.0);
        float diff = max(dot(n, normalize(vec3(1, 2, 1))), 0.0);
        col = albedo * diff + albedo * 0.2;
        col += pow(max(dot(ref, normalize(vec3(1, 2, 1))), 0.0), 32.0) * 0.5;
    }
    
    return col * exp(-t * 0.03);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * RES) / RES.y;
    
    vec3 colFinal = vec3(0);
    float decalage = bruit(uv * 10.0 + TEMPS) * 0.005;
    
    colFinal.r = rendu(uv + vec2(decalage, 0)).r;
    colFinal.g = rendu(uv).g;
    colFinal.b = rendu(uv - vec2(decalage, 0)).b;
    
    colFinal *= 1.2 - dot(uv, uv) * 0.5;
    colFinal = pow(colFinal, vec3(0.8));
    
    fragColor = vec4(colFinal, 1.0);
}
