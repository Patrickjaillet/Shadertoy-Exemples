// ==== Image (image) ====
// by     : Patrick JAILLET
// GO!Toy : https://gotoy.xo.je
// Kymatix: https://kymatix.netlify.app
#define COUL_B vec3(0.00, 0.72, 1.00)
#define COUL_R vec3(1.00, 0.14, 0.04)
#define COUL_C vec3(0.00, 1.00, 0.85)
#define COUL_W vec3(1.00, 0.95, 0.80)

float distRect(vec2 p, vec2 c, vec2 dms){
    vec2 d = abs(p - c) - dms;
    return max(d.x, d.y);
}

float sdRectArrondi(vec2 p, vec2 c, vec2 dms, float r){
    vec2 d = abs(p - c) - dms + r;
    return length(max(d, 0.)) + min(max(d.x, d.y), 0.) - r;
}

vec3 barreNeon(vec2 uv, vec2 c, vec2 dms, vec3 col, float eclat){
    float d = distRect(uv, c, dms);
    return (1. - smoothstep(-.001, .004, d)) * col * eclat + step(d, 0.) * col * .12;
}

float seg7(vec2 p, int chiffre){
    float s = 0.;
    float epaisseur = 0.08, longueur = 0.18; 
    bool haut   = (chiffre==0||chiffre==2||chiffre==3||chiffre==5||chiffre==6||chiffre==7||chiffre==8||chiffre==9);
    bool milieu = (chiffre==2||chiffre==3||chiffre==4||chiffre==5||chiffre==6||chiffre==8||chiffre==9);
    bool bas    = (chiffre==0||chiffre==2||chiffre==3||chiffre==5||chiffre==6||chiffre==8||chiffre==9);
    bool gh     = (chiffre==0||chiffre==4||chiffre==5||chiffre==6||chiffre==8||chiffre==9);
    bool dh     = (chiffre==0||chiffre==1||chiffre==2||chiffre==3||chiffre==4||chiffre==7||chiffre==8||chiffre==9);
    bool gb     = (chiffre==0||chiffre==2||chiffre==6||chiffre==8);
    bool db     = (chiffre==0||chiffre==1||chiffre==3||chiffre==4||chiffre==5||chiffre==6||chiffre==7||chiffre==8||chiffre==9);

    vec2 q;
    if(haut)  { q=p-vec2(0., 1.8); s=max(s,step(max(abs(q.x)-longueur,abs(q.y)-epaisseur),0.)); }
    if(milieu){ q=p-vec2(0., 0.0); s=max(s,step(max(abs(q.x)-longueur,abs(q.y)-epaisseur),0.)); }
    if(bas)   { q=p-vec2(0.,-1.8); s=max(s,step(max(abs(q.x)-longueur,abs(q.y)-epaisseur),0.)); }
    if(gh)    { q=p-vec2(-.8, .9); s=max(s,step(max(abs(q.y)-longueur,abs(q.x)-epaisseur),0.)); }
    if(dh)    { q=p-vec2( .8, .9); s=max(s,step(max(abs(q.y)-longueur,abs(q.x)-epaisseur),0.)); }
    if(gb)    { q=p-vec2(-.8,-.9); s=max(s,step(max(abs(q.y)-longueur,abs(q.x)-epaisseur),0.)); }
    if(db)    { q=p-vec2( .8,-.9); s=max(s,step(max(abs(q.y)-longueur,abs(q.x)-epaisseur),0.)); }
    return s;
}

vec3 dessinerScore(vec2 uv, vec2 centre, float taille, float valeur, vec3 col){
    int v = clamp(int(valeur), 0, 99);
    int dizaines = v / 10;
    int unites = v - dizaines * 10;
    vec3 rendu = vec3(0.);
    float ratio = iResolution.x / iResolution.y;

    for(int i=0; i<2; i++){
        float decalageX = (float(i) - 0.5) * taille * 1.4; 
        vec2 local = (uv - centre - vec2(decalageX, 0.)) / vec2(taille / ratio, taille) * 2.;
        int digit = (i == 0) ? dizaines : unites;
        if(dizaines == 0 && i == 0) continue;
        float s = seg7(local, digit);
        rendu += s * col;
        float dist = length(local) * taille * 0.3;
        rendu += s * col * exp(-dist * 12.) * 0.6;
    }
    return rendu;
}

