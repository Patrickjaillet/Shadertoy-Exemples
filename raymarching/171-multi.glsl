// ==== Image (image) ====
float hache1(float n) { return fract(sin(n) * 43758.5453123); }

float bruit(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(mix(mix(hache1(n + 0.0), hache1(n + 1.0), f.x),
                   mix(hache1(n + 57.0), hache1(n + 58.0), f.x), f.y),
               mix(mix(hache1(n + 113.0), hache1(n + 114.0), f.x),
                   mix(hache1(n + 170.0), hache1(n + 171.0), f.x), f.y), f.z);
}

float fbm4(in vec3 q) {
    const mat3 m3 = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
    float f = 0.5 * bruit(q); q = m3 * q * 2.02;
    f += 0.25 * bruit(q); q = m3 * q * 2.03;
    f += 0.125 * bruit(q); q = m3 * q * 2.01;
    f += 0.0625 * bruit(q);
    return f;
}

float dalles_pierre(vec2 p) {
    vec2 f = fract(p);
    float bordure = smoothstep(0.0, 0.08, f.x) * smoothstep(1.0, 0.92, f.x) *
                    smoothstep(0.0, 0.08, f.y) * smoothstep(1.0, 0.92, f.y);
    return (1.0 - bordure) * 0.06 + bruit(vec3(p * 4.0, 0.0)) * 0.03;
}

void pliage_boite(inout vec3 v) { v = clamp(v, -1.0, 1.0) * 2.0 - v; }
void pliage_sphere(inout vec3 v, inout float f) {
    float r2 = dot(v, v);
    if (r2 < 0.5) { v *= 2.0; f *= 2.0; }
    else if (r2 < 1.0) { float p = 1.0 / r2; v *= p; f *= p; }
}
float map(vec3 p) {
    float d = p.y + 2.0 + dalles_pierre(p.xz * 0.4);
    vec3 p0 = p * 0.2 + vec3(0, 0.5, 0); float f = 1.0;
    for(int i=0; i<8; i++) { pliage_boite(p0); pliage_sphere(p0, f); p0 = p0 * 2.8 + (p * 0.2 + vec3(0, 0.5, 0)); f = f * 2.8 + 1.0; }
    return min(d, length(p0) / f * 5.0);
}

vec3 getNormal(in vec3 p, in float t) {
    float e = max(0.001, 0.0006 * t);
    vec2 h = vec2(1.0, -1.0) * 0.5773;
    return normalize(h.xyy * map(p + h.xyy * e) + h.yyx * map(p + h.yyx * e) + h.yxy * map(p + h.yxy * e) + h.xxx * map(p + h.xxx * e));
}

float zones_feu(vec2 p) { return smoothstep(0.55, 0.8, fbm4(vec3(p * 0.3, iTime * 0.5))); }

vec4 volume(in vec3 ro, in vec3 rd, float tmax, vec2 fragCoord) {
    vec4 res = vec4(0.0);
    float t = hache1(fragCoord.x + fragCoord.y * 517.0) * 0.3;
    for(int i=0; i<35; i++) {
        if(t > tmax || res.a > 0.98) break;
        vec3 p = ro + t * rd;
        float fsol = zones_feu(p.xz) * smoothstep(1.0, -1.0, p.y);
        float d = clamp(fbm4(p * 0.3 + vec3(0, -iTime * 0.1, 0)) - 0.5 + fsol * 2.0, 0.0, 1.0);
        vec4 col = vec4(mix(vec3(0.3), vec3(0.7, 0.35, 0.15), fsol * 0.8), d);
        col.rgb *= col.a;
        res += col * (1.0 - res.a);
        t += max(0.15, 0.1 * t);
    }
    return res;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(18.0 * cos(0.05 * (iTime + 20.0)), 8.0 + 2.0 * sin(0.1 * (iTime + 20.0)), 18.0 * sin(0.06 * (iTime + 20.0)));
    vec3 ta = vec3(18.0 * cos(0.05 * (iTime + 23.0)), 3.0 + 2.0 * sin(0.1 * (iTime + 23.0)), 18.0 * sin(0.06 * (iTime + 23.0)));
    vec3 cw = normalize(ta - ro), cu = normalize(cross(cw, vec3(0, 1, 0))), cv = normalize(cross(cu, cw));
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.7 * cw);

    float t = texture(iChannel0, fragCoord / iResolution.xy).r;
    vec3 sky = vec3(0.3, 0.35, 0.4) - rd.y * 0.5;
    vec3 col = sky;

    if(t > 0.0) {
        vec3 pos = ro + t * rd, nor = getNormal(pos, t), lum = normalize(vec3(-0.5, 0.8, 0.3));
        float occ = zones_feu(pos.xz), vac = 0.8 + 0.2 * sin(iTime * 10.0 + hache1(pos.x));
        vec3 lueur = vec3(1.0, 0.4, 0.1) * occ * smoothstep(-1.8, -2.0, pos.y) * vac * 2.0;
        vec3 mat = (pos.y < -1.8) ? mix(mix(vec3(0.25), vec3(0.15), dalles_pierre(pos.xz * 0.4)), vec3(1.0, 0.5, 0.1) * vac, occ * 0.8) : vec3(0.2);
        col = mat * (clamp(dot(nor, lum), 0.0, 1.0) * vec3(0.8) + (0.5 + 0.5 * nor.y) * 0.1) + lueur;
        col = mix(col, sky, 1.0 - exp(-0.0007 * t * t));
    }

    vec4 fumee = volume(ro, rd, (t < 0.0) ? 60.0 : t, fragCoord);
    col = mix(col, fumee.xyz, fumee.w);
    col = pow(col, vec3(0.4545));
    vec2 q = fragCoord / iResolution.xy;
    col *= 0.5 + 0.5 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15);
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
float hache1(float n) {
    return fract(sin(n) * 43758.5453123);
}

