// ==== Image (image) ====
// PRIME WAVES / RIEMANN ZETA
// Shadertoy - Image shader
//
// Nombres premiers = émetteurs d'ondes
// Entiers = points sur une spirale à angle doré
// Fond = approximation basée sur les zéros non triviaux de zeta

#define PI 3.14159265359
#define TAU 6.28318530718
#define PHI 1.61803398875
#define GOLDEN_ANGLE 2.39996322973

// ============================================================
// Premiers zéros non triviaux de zeta :
// rho = 1/2 + i * gamma
// On utilise ici leurs parties imaginaires gamma.
// ============================================================

const float Z0 = 14.134725;
const float Z1 = 21.022040;
const float Z2 = 25.010858;
const float Z3 = 30.424876;
const float Z4 = 32.935062;
const float Z5 = 37.586178;
const float Z6 = 40.918719;
const float Z7 = 43.327073;
const float Z8 = 48.005151;
const float Z9 = 49.773832;
const float Z10 = 52.970321;
const float Z11 = 56.446248;
const float Z12 = 59.347044;
const float Z13 = 60.831779;
const float Z14 = 65.112544;
const float Z15 = 67.079811;
const float Z16 = 69.546402;
const float Z17 = 72.067158;
const float Z18 = 75.704691;
const float Z19 = 77.144840;

// ============================================================
// Hash pseudo-aléatoire
// ============================================================