vec3 radar(vec2 uv, vec2 posP, vec2 posE, bool pMort, bool eMort){
    vec2 rc = vec2(.5, .058); vec2 dmsR = vec2(.055, .038);
    if(distRect(uv, rc, dmsR) > 0.) return vec3(0.);
    vec2 local = (uv - rc) / dmsR;
    vec3 col = vec3(0., .04, .08);
    vec2 grille = abs(fract(local * 3.) - .5);
    col += (1. - smoothstep(0., .05, min(grille.x, grille.y))) * vec3(0., .08, .14) * .6;
    float bordure = max(abs(local.x), abs(local.y));
    col += (1. - smoothstep(.92, .98, bordure)) * COUL_C * .15;
    vec2 pp = posP / 40.; vec2 ep = posE / 40.;
    float dp = length(local - pp * vec2(1., -1.));
    float de = length(local - ep * vec2(1., -1.));
    col += (1. - smoothstep(0., .09, dp)) * COUL_B * (pMort ? .15 : .9);
    col += (1. - smoothstep(0., .09, de)) * COUL_R * (eMort ? .15 : .9);
    col += (1. - smoothstep(0., .18, dp)) * COUL_B * (pMort ? .05 : .25);
    col += (1. - smoothstep(0., .18, de)) * COUL_R * (eMort ? .05 : .25);
    return col;
}

