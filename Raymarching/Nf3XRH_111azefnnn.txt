// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalisation des coordonnées de l'écran (repère centré à 0,0, axe Y inversé pour correspondre à p5.js)
    vec2 st = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    st.y = -st.y;

    vec3 color = vec3(0.035); // Fond sombre (équivalent à background(9) sur 255)
    float time = iTime * 1.5;   // Progression temporelle

    // Nombre de points accumulés dans la boucle du shader
    const float totalPoints = 600.0;
    
    for (float idx = 0.0; idx < totalPoints; idx += 1.0) {
        // Variation de i entre 0 et 10000 comme dans la boucle p5.js originale
        float i = mix(0.0, 10000.0, idx / totalPoints);
        float y = i / 43.0;

        // Équivalents des variables géométriques du code p5.js
        float k = 5.0 * cos(i / 14.0) * cos(y / 30.0);
        float e = y / 8.0 - 13.0;
        
        // mag(k, e)^2 / 59 + 6
        float d = (k * k + e * e) / 59.0 + 6.0;
        
        float angle = atan(k, e); // atan2(k, e)
        float q = 90.0 - 5.0 * sin(angle * e) + k * (3.0 + sin(d * d - time * 2.0));
        float c = d / 2.0 - time / 18.0;

        // Position calculée du point (recentrée par rapport aux 400x400 de l'original)
        vec2 p = vec2(
            (q = (90.0 - 5.0 * sin(angle * e) + k * (3.0 + sin(d * d - time * 2.0)))) * sin(c),
            (q + d * pow(d, sin(d * 2.0 - time / 3.0))) * cos(c)
        ) / 200.0;

        // Rendu du point avec un flou léger (effet de trait stroke)
        float dist = length(st - p);
        float pointShape = smoothstep(0.008, 0.001, dist);
        
        color += vec3(1.0, 1.0, 1.0) * pointShape * 0.15;
    }

    fragColor = vec4(color, 1.0);
}
