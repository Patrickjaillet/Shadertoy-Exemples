// --- CONFIGURATION DE LA CAMÉRA & ESPACE ---
#define CAM_FOV 0.964                             // Champ de vision (focale de la caméra)
#define CAM_SPEED 4.0                             // Vitesse de déplacement automatique sur l'axe Z
#define CAM_OFFSET vec3(0.0, 0.0, iTime * CAM_SPEED) // Origine de la caméra
#define ROT_SPEED_X 0.8                           // Vitesse de rotation automatique sur l'axe X (horizontal)
#define ROT_SPEED_Y 0.4                           // Vitesse de rotation automatique sur l'axe Y (vertical)
#define ROT_AMP_X 0.5848                          // Amplitude de rotation sur l'axe X
#define ROT_AMP_Y 0.2                             // Amplitude de rotation sur l'axe Y
#define MOUSE_SENSITIVITY 2.0                     // Sensibilité du contrôle de la caméra à la souris
#define ASPECT_RATIO_DIVISOR r.y                  // Composante de résolution pour corriger le ratio d'aspect
#define RAY_SCREEN_OFFSET 0.5                     // Facteur de centrage des coordonnées d'écran
#define ZERO_FLOAT 0.0                            // Constante flottante 0.0 pour l'optimisation
#define ONE_FLOAT 1.0                             // Constante flottante 1.0 pour l'optimisation

// --- PARAMÈTRES DU CYLINDRE & RÉFRACTION ---
#define CYLINDER_RADIUS 1.5                       // Rayon du tube/tunnel cylindrique
#define MIN_RADIUS_EPS 0.001                      // Seuil minimal d'évitement de division par zéro au centre
#define REFRACT_THRESHOLD 0.05                    // Distance de déclenchement de la réfraction
#define REFRACT_INDEX 0.85                        // Indice de réfraction du verre/milieu

// --- TRANSFORMATION SPATIALE & DOMAIN WARPING (MAXIMUM) ---
#define USE_DOMAIN_TWIST 0                        // Activer (1) ou désactiver (0) la torsion de l'espace (Twist)
#define TWIST_STRENGTH 0.5                        // Force de la torsion appliquée au domaine
#define TWIST_AXIS 0                              // Axe de la torsion (0: Y, 1: X, 2: Z)

#define USE_DOMAIN_BEND 0                         // Activer (1) ou désactiver (0) la courbure de l'espace (Bend)
#define BEND_STRENGTH 0.3                         // Force de courbure appliquée au domaine
#define BEND_AXIS 0                               // Axe de courbure (0: X-Y, 1: Y-Z, 2: Z-X)

#define USE_SPACE_REPETITION 0                    // Activer (1) ou désactiver (0) la répétition infinie de l'espace
#define REPETITION_SPACING vec3(4.0, 4.0, 4.0)    // Intervalle de répétition spatiale sur X, Y, Z
#define USE_LIMITED_REPETITION 0                  // Activer (1) ou désactiver (0) la répétition spatiale bornée
#define REPETITION_LIMIT_MIN vec3(-2.0)           // Limite inférieure du nombre de répétitions
#define REPETITION_LIMIT_MAX vec3(2.0)            // Limite supérieure du nombre de répétitions

#define USE_POLAR_REPETITION 0                    // Activer (1) ou désactiver (0) la répétition angulaire/polaire
#define POLAR_REPETITION_SECTORS 8.0              // Nombre de secteurs pour la répétition polaire

#define USE_DOMAIN_PINCH 0                        // Activer (1) ou désactiver (0) la déformation par pincement (Pinch)
#define PINCH_STRENGTH 0.5                        // Intensité du pincement spatial

#define USE_DOMAIN_SHEAR 0                        // Activer (1) ou désactiver (0) le cisaillement de l'espace (Shear)
#define SHEAR_FACTOR vec3(0.2, 0.0, 0.0)          // Facteurs de cisaillement sur X, Y, Z

#define USE_DOMAIN_DISPLACEMENT 0                 // Activer (1) ou désactiver (0) le déplacement sinusoïdal du domaine
#define DOMAIN_DISPLACEMENT_AMP vec3(0.2)         // Amplitude du déplacement ondulatoire du domaine
#define DOMAIN_DISPLACEMENT_FREQ vec3(2.0)        // Fréquence du déplacement ondulatoire du domaine

