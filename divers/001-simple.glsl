// --- CONFIGURATION DE LA CAMÉRA & ESPACE ---
#define CAM_FOV 2.0                               // Champ de vision (focale de la caméra)
#define CAM_DIST -3.5                             // Distance initiale de la caméra sur l'axe Z
#define CAM_OFFSET vec3(0.0, 0.0, CAM_DIST)       // Vecteur de position d'origine de la caméra
#define CAM_LOOKAT vec3(0.0, 0.0, 0.0)            // Point cible visé par la caméra
#define ROT_SPEED_X 0.5                           // Vitesse de rotation automatique sur l'axe X (horizontal)
#define ROT_SPEED_Y 0.3                           // Vitesse de rotation automatique sur l'axe Y (vertical)
#define MOUSE_SENSITIVITY 4.0                     // Sensibilité du contrôle de la caméra à la souris
#define MOUSE_Y_SCALE 0.5                         // Facteur d'échelle d'amplitude pour le mouvement vertical automatique
#define ASPECT_RATIO_DIVISOR r.y                  // Composante de résolution utilisée pour corriger le ratio d'aspect
#define RAY_SCREEN_OFFSET 0.5                     // Facteur de centrage des coordonnées d'écran
#define RAY_DIR_Z_DEFAULT 2.0                     // Profondeur par défaut du vecteur direction du rayon
#define ZERO_FLOAT 0.0                            // Constante flottante 0.0 pour l'optimisation
#define ONE_FLOAT 1.0                             // Constante flottante 1.0 pour l'optimisation

// --- TRANSFORMATION SPATIALE & DOMAIN WARPING (MAXIMUM) ---
#define USE_DOMAIN_TWIST 0                        // Activer (1) ou désactiver (0) la torsion de l'espace (Twist)
#define TWIST_STRENGTH 0.5                        // Force de la torsion appliquée au domaine
#define TWIST_AXIS 0                              // Axe de la torsion (0: Y, 1: X, 2: Z)

#define USE_DOMAIN_BEND 0                         // Activer (1) ou désactiver (0) la courbure de l'espace (Bend)
#define BEND_STRENGTH 0.3                         // Force de courbure appliquée au domaine
#define BEND_AXIS 0                               // Axe de courbure (0: X-Y, 1: Y-Z, 2: Z-X)

#define USE_SPACE_REPETITION 0                    // Activer (1) ou désactiver (0) la répétration infinie de l'espace
#define REPETITION_SPACING vec3(4.0, 4.0, 4.0)    // Intervalle de répétition spatiale sur les axes X, Y, Z
#define USE_LIMITED_REPETITION 0                  // Activer (1) ou désactiver (0) la répétition spatiale bornée
#define REPETITION_LIMIT_MIN vec3(-2.0)           // Limite inférieure du nombre de répétitions
#define REPETITION_LIMIT_MAX vec3(2.0)            // Limite supérieure du nombre de répétitions

#define USE_POLAR_REPETITION 0                    // Activer (1) ou désactiver (0) la répétition angulaire/polaire
#define POLAR_REPETITION_SECTORS 8.0              // Nombre de secteurs pour la répétition polaire

#define USE_DOMAIN_PINCH 0                        // Activer (1) ou désactiver (0) la déformation par pincement (Pinch)
#define PINCH_STRENGTH 0.5                        // Intensité du pincement spatial

#define USE_DOMAIN_SHEAR 0                        // Activer (1) ou désactiver (0) le cisaillement de l'espace (Shear)
#define SHEAR_FACTOR vec3(0.2, 0.0, 0.0)          // Facteurs de cisaillement sur les axes X, Y, Z

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

// --- SÉLECTION & PARAMÈTRES DES FORMES DE BASE (SDF) ---
#define SHAPE_TYPE 0                              // Forme de base (0: Sphère, 1: Cube, 2: Torus, 3: Fractale, 4: Cylindre, 5: Cône, 6: Prisme)
#define SPHERE_RADIUS 1.2                         // Rayon de la sphère de base
#define CUBE_SIZE vec3(0.8)                       // Dimensions du cube sur les axes X, Y, Z
#define CUBE_ROUNDING 0.0                         // Rayon d'arrondissement des coins du cube
#define TORUS_RAD vec2(0.9, 0.3)                  // Rayons du torus (rayon principal, rayon de la section)
#define CYLINDER_RAD vec2(0.8, 1.0)               // Dimensions du cylindre (rayon, demi-hauteur)
#define CONE_RAD vec2(0.8, 1.2)                   // Dimensions du cône (angle/rayon, hauteur)
#define PRISM_SIZE vec2(1.0, 0.5)                 // Dimensions du prisme triangulaire (largeur, profondeur)

