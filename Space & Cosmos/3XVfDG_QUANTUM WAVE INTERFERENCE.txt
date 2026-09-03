// ==== Image (image) ====
// ==========================================================
// NAME : QUANTUM WAVE INTERFERENCE
// ==========================================================
// DESCRIPTION : A scientific visualization of quantum mechanics 
// simulating the superposition of multiple energy states. It 
// calculates the probability density of wave functions and 
// maps their mathematical phase to the visible color spectrum.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define PI 3.14159265359

// --- Color Mapping ---

// Converts a mathematical phase (an angle in radians) into an RGB color.
// This represents the "argument" of a complex wave function, allowing 
// us to see the phase shifting in real-time.
vec3 phaseToRGB(float phase) {
    // We use a cosine-based palette to cycle through the spectrum every 2PI.
    return 0.5 + 0.5 * cos(phase + vec3(0.0, 2.0 * PI / 3.0, 4.0 * PI / 3.0));
}

// --- Main Simulation ---

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 1. Coordinate Normalization
    // We center the coordinates at (0,0) and scale them from -1.0 to 1.0 
    // relative to the height of the screen.
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t = iTime * 0.5;
    vec3 finalColor = vec3(0.0);
    
    // 2. Quantum State Superposition
    // We simulate three distinct energy levels (n=1, 2, 3). 
    // In quantum mechanics, the observed state is often a sum of these bases.
    for(float i = 1.0; i <= 3.0; i++) {
        
        // Energy Calculation:
        // Following the "Particle in a Box" model, energy $E_n$ is 
        // proportional to $n^2$. This dictates the frequency of the phase rotation.
        float energy = i * i * 0.2; 
        float phase = energy * t;
        
        // 3. Spatial Geometry
        // We calculate the polar coordinates (radius and angle) for the pixel.
        float radius = length(uv) * (2.0 + i);
        float angle = atan(uv.y, uv.x);
        
        // 4. The Wave Function ($\psi$)
        // We define the amplitude using a Gaussian envelope: $exp(-r^2)$.
        // This keeps the "electron cloud" concentrated near the center.
        // The sine term introduces the spatial oscillation of the wave.
        float psi = exp(-radius * radius * 0.5) * sin(radius * i - phase);
        
        // 5. Probability Density ($|\psi|^2$)
        // In physics, we don't "see" the wave function directly, but rather 
        // the probability of a particle's presence, which is the square of the amplitude.
        float prob = psi * psi;
        
        // 6. Color Synthesis
        // The color is derived from the local phase, which is a combination 
        // of the spatial angle and the time-dependent energy phase.
        vec3 color = phaseToRGB(angle + phase);
        
        // Accumulate the contributions of each state into the final pixel color.
        finalColor += color * prob;
    }

    // --- Post-Processing ---

    // Apply a light Gamma Correction to mimic filmic/scientific imaging.
    finalColor = pow(finalColor, vec3(0.8)); 
    
    // Natural Vignetting to focus the viewer's eye on the center of the orbital.
    finalColor *= 1.2 - length(uv); 
    
    fragColor = vec4(finalColor, 1.0);
}
