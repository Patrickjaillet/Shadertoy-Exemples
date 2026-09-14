// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 1. Initialisation des variables globales du shader
    // On initialise la couleur de sortie à noir opaque
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    
    // Définition de la résolution de l'écran et du temps écoulé
    vec2 resolution = iResolution.xy;
    float time = iTime;

    // Distance cumulative parcourue le long du rayon (Raymarching)
    float RayDistance = 0.0;
    
    // Facteur d'échelle de la fractale (Inversion/Plissement)
    float scaleFactor = 0.0;
    
    // Facteur d'échelle cumulé de la fractale
    float accumulatedScale = 0.0;

    // 2. Boucle principale de Raymarching (64 étapes/marches)
    for(int stepIndex = 0; stepIndex < 64; stepIndex++) 
    {
        // --- CALCUL DU RAYON ET DE LA POSITION DANS L'ESPACE 3D ---
        
        // Centrage des coordonnées UV de (-0.5 à 0.5) et ajustement au ratio de l'écran (.x)
        // L'échelle 0.4 contrôle le champ de vision (FOV / Zoom)
        vec2 uv = (fragCoord - 0.5 * resolution) / resolution.x * 0.4;
        
        // Décalage vertical du point d'origine du rayon
        uv += vec2(0.0, 1.5);
        
        // Construction de la position 3D (Point de départ + avancée le long de la vue)
        vec3 position = vec3(uv, RayDistance - 1.0);

        // --- ROTATION 3D DE LA SCÈNE (Caméra) ---
        // Application d'une matrice de rotation autour de l'axe Y (plan Z-X) en fonction du temps
        float angle = time * 0.5;
        mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        position.zx *= rotationMatrix;

        // --- ITERATIONS DE LA FRACTALE (Fold & Scale) ---
        // Initialisation du facteur d'échelle cumulé pour la formule de la fractale
        accumulatedScale = 1.8;

        // Boucle interne (18 itérations) : Plissement d'espace et inversion de sphère
        for(int fractalIter = 0; fractalIter < 18; fractalIter++) 
        {
            // Calcul du facteur d'inversion sphérique
            // Dépend de la distance au carré par rapport à l'origine
            scaleFactor = 5.7 / dot(position, position * 0.5);
            
            // Accumulation de l'échelle globale
            accumulatedScale *= scaleFactor;

            // Plissement de l'espace (Space Folding) avec symétrie absolue
            // Crée la structure géométrique complexe auto-similaire
            vec3 foldOffset = vec3(2.4 - RayDistance, 3.99 + scaleFactor * 0.08, 3.8);
            position = vec3(0.0, 4.0, 0.7) - abs(abs(position) * scaleFactor - foldOffset);
        }

        // --- MARCHE DU RAYON (Raymarch step) ---
        // Avancement du rayon basé sur la coordonnée Y transformée et l'échelle
        RayDistance += position.y / accumulatedScale;

        // --- CALCUL DU BROUILLARD ET DE LA LUMINANCE ---
        // Combinaison logarithmique de l'échelle et de la distance pour contrôler la profondeur
        accumulatedScale = log2(accumulatedScale) + RayDistance * RayDistance;

        // --- CALCUL DE LA COULEUR HSV ET ACCUMULATION ---
        // Teinte (Hue) basée sur la position Y
        float hue = 0.3 / position.y;
        
        // Saturation basée sur la position Z
        float saturation = position.z * 0.1;
        
        // Valeur (Luminosité/Lumière) basée sur l'échelle et la distance
        float brightness = accumulatedScale / 1000.0;

        // Fonction de conversion HSV vers RGB standard
        vec3 hsvOffset = vec3(0.0, 2.0 / 3.0, 1.0 / 3.0);
        vec3 colorMap = clamp(abs(fract(hue + hsvOffset) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
        vec3 rgbColor = brightness * mix(vec3(1.0), colorMap, saturation);

        // Accumulation volumétrique de la couleur (effet de densité/brouillard lumineux)
        fragColor.rgb += 0.019 - rgbColor;
    }
}
