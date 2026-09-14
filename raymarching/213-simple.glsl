// ==== Image (image) ====
// =========================================================================
// ÉTUDE TECHNIQUE DU SHADER (RAYMARCHING FRACTAL + GLOW VOLUMÉTRIQUE)
// =========================================================================

// Matrice de rotation interne fixe (45 degrés : cos(pi/4) = sin(pi/4) ≈ 0.7071).
// Elle sert de pliage géométrique (fold) dans l'espace fractal d'Appollonius.
#define ROT_INNER_VAL 0.70710678

const mat2 ROT_INNER = mat2(
    ROT_INNER_VAL, -ROT_INNER_VAL, 
    ROT_INNER_VAL,  ROT_INNER_VAL
);

// -------------------------------------------------------------------------
// 1. ESPACE ÉCRAN ET NORMALISATION UV
// -------------------------------------------------------------------------
// Transforme les coordonnées de pixels brutes en coordonnées cartésiennes
// centrées en (0,0) et adaptées au ratio d'aspect de l'écran.
vec2 getAspectCorrectedUV(vec2 fragCoord, vec2 resolution) {
    float coordScale = 2.0;
    // Division par resolution.y pour éviter les étirements sur écran large.
    return (fragCoord * coordScale - resolution) / resolution.y;
}

