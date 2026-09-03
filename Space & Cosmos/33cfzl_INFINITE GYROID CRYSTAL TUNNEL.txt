// ==== Image (image) ====
// ==========================================================
// NAME : INFINITE GYROID CRYSTAL TUNNEL
// ==========================================================
// DESCRIPTION : A procedural raymarched tunnel featuring a multi-scale 
// gyroid surface. The scene includes space twisting, dynamic 
// thickness pulsing, and a proximity-based glow accumulation 
// for a deep, volumetric atmospheric effect.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Utilities ---

// Standard 2D rotation matrix for coordinate transformation.
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Gyroid Function: Defines a minimal surface through trigonometric dot products.
// It creates a porous, interconnected structure that looks organic or crystalline.
// 
float gyroid(vec3 p) {
    return dot(sin(p), cos(p.yzx));
}

// --- Scene Distance Function (SDF) ---

float map(vec3 p) {
    float d = 100.0;
    
    // Constant forward movement along the Z-axis.
    p.z += iTime * 0.5; 
    
    // 1. Domain Warping (Twist)
    // Rotates the XY plane based on the Z position to create a spiral effect.
    p.xy *= rot(p.z * 0.1);
    
    // 2. Multi-scale Gyroid Construction
    // We layer multiple frequencies of the gyroid function to create detail (FBM style).
    float g = gyroid(p * 2.0) * 0.5;
    g += gyroid(p * 4.0) * 0.25;
    g += gyroid(p * 8.0) * 0.125;
    
    // 3. Dynamic Thickness
    // The surface "breathes" over time by modulating the thickness parameter.
    float thickness = 0.05 + 0.02 * sin(iTime * 0.5);
    
    // Convert the gyroid density into a hollow shell surface.
    d = abs(g) - thickness;
    
    // 4. Tunnel Constraints
    // We use max() to perform Boolean subtractions/intersections.
    // This carves a circular path (tunnel) through the center and bounds the exterior.
    d = max(d, 0.5 - length(p.xy));   // Carve inner tunnel
    d = max(d, length(p.xy) - 2.0);  // Restrict to outer cylinder
    
    return d;
}

// --- Main Rendering ---

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalizing screen coordinates (Aspect ratio corrected).
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // Mouse interaction for view rotation.
    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.z <= 0.0) m = vec2(0.0); 

    // ro = Ray Origin (Camera), rd = Ray Direction.
    vec3 ro = vec3(0.0, 0.0, -2.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    // Rotate camera based on mouse input.
    ro.yz *= rot(m.y * 1.5);
    rd.yz *= rot(m.y * 1.5);
    ro.xz *= rot(-m.x * 1.5);
    rd.xz *= rot(-m.x * 1.5);
    
    float t = 0.0;
    vec3 p = ro;
    float d = 0.0;
    vec3 glow = vec3(0.0);
    
    // --- Raymarching Loop ---
    // Instead of simple surface hits, we accumulate color as we approach surfaces.
    for(int i = 0; i < 64; i++) {
        p = ro + rd * t;
        d = map(p);
        
        // Accumulate glow based on proximity to the surface (Inverse Square Law logic).
        // 
        float dist_factor = 1.0 / (1.0 + d * d * 100.0);
        
        // Procedural color palette shifting along the tunnel depth (p.z).
        vec3 pal = 0.5 + 0.5 * cos(iTime * 0.2 + p.z * 0.1 + vec3(0.0, 0.33, 0.67));
        
        // Add current step color to total glow.
        glow += pal * dist_factor * 0.05;
        
        // Move the ray forward; use a 0.5 multiplier for softer, more accurate glow.
        t += max(d * 0.5, 0.01);
        if(t > 20.0) break;
    }
    
    vec3 color = glow;
    
    // --- Post-Processing ---
    
    // Subtle vignette to focus the eye on the tunnel center.
    color *= 1.0 - length(uv) * 0.5;
    
    // Reinhard Tone Mapping: Prevents colors from over-saturating into pure white.
    color = color / (1.0 + color);
    
    fragColor = vec4(color, 1.0);
}
