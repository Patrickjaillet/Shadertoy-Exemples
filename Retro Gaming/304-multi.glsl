// ==== Image (image) ====
#define MAX_PAS 120
#define DIST_MAX 180.0
#define DIST_SURF 0.001
#define PI 3.14159265

#define COUL_FOND vec3(0.0, 0.0, 0.01)
#define COUL_GRILLE vec3(0.0, 1.0, 0.9)
#define COUL_SOLEIL vec3(0.0, 0.8, 1.0)
#define COUL_FUMEE vec3(1.0, 0.2, 0.0)
#define COUL_BROUILLARD vec3(0.0, 0.02, 0.05)

mat2 rotation(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hachage21(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 obtenirCouleur(float i) {
    vec3 p[8] = vec3[8](
        vec3(0.0, 1.0, 0.9),
        vec3(1.0, 0.0, 0.4),
        vec3(0.5, 0.0, 1.0),
        vec3(0.0, 0.5, 1.0),
        vec3(1.0, 0.5, 0.0),
        vec3(1.0, 1.0, 0.0),
        vec3(0.0, 1.0, 0.4),
        vec3(1.0, 0.0, 1.0)
    );
    return p[int(mod(i * 8.0, 8.0))];
}

float obtenirAngle(float t) {
    float shift_t = t + 1.0;
    float id = floor(shift_t / 2.0);
    float f = fract(shift_t / 2.0);
    
    float m0 = mod(id - 1.0, 4.0);
    float a0 = 0.0;
    if (m0 > 0.5 && m0 < 1.5) a0 = 1.0;
    if (m0 > 2.5 && m0 < 3.5) a0 = -1.0;
    
    float m1 = mod(id, 4.0);
    float a1 = 0.0;
    if (m1 > 0.5 && m1 < 1.5) a1 = 1.0;
    if (m1 > 2.5 && m1 < 3.5) a1 = -1.0;
    
    float diff = a1 - a0;
    if (diff > 1.5) diff -= 4.0;
    if (diff < -1.5) diff += 4.0;
    
    return (a0 + diff * smoothstep(0.4, 0.6, f)) * 1.57079632;
}

vec2 obtenirPosMonde(float t) {
    float cycle = floor(t / 8.0);
    float local_t = mod(t, 8.0);
    vec2 pos = vec2(0.0, cycle * 160.0);
    
    float t0 = clamp(local_t, 0.0, 2.0);
    pos += vec2(0.0, t0 * 40.0);
    
    float t1 = clamp(local_t - 2.0, 0.0, 2.0);
    pos += vec2(-t1 * 40.0, 0.0);
    
    float t2 = clamp(local_t - 4.0, 0.0, 2.0);
    pos += vec2(0.0, t2 * 40.0);
    
    float t3 = clamp(local_t - 6.0, 0.0, 2.0);
    pos += vec2(t3 * 40.0, 0.0);
    
    return pos;
}

float sdBoite(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float Carte(vec3 p) {
    float angle_monde = obtenirAngle(iTime);
    vec2 pos_monde = obtenirPosMonde(iTime);
    
    vec3 pw = p;
    pw.xz *= rotation(angle_monde);
    pw.xz += pos_monde;
    
    float sol = pw.y;
    
    vec2 id_bloc = floor(pw.xz / 30.0);
    vec3 p_b = pw;
    p_b.xz = mod(p_b.xz, 30.0) - 15.0;
    float h = 15.0 + hachage21(id_bloc) * 40.0;
    
    float batiments = sdBoite(p_b, vec3(12.0, h, 12.0));
    
    float couloirZ = sdBoite(p, vec3(18.0, 100.0, 1000.0));
    float couloirX = sdBoite(p, vec3(1000.0, 100.0, 18.0));
    batiments = max(batiments, -min(couloirZ, couloirX));
    
    vec3 pm = p;
    float inclinaison = (obtenirAngle(iTime + 0.1) - angle_monde) * 1.5;
    pm.xy *= rotation(inclinaison);
    float moto = min(sdBoite(pm, vec3(0.4, 0.2, 1.2)), sdBoite(pm - vec3(0.0, -0.15, 0.0), vec3(0.18, 0.45, 1.4)));
    
    return min(min(sol, batiments), moto);
}

vec3 Normale(vec3 p) {
    float d = Carte(p);
    vec2 e = vec2(0.01, 0);
    return normalize(d - vec3(Carte(p-e.xyy), Carte(p-e.yxy), Carte(p-e.yyx)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 uv_dist = uv * (1.0 + dot(uv, uv) * 0.15);
    
    float angle_monde = obtenirAngle(iTime);
    vec2 pos_monde = obtenirPosMonde(iTime);

    vec3 ro = vec3(0.0, 4.5, -16.0);
    vec3 rd = normalize(vec3(uv_dist.x, uv_dist.y - 0.1, 1.0));

    float dO = 0.0;
    float eclat = 0.0;
    
    for(int i=0; i<120; i++) {
        float dS = Carte(ro + rd * dO);
        eclat += 0.015 / (0.05 + abs(dS));
        dO += dS;
        if(dO > DIST_MAX || dS < DIST_SURF) break;
    }

    vec3 col = vec3(0.0);
    vec3 p = ro + rd * dO;

    if(dO < DIST_MAX) {
        vec3 n = Normale(p);
        vec3 pw = p;
        pw.xz *= rotation(angle_monde);
        pw.xz += pos_monde;
        vec2 id_bloc = floor(pw.xz / 30.0);
        
        if(p.y < 0.1) {
            vec2 g = abs(fract(pw.xz * 0.2) - 0.5) / max(fwidth(pw.xz * 0.2), 0.001);
            vec2 g2 = abs(fract(pw.xz * 1.0) - 0.5) / max(fwidth(pw.xz * 1.0), 0.001);
            
            col = mix(vec3(0.0), COUL_GRILLE * 0.1, (1.0 - min(g2.x, g2.y)));
            col = mix(col, COUL_GRILLE * 0.4, (1.0 - min(g.x, g.y)) * 0.8);
            col += COUL_GRILLE * exp(-abs(p.x) * 0.8) * 0.1;
        } else if (p.y > 0.1 && dO > 1.0) {
            col = vec3(0.01, 0.01, 0.02) + COUL_GRILLE * pow(1.0 + dot(rd, n), 2.0) * 0.5;
            
            vec2 cA = floor(pw.yz * 1.5);
            vec2 cB = floor(pw.xy * 1.5);
            
            float hA = hachage21(cA + hachage21(id_bloc) * 1000.0);
            float hB = hachage21(cB + hachage21(id_bloc) * 1000.0);
            
            float actA = max(0.0, sin(iTime * (0.3 + hA * 0.6) + hA * 10.0) * 0.5 + 0.5);
            float actB = max(0.0, sin(iTime * (0.3 + hB * 0.6) + hB * 10.0) * 0.5 + 0.5);
            
            vec3 colA = obtenirCouleur(hA);
            vec3 colB = obtenirCouleur(hB);
            
            vec2 g_b = abs(fract(pw.yz * 1.5) - 0.5) / max(fwidth(pw.yz * 1.5), 0.001);
            vec2 g_bx = abs(fract(pw.xy * 1.5) - 0.5) / max(fwidth(pw.xy * 1.5), 0.001);
            float lignes_bat = max(1.0 - min(g_b.x, g_b.y), 1.0 - min(g_bx.x, g_bx.y));
            
            vec3 colFen = mix(colB * actB, colA * actA, step(abs(n.z), abs(n.x)));
            col += colFen * lignes_bat * 3.0;
        } else {
            col = vec3(0.01) + COUL_GRILLE * pow(1.0 + dot(rd, n), 4.0);
        }
        col = mix(col, COUL_BROUILLARD, 1.0 - exp(-dO * 0.025));
    } else {
        vec2 skyUV = vec2(atan(rd.x, rd.z) / (2.0 * PI), rd.y);
        vec2 grilleCiel = skyUV * vec2(30.0, 15.0) + vec2(angle_monde*0.5, iTime * 0.02);
        vec2 gS = abs(fract(grilleCiel) - 0.5);
        col = mix(COUL_FOND, COUL_GRILLE * 0.15, smoothstep(0.48, 0.5, max(gS.x, gS.y)));
        
        vec2 id_ciel = floor(grilleCiel);
        float h_ciel = hachage21(id_ciel);
        if (h_ciel > 0.85 && rd.y > 0.0) {
            vec2 centre_grille = fract(grilleCiel) - 0.5;
            float etoile = length(centre_grille);
            float eclat_etoile = max(0.0, sin(iTime * 1.5 + h_ciel * 20.0));
            col += obtenirCouleur(h_ciel) * smoothstep(0.15, 0.0, etoile) * eclat_etoile * 2.5;
        }
        
        float soleil = length(rd.xy - vec2(0.0, 0.1));
        col += COUL_SOLEIL * smoothstep(0.5, 0.48, soleil) * 0.6;
        col += COUL_SOLEIL * exp(-soleil * 3.0) * 0.4;
        
        col = mix(COUL_BROUILLARD, col, smoothstep(0.0, 0.2, rd.y));
    }

    col += COUL_GRILLE * eclat * 0.06;

    vec3 accF = vec3(0.0);
    float opaF = 0.0;
    
    for(int i=0; i<45; i++) {
        float d_f = float(i) * (dO / 45.0);
        vec3 pv = ro + rd * d_f;
        if(d_f > dO) break;
        
        float dT = -pv.z / 40.0;
        if(dT > 0.0 && dT < 1.8) {
            vec2 w_s = obtenirPosMonde(iTime - dT);
            vec2 v_s = w_s - pos_monde;
            v_s *= rotation(-angle_monde);
            
            vec3 pt = pv - vec3(v_s.x, 0.6, v_s.y);
            float dc = length(pt.xy);
            
            float den = smoothstep(0.5 + dT*0.3, 0.0, dc) * smoothstep(1.8, 1.2, dT);
            if(den > 0.01) {
                accF += mix(COUL_FUMEE * 3.0, vec3(0.2, 0.0, 0.4), dT/1.8) * den * 0.3 * (1.0 - opaF);
                opaF += den * 0.3;
            }
        }
    }
    
    col = col * (1.0 - opaF) + accF;
    
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    col *= 0.95 + 0.05 * sin(fragCoord.y * 2.5);
    col += (hachage21(uv + mod(iTime, 10.0)) - 0.5) * 0.03;
    col *= smoothstep(1.5, 0.0, length(uv));
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}

// ==== Sound (sound) ====
float hachageAudio(float p) {
    return fract(sin(p * 127.1) * 43758.545);
}

vec2 mainSound( int samp, float time ) {
    float intervalle = 2.0;
    float pulsation = 0.7 + 0.3 * sin(time * 3.14159265 / intervalle);

    float freqBasse = 55.0 + sin(time * 0.5) * 2.0;
    float onde1 = sin(time * freqBasse * 6.2831853);
    float onde2 = sin(time * (freqBasse * 1.015) * 6.2831853);
    float basse = (onde1 + onde2) * 0.5;

    float freqMoyenne = 110.0 + pulsation * 5.0;
    float onde3 = sin(time * freqMoyenne * 6.2831853);
    
    float sonGauche = (basse * 0.8 + onde3 * 0.1) * pulsation;
    
    float tempsD = time - 0.015;
    float freqBasseD = 55.0 + sin(tempsD * 0.5) * 2.0;
    float onde1D = sin(tempsD * freqBasseD * 6.2831853);
    float onde2D = sin(tempsD * (freqBasseD * 1.015) * 6.2831853);
    float basseD = (onde1D + onde2D) * 0.5;
    
    float freqMoyenneD = 110.0 + pulsation * 5.0;
    float onde3D = sin(tempsD * freqMoyenneD * 6.2831853);
    
    float sonDroite = (basseD * 0.8 + onde3D * 0.1) * pulsation;
    
    sonGauche = sonGauche / (1.0 + abs(sonGauche));
    sonDroite = sonDroite / (1.0 + abs(sonDroite));
    
    float volume = min(time * 0.3, 1.0) * 0.6;
    
    return vec2(sonGauche, sonDroite) * volume;
}
