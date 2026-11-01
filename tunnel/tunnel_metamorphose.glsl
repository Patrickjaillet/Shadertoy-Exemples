#define AA 1
#define PAS_MAX 200
#define PI 3.14159265
#define EPS_POIDS 0.0001

vec4 W1;
float W5;
float MELANGE;

vec3 ORB;
float ORB_R;
float ORB_I;
float ORB_PULSE;
vec3 ORB_COL;

vec3 CAM_O;
vec3 CAM_R;
vec3 CAM_U;
vec3 CAM_F;
float CAM_FOC;

mat2 rot(float b) {
    float c = cos(b), d = sin(b);
    return mat2(c, d, -d, c);
}

float tri(float f) {
    return abs(fract(f) - 0.5);
}

float hachage12(vec2 p) {
    vec3 p3 = fract(p.xyx * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 pliage(vec3 h) {
    return vec3(
        tri(h.z + tri(h.y)),
        tri(h.z + tri(h.x)),
        tri(h.y + tri(h.x))
    );
}

float turbulence(vec3 h, float j) {
    float t = iTime * 0.64;
    float k = 1.0, l = 0.1;
    vec3 m = h;
    for (int n = 0; n < 5; n++) {
        vec3 o = pliage(m);
        h += o + t * j;
        m *= 2.0;
        k *= 1.5;
        h *= 1.3;
        l += tri(h.z + tri(h.x + tri(h.y))) / k;
        m += 0.14;
    }
    return l;
}

float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

void poidsMorphing() {
    float cycle = mod(iTime, 75.0);
    float m1 = (1.0 - smoothstep(12.0, 15.0, cycle)) + smoothstep(72.0, 75.0, cycle);
    float m2 = smoothstep(12.0, 15.0, cycle) - smoothstep(27.0, 30.0, cycle);
    float m3 = smoothstep(27.0, 30.0, cycle) - smoothstep(42.0, 45.0, cycle);
    float m4 = smoothstep(42.0, 45.0, cycle) - smoothstep(57.0, 60.0, cycle);
    float m5 = smoothstep(57.0, 60.0, cycle) - smoothstep(72.0, 75.0, cycle);

    vec4 w = clamp(vec4(m1, m2, m3, m4), 0.0, 1.0);
    float w5 = clamp(m5, 0.0, 1.0);
    float s = w.x + w.y + w.z + w.w + w5;
    if (s > 0.0001) {
        w /= s;
        w5 /= s;
    } else {
        w = vec4(1.0, 0.0, 0.0, 0.0);
        w5 = 0.0;
    }
    W1 = w;
    W5 = w5;
    MELANGE = 2.0 * (1.0 - max(max(w.x, w.y), max(max(w.z, w.w), w5)));
}

vec2 chemin(float k) {
    vec2 r = vec2(0.0);
    if (W1.x > EPS_POIDS) r += vec2(sin(k * 0.12) * 3.5 + cos(k * 0.04) * 1.5, cos(k * 0.09) * 2.5 + sin(k * 0.13) * 1.2) * W1.x;
    if (W1.y > EPS_POIDS) r += vec2(sin(k * 0.06) * 8.0 + cos(k * 0.12) * 4.0, cos(k * 0.04) * 7.0 + sin(k * 0.09) * 3.5) * W1.y;
    if (W1.z > EPS_POIDS) r += vec2(sin(k * 0.11) * 2.2 + cos(k * 0.05) * 1.8, cos(k * 0.08) * 2.0 + sin(k * 0.14) * 1.3) * W1.z;
    if (W1.w > EPS_POIDS) r += vec2(sin(k * 0.15) * 6.0 + cos(k * 0.07) * 3.0, cos(k * 0.11) * 5.0 + sin(k * 0.03) * 2.5) * W1.w;
    if (W5 > EPS_POIDS) r += vec2(sin(k * 0.08) * 4.5 + cos(k * 0.14) * 2.2, cos(k * 0.06) * 3.8 + sin(k * 0.11) * 2.8) * W5;
    return r;
}

vec3 positionOrbe(float ab) {
    float orbZ = ab + 18.0 + sin(iTime * 0.7) * 5.0 + cos(iTime * 1.3) * 3.0;
    vec2 centre = chemin(orbZ);
    vec2 decalage = vec2(
        sin(iTime * 1.9) * 1.2 + cos(iTime * 3.1) * 0.6,
        cos(iTime * 2.3) * 1.0 + sin(iTime * 4.2) * 0.5
    );
    return vec3(centre + decalage, orbZ);
}

float tunnel(vec3 h) {
    vec2 r = chemin(h.z);
    vec3 s = h;
    s.xy -= r;
    float d = 0.0;

    if (W1.x > EPS_POIDS) {
        float t1 = 5.5 - length(s.xy);
        float u1 = turbulence(h * 0.25, 0.0);
        vec3 s1 = s;
        s1.xy *= rot(h.z * 0.1);
        float v1 = length(s1.xy + vec2(sin(h.z), cos(h.z)) * 1.5) - 0.8;
        d += (min(t1, v1) - u1 * 0.5) * W1.x;
    }

    if (W1.y > EPS_POIDS) {
        vec3 s2 = s;
        s2.xy *= rot(h.z * 0.15 + sin(h.z * 0.08) * 1.2);
        float hexOuter = -sdHexagon(s2.xy, 8.5 + sin(h.z * 0.3) * 1.2);
        vec3 pFractal = vec3(s2.xy * 0.4, h.z * 0.15);
        float fVal = turbulence(pFractal, 0.2);
        float ribs = sin(s2.x * 1.5) * sin(s2.y * 1.5) * sin(h.z * 1.2);
        vec3 corePos = s2;
        corePos.xy *= rot(h.z * 0.4);
        vec2 coreGrid = abs(mod(corePos.xy, 3.2) - 1.6);
        float corePillars = length(coreGrid) - 0.35;
        d += (min(hexOuter, corePillars) - fVal * 0.9 + ribs * 0.2) * W1.y;
    }

    if (W1.z > EPS_POIDS) {
        vec3 s3 = s;
        s3.xy *= rot(h.z * 0.2 + sin(h.z * 0.4) * 0.5);
        float angle = atan(s3.y, s3.x);
        float radius = length(s3.xy);
        float bioCavity = (4.5 + sin(angle * 5.0 + h.z * 0.8) * 0.8 + cos(angle * 3.0 - h.z * 0.5) * 0.6) - radius;
        vec3 bioNoisePos = vec3(s3.xy * 0.35, h.z * 0.25);
        float bioFBM = turbulence(bioNoisePos, 0.15);
        float organicFolds = sin(radius * 2.5 + h.z * 1.5) * sin(angle * 8.0) * 0.25;
        d += (bioCavity - bioFBM * 0.8 + organicFolds) * W1.z;
    }

    if (W1.w > EPS_POIDS) {
        vec3 s4 = s;
        s4.xy *= rot(h.z * 0.1 + cos(h.z * 0.08) * 0.4);
        float crystBound = 7.5 - length(s4.xy);
        float ringRadius = 4.8 + sin(h.z * 0.2) * 0.8;
        float angle = atan(s4.y, s4.x);
        float sector = PI / 4.0;
        float aSector = floor((angle + sector * 0.5) / sector) * sector;
        vec2 octCenter = ringRadius * vec2(cos(aSector), sin(aSector));
        vec3 octPos = s4;
        octPos.xy -= octCenter;
        octPos.z = mod(octPos.z + 3.0, 6.0) - 3.0;
        float octNodes = sdOctahedron(octPos, 0.95);
        vec3 latticePos = vec3(s4.xy * 0.3, h.z * 0.15);
        float crystFBM = turbulence(latticePos, 0.1);
        d += (min(crystBound, octNodes) - crystFBM * 0.3) * W1.w;
    }

    if (W5 > EPS_POIDS) {
        vec3 s5 = s;
        s5.xy *= rot(h.z * 0.12 + sin(h.z * 0.15) * 0.8);
        float ang = atan(s5.y, s5.x);
        float rad = length(s5.xy);
        float peristalsis = sin(h.z * 0.8 - iTime * 2.5) * 0.65;
        float sphincter = sin(ang * 6.0 + h.z * 0.4) * sin(ang * 3.0 - h.z * 0.2) * 0.55;
        float lumen = (5.2 + peristalsis + sphincter) - rad;
        vec3 bioPos = vec3(s5.xy * 0.45, h.z * 0.3);
        float bioNoise = turbulence(bioPos, 0.25);
        d += (lumen - bioNoise * 0.85) * W5;
    }

    return d;
}

float carte(vec3 h) {
    float d = tunnel(h);
    if (ORB_R > 0.01) d = min(d, length(h - ORB) - ORB_R);
    return d;
}

vec3 normale(vec3 p, float e) {
    vec2 k = vec2(1.0, -1.0);
    return normalize(
        k.xyy * carte(p + k.xyy * e) +
        k.yyx * carte(p + k.yyx * e) +
        k.yxy * carte(p + k.yxy * e) +
        k.xxx * carte(p + k.xxx * e)
    );
}

float occlusion(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 4; i++) {
        float h = 0.12 + 0.46 * float(i);
        float d = carte(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.72;
    }
    return clamp(1.0 - 0.5 * occ, 0.3, 1.0);
}

float ombreDouce(vec3 ro, vec3 rd, float maxt) {
    float res = 1.0;
    float t = 0.08;
    for (int i = 0; i < 22; i++) {
        float h = tunnel(ro + rd * t);
        res = min(res, 7.0 * h / t);
        t += clamp(h, 0.1, 2.2);
        if (res < 0.01 || t > maxt) break;
    }
    return smoothstep(0.0, 1.0, clamp(res, 0.0, 1.0));
}

void initialiserScene() {
    poidsMorphing();

    float t = iTime * 0.64;
    float ab = t * 14.0;

    ORB = positionOrbe(ab);
    ORB_PULSE = sin(iTime * 9.0 + sin(iTime * 3.0) * 2.0);
    float presence = W1.z + W1.w + W5;
    ORB_R = (1.0 + 0.35 * ORB_PULSE) * smoothstep(0.0, 0.4, presence);
    ORB_I = W1.z + W1.w * 0.5 + W5 * 0.8;
    ORB_COL = mix(vec3(1.0, 0.15, 0.3), vec3(1.0, 0.6, 0.1), 0.5 + 0.5 * ORB_PULSE);

    vec3 ac = vec3(chemin(ab), ab);
    float avance = dot(W1, vec4(8.0, 16.0, 10.0, 12.0)) + W5 * 11.0;
    vec3 ad = vec3(chemin(ab + avance), ab + avance);

    float ae = W1.x * sin(t * 0.2) * 0.5
             + W1.y * sin(t * 0.6) * 1.4
             + W1.z * sin(t * 0.4) * 0.8
             + W1.w * sin(t * 0.3) * 1.1
             + W5 * sin(t * 0.5) * 1.2;

    vec3 af = normalize(ad - ac);
    vec3 ag = vec3(sin(ae), cos(ae), sin(t * 0.5) * W1.y + cos(t * 0.7) * W5);
    vec3 ah = normalize(cross(af, ag));
    vec3 ai = normalize(cross(ah, af));

    CAM_O = ac;
    CAM_R = ah;
    CAM_U = ai;
    CAM_F = af;
    CAM_FOC = dot(W1, vec4(1.7, 0.85, 1.4, 1.1)) + W5 * 1.3;
}

vec3 rendu(vec2 fc, float dither) {
    vec2 aa = fc / iResolution.xy;
    vec2 h = aa - 0.5;
    h.x *= iResolution.x / iResolution.y;

    float t = iTime * 0.64;
    h += vec2(sin(t * 3.1) + sin(t * 5.3) * 0.5, sin(t * 2.7) + sin(t * 6.1) * 0.5) * 0.0018;

    vec3 rd = normalize(h.x * CAM_R + h.y * CAM_U + CAM_FOC * CAM_F);
    vec3 ro = CAM_O;

    float maxDist = dot(W1, vec4(50.0, 80.0, 60.0, 70.0)) + W5 * 65.0;
    float pasNominal = dot(W1, vec4(0.75, 0.65, 0.68, 0.65)) + W5 * 0.62;
    float pasEff = pasNominal * 0.8 * (1.0 - 0.3 * MELANGE);
    float ratioPas = pasEff / pasNominal;
    float lueurSeuil = dot(W1, vec4(0.35, 0.7, 0.5, 0.6)) + W5 * 0.6;
    float lueurCoef = dot(W1, vec4(0.09, 0.08, 0.12, 0.10)) + W5 * 0.14;

    float ak = dither * 0.03;
    float al = 0.0;
    float w = 0.0;
    for (int n = 0; n < PAS_MAX; n++) {
        w = carte(ro + rd * ak);
        float seuil = 0.002 + 0.0006 * ak;
        if (abs(w) < seuil || ak > maxDist) break;
        ak += max(w * pasEff, 0.002);
        al += max(0.0, lueurSeuil - w) * lueurCoef * ratioPas;
    }

    vec3 fondBiome = W1.x * vec3(0.002, 0.004, 0.008) + W1.y * vec3(0.001, 0.003, 0.008) + W1.z * vec3(0.008, 0.001, 0.004) + W1.w * vec3(0.006, 0.002, 0.008) + W5 * vec3(0.009, 0.003, 0.001);
    vec3 am = fondBiome;

    float pulseVal = 0.5 + 0.5 * ORB_PULSE;
    float intensiteOrbe = 0.88 + 0.12 * pulseVal;

    if (ak < maxDist) {
        vec3 an = ro + rd * ak;
        vec3 n = normale(an, 0.004 + 0.0008 * ak);
        vec3 L = normalize(W1.x * vec3(0.5, 0.8, -0.2) + W1.y * vec3(-0.2, 0.9, -0.4) + W1.z * vec3(-0.3, 0.7, -0.6) + W1.w * vec3(0.6, 0.6, -0.5) + W5 * vec3(-0.4, 0.8, -0.4));

        float uVal = turbulence(an * (dot(W1, vec4(0.1, 0.12, 0.15, 0.11)) + W5 * 0.18), 0.0);
        float aq = clamp(dot(n, L), 0.0, 1.0);
        float ar = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), dot(W1, vec4(3.0, 4.0, 3.5, 5.0)) + W5 * 2.5);
        float ao = occlusion(an, n);

        vec3 col1 = mix(vec3(0.05, 0.1, 0.25), vec3(0.4, 0.6, 0.8), uVal);
        vec3 col2 = mix(vec3(0.02, 0.2, 0.25), vec3(0.1, 0.8, 0.85), uVal);
        vec3 col3 = mix(vec3(0.2, 0.02, 0.08), vec3(0.85, 0.15, 0.35), uVal);
        vec3 col4 = mix(vec3(0.15, 0.02, 0.2), vec3(0.65, 0.25, 0.9), uVal);
        vec3 col5 = mix(vec3(0.25, 0.04, 0.01), vec3(0.95, 0.35, 0.05), uVal);
        vec3 albedo = col1 * W1.x + col2 * W1.y + col3 * W1.z + col4 * W1.w + col5 * W5;
        vec3 specCol = W1.x * vec3(0.7, 0.9, 1.0) + W1.y * vec3(0.3, 1.0, 0.9) + W1.z * vec3(1.0, 0.4, 0.6) + W1.w * vec3(0.9, 0.5, 1.0) + W5 * vec3(1.0, 0.6, 0.2);

        vec3 hv = normalize(L - rd);
        float spec = pow(max(dot(n, hv), 0.0), mix(24.0, 96.0, uVal)) * aq;

        vec3 lum = albedo * (aq * 0.9 + 0.015) + ar * specCol * 0.9 + spec * specCol * 0.18;
        lum *= ao;

        float distOrb = length(an - ORB);
        float surOrbe = 1.0 - smoothstep(ORB_R, ORB_R + 0.15, distOrb);

        if (ORB_I > 0.001 && distOrb < 60.0) {
            vec3 orbDir = (ORB - an) / distOrb;
            float vis = ombreDouce(an + n * 0.02, orbDir, max(distOrb - ORB_R, 0.1));
            float orbDiff = max(0.0, dot(n, orbDir));
            vec3 reflDir = reflect(-orbDir, n);
            float orbSpec = pow(max(0.0, dot(reflDir, -rd)), 16.0);
            float atten = 1.0 / (1.0 + distOrb * 0.15 + distOrb * distOrb * 0.05);
            vec3 eclairage = (ORB_COL * orbDiff * 2.5 + vec3(1.0, 0.8, 0.6) * orbSpec * 4.0) * atten * intensiteOrbe * vis;
            lum += eclairage * ORB_I * mix(0.55, 1.0, ao);

            vec3 rDir = reflect(rd, n);
            float rk = 0.1;
            float hitOrb = 0.0;
            for (int rs = 0; rs < 18; rs++) {
                float dO = length(an + rDir * rk - ORB) - ORB_R;
                if (dO < 0.02) { hitOrb = 1.0; break; }
                if (rk > 35.0) break;
                rk += dO;
            }
            float fresnel = pow(1.0 - clamp(dot(-rd, n), 0.0, 1.0), 3.0);
            lum = mix(lum, ORB_COL * 2.5, hitOrb * (0.4 + 0.6 * fresnel) * ORB_I * vis);
        }

        lum = mix(lum, ORB_COL * 3.5 * intensiteOrbe, surOrbe * clamp(ORB_I * 1.25, 0.0, 1.0));
        am = lum;
    }

    float at = length(h) * 0.15;
    vec3 glowCol = W1.x * vec3(1.0, 0.75, 0.5) + W1.y * vec3(0.1, 0.95, 0.85) + W1.z * vec3(1.0, 0.2, 0.4) + W1.w * vec3(0.8, 0.3, 1.0) + W5 * vec3(1.0, 0.4, 0.1);
    am += glowCol * al * max(0.4 - at, 0.0);

    float orbAlongRay = dot(ORB - ro, rd);
    if (orbAlongRay > 0.0 && ORB_I > 0.001) {
        vec3 closest = ro + rd * orbAlongRay;
        float gd = length(closest - ORB);
        float orbGlow = (0.4 + 0.3 * pulseVal) / (gd * gd + 0.08);
        float occ = orbAlongRay < ak ? 1.0 : exp(-(orbAlongRay - ak) * 0.9);
        am += ORB_COL * orbGlow * ORB_I * intensiteOrbe * occ * exp(-orbAlongRay * 0.025);
    }

    vec3 fogCol = W1.x * vec3(0.001, 0.002, 0.005) + W1.y * vec3(0.0, 0.005, 0.015) + W1.z * vec3(0.008, 0.001, 0.003) + W1.w * vec3(0.005, 0.001, 0.008) + W5 * vec3(0.01, 0.002, 0.001);
    float fogDensity = dot(W1, vec4(0.06, 0.025, 0.04, 0.035)) + W5 * 0.045;
    am = mix(am, fogCol, 1.0 - exp(-ak * fogDensity));

    return min(am, vec3(40.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    initialiserScene();

    vec3 acc = vec3(0.0);
    for (int j = 0; j < AA; j++) {
        for (int i = 0; i < AA; i++) {
            vec2 off = (vec2(float(i), float(j)) + 0.5) / float(AA) - 0.5;
            vec2 fc = fragCoord + off;
            float dith = hachage12(fc + vec2(iTime * 91.3) + float(i + j * AA) * 5.7);
            acc += rendu(fc, dith);
        }
    }
    vec3 col = acc / float(AA * AA);

    vec2 aa = fragCoord / iResolution.xy;
    vec2 uv0 = aa - 0.5;
    uv0.x *= iResolution.x / iResolution.y;
    float r2 = dot(uv0, uv0);
    col *= vec3(1.0 + r2 * 0.08, 1.0, 1.0 - r2 * 0.08);

    col = max(col, 0.0);
    vec3 fin = sqrt(col);

    float vig = 0.4 + 0.6 * pow(16.0 * aa.x * aa.y * (1.0 - aa.x) * (1.0 - aa.y), 0.35);
    fin *= vig;

    float luma = dot(fin, vec3(0.2126, 0.7152, 0.0722));
    fin = mix(vec3(luma), fin, 1.08);

    float grain = hachage12(fragCoord + fract(iTime) * 91.7) - 0.5;
    fin += grain * (2.0 / 255.0) * (1.3 - luma);
    fin += (hachage12(fragCoord + iTime * 57.3) - 0.5) / 255.0;

    float entree = smoothstep(0.0, 2.5, iTime * 0.64);
    fragColor = vec4(clamp(fin * entree, 0.0, 1.0), 1.0);
}