// --- KALEIDOSCOPE 2D/3D ---
#define USE_KALEIDOSCOPE 0                        // Activer (1) ou désactiver (0) le kaléidoscope 2D
#define KALEIDO_SECTORS 6.0                       // Nombre de branches/symétries du kaléidoscope 2D
#define KALEIDO_ANGLE_OFFSET 0.0                  // Décalage d'angle initial du kaléidoscope 2D
#define KALEIDO_CENTER vec2(0.0, 0.0)             // Centre du kaléidoscope 2D sur le plan
#define USE_KALEIDO_3D_ICOSAHEDRAL 0              // Activer (1) ou désactiver (0) la symétrie 3D icosaédrique
#define USE_KALEIDO_3D_OCTAHEDRAL 0               // Activer (1) ou désactiver (0) la symétrie 3D octaédrique
#define USE_KALEIDO_3D_TETRAHEDRAL 0              // Activer (1) ou désactiver (0) la symétrie 3D tétraédrique

// --- LOG-POLAR MAPPING ---
#define USE_LOG_POLAR 0                           // Activer (1) ou désactiver (0) la projection log-polaire
#define LOG_POLAR_SCALE 1.0                       // Échelle d'agrandissement de la grille log-polaire
#define LOG_POLAR_SWIRL 0.0                       // Effet de tourbillon (Swirl) combiné à la projection
#define LOG_POLAR_ANIM_SPEED 0.0                  // Vitesse de défilement temporel de la grille log-polaire
#define LOG_POLAR_CENTER vec2(0.0, 0.0)            // Centre de l'origine de la projection log-polaire
#define LOG_POLAR_BRANCHES 1.0                    // Multiplicateur du nombre de branches angulaires
#define LOG_POLAR_SPIRAL_ANGLE 0.0                // Angle de rotation de la spirale log-polaire
#define LOG_POLAR_PLANE_SELECT 0                  // Choix du plan de projection (0: XZ, 1: XY, 2: YZ)

// --- GEOMETRIC FOLDING ---
#define USE_FOLDING 0                             // Activer (1) ou désactiver (0) le pliage géométrique par plan
#define FOLD_PLANE_NORMAL vec3(0.7071, 0.7071, 0.0) // Normale du plan de pliage géométrique
#define FOLD_DISTANCE 0.0                         // Distance du plan de pliage par rapport à l'origine
#define FOLD_ITERATIONS 1                         // Nombre d'itérations du processus de pliage
#define USE_BOX_FOLD 0                            // Activer (1) ou désactiver (0) le pliage en boîte (Box Fold)
#define BOX_FOLD_LIMIT 1.0                        // Limite de seuil pour le Box Fold
#define BOX_FOLD_VALUE 2.0                        // Valeur d'échelle de multiplication du Box Fold
#define USE_SPHERE_FOLD 0                         // Activer (1) ou désactiver (0) le pliage sphérique (Sphere Fold)
#define SPHERE_FOLD_MIN_RAD 0.5                   // Rayon interne minimal pour l'inversion sphérique
#define SPHERE_FOLD_MAX_RAD 1.0                   // Rayon externe maximal pour l'inversion sphérique
#define USE_OCTAHEDRAL_FOLD 0                     // Activer (1) ou désactiver (0) le pliage octaédrique
#define USE_DODECAHEDRAL_FOLD 0                   // Activer (1) ou désactiver (0) le pliage dodécaédrique
#define USE_MENGER_FOLD 0                         // Activer (1) ou désactiver (0) le pliage d'éponge de Menger
#define FOLD_SCALE_FACTOR 1.0                     // Facteur d'échelle appliqué après chaque itération de pliage
#define FOLD_TRANSLATION vec3(0.0, 0.0, 0.0)      // Vecteur de translation appliqué après chaque pliage

// --- FRACTALE TYPE 3 / MANDELBOX & FRACTALES AVANCÉES (MAXIMUM) ---
#define FRACTAL_TYPE 0                            // Type de fractale (0: Kaliset, 1: Mandelbox, 2: Menger Sponge, 3: Mandelbulb)
#define FRACTAL_ITER 4                            // Nombre d'itérations globales de la fractale
#define FRACTAL_SCALE 1.5                         // Échelle de multiplication récursive de la fractale
#define FRACTAL_OFFSET vec3(0.5)                  // Décalage spatial appliqué à chaque itération de fractale
#define FRACTAL_ROT_XY 0.5                        // Angle de rotation sur le plan XY à chaque itération
#define FRACTAL_ROT_XZ 0.3                        // Angle de rotation sur le plan XZ à chaque itération
#define FRACTAL_ROT_YZ 0.0                        // Angle de rotation sur le plan YZ à chaque itération
#define FRACTAL_RADIUS 0.2                        // Rayon de consigne de la forme fractale de base
#define FRACTAL_CLAMP_MIN 0.1                     // Borne minimale de sécurité pour l'inversion de distance
#define FRACTAL_CLAMP_MAX 1.0                     // Borne maximale de sécurité pour l'inversion de distance

