// ==== Image (image) ====
// ==========================================================
// NAME : QUANTUM GEOMETRY TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through infinite 3D 
// gates. Features domain repetition, FBM-based displacement 
// mapping, volumetric glow for moving particles, and a 
// temporal feedback loop for persistence.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Standard UV coordinates (0.0 to 1.0)
    vec2 uv = fragCoord / iResolution.xy;
    
    // 1. RAW COLOR FETCH
    // Sample the base scene from the main buffer.
    vec3 col = texture(iChannel0, uv).rgb;
    
    // 2. INTEGRATED BLOOM PASS
    // This nested loop performs a 7x7 Gaussian blur kernel.
    vec3 blur = vec3(0.0);
    float total = 0.0;
    
    for (float x = -3.0; x <= 3.0; x++) {
        for (float y = -3.0; y <= 3.0; y++) {
            // Calculate the sampling offset in pixel-space.
            vec2 off = vec2(x, y) * 2.0 / iResolution.xy;
            
            // Weighting: Gaussian distribution (Bell curve).
            // 
            float w = exp(-(x * x + y * y) / 4.0);
            
            // Brightness Isolation (Thresholding):
            // We only blur colors that exceed a brightness of 0.5.
            vec3 s = texture(iChannel0, uv + off).rgb;
            blur += max(vec3(0.0), s - 0.5) * w;
            total += w;
        }
    }
    
    // Normalize the blurred result and add it back to the original image.
    blur /= total;
    col += blur * 1.5;
    
    // 3. COLOR GRADING & TONEMAPPING
    
    // Reinhard Tonemapping: Maps HDR values (infinite) to LDR (0-1).
    // This prevents bright spots from "clipping" into flat white blocks.
    // 
    col = col / (col + vec3(1.0));
    
    // Gamma Correction (Linear to sRGB).
    col = pow(col, vec3(0.4545));
    
    // Contrast boost using smoothstep.
    col = smoothstep(-0.1, 1.1, col);
    
    // Stylized Color Tint: Slightly boosting Reds and Blues for a "Cool/Warm" balance.
    col *= vec3(1.05, 1.0, 1.1);
    
    // 4. VIGNETTING
    // Darkens the corners to focus attention on the center of the frame.
    float vign = pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.15);
    col *= vign;
    
    // Output final color
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// ==========================================================
// NAME : QUANTUM GEOMETRY TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through infinite 3D 
// gates. Features domain repetition, FBM-based displacement 
// mapping, volumetric glow for moving particles, and a 
// temporal feedback loop for persistence.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Math & Noise Utilities ---

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

// 3D Value Noise: Generates smooth procedural textures
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(mix(mix(fract(sin(n + 0.0) * 43758.5453), fract(sin(n + 1.0) * 43758.5453), f.x),
                   mix(fract(sin(n + 157.0) * 43758.5453), fract(sin(n + 158.0) * 43758.5453), f.x), f.y),
               mix(mix(fract(sin(n + 113.0) * 43758.5453), fract(sin(n + 114.0) * 43758.5453), f.x),
                   mix(fract(sin(n + 270.0) * 43758.5453), fract(sin(n + 271.0) * 43758.5453), f.x), f.y), f.z);
}

// Fractal Brownian Motion: Layers noise to create "natural" looking detail
float fbm(vec3 p) {
    float f = 0.0, w = 0.5;
    for (int i = 0; i < 5; i++) {
        f += w * noise(p);
        p *= 2.0;
        w *= 0.5;
    }
    return f;
}

// --- Signed Distance Functions (SDF) ---

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// Scene Mapping: Combines domain repetition with space twisting
float map(vec3 p) {
    float spacing = 8.0;
    // Domain Repetition: Creates the infinite series of gates along Z
    float id = floor((p.z + spacing * 0.5) / spacing);
    p.z = mod(p.z + spacing * 0.5, spacing) - spacing * 0.5;
    
    // Twist each gate relative to its ID
    p.xy *= rot(iTime * 0.2 + id);
    
    // Create a square gate with a hollow center
    float box = sdBox(p, vec3(3.0, 3.0, 0.5));
    float hole = length(p.xy) - 2.2;
    
    // FBM-based Displacement: Adds organic "glowing" detail to the surfaces
    float disp = fbm(p * 2.0 + vec3(iTime, iTime * 0.5, 0.0)) * 0.3;
    
    return max(box - disp, -hole);
}

