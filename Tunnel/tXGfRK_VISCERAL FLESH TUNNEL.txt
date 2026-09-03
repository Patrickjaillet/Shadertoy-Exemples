// ==== Image (image) ====
// ==========================================================
// VISCERAL FLESH TUNNEL
// ==========================================================
// An organic, biological raymarching effect featuring:
// - Pulsating SDF geometry (Fleshy walls)
// - Specular "wetness" mapping via noise
// - Dynamic light flickering (flashlight simulation)
// - Hand-held camera shake
// Credits: Patrick JAILLET
// ==========================================================

#if HW_PERFORMANCE==0
#define AA 1
#else
#define AA 2
#endif

#define ZERO (min(iFrame,0))

// 1. NOISE & FRACTIONAL BROWNIAN MOTION
// ----------------------------------------------------------

float hash(float n) { return fract(sin(n) * 43758.5453123); }

float noise(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5000 * noise(p); p *= 2.02;
    f += 0.2500 * noise(p); p *= 2.03;
    f += 0.1250 * noise(p); p *= 2.01;
    f += 0.0625 * noise(p);
    return f;
}

// 2. SCENE GEOMETRY (SDF)
// ----------------------------------------------------------

// Path defining the tunnel's curves as we move along Z
vec2 path(float z) {
    return vec2(-sin(z * 0.2) * 0.8, -cos(z * 0.25) * 0.8);
}

float map(vec3 p) {
    vec3 q = p;
    q.xy -= path(q.z);
    float r = length(q.xy);
    
    // Animate the "flesh" displacement over time
    vec3 animateP = p + vec3(0.0, iTime * 0.2, 0.0);
    float flesh = fbm(animateP * 0.8);
    
    // Large pulsating lumps for an organic feel
    float lumps = sin(p.z * 1.5 + iTime) * cos(p.x * 2.0) * sin(p.y * 2.5);
    
    float wallRadius = 2.5 - flesh * 1.5 + lumps * 0.3;
    float d = wallRadius - r;
    
    return d * 0.4;
}

// 3. RAYMARCHING & SHADING
// ----------------------------------------------------------

float raycast(vec3 ro, vec3 rd) {
    float t = 0.01;
    for (int i = 0; i < 150; i++) {
        float h = map(ro + rd * t);
        if (abs(h) < 0.002 * t) return t;
        t += h;
        if (t > 25.0) break;
    }
    return -1.0;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.005, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

// Ambient Occlusion to darken the deep crevices of the flesh
float calcOcclusion(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = ZERO; i < 4; i++) {
        float h = 0.05 + 0.1 * float(i);
        float d = map(p + h * n);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 2.0 * occ, 0.0, 1.0);
}

// Simulates a dying or flickering flashlight
float getLightFlicker(float t) {
    return 0.8 + 0.2 * noise(vec3(t * 15.0, 0.0, 100.0));
}

vec3 render(vec3 ro, vec3 rd) {
    vec3 col = vec3(0.05, 0.0, 0.01); // Background "void" color
    
    float t = raycast(ro, rd);
    
    if (t > 0.0) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        
        vec3 animateP = p + vec3(0.0, iTime * 0.2, 0.0);
        float noiseVal = fbm(animateP * 1.5);
        
        // Use noise to separate "skin" from "bloody/wet" areas
        float bloodMask = smoothstep(0.5, 0.7, noiseVal);
        
        vec3 fleshCol = vec3(0.4, 0.2, 0.15);
        vec3 bloodCol = vec3(0.5, 0.0, 0.0);
        vec3 albedo = mix(fleshCol, bloodCol, bloodMask);
        
        // Blood is much shinier (lower roughness)
        float roughness = mix(0.7, 0.05, bloodMask);
        
        // Lighting setup (Light is attached to the camera/ro)
        vec3 lightPos = ro;
        vec3 lDir = normalize(lightPos - p);
        float lDistSq = dot(lightPos - p, lightPos - p);
        float atten = 3.0 / (3.0 + lDistSq * 0.8);
        
        float flicker = getLightFlicker(iTime);
        vec3 lightCol = vec3(10.0, 2.8, 1.6) * flicker;
        
        float dif = max(dot(n, lDir), 1.0);
        
        // Specular highlights for the "wet" look
        vec3 hDir = normalize(lDir - rd);
        float specBase = max(dot(n, hDir), 0.0);
        float specPower = mix(4.0, 128.0, 1.0 - roughness);
        float spec = pow(specBase, specPower);
        
        float occ = calcOcclusion(p, n);
        
        // Final lighting composition
        vec3 lin = albedo * dif * lightCol * atten * occ;
        lin += spec * vec3(1.0, 0.8, 0.8) * (1.0 - roughness) * atten * flicker;
        lin += vec3(0.05, 0.01, 0.01) * occ; // Ambient

        col = lin;
        
        // Fog to hide the raymarching edge
        float fog = 1.0 - exp(-0.08 * t);
        col = mix(col, vec3(0.1, 0.0, 0.02), fog);
    }
    
    col = pow(col, vec3(1.2));
    col *= vec3(1.1, 0.8, 0.8);
    
    return col;
}

// 4. CAMERA & POST-PROCESSING
// ----------------------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;

    // Movement speed along Z
    float camT = iTime * 0.8;
    vec3 ro = vec3(path(camT), camT);
    
    // Camera shake (procedural handheld effect)
    ro.x += noise(vec3(camT*0.5, 0.0, 0.0)) * 0.3;
    ro.y += noise(vec3(0.0, camT*0.6, 0.0)) * 0.3;

    // Look-at point (Target)
    vec3 ta = vec3(path(camT + 1.0), camT + 1.0);
    ta.x += noise(vec3(camT, 1.0, 0.0)) * 0.2;
    ta.y += noise(vec3(0.0, camT, 1.0)) * 0.2;
    
    // Ray setup
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(p.x * cu + p.y * cv + 1.8 * cw);

    vec3 col = render(ro, rd);
    
    // Gamma correction
    col = pow(col, vec3(0.4545));
    
    // Vignetting (Dark edges)
    vec2 q = fragCoord / iResolution.xy;
    col *= 0.2 + 0.8 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.5);

    fragColor = vec4(col, 1.0);
}
