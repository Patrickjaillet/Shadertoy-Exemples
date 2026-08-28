// ============================================================================
// UNIFORMS & SLIDERS (Contrôles dynamiques auto-détectés par Le Petit Éditeur GLSL)
// ============================================================================

// --- CAMÉRA & ESPACE ---
uniform float u_CamFov;          // Slider: [0.1, 5.0], default: 0.964
uniform float u_CamSpeed;        // Slider: [0.0, 10.0], default: 4.0
uniform float u_RotSpeedX;       // Slider: [-2.0, 2.0], default: 0.8
uniform float u_RotSpeedY;       // Slider: [-2.0, 2.0], default: 0.4
uniform float u_RotAmpX;         // Slider: [0.0, 2.0], default: 0.5848
uniform float u_RotAmpY;         // Slider: [0.0, 2.0], default: 0.2
uniform float u_MouseSens;       // Slider: [0.1, 10.0], default: 2.0

// --- GEOMÉTRIE & RÉFRACTION ---
uniform float u_CylinderRadius;  // Slider: [0.1, 5.0], default: 1.5
uniform float u_RefractThresh;   // Slider: [0.0, 0.5], default: 0.05
uniform float u_RefractIndex;    // Slider: [0.1, 2.0], default: 0.85

// --- DOMAIN WARPING & DEFORMATIONS ---
uniform float u_TwistStrength;   // Slider: [-2.0, 2.0], default: 0.0
uniform float u_BendStrength;    // Slider: [-2.0, 2.0], default: 0.0
uniform float u_LogPolarScale;   // Slider: [0.1, 5.0], default: 1.0
uniform float u_LogPolarSwirl;   // Slider: [-5.0, 5.0], default: 0.0
uniform float u_KaleidoSectors;  // Slider: [1.0, 16.0], default: 6.0

// --- ONDULATION & ÉNERGIE ---
uniform float u_WaveZScale;      // Slider: [0.0, 2.0], default: 0.5
uniform float u_WaveSpeed;       // Slider: [0.0, 5.0], default: 2.0
uniform float u_WaveSinAmp;      // Slider: [0.0, 2.0], default: 0.75
uniform float u_WaveSinFreq;     // Slider: [0.1, 5.0], default: 1.5
uniform float u_InterferenceFreq;// Slider: [1.0, 30.0], default: 15.0
uniform float u_WaveEnergyMult;  // Slider: [0.0001, 0.05], default: 0.008

// --- RENDU & FOG ---
uniform float u_MaxSteps;        // Slider: [10.0, 120.0], default: 60.0
uniform float u_StepPull;        // Slider: [0.001, 0.1], default: 0.01
uniform float u_FogAttenuation;  // Slider: [0.0, 0.5], default: 0.1

// --- ÉCLAIRAGE, OMBRES & AO ---
uniform float u_UseLighting;     // Slider: [0.0, 1.0], default: 0.0
uniform float u_SpecPower;       // Slider: [1.0, 128.0], default: 32.0
uniform float u_UseSoftShadows;  // Slider: [0.0, 1.0], default: 0.0
uniform float u_ShadowK;         // Slider: [1.0, 64.0], default: 16.0
uniform float u_UseAO;           // Slider: [0.0, 1.0], default: 0.0
uniform float u_AOIntensity;     // Slider: [0.0, 3.0], default: 1.5

// --- COULEURS & MATÉRIAUX ---
uniform float u_ColorMode;       // Slider: [0.0, 4.0], default: 0.0
uniform float u_PaletteFreq;     // Slider: [0.1, 5.0], default: 1.0
uniform float u_PaletteSpeed;    // Slider: [0.0, 2.0], default: 0.1

// --- POST-PROCESSING FX ---
uniform float u_Contrast;        // Slider: [0.1, 3.0], default: 1.0
uniform float u_Saturation;      // Slider: [0.0, 3.0], default: 1.0
uniform float u_Gamma;           // Slider: [0.1, 3.0], default: 1.0
uniform float u_Vignette;        // Slider: [0.0, 1.0], default: 0.0
uniform float u_Aberration;      // Slider: [0.0, 0.02], default: 0.0
uniform float u_BloomStrength;   // Slider: [0.0, 2.0], default: 0.0

// --- SHADERTOY / ONGLET PASS INPUTS ---
uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;