#define MANDELBOX_SCALE 2.0                       // Facteur d'échelle spécifique pour la Mandelbox
#define MANDELBOX_FIXED_RADIUS 1.0                // Rayon fixe au carré pour le pliage sphérique de la Mandelbox
#define MANDELBOX_MIN_RADIUS 0.5                  // Rayon minimum au carré pour le pliage sphérique de la Mandelbox
#define MANDELBOX_FOLD_LIMIT 1.0                  // Limite de pliage linéaire des coordonnées pour la Mandelbox

#define MENGER_SCALE 3.0                          // Échelle de sous-division pour l'éponge de Menger
#define MENGER_OFFSET vec3(1.0)                   // Décalage de centrage pour la structure de Menger

#define MANDELBULB_POWER 8.0                      // Puissance exponentielle (N) du Mandelbulb 3D
#define MANDELBULB_BAILOUT 4.0                    // Seuil d'échappement (Bailout) des itérations du Mandelbulb

// --- MOTIF ONDULATOIRE ET ÉNERGIE ---
#define WAVE_LOG_SCALE 1.0                        // Facteur d'échelle du terme log dans la déformation UV
#define WAVE_Z_SCALE 0.5                          // Facteur d'échelle de la vitesse Z dans la déformation UV
#define WAVE_TIME_SPEED 2.0                       // Vitesse temporelle de l'onde de fond
#define WAVE_SIN_AMP 0.75                         // Amplitude du sinus interne de la déformation UV
#define WAVE_SIN_FREQ 1.5                         // Fréquence du sinus interne de la déformation UV
#define WAVE_CLAMP_MIN -0.99                      // Borne minimale d'écrêtage pour l'arcsinus
#define WAVE_CLAMP_MAX 0.99                       // Borne maximale d'écrêtage pour l'arcsinus

#define INTERFERENCE_OFFSET vec2(0.2, 0.0)        // Décalage d'échantillonnage pour le motif d'interférence
#define INTERFERENCE_FREQ 15.0                    // Fréquence des ondulations de l'interférence
#define INTERFERENCE_SPEED_1 4.0                  // Vitesse temporelle de la première onde d'interférence
#define INTERFERENCE_SPEED_2 3.0                  // Vitesse temporelle de la seconde onde d'interférence

// --- MOTEUR DE RAYMARCHING ---
#define MAX_STEPS 60.0                            // Nombre maximal de pas d'évaluation le long du rayon
#define STEP_PULL 0.01                            // Pas d'avancement minimal garanti pour éviter le blocage
#define MARCH_LOOP_START 0.0                      // Valeur initiale du compteur de boucle du Raymarching
#define MARCH_STEP_INC 1.0                        // Incrément par itération dans la boucle de Raymarching
#define FOG_ATTENUATION 0.1                       // Facteur d'atténuation exponentielle de la lumière avec la distance

// --- ÉCLAIRAGE, OMBRES & AMBIENT OCCLUSION ---
#define USE_LIGHTING 0                            // Activer (1) ou désactiver (0) le système d'éclairage avec normales
#define LIGHT_DIR normalize(vec3(1.0, 2.0, -2.0)) // Vecteur de direction de la source de lumière principale
#define LIGHT_COLOR vec3(1.0, 0.95, 0.85)         // Couleur de la lumière directe (teinte chaude)
#define AMBIENT_COLOR vec3(0.05, 0.08, 0.15)      // Couleur de la lumière ambiante (teinte froide)
#define SPEC_POWER 32.0                           // Exposant de brillance spéculaire (Phong/Blinn-Phong)
#define NORMAL_EPSILON 0.001                      // Intervalle d'échantillonnage pour le calcul des normales
#define LIGHT_DIFF_MIN 0.0                        // Valeur minimale de l'éclairage diffus (clamping)
#define LIGHT_SPEC_MIN 0.0                        // Valeur minimale de la réflexion spéculaire (clamping)

#define USE_SOFT_SHADOWS 0                        // Activer (1) ou désactiver (0) le calcul des ombres douces
#define SHADOW_K 16.0                             // Facteur de dureté/pénombre des ombres douces
#define SHADOW_MIN_DIST 0.02                      // Distance minimale du rayon d'ombre pour éviter l'auto-intersection
#define SHADOW_MAX_DIST 2.5                       // Distance maximale de recherche d'obstacles d'ombrage
#define SHADOW_STEPS 24                           // Nombre maximal de pas du rayon d'ombre