float hash21(float p)
{
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

// ============================================================
// Test de primalité
// ============================================================

bool isPrime(int n)
{
    if(n < 2) return false;
    if(n == 2) return true;
    if(n % 2 == 0) return false;

    for(int i = 3; i <= 100; i += 2)
    {
        if(i * i > n) break;
        if(n % i == 0) return false;
    }

    return true;
}

// ============================================================
// Position d'un entier sur la spirale d'or
// ============================================================

vec2 spiralPosition(float n)
{
    // Rayon type sqrt(n) : distribution de type phyllotaxie
    float r = sqrt(n) * 0.115;

    // Angle d'or
    float a = n * GOLDEN_ANGLE;

    return vec2(cos(a), sin(a)) * r;
}

// ============================================================
// Zéros de Riemann
// Construction d'un champ oscillatoire à partir de
// cos(gamma * log(r))
// ============================================================

float zetaZeroField(vec2 p)
{
    float r = length(p) + 0.001;

    // Coordonnée logarithmique.
    float x = log(r * 2.5 + 0.03);

    float f = 0.0;

    f += cos(Z0  * x) / sqrt(Z0);
    f += cos(Z1  * x) / sqrt(Z1);
    f += cos(Z2  * x) / sqrt(Z2);
    f += cos(Z3  * x) / sqrt(Z3);
    f += cos(Z4  * x) / sqrt(Z4);
    f += cos(Z5  * x) / sqrt(Z5);
    f += cos(Z6  * x) / sqrt(Z6);
    f += cos(Z7  * x) / sqrt(Z7);
    f += cos(Z8  * x) / sqrt(Z8);
    f += cos(Z9  * x) / sqrt(Z9);

    f += cos(Z10 * x) / sqrt(Z10);
    f += cos(Z11 * x) / sqrt(Z11);
    f += cos(Z12 * x) / sqrt(Z12);
    f += cos(Z13 * x) / sqrt(Z13);
    f += cos(Z14 * x) / sqrt(Z14);
    f += cos(Z15 * x) / sqrt(Z15);
    f += cos(Z16 * x) / sqrt(Z16);
    f += cos(Z17 * x) / sqrt(Z17);
    f += cos(Z18 * x) / sqrt(Z18);
    f += cos(Z19 * x) / sqrt(Z19);

    return f / 3.2;
}

// ============================================================
// Fonction distance à une onde circulaire
// ============================================================

float ringWave(float d, float radius, float width)
{
    float x = abs(d - radius);
    return exp(-x * x / (width * width));
}

// ============================================================
// Ondes générées par les nombres premiers
// ============================================================

float primeWaves(vec2 p, float time)
{
    float field = 0.0;

    // Nombre maximum de points dessinés.
    // Augmenter à 250/300 si le GPU le permet.
    for(int i = 2; i <= 180; i++)
    {
        if(!isPrime(i))
            continue;

        vec2 q = spiralPosition(float(i));

        // Distance au centre du premier
        float d = length(p - q);

        // Chaque premier a une phase différente.
        float phase = float(i) * 0.37;

        // Vitesse légèrement différente selon le premier.
        float speed = 0.72 + 0.16 * hash21(float(i));

        // Rayon de l'onde
        float waveRadius =
            mod(time * speed + phase, 1.8);

        // Anneaux multiples
        float w = 0.0;

        w += ringWave(d, waveRadius, 0.018);
        w += 0.55 * ringWave(d, waveRadius * 0.72, 0.014);
        w += 0.30 * ringWave(d, waveRadius * 0.43, 0.010);

        // Décroissance avec la distance
        w *= exp(-d * 1.15);

        field += w;
    }

    return field;
}

// ============================================================
// Particules / points premiers
// ============================================================

vec3 primePoints(vec2 p)
{
    vec3 col = vec3(0.0);

    for(int i = 2; i <= 180; i++)
    {
        if(!isPrime(i))
            continue;

        vec2 q = spiralPosition(float(i));

        float d = length(p - q);

        // Taille des points
        float size = 0.012 + 0.004 *
                     (1.0 + sin(float(i)));

        float dot = exp(-d * d / (size * size));

        // Les grands premiers sont légèrement plus lumineux.
        float intensity = 0.55 +
                          0.45 * hash21(float(i) * 7.13);

        col += dot * intensity *
               vec3(1.0, 0.55, 0.15);
    }

    return col;
}

// ============================================================
// Halo central
// ============================================================

vec3 centralGlow(vec2 p)
{
    float d = length(p);

    float glow =
        exp(-d * d * 8.0);

    float core =
        exp(-d * d * 180.0);

    return vec3(0.9, 0.45, 0.12) * glow * 0.12
         + vec3(1.0, 0.75, 0.3) * core;
}

// ============================================================
// Spirale très subtile en arrière-plan
// ============================================================

float goldenSpiral(vec2 p)
{
    float r = length(p) + 0.0001;
    float a = atan(p.y, p.x);

    float s =
        sin(a - log(r) * PHI * 5.0);

    return exp(-abs(s) * 8.0);
}

// ============================================================
// MAIN
// ============================================================

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Coordonnées centrées
    vec2 uv =
        (fragCoord - 0.5 * iResolution.xy)
        / iResolution.y;

    // Zoom
    uv *= 1.35;

    float time = iTime * 0.35;

    // Rotation très lente du champ
    float ca = cos(time * 0.08);
    float sa = sin(time * 0.08);

    uv = mat2(ca, -sa, sa, ca) * uv;

    // --------------------------------------------------------
    // FOND ZÊTA
    // --------------------------------------------------------

    float z = zetaZeroField(uv);

    // Structure logarithmique
    float zPattern =
        0.5 + 0.5 * sin(z * 4.5);

    // --------------------------------------------------------
    // Spirale d'or
    // --------------------------------------------------------

    float spiral = goldenSpiral(uv);

    // Très faible pour laisser respirer les ondes
    float spiralGlow =
        spiral * exp(-length(uv) * 0.9);

    // --------------------------------------------------------
    // ONDES DES NOMBRES PREMIERS
    // --------------------------------------------------------

    float waves =
        primeWaves(uv, time);

    // Interaction avec le champ zêta
    float interference =
        waves * (0.65 + 0.35 * zPattern);

    // --------------------------------------------------------
    // COULEUR DU FOND
    // --------------------------------------------------------

    vec3 background =
        vec3(0.003, 0.004, 0.012);

    // Champ zêta : bleu / violet
    background +=
        vec3(0.035, 0.015, 0.075)
        * (0.5 + 0.5 * z);

    background +=
        vec3(0.015, 0.035, 0.09)
        * zPattern
        * 0.32;

    // Spirale d'or discrète
    background +=
        vec3(0.08, 0.035, 0.008)
        * spiralGlow
        * 0.18;

    // --------------------------------------------------------
    // ONDES : bleu électrique -> violet -> orange
    // --------------------------------------------------------

    vec3 waveColor =
        vec3(0.12, 0.35, 1.0)
        * interference;

    waveColor +=
        vec3(0.55, 0.10, 0.95)
        * pow(interference, 1.8);

    waveColor +=
        vec3(1.0, 0.20, 0.035)
        * pow(interference, 3.8)
        * 0.75;

    background += waveColor;

    // --------------------------------------------------------
    // POINTS PREMIERS
    // --------------------------------------------------------

    background += primePoints(uv);

    // --------------------------------------------------------
    // CENTRE
    // --------------------------------------------------------

    background += centralGlow(uv);

    // --------------------------------------------------------
    // VIGNETTE
    // --------------------------------------------------------

    float vignette =
        1.0 - smoothstep(0.45, 1.35, length(uv));

    background *= 0.45 + 0.55 * vignette;

    // Tonemapping
    background =
        1.0 - exp(-background * 1.6);

    // Gamma
    background =
        pow(background, vec3(0.82));

    fragColor =
        vec4(background, 1.0);
}
