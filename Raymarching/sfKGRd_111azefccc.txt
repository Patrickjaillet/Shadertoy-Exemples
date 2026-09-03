// ==== Image (image) ====
// Conversion HSV -> RGB (identique à l'original)
vec3 hsv(float h, float s, float v) {
    vec3 c = vec3(h, s, v);
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// Matrice de rotation 2D
mat2 rotate2D(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    float time = iTime * 0.2;   // rotation lente de la caméra
    fragColor = vec4(0.0);      // fond noir par défaut

    // --- CAMÉRA ORBITALE ---
    // Position de la caméra sur un cercle horizontal autour de l'origine
    vec3 camPos = vec3(sin(time) * 3.0, 0.5, cos(time) * 3.0);
    // Axe de la caméra pointant vers l'origine
    vec3 forward = normalize(-camPos);
    // Construction d'une base orthonormée (u, v, forward)
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(forward, up));
    vec3 camUp = cross(right, forward);   // v aligné sur l'axe Y

    // Rayon dans l'espace monde
    vec2 uv = (fragCoord - 0.5 * res) / res.y * 2.0;  // coordonnées normalisées
    vec3 rayDir = normalize(mat3(right, camUp, forward) * vec3(uv, 2.0));

    // --- RAYMARCHING ---
    float dist = 0.0;          // distance parcourue le long du rayon
    float stepDist;           // distance d'une étape
    float totalDensity = 0.0; // accumulateur pour le brouillard

    for (float i = 0.0; i < 80.0; i++) {
        vec3 pos = camPos + rayDir * dist;

        // IFS kaleidoscopique (folding + scaling)
        // 6 itérations pour former une fractale compacte
        for (int k = 0; k < 6; k++) {
            pos = abs(pos) - 1.2;                // symétrie octaédrique (fold)
            pos.xz *= rotate2D(0.7);             // torsion autour de Y
            pos *= 1.7;                          // mise à l'échelle
        }

        // Estimateur de distance conservatif pour l'IFS
        // La formule est longueur / scale^itérations * facteur de sécurité
        stepDist = length(pos) / pow(1.7, 6.0) * 0.5;
        totalDensity += stepDist;                // accumulation pour le brouillard

        // Sortie de la boucle si on touche une surface ou si on va trop loin
        if (stepDist < 0.001 || dist > 10.0) break;
        dist += stepDist;
    }

    // --- SHADING ---
    if (dist < 10.0) {   // le rayon a touché une surface
        vec3 hitPoint = camPos + rayDir * dist;

        // Couleur basée sur la position du point d'impact
        float hue = length(hitPoint) * 0.2
                  + sin(hitPoint.x * 3.0) * 0.1
                  + cos(hitPoint.z * 3.0) * 0.1;
        vec3 surfaceColor = hsv(hue, 0.6, 1.0);

        // Brouillard : atténuation en fonction de la densité accumulée
        float fog = exp(-totalDensity * 0.05);
        fragColor.rgb = surfaceColor * fog;
    } else {
        fragColor.rgb = vec3(0.0);   // fond noir
    }
}