#define USE_AO 0                                  // Activer (1) ou désactiver (0) l'Ambient Occlusion (AO)
#define AO_STEPS 5                                // Nombre d'échantillons le long de la normale pour l'AO
#define AO_STEP_SIZE 0.05                         // Distance entre chaque échantillon d'AO
#define AO_INTENSITY 1.5                          // Force d'assombrissement de l'Ambient Occlusion

// --- PALETTE DE COULEURS, GRADIENTS & MATÉRIAUX (MAXIMUM) ---
#define COLOR_MODE 0                              // Mode de coloration (0: Palette cosinus animée, 1: Cosine IQ, 2: Normales, 3: Profondeur, 4: Orbit Trap)
#define COLOR_PHASE_VEC vec3(0.0, 2.0, 4.0)       // Décalage de phase des canaux R, G, B pour la palette par défaut
#define COLOR_ANGULAR_SCALE 2.0                   // Facteur d'échelle angulaire pour le calcul de couleur
#define COLOR_Z_SCALE 0.2                         // Facteur d'échelle sur l'axe Z pour la variation de couleur
#define WAVE_ENERGY_MULT 0.008                    // Multiplicateur d'énergie pour la contribution ondulatoire
#define COLOR_CLAMP_MIN 0.0                       // Borne minimale de découpage de la couleur finale
#define COLOR_CLAMP_MAX 1.0                       // Borne maximale de découpage de la couleur finale

// Palettes Inigo Quilez
#define PALETTE_A vec3(0.5, 0.5, 0.5)            // Composante d'offset (A) de la formule de palette cosinus
#define PALETTE_B vec3(0.5, 0.5, 0.5)            // Composante d'amplitude (B) de la formule de palette cosinus
#define PALETTE_C vec3(1.0, 1.0, 1.0)            // Composante de fréquence (C) de la formule de palette cosinus
#define PALETTE_D vec3(0.0, 0.33, 0.67)          // Composante de phase (D) de la formule de palette cosinus
#define PALETTE_FREQ 1.0                          // Multiplicateur de fréquence spatiale de la palette
#define PALETTE_SPEED 0.1                         // Vitesse d'animation temporelle du défilement des couleurs

// Gradient par profondeur
#define DEPTH_COLOR_NEAR vec3(1.0, 0.8, 0.3)      // Couleur affectée aux surfaces proches de la caméra
#define DEPTH_COLOR_FAR vec3(0.0, 0.2, 0.8)       // Couleur affectée aux surfaces éloignées de la caméra
#define DEPTH_RANGE vec2(0.5, 4.0)                // Plage de distances (Near, Far) pour l'interpolation de couleur

// Normales comme couleur
#define NORMAL_COLOR_INTENSITY 1.0                // Multiplicateur d'intensité pour la coloration basée sur les normales
#define NORMAL_COLOR_OFFSET vec3(0.5)             // Décalage pour mapper l'intervalle [-1,1] vers [0,1]

// Orbit Trap Colorization
#define ORBIT_COLOR_1 vec3(0.1, 0.8, 0.6)         // Première couleur du piège d'orbite
#define ORBIT_COLOR_2 vec3(0.9, 0.1, 0.4)         // Seconde couleur du piège d'orbite
#define ORBIT_POWER 2.0                           // Exposant de lissage pour la coloration par piège d'orbite

#define ALPHA_DEFAULT 1.0                         // Valeur du canal alpha par défaut pour le pixel de sortie

// --- POST-PROCESSING (FX) ---
#define USE_BLOOM 0                               // Activer (1) ou désactiver (0) l'effet de Bloom volumétrique
#define BLOOM_STRENGTH 0.5                        // Intensité de la surbrillance du Bloom
#define BLOOM_OFFSET 2.0                          // Écartement en pixels des échantillons pour le flou de Bloom
#define BLOOM_WEIGHT 0.25                         // Poids de mélange par échantillon de flou

#define USE_ABERRATION 0                          // Activer (1) ou désactiver (0) l'aberration chromatique
#define ABERRATION_AMOUNT 0.003                   // Distance de séparation des canaux R, G, B en pourcentage d'écran

