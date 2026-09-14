// ==== Image (image) ====
// ==========================================================
// NAME : KALEIDOSCOPIC FRACTAL TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through an infinite 
// industrial tunnel containing a complex KIFS fractal. 
// Features iterative folding, global glow accumulation, 
// and dynamic Fresnel-based lighting.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize coordinates (0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // 1. Texture Fetching
    // iChannel0 usually contains the main scene, iChannel1 contains the bloom (glow).
    vec3 scene = texture(iChannel0, uv).rgb;
    vec3 bloom = texture(iChannel1, uv).rgb;

    // 2. Additive Bloom Blending
    // We add a portion of the bloom texture back onto the scene to create glow.
    vec3 col = scene + bloom * 0.5;
    
    // 3. ACES Filmic Tonemapping
    // This maps High Dynamic Range (HDR) colors to the 0.0-1.0 range of your screen.
    // It creates a "filmic" look with high contrast and soft highlight roll-off.
    col *= 0.8; // Exposure adjustment
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    col = clamp((col * (a * col + b)) / (col * (c * col + d) + e), 0.0, 1.0);
    
    // 4. Gamma Correction
    // Converts the linear color space to sRGB (standard for monitors).
    col = pow(col, vec3(1.0 / 2.2));

    // 5. Vignette Effect
    // Darkens the corners to focus the viewer's eye on the center of the frame.
    vec2 vuv = uv * (1.0 - uv.yx);
    float vig = vuv.x * vuv.y * 15.0;
    vig = pow(vig, 0.3); // Control the softness of the vignette
    col *= mix(0.7, 1.0, vig);

    // 6. Chromatic Aberration
    // Simulates a physical lens defect where colors separate at the edges of the image.
    // We shift the Red and Blue channels in opposite directions based on distance from center.
    float caStrength = smoothstep(0.3, 1.5, length(uv - 0.5)) * 0.005;
    col.r = texture(iChannel0, uv - caStrength).r;
    col.b = texture(iChannel0, uv + caStrength).b;

    // 7. Procedural Film Grain
    // Adds a subtle "static" noise to make the image feel less digitally perfect.
    float grain = fract(sin(dot(uv + iTime * 0.1, vec2(12.9898, 78.233))) * 43758.5453);
    col += (grain - 0.5) * 0.03;
    
    // 8. Final Contrast Pass
    // A slight smoothstep at the end to deepen the blacks and brighten the whites.
    col = smoothstep(0.02, 1.02, col);

    // Output final cinematic color
    fragColor = vec4(col, 1.0);
}

// ==== Common (common) ====
// ==========================================================
// NAME : KALEIDOSCOPIC FRACTAL TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through an infinite 
// industrial tunnel containing a complex KIFS fractal. 
// Features iterative folding, global glow accumulation, 
// and dynamic Fresnel-based lighting.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.3, 0.20, 0.2);
    return a + b * cos(6.28318 * (c * t + d) + vec3(0.0, 1.4, 2.9));
}

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float star(vec2 uv, float flare) {
    float d = length(uv);
    float m = 0.05 / d;
    float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
    m += rays * flare;
    uv *= rot(3.1415 / 4.0);
    rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
    m += rays * 0.3 * flare;
    m *= smoothstep(0.5, 0.2, d);
    return m;
}

vec3 GetBackground(vec3 rd, float time) {
    vec3 bgColor = vec3(0.01, 0.02, 0.08) * (1.0 - abs(rd.y)); 
    
    float noise = 0.0;
    vec3 p = rd * 4.0;
    for(float i=1.0; i<=4.0; i++){
        p.xz *= rot(time*0.05/i);
        noise += (sin(p.x + sin(p.y*1.5) + p.z)*0.5+0.5) / i;
        p *= 2.0;
    }
    bgColor += palette(noise*0.5 + time*0.1) * noise * 0.05;

    vec2 uv = rd.xy * 8.0;
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
    float flicker = hash21(id);
    float starSize = sin(time * 2.0 + flicker * 6.28) * 0.5 + 0.5;
    if(flicker > 0.95) {
        bgColor += vec3(1.0, 0.9, 0.7) * star(gv, starSize) * flicker;
    }
    
    return bgColor;
}

// ==== Buffer A (buffer) ====
// ==========================================================
// NAME : KALEIDOSCOPIC FRACTAL TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through an infinite 
// industrial tunnel containing a complex KIFS fractal. 
// Features iterative folding, global glow accumulation, 
// and dynamic Fresnel-based lighting.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// Global glow accumulator used for volumetric-like lighting effects
float g_glow = 0.0;