// --- MOTEUR DE RAYMARCHING ---
#define MAX_STEPS 60.0                            // Nombre maximal de pas d'évaluation le long du rayon
#define MIN_DIST 0.01                             // Distance minimale à la surface pour valider un impact
#define STEP_PULL 0.02                            // Pas d'avancement minimal Garanti pour éviter les boucles infinies
#define GLOW_THRESHOLD 0.01                       // Seuil de distance pour l'accumulation du halo lumineux (Glow)
#define MARCH_LOOP_START 0.0                      // Valeur initiale du compteur de boucle du Raymarching
#define MARCH_STEP_INC 1.0                        // Incrément par itération dans la boucle de Raymarching

// --- BRUIT & DEFORMATION DISPLACEMENT ---
#define NOISE_OCTAVES 5.0                         // Nombre d'octaves de bruit pour le bruit fractal FBM
#define NOISE_SCALE 2.0                           // Échelle spatiale de fréquence du bruit 3D
#define NOISE_AMP 0.5                             // Amplitude/force de la déformation par le bruit
#define NOISE_SPEED 1.0                           // Vitesse d'animation temporelle du bruit
#define HASH_MULT 43758.5                         // Multiplicateur chaotique pour la fonction de hachage sinusoïdale
#define NOISE_VEC vec3(1.0, 57.0, 113.0)          // Coefficients d'espacement spatial pour le hachage 3D
#define NOISE_OFFSETS vec4(0.0, 57.0, 113.0, 170.0) // Offsets d'indexation des sommets du cube pour le bruit
#define HASH_OFFSET_1 1.0                         // Décalage unitaire pour l'interpolation des sommets adjacents
#define HASH_OFFSET_2 2.0                         // Décalage secondaire pour les calculs de gradients
#define NOISE_SMOOTH_MULT 3.0                     // Coefficient de lissage pour la courbe d'interpolation d'Hermite
#define NOISE_AMP_INITIAL 0.5                     // Amplitude initiale de la première octave de bruit
#define NOISE_AMP_FACTOR 0.5                      // Facteur d'atténuation d'amplitude à chaque octave
#define NOISE_LOOP_START 0.0                      // Valeur initiale de boucle pour le calcul FBM
#define NOISE_STEP_INC 1.0                        // Pas d'incrémentation des itérations d'octave

// --- ÉCLAIRAGE, OMBRES & AMBIENT OCCLUSION ---
#define USE_LIGHTING 0                            // Activer (1) ou désactiver (0) le système d'éclairage avec normales
#define LIGHT_DIR normalize(vec3(1.0, 2.0, -2.0)) // Vecteur de direction de la source de lumière principale
#define LIGHT_COLOR vec3(1.0, 0.95, 0.85)         // Couleur de la lumière directe (teinte chaude)
#define AMBIENT_COLOR vec3(0.05, 0.08, 0.15)      // Couleur de la lumière ambiante (teinte froide)
#define SPEC_POWER 32.0                           // Exposant de brillance spéculaire (Phong/Blinn-Phong)
#define NORMAL_EPSILON 0.001                      // Intervalle d'échantillonnage pour le calcul des normales par dérivées partielles
#define LIGHT_DIFF_MIN 0.0                        // Valeur minimale de l'éclairage diffus (clamping)
#define LIGHT_SPEC_MIN 0.0                        // Valeur minimale de la réflexion spéculaire (clamping)

#define USE_SOFT_SHADOWS 0                        // Activer (1) ou désactiver (0) le calcul des ombres douces
#define SHADOW_K 16.0                             // Facteur de dureté/penombre des ombres douces (plus élevé = plus net)
#define SHADOW_MIN_DIST 0.02                      // Distance minimale du rayon d'ombre pour éviter l'auto-intersection
#define SHADOW_MAX_DIST 2.5                       // Distance maximale de recherche d'obstacles d'ombrage
#define SHADOW_STEPS 24                           // Nombre maximal de pas du rayon d'ombre

#define USE_AO 0                                  // Activer (1) ou désactiver (0) l'Ambient Occlusion (AO)
#define AO_STEPS 5                                // Nombre d'échantillons le long de la normale pour l'AO
#define AO_STEP_SIZE 0.05                         // Distance entre chaque échantillon d'AO
#define AO_INTENSITY 1.5                          // Force d'assombrissement de l'Ambient Occlusion