float ligneBalayage(vec2 fc){ return .93 + .07 * sin(fc.y * 3.14); }

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = fragCoord / iResolution.xy;
    vec2 fc = fragCoord;
    vec3 col = texture(iChannel0, uv).rgb;

    vec4 etat  = texelFetch(iChannel1, ivec2(2,0), 0);
    vec4 jHist = texelFetch(iChannel1, ivec2(3,0), 0);
    vec4 eHist = texelFetch(iChannel1, ivec2(4,0), 0);
    vec4 jPos  = texelFetch(iChannel1, ivec2(0,0), 0);
    vec4 ePos  = texelFetch(iChannel1, ivec2(1,0), 0);
    vec4 scores = texelFetch(iChannel1, ivec2(5,0), 0);

    float demarre = etat.x, joueurMort = etat.y, ennemiMort = etat.z, chrono = etat.w;
    float longJ = jHist.y, longE = eHist.y;
    float scoreJ = scores.x, scoreE = scores.y;

    float hudY = .027;
    col += (1. - step(0., distRect(uv, vec2(.5, .973), vec2(.5, hudY)))) * vec3(0., .05, .10) * .9;

    col += barreNeon(uv, vec2(.12, .973), vec2(.10, .012), COUL_B, joueurMort > .5 ? .2 : .9);
    float ratioJ = clamp(longJ / 512., 0., 1.);
    col += barreNeon(uv, vec2(.04 + ratioJ * .16, .944), vec2(ratioJ * .16 + .002, .006), COUL_B, .7);

    col += barreNeon(uv, vec2(.88, .973), vec2(.10, .012), COUL_R, ennemiMort > .5 ? .2 : .9);
    float ratioE = clamp(longE / 512., 0., 1.);
    col += barreNeon(uv, vec2(.96 - ratioE * .16, .944), vec2(ratioE * .16 + .002, .006), COUL_R, .7);

    col += (1. - smoothstep(0., .003, abs(uv.x - .5))) * step(.947, uv.y) * COUL_C * .4;

    col += dessinerScore(uv, vec2(.30, .968), .022, scoreJ, COUL_B);
    col += dessinerScore(uv, vec2(.70, .968), .022, scoreE, COUL_R);

    col += radar(uv, jPos.xy, ePos.xy, joueurMort > .5, ennemiMort > .5);

    if(demarre < .5){
        col *= .25;
        float battement = .6 + .4 * sin(iTime * 2.5);
        float battement2 = .6 + .4 * sin(iTime * 3.1 + 1.2);
        vec2 g = abs(fract(uv * 18.) - .5);
        col += (1. - smoothstep(0., .06, min(g.x, g.y))) * vec3(0., .15, .30) * .4 * battement;
        col += exp(-dot(uv - .5, uv - .5) * 5.) * battement * COUL_B * .7;
        col += (1. - smoothstep(0., .006, abs(uv.y - .50))) * COUL_C * .8 * battement;
        col += (1. - smoothstep(0., .012, abs(uv.y - .50))) * COUL_C * .3 * battement;
        col += (1. - smoothstep(0., .004, abs(uv.y - .42))) * COUL_B * .5 * battement2;
        col += (1. - smoothstep(0., .002, abs(uv.y - .35))) * COUL_C * .2 * battement2;
        col += (1. - smoothstep(0., .002, abs(uv.y - .57))) * COUL_R * .2 * battement;
    }

    if(joueurMort > .5 || ennemiMort > .5){
        bool joueurGagne = (ennemiMort > .5 && joueurMort < .5);
        bool ennemiGagne = (joueurMort > .5 && ennemiMort < .5);
        vec3 coulVictoire = joueurGagne ? COUL_B : (ennemiGagne ? COUL_R : COUL_W);
        vec3 coulDefaite  = joueurGagne ? COUL_R : (ennemiGagne ? COUL_B : COUL_W);

        float t = mod(iTime, 100.0);
        float assombrir = smoothstep(0., .4, t) * .82;
        col = mix(col, col * .08, assombrir);

        float eclat = exp(-t * 4.) * .9;
        col += eclat * coulVictoire * exp(-dot(uv - .5, uv - .5) * 3.);

        float dist = length(uv - .5) * .7;
        for(int w=0; w<3; w++){
            float wt = t - float(w) * .25;
            float onde = exp(-pow(dist - wt * .6, 2.) * 80.) * exp(-wt * 2.);
            col += onde * coulVictoire * (.8 - float(w) * .2);
        }

        float balayage = smoothstep(0., .5, t);
        float scanY = uv.y - balayage * 1.2 + .1;
        col += exp(-scanY * scanY * 60.) * coulVictoire * .3 * smoothstep(.1, .4, t);

        float bord = min(min(uv.x, 1. - uv.x), min(uv.y, 1. - uv.y));
        col += exp(-bord * 30.) * (.4 + .6 * sin(iTime * 8.)) * coulVictoire * .8;

        float strob = step(.5, fract(uv.y * 10. + iTime * .6)) * smoothstep(.05, .3, t) * .06;
        col += strob * coulVictoire;

        float alphaPanneau = smoothstep(.5, .9, t);
        if(alphaPanneau > 0.01){
            float rect = sdRectArrondi(uv, vec2(.5, .5), vec2(.28, .14), .006);
            float masqueP = 1. - smoothstep(-.002, .002, rect);
            col = mix(col, vec3(0., .03, .08), masqueP * alphaPanneau * .95);
            float contour = (1. - smoothstep(-.004, .004, rect)) - (1. - smoothstep(-.002, .002, rect));
            col += contour * coulVictoire * alphaPanneau * 2.;
            float ligneY = .535;
            col += masqueP * (1. - smoothstep(0., .004, abs(uv.y - ligneY - .02))) * coulVictoire * alphaPanneau * .9;
            col += masqueP * (1. - smoothstep(0., .003, abs(uv.y - .47))) * coulDefaite * alphaPanneau * .5;
            col += masqueP * coulVictoire * (.03 + .03 * sin(iTime * 4.)) * alphaPanneau;
        }

        float clignote = step(.5, fract(iTime * .8));
        float relanceY = .3;
        col += clignote * (1. - smoothstep(0., .004, abs(uv.y - relanceY))) * COUL_C * alphaPanneau * .6;
        col += clignote * (1. - smoothstep(0., .002, abs(uv.y - relanceY - .012))) * COUL_C * alphaPanneau * .2;
    }

    float bordureExt = min(min(uv.x, 1. - uv.x), min(uv.y, 1. - uv.y));
    col += exp(-bordureExt * 22.) * .2 * COUL_B * .25;

    col *= ligneBalayage(fc);
    fragColor = vec4(pow(clamp(col, 0., 2.), vec3(.8)), 1.);
}

