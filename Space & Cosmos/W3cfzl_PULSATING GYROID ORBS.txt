// ==== Image (image) ====
// ==========================================================
// NAME : PULSATING GYROID ORBS
// ==========================================================
// DESCRIPTION : A procedural raymarched scene featuring layered 
// gyroid structures that react to audio and time. It includes 
// dynamic orbiting light sources and a rhythmic pulsing effect.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Helper Functions ---

// Standard 2D rotation matrix for a given angle 'a'
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Gyroid function: creates a complex, porous periodic surface 
// using dot product of sine and cosine of coordinates.
float gyroid(vec3 p) {
    return dot(sin(p), cos(p.yzx));
}

// --- Scene Mapping ---

float map(vec3 p) {
    float d = 100.0;
    
    // Move the scene along the Z-axis over time (tunnel effect)
    p.z += iTime * 0.6; 
    
    // Twist the space based on the Z position for a spiral effect
    p.xy *= rot(p.z * 0.1);

    // Fractal Brownian Motion (FBM) approach using the gyroid:
    // We add layers of noise at different scales and amplitudes.
    float g = gyroid(p * 2.0) * 0.5;
    g += gyroid(p * 4.0) * 0.25;
    g += gyroid(p * 8.0) * 0.125;
    
    // Calculate thickness with a sine-wave pulse over time
    float thickness = 0.05 + 0.02 * sin(iTime * 0.5);
    
    // Convert the gyroid volume into a hollow shell (Distance Field)
    d = abs(g) - thickness;
    
    // Limit the gyroid to a cylindrical tube shape
    d = max(d, 0.5 - length(p.xy)); // Inner hole
    d = max(d, length(p.xy) - 2.0); // Outer boundary
    
    return d;
}

// --- Main Rendering ---

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalize pixel coordinates (from -0.5 to 0.5 relative to height)
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // Fetch audio data (FFT) from iChannel0 (low frequencies)
    float fft = texture(iChannel0, vec2(0.05, 0.0)).x; 
    
    // Handle mouse interaction for rotation
    vec2 m = iMouse.xy / iResolution.xy;
    if (iMouse.z <= 0.0) m = vec2(0.0); 

    // Setup camera: ro = ray origin (position), rd = ray direction
    vec3 ro = vec3(0.0, 0.0, -2.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    // Rotate camera and ray direction based on mouse movement
    ro.yz *= rot(m.y * 1.5);
    rd.yz *= rot(m.y * 1.5);
    ro.xz *= rot(-m.x * 1.5);
    rd.xz *= rot(-m.x * 1.5);
    
    // Raymarching initialization
    float t = 0.0;
    vec3 p = ro;
    float d = 0.0;
    vec3 glow = vec3(0.0);
    
    // Raymarching loop: step through space to find the surface
    for(int i = 0; i < 64; i++) {
        p = ro + rd * t;
        d = map(p);
        
        // --- Light Orbs Logic ---
        // Create 3 dynamic orbiting light sources
        for(int j = 1; j <= 3; j++) {
            float seed = float(j);

            // Calculate animated position for each orb
            vec3 orbPos = vec3(
                sin(iTime * (0.8 + seed * 0.2)) * 1.5,
                cos(iTime * (0.6 + seed * 0.3)) * 1.5,
                sin(iTime * 0.3 + seed) * 5.0 
            );
            
            float distToOrb = length(p - orbPos);
            
            // Generate a color palette for the orbs based on their index
            vec3 orbCol = 0.5 + 0.5 * cos(vec3(0.0, 2.0, 4.0) + seed);

            // Pulse intensity based on the music (FFT)
            float pulse = 0.02 * (1.0 + fft * 4.0); 

            // Add glow based on proximity to the orb (inverse square law)
            glow += orbCol * (pulse / (0.01 + distToOrb * distToOrb * 10.0));
        }

        // --- Surface Glow Logic ---
        // Create a glow effect near the surface of the gyroid
        float dist_factor = 1.0 / (1.0 + d * d * 100.0);

        // Procedural color palette shifting over time and depth
        vec3 pal = 0.5 + 0.5 * cos(iTime * 0.2 + p.z * 0.1 + fft * 2.0 + vec3(0.0, 0.33, 0.67));

        // Add the surface glow to the final accumulation
        glow += pal * dist_factor * 0.05 * (1.0 + fft);
        
        // Advance the ray; use a multiplier (0.5) for softer edges/glow
        t += max(d * 0.5, 0.01);
        if(t > 20.0) break; // Maximum distance clipping
    }
    
    vec3 color = glow;

    // --- Post-Processing ---
    // Simple Vignette
    color *= 1.0 - length(uv) * 0.5;
    
    // Tone mapping to handle high brightness (Reinhard)
    color = color / (1.0 + color);
    
    // Gamma correction for better color representation
    color = pow(color, vec3(0.4545));
    
    // Output final color
    fragColor = vec4(color, 1.0);
}
