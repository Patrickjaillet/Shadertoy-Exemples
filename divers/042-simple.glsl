// ==== Image (image) ====
highp float Saturer(float valeur) {
    return clamp(valeur, 0.0, 1.0);
}

highp vec3 Saturer(vec3 valeur) {
    return clamp(valeur, 0.0, 1.0);
}

vec2 CalculerUvGlint(vec2 uv, float temps, float decalage) {
    float angle = 0.5;
    float cosinus = cos(angle);
    float sinus = sin(angle);
    mat2 rotation = mat2(cosinus, -sinus, sinus, cosinus);
    vec2 uvTourne = rotation * (uv - 0.5);
    uvTourne.x += temps * 0.1 + decalage;
    return (uvTourne + 0.5) * 2.0;
}

void mainImage(out vec4 couleurSortie, in vec2 coordonneesFragment) {
    vec2 uv = coordonneesFragment / iResolution.xy;
    vec2 uvCentre = (coordonneesFragment - 0.5 * iResolution.xy) / iResolution.y;
    
    vec2 mouvementTorche = vec2(sin(iTime * 1.1), cos(iTime * 0.8)) * 0.12;
    float distanceTorche = length(uvCentre - mouvementTorche);
    
    float faisceauPrincipal = smoothstep(0.75, 0.0, distanceTorche);
    float pointChaudCentral = pow(smoothstep(0.35, 0.0, distanceTorche), 3.0);
    
    vec3 couleurJauneChaud = vec3(1.0, 0.92, 0.65); 
    vec3 eclatTorche = couleurJauneChaud * (faisceauPrincipal * 1.5 + pointChaudCentral * 1.2);

    vec3 albedoEntite = 0.5 + 0.5 * cos(uv.xyx + vec3(0, 2, 4));
    float occlusionTotale = 1.0;
    vec3 renduOrbes = vec3(0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        float phase = i * 1.57;
        vec2 posOrbe = vec2(sin(iTime * 0.7 + phase), cos(iTime * 0.5 + phase)) * 0.5;
        float distFragment = length(uvCentre - posOrbe);
        
        vec2 directionOmbre = normalize(uvCentre - mouvementTorche);
        float distanceOmbre = length(uvCentre - (posOrbe + directionOmbre * 0.18));
        float adoucissementOmbre = smoothstep(0.0, 0.4, distanceOmbre);
        occlusionTotale *= mix(0.3, 1.0, adoucissementOmbre);
        
        vec3 colOrbe = 0.5 + 0.5 * cos(iTime + i + vec3(0, 2, 4));
        float coeur = 0.007 / distFragment;
        float lueurBloom = pow(Saturer(1.0 - distFragment * 2.2), 12.0) * 3.5;
        renduOrbes += colOrbe * (coeur + lueurBloom);
    }
    
    vec3 lumiereAmbiante = vec3(0.02, 0.015, 0.03);
    vec3 eclairageScene = (lumiereAmbiante + eclatTorche) * occlusionTotale;
    vec3 compositionFinale = albedoEntite * eclairageScene;
    
    vec2 uvG1 = CalculerUvGlint(uv, iTime, 0.0);
    float brillanceGlint = Saturer(sin(uvG1.x * 22.0) * cos(uvG1.y * 22.0));
    compositionFinale += brillanceGlint * vec3(0.6, 0.3, 1.0) * 0.3 * (faisceauPrincipal + 0.05);
    
    compositionFinale += renduOrbes;
    
    vec3 noirProfond = vec3(0.002, 0.002, 0.005);
    float vignetage = Saturer(exp(-length(uvCentre) * 0.7));
    compositionFinale = mix(noirProfond, compositionFinale, vignetage);
    
    couleurSortie = vec4(Saturer(compositionFinale), 1.0);
}