// ==== Buffer A (buffer) ====
#define TRAINEE_MAX   512
#define LIGNE_TRAINEE_J 1
#define LIGNE_TRAINEE_E 2
#define VITESSE       0.55
#define VITESSE_ROT   0.09
#define DIST_COL      0.8
#define MOITIE_GRILLE 40.0
#define PAS_TRAINEE   2

vec4 charger(ivec2 p){ return texelFetch(iChannel0, p, 0); }
bool dansArene(vec2 p){ return abs(p.x) < MOITIE_GRILLE && abs(p.y) < MOITIE_GRILLE; }
vec2 dirAngle(float a){ return vec2(cos(a), sin(a)); }

bool touche(int c){ return texelFetch(iChannel1, ivec2(c, 0), 0).x > 0.; }
bool toucheGauche(){ return touche(37) || touche(81) || touche(65); }
bool toucheDroite(){ return touche(39) || touche(68); }
bool toucheAction(){ return toucheGauche() || toucheDroite(); }

bool collisionTrainee(vec2 pos, int ligne, int longueur){
    for(int i=0; i < TRAINEE_MAX; i++){
        if(i >= longueur) break;
        vec4 t = texelFetch(iChannel0, ivec2(i, ligne), 0);
        if(t.w < 0.5) continue;
        if(distance(pos, t.xy) < DIST_COL) return true;
    }
    return false;
}

