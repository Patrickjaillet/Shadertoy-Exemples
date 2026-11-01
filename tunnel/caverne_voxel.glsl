#define LOIN 64.0
#define PI 3.14159265
#define AA 1
#define PAS_VOXEL 128
#define PAS_OMBRE 40
#define PAS_VOLUME 48

const vec3 COULEUR_LAMPE = vec3(1.0, 0.72, 0.42);
const vec3 COULEUR_FROID = vec3(0.35, 0.55, 0.95);
const vec3 COULEUR_BRUME = vec3(0.012, 0.016, 0.028);

mat3 matrice = mat3(0.00, 1.60, 1.20, -1.60, 0.72, -0.96, -1.20, -0.96, 1.28);

mat2 rotation2(float a) {
    vec2 v = sin(vec2(1.570796, 0.0) + a);
    return mat2(v, -v.y, v.x);
}

float hachage(float n) {
    n = fract(n * .1031);
    n *= n + 33.33;
    n *= n + n;
    return fract(n);
}

float hachage12(vec2 p) {
    vec3 p3 = fract(p.xyx * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hachage31(vec3 p) {
    p = fract(p * vec3(.1031, .1030, .0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

float bruit(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    return mix(
        mix(mix(hachage31(p), hachage31(p + vec3(1, 0, 0)), f.x),
            mix(hachage31(p + vec3(0, 1, 0)), hachage31(p + vec3(1, 1, 0)), f.x), f.y),
        mix(mix(hachage31(p + vec3(0, 0, 1)), hachage31(p + vec3(1, 0, 1)), f.x),
            mix(hachage31(p + vec3(0, 1, 1)), hachage31(p + vec3(1, 1, 1)), f.x), f.y),
        f.z);
}

float mbf(vec3 p) {
    float f = 0.5000 * bruit(p);
    p = matrice * p;
    f += 0.2500 * bruit(p);
    p = matrice * p;
    f += 0.1666 * bruit(p);
    return f / 0.9166;
}

float marche(float t) {
    return t * 1.1 + 1.6 * sin(t * .37) + .3 * sin(t * .91);
}

vec2 regard(float t) {
    float periode = 5.5;
    float k = floor(t / periode);
    float f = fract(t / periode);
    float a = smoothstep(.06, .16, f) * (1. - smoothstep(.5, .72, f));
    float b = smoothstep(.78, .84, f) * (1. - smoothstep(.9, .96, f));
    vec2 c1 = vec2(hachage(k) - .5, hachage(k + 7.3) - .5) * vec2(1.6, .5);
    vec2 c2 = vec2(hachage(k + 3.1) - .5, hachage(k + 11.7) - .5) * vec2(.6, .25);
    vec2 base = vec2(sin(t * .23) * .2 + sin(t * .57) * .07, sin(t * .19) * .06 - .05);
    vec2 tremble = vec2(sin(t * 7.3) + sin(t * 11.7) * .6, sin(t * 8.9) + sin(t * 13.1) * .5) * .0035;
    return base + c1 * a + c2 * b + tremble;
}

vec2 chemin(float z) {
    float a = sin(z * 0.11);
    float b = cos(z * 0.14);
    return vec2(a * 4.0 - b * 1.5, b * 1.7 + a * 1.5);
}

float geometrie(vec3 p) {
    p.xy -= chemin(p.z);
    float n = 5.0 - length(p.xy * vec2(1.0, 0.8));
    return min(p.y + 3.0, n);
}

vec3 tracageVoxel(vec3 origine, vec3 direction, out vec3 masque, out float t) {
    vec3 p = floor(origine);
    vec3 dirSecurisee = direction + step(abs(direction), vec3(1e-8)) * 1e-8;
    vec3 dirInverse = 1.0 / dirSecurisee;
    vec3 dirPas = sign(dirSecurisee);
    vec3 deltaT = dirInverse * dirPas;
    vec3 maxT = (p - origine + 0.5 + 0.5 * dirPas) * dirInverse;

    masque = vec3(0.0);
    bool touche = false;
    for (int i = 0; i < PAS_VOXEL; i++) {
        if (geometrie(p + 0.5) < 0.0) {
            touche = true;
            break;
        }
        if (min(maxT.x, min(maxT.y, maxT.z)) > LOIN) break;
        masque = step(maxT.xyz, maxT.yzx) * step(maxT.xyz, maxT.zxy);
        maxT += masque * deltaT;
        p += masque * dirPas;
    }
    t = touche ? dot(masque, (p - origine + 0.5 - 0.5 * dirPas) * dirInverse) : LOIN * 2.0;
    return p + 0.5;
}

float ombreVoxel(vec3 origine, vec3 direction, float fin) {
    vec3 p = floor(origine);
    vec3 dirSecurisee = direction + step(abs(direction), vec3(1e-8)) * 1e-8;
    vec3 dirInverse = 1.0 / dirSecurisee;
    vec3 dirPas = sign(dirSecurisee);
    vec3 deltaT = dirInverse * dirPas;
    vec3 maxT = (p - origine + 0.5 + 0.5 * dirPas) * dirInverse;

    for (int i = 0; i < PAS_OMBRE; i++) {
        if (geometrie(p + 0.5) < 0.0) return 0.0;
        if (min(maxT.x, min(maxT.y, maxT.z)) > fin) return 1.0;
        vec3 masque = step(maxT.xyz, maxT.yzx) * step(maxT.xyz, maxT.zxy);
        maxT += masque * deltaT;
        p += masque * dirPas;
    }
    return 1.0;
}

vec4 oaVoxel(vec3 p, vec3 d1, vec3 d2) {
    vec4 cote = vec4(geometrie(p + d1), geometrie(p + d2), geometrie(p - d1), geometrie(p - d2));
    vec4 coin = vec4(geometrie(p + d1 + d2), geometrie(p - d1 + d2), geometrie(p - d1 - d2), geometrie(p + d1 - d2));
    cote = step(cote, vec4(0.0));
    coin = step(coin, vec4(0.0));
    return 1.0 - (cote + cote.yzwx + max(coin, cote * cote.yzwx)) / 3.0;
}

float calculerOAVoxel(vec3 posVoxel, vec2 uv, vec3 direction, vec3 masque) {
    vec4 oa = oaVoxel(posVoxel - sign(direction + 1e-8) * masque, masque.zxy, masque.yzx);
    return mix(mix(oa.z, oa.w, uv.x), mix(oa.y, oa.x, uv.x), uv.y);
}

vec3 brdf(vec3 n, vec3 v, vec3 l, vec3 alb, float rug) {
    vec3 h = normalize(v + l);
    float NdL = max(dot(n, l), 0.0);
    float NdV = max(dot(n, v), 0.0001);
    float NdH = max(dot(n, h), 0.0);
    float VdH = max(dot(v, h), 0.0);
    float a = rug * rug;
    float a2 = a * a;
    float dn = NdH * NdH * (a2 - 1.0) + 1.0;
    float D = a2 / (PI * dn * dn + 1e-5);
    float k = (rug + 1.0) * (rug + 1.0) / 8.0;
    float G = (NdV / (NdV * (1.0 - k) + k)) * (NdL / (NdL * (1.0 - k) + k));
    float F = 0.04 + 0.96 * pow(1.0 - VdH, 5.0);
    float spec = D * G * F / (4.0 * NdV * NdL + 1e-4);
    return (alb * (1.0 - F) / PI + spec) * NdL;
}

float phaseHG(float c, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * c, 1.5));
}

float densite(vec3 p, float T) {
    float h = p.y - chemin(p.z).y + 3.0;
    float nuage = smoothstep(.45, .9, mbf(p * .13 + vec3(0., T * .03, T * .06)));
    float sol = exp(-max(h, 0.0) * .7) * .15;
    return .012 + nuage * .2 + sol;
}

vec4 renduVolumetrique(vec3 origine, vec3 direction, float distanceMax, vec3 lampe, float dither, float T, float flick) {
    float dt = distanceMax / float(PAS_VOLUME);
    float t = dt * dither;
    vec3 diff = vec3(0.0);
    float trans = 1.0;

    for (int i = 0; i < PAS_VOLUME; i++) {
        vec3 p = origine + direction * t;
        float dens = densite(p, T);

        vec3 vers = lampe - p;
        float dl = length(vers);
        vec3 dirL = vers / dl;

        float vis = step(0.0, geometrie(floor(mix(p, lampe, .25)) + .5))
                  * step(0.0, geometrie(floor(mix(p, lampe, .5)) + .5))
                  * step(0.0, geometrie(floor(mix(p, lampe, .75)) + .5));

        float c = dot(direction, dirL);
        float phase = mix(phaseHG(c, .6), phaseHG(c, -.2), .25);
        float att = 1.0 / (1.0 + dl * dl * .04);

        vec3 lum = COULEUR_LAMPE * flick * 28.0 * att * phase * vis;
        vec3 dcam = origine - p;
        vec3 amb = COULEUR_BRUME * 3.0 + COULEUR_FROID * .02 / (1.0 + dot(dcam, dcam) * .1);

        float ext = exp(-dens * dt);
        diff += trans * (1.0 - ext) * (lum + amb);

        float mote = step(.9965, hachage31(floor(p * 4.0 + vec3(0.0, T * .15, T * .1))));
        diff += trans * COULEUR_LAMPE * flick * att * vis * mote * dt * .8 * exp(-t * .15);

        trans *= ext;
        t += dt;
    }
    return vec4(diff, trans);
}

vec3 echantillon(vec3 ro, vec3 cu, vec3 cv, vec3 cw, float roll, vec2 uv, float dither, vec3 lampe, float flick, float T) {
    uv = rotation2(roll) * uv;
    vec3 rd = normalize(uv.x * cu + uv.y * cv + cw * 0.95);

    vec3 masque;
    float t;
    vec3 posVoxel = tracageVoxel(ro, rd, masque, t);

    vec3 surf = COULEUR_BRUME;

    if (t < LOIN) {
        vec3 ps = ro + rd * t;
        vec3 n0 = -(masque * sign(rd + 1e-8));
        vec3 f = fract(ps);
        vec2 uvf = f.yz * masque.x + f.zx * masque.y + f.xy * masque.z;

        float a = 1.0 - smoothstep(0.0, .14, uvf.x);
        float b = 1.0 - smoothstep(0.0, .14, 1.0 - uvf.x);
        float c = 1.0 - smoothstep(0.0, .14, uvf.y);
        float d = 1.0 - smoothstep(0.0, .14, 1.0 - uvf.y);
        vec3 bevel = masque.zxy * (b - a) + masque.yzx * (d - c);
        float bord = min(min(uvf.x, 1.0 - uvf.x), min(uvf.y, 1.0 - uvf.y));
        float bordSombre = mix(.8, 1.0, smoothstep(0.0, .06, bord));

        float b0 = bruit(ps * 9.0);
        vec3 g = vec3(bruit(ps * 9.0 + vec3(.1, 0, 0)) - b0,
                      bruit(ps * 9.0 + vec3(0, .1, 0)) - b0,
                      bruit(ps * 9.0 + vec3(0, 0, .1)) - b0) / .1;
        g -= n0 * dot(g, n0);

        float flaque = smoothstep(.5, .58, n0.y) * smoothstep(.5, .6, bruit(vec3(ps.x * .3, 7.0, ps.z * .3)));

        float hv = hachage31(posVoxel);
        float large = mbf(ps * .35);
        vec3 alb = mix(vec3(.10, .085, .075), vec3(.34, .29, .24), large);
        alb *= .85 + .15 * sin(ps.y * 3.0 + large * 6.0);
        alb *= .85 + .3 * hv;
        alb *= .85 + .3 * bruit(ps * 14.0);
        alb *= mix(1.0, .45, flaque);

        float rug = mix(.35 + .35 * bruit(ps * 5.0), .06, flaque);

        vec3 n = normalize(n0 + bevel * .75 - g * .25 * (1.0 - flaque));
        vec3 v = -rd;

        float ao = calculerOAVoxel(posVoxel, uvf, rd, masque);
        ao = ao * ao * (3.0 - 2.0 * ao) * bordSombre;

        vec3 jit = vec3(dither, fract(dither * 17.17 + .3), fract(dither * 31.7 + .7)) - .5;
        vec3 lJ = lampe + jit * .8;
        vec3 dL = lJ - ps;
        float dist = length(dL);
        dL /= dist;

        float vis = dot(n0, dL) > 0.0 ? ombreVoxel(ps + n0 * .02, dL, dist) : 0.0;
        vec3 rad = COULEUR_LAMPE * 60.0 * flick / (1.0 + dist * dist * .08);
        vec3 direct = brdf(n, v, dL, alb, rug) * rad * vis;

        vec3 pf = ro + vec3(0., .3, 0.);
        vec3 dF = pf - ps;
        float distF = length(dF);
        dF /= distF;
        vec3 radF = COULEUR_FROID * 3.0 / (1.0 + distF * distF * .6);
        vec3 fill = brdf(n, v, dF, alb, rug) * radF;

        vec3 amb = mix(COULEUR_FROID * .05, COULEUR_LAMPE * .12, exp(-dist * .08)) * alb;

        surf = direct * mix(1.0, ao, .6) + (fill + amb) * ao;
    }

    float dv = min(t, 48.0);
    vec4 vol = renduVolumetrique(ro, rd, dv, lampe, dither, T, flick);
    vec3 col = surf * vol.w + vol.rgb;
    col = mix(col, COULEUR_BRUME * 2.0, smoothstep(40.0, LOIN, t));

    float tl = dot(lampe - ro, rd);
    if (tl > 0.0 && tl < t) {
        vec3 cc = lampe - ro - rd * tl;
        float d2 = dot(cc, cc);
        float coeur = exp(-d2 * 80.0) * 8.0;
        float halo = .05 / (d2 + .05);
        col += COULEUR_LAMPE * (coeur + halo) * flick * vol.w;
    }

    return min(col, vec3(30.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float T = iTime;
    float z = marche(T) * 1.4 + 6.0;
    float sp = z * 4.2;

    vec3 centre = vec3(chemin(z), z);
    vec3 fw = normalize(vec3(chemin(z + 4.0), z + 4.0) - centre);
    vec3 ri = normalize(cross(fw, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(ri, fw);

    vec3 ro = centre + vec3(0.0, -1.3, 0.0)
            + up * (abs(sin(sp)) * .05 - .03 + sin(T * 1.3) * .008)
            + ri * (sin(sp) * .035);

    vec2 hl = regard(T);
    vec3 cw = normalize(fw + ri * hl.x + up * hl.y);
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 cv = cross(cu, cw);
    float roll = -hl.x * .07 + sin(sp) * .012 + sin(T * .9) * .004;

    float zl = z + 9.0;
    vec3 lampe = vec3(chemin(zl), zl) + vec3(sin(T * .5) * .8, 1.2 + cos(T * .7) * .4, 0.0);
    float flick = .94 + .06 * sin(T * 17.0) * sin(T * 6.1) + .02 * sin(T * 41.0);

    vec3 acc = vec3(0.0);
    for (int j = 0; j < AA; j++) {
        for (int i = 0; i < AA; i++) {
            vec2 off = (vec2(float(i), float(j)) + .5) / float(AA) - .5;
            vec2 fc = fragCoord + off;
            vec2 uv = (fc - .5 * iResolution.xy) / iResolution.y;
            float dith = hachage12(fc + vec2(T * 123.45) + float(i + j * AA) * 7.7);
            acc += echantillon(ro, cu, cv, cw, roll, uv, dith, lampe, flick, T);
        }
    }
    vec3 col = acc / float(AA * AA);

    vec2 uv0 = (fragCoord - .5 * iResolution.xy) / iResolution.y;
    float r2 = dot(uv0, uv0);
    col *= vec3(1.0 + r2 * .1, 1.0, 1.0 - r2 * .1);

    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);

    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));
    col = mix(vec3(luma), col, 1.1);
    col *= mix(vec3(0.94, 1.0, 1.08), vec3(1.06, 1.0, 0.92), smoothstep(0.1, 0.6, luma));

    vec3 fin = pow(max(col, 0.0), vec3(1.0 / 2.2));

    float vig = 1.0 - smoothstep(0.25, 1.05, length(uv0 * vec2(0.9, 1.1)));
    fin *= mix(0.35, 1.0, vig);

    float grain = hachage12(fragCoord + fract(T) * 91.7) - 0.5;
    fin += grain * (1.8 / 255.0) * (1.5 - luma);
    fin += (hachage12(fragCoord + T * 57.3) - 0.5) / 255.0;

    fragColor = vec4(clamp(fin, 0.0, 1.0), 1.0);
}
