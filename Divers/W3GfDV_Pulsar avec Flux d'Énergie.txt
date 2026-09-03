// ==== Image (image) ====
// Pulsar avec Flux d'Énergie Relativistes
// Palette : Blanc, Bleu Électrique, Bleu profond

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Fonction de bruit pour simuler la turbulence du plasma
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f*f*(3.0-2.0*f);
    float n = dot(i, vec3(1.0, 57.0, 113.0));
    return mix(mix(mix( fract(sin(n)*43758.5453), fract(sin(n+1.0)*43758.5453), f.x),
                   mix( fract(sin(n+57.0)*43758.5453), fract(sin(n+58.0)*43758.5453), f.x), f.y),
               mix(mix( fract(sin(n+113.0)*43758.5453), fract(sin(n+114.0)*43758.5453), f.x),
                   mix( fract(sin(n+170.0)*43758.5453), fract(sin(n+171.0)*43758.5453), f.x), f.y), f.z);
}

// Champ magnétique dipolaire
float magneticField(vec3 p, vec3 axis) {
    float r = length(p);
    if (r < 0.2) return 0.0;
    vec3 unitP = p / r;
    float cosTheta = dot(unitP, axis);
    float sin2Theta = 1.0 - cosTheta * cosTheta;
    float L = r / max(sin2Theta, 0.001);
    float lines = smoothstep(0.05, 0.0, abs(fract(L * 2.5 - iTime * 0.4) - 0.5));
    return lines * (0.8 / (r * r));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, -4);
    vec3 rd = normalize(vec3(uv, 1.5));
    
    float time = iTime * 0.8;
    // L'axe magnétique est incliné et tourne
    vec3 axis = normalize(vec3(0.4, 1.0, 0.2));
    axis.xz *= rot(time);
    
    vec3 color = vec3(0.0);

    // --- 1. Cœur de l'étoile (Neutron Star) ---
    float d = length(uv);
    color += vec3(0.8, 1.9, 3.0) * (0.08 / d);

    // --- 2. Flux d'Énergie aux Pôles (Jets) ---
    // On calcule la proximité du rayon avec l'axe magnétique
    float projection = dot(rd, axis);
    float absProj = abs(projection);
    
    // Le jet est un cône très serré (pow 150)
    if (absProj > 0.9) {
        // Coordonnées locales au jet pour l'animation du flux
        // On simule une vitesse de sortie ultra-rapide (time * 20.0)
        float flow = noise(vec3(rd * 15.0 - (axis * time * 20.0)));
        
        // Intensité du jet basée sur l'alignement + le flux turbulent
        float jetIntensity = pow(absProj, 150.0) * (1.0 + flow * 1.5);
        
        // Couleur : du blanc au centre vers le bleu électrique
        color += vec3(0.4, 0.6, 1.0) * jetIntensity * 2.0;
        color += vec3(1.0, 1.0, 1.0) * pow(absProj, 500.0) * 3.0; // Cœur du flux
    }

    // --- 3. Magnétosphère ---
    for(float i = 0.0; i < 1.5; i += 0.25) {
        vec3 p = ro + rd * (2.5 + i);
        // On applique la rotation inverse pour que le champ suive l'axe
        float field = magneticField(p, axis);
        color += vec3(0.1, 0.3, 0.7) * field * 0.2;
    }

    // --- Finition ---
    color = pow(color, vec3(1.4545)); // Gamma
    fragColor = vec4(color, 1.0);
}