float angleIA(vec2 pe, float ae, vec2 pj, int longJ, int longE){
    float meilleur = -1e9; 
    float bAngle = ae;
    for(int t=-2; t<=2; t++){
        float testA = ae + float(t) * VITESSE_ROT * 1.5;
        vec2 dir = dirAngle(testA);
        float score = 0.;
        vec2 actuel = pe;
        for(int s=1; s<=20; s++){
            actuel += dir * VITESSE * 2.;
            if(!dansArene(actuel)) { score -= 80.; break; }
            if(collisionTrainee(actuel, LIGNE_TRAINEE_E, longE)) { score -= 50.; break; }
            if(collisionTrainee(actuel, LIGNE_TRAINEE_J, longJ)) { score -= 30.; break; }
            score += 1.;
        }
        vec2 versJ = normalize(pj - pe + vec2(0.001));
        score += dot(versJ, dir) * 3.;
        if(t == 0) score += 2.;
        if(score > meilleur){ meilleur = score; bAngle = testA; }
    }
    return bAngle;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    ivec2 ifc = ivec2(fragCoord);

    vec4 etatJ = charger(ivec2(0,0));
    vec4 etatE = charger(ivec2(1,0));
    vec4 drapeaux = charger(ivec2(2,0));
    vec4 histJ = charger(ivec2(3,0));
    vec4 histE = charger(ivec2(4,0));
    vec4 scores = charger(ivec2(5,0));

    vec2  posJ = etatJ.xy; float angleJ = etatJ.z;
    vec2  posE = etatE.xy; float angleE = etatE.z;
    float demarre = drapeaux.x, jMort = drapeaux.y, eMort = drapeaux.z, chrono = drapeaux.w;
    int   jTete = int(histJ.x), jLong = int(histJ.y);
    int   eTete = int(histE.x), eLong = int(histE.y);
    float scoreJ = scores.x, scoreE = scores.y;

    bool initialisation = (iFrame == 0);
    bool finDePartie = (jMort > 0.5 || eMort > 0.5);
    if(finDePartie && iMouse.z > 0.5) initialisation = true;

    if(initialisation){
        if(iFrame > 0 && finDePartie){
            if(eMort > 0.5 && jMort < 0.5) scoreJ += 1.;
            if(jMort > 0.5 && eMort < 0.5) scoreE += 1.;
        }
        posJ = vec2(-18., 0.); angleJ = 0.;
        posE = vec2( 18., 0.); angleE = 3.14159;
        demarre = 0.; jMort = 0.; eMort = 0.; chrono = 0.;
        jTete = 0; jLong = 0; eTete = 0; eLong = 0;
    }

    if(demarre < 0.5 && toucheAction()) demarre = 1.;

    if(!initialisation && demarre > 0.5 && jMort < 0.5){
        if(toucheGauche()) angleJ -= VITESSE_ROT;
        if(toucheDroite()) angleJ += VITESSE_ROT;
    }

    if(!initialisation && demarre > 0.5 && jMort < 0.5 && eMort < 0.5){
        chrono += 1.;
        bool etapeTrainee = (mod(chrono, float(PAS_TRAINEE)) < 0.5);

        angleE = angleIA(posE, angleE, posJ, jLong, eLong);

        vec2 dirJ = dirAngle(angleJ);
        vec2 dirE = dirAngle(angleE);
        vec2 nPosJ = posJ + dirJ * VITESSE * float(PAS_TRAINEE);
        vec2 nPosE = posE + dirE * VITESSE * float(PAS_TRAINEE);

        bool collisionJ = !dansArene(nPosJ)
                       || collisionTrainee(nPosJ, LIGNE_TRAINEE_J, jLong)
                       || collisionTrainee(nPosJ, LIGNE_TRAINEE_E, eLong);
        bool collisionE = !dansArene(nPosE)
                       || collisionTrainee(nPosE, LIGNE_TRAINEE_E, eLong)
                       || collisionTrainee(nPosE, LIGNE_TRAINEE_J, jLong);
        bool faceAFace = distance(nPosJ, nPosE) < 1.3;

        if(collisionJ || faceAFace) jMort = 1.;
        if(collisionE || faceAFace) eMort = 1.;

        if(etapeTrainee){
            int nTeteJ = int(mod(float(jTete) + 1., float(TRAINEE_MAX)));
            int nTeteE = int(mod(float(eTete) + 1., float(TRAINEE_MAX)));

            if(ifc.y == LIGNE_TRAINEE_J && ifc.x == nTeteJ && jMort < 0.5){
                fragColor = vec4(posJ, angleJ, 1.); return;
            }
            if(ifc.y == LIGNE_TRAINEE_E && ifc.x == nTeteE && eMort < 0.5){
                fragColor = vec4(posE, angleE, 1.); return;
            }

            jTete = nTeteJ; jLong = min(jLong + 1, TRAINEE_MAX);
            eTete = nTeteE; eLong = min(eLong + 1, TRAINEE_MAX);
        }
        posJ = nPosJ; posE = nPosE;
    }

    if(ifc == ivec2(0,0)){ fragColor = vec4(posJ, angleJ, 0.); return; }
    if(ifc == ivec2(1,0)){ fragColor = vec4(posE, angleE, 0.); return; }
    if(ifc == ivec2(2,0)){ fragColor = vec4(demarre, jMort, eMort, chrono); return; }
    if(ifc == ivec2(3,0)){ fragColor = vec4(float(jTete), float(jLong), 0., 0.); return; }
    if(ifc == ivec2(4,0)){ fragColor = vec4(float(eTete), float(eLong), 0., 0.); return; }
    if(ifc == ivec2(5,0)){ fragColor = vec4(scoreJ, scoreE, 0., 0.); return; }

    if(ifc.y == LIGNE_TRAINEE_J || ifc.y == LIGNE_TRAINEE_E){
        fragColor = initialisation ? vec4(-999., -999., 0., 0.) : texelFetch(iChannel0, ifc, 0);
        return;
    }
    fragColor = texelFetch(iChannel0, ifc, 0);
}

// ==== Buffer B (buffer) ====
#define MOITIE_GRILLE 40.0
#define TRAINEE_MAX   512
#define LIGNE_TRAINEE_P 1
#define LIGNE_TRAINEE_E 2

void mainImage(out vec4 couleurFragment, in vec2 coordFragment){
    vec2 posGrille = (coordFragment / iResolution.xy) * (MOITIE_GRILLE * 2.0) - MOITIE_GRILLE;

    vec4 histJ = texelFetch(iChannel0, ivec2(3,0), 0);
    vec4 histE = texelFetch(iChannel0, ivec2(4,0), 0);
    int longJ = int(histJ.y), longE = int(histE.y);

    float distP = 1e9, distE = 1e9;
    for(int i=0; i<TRAINEE_MAX; i++){
        if(i < longJ){
            vec4 t = texelFetch(iChannel0, ivec2(i, LIGNE_TRAINEE_P), 0);
            if(t.w > 0.5) distP = min(distP, length(posGrille - t.xy));
        }
        if(i < longE){
            vec4 t = texelFetch(iChannel0, ivec2(i, LIGNE_TRAINEE_E), 0);
            if(t.w > 0.5) distE = min(distE, length(posGrille - t.xy));
        }
    }
    
    couleurFragment = vec4(distP / (MOITIE_GRILLE * 2.0), distE / (MOITIE_GRILLE * 2.0), 0., 1.);
}

