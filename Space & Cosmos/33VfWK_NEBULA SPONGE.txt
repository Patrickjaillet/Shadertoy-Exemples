// ==== Image (image) ====
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MENGER_ITER 4 // Réduit pour l'optimisation avec le blur
#define MAX_STEPS 80  // Réduit pour l'optimisation
#define SURF_DIST 0.002

// Paramètres du Motion Blur 
#define MOTION_BLUR_SAMPLES 2 // Nombre d'échantillons temporels
#define SHUTTER_SPEED 0.04    // Durée de l'exposition (0.0 à 1.0)

// Matrice de rotation
mat2 Rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

// Fonctions de bruit pour la fumée
float Hash21(vec2 p) {
p = fract(p * vec2(123.34, 456.21));
p += dot(p, p + 45.32);
return fract(p.x * p.y);
}

float Noise(vec2 p) {
vec2 i = floor(p);
vec2 f = fract(p);
f = f * f * (3.0 - 2.0 * f);
float a = Hash21(i);
float b = Hash21(i + vec2(1.0, 0.0));
float c = Hash21(i + vec2(0.0, 1.0));
float d = Hash21(i + vec2(1.0, 1.0));
return mix(a, b, f.x) + (c - a) * f.y * (1.0 - f.x) + (d - b) * f.x * f.y;
}

// Fractional Brownian Motion (FBM)
float FBM(vec2 p) {
float v = 0.0;
float a = 0.5;
for (int i = 0; i < 5; i++) {
v += a * Noise(p);
p *= 2.0;
a *= 0.5;
}
return v;
}

// Background : Fumée Cosmique Tourbillonnante (Vortex Nebula)
vec3 GetVortexNebula(vec3 rd, float time) {
vec3 col = vec3(0);
// Coordonnées de base
vec2 uv = vec2(atan(rd.z, rd.x), acos(rd.y));

// Création du tourbillon (Vortex)
float angle = length(uv) * 2.0 - time * 0.1;
uv *= Rot(angle); // Applique la rotation dépendante de la distance

// Bruit fractal déformé (Warped FBM) pour l'effet de fumée
vec2 p = uv * 2.0;
vec2 q = vec2(FBM(p + time * 0.05), FBM(p + vec2(1.0)));
vec2 r = vec2(FBM(p + q + time * 0.02), FBM(p + q + vec2(2.4)));
float smoke = FBM(p + r);

// Couleurs de fumée cosmique (Violet Profond, Vert Émeraude, Or)
vec3 col1 = vec3(0.1, 0.0, 0.2); // Profondeur violette
vec3 col2 = vec3(0.0, 0.3, 0.2); // Volutes vertes
vec3 col3 = vec3(0.5, 0.4, 0.1); // Éclats dorés

// Mixage des couleurs basé sur les différentes couches de fumée
col = mix(col1, col2, smoke);
col = mix(col, col3, length(q) * 0.3); // Ajout d'éclats basés sur la déformation q

// Intensité et contraste
col = pow(col, vec3(1.2)); // Augmente le contraste
col *= 1.5; // Brillance globale

// Ajout d'étoiles lointaines qui suivent le tourbillon
float stars = pow(Hash21(floor(uv * 40.0)), 25.0);
col += stars * (sin(time * 2.0 + stars * 100.0) * 0.5 + 0.5) * col2; // Étoiles teintées

return col;
}

// Coloration spectrale
vec3 getSpectralColor(vec3 p) {
float d = length(p) * 0.5;
return 0.5 + 0.5 * cos(6.28318 * (d + vec3(0.0, 0.33, 0.67)));
}

// SDF Menger Sponge Morphing
float sdMenger(vec3 p, vec3 b, float morph) {
vec3 q = abs(p) - b;
float d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
float s = 1.0;
for (int i = 0; i < MENGER_ITER; i++) {
vec3 a = mod(p * s, 2.0) - 1.0;
s *= 3.0;
vec3 r = abs(1.0 - 3.0 * abs(a));
float da = max(r.x, r.y), db = max(r.y, r.z), dc = max(r.z, r.x);
float c_cross = (min(da, min(db, dc)) - 1.0) / s;
float c_sphere = (length(r) - 1.25) / s;
d = max(d, mix(c_cross, c_sphere, morph));
}
return d;
}

// Distance Function (inclut le temps pour le calcul du flou)
float GetDist(vec3 p, float time) {
// 1. Morphing factor (accéléré pour voir le blur)
float morph = sin(time * 2.0) * 0.5 + 0.5;

// 2. Contrôles
float sliderX = iMouse.z > 0.0 ? (iMouse.x / iResolution.x - 0.5) * 5.0 : 0.0;
float sliderY = iMouse.z > 0.0 ? (iMouse.y / iResolution.y - 0.5) * 3.0 : 0.0;
float scale = 1.0 + sin(time * 0.5) * 0.3;

p -= vec3(sliderX, sliderY, 0.0);
p /= scale;

// Rotation RAPIDE (nécessaire pour le motion blur)
p.xz *= Rot(time * 2.5); // Rotation xz beaucoup plus rapide
p.xy *= Rot(time * 1.5); // Rotation xy rapide

return sdMenger(p, vec3(1.0), morph) * scale;
}

float RayMarch(vec3 ro, vec3 rd, float time) {
float dO = 0.0;
for (int i = 0; i < MAX_STEPS; i++) {
float dS = GetDist(ro + rd * dO, time);
dO += dS;
if (dO > 20.0 || dS < SURF_DIST) break;
}
return dO;
}

vec3 GetNormal(vec3 p, float time) {
float d = GetDist(p, time);
vec2 e = vec2(0.001, 0);
vec3 n = d - vec3(GetDist(p-e.xyy, time), GetDist(p-e.yxy, time), GetDist(p-e.yyx, time));
return normalize(n);
}

// Calcule la couleur pour un instant T donné (utilisé par le blur)
vec3 RenderScene(vec3 ro, vec3 rd, float time) {
float d = RayMarch(ro, rd, time);
vec3 col;

if (d < 20.0) {
    vec3 p = ro + rd * d;
    vec3 n = GetNormal(p, time);
    vec3 lightPos = vec3(2, 3, -5);
    vec3 l = normalize(lightPos - p);
    
    float diff = clamp(dot(n, l), 0.1, 1.0);
    float rim = pow(1.0 - max(dot(n, -rd), 0.0), 4.0);
    
    col = mix(vec3(0.4), getSpectralColor(p), 0.5) * diff;
    col += rim * 0.4; // Rim light
} else {
    col = GetVortexNebula(rd, time);
}
return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
vec3 ro = vec3(0, 0, -4.5);
vec3 rd = normalize(vec3(uv, 1.5));

vec3 accCol = vec3(0); // Accumulateur de couleur pour le blur

// Boucle d'échantillonnage temporelle pour le Motion Blur
float shutterDistArr = SHUTTER_SPEED / float(MOTION_BLUR_SAMPLES);

for (int i = 0; i < MOTION_BLUR_SAMPLES; i++) {
    // Calcule un décalage temporel aléatoire pour chaque échantillon (Jitter)
    float jitter = Hash21(uv + iTime + float(i)) * shutterDistArr;
    float sampleTime = iTime - SHUTTER_SPEED * 0.5 + float(i) * shutterDistArr + jitter;
    
    // Rend la scène à cet instant précis
    accCol += RenderScene(ro, rd, sampleTime);
}

// Moyenne des échantillons
vec3 col = accCol / float(MOTION_BLUR_SAMPLES);

// Post-processing
col = pow(col, vec3(0.4545)); // Correction Gamma

fragColor = vec4(col, 1.0);
}