// Normal calculation for surface lighting
vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

// --- Main Pipeline ---

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalizing screen coordinates
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // 1. Camera Logic
    // Ray Origin moves forward (Z) while swaying (X,Y)
    vec3 ro = vec3(0.0, 0.0, iTime * 6.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    ro.x += sin(iTime * 0.5) * 1.0;
    ro.y += cos(iTime * 0.3) * 1.0;
    rd.xy *= rot(sin(iTime * 0.1) * 0.2); // Dynamic camera tilt
    
    // 2. Raymarching
    float t = 0.0, d = 0.0;
    vec3 p;
    for (int i = 0; i < 80; i++) {
        p = ro + rd * t;
        d = map(p);
        if (d < 0.001 || t > 60.0) break;
        t += d * 0.6; // Safe stepping for displaced surfaces
    }
    
    vec3 col = vec3(0.0);
    
    // 3. Shading the Geometry
    if (d < 0.001) {
        vec3 n = getNormal(p);
        vec3 lp = ro + vec3(0.0, 0.0, 2.0); // Dynamic point light
        vec3 ld = normalize(lp - p);
        
        float diff = max(dot(n, ld), 0.0);
        float spec = pow(max(dot(reflect(-ld, n), -rd), 0.0), 32.0);
        float rim = pow(1.0 - max(dot(n, -rd), 0.0), 4.0); // Fresnel/Rim lighting
        
        // Surface pattern based on FBM
        vec3 matPos = p * 0.5;
        matPos.z += iTime; 
        float pat = fbm(matPos * 3.0);
        
        vec3 baseCol = mix(vec3(0.1, 0.0, 0.2), vec3(0.0, 0.5, 0.8), pat);
        baseCol += vec3(1.0, 0.8, 0.4) * step(0.7, pat); // Hot spots
        
        col = baseCol * diff + vec3(1.0) * spec + vec3(0.5, 0.8, 1.0) * rim * 2.0;
        col *= exp(-0.05 * t); // Distance fog
    }
    
    // 4. Volumetric Particles ("Electrons")
    // Analytical glow calculation for point particles moving in 3D
    vec3 electrons = vec3(0.0);
    for (float i = 0.0; i < 6.0; i++) {
        float t2 = iTime * (2.0 + i * 0.5);
        vec3 ep = ro + vec3(sin(t2) * 4.0, cos(t2 * 1.3) * 3.0, 10.0 + sin(t2 * 0.7) * 5.0);
        vec3 ed = ep - ro;
        float el = length(ed);
        vec3 edir = ed / el;
        
        float proj = dot(rd, edir);
        float dist = length(cross(rd, edir)) * el; // Point-to-line distance
        
        if (proj > 0.0) {
            float glow = exp(-dist * 8.0) / (el * 0.1);
            vec3 pCol = 0.5 + 0.5 * cos(vec3(0.0, 2.0, 4.0) + i);
            electrons += pCol * glow * 2.0;
        }
    }
    col += electrons;
    
    // 5. Fake Volumetric Fog
    // Sampling FBM along the ray to create hazy atmosphere
    float fogDen = 0.0;
    for(int i=0; i<6; i++) {
        vec3 fp = ro + rd * (float(i) * 5.0);
        fogDen += max(0.0, fbm(fp * 0.3 + vec3(iTime, 0.0, iTime*0.2)) - 0.2);
    }
    col += vec3(0.6, 0.2, 0.8) * fogDen * 0.15;

    // 6. Temporal Feedback Loop
    // Blends the current frame with the previous one for motion trails
    vec3 prev = texture(iChannel0, fragCoord / iResolution.xy).rgb;
    col = mix(col, prev, 0.6);
    
    fragColor = vec4(col, 1.0);
}