// ==== Buffer C (buffer) ====
#define MOITIE_GRILLE 40.0
#define TRAINEE_MAX   512
#define LIGNE_TRAINEE_P 1
#define LIGNE_TRAINEE_E 2
#define ETAPES_MAX    100
#define DIST_MAX      200.0
#define DIST_SURF     0.015
#define COUL_BLEU     vec3(0.00,0.72,1.00)
#define COUL_ROUGE    vec3(1.00,0.14,0.04)
#define COUL_GRILLE   vec3(0.00,0.13,0.22)

vec2 dirAngle(float a){ return vec2(cos(a),sin(a)); }

float sdBoite(vec3 p, vec3 b){
    vec3 q = abs(p) - b;
    return length(max(q,0.)) + min(max(q.x,max(q.y,q.z)),0.);
}

float sdCyl(vec3 p, float r, float h){
    vec2 d = vec2(length(p.xz)-r, abs(p.y)-h);
    return min(max(d.x,d.y),0.) + length(max(d,0.));
}

float sdMoto(vec3 p, vec2 centre, float angle){
    vec2 dirFwd = dirAngle(angle);
    vec3 cp = vec3(centre.x, 0., centre.y);
    float ag = atan(dirFwd.x, dirFwd.y);
    float ca = cos(ag), sa = sin(ag);
    vec3 lp = p - cp;
    lp = vec3(ca*lp.x - sa*lp.z, lp.y, sa*lp.x + ca*lp.z);
    float corps = sdBoite(lp-vec3(0.,.45,0.), vec3(.36,.26,1.02));
    float cockpit = sdBoite(lp-vec3(0.,.88,-.05), vec3(.20,.18,.50));
    float aileron = sdBoite(lp-vec3(0.,1.08,0.), vec3(.035,.20,.68));
    float rAV_G = sdCyl(lp-vec3( .46,.24, .82), .27,.11);
    float rAV_D = sdCyl(lp-vec3(-.46,.24, .82), .27,.11);
    float rAR_G = sdCyl(lp-vec3( .46,.24,-.82), .27,.11);
    float rAR_D = sdCyl(lp-vec3(-.46,.24,-.82), .27,.11);
    return min(min(min(corps,cockpit),min(aileron,min(rAV_G,rAV_D))),min(rAR_G,rAR_D));
}

float murTrainee(vec3 p, int ligne, int longueur){
    float d = 1e9;
    vec4 prec = vec4(-9999.,-9999.,0.,0.);
    for(int i=0; i<TRAINEE_MAX; i++){
        if(i>=longueur) break;
        vec4 t = texelFetch(iChannel0, ivec2(i,ligne), 0);
        if(t.w>0.5 && prec.w>0.5 && distance(prec.xy,t.xy)>0.05){
            vec3 a = vec3(prec.x, 0., prec.y);
            vec3 b = vec3(t.x, 0., t.y);
            vec3 mil = (a+b)*.5;
            vec3 seg = b-a; 
            float longSeg = length(seg)+.001;
            float ag = atan(seg.x/longSeg, seg.z/longSeg);
            float ca = cos(-ag), sa = sin(-ag);
            vec3 rp = p - mil;
            rp = vec3(ca*rp.x - sa*rp.z, rp.y, sa*rp.x + ca*rp.z);
            d = min(d, sdBoite(rp, vec3(.10, 1.3, longSeg*.5+.06)));
        }
        prec = t;
    }
    return d;
}

float murArene(vec3 p){
    float H = MOITIE_GRILLE, ht = 5., ep = .6;
    float d = sdBoite(p-vec3( H+ep,ht,0.), vec3(ep,ht,H+ep));
    d = min(d, sdBoite(p-vec3(-H-ep,ht,0.), vec3(ep,ht,H+ep)));
    d = min(d, sdBoite(p-vec3(0.,ht, H+ep), vec3(H+ep,ht,ep)));
    d = min(d, sdBoite(p-vec3(0.,ht,-H-ep), vec3(H+ep,ht,ep)));
    return d;
}