#define FX_CONTRAST 1.0                           // Facteur d'ajustement du contraste de l'image
#define FX_SATURATION 1.0                         // Facteur d'ajustement de la saturation de la couleur
#define FX_GAMMA 1.0                              // Valeur de correction Gamma (ex: 2.2 pour sRGB)
#define FX_VIGNETTE 0.0                           // Intensité de l'assombrissement sur les bords (Vignettage)
#define LUMINANCE_WEIGHTS vec3(0.2126, 0.7152, 0.0722) // Poids d'évaluation de la luminance pour la désaturation
#define VIGNETTE_POWER 0.25                       // Courbe d'atténuation du vignettage du centre vers les bords
#define VIGNETTE_SCALE 16.0                       // Facteur d'échelle multiplicatif de la formule de vignettage
#define MIDTONE_BIAS 0.5                          // Point pivot des tons moyens pour le calcul du contraste
#define GAMMA_SAFE_MIN 0.0                        // Borne minimale de sécurité avant l'application de la puissance Gamma
#define VIGNETTE_ONE 1.0                          // Constante neutre pour le calcul du vignettage

mat2 rot2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

vec3 palette(float t) {
    return PALETTE_A + PALETTE_B * cos(6.28318530718 * (PALETTE_C * (t * PALETTE_FREQ + iTime * PALETTE_SPEED) + PALETTE_D));
}

