// ==== Image (image) ====
// ==========================================================
// NAME : HYPER-RECURSIVE MONOLITH
// ==========================================================
// This shader explores an "extreme" non-Euclidean fractal structure through
// spatial folding and infinite recursion. It uses a Raymarching engine
// coupled with a KIFS (Kleinian Iterated Function System) distance
// estimator. The visual style is focused on monochromatic depth,
// complex shadows, and organic complexity rather than bright colors.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MAX_STEPS 100
#define MAX_DIST 20.0
#define SURF_DIST 0.001

// Standard 2D rotation
mat2 Rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

// Helper for smooth multicolor transitions (Cosine palette)
vec3 Palette(float t) {
// An organic, mineral palette: Golds, deep blues, and earthy greens
vec3 a = vec3(0.5, 0.5, 0.5);
vec3 b = vec3(0.5, 0.5, 0.5);
vec3 c = vec3(1.0, 1.0, 0.7);
vec3 d = vec3(0.0, 0.15, 0.20);
return a + b * cos(6.28318 * (c * t + d));
}

// Global variable to store the color trap data
float gTrap = 0.0;

// The fractal distance function (KIFS)
float GetDist(vec3 p) {
float scale = 1.35;
p.xy *= Rot(iTime * 0.1);
p.yz *= Rot(iTime * 0.15);

vec3 p_orig = p;
float d = 100.0;
float trap = 0.0;

// The "Extreme" folding loop
for(int i = 0; i < 12; i++) {
    p = abs(p) - vec3(0.5, 0.8, 0.4); 
    p.xy *= Rot(0.785); 
    p *= scale;
    
    // Orbit Trap: Accumulate position data for coloring
    trap += exp(-length(p) * 0.1);
    
    float sphere = length(p) - 1.2;
    d = min(d, sphere / pow(scale, float(i)));
}

gTrap = trap * 0.15; // Store normalized trap value
return d;
}

// Raymarching engine
float RayMarch(vec3 ro, vec3 rd) {
float dO = 0.0;
for(int i = 0; i < MAX_STEPS; i++) {
vec3 p = ro + rd * dO;
float dS = GetDist(p);
dO += dS;
if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
}
return dO;
}

// Normal calculation
vec3 GetNormal(vec3 p) {
float d = GetDist(p);
vec2 e = vec2(0.01, 0);
vec3 n = d - vec3(
GetDist(p - e.xyy),
GetDist(p - e.yxy),
GetDist(p - e.yyx));
return normalize(n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
vec3 col = vec3(0);

// Camera
vec3 ro = vec3(0, 0, -4.0);
vec3 rd = normalize(vec3(uv.x, uv.y, 1.2));

// Render
float d = RayMarch(ro, rd);

if(d < MAX_DIST) {
    vec3 p = ro + rd * d;
    vec3 n = GetNormal(p);
    vec3 r = reflect(rd, n);
    
    // Retrieve the trap value calculated during RayMarch
    float colorData = gTrap;

    // Lighting
    vec3 lightPos = vec3(2, 5, -5);
    vec3 l = normalize(lightPos - p);
    float diff = dot(n, l) * 0.5 + 0.5;
    float spec = pow(max(dot(r, l), 0.0), 32.0);
    
    // Combine Orbit Trap with the palette
    vec3 baseCol = Palette(colorData + length(p) * 0.1);
    
    col = baseCol * diff;
    col += spec * 0.3 * baseCol; // Specular highlights tinted by base color
    
    // Ambient Occlusion (fake)
    float ao = 1.0 / (1.0 + d * 0.15);
    col *= ao;
    
    // Distance fog
    col = mix(col, vec3(0.02, 0.04, 0.06), 1.0 - exp(-0.15 * d));
} else {
    // Background Gradient
    col = vec3(0.01, 0.01, 0.03) + 0.05 * vec3(uv.y);
}

// Post-processing
col = pow(col, vec3(0.4545)); // Gamma correction
col *= 1.2; // Slight exposure boost

fragColor = vec4(col, 1.0);
}
