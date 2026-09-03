// ==== Image (image) ====
// Raccourci pour récupérer la résolution globale iResolution
#define R iResolution
// Macro compacte pour générer une matrice de rotation 2D à partir d'un angle 'a' encodé via un vec4 décalé (astuce mathématique de compression)
#define r(a) mat2(cos(a+vec4(0,11,33,0)))

void mainImage(out vec4 O, vec2 I) {
    // Déclaration des variables de vecteurs pour la résolution, la position courante, le gradient/normale, les décalages de pas et les positions de caméra / rayon
    vec3 r = iResolution, p, g, st,
         ro = vec3(0, 0, -2.5), 
         rd = normalize(vec3((I - .5 * r.xy) / r.y, 1.2)),
         ink = vec3(.01, .02, .05); // Couleur de base représentant l'encre / fluide sombre de l'objet
    
    // Initialisation des variables scalaires pour le temps, l'accumulation de distance (a), la SDF (d), l'opacité (n) et les compteurs de boucles
    float t = sin(iTime * .05) * .3, a = 0., d, n = 0., j, k, m, sd, scl, h, ax;
    
    // Application d'une rotation globale à la position d'origine du rayon (Camera Ray Origin) sur l'axe XZ
    ro.xz *= r(t);
    // Application de la même rotation globale à la direction du rayon (Ray Direction) pour orienter la vue
    rd.xz *= r(t);
    
    // Boucle principale de raymarching configurée pour un maximum de 90 itérations
    for (int i = 0; i < 90; i++) {
        // Calcul du point courant p dans l'espace 3D le long de la direction du rayon
        p = ro + rd * a;
        // Copie de la coordonnée p dans une variable de travail q pour les transformations fractales
        vec3 q = p;
        // Défilement continu de la coordonnée Z en fonction du temps pour simuler un mouvement de flux infini
        q.z += iTime * .5;
        // Répétition infinie de l'espace par un partitionnement cellulaire (grille tridimensionnelle de période 8.0 centrée sur [-4, 4])
        q = mod(q + 4., 8.) - 4.;
        // Initialisation du facteur d'échelle globale de la fractale (scl) et de la distance minimale par défaut (d)
        scl = 1.; d = 1e10;
        
        // Boucle interne KIFS (Système de Fonctions Itérées par Repliement) sur 5 itérations pour générer la structure fractale
        for (j = 0.; j < 5.; j++) {
            // Repliement absolu de l'espace créant des symétries miroirs, suivi d'un décalage pour générer des cavités
            q = abs(q) - .35;
            // Calcul de l'angle de rotation dynamique propre à chaque niveau d'itération/octave
            ax = iTime * .15 + j * .2;
            // Transformation de rotation itérative sur le plan YZ
            q.yz *= r(ax);
            // Transformation de rotation itérative sur le plan XZ animée à une vitesse constante
            q.xz *= r(iTime * .225);
            // Inversion sphérique : calcul du facteur de mise à l'échelle inverse basé sur le produit scalaire magnétisé et borné
            h = 1.8 / clamp(dot(q, q), .15, 1.);
            // Homothétie (grossissement) de l'espace de coordonnées q pour amplifier les détails internes
            q *= h; 
            // Accumulation du facteur d'échelle total pour corriger la distance finale de la SDF de la fractale
            scl *= h;
            // Évaluation de la SDF : calcul de la distance à un cylindre modulé de manière sinusoïdale sur l'axe Z, divisé par l'échelle courante
            d = min(d, (length(q.xy) - .12 * abs(sin(q.z * 2. + iTime))) / scl);
        }
        
        // Ajout d'une perturbation harmonique tridimensionnelle de haute fréquence (bruit de déplacement de surface)
        d += sin(p.x * 4. + iTime * .15) * cos(p.y * 4. - iTime * .15) * sin(p.z * 4. + iTime) * .04;
        
        // Condition d'intersection volumétrique : si la distance mesurée passe sous le seuil critique (0.01)
        if (d < .01) { 
            // Accumulation d'une densité d'opacité (effet de flou géométrique / diffusion d'encre)
            n += (.01 - d) * 18.; 
            // Avancement forcé minimal fixe pour traverser l'épaisseur de la géométrie (rendu semi-transparent)
            a += .01; 
        }
        // Sinon, progression adaptative standard du rayon (raymarche relaxée à 45% avec un pas de sécurité minimum)
        else a += max(d * .45, .008);
        
        // Critère d'arrêt précoce si le rayon dépasse la distance d'arrière-plan ou si l'opacité accumulée s'est saturée
        if (a > 14. || n > 4.5) break;
    }
    
    // Si le rayon a intersecté le volume fractal (distance parcourue inférieure à l'arrière-plan maximal de 14.0)
    if (a < 14.) {
        // Boucle tridimensionnelle pour approximer le vecteur gradient par différences finies (calcul de la normale de surface)
        for (int k = 0; k < 3; k++) {
            // Initialisation d'un vecteur de décalage propre à l'axe courant (k) réinitialisé à chaque itération
            st = vec3(0); st[k] = .002;
            float d1, d2;
            // Sous-boucle évaluant deux positions décalées (une positive m=0 et une négative m=1) le long de l'axe st[k]
            for (int m = 0; m < 2; m++) {
                // Application du décalage positif ou négatif au point d'intersection original p
                vec3 np = p + (m == 0 ? st : -st), q = np;
                // Reproduction exacte de l'animation de défilement temporel de la structure fractale
                q.z += iTime * .5;
                // Répétition périodique identique à la boucle principale pour s'aligner sur la géométrie locale
                q = mod(q + 4., 8.) - 4.;
                // Réinitialisation des facteurs de calcul fractal pour l'évaluation du point échantillonné
                scl = 1.; sd = 1e10;
                // Boucle KIFS identique à 5 itérations pour recalculer précisément la SDF au point décalé np
                for (j = 0.; j < 5.; j++) {
                    q = abs(q) - .35;
                    ax = iTime * .15 + j * .2;
                    q.yz *= r(ax);
                    q.xz *= r(iTime * .225);
                    h = 1.8 / clamp(dot(q, q), .15, 1.);
                    q *= h; scl *= h;
                    sd = min(sd, (length(q.xy) - .12 * abs(sin(q.z * 2. + iTime))) / scl);
                }
                // Ré-application de la perturbation harmonique tridimensionnelle sur la position décalée np
                sd += sin(np.x * 4. + iTime * .15) * cos(np.y * 4. - iTime * .15) * sin(np.z * 4. + iTime) * .04;
                // Stockage de la distance obtenue selon la polarité du décalage appliqué
                if (m == 0) d1 = sd; else d2 = sd;
            }
            // Calcul de la pente locale (dérivée partielle) sur la composante k du vecteur gradient g
            g[k] = d1 - d2;
        }
        // Normalisation finale du vecteur de gradient obtenu pour le transformer en un vecteur normal unitaire
        g = normalize(g);
        
        // Ajout d'une composante de diffusion de Fresnel rasante sur les bords du volume en exploitant le produit scalaire
        n += pow(1. - max(dot(-rd, g), 0.), 3.) * 1.275;
        // Calcul de l'apport d'une source de lumière diffuse directionnelle (Lumière orientée vers (1, 2, -2))
        ink += max(dot(g, normalize(vec3(1, 2, -2))), 0.) * vec3(.02, .05, .1);
    }
    
    // Interpolation de couleur finale (mix entre l'encre éclairée et le fond dégradé en vignette papier) gérée par l'opacité exponentielle exp(-n)
    O = vec4(pow(clamp(mix(ink, vec3(.96, .95, .92) - length((I - .5 * r.xy) / r.y) * .22, exp(-n)), 0., 1.), vec3(.95)), 1.);
}
