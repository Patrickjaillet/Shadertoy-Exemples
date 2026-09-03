// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Initialisation du vecteur de couleur accumulée à zéro
    vec4 o = vec4(0.0);
    // Déclaration et initialisation des scalaires pour l'index de marche (i), la densité (e), le rayon logarithmique (R) et le facteur d'échelle de fréquence (s)
    float i = 0.0, e = 0.0, R = 1.0, s = 0.0;
    // Initialisation des vecteurs de position pour la marche du rayon (q) et le repère transformé (p)
    vec3 q = vec3(0.0), p = vec3(0.0);

    // Normalisation et centrage des coordonnées d'écran avec conservation du ratio d'aspect sur l'axe Y
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    // Définition du vecteur de direction du rayon avec ajustement de la focale / ouverture (0.6)
    vec3 d = vec3(uv * 0.6, 1.0);

    // Déplacement initial de l'origine du rayon sur l'axe Z pour reculer la caméra de la scène
    q.z -= 1.0;

    // Boucle principale d'accumulation volumétrique (Raymarching) limitée à un maximum de 80 étapes
    for(; i++ < 80.0;)
    {
        // Réinitialisation de la fréquence de départ pour la boucle de bruit procédural fractal
        s = 3.0;
        // Avancement du point de marche q le long du rayon et synchronisation de la variable de transformation p
        p = q += d * e * R * 0.52;

        // Calcul de la distance euclidienne brute du point par rapport à l'origine du repère
        float rSphere = length(p);
        // Création d'un masque d'atténuation sphérique lisse pour confiner le volume et éviter les cassures nettes aux bords
        float sphereMask = smoothstep(4.8, 1.0, rSphere);

        // Calcul de la distance radiale mise à l'échelle pour la projection logarithmique
        R = length(p * 1.7);

        // Projection spatiale tridimensionnelle vers un repère cylindrique/sphérique logarithmique animé temporellement sur l'angle
        p = vec3(
            log(R + 1e-4),
            exp2(-p.z / (R + 1e-4)),
            atan(p.y, p.x + 1e-4 * step(length(p.xy), 1e-6)) - iTime*0.3
        );

        // Initialisation du champ de potentiel/densité de base dérivé de la coordonnée verticale transformée Y
        e = --p.y;

        // Boucle de calcul du Mouvement Brownien Fractionnaire (FBM) doublant la fréquence à chaque itération jusqu'à la limite supérieure
        for(; s < 1000.0; s += s)
            // Accumulation des harmoniques : produit scalaire trigonométrique imbriquant sinus, cosinus et variables temporelles
            e += cos(dot(sin(p*s), cos(p.yyz*s + iTime*0.9))) / s * 0.45;

        // Normalisation et remappage de la densité accumulée e pondérée par la fréquence maximale s, bornée entre 0.1 et 1.0
        float val = clamp((e*s - 1.0) / 24.2, 0.1, 1.0);
        // Application du masque sphérique global à la valeur de densité calculée
        val *= sphereMask;

        // Génération de 4 masques distincts basés sur des transitions lisses pour segmenter les différentes strates de la rampe de couleur
        vec4 w = smoothstep(vec4(0.0, 0.15, 0.35, 0.65), vec4(0.15, 0.35, 0.65, 0.88), vec4(val));
        // Interpolation de la première strate : passage d'un rouge très sombre et profond à un rouge vif incandescent
        vec3 col = mix(mix(vec3(0.30, 0.00, 0.00), vec3(1.00, 0.08, 0.00), w.x), vec3(1.00, 0.45, 0.00), w.y);
        // Interpolation de la deuxième strate vers des teintes orangées vives
        // Interpolation de la troisième strate vers un jaune chaud haute intensité
        col = mix(col, vec3(1.00, 0.95, 0.15), w.z);
        // Interpolation de la quatrième strate vers un blanc/crème thermique émissif
        col = mix(col, vec3(1.20, 1.15, 1.05), w.w);
        // Ajout d'une dernière transition de couleur vers un bleu électrique surréel pour les zones de densité extrême (cœur énergétique)
        col = mix(col, vec3(0.25, 0.60, 2.00), smoothstep(0.88, 1.0, val));

        // Calcul d'une fonction d'interférence sinusoïdale à haute fréquence spatio-temporelle pour simuler un vacillement/scintillement du fluide
        float flicker = 0.9 + 0.6 * sin(iTime * 15.0 + q.z * 14.0 + e * 6.0);
        // Accumulation de la couleur du fragment modulée par la densité, le vacillement et isolée par un filtre à seuil strict (step)
        o.rgb += col * val * flicker * 0.03 * step(0.001, val);
    }

    // Application d'une fonction de mappage des tons (Tone Mapping) de Reinhard pour compresser l'échelle dynamique HDR
    o.rgb = o.rgb / (1.0 + o.rgb);
    // Correction gamma non linéaire de l'image (approximation de la courbe standard avec l'exposant 0.6750)
    o.rgb = pow(o.rgb, vec3(0.6750));

    // Écriture finale de la couleur convertie dans le tampon de sortie RGBA avec un canal alpha opaque
    fragColor = vec4(o.rgb, 1.0);
}
