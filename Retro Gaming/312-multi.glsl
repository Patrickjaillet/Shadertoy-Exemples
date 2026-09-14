// ==== Image (image) ====
#define DUREE_CYCLE 25.0
#define TEMPS_EXPLOSION 18.0
#define PI 3.14159265359

#define MAT_SOL 0.0
#define MAT_CORPS_MOTO 1.0
#define MAT_MOTEUR_LUM 2.0
#define MAT_TRAINEE 3.0
#define MAT_ROUE 5.0
#define MAT_LASER 6.0

float tBoucle;
float tExp;

mat2 rot(float a) { 
    float c=cos(a), s=sin(a); 
    return mat2(c,-s,s,c); 
}

float sdBoite(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdCylindre(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCylindreInfini(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return length(pa - ba*h) - r;
}

float aleatoire(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float obtenirMotoX(float t) {
    return sin(t * 1.5) * 1.5;
}

float obtenirInclinaison(float t) {
    return cos(t * 1.5) * 0.25;
}

vec2 carte(vec3 p) {
    float d = p.y;
    float mat = MAT_SOL;
    
    if(tBoucle > 17.8 && tBoucle < 18.5) {
        vec3 cible = vec3(obtenirMotoX(TEMPS_EXPLOSION), 0.5, 6.0);
        vec3 source = cible + vec3(-5.0, 8.0, 2.0);
        float dLaser = sdCylindreInfini(p, source, cible, 0.04);
        if(dLaser < d) { d = dLaser; mat = MAT_LASER; }
    }

    float distExpFonc = 1e10;
    if(tExp > 0.0) {
        vec3 posExp = vec3(obtenirMotoX(TEMPS_EXPLOSION), 0.5, 6.0);
        distExpFonc = length(p - posExp) - (tExp * 5.0 + 1.0);
    }
    
    if(distExpFonc > 0.1) {
        float motoZ = 6.0;
        if(p.z < motoZ && p.z > 0.5) {
            float tHist = tBoucle - ((motoZ - p.z) * 0.1); 
            float dTr = sdBoite(p - vec3(obtenirMotoX(tHist), 0.4, p.z), vec3(0.02, 0.4, 0.01));
            dTr += sin(p.z * 10.0 + tBoucle * 20.0) * 0.01;
            if(dTr < d) { d = dTr; mat = MAT_TRAINEE; }
        }
        
        if(tExp <= 0.0) {
            vec3 pM = p;
            pM.z -= motoZ;
            pM.x -= obtenirMotoX(tBoucle);
            pM.y -= sin(tBoucle * 10.0) * 0.02;
            
            float inc = obtenirInclinaison(tBoucle);
            float c=cos(inc), s=sin(inc);
            pM.xy *= mat2(c,-s,s,c);
            
            float corps = sdBoite(pM - vec3(0.0, 0.45, 0.0), vec3(0.12, 0.25, 0.7));
            corps = min(corps, sdBoite(pM - vec3(0.0, 0.65, -0.1), vec3(0.15, 0.15, 0.4)));
            
            float dRAr = sdCylindre(pM.zyx - vec3(-0.7, 0.25, 0.0), 0.12, 0.25);
            float dRAv = sdCylindre(pM.zyx - vec3(0.7, 0.25, 0.0), 0.1, 0.25);
            
            float guidon = sdBoite(pM - vec3(0.0, 0.75, 0.55), vec3(0.3, 0.02, 0.02));
            float motoD = min(min(corps, guidon), min(dRAr, dRAv));
            
            if(motoD < d) {
                d = motoD;
                mat = MAT_CORPS_MOTO;
                if(min(dRAr, dRAv) < 0.01) mat = MAT_ROUE;
                if(length(pM - vec3(0.0, 0.55, 0.75)) < 0.17) mat = MAT_MOTEUR_LUM;
            }
        }
    }
    return vec2(d, mat);
}

vec3 obtenirNormale(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(carte(p+e.xyy).x - carte(p-e.xyy).x, 
                        carte(p+e.yxy).x - carte(p-e.yxy).x, 
                        carte(p+e.yyx).x - carte(p-e.yyx).x));
}

float bruitVol(vec3 p) {
    p.z -= tExp * 2.0;
    float d = length(p);
    float f = 0.5 * aleatoire(p.xy + p.z);
    f += 0.25 * aleatoire(p.xy * 2.01 + p.z * 2.01);
    return f * exp(-d * 0.2);
}

vec4 renduExplosion(vec3 ro, vec3 rd, float dMax) {
    vec3 pE = vec3(obtenirMotoX(TEMPS_EXPLOSION), 0.5, 6.0);
    float r = tExp * 6.0 + 0.5;
    vec3 rc = ro - pE;
    float b = dot(rc, rd);
    float c = dot(rc, rc) - r * r;
    float h = b*b - c;
    if(h < 0.0) return vec4(0.0);
    float s = sqrt(h);
    float tEn = max(-b - s, 0.1);
    float tSo = min(-b + s, dMax);
    if(tEn >= tSo) return vec4(0.0);
    
    vec4 colV = vec4(0.0);
    float pas = 0.25;
    for(float t = tEn; t < tSo; t += pas) {
        vec3 pV = ro + rd * t;
        float dV = length(pV - pE);
        float den = smoothstep(r, r - 1.0, dV) * bruitVol(pV * 0.5 - pE) * exp(-tExp * 0.5);
        if(den > 0.01) {
            vec3 cF = mix(vec3(1.0, 0.1, 0.0), vec3(1.0, 0.9, 0.5), smoothstep(0.0, r * 0.3, dV));
            colV.rgb += cF * den * pas * 15.0;
            colV.a += den * pas * 2.0;
            if(colV.a > 0.95) break;
        }
    }
    return colV;
}

vec3 obtenirCouleurFond(vec2 uv, float rotC, float incC) {
    float hor = -0.15 + incC;
    if(uv.y < hor) return vec3(0.01, 0.0, 0.02);
    
    vec3 col = mix(vec3(0.05, 0.0, 0.1), vec3(0.0, 0.0, 0.02), (uv.y - hor) * 1.5);
    vec2 uvE = uv + vec2(rotC * 0.5, 0.0);
    col += vec3(step(0.996, aleatoire(uvE * 150.0 + tBoucle * 0.02))) * (0.6 + 0.4 * sin(tBoucle * 4.0));
    
    vec2 pS = vec2(-rotC * 1.5, hor + 0.4);
    float dS = length(uv - pS);
    if (dS < 0.28) {
        vec3 cS = mix(vec3(1.0, 1.0, 0.0), vec3(1.0, 0.0, 0.6), (uv.y - pS.y + 0.28) / 0.56);
        col = cS * step(0.1, sin(uv.y * 120.0 - tBoucle * 3.0)) + vec3(0.3, 0.09, 0.27);
    }
    col += vec3(1.0, 0.2, 0.7) * (0.015 / (abs(dS - 0.28) + 0.01));
    return col;
}

vec3 calculerImage(vec2 fC, float iT) {
    tBoucle = mod(iT, DUREE_CYCLE);
    tExp = max(0.0, tBoucle - TEMPS_EXPLOSION);
    vec2 uv = (fC.xy * 2.0 - iResolution.xy) / iResolution.y;
    
    float rC = sin(tBoucle * 0.5) * 0.7;
    float iC = cos(tBoucle * 0.3) * 0.04;
    
    vec3 ro = vec3(0.0, 0.7, 0.0);
    vec3 rd = normalize(vec3(uv, 1.3));
    
    mat2 rMatI = rot(-iC);
    mat2 rMatR = rot(-rC);
    rd.yz *= rMatI; rd.xz *= rMatR;
    
    float t = 0.1; float m = -1.0;
    for(int i = 0; i < 80; i++) {
        vec2 res = carte(ro + rd * t);
        if(res.x < 0.001 || t > 35.0) break;
        t += res.x; m = res.y;
    }
    
    vec3 col = vec3(0.0); 
    vec3 cFd = obtenirCouleurFond(uv, rC, iC);
    
    if(t < 35.0) {
        vec3 p = ro + rd * t; 
        vec3 n = obtenirNormale(p);
        col = cFd * 0.2;
        
        if(m == MAT_SOL) {
            vec2 uvG = p.xz + vec2(0.0, tBoucle * 10.0);
            vec2 l = abs(fract(uvG - 0.5) - 0.5) / fwidth(uvG);
            float g = 1.0 - min(min(l.x, l.y), 1.0);
            col += vec3(0.0, 0.8, 1.0) * g * smoothstep(0.1, 0.6, abs(n.y));
        } else if(m == MAT_CORPS_MOTO) {
            float sp = pow(max(dot(reflect(rd, n), normalize(vec3(1.0, 1.0, -1.0))), 0.0), 32.0);
            col = vec3(0.02) + vec3(0.5) * sp + cFd * pow(1.0 - max(dot(n, -rd), 0.0), 5.0) * 0.3;
        } else if(m == MAT_ROUE) {
            vec3 pRel = p - vec3(obtenirMotoX(tBoucle), 0.25, 6.0);
            float angle = atan(pRel.y, (p.z > 6.0 ? pRel.z - 0.7 : pRel.z + 0.7));
            col = mix(vec3(0.05), vec3(0.0, 0.8, 1.0), step(0.9, sin(angle * 10.0 + tBoucle * 50.0)));
        } else if(m == MAT_MOTEUR_LUM) {
            col = vec3(4.0, 2.4, 0.0); 
        } else if(m == MAT_TRAINEE) {
            col = vec3(0.0, 0.9, 1.0) * (0.4 + step(0.8, sin(p.z * 50.0 + tBoucle * 15.0)) * 0.6);
        } else if(m == MAT_LASER) {
            col = vec3(5.0, 0.0, 1.0);
        }
        col = mix(col, cFd, smoothstep(5.0, 35.0, t));
    } else col = cFd;
    
    if(tExp > 0.0) {
        vec4 cE = renduExplosion(ro, rd, t);
        col = col * (1.0 - cE.a) + cE.rgb + vec3(1.5, 1.2, 0.75) * exp(-tExp * 4.0);
    }
    
    return col * (1.0 - dot(uv, uv) * 0.35);
}

void mainImage(out vec4 fC, in vec2 fG) {
    vec3 cA = vec3(0.0);
    for(float i = 0.0; i < 4.0; i++) {
        cA += calculerImage(fG, iTime + (i * 0.01));
    }
    vec3 cF = cA * 0.25;
    cF *= (0.93 + 0.07 * sin(fG.y * 1.5 + iTime * 5.0));
    fC = vec4(pow(cF, vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
vec2 mainSound(int id, float temps) {
    float dureeCycle = 25.0;
    float tempsBoucle = mod(temps, dureeCycle);
    
    float tempsExplosion = 18.0;
    float tExp = max(0.0, tempsBoucle - tempsExplosion);
    
    float frequenceMoteur = 50.0 + sin(tempsBoucle * 1.5) * 5.0;
    float moteur = sin(6.2831 * frequenceMoteur * tempsBoucle + sin(6.2831 * 100.0 * tempsBoucle) * 0.5);
    moteur *= 0.15;
    
    float bruitVent = fract(sin(tempsBoucle * 437.12) * 98.45) * 2.0 - 1.0;
    float vent = bruitVent * 0.05 * (1.0 + sin(tempsBoucle * 0.5) * 0.5);
    
    float bruitExplosion = fract(sin(tempsBoucle * 1234.56) * 43758.54) * 2.0 - 1.0;
    float ondeChoc = sin(6.2831 * 40.0 * tExp) * exp(-tExp * 3.0);
    float impact = (bruitExplosion * exp(-tExp * 1.5) + ondeChoc) * step(0.001, tExp);
    impact = clamp(impact, -1.0, 1.0) * 0.8;
    
    float signalFinal = (moteur + vent) * (1.0 - step(0.001, tExp)) + impact;
    
    float facteurFondu = smoothstep(dureeCycle, dureeCycle - 2.0, tempsBoucle);
    signalFinal *= facteurFondu;
    
    return vec2(signalFinal);
}
