// ==== Image (image) ====
// ==========================================================
// NAME : PYTHAGOREAN THEOREM
// ==========================================================
// DESCRIPTION : A geometric visualization of the Pythagorean 
// theorem (a² + b² = c²). The shader dynamically animates a 
// right-angled triangle and its associated squares using 
// Signed Distance Functions (SDF) and a classic paper aesthetic.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Geometry Utilities ---

// Standard SDF for a 2D box/square
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Standard SDF for a 2D line segment
float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    // Normalizing coordinates: center (0,0) and aspect ratio correction
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // 1. DYNAMIC TRIANGLE SIDES
    // We oscillate the lengths of sides 'a' and 'b' over time.
    float a = 0.2 + 0.12 * sin(iTime * 0.7);
    float b = 0.2 + 0.12 * cos(iTime * 0.5);
    
    // Ensure positive values for geometry stability
    a = abs(a) + 0.05; 
    b = abs(b) + 0.1;
    
    // Calculate the hypotenuse 'c' based on a² + b² = c²
    float c = sqrt(a*a + b*b);

    // 

    // Triangle vertices
    vec2 A = vec2(0.0, 0.0); // Right angle corner
    vec2 B = vec2(a, 0.0);   // Horizontal side end
    vec2 C = vec2(0.0, b);   // Vertical side end

    // 2. AESTHETIC PALETTE (Inked Paper Style)
    vec3 col_bg   = vec3(0.96, 0.95, 0.90); // Ivory/Cream background
    vec3 col_a    = vec3(0.75, 0.40, 0.40); // Terra Cotta (Side a²)
    vec3 col_b    = vec3(0.40, 0.55, 0.70); // Horizon Blue (Side b²)
    vec3 col_c    = vec3(0.50, 0.65, 0.50); // Lichen Green (Hypotenuse c²)
    vec3 col_line = vec3(0.15);             // Charcoal Gray line

    vec3 color = col_bg;

    // 3. SURFACE RENDERING (Squares)

    // Square a² (Attached to the horizontal side)
    float d_sqA = sdBox(uv - vec2(a*0.5, -a*0.5), vec2(a*0.5));
    if (d_sqA < 0.0) color = mix(color, col_a, 0.35);

    // Square b² (Attached to the vertical side)
    float d_sqB = sdBox(uv - vec2(-b*0.5, b*0.5), vec2(b*0.5));
    if (d_sqB < 0.0) color = mix(color, col_b, 0.35);

    // Square c² (Attached to the hypotenuse)
    // We must rotate this square to align with the slope of the hypotenuse.
    float angle = atan(b, a);
    vec2 uv_c = uv - C;
    float cosA = cos(angle), sinA = sin(angle);
    mat2 rot = mat2(cosA, sinA, -sinA, cosA);
    vec2 p_rot = rot * uv_c;
    
    // Draw square c² using the rotated UV space
    float d_sqC = sdBox(p_rot - vec2(c*0.5, c*0.5), vec2(c*0.5));
    if (d_sqC < 0.0) color = mix(color, col_c, 0.35);

    // 4. OUTLINE RENDERING ("Pen Stroke")
    // Combine all segment distances for the main triangle
    float dist = sdSegment(uv, A, B);
    dist = min(dist, sdSegment(uv, A, C));
    dist = min(dist, sdSegment(uv, B, C));
    
    // Combine with the borders of the squares
    dist = min(dist, abs(d_sqA));
    dist = min(dist, abs(d_sqB));
    dist = min(dist, abs(d_sqC));

    // Antialiased stroke rendering
    float edge = 1.0 - smoothstep(0.0, 0.004, dist);
    color = mix(color, col_line, edge);

    // 5. TEXTURE & POST-PROCESS
    // Add subtle procedural noise to simulate paper grain texture
    float grain = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    color -= grain * 0.03;

    // Final color output
    fragColor = vec4(color, 1.0);
}
