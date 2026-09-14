// ==== Image (image) ====
// ==========================================================
// REFLECTIVE FIREBALL
// ==========================================================
// A high-end volumetric effect featuring a central plasma 
// sphere, a distorted reflective container, and bump-mapped
// specular highlights.
// Credits: Patrick JAILLET
// ==========================================================

#define kB 1.380649

// 1. UTILITY & NOISE FUNCTIONS
// ----------------------------------------------------------

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + p.z * 113.0;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

// Fractional Brownian Motion (FBM)
// Layers multiple octaves of noise to create the "flame" texture.
float fbm(vec3 p, float T) {
    float f = 0.0;
    float amp = 0.5;
    vec3 timeShift = vec3(0.0, 0.0, iTime * kB * T * 0.1);
    vec3 shift = vec3(100.0);
    for (int i = 0; i < 5; i++) {
        f += amp * noise(p - timeShift);
        p = p * 2.0 + shift;
        amp *= 0.5;
    }
    return f;
}

// Maps temperature values to fire colors (Blackbody radiation).
vec3 blackbody(float temp) {
    vec3 col = vec3(255.0, 100.0, 15.0) / 255.0;
    return mix(vec3(0.0), col, temp) + pow(max(temp, 0.0), 3.0) * vec3(1.0, 0.9, 0.5);
}

// 2. VOLUMETRIC MARCHING
// ----------------------------------------------------------
// This function marches through the "fire" to calculate light accumulation.
vec3 marchFireball(vec3 ro, vec3 rd, float T) {
    float density = 0.0;
    vec3 col = vec3(0.0);
    float t = 0.0;
    
    for (int i = 0; i < 75; i++) {
        vec3 p = ro + rd * t;
        float d = length(p) - 1.5;
        float n = fbm(p * 2.0, T);
        d += n * 0.8;
        
        if (d < 0.1) {
            float localDensity = (0.1 - d);
            density += localDensity;
            float heat = n * T * 1.1;
            col += blackbody(heat) * localDensity * 0.5;
        }
        
        t += max(0.04, abs(d) * 0.5);
        if (t > 30.0 || density > 1.5) break; 
    }
    return mix(vec3(0.0), col, smoothstep(0.0, 1.5, density));
}

// 3. BACKGROUND & REFLECTIONS
// ----------------------------------------------------------
// Simulates an outer shell that reflects the central fireball.
vec3 getBackgroundReflection(vec3 ro, vec3 rd, float T) {
    float outerRadius = 12.0;
    vec3 sphereCenter = vec3(2.5, 1.5, 3.0); 
    
    vec3 oc = ro - sphereCenter;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - outerRadius * outerRadius;
    float h = b*b - c;
    
    if (h < 0.0) return vec3(0.0);
    
    float tWall = -b + sqrt(h);
    vec3 posWall = ro + rd * tWall;
    vec3 norWall = normalize(sphereCenter - posWall);
    
    // BUMP MAPPING: Perturb the wall normal with FBM for a "hammered metal" look
    vec3 bumpNoise = vec3(
        fbm(posWall * 1.2, 0.0),
        fbm(posWall * 1.2 + vec3(17.3, 5.2, 8.9), 0.0),
        fbm(posWall * 1.2 + vec3(2.4, 9.1, 13.7), 0.0)
    );
    bumpNoise = bumpNoise * 2.0 - 1.0;
    float bumpStrength = 0.035;
    norWall = normalize(norWall + bumpNoise * bumpStrength);

    // Texture pattern for the wall
    float basePattern = noise(posWall * 0.15) * 0.5 + 0.5;
    vec3 baseColor = vec3(0.03, 0.02, 0.02) * basePattern;
    
    // Fresnel: Makes reflections stronger at grazing angles
    float fresnel = pow(1.0 - max(dot(norWall, -rd), 0.0), 3.0);
    
    // Specular Reflection (Highlights)
    vec3 lightDir = normalize(-posWall);
    vec3 viewDir = -rd;
    vec3 halfVec = normalize(lightDir + viewDir);
    float spec = pow(max(dot(norWall, halfVec), 0.0), 128.0);
    vec3 specColor = blackbody(T * 1.1) * spec * 0.15;
    
    // Ray-traced reflection of the fireball
    vec3 reflectedDir = reflect(rd, norWall);
    vec3 reflectedOrigin = posWall + norWall * 0.1;
    vec3 reflectionColor = marchFireball(reflectedOrigin, reflectedDir, T);
    
    return baseColor + specColor + reflectionColor * mix(0.15, 0.7, fresnel);
}

// 4. MAIN IMAGE RENDER
// ----------------------------------------------------------
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    vec2 q = fragCoord.xy / iResolution.xy; 
    
    vec3 ro = vec3(0.0, 0.0, -4.5);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    // Rotate the camera around the scene
    mat2 rotMat = rot(iTime * 0.15);
    ro.xz *= rotMat;
    rd.xz *= rotMat;

    // Heat intensity pulses over time
    float T = 1.0 + 0.7 * sin(iTime * 0.5); 
    
    float density = 0.0;
    vec3 col = vec3(0.0);
    float t = 0.0;
    
    // PRIMARY MARCH: The Central Fireball
    for (int i = 0; i < 90; i++) {
        vec3 p = ro + rd * t;
        float d = length(p) - 1.5;
        float n = fbm(p * 2.0, T);
        d += n * 0.8;
        
        if (d < 0.1) {
            float localDensity = (0.1 - d);
            density += localDensity;
            float heat = n * T * 1.1;
            col += blackbody(heat) * localDensity * 0.5;
        }
        
        t += max(0.03, abs(d) * 0.4); 
        if (t > 30.0 || density > 1.2) break;
    }
    
    // SECONDARY PASS: Background Reflections
    vec3 bgCol = vec3(0.0);
    if (density < 1.2) {
        bgCol = getBackgroundReflection(ro, rd, T);
    }

    // Blend the fireball with the background
    col = mix(bgCol, col, smoothstep(0.0, 1.2, density));
    
    // POST-PROCESSING: Gamma Correction & Vignette
    col = pow(col, vec3(0.4545)); 
    col *= pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );
    
    fragColor = vec4(col, 1.0);
}