// ============================================================================
// MACROS DE CONFIGURATION OPTIONNELLES
// ============================================================================
#define USE_DOMAIN_TWIST 0
#define USE_DOMAIN_BEND 0
#define USE_KALEIDOSCOPE 0
#define USE_KALEIDO_3D_ICOSAHEDRAL 0
#define USE_KALEIDO_3D_OCTAHEDRAL 0
#define USE_KALEIDO_3D_TETRAHEDRAL 0
#define USE_LOG_POLAR 0
#define LOG_POLAR_PLANE_SELECT 0
#define USE_FOLDING 0
#define USE_BOX_FOLD 0
#define USE_SPHERE_FOLD 0
#define USE_OCTAHEDRAL_FOLD 0
#define USE_DODECAHEDRAL_FOLD 0
#define USE_MENGER_FOLD 0

#define FOLD_PLANE_NORMAL vec3(0.7071, 0.7071, 0.0)
#define FOLD_DISTANCE 0.0
#define FOLD_ITERATIONS 1
#define BOX_FOLD_LIMIT 1.0
#define BOX_FOLD_VALUE 2.0
#define SPHERE_FOLD_MIN_RAD 0.5
#define SPHERE_FOLD_MAX_RAD 1.0
#define FOLD_SCALE_FACTOR 1.0
#define FOLD_TRANSLATION vec3(0.0, 0.0, 0.0)

#define LIGHT_DIR normalize(vec3(1.0, 2.0, -2.0))
#define LIGHT_COLOR vec3(1.0, 0.95, 0.85)
#define AMBIENT_COLOR vec3(0.05, 0.08, 0.15)
#define NORMAL_EPSILON 0.001

#define PALETTE_A vec3(0.5, 0.5, 0.5)
#define PALETTE_B vec3(0.5, 0.5, 0.5)
#define PALETTE_C vec3(1.0, 1.0, 1.0)
#define PALETTE_D vec3(0.0, 0.33, 0.67)

#define DEPTH_COLOR_NEAR vec3(1.0, 0.8, 0.3)
#define DEPTH_COLOR_FAR vec3(0.0, 0.2, 0.8)
#define DEPTH_RANGE vec2(0.5, 4.0)

#define ORBIT_COLOR_1 vec3(0.1, 0.8, 0.6)
#define ORBIT_COLOR_2 vec3(0.9, 0.1, 0.4)
#define ORBIT_POWER 2.0

mat2 rot2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

vec3 palette(float t) {
    return PALETTE_A + PALETTE_B * cos(6.28318530718 * (PALETTE_C * (t * u_PaletteFreq + iTime * u_PaletteSpeed) + PALETTE_D));
}

vec3 applyDomainWarping(vec3 p) {
    #if USE_DOMAIN_TWIST
        if (u_TwistStrength != 0.0) {
            float cT = cos(u_TwistStrength * p.y);
            float sT = sin(u_TwistStrength * p.y);
            p.xz = mat2(cT, -sT, sT, cT) * p.xz;
        }
    #endif

    #if USE_DOMAIN_BEND
        if (u_BendStrength != 0.0) {
            float cB = cos(u_BendStrength * p.x);
            float sB = sin(u_BendStrength * p.x);
            p.xy = mat2(cB, -sB, sB, cB) * p.xy;
        }
    #endif

    #if USE_KALEIDOSCOPE
        vec2 plane = p.xz;
        float angle = 6.28318530718 / u_KaleidoSectors;
        float a = atan(plane.y, plane.x);
        float r = length(plane);
        a = mod(a, angle) - angle * 0.5;
        p.xz = vec2(cos(a), sin(a)) * r;
    #endif

    #if USE_KALEIDO_3D_TETRAHEDRAL
        p.xy = p.x < -p.y ? -p.yx : p.xy;
        p.xz = p.x < -p.z ? -p.zx : p.xz;
        p.yz = p.y < -p.z ? -p.zy : p.yz;
    #endif

    #if USE_KALEIDO_3D_OCTAHEDRAL
        p = abs(p);
        p.xy = p.x < p.y ? p.yx : p.xy;
        p.xz = p.x < p.z ? p.zx : p.xz;
        p.yz = p.y < p.z ? p.zy : p.yz;
    #endif

    #if USE_KALEIDO_3D_ICOSAHEDRAL
        p = abs(p);
        vec3 n1 = vec3(-0.5, 0.8660254, 0.0);
        vec3 n2 = vec3(0.8660254, -0.5, 0.0);
        vec3 n3 = vec3(0.0, -0.5, 0.8660254);
        p -= 2.0 * min(0.0, dot(p, n1)) * n1;
        p -= 2.0 * min(0.0, dot(p, n2)) * n2;
        p -= 2.0 * min(0.0, dot(p, n3)) * n3;
    #endif

    #if USE_LOG_POLAR
        vec2 lpPlane = p.xz;
        float rLog = length(lpPlane);
        float aLog = atan(lpPlane.y, lpPlane.x);
        float rMapped = log(rLog + 0.0001) * u_LogPolarScale;
        float aMapped = (aLog + rLog * u_LogPolarSwirl) * u_LogPolarScale;
        p.xz = vec2(rMapped, aMapped);
    #endif

    for (int i = 0; i < FOLD_ITERATIONS; i++) {
        #if USE_BOX_FOLD
            p = clamp(p, -BOX_FOLD_LIMIT, BOX_FOLD_LIMIT) * BOX_FOLD_VALUE - p;
        #endif

        #if USE_SPHERE_FOLD
            float r2 = dot(p, p);
            if (r2 < SPHERE_FOLD_MIN_RAD) {
                p *= SPHERE_FOLD_MAX_RAD / SPHERE_FOLD_MIN_RAD;
            } else if (r2 < SPHERE_FOLD_MAX_RAD) {
                p *= SPHERE_FOLD_MAX_RAD / r2;
            }
        #endif

        #if USE_FOLDING
            vec3 foldNorm = normalize(FOLD_PLANE_NORMAL);
            p -= 2.0 * min(0.0, dot(p, foldNorm) - FOLD_DISTANCE) * foldNorm;
        #endif

        #if USE_OCTAHEDRAL_FOLD
            p = abs(p);
            if (p.x < p.y) p.xy = p.yx;
            if (p.x < p.z) p.xz = p.zx;
            if (p.y < p.z) p.yz = p.zy;
        #endif

        #if USE_DODECAHEDRAL_FOLD
            vec3 d1 = vec3(0.30901699, 0.5, 0.80901699);
            vec3 d2 = vec3(0.80901699, 0.30901699, 0.5);
            p -= 2.0 * min(0.0, dot(p, d1)) * d1;
            p -= 2.0 * min(0.0, dot(p, d2)) * d2;
        #endif

        #if USE_MENGER_FOLD
            p = abs(p);
            if (p.x - p.y < 0.0) p.xy = p.yx;
            if (p.x - p.z < 0.0) p.xz = p.zx;
            if (p.y - p.z < 0.0) p.yz = p.zy;
            p.z -= 0.5 * (1.0 - 1.0 / 3.0);
            p.z = -abs(p.z);
            p.z += 0.5 * (1.0 - 1.0 / 3.0);
        #endif

        p = p * FOLD_SCALE_FACTOR + FOLD_TRANSLATION;
    }

    return p;
}

