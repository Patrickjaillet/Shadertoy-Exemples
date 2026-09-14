// ==== Image (image) ====
#define T (iTime * 1.5)
#define PI 3.14159265

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hachage(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

vec3 trajectoire(float z) {
    float x = sin(z * 0.15) * 6.0 + cos(z * 0.07) * 4.0;
    float y = cos(z * 0.12) * 3.0 + sin(z * 0.05) * 2.0;
    return vec3(x, y, z);
}

float fleur(vec3 p, vec3 id, float t) {
    float h = hachage(id);
    p.xy *= rot(h * 6.28 + t * (h - 0.5));
    p.xz *= rot(h * 3.14);
    float r = length(p.xy);
    float a = atan(p.y, p.x);
    float forme = 0.18 + 0.12 * sin(a * 6.0 + h * 5.0);
    float d = max(r - forme, abs(p.z) - 0.008);
    float coeur = length(p) - 0.07;
    return min(d, coeur) - 0.004;
}

float carte(vec3 p, float t) {
    vec3 p_courbe = p - trajectoire(p.z);
    float tunnel = length(p_courbe.xy) - 3.8;
    vec3 id = floor(p);
    vec3 q = fract(p) - 0.5;
    float fleurs = fleur(q, id, t);
    return max(fleurs, -tunnel);
}

vec3 calculer_normale(vec3 p, float t) {
    vec2 e = vec2(1.0, -1.0) * 0.0006;
    return normalize(e.xyy * carte(p + e.xyy, t) + e.yyx * carte(p + e.yyx, t) + 
                     e.yxy * carte(p + e.yxy, t) + e.xxx * carte(p + e.xxx, t));
}

vec3 calculer_flare(vec2 uv, vec2 pos_s, vec3 col_s) {
    vec2 dir = pos_s - uv;
    float dist = length(dir);
    vec2 n_dir = normalize(dir);
    vec3 flare = vec3(0);
    float o = 1.0 - clamp(length(pos_s), 0.0, 1.0);
    flare += 0.2 * col_s * pow(1.0 - clamp(dist, 0.0, 1.0), 10.0) * o;
    for (int i = 0; i < 3; i++) {
        float f = float(i);
        vec2 p_f = uv + n_dir * dist * (2.0 + f * 0.5);
        float d_f = length(p_f);
        float fr = pow(max(0.0, 1.0 - d_f * 2.0), 3.0);
        vec3 c_f = col_s * (f == 0.0 ? vec3(1,0,0) : (f == 1.0 ? vec3(0,1,0) : vec3(0,0,1)));
        flare += 0.08 * c_f * fr * o;
    }
    return flare;
}

vec3 rendu_scene(vec2 uv, float t_offset) {
    float t = T + t_offset;
    vec3 ro = trajectoire(t * 6.0);
    vec3 cible = trajectoire(t * 6.0 + 1.2);
    ro.xy += sin(t * 10.0) * 0.01 + sin(t * 110.0) * 0.005;
    vec3 av = normalize(cible - ro);
    float inc = (trajectoire(t * 6.0 + 0.5).x - ro.x) * 0.25;
    vec3 dr = normalize(cross(vec3(sin(inc), cos(inc), 0), av));
    vec3 ha = cross(av, dr);
    vec3 pt = ro + normalize(uv.x * dr + uv.y * ha + av * 1.8) * 6.0;
    vec3 rd = normalize(pt - ro);
    float d = 0.0, d_m = 50.0;
    for(int i = 0; i < 64; i++) {
        float s = carte(ro + rd * d, t);
        if(abs(s) < 0.001 || d > d_m) break;
        d += s * 0.9;
    }
    vec3 col = vec3(0.001, 0.002, 0.005);
    if(d < d_m) {
        vec3 p = ro + rd * d;
        vec3 n = calculer_normale(p, t);
        vec3 id = floor(p);
        vec3 b_c = 0.5 + 0.5 * cos(hachage(id) * 7.0 + vec3(0, 2.5, 5.0));
        if(length(fract(p)-0.5) < 0.11) b_c *= 15.0; 
        float di = max(dot(n, normalize(vec3(1, 2, -1))), 0.0);
        float sp = pow(max(dot(reflect(normalize(vec3(1, 2, -1)), n), rd), 0.0), 30.0);
        col = b_c * (di * 0.7 + 0.3) + sp * 0.4;
        col *= exp(-0.06 * d);
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    vec3 final_col = vec3(0);
    float ab_int = 0.005 * length(uv);
    final_col.r = rendu_scene(uv * (1.0 + ab_int), 0.0).r;
    final_col.g = rendu_scene(uv, 0.005).g;
    final_col.b = rendu_scene(uv * (1.0 - ab_int), 0.01).b;
    final_col *= 1.8;
    final_col = final_col / (1.0 + final_col);
    final_col = pow(final_col, vec3(0.4545));
    final_col *= 1.15 - dot(uv, uv) * 0.9;
    fragColor = vec4(final_col, 1.0);
}