// --- PALETTE DE COULEURS, GRADIENTS & MATÉRIAUX (MAXIMUM) ---
#define COLOR_MODE 0                              // Mode de coloration (0: Base/Accent, 1: Palette, 2: Normales, 3: Profondeur, 4: Orbit Trap)
#define COLOR_BASE vec3(1.0, 1.0, 1.0)            // Couleur de base principale du matériau
#define COLOR_ACCENT vec3(0.9, 0.2, 0.5)          // Couleur secondaire d'accentuation

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

#define GLOW_INTENSITY 0.005                      // Intensité lumineuse ajoutée à chaque pas de Raymarching
#define DENSITY_FACTOR 0.04                       // Facteur d'échelle global de l'accumulation volumétrique de lumière
#define ALPHA_DEFAULT 1.0                         // Valeur du canal alpha par défaut pour le pixel de sortie
#define COLOR_CLAMP_MIN 0.0                       // Borne minimale de découpage de la couleur finale
#define COLOR_CLAMP_MAX 1.0                       // Borne maximale de découpage de la couleur finale

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

float mapNoise(vec3 q) {
    float f = ZERO_FLOAT;
    float a = NOISE_AMP_INITIAL;
    for (float k = NOISE_LOOP_START; k++ < NOISE_OCTAVES; a *= NOISE_AMP_FACTOR, q += q) {
        vec3 g = floor(q), h = fract(q);
        h = h * h * (NOISE_SMOOTH_MULT - h - h);
        float n = dot(g, NOISE_VEC);
        vec4 v = n + NOISE_OFFSETS;
        f += a * mix(mix(mix(fract(sin(v.x) * HASH_MULT), fract(sin(v.x + HASH_OFFSET_1) * HASH_MULT), h.x),
                         mix(fract(sin(v.y) * HASH_MULT), fract(sin(v.y + HASH_OFFSET_1) * HASH_MULT), h.x), h.y),
                     mix(mix(fract(sin(v.z) * HASH_MULT), fract(sin(v.z + HASH_OFFSET_1) * HASH_MULT), h.x),
                         mix(fract(sin(v.w) * HASH_MULT), fract(sin(v.w + HASH_OFFSET_1) * HASH_MULT), h.x), h.y), h.z);
    }
    return f;
}

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, ZERO_FLOAT)) + min(max(q.x, max(q.y, q.z)), ZERO_FLOAT) - CUBE_ROUNDING;
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

float sdCylinder(vec3 p, vec2 h) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - h;
    return min(max(d.x, d.y), ZERO_FLOAT) + length(max(d, ZERO_FLOAT));
}

float sdCone(vec3 p, vec2 c) {
    float q = length(p.xz);
    return max(dot(c.xy, vec2(q, p.y)), -p.y - c.y);
}

float sdTriPrism(vec3 p, vec2 h) {
    vec3 q = abs(p);
    return max(q.z - h.y, max(q.x * 0.866025 + p.y * 0.5, -p.y) - h.x * 0.5);
}

