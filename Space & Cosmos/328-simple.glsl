// ==== Image (image) ====
// Fonction de hachage pseudo-aléatoire 3D renvoyant une valeur scalaire entre 0.0 et 1.0
#define H(p) fract(sin(dot(p, vec3(12.989, 78.233, 45.164))) * 43758.545)
// Macro pour générer une matrice de rotation 2D d'un angle 'a' (utilisée pour les transformations spatiales)
#define M(a) mat2(cos(a), -sin(a), sin(a), cos(a))

// Fonction de bruit de valeur 3D avec interpolation cubique (Smoothstep manuel)
float N(vec3 x) {
    // Séparation de la position en partie entière (i) pour la grille et fractionnaire (f) pour la cellule
    vec3 i = floor(x), f = fract(x);
    // Application de la courbe d'atténuation cubique 3x^2 - 2x^3 pour lisser l'interpolation
    f *= f * (3.0 - 2.0 * f);
    // Interpolation trilinéaire combinant les 8 sommets de la cellule de bruit 3D via le hash H
    return mix(mix(mix(H(i), H(i + vec3(1,0,0)), f.x), mix(H(i + vec3(0,1,0)), H(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(H(i + vec3(0,0,1)), H(i + vec3(1,0,1)), f.x), mix(H(i + vec3(0,1,1)), H(i + vec3(1,1,1)), f.x), f.y), f.z);
}

// Mouvement brownien fractionnaire (FBM) combinant 6 octaves de bruit avec distorsion harmonique temporelle
float F(vec3 p) {
    // Initialisation de la valeur accumulée (v) et de l'amplitude initiale de la première octave (a)
    float v = 0.0, a = 0.2;
    // Boucle d'accumulation sur 6 octaves pour générer du détail haute fréquence
    for (int i = 0; i < 6; i++) {
        // Ajout du bruit de la coordonnée modulée par une onde sinusoïdale animée pour un effet fluide/organique
        v += a * N(p + sin(p.x * 0.5 + iTime * 1.2) * cos(p.z * 0.5 + iTime * 0.8));
        // Passage à l'octave suivante : augmentation de la fréquence spatiale et défilement temporel de la position
        p = p * 2.4 + vec3(0.0, iTime * 0.04, iTime * -0.1);
        // Diminution de l'amplitude pour l'octave suivante (persistance de 0.48)
        a *= 0.48;
    }
    // Renvoi de la valeur de bruit multi-octave accumulée
    return v;
}

// Fonction d'estimation de distance (SDF) définissant la géométrie de la scène
float map(vec3 p) {
    // Mise à l'échelle des coordonnées pour ajuster la fréquence des détails à la surface
    vec3 nP = p * 1.8;
    // Animation de défilement sur l'axe Z pour simuler un flux continu
    nP.z += iTime * 0.6;
    // Calcul d'une macro-ondulation de base combinant des ondes sinus et cosinus sur les axes X et Z
    float m = sin(p.x * 1.5 + iTime) * 0.5 + cos(p.z * 1.2 + iTime * 1.5) * 0.5;
    // Calcul du déplacement final en appliquant une puissance non linéaire au FBM pour accentuer les crêtes
    float disp = pow(F(nP + m * 0.2), 1.4) * 1.45 + m * 0.15;
    // SDF d'une sphère de rayon 2.8 déformée par le déplacement procédural volumétrique
    return length(p) - 2.8 + disp;
}

// Calcul de l'occlusion ambiante (AO) basée sur l'échantillonnage de la SDF le long de la normale
float calcAO(vec3 pos, vec3 nor) {
    // Initialisation du facteur d'occlusion accumulé
    float occ = 0.0;
    // Facteur d'atténuation de l'influence de chaque échantillon successif
    float sca = 1.0;
    // Échantillonnage de la SDF en 5 points distants le long du vecteur normal
    for(int i = 0; i < 5; i++) {
        // Calcul de la distance de décalage (h) augmentant progressivement à chaque itération
        float h = 0.01 + 0.12 * float(i) / 4.0;
        // Évaluation de la SDF au point décalé
        float d = map(pos + h * nor);
        // Accumulation de la différence entre la distance théorique (h) et la distance réelle (d)
        occ += (h - d) * sca;
        // Réduction de l'échelle d'influence pour les échantillons plus lointains
        sca *= 0.95;
        // Optimisation : arrêt précoce si l'occlusion mesurée devient trop intense
        if(occ > 0.35) break;
    }
    // Normalisation de l'occlusion, application d'un gradient hémisphérique basé sur l'orientation Y de la normale
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0) * (0.5 + 0.5 * nor.y);
}

// Approximation du Subsurface Scattering (SSS) en mesurant la pénétration le long du rayon de vue
float calcSSS(vec3 pos, vec3 dir) {
    // Initialisation de la quantité de lumière absorbée/obstruée à l'intérieur du volume
    float sss = 0.0;
    // Facteur d'échelle d'atténuation pour la pondération des étapes
    float sca = 1.0;
    // Échantillonnage de la SDF en 4 étapes en s'enfonçant ou suivant la direction du rayon
    for(int i = 0; i < 4; i++) {
        // Pas d'échantillonnage de plus en plus profond à chaque itération
        float h = 0.1 + 0.2 * float(i);
        // Évaluation de la géométrie au point échantillonné
        float d = map(pos + h * dir);
        // Accumulation de la densité traversée (la différence indique l'épaisseur de la géométrie)
        sss += (h - d) * sca;
        // Décroissance de la contribution des couches profondes
        sca *= 0.7;
    }
    // Inversion du résultat pour obtenir la translucidité (plus la structure est fine, plus la lumière traverse)
    return clamp(1.0 - sss * 0.5, 0.0, 1.0);
}

// Fonction principale d'exécution du shader par fragment
void mainImage(out vec4 O, vec2 U) {
    // Normalisation des coordonnées de l'écran centrées en (0,0) avec préservation du ratio d'aspect (Y)
    vec2 u = (U - 0.5 * iResolution.xy) / iResolution.y;

    // Calcul de l'animation temporelle de la trajectoire de la caméra
    float camTime = iTime * 0.12;
    // Définition de la position de la caméra (ro) décrivant une trajectoire orbitale oscillante en 3D
    vec3 ro = vec3(cos(camTime) * 8.5, sin(camTime * 0.4) * 4.5, sin(camTime) * 8.5);
    // Point de visée de la caméra (Target) positionné à l'origine du monde
    vec3 ta = vec3(0.0, 0.0, 0.0);
    // Calcul du vecteur de visée avant (Forward) normalisé de la caméra
    vec3 cw = normalize(ta - ro);
    // Calcul du vecteur latéral droit (Right) via le produit vectoriel avec le vecteur universel Up (0,1,0)
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    // Calcul du vecteur vertical local (Up personnalisé) orthogonal aux deux vecteurs précédents
    vec3 cv = cross(cu, cw);
    // Génération du vecteur de direction du rayon (Ray Direction) pour le pixel courant (Longueur focale de 1.5)
    vec3 rd = normalize(u.x * cu + u.y * cv + 1.5 * cw);

    // Initialisation de la couleur finale du pixel à noir
    vec3 col = vec3(0.0);
    // Initialisation de la distance de marche (t), de la variable SDF (d), et de l'accumulateur d'éclat volumétrique (g)
    float t = 0.0, d, g = 0.0;

    // Boucle principale de Raymarching limitée à un maximum de 120 étapes
    for(int i = 0; i < 120; i++) {
        // Évaluation de la distance minimale par rapport à la scène à la position actuelle du rayon
        d = map(ro + rd * t);
        // Accumulation d'une lueur volumétrique (Glow) inversement proportionnelle à la distance à la surface
        g += exp(-max(d, 0.0) * 3.2) * 0.12;
        // Condition de sortie : détection d'intersection (d très proche de 0) ou dépassement de la distance max d'affichage (30.0)
        if(d < 0.002 || t > 30.0) break;
        // Progression prudente du rayon le long de sa direction en utilisant un pas relaxé à 45% pour éviter les artefacts
        t += d * 0.45;
    }

    // Branchement conditionnel : Si le rayon a intersecté la surface de l'objet
    if (t < 30.0) {
        // Calcul du point d'intersection exact dans l'espace 3D
        vec3 p = ro + rd * t;
        // Vecteur epsilon pour le calcul des différences finies du gradient
        vec2 e = vec2(0.002, 0.0);
        // Approximation de la normale de la surface en calculant le gradient de la SDF sur les 3 axes
        vec3 n = normalize(vec3(map(p+e.xyy)-map(p-e.xyy), map(p+e.yxy)-map(p-e.yxy), map(p+e.yyx)-map(p-e.yyx)));

        // Évaluation du FBM à la surface avec décalage temporel pour animer les variations de teintes de l'albedo
        float f = F(p * 0.6 - iTime * 0.4);
        // Interpolation de la couleur de base (Albedo) créant un dégradé de type magma/fluide incandescent (Rouge -> Orange -> Jaune)
        vec3 alb = mix(mix(vec3(0.9, 0.02, 0.0), vec3(1.0, 0.45, 0.0), f * 2.4), vec3(1.0, 0.95, 0.6), pow(f, 3.5));

        // Approximation du terme de réflexion de Fresnel de type Schlick pour simuler la réflectance rasante (PBR)
        float pbr = 0.05 + 0.95 * pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        // Calcul de la valeur d'occlusion ambiante au point d'impact
        float ao = calcAO(p, n);
        // Calcul du terme de diffusion sous-surfacique pour donner un aspect translucide/organique charnu
        float sss = calcSSS(p, rd);
        
        // Définition de la direction normalisée de la source lumineuse principale
        vec3 lightDir = normalize(vec3(1.0, 1.5, -1.0));
        // Calcul de la diffusion Lambertienne standard (produit scalaire saturé entre la normale et la lumière)
        float diff = max(dot(n, lightDir), 0.0);
        // Calcul d'une lueur de rétro-éclairage (Backlight) bleutée opposée à la direction de la lumière principale
        vec3 backLight = vec3(0.1, 0.3, 0.8) * clamp(dot(n, -lightDir), 0.0, 1.0);
        
        // Composition de la composante spéculaire/réflexion rasante modulée par l'albedo et l'occlusion ambiante
        col = alb * pbr * 3.5 * ao;
        // Ajout de l'émission interne due au SSS accentuée de façon non linéaire par les zones chaudes du FBM
        col += alb * pow(f, 2.5) * 14.0 * sss;
        // Ajout de l'éclairage direct diffus (Lambert) teinté et atténué par l'occlusion ambiante
        col += diff * vec3(1.0, 0.9, 0.8) * alb * 0.5 * ao;
        // Ajout de la contribution de la lumière arrière traversant l'objet via le SSS
        col += backLight * sss * 0.8;

        // Application d'une atténuation de visibilité atmosphérique (brouillard) exponentielle basée sur la distance parcourue
        col *= exp(-0.02 * t);
    } else { // Branchement conditionnel : Si le rayon s'échappe dans le vide (Arrière-plan / Skybox procédurale)
        // Duplication du rayon de direction pour lui appliquer des transformations spatiales isolées
        vec3 brd = rd;
        // Application d'une rotation dynamique oscillante sur l'axe YZ de l'arrière-plan
        brd.yz *= M(sin(iTime * 0.04) * 0.2);
        // Application d'une rotation continue lente sur l'axe XZ de l'arrière-plan
        brd.xz *= M(iTime * 0.02);

        // Génération d'une nébuleuse de fond sombre et rougeâtre basée sur le FBM appliqué aux coordonnées de la skybox
        col = vec3(0.08, 0.01, 0.0) * F(brd * 3.0 + iTime * 0.03);

        // Boucle de génération d'étoiles/particules scintillantes réparties sur 21 couches de profondeur virtuelles
        for(float i = 1.0; i < 22.0; i++) {
            // Projection du rayon de direction sur une sphère virtuelle de rayon croissant à chaque couche
            vec3 q = brd * (30.0 + i * 18.0);
            // Extraction de l'identifiant unique de la cellule de la grille tridimensionnelle pour la particule
            vec3 id = floor(q);
            // Calcul des coordonnées locales centrées au milieu de la cellule courante [-0.5, 0.5]
            vec3 fd = fract(q) - 0.5;
            // Génération d'une valeur pseudo-aléatoire unique pour la cellule courante
            float r = H(id);
            // Seuil de rareté : Seules les cellules ayant un hash supérieur à 0.97 contiendront une étoile
            if(r > 0.97) {
                // Calcul d'une fonction sinusoïdale de pulsation temporelle désynchronisée par le hash pour le scintillement
                float pulse = sin(iTime * 3.5 * r + r * 25.0) * 0.5 + 0.5;
                // Dessin de la particule circulaire via smoothstep et accumulation de son intensité lumineuse teintée
                col += pulse * vec3(1.0, 0.85, 0.7) * smoothstep(0.15, 0.0, length(fd) - 0.0025 * i) * 3.0;
            }
        }
    }

    // Ajout d'une lueur d'aspiration/volumétrique globale (Glow primaire) de couleur rouge/orangée autour de l'objet
    col += vec3(1.0, 0.3, 0.02) * g * 1.1;
    // Superposition d'une seconde composante de lueur haute intensité (Glow secondaire) plus jaune et concentrée
    vec3(1.0, 0.65, 0.15) * pow(g, 1.9) * 0.35;

    // Égalisation des couleurs via un opérateur de Tone Mapping ACES (approximation mathématique pour le rendu HDR vers LDR)
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    
    // Application d'un effet cosmétique de vignettage assombrissant les bords de l'image en fonction de la distance au centre
    col *= 1.0 - 0.0 * pow(length(u), 2.5);

    // Encodage final de la couleur avec correction gamma standard (0.4545 correspondant à l'inverse de 2.2) dans le canal RGBA
    O = vec4(pow(col * 0.95, vec3(0.4545)), 1.0);
}