// Standard 2D rotation matrix
mat2 rot1(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// --- Scene Distance Function (SDF) ---

float map(vec3 p) {
    vec3 q = p; 
    float d = 1000.0;
    
    // 1. TUNNEL ENVIRONMENT
    vec3 p_env = p;
    p_env.z += iTime * 15.0; // Rapid forward movement
    p_env.xy *= rot(p_env.z * 0.01); // Subtle twist along the tunnel length

    // Domain repetition: Creates an infinite corridor
    vec3 id = floor((p_env + 5.0) / 10.0);
    p_env = mod(p_env + 5.0, 10.0) - 5.0;
    
    // Define the tunnel cross-section (hollow box/cylinder hybrid)
    float box = length(max(abs(p_env) - vec3(2.0, 2.0, 10.0), 0.0));
    box = max(box, -length(p_env.xy) + 3.5 + sin(p_env.z*0.5)*0.2); 
    d = min(d, box);
    
    // 2. CENTRAL KIFS FRACTAL
    vec3 p_frac = q;
    // Rotate the entire fractal object over time
    p_frac.xz *= rot(iTime * 0.2);
    p_frac.yz *= rot(iTime * 0.15);

    float scale = 1.0;
    float frac_d = 0.0;
    float localGlow = 0.0;
    
    // Fractal Iteration Loop (KIFS)
    // We repeatedly fold space, rotate it, and scale it up.
    for(int i = 0; i < 6; i++) {
        // Fold: Mirror space across the axes to create symmetry
        p_frac = abs(p_frac) - vec3(0.8, 0.8 + float(i)*0.1, 0.8); 
        
        // Rotate: Twist the folded space to increase structural complexity
        p_frac.xz *= rot(0.785); // 45 degrees
        p_frac.yz *= rot(0.4 + float(i)*0.05);
        
        // Scale: Amplify the distance and reposition
        scale *= 1.5;
        p_frac *= 1.5;
        p_frac -= vec3(1.2, 0.5, 1.2); 
        
        // Accumulate glow based on proximity to the fractal "limbs"
        localGlow += exp(-length(p_frac) * 1.5) * (1.0/scale);
    }
    
    // Calculate final fractal distance
    frac_d = length(p_frac) / scale - 0.02; 
    
    // Update global glow for use in mainImage
    g_glow += localGlow * 0.2;
    
    // Smoothly blend the fractal with the tunnel walls
    d = smin(d, frac_d, 1.5);
    return d;
}

// --- Lighting & Rendering ---

vec3 GetNormal(vec3 p) {
    float d = map(p);
    vec2 e = vec2(0.005, 0.0); 
    vec3 n = d - vec3(
        map(p - e.xyy),
        map(p - e.yxy),
        map(p - e.yyx)
    );
    return normalize(n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Reset global glow at the start of the pixel calculation
    g_glow = 0.0;

    // UV normalization
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    // Mouse interaction for camera control
    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.z <= 0.0) m = vec2(0.5); 

    vec3 ro = vec3(0.0, 0.0, -8.0); 
    vec3 rd = normalize(vec3(uv, 1.2)); 

    // Rotate camera view based on mouse position
    float pitch = (m.y - 0.5) * 3.0;
    float yaw = (m.x - 0.5) * 6.0;
    rd.yz *= rot(pitch);
    rd.xz *= rot(yaw);
    ro.yz *= rot(pitch * 0.5); 
    ro.xz *= rot(yaw * 0.5);
    
    // --- RAYMARCHING ---
    float t = 0.0;
    float maxDist = 120.0;
    
    for(int i = 0; i < 128; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        t += d * 0.8; 
        if(d < 0.002 || t > maxDist) break;
    }
    
    vec3 col = vec3(0.0);
    // Assumes existence of GetBackground() and palette() functions
    vec3 bgCol = GetBackground(rd, iTime);

    if(t < maxDist) {
        vec3 p = ro + rd * t;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        // Dual Light setup
        vec3 l1 = normalize(vec3(5.0, 10.0, p.z - 5.0) - p);
        vec3 l2 = normalize(vec3(-5.0, -8.0, p.z + 2.0) - p);
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0) * 0.5;
        float spec1 = pow(max(dot(r, l1), 0.0), 16.0);
        float spec2 = pow(max(dot(r, l2), 0.0), 8.0);
        
        // Fresnel: Simulates glancing reflection at steep angles
        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        
        vec3 objColor = palette(length(p.xy) * 0.1 + p.z*0.02);
        
        // Composite lighting
        col = objColor * (diff1 * vec3(1.0, 0.8, 0.6) + diff2 * vec3(0.2, 0.4, 1.0));
        col += vec3(1.0, 0.9, 0.8) * spec1 * 2.0; 
        col += vec3(0.5, 0.7, 1.0) * spec2 * 1.0; 
        col += bgCol * fresnel * 4.0; 
        
        // Distance Fog
        float fog = 1.0 - exp(-t * t * 0.0001);
        col = mix(col, bgCol, fog);
    } else {
        col = bgCol;
        g_glow += 2.0; // Extra sky glow
    }
    
    // --- FINAL EFFECTS ---
    
    // Apply the accumulated glow from the mapping loop
    vec3 glowColor = mix(vec3(0.1, 0.5, 1.0), vec3(1.0, 0.2, 0.1), smoothstep(0.0, 5.0, g_glow));
    col += glowColor * g_glow * 0.08;
    
    // Simple temporal feedback (Assumes texture on iChannel0)
    vec3 prevFrame = texture(iChannel0, fragCoord / iResolution.xy).rgb;
    col = mix(prevFrame, col, 0.1); 
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer B (buffer) ====
// ==========================================================
// NAME : KALEIDOSCOPIC FRACTAL TUNNEL
// ==========================================================
// DESCRIPTION : A high-speed traversal through an infinite 
// industrial tunnel containing a complex KIFS fractal. 
// Features iterative folding, global glow accumulation, 
// and dynamic Fresnel-based lighting.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec3 sum = vec3(0.0);
    float weightSum = 0.0;
    
    for(int x = -5; x <= 5; x++) {
        for(int y = -5; y <= 5; y++) {
            vec2 offset = vec2(float(x), float(y));
   
            vec3 col = texture(iChannel0, uv + offset * 2.5 / iResolution.xy).rgb;
            
            float w = exp(-(offset.x*offset.x + offset.y*offset.y) / 24.0);
        
            vec3 brightPart = max(col - vec3(0.7), 0.0); 

            sum += brightPart * w; 
            weightSum += w;
        }
    }
    
    sum /= weightSum;
  
    fragColor = vec4(sum * 2.5, 1.0);
}