float sdFractal(vec3 p) {
    #if FRACTAL_TYPE == 0
        float s = ONE_FLOAT;
        for (int i = 0; i < FRACTAL_ITER; i++) {
            p = abs(p) - FRACTAL_OFFSET;
            p.xy *= rot2D(FRACTAL_ROT_XY);
            p.xz *= rot2D(FRACTAL_ROT_XZ);
            p.yz *= rot2D(FRACTAL_ROT_YZ);
            float k = FRACTAL_SCALE / clamp(dot(p, p), FRACTAL_CLAMP_MIN, FRACTAL_CLAMP_MAX);
            p *= k;
            s *= k;
        }
        return (length(p) - FRACTAL_RADIUS) / s;

    #elif FRACTAL_TYPE == 1
        vec3 offset = p;
        float dr = 1.0;
        for (int i = 0; i < FRACTAL_ITER; i++) {
            p = clamp(p, -MANDELBOX_FOLD_LIMIT, MANDELBOX_FOLD_LIMIT) * 2.0 - p;
            float r2 = dot(p, p);
            if (r2 < MANDELBOX_MIN_RADIUS) {
                float temp = (MANDELBOX_FIXED_RADIUS / MANDELBOX_MIN_RADIUS);
                p *= temp;
                dr *= temp;
            } else if (r2 < MANDELBOX_FIXED_RADIUS) {
                float temp = (MANDELBOX_FIXED_RADIUS / r2);
                p *= temp;
                dr *= temp;
            }
            p = p * MANDELBOX_SCALE + offset;
            dr = dr * abs(MANDELBOX_SCALE) + 1.0;
        }
        return length(p) / abs(dr);

    #elif FRACTAL_TYPE == 2
        float d = sdBox(p, vec3(1.0));
        float s = 1.0;
        for (int m = 0; m < FRACTAL_ITER; m++) {
            vec3 a = mod(p * s, 2.0) - 1.0;
            s *= MENGER_SCALE;
            vec3 r = abs(1.0 - 3.0 * abs(a));
            float da = max(r.x, r.y);
            float db = max(r.y, r.z);
            float dc = max(r.z, r.x);
            float c = (min(da, min(db, dc)) - 1.0) / s;
            d = max(d, c);
        }
        return d;

    #elif FRACTAL_TYPE == 3
        vec3 w = p;
        float dr = 1.0;
        float r = 0.0;
        for (int i = 0; i < FRACTAL_ITER; i++) {
            r = length(w);
            if (r > MANDELBULB_BAILOUT) break;
            float theta = acos(w.z / r);
            float phi = atan(w.y, w.x);
            dr = pow(r, MANDELBULB_POWER - 1.0) * MANDELBULB_POWER * dr + 1.0;
            float zr = pow(r, MANDELBULB_POWER);
            theta = theta * MANDELBULB_POWER;
            phi = phi * MANDELBULB_POWER;
            w = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
            w += p;
        }
        return 0.5 * log(r) * r / dr;

    #else
        return length(p) - 1.0;
    #endif
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

float getBaseSDF(vec3 p) {
    p = applyDomainWarping(p);
    #if SHAPE_TYPE == 0
        return sdSphere(p, SPHERE_RADIUS);
    #elif SHAPE_TYPE == 1
        return sdBox(p, CUBE_SIZE);
    #elif SHAPE_TYPE == 2
        return sdTorus(p, TORUS_RAD);
    #elif SHAPE_TYPE == 3
        return sdFractal(p);
    #elif SHAPE_TYPE == 4
        return sdCylinder(p, CYLINDER_RAD);
    #elif SHAPE_TYPE == 5
        return sdCone(p, CONE_RAD);
    #elif SHAPE_TYPE == 6
        return sdTriPrism(p, PRISM_SIZE);
    #else
        return sdSphere(p, SPHERE_RADIUS);
    #endif
}

float map(vec3 p, out float f) {
    vec3 q = p * NOISE_SCALE + iTime * NOISE_SPEED;
    f = mapNoise(q);
    return getBaseSDF(p) - f * NOISE_AMP;
}

float mapSimple(vec3 p) {
    float dummy;
    return map(p, dummy);
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

vec3 computeMaterialColor(vec3 p, float f, float dist, vec3 rd) {
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
        return mix(COLOR_BASE, COLOR_ACCENT, f);
    #endif
}

vec4 march(vec2 u, vec2 r, float t, vec2 m) {
    vec4 o = vec4(ZERO_FLOAT);
    float s = ZERO_FLOAT, i = MARCH_LOOP_START, d, f;
    
    mat2 rotY = rot2D(m.x);
    mat2 rotX = rot2D(m.y);

    for (o *= ZERO_FLOAT; i++ < MAX_STEPS; s += max(d, STEP_PULL)) {
        vec3 rd = normalize(vec3((u + u - r) / ASPECT_RATIO_DIVISOR, CAM_FOV));
        vec3 ro = CAM_OFFSET;
        
        rd.yz *= rotX;
        rd.xz *= rotY;
        ro.yz *= rotX;
        ro.xz *= rotY;

        vec3 p = ro + rd * s;
        d = map(p, f);
        
        if (d < MIN_DIST) {
            vec3 stepColor = computeMaterialColor(p, f, s, rd);
            
            #if USE_LIGHTING
                vec3 N = calcNormal(p);
                stepColor = computeLighting(p, N, -rd, stepColor);
            #endif
            o += (GLOW_INTENSITY / (d * d + GLOW_THRESHOLD)) * vec4(stepColor, ALPHA_DEFAULT);
        }
    }
    return clamp(o * DENSITY_FACTOR, COLOR_CLAMP_MIN, COLOR_CLAMP_MAX);
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
    vec2 m = iMouse.z > ZERO_FLOAT ? (iMouse.xy - r * RAY_SCREEN_OFFSET) / ASPECT_RATIO_DIVISOR * MOUSE_SENSITIVITY : vec2(t * ROT_SPEED_X, sin(t * ROT_SPEED_Y) * MOUSE_Y_SCALE);

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