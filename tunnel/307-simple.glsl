// ==== Image (image) ====
// ==========================================================
// NAME : VISCERAL ORGANIC TUNNEL
// ==========================================================
// DESCRIPTION : A deep-dive raymarched tunnel with fleshy textures. 
// Features multi-layered trigonometric displacement, dynamic 
// "ooze" patterns, and dual-specular shading to simulate 
// wet, biological surfaces.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Utilities ---

// Standard 2D rotation matrix for coordinate transformation.
mat2 r2(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// --- Scene Distance Function (SDF) ---

float m(vec3 p) {
    // Apply a twisting effect to the tunnel based on depth (Z) and time.
    p.xy *= r2(p.z * 0.05 + iTime * 0.1);
    
    // Base geometry: An inverted cylinder (distance from center).
    float d = 2.8 - length(p.xy);
    
    // 1. Organic Displacement Layering
    // We add multiple sine waves at different scales to create "fleshy" bumps.
    float organic = sin(p.z * 2.0 + p.y * 1.5) * 0.3;      // Large folds
    organic += sin(p.x * 3.5 + p.z * 2.5) * 0.15;        // Medium bumps
    organic += (sin(p.x * 7.0) * sin(p.y * 8.0) * sin(p.z * 6.0)) * 0.08; // Small pores

    // Subtract the organic noise from the distance to "push" the walls inward.
    d -= organic;
    
    // Return the distance multiplied by a safety factor (0.6) to prevent overstepping.
    return d * 0.6;
}

// --- Main Rendering ---

void mainImage(out vec4 O, in vec2 U) {
    vec2 R = iResolution.xy;
    vec2 uv = (U - 0.5 * R) / R.y;
    
    // 1. Camera setup
    // ro = ray origin (moving forward through the tunnel).
    vec3 ro = vec3(0.0, 0.0, iTime * 4.0);
    
    // rd = ray direction (normalized direction for each pixel).
    vec3 rd = normalize(vec3(uv, 1.0));
    
    // Apply camera "roll" and "pitch/yaw" to simulate a swimming movement.
    rd.xy *= r2(sin(iTime * 0.5) * 0.1);
    float pitch = cos(iTime * 0.25) * 1.2;
    float yaw = sin(iTime * 0.4) * 3.14159;
    rd.yz *= r2(pitch);
    rd.xz *= r2(yaw);
    
    // 2. Raymarching Loop
    float t = 0.0, d;
    vec3 p;
    for(int i = 0; i < 120; i++) {
        p = ro + rd * t;
        d = m(p);
        // If the ray is close enough to the surface or too far away, stop.
        if(d < 0.001 || t > 60.0) break;
        t += d;
    }
    
    // 3. Shading and Coloring
    vec3 c = vec3(0.05, 0.01, 0.02); // Dark background/fog color
    
    if(t < 60.0) {
        // Calculate the surface normal using finite difference.
        vec2 e = vec2(0.01, 0.0);
        vec3 n = normalize(vec3(
            m(p + e.xyy) - m(p - e.xyy),
            m(p + e.yxy) - m(p - e.yxy),
            m(p + e.yyx) - m(p - e.yyx)
        ));
        
        // Light direction (originating from the camera position).
        vec3 ld = normalize(ro - p);
        float dif = max(dot(n, ld), 0.1); // Lambertian diffuse
        
        // 4. "Ooze" Texture Logic
        // Creates a dripping pattern that moves down the walls over time.
        float dripPattern = sin(p.y * 6.0 - iTime * 3.5 + sin(p.z * 1.5) * 4.0 + sin(p.x * 3.0) * 2.0);
        float ooze = smoothstep(0.3, 0.8, dripPattern);
        
        // Blend between a dry fleshy base and a dark, wet "ooze" color.
        vec3 baseCol = vec3(0.4, 0.15, 0.1);
        vec3 wetCol = vec3(0.2, 0.02, 0.01);
        c = mix(baseCol, wetCol, ooze * 0.8) * dif;
        
        // 5. Specular Highlights
        // Two layers: A broad soft shine for skin and a sharp, bright shine for wetness.
        vec3 ref = reflect(-ld, n);
        float baseSpec = pow(max(dot(ref, -rd), 0.0), 4.0) * 0.2;
        float wetSpec = pow(max(dot(ref, -rd), 0.0), 64.0) * ooze * 2.5;
        
        c += vec3(1.0, 0.8, 0.7) * (baseSpec + wetSpec);
    }
    
    // 6. Final Polish
    // Apply exponential fog to fade distant parts into the dark background.
    c = mix(c, vec3(0.08, 0.02, 0.03), 1.0 - exp(-t * 0.06));
    
    // Gamma correction for realistic color presentation.
    O = vec4(pow(c, vec3(0.4545)), 1.0);
}
