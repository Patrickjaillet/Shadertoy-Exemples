// ==== Image (image) ====
#define ETAPES 128
#define DIST_MAX 100.0
#define PI 3.14159265359
#define SATURER(x) clamp(x, 0.0, 1.0)

struct EtatMarche {
    float rebond, balancier, jambeG, jambeD, brasG, brasD, zG, zD;
};

mat2 rot(float a) { 
    float s = sin(a), c = cos(a); 
    return mat2(c, s, -s, c); 
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void calculerAnimation(float t, inout EtatMarche em) {
    float v = t * 4.5;
    em.rebond = 0.05 * abs(cos(v * 2.0)); 
    em.balancier = 0.06 * sin(v);
    em.jambeG = 0.4 * sin(v); 
    em.jambeD = -0.4 * sin(v);
    em.brasG = 0.6 * sin(v + PI * 0.5); 
    em.brasD = 0.6 * sin(v - PI * 0.5);
    em.zG = 0.2 * sin(v); 
    em.zD = -0.2 * sin(v);
}

float sdPerso(vec3 p, EtatMarche em) {
    vec3 pC = p;
    pC.y -= 0.6 + em.rebond; 
    pC.x -= em.balancier;
    
    float corps = length(pC / vec3(0.8, 1.1, 0.7)) - 0.6; 
    
    vec3 pO = pC; 
    pO.x = abs(pO.x) - 0.25; 
    pO.y -= 0.35;           
    pO.z -= 0.45;           
    float yeux = length(pO) - 0.12;
    
    vec3 pM = pC; 
    pM.y -= 0.1; 
    pM.z -= 0.45;
    float bouche = length(pM * vec3(1.0, 1.0, 0.5)) - 0.1;

    corps = min(corps, yeux); 
    corps = max(corps, -bouche); 

    vec3 pJG = pC - vec3(0.25, -0.6, em.zG);
    pJG.yz *= rot(em.jambeG);
    float jG = length(pJG * vec3(1.1, 0.8, 1.0)) - 0.22;
    
    vec3 pJD = pC - vec3(-0.25, -0.6, em.zD);
    pJD.yz *= rot(em.jambeD);
    float jD = length(pJD * vec3(1.1, 0.8, 1.0)) - 0.22;

    vec3 pBG = pC - vec3(0.5, 0.2, em.zD * 0.5);
    pBG.yz *= rot(em.brasG);
    float bG = length(pBG * vec3(1.0, 0.5, 1.0)) - 0.18;
    
    vec3 pBD = pC - vec3(-0.5, 0.2, em.zG * 0.5);
    pBD.yz *= rot(em.brasD);
    float bD = length(pBD * vec3(1.0, 0.5, 1.0)) - 0.18;
    
    float membres = smin(smin(jG, jD, 0.1), smin(bG, bD, 0.1), 0.1);
    return smin(corps, membres, 0.2);
}

float getWaves(vec2 p, float t) {
    float v = noise(p * 0.5 + t) * 0.2;
    v += noise(p * 1.5 - t * 0.5) * 0.05;
    return v;
}

float map(vec3 p, float t, EtatMarche em) {
    float d = sdPerso(p, em);
    float sol = p.y + 0.8 - getWaves(p.xz, t);
    float ciel = 6.0 - p.y - getWaves(p.xz, -t); 
    
    return min(d, min(sol, ciel));
}

vec3 getNormal(vec3 p, float t, EtatMarche em) {
    vec2 e = vec2(0.002, 0.0);
    return normalize(vec3(
        map(p + e.xyy, t, em) - map(p - e.xyy, t, em),
        map(p + e.yxy, t, em) - map(p - e.yxy, t, em),
        map(p + e.yyx, t, em) - map(p - e.yyx, t, em)
    ));
}

float getShadow(vec3 ro, vec3 rd, EtatMarche em) {
    float res = 1.0;
    float t_min = 0.05;
    for(int i = 0; i < 32; i++) {
        float d = sdPerso(ro + rd * t_min, em);
        if(d < 0.001) return 0.0;
        res = min(res, 12.0 * d / t_min);
        t_min += d * 0.8;
        if(t_min > 10.0) break;
    }
    return SATURER(res);
}

vec3 tonemap(vec3 x) {
    float a = 2.51; float b = 0.03; float c = 2.43; float d = 0.59; float e = 0.14;
    return SATURER((x*(a*x+b))/(x*(c*x+d)+e));
}

vec3 shadePBR(vec3 p, vec3 n, vec3 v, vec3 lPos, vec3 albedo, float rugosite, float shadow, vec3 lCol) {
    vec3 h = normalize(lPos + v);
    float ndotl = SATURER(dot(n, lPos));
    float ndoth = SATURER(dot(n, h));
    float fre = pow(1.0 - SATURER(dot(n, v)), 5.0);
    float spec = pow(ndoth, mix(256.0, 20.0, rugosite)) * (0.1 + 0.9 * fre);
    vec3 diffus = albedo * (ndotl * 0.8 + 0.2);
    return (diffus + spec) * lCol * shadow;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    float t = iTime;
    
    EtatMarche em;
    calculerAnimation(t, em);
    
    vec3 ro = vec3(3.5 * cos(t * 0.12), 1.8 + em.rebond, 4.5 + sin(t * 0.12));
    vec3 ta = vec3(0.0, 0.6, 0.0);
    vec3 cw = normalize(ta - ro), cu = normalize(cross(cw, vec3(0,1,0))), cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 2.0 * cw);
    
    float d = 0.0, dist = 0.0;
    for(int i = 0; i < ETAPES; i++) {
        d = map(ro + rd * dist, t, em);
        if(abs(d) < 0.0005 || dist > DIST_MAX) break; 
        dist += d * 0.7;
    }
    
    vec3 lPos = normalize(vec3(1.0, 4.0, 1.0)); 
    vec3 lCol = vec3(1.1, 1.25, 1.35); 
    vec3 colAmbiante = vec3(0.01, 0.04, 0.1); 
    vec3 col = colAmbiante;
    
    if(dist < DIST_MAX) {
        vec3 p = ro + rd * dist;
        vec3 n = getNormal(p, t, em);
        vec3 v = -rd;
        
        float dPerso = sdPerso(p, em);
        bool estPerso = dPerso < 0.02; 
        bool estCiel = p.y > 3.0; 
        
        vec3 albedo;
        float rugosite = 0.3, shadow = 1.0;
        
        if(estPerso) {
            vec3 pC = p - vec3(em.balancier, 0.6 + em.rebond, 0.0);

            vec3 pO = pC; 
            pO.x = abs(pO.x) - 0.25; 
            pO.y -= 0.35; 
            pO.z -= 0.45;
            float yeuxM = length(pO) - 0.14; 

            vec3 pM = pC; 
            pM.y -= 0.1; 
            pM.z -= 0.45;
            float boucheM = length(pM * vec3(1.0, 1.0, 0.5)) - 0.12;
            
            albedo = vec3(0.2, 0.6, 1.0); 
            if(yeuxM < 0.0 || boucheM < 0.0) { 
                albedo = vec3(0.005, 0.01, 0.03);
                rugosite = 0.05; 
            }
        } else {
            albedo = vec3(0.01, 0.08, 0.25);
            rugosite = 0.01;
            shadow = getShadow(p, lPos, em); 
            if(estCiel) shadow = mix(shadow, 1.0, 0.9); 
        }
        
        col = shadePBR(p, n, v, lPos, albedo, rugosite, shadow, lCol);
        
        if(estPerso) {
             col += vec3(0.05, 0.2, 0.5) * pow(SATURER(dot(v, -lPos)), 3.0); 
        } else {
            vec3 refrd = reflect(rd, n);
            refrd.y = estCiel ? abs(refrd.y) : -abs(refrd.y); 
            
            float dR = 0.0, distR = 0.0;
            for(int i = 0; i < 40; i++) { 
                dR = sdPerso(p + refrd * distR, em);
                if(dR < 0.001 || distR > 15.0) break;
                distR += dR * 0.8;
            }
            
            vec3 colRef = estCiel ? colAmbiante : colAmbiante * 0.3;
            if(distR < 15.0) {
                colRef = vec3(0.1, 0.4, 0.8) * shadow * SATURER(dot(refrd, lPos));
            }
            float fre = pow(1.0 - SATURER(dot(n, v)), estCiel ? 5.0 : 4.0); 
            col += colRef * fre * 0.5;
        }
    }
    
    col = mix(col, vec3(0.2, 0.5, 0.9), 1.0 - exp(-0.0006 * dist * dist)); 
    col = tonemap(col * 1.1);
    col = pow(col, vec3(0.4545));
    col *= 1.0 - dot(uv, uv) * 0.2; 
    col += (hash(uv + t) - 0.5) * 0.015; 
    
    fragColor = vec4(col, 1.0);
}
