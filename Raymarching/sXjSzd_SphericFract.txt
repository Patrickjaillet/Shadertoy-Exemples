// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    // Initialisation du vecteur de couleur de sortie à zéro (fond noir transparent)
    O = vec4(0);
    // Calcul du vecteur de direction du rayon (Ray Direction) normalisé et centré avec un ajustement du champ de vision (* 0.53) et de l'origine (q)
    vec3 d = normalize(vec3((C * 2. - iResolution.xy) / iResolution.y * .53, 1)), q = vec3(0, 0, -2.22), p;
    // Déclaration des scalaires pour l'itération de marche (i), la SDF/densité (e), la distance radiale (R), l'échelle de fréquence (s), l'opacité/facteur et l'amplitude (a, v)
    float i = 0., e = 0., R = 0., s, n, a, v;
    
    // Boucle principale d'accumulation volumétrique limitée à un maximum de 74 étapes de marche
    for (; i++ < 74.;) {
        // Avancement du point courant q le long du rayon et copie dans p pour appliquer les transformations de coordonnées
        p = q += d * e * R * .35;
        // Calcul du module / distance radiale du point pour la transformation en coordonnées logarithmiques et polaires
        R = length(p * .21);
        // Projection de l'espace tridimensionnel dans un repère de coordonnées cylindriques logarithmiques animées (Log-Spherical/Cylindrical mapping)
        p = vec3(log(R + 1e-4), exp2(-p.z / (R + 1e-4)), atan(p.y, p.x + 1e-4 * step(length(p.xy), 1e-6)) - iTime * .28);

        // Initialisation de la densité de base décalée sur la coordonnée y transformée
        e = --p.y;
        // Boucle de texture procédurale FBM (Fractal Brownian Motion) par produit scalaire trigonométrique s'étendant de la fréquence 12 à 4096
        for (s = 12., a = .45; s < 8192.; s *= 2., a *= .48)
            // Accumulation harmonique de vagues de bruit sinusoïdales entrelacées (Sin/Cos modulant les composantes spatiales et temporelles)
            e += a * cos(dot(sin(p * s), cos(p.yyz * s + iTime * .92)));
        // Calcul de l'intensité volumétrique finale héritée du bruit, encapsulée dans un masque d'atténuation sphérique global (smoothstep)
        v = clamp(e * s, .1, .6) * smoothstep(5.2, .8, length(q));
        
        // Condition d'évaluation de la densité : si la contribution énergétique de la tranche de volume est significative
        if (v > .001)
            // Accumulation de l'incandescence chromatique (dégradé Rouge -> Orange) modulée par un motif d'interférence et de pulsation haute fréquence
            O.rgb += mix(vec3(1, .12, 0), 
            vec3(1, .48, 0), smoothstep(.12, .32, v)) * v * (1. + sin(iTime * 14. + q.z * 18. + e * 8. + p.x * 6.)) * .12;
    }
    // Application d'un opérateur de mappage des tons (Tone Mapping) de type Reinhard modifié pour compresser les hautes lumières HDR vers le LDR
    O.rgb = pow(O.rgb / (1. + O.rgb * .92), vec3(.68));
}
