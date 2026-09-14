// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalisation des coordonnées de l'écran (-1 à 1)
    vec2 u = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    float t = iTime * 0.4;

    // Orientation de la caméra et effet de lentille (FOV)
    vec3 ro = vec3(0.0, 0.0, -2.5);
    vec3 rd = normalize(vec3(u * 0.8, 1.0));

    // Matrice de rotation 2D pour la caméra
    float c0 = cos(t * 0.3), s0 = sin(t * 0.3);
    mat2 rotCam = mat2(c0, -s0, s0, c0);
    rd.xy *= rotCam;

    vec3 col = vec3(0.0);
    float acc = 0.0;
    float accumulatedDistance = 0.0;

    // Raymarching volumétrique
    for (int i = 0; i < 96; i++) {
        vec3 p = ro + rd * accumulatedDistance;

        // Distorsion spatiale et torsions successives
        float a = p.z * 0.4 + t;
        float ca = cos(a), sa = sin(a);
        mat2 rMat = mat2(ca, -sa, sa, ca);
        p.xy *= rMat;

        // Symétrie et suivi de l'échelle accumulée
        p = abs(p) - 0.4;
        p.xy *= rMat;
        
        float accumulatedScale = 1.0 + length(p.xy); // Échelle locale pour normaliser le pas

        // Insertion du snippet adapté
        vec3 rotatedPosition = p;
        float yMagnitude = length(rotatedPosition.yy);
        
        // SÉCURITÉ : Évite la division par zéro si rotatedPosition.y ou accumulatedScale est nul
        float safeY = abs(rotatedPosition.y) < 0.0001 ? 0.0001 : rotatedPosition.y;
        float safeScale = max(accumulatedScale, 0.0001);
        
        float fieldStep = mod(yMagnitude, safeY) / safeScale * 0.5;
        accumulatedDistance += fieldStep;

        // Dynamic SDF pour le rendu volumétrique
        float d = length(p.xy) - 0.15;
        d += sin(p.z * 8.0 + t * 2.0) * 0.03;
        d = max(d, 0.002);

        // Accumulation de lumière volumétrique
        float density = exp(-d * 12.0);
        acc += density * (1.0 / (1.0 + accumulatedDistance * accumulatedDistance * 0.1));

        if (accumulatedDistance > 10.0) break;
    }

    // Palette cinématique basée sur le temps et la profondeur
    vec3 baseColor = 0.5 + 0.5 * cos(t + accumulatedDistance * 0.2 + vec3(0.0, 2.0, 4.0));
    vec3 accentColor = vec3(0.1, 0.5, 1.0);

    col = acc * 0.02 * mix(baseColor, accentColor, sin(accumulatedDistance * 2.0) * 0.5 + 0.5);

    // Vignettage cinématique
    vec2 uv = fragCoord / iResolution.xy;
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);
    col *= vignette;

    // ACES Tone Mapping
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    col = clamp(col, 0.0, 1.0);

    // Correction Gamma
    col = pow(col, vec3(1.0 / 2.2));

    fragColor = vec4(col, 1.0);
}
