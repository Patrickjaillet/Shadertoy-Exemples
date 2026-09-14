// ==== Image (image) ====
// https://github.com/Patrickjaillet


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Initialize the accumulated color output vector to zero (transparent black background)
    vec4 o = vec4(0.0);
    // Declare and initialize scalars for the raymarching step index (i), density/SDF (e), radial radius (R), and frequency scaling factor (s)
    float i = 0.0, e = 0.0, R = 1.0, s = 0.0;
    
    // Normalize and center the screen coordinates with a 2.2 zoom multiplier, preserving the aspect ratio on the Y-axis
    vec2 uv = (fragCoord * 2.2 - iResolution.xy) / iResolution.y;
    
    // Set the ray origin position (Camera position) slightly elevated on the Y-axis
    vec3 ro = vec3(0.0, 0.2, 0.0);
    // Define the normalized ray direction vector with a focal length/depth adjustment of 1.2
    vec3 rd = normalize(vec3(uv, 1.2));
    
    // Initialize the current marching point vector q at the camera position
    vec3 q = ro;
    // Declare the position vector p which will store the space-transformed coordinates
    vec3 p = vec3(0.0);

    // Main raymarching loop for volumetric accumulation, capped at a maximum of 113 iterations
    for(; i++ < 113.0;)
    {
        // Reset the initial base frequency for the fractal noise loop
        s = 3.3;
        // Move the ray marching point q forward along its path and copy the value into p for transformations
        p = q += rd * e * R * 0.1;

        // Calculate the raw Euclidean distance (radius) of the point p from the world origin
        R = length(p);
        
        // Generate a 3D trigonometric displacement field (blister pattern) animated over time
        float blisters = sin(p.x * 6.3 + iTime) * cos(p.y * 3.5 - iTime) * sin(p.z * 4.0) * 0.45;

        // Project the 3D space into log-spherical / cylindrical coordinates, distorted by time and the blister displacement
        p = vec3(
            log2(R + 1e-4) - iTime * 0.5 + blisters,
            exp2(R - p.z / (R + 1e-4)),
            atan(p.y, p.x)
        );

        // Initialize the base density/potential field derived from the transformed vertical Y coordinate
        e = --p.y;

        // Nested Fractal Brownian Motion (FBM) loop that doubles the frequency (s) at each iteration up to the upper threshold
        for(; s < 734.0; s += s)
            // Accumulate absolute value harmonic wave layers using interleaved trigonometric dot products, scaled down by frequency
            e += abs(dot(cos(p.yzz * s), cos(p.yyx * s))) / s * 0.4;

        // Normalize and remap the accumulated density e weighted by the maximum frequency, bounded between 0.0 and 1.0
        float val = clamp((e * s - 1.0) / 42.6, 0.0, 1.0);

        // Generate 4 distinct smooth transition masks to segment the gradient color ramp based on the local density value
        vec4 w = smoothstep(vec4(0.0, 0.17, 0.00, 1.0), vec4(0.15, 0.34, 0.58, 1.0), vec4(val));
        // Linearly interpolate the first tier: transitioning from a dark magenta-red base to a bright vermilion red
        vec3 col = mix(mix(vec3(0.25, 0.00, 0.05), vec3(1.0, 0.05, 0.00), w.x), vec3(1.00, 0.40, 0.00), w.y);
        // Linearly interpolate the second tier into a warm glowing orange
        // Interpolate the third tier towards a bright, core emissive white color
        col = mix(col, vec3(1.0, 1.0, 1.00), w.z);
        // Interpolate the fourth tier into a highly energetic, yellowish-white thermal tint
        col = mix(col, vec3(1.5, 2.20, 1.05), w.w);
        // Add a final hyper-energetic layer shifting towards an electric blue for peak structural density zones
        col = mix(col, vec3(0.20, 0.55, 2.00), smoothstep(0.75, 1.0, val));

        // Accumulate the fragment's color multiplied by its density, a step filter threshold (0.6), and an absorption constant
        o.rgb += col * val * 0.020 * step(0.6, val);
    }

    // Apply a Reinhard tonemapping operator to map high dynamic range (HDR) illumination back into a 0-1 LDR scale
    o.rgb = o.rgb / (1.0 + o.rgb);
    // Gamma correction with a linear exponent of 1.0 (maintaining raw color curves or assuming linear color space)
    o.rgb = pow(o.rgb, vec3(1.0));

    // Write the final processed color output to the RGBA frame buffer with an opaque alpha channel
    fragColor = vec4(o.rgb, 1.0);
}