vec2 CARTE(vec3 p){
    vec4 pS = texelFetch(iChannel0,ivec2(0,0),0);
    vec4 eS = texelFetch(iChannel0,ivec2(1,0),0);
    vec4 fl = texelFetch(iChannel0,ivec2(2,0),0);
    vec4 pH = texelFetch(iChannel0,ivec2(3,0),0);
    vec4 eH = texelFetch(iChannel0,ivec2(4,0),0);
    int pLong = int(pH.y), eLong = int(eH.y);

    vec2 res = vec2(p.y, 0.);

    float ma = murArene(p);
    if(ma < res.x) res = vec2(ma, 1.);

    if(fl.y < .5){ float motoP = sdMoto(p,pS.xy,pS.z); if(motoP < res.x) res = vec2(motoP, 2.); }
    if(fl.z < .5){ float motoE = sdMoto(p,eS.xy,eS.z); if(motoE < res.x) res = vec2(motoE, 3.); }

    if(pLong > 1){ float trP = murTrainee(p,LIGNE_TRAINEE_P,pLong); if(trP < res.x) res = vec2(trP, 4.); }
    if(eLong > 1){ float trE = murTrainee(p,LIGNE_TRAINEE_E,eLong); if(trE < res.x) res = vec2(trE, 5.); }

    return res;
}

vec3 calcNormale(vec3 p){
    float e = .003;
    return normalize(vec3(
        CARTE(p+vec3(e,0,0)).x - CARTE(p-vec3(e,0,0)).x,
        CARTE(p+vec3(0,e,0)).x - CARTE(p-vec3(0,e,0)).x,
        CARTE(p+vec3(0,0,e)).x - CARTE(p-vec3(0,0,e)).x));
}

vec2 marcheRayon(vec3 ro, vec3 rd){
    float t = .05; 
    float idMat = -1.;
    for(int i=0; i<ETAPES_MAX; i++){
        vec2 d = CARTE(ro+rd*t);
        if(d.x < DIST_SURF){ idMat = d.y; break; }
        if(t > DIST_MAX) break;
        t += d.x * .88;
    }
    return vec2(t, idMat);
}

mat3 matCam(vec3 ro, vec3 ta){
    vec3 cw = normalize(ta-ro);
    vec3 cu = normalize(cross(cw, vec3(0,1,0)));
    return mat3(cu, cross(cu,cw), cw);
}