float mapSimple(vec3 p) {
    p = applyDomainWarping(p);
    float r = max(length(p.xy), 0.001);
    return u_CylinderRadius - r;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(NORMAL_EPSILON, 0.0);
    return normalize(vec3(
        mapSimple(p + e.xyy) - mapSimple(p - e.xyy),
        mapSimple(p + e.yxy) - mapSimple(p - e.yxy),
        mapSimple(p + e.yyx) - mapSimple(p - e.yyx)
    ));
}

float calcSoftShadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 24; i++) {
        float h = mapSimple(ro + rd * t);
        if (h < 0.001) return 0.0;
        res = min(res, u_ShadowK * h / t);
        t += clamp(h, 0.02, 0.2);
        if (t > 2.5) break;
    }
    return clamp(res, 0.0, 1.0);
}

float calcAO(vec3 p, vec3 N) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.05 * float(i + 1);
        float d = mapSimple(p + N * h);
        occ += (h - d) * sca;
        sca *= 0.75;
    }
    return clamp(1.0 - u_AOIntensity * occ, 0.0, 1.0);
}

vec3 computeLighting(vec3 p, vec3 N, vec3 V, vec3 baseColor) {
    vec3 L = normalize(LIGHT_DIR);
    vec3 H = normalize(L + V);
    
    float shadow = 1.0;
    if (u_UseSoftShadows > 0.5) {
        shadow = calcSoftShadow(p + N * 0.005, L);
    }
    
    float ao = 1.0;
    if (u_UseAO > 0.5) {
        ao = calcAO(p, N);
    }
    
    float diff = max(dot(N, L), 0.0);
    float spec = pow(max(dot(N, H), 0.0), u_SpecPower);
    vec3 diffuse = diff * shadow * LIGHT_COLOR * baseColor;
    vec3 specular = spec * shadow * LIGHT_COLOR;
    vec3 ambient = AMBIENT_COLOR * baseColor * ao;
    return ambient + diffuse + specular;
}