vec3 applyDomainWarping(vec3 p) {
    #if USE_DOMAIN_DISPLACEMENT
        p += sin(p.zxy * DOMAIN_DISPLACEMENT_FREQ + iTime) * DOMAIN_DISPLACEMENT_AMP;
    #endif

    #if USE_DOMAIN_SHEAR
        p.x += p.y * SHEAR_FACTOR.x;
        p.y += p.z * SHEAR_FACTOR.y;
        p.z += p.x * SHEAR_FACTOR.z;
    #endif

    #if USE_DOMAIN_PINCH
        float factor = 1.0 + p.z * PINCH_STRENGTH;
        p.xy *= factor;
    #endif

    #if USE_POLAR_REPETITION
        float angleP = 6.28318530718 / POLAR_REPETITION_SECTORS;
        float aP = atan(p.z, p.x) + angleP * 0.5;
        float rP = length(p.xz);
        aP = mod(aP, angleP) - angleP * 0.5;
        p.xz = vec2(cos(aP), sin(aP)) * rP;
    #endif

    #if USE_LIMITED_REPETITION
        p = p - REPETITION_SPACING * clamp(round(p / REPETITION_SPACING), REPETITION_LIMIT_MIN, REPETITION_LIMIT_MAX);
    #endif

    #if USE_SPACE_REPETITION && !USE_LIMITED_REPETITION
        p = mod(p + 0.5 * REPETITION_SPACING, REPETITION_SPACING) - 0.5 * REPETITION_SPACING;
    #endif

    #if USE_DOMAIN_TWIST
        #if TWIST_AXIS == 0
            float cT = cos(TWIST_STRENGTH * p.y);
            float sT = sin(TWIST_STRENGTH * p.y);
            p.xz = mat2(cT, -sT, sT, cT) * p.xz;
        #elif TWIST_AXIS == 1
            float cT = cos(TWIST_STRENGTH * p.x);
            float sT = sin(TWIST_STRENGTH * p.x);
            p.yz = mat2(cT, -sT, sT, cT) * p.yz;
        #else
            float cT = cos(TWIST_STRENGTH * p.z);
            float sT = sin(TWIST_STRENGTH * p.z);
            p.xy = mat2(cT, -sT, sT, cT) * p.xy;
        #endif
    #endif

    #if USE_DOMAIN_BEND
        #if BEND_AXIS == 0
            float cB = cos(BEND_STRENGTH * p.x);
            float sB = sin(BEND_STRENGTH * p.x);
            p.xy = mat2(cB, -sB, sB, cB) * p.xy;
        #elif BEND_AXIS == 1
            float cB = cos(BEND_STRENGTH * p.y);
            float sB = sin(BEND_STRENGTH * p.y);
            p.yz = mat2(cB, -sB, sB, cB) * p.yz;
        #else
            float cB = cos(BEND_STRENGTH * p.z);
            float sB = sin(BEND_STRENGTH * p.z);
            p.zx = mat2(cB, -sB, sB, cB) * p.zx;
        #endif
    #endif

    #if USE_KALEIDOSCOPE
        vec2 plane = p.xz - KALEIDO_CENTER;
        float angle = 6.28318530718 / KALEIDO_SECTORS;
        float a = atan(plane.y, plane.x) + KALEIDO_ANGLE_OFFSET;
        float r = length(plane);
        a = mod(a, angle) - angle * 0.5;
        p.xz = vec2(cos(a), sin(a)) * r + KALEIDO_CENTER;
    #endif

    #if USE_KALEIDO_3D_TETRAHEDRAL
        p.xy = p.x < -p.y ? -p.yx : p.xy;
        p.xz = p.x < -p.z ? -p.zx : p.xz;
        p.yz = p.y < -p.z ? -p.zy : p.yz;
    #endif

    #if USE_KALEIDO_3D_OCTAHEDRAL
        p = abs(p);
        p.xy = p.x < p.y ? p.yx : p.xy;
        p.xz = p.x < p.z ? p.zx : p.xz;
        p.yz = p.y < p.z ? p.zy : p.yz;
    #endif

    #if USE_KALEIDO_3D_ICOSAHEDRAL
        p = abs(p);
        vec3 n1 = vec3(-0.5, 0.8660254, 0.0);
        vec3 n2 = vec3(0.8660254, -0.5, 0.0);
        vec3 n3 = vec3(0.0, -0.5, 0.8660254);
        p -= 2.0 * min(0.0, dot(p, n1)) * n1;
        p -= 2.0 * min(0.0, dot(p, n2)) * n2;
        p -= 2.0 * min(0.0, dot(p, n3)) * n3;
    #endif

    #if USE_LOG_POLAR
        vec2 lpPlane;
        #if LOG_POLAR_PLANE_SELECT == 0
            lpPlane = p.xz - LOG_POLAR_CENTER;
        #elif LOG_POLAR_PLANE_SELECT == 1
            lpPlane = p.xy - LOG_POLAR_CENTER;
        #else
            lpPlane = p.yz - LOG_POLAR_CENTER;
        #endif

        float rLog = length(lpPlane);
        float aLog = atan(lpPlane.y, lpPlane.x) * LOG_POLAR_BRANCHES;
        float rMapped = log(rLog + 0.0001) * LOG_POLAR_SCALE + iTime * LOG_POLAR_ANIM_SPEED;
        float aMapped = (aLog + rLog * LOG_POLAR_SWIRL) * LOG_POLAR_SCALE;

        vec2 mappedUV = vec2(
            rMapped * cos(LOG_POLAR_SPIRAL_ANGLE) - aMapped * sin(LOG_POLAR_SPIRAL_ANGLE),
            rMapped * sin(LOG_POLAR_SPIRAL_ANGLE) + aMapped * cos(LOG_POLAR_SPIRAL_ANGLE)
        );

        #if LOG_POLAR_PLANE_SELECT == 0
            p.xz = mappedUV + LOG_POLAR_CENTER;
        #elif LOG_POLAR_PLANE_SELECT == 1
            p.xy = mappedUV + LOG_POLAR_CENTER;
        #else
            p.yz = mappedUV + LOG_POLAR_CENTER;
        #endif
    #endif

    for (int i = 0; i < FOLD_ITERATIONS; i++) {
        #if USE_BOX_FOLD
            p = clamp(p, -BOX_FOLD_LIMIT, BOX_FOLD_LIMIT) * BOX_FOLD_VALUE - p;
        #endif

        #if USE_SPHERE_FOLD
            float r2 = dot(p, p);
            if (r2 < SPHERE_FOLD_MIN_RAD) {
                p *= SPHERE_FOLD_MAX_RAD / SPHERE_FOLD_MIN_RAD;
            } else if (r2 < SPHERE_FOLD_MAX_RAD) {
                p *= SPHERE_FOLD_MAX_RAD / r2;
            }
        #endif

        #if USE_FOLDING
            vec3 foldNorm = normalize(FOLD_PLANE_NORMAL);
            p -= 2.0 * min(0.0, dot(p, foldNorm) - FOLD_DISTANCE) * foldNorm;
        #endif

        #if USE_OCTAHEDRAL_FOLD
            p = abs(p);
            if (p.x < p.y) p.xy = p.yx;
            if (p.x < p.z) p.xz = p.zx;
            if (p.y < p.z) p.yz = p.zy;
        #endif

        #if USE_DODECAHEDRAL_FOLD
            vec3 d1 = vec3(0.30901699, 0.5, 0.80901699);
            vec3 d2 = vec3(0.80901699, 0.30901699, 0.5);
            p -= 2.0 * min(0.0, dot(p, d1)) * d1;
            p -= 2.0 * min(0.0, dot(p, d2)) * d2;
        #endif

        #if USE_MENGER_FOLD
            p = abs(p);
            if (p.x - p.y < 0.0) p.xy = p.yx;
            if (p.x - p.z < 0.0) p.xz = p.zx;
            if (p.y - p.z < 0.0) p.yz = p.zy;
            p.z -= 0.5 * (1.0 - 1.0 / 3.0);
            p.z = -abs(p.z);
            p.z += 0.5 * (1.0 - 1.0 / 3.0);
        #endif

        p = p * FOLD_SCALE_FACTOR + FOLD_TRANSLATION;
    }

    return p;
}