float eclatSol(vec3 p, int canal){
    vec2 uv = (p.xz + MOITIE_GRILLE) / (MOITIE_GRILLE * 2.0);
    vec4 df = texture(iChannel1, clamp(uv, 0.0, 1.0));
    return exp(-(canal == 0 ? df.x : df.y) * 12.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;

    vec4 pS = texelFetch(iChannel0, ivec2(0,0), 0);
    float angleP = pS.z;
    vec2 dirP = dirAngle(angleP);
    vec3 cible = vec3(pS.x, 1.2, pS.y);
    vec3 ro = cible + vec3(-dirP.x, 0., -dirP.y) * 18. + vec3(0., 10., 0.);
    vec3 ta = cible + vec3(dirP.x, -.5, dirP.y) * 5.;
    mat3 cam = matCam(ro, ta);
    vec3 rd = cam * normalize(vec3(uv, 1.8));

    vec2 rm = marcheRayon(ro, rd);
    float t = rm.x, mat = rm.y;

    vec3 col = vec3(0., .018, .055);

    if(mat >= 0. && t < DIST_MAX){
        vec3 p = ro + rd * t;
        vec3 n = calcNormale(p);
        vec3 dirLum = normalize(vec3(.3, 1., .2));
        float diff = clamp(dot(n, dirLum), 0., 1.);
        float spec = pow(clamp(dot(reflect(-dirLum, n), -rd), 0., 1.), 56.);
        float fres = pow(1. - abs(dot(n, -rd)), 3.);

        if(mat < .5){
            vec2 g = abs(fract(p.xz * .5 + .5) - .5);
            float ligne = 1. - smoothstep(0., .05, min(g.x, g.y));
            col = mix(COUL_GRILLE, COUL_GRILLE * 2.5, diff * .25) + ligne * vec3(0., .28, .42);
            col += eclatSol(p, 0) * COUL_BLEU * .4 + eclatSol(p, 1) * COUL_ROUGE * .4 + spec * .08;
        } else if(mat < 1.5){
            float balayage = .5 + .5 * sin(p.y * 9.);
            col = (COUL_GRILLE + vec3(0., .1, .15)) * (diff * .5 + .4) * (.8 + .2 * balayage) + spec * .3 * COUL_BLEU;
        } else if(mat < 2.5){
            col = COUL_BLEU * (diff * .6 + .4) + spec * vec3(.4, .85, 1.) * .9 + COUL_BLEU * .35 + fres * COUL_BLEU * 1.2;
        } else if(mat < 3.5){
            col = COUL_ROUGE * (diff * .6 + .4) + spec * vec3(1., .5, .3) * .9 + COUL_ROUGE * .35 + fres * COUL_ROUGE * 1.2;
        } else if(mat < 4.5){
            col = COUL_BLEU * (diff * .4 + .6) + spec * .7 + COUL_BLEU * .55 + fres * COUL_BLEU * 2.;
        } else {
            col = COUL_ROUGE * (diff * .4 + .6) + spec * .7 + COUL_ROUGE * .55 + fres * COUL_ROUGE * 2.;
        }
        col = mix(vec3(0., .018, .055), col, exp(-t * .009));
    }

    float vig = 1. - .6 * pow(length((fragCoord / iResolution.xy - .5) * vec2(1.1, 1.)), 2.);
    col *= vig * (.93 + .07 * sin(fragCoord.y * 3.14));

    fragColor = vec4(pow(clamp(col, 0., 1.), vec3(.82)), 1.);
}

// ==== Buffer D (buffer) ====
vec3 flouLumineux(sampler2D textureSource, vec2 uv, vec2 taillePixel, float rayon){
    vec3 accumulation = vec3(0.); 
    float poidsTotal = 0.;
    for(int x=-3; x<=3; x++) {
        for(int y=-3; y<=3; y++){
            vec2 decalage = vec2(float(x), float(y)) * taillePixel * rayon;
            vec3 echantillon = texture(textureSource, uv + decalage).rgb;
            float luminance = dot(echantillon, vec3(.213, .715, .072));
            float contribution = max(luminance - .35, 0.) * exp(-float(x*x + y*y) * .18);
            accumulation += echantillon * contribution; 
            poidsTotal += contribution;
        }
    }
    return poidsTotal > 0. ? accumulation / poidsTotal : vec3(0.);
}

void mainImage(out vec4 couleurFragment, in vec2 coordFragment){
    vec2 uv = coordFragment / iResolution.xy;
    vec2 taillePixel = 1. / iResolution.xy;

    float decalageChr = .0022;
    vec3 couleur;
    couleur.r = texture(iChannel0, uv + vec2(decalageChr, 0.)).r;
    couleur.g = texture(iChannel0, uv).g;
    couleur.b = texture(iChannel0, uv - vec2(decalageChr, 0.)).b;

    couleur += flouLumineux(iChannel0, uv, taillePixel, 1.4) * .50
             + flouLumineux(iChannel0, uv, taillePixel, 3.2) * .28
             + flouLumineux(iChannel0, uv, taillePixel, 7.0) * .14;

    vec2 centreUv = uv - .5;
    float rayonCarre = dot(centreUv, centreUv);
    vec2 distorsion = uv + centreUv * rayonCarre * .07;
    
    if(any(lessThan(distorsion, vec2(0.))) || any(greaterThan(distorsion, vec2(1.)))){
        couleurFragment = vec4(0., 0., 0., 1.); 
        return;
    }

    couleur *= .88 + .12 * sin(coordFragment.y * 2.);
    couleur *= .97 + .03 * sin(coordFragment.x * 1.6);
    couleur *= .975 + .025 * fract(sin(iTime * 1337.) * 5678.);
    couleur.b = min(couleur.b * 1.06, 2.);

    couleurFragment = vec4(couleur, 1.);
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