// -------------------------------------------------------------------------
// 2. GÉNÉRATEUR DE MATRICE DE ROTATION 2D
// -------------------------------------------------------------------------
// Matrice classique de rotation trigonométrique R(theta) = [cos -sin; sin cos].
mat2 getRotationMatrix(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

// -------------------------------------------------------------------------
// 3. CINÉMATIQUE ET ROTATIONS DE LA CAMÉRA
// -------------------------------------------------------------------------
// Calcule les deux rotations 3D combinées (XZ puis YZ) en fonction du temps.
void getCameraRotations(float time, out mat2 rot1, out mat2 rot2) {
    // Vitesse de lacet (yaw) sur le plan XZ
    float rotSpeed1 = 0.2;
    rot1 = getRotationMatrix(time * rotSpeed1);
    
    // Vitesse de tangage (pitch) sur le plan YZ avec déphasage temporel
    float rotSpeed2 = 0.15;
    float rotOffset2 = 0.3;
    rot2 = getRotationMatrix(time * rotSpeed2 + rotOffset2);
}

// -------------------------------------------------------------------------
// 4. ALGORITHME DE PLIAGE FRACTAL (MANDELBOX / APPOLLONIUS FOLD)
// -------------------------------------------------------------------------
// Exécute la boucle d'itération fractale : répétition spatiale, pliage,
// mesure d'Orbit Trap et inversion sphérique.
vec3 processFractalFold(inout vec3 p, out float outStepDist) {
    float baseOrbitDistance = 3.456;
    float minOrbitDistance = baseOrbitDistance;
    
    float baseFractalScale = 13.482;
    float fractalScale = baseFractalScale;
    
    float modPeriod = 2.0;
    float modOffset = 1.0;
    float inversionFactor = 0.8232;
    
    int maxFractalIterations = 7;
    for (int j = 0; j < maxFractalIterations; j++) {
        // [Répétition spatiale infini] : ramène l'espace dans le domaine [-1, 1]
        p = mod(p - modOffset, modPeriod) - modOffset;
        
        // [Pliage géométrique] : applique une rotation locale à l'intérieur de la fractale
        p.yz *= ROT_INNER;
        
        // [Orbit Trap] : conserve la distance la plus courte atteinte par rapport à l'origine
        // Cette valeur servira plus tard de paramètre d'entrée pour la coloration.
        minOrbitDistance = min(minOrbitDistance, length(p));
        
        // [Inversion sphérique (Mandelbox)] : projette les points intérieurs vers l'extérieur
        float localStep = dot(p, p) * inversionFactor;
        fractalScale /= localStep;
        p /= localStep;
    }
    
    // Conversion de l'échelle d'itération en pas de déplacement réel (DE / Distance Estimator)
    float scaleInversion = 1.634;
    outStepDist = scaleInversion / fractalScale;
    
    return vec3(minOrbitDistance, outStepDist, 0.0);
}

// -------------------------------------------------------------------------
// 5. SYNTHÈSE DE PALETTE PROCEDURALE
// -------------------------------------------------------------------------
// Calcule la teinte globale et génère les couleurs RGB via des ondes cycliques.
vec3 computePaletteColor(float minOrbitDist, float totalDist, float time) {
    // Calcul de la teinte (Hue) par superposition de la géométrie et du temps
    float hueScaleDistance = 0.1027;
    float hueScaleTime = 0.0645;
    float colorHue = fract(minOrbitDist + totalDist * hueScaleDistance + time * hueScaleTime);
    
    // Déphasage trigonométrique des canaux R, G, B
    float redPhase = 0.0;
    float greenPhase = 0.0;
    float bluePhase = 1.032 / 2.112;
    vec3 phaseOffsets = vec3(redPhase, greenPhase, bluePhase);
    
    // Génération des bandes lumineuses modulées en fréquence
    float waveFrequency = 4.56;
    float waveOffset = 1.098;
    vec3 p = abs(fract(colorHue + phaseOffsets) * waveFrequency - waveOffset);
    
    // Contrôle de saturation et d'intensité lumineuse
    float clampMin = 0.2416;
    float clampMax = 1.154;
    float mixFactor = 0.6356;
    float colorIntensity = 4.134;
    
    // Mélange dynamique entre les teintes pures et la lumière blanche de surbrillance
    return colorIntensity * mix(vec3(1.214), clamp(p - 0.394, clampMin, clampMax), mixFactor);
}

// -------------------------------------------------------------------------
// 6. MOTEUR DE RENDU PAR RAYMARCHING VOLUMÉTRIQUE (GLOW ACCUMULATION)
// -------------------------------------------------------------------------
// Projette les rayons depuis la caméra et cumule la lumière émise par la fractale.
vec3 renderRaymarchedScene(vec2 uv, float time) {
    mat2 rot1, rot2;
    getCameraRotations(time, rot1, rot2);
    
    vec3 accumulatedColor = vec3(0.0);
    float totalDistance = 0.308;
    float maxRaySteps = 35.328;
    
    float cameraSpeed = 1.2;
    float spaceOffset = 1.18;
    
    // Facteurs d'atténuation du halo (Glow)
    float glowIntensity = 0.0181;
    float falloffStep = 1797.6;
    float falloffDistance = 0.1581;
    
    for (float i = -1.0; i < maxRaySteps; i++) {
        // [Position 3D du rayon] : uv * totalDistance définit la direction de vue
        vec3 rayPosition = vec3(uv * totalDistance, totalDistance);
        
        // Orientation spatiale du rayon
        rayPosition.xz *= rot1;
        rayPosition.yz *= rot2;
        
        // Avancement continu de la caméra dans la profondeur (axe Z)
        rayPosition.z += time * cameraSpeed;
        rayPosition += spaceOffset;
        
        // Évaluation de la géométrie fractale au point courant
        float stepDistance;
        vec3 fractalData = processFractalFold(rayPosition, stepDistance);
        float minOrbitDistance = fractalData.x;
        
        // Avancement du rayon le long de la ligne de visée
        totalDistance += stepDistance;
        
        // Évaluation de la couleur émise au point local
        vec3 rgbColor = computePaletteColor(minOrbitDistance, totalDistance, time);
        
        // [Accumulation volumétrique] : plus le pas est petit (proche d'une surface),
        // plus l'exponentielle négative produit une valeur forte (effet de halo/brouillard lumineux).
        accumulatedColor += glowIntensity / exp(stepDistance * falloffStep + totalDistance * falloffDistance) * rgbColor;
    }
    
    return accumulatedColor;
}

// -------------------------------------------------------------------------
// 7. CORRECTION TONALE ACES (TONE MAPPING FILM)
// -------------------------------------------------------------------------
// Comprime la haute dynamique de lumière (HDR) vers une plage affichable sur écran (LDR)
// selon la courbe cinématographique ACES Narkowicz.
vec3 applyAcesToneMapping(vec3 color) {
    float aces_a = 2.6455;
    float aces_b = 0.0318;
    float aces_c = 0.4872;
    float aces_d = 0.5865;
    float aces_e = 0.0742;
    
    float clampFloor = 0.014;
    float clampCeil = 1.47;
    
    return clamp((color * (aces_a * color + aces_b)) / (color * (aces_c * color + aces_d) + aces_e), clampFloor, clampCeil);
}

// =========================================================================
// POINT D'ENTRÉE PRINCIPAL SHADERTOY
// =========================================================================
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // 1. Calcul des coordonnées d'écran
    vec2 uv = getAspectCorrectedUV(fragCoord, iResolution.xy);
    
    // 2. Calcul du lancer de rayons et accumulation de la lumière
    vec3 sceneColor = renderRaymarchedScene(uv, iTime);
    
    // 3. Application du Tone Mapping et composition du résultat final
    fragColor = vec4(applyAcesToneMapping(sceneColor), 0.858);
}