float mapSimple(vec3 p) {
    p = applyDomainWarping(p);
    float r = max(length(p.xy), MIN_RADIUS_EPS);
    return CYLINDER_RADIUS - r;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(NORMAL_EPSILON, ZERO_FLOAT);
    return normalize(vec3(
        mapSimple(p + e.xyy) - mapSimple(p - e.xyy),
        mapSimple(p + e.yxy) - mapSimple(p - e.yxy),
        mapSimple(p + e.yyx) - mapSimple(p - e.yyx)
    ));
}

float calcSoftShadow(vec3 ro, vec3 rd) {
    float res = ONE_FLOAT;
    float t = SHADOW_MIN_DIST;
    for (int i = 0; i < SHADOW_STEPS; i++) {
        float h = mapSimple(ro + rd * t);
        if (h < 0.001) return ZERO_FLOAT;
        res = min(res, SHADOW_K * h / t);
        t += clamp(h, 0.02, 0.2);
        if (t > SHADOW_MAX_DIST) break;
    }
    return clamp(res, ZERO_FLOAT, ONE_FLOAT);
}

float calcAO(vec3 p, vec3 N) {
    float occ = ZERO_FLOAT;
    float sca = ONE_FLOAT;
    for (int i = 0; i < AO_STEPS; i++) {
        float h = AO_STEP_SIZE * float(i + 1);
        float d = mapSimple(p + N * h);
        occ += (h - d) * sca;
        sca *= 0.75;
    }
    return clamp(ONE_FLOAT - AO_INTENSITY * occ, ZERO_FLOAT, ONE_FLOAT);
}

vec3 computeLighting(vec3 p, vec3 N, vec3 V, vec3 baseColor) {
    vec3 L = normalize(LIGHT_DIR);
    vec3 H = normalize(L + V);
    
    float shadow = ONE_FLOAT;
    #if USE_SOFT_SHADOWS
        shadow = calcSoftShadow(p + N * 0.005, L);
    #endif
    
    float ao = ONE_FLOAT;
    #if USE_AO
        ao = calcAO(p, N);
    #endif
    
    float diff = max(dot(N, L), LIGHT_DIFF_MIN);
    float spec = pow(max(dot(N, H), LIGHT_SPEC_MIN), SPEC_POWER);
    vec3 diffuse = diff * shadow * LIGHT_COLOR * baseColor;
    vec3 specular = spec * shadow * LIGHT_COLOR;
    vec3 ambient = AMBIENT_COLOR * baseColor * ao;
    return ambient + diffuse + specular;
}

vec3 computeMaterialColor(vec3 p, vec2 u, float f, float dist) {
    #if COLOR_MODE == 1
        return palette(f);
    #elif COLOR_MODE == 2
        vec3 N = calcNormal(p);
        return N * NORMAL_COLOR_OFFSET + NORMAL_COLOR_OFFSET;
    #elif COLOR_MODE == 3
        float t = clamp((dist - DEPTH_RANGE.x) / (DEPTH_RANGE.y - DEPTH_RANGE.x), 0.0, 1.0);
        return mix(DEPTH_COLOR_NEAR, DEPTH_COLOR_FAR, t);
    #elif COLOR_MODE == 4
        float trap = pow(abs(f), ORBIT_POWER);
        return mix(ORBIT_COLOR_1, ORBIT_COLOR_2, clamp(trap, 0.0, 1.0));
    #else
        return 0.5 + 0.5 * cos(COLOR_PHASE_VEC + u.y * COLOR_ANGULAR_SCALE + p.z * COLOR_Z_SCALE + iTime);
    #endif
}