float bruit(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(mix(mix(hache1(n + 0.0), hache1(n + 1.0), f.x),
                   mix(hache1(n + 57.0), hache1(n + 58.0), f.x), f.y),
               mix(mix(hache1(n + 113.0), hache1(n + 114.0), f.x),
                   mix(hache1(n + 170.0), hache1(n + 171.0), f.x), f.y), f.z);
}

void pliage_boite(inout vec3 v) {
    v = clamp(v, -1.0, 1.0) * 2.0 - v;
}

void pliage_sphere(inout vec3 v, inout float f) {
    float r2 = dot(v, v);
    if (r2 < 0.5) {
        float p = 2.0;
        v *= p;
        f *= p;
    } else if (r2 < 1.0) {
        float p = 1.0 / r2;
        v *= p;
        f *= p;
    }
}

float carteMandelbox(vec3 p) {
    vec3 p0 = p;
    float echelle = 2.8;
    float f = 1.0;
    for (int i = 0; i < 8; i++) {
        pliage_boite(p);
        pliage_sphere(p, f);
        p = p * echelle + p0;
        f = f * abs(echelle) + 1.0;
    }
    return length(p) / f;
}

float dalles_pierre(vec2 p) {
    vec2 f = fract(p);
    float bordure = smoothstep(0.0, 0.08, f.x) * smoothstep(1.0, 0.92, f.x) *
                    smoothstep(0.0, 0.08, f.y) * smoothstep(1.0, 0.92, f.y);
    float rugosite = bruit(vec3(p * 4.0, 0.0)) * 0.03;
    return rugosite + (1.0 - bordure) * 0.06;
}

float carteGlobale(in vec3 pos) {
    float fractale = carteMandelbox(pos * 0.2 + vec3(0.0, 0.5, 0.0)) * 5.0;
    float relief_pierre = dalles_pierre(pos.xz * 0.4);
    float sol = pos.y + 2.0 + relief_pierre;
    return min(sol, fractale);
}

float marcheRayon(in vec3 ro, in vec3 rd) {
    float t = 0.01, tmax = 60.0;
    for (int i = 0; i < 200; i++) {
        float h = carteGlobale(ro + rd * t);
        if (h < 0.001 * t || t > tmax) break;
        t += h * 0.8;
    }
    return (t > tmax) ? -1.0 : t;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(18.0 * cos(0.05 * (iTime + 20.0)), 8.0 + 2.0 * sin(0.1 * (iTime + 20.0)), 18.0 * sin(0.06 * (iTime + 20.0)));
    vec3 ta = vec3(18.0 * cos(0.05 * (iTime + 23.0)), 3.0 + 2.0 * sin(0.1 * (iTime + 23.0)), 18.0 * sin(0.06 * (iTime + 23.0)));
    vec3 cw = normalize(ta - ro);
    vec3 cu = normalize(cross(cw, vec3(0, 1, 0)));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.7 * cw);
    
    float t = marcheRayon(ro, rd);
    fragColor = vec4(t, 0.0, 0.0, 1.0);
}