vec3 computeMaterialColor(vec3 p, vec2 u, float f, float dist) {
    if (u_ColorMode >= 0.9 && u_ColorMode < 1.9) {
        return palette(f);
    } else if (u_ColorMode >= 1.9 && u_ColorMode < 2.9) {
        vec3 N = calcNormal(p);
        return N * 0.5 + 0.5;
    } else if (u_ColorMode >= 2.9 && u_ColorMode < 3.9) {
        float t = clamp((dist - DEPTH_RANGE.x) / (DEPTH_RANGE.y - DEPTH_RANGE.x), 0.0, 1.0);
        return mix(DEPTH_COLOR_NEAR, DEPTH_COLOR_FAR, t);
    } else if (u_ColorMode >= 3.9) {
        float trap = pow(abs(f), ORBIT_POWER);
        return mix(ORBIT_COLOR_1, ORBIT_COLOR_2, clamp(trap, 0.0, 1.0));
    }
    return 0.5 + 0.5 * cos(vec3(0.0, 2.0, 4.0) + u.y * 2.0 + p.z * 0.2 + iTime);
}

vec4 march(vec2 u, vec2 r, float t, vec2 m) {
    vec4 o = vec4(0.0);
    vec3 c = vec3(0.0, 0.0, t * u_CamSpeed);
    vec3 rd = normalize(vec3((u + u - r.xy) / r.y, u_CamFov));
    
    mat2 rotX = rot2D(m.y);
    mat2 rotY = rot2D(m.x);
    rd.xz *= rotY;
    rd.xy *= rotX;

    vec3 dVec = rd;
    float distAccum = 0.0;
    float i = 0.0;
    float s = 0.0;

    for (o *= 0.0; i++ < u_MaxSteps; distAccum += max(s, u_StepPull)) {
        vec3 p = c + distAccum * dVec;
        vec3 pWarped = applyDomainWarping(p);
        
        float rCyl = max(length(pWarped.xy), 0.001);
        s = u_CylinderRadius - rCyl;

        if (s < u_RefractThresh) {
            vec3 refractedRd = refract(dVec, vec3(-pWarped.xy / rCyl, 0.0), u_RefractIndex);
            if (length(refractedRd) > 0.0) dVec = refractedRd;
        }

        vec2 uvPattern = vec2(
            asin(clamp(sin((log(rCyl) + (pWarped.z - c.z) * u_WaveZScale - t * u_WaveSpeed) * u_WaveSinFreq) * u_WaveSinAmp, -0.99, 0.99)),
            atan(pWarped.y, pWarped.x)
        );

        float f = sin(u_InterferenceFreq * length(uvPattern - vec2(0.2, 0.0)) - t * 4.0) +
                  sin(u_InterferenceFreq * length(uvPattern + vec2(0.2, 0.0)) + t * 3.0);

        vec3 baseCol = computeMaterialColor(pWarped, uvPattern, f, distAccum);
        
        if (u_UseLighting > 0.5) {
            vec3 N = calcNormal(pWarped);
            baseCol = computeLighting(pWarped, N, -dVec, baseCol);
        }

        o.rgb += baseCol * (f * f * u_WaveEnergyMult) * exp(-distAccum * u_FogAttenuation);
    }

    return clamp(o, 0.0, 1.0);
}

vec3 applyPostFX(vec3 col, vec2 u, vec2 r) {
    col = mix(vec3(dot(col, vec3(0.2126, 0.7152, 0.0722))), col, u_Saturation);
    col = (col - 0.5) * u_Contrast + 0.5;
    col = pow(max(col, 0.0), vec3(1.0 / u_Gamma));
    
    if (u_Vignette > 0.0) {
        vec2 q = u / r;
        float vig = pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.25);
        col *= mix(1.0, vig, u_Vignette);
    }
    
    return clamp(col, 0.0, 1.0);
}

void mainImage(out vec4 o, vec2 u) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec2 m = iMouse.z > 0.0 ? (iMouse.xy - r * 0.5) / r.y * u_MouseSens 
                            : vec2(sin(t * u_RotSpeedX) * u_RotAmpX, sin(t * u_RotSpeedY) * u_RotAmpY);

    if (u_Aberration > 0.0) {
        float ca = u_Aberration * r.x;
        vec4 colR = march(u + vec2(ca, 0.0), r, t, m);
        vec4 colG = march(u, r, t, m);
        vec4 colB = march(u - vec2(ca, 0.0), r, t, m);
        o = vec4(colR.r, colG.g, colB.b, colG.a);
    } else {
        o = march(u, r, t, m);
    }

    if (u_BloomStrength > 0.0) {
        vec4 blur = (march(u + vec2(2.0, 0.0), r, t, m) + 
                     march(u - vec2(2.0, 0.0), r, t, m) + 
                     march(u + vec2(0.0, 2.0), r, t, m) + 
                     march(u - vec2(0.0, 2.0), r, t, m)) * 0.25;
        o += blur * u_BloomStrength;
    }

    o.rgb = applyPostFX(o.rgb, u, r);
}