vec4 march(vec2 u, vec2 r, float t, vec2 m) {
    vec4 o = vec4(ZERO_FLOAT);
    vec3 c = CAM_OFFSET;
    vec3 rd = normalize(vec3((u + u - r.xy) / ASPECT_RATIO_DIVISOR, CAM_FOV));
    
    mat2 rotX = rot2D(m.y);
    mat2 rotY = rot2D(m.x);
    rd.xz *= rotY;
    rd.xy *= rotX;

    vec3 dVec = rd;
    float distAccum = ZERO_FLOAT;
    float i = MARCH_LOOP_START;
    float s = ZERO_FLOAT;

    for (o *= ZERO_FLOAT; i++ < MAX_STEPS; distAccum += max(s, STEP_PULL)) {
        vec3 p = c + distAccum * dVec;
        vec3 pWarped = applyDomainWarping(p);
        
        float rCyl = max(length(pWarped.xy), MIN_RADIUS_EPS);
        s = CYLINDER_RADIUS - rCyl;

        if (s < REFRACT_THRESHOLD) {
            vec3 refractedRd = refract(dVec, vec3(-pWarped.xy / rCyl, ZERO_FLOAT), REFRACT_INDEX);
            if (length(refractedRd) > ZERO_FLOAT) dVec = refractedRd;
        }

        vec2 uvPattern = vec2(
            asin(clamp(sin((log(rCyl) + (pWarped.z - c.z) * WAVE_Z_SCALE - t * WAVE_TIME_SPEED) * WAVE_SIN_FREQ) * WAVE_SIN_AMP, WAVE_CLAMP_MIN, WAVE_CLAMP_MAX)),
            atan(pWarped.y, pWarped.x)
        );

        float f = sin(INTERFERENCE_FREQ * length(uvPattern - INTERFERENCE_OFFSET) - t * INTERFERENCE_SPEED_1) +
                  sin(INTERFERENCE_FREQ * length(uvPattern + INTERFERENCE_OFFSET) + t * INTERFERENCE_SPEED_2);

        vec3 baseCol = computeMaterialColor(pWarped, uvPattern, f, distAccum);
        
        #if USE_LIGHTING
            vec3 N = calcNormal(pWarped);
            baseCol = computeLighting(pWarped, N, -dVec, baseCol);
        #endif

        o.rgb += baseCol * (f * f * WAVE_ENERGY_MULT) * exp(-distAccum * FOG_ATTENUATION);
    }

    return clamp(o, COLOR_CLAMP_MIN, COLOR_CLAMP_MAX);
}

vec3 applyPostFX(vec3 col, vec2 u, vec2 r) {
    col = mix(vec3(dot(col, LUMINANCE_WEIGHTS)), col, FX_SATURATION);
    col = (col - MIDTONE_BIAS) * FX_CONTRAST + MIDTONE_BIAS;
    col = pow(max(col, GAMMA_SAFE_MIN), vec3(ONE_FLOAT / FX_GAMMA));
    
    vec2 q = u / r;
    float vig = pow(VIGNETTE_SCALE * q.x * q.y * (ONE_FLOAT - q.x) * (ONE_FLOAT - q.y), VIGNETTE_POWER);
    col *= mix(VIGNETTE_ONE, vig, FX_VIGNETTE);
    
    return clamp(col, COLOR_CLAMP_MIN, COLOR_CLAMP_MAX);
}

void mainImage(out vec4 o, vec2 u) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec2 m = iMouse.z > ZERO_FLOAT ? (iMouse.xy - r * RAY_SCREEN_OFFSET) / ASPECT_RATIO_DIVISOR * MOUSE_SENSITIVITY 
                                  : vec2(sin(t * ROT_SPEED_X) * ROT_AMP_X, sin(t * ROT_SPEED_Y) * ROT_AMP_Y);

    #if USE_ABERRATION
        float ca = ABERRATION_AMOUNT * r.x;
        vec4 colR = march(u + vec2(ca, ZERO_FLOAT), r, t, m);
        vec4 colG = march(u, r, t, m);
        vec4 colB = march(u - vec2(ca, ZERO_FLOAT), r, t, m);
        o = vec4(colR.r, colG.g, colB.b, colG.a);
    #else
        o = march(u, r, t, m);
    #endif

    #if USE_BLOOM
        vec4 blur = (march(u + vec2(BLOOM_OFFSET, ZERO_FLOAT), r, t, m) + 
                     march(u - vec2(BLOOM_OFFSET, ZERO_FLOAT), r, t, m) + 
                     march(u + vec2(ZERO_FLOAT, BLOOM_OFFSET), r, t, m) + 
                     march(u - vec2(ZERO_FLOAT, BLOOM_OFFSET), r, t, m)) * BLOOM_WEIGHT;
        o += blur * BLOOM_STRENGTH;
    #endif

    o.rgb = applyPostFX(o.rgb, u, r);
}