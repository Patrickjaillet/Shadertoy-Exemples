// ==== Image (image) ====
// --- Noise & Math Foundations ---

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Optimized 2D hash for noise generation
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// 2D Simplex Noise: Faster and more organic than standard Value Noise.
// It uses a triangular grid to avoid the "grid-like" artifacts of square noise.
float noise(in vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2
    const float K2 = 0.211324865; // (3-sqrt(3))/6
    
    // Skew space to find which "triangle" we are in
    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x);
    vec2 o = vec2(m, 1.0 - m);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    
    // Calculate the influence of the three corners of the triangle
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
    
    return dot(n, vec3(70.0));
}

// Fractal Brownian Motion: Layering 6 octaves of noise for rich detail.
// Each iteration doubles the frequency and halves the amplitude.
float fbm(vec2 uv) {
    float f = 0.0;
    uv *= 2.0;
    float w = 0.5;
    for (int i = 0; i < 6; i++) {
        f += w * noise(uv);
        // Rotating the UVs per octave breaks up directional artifacts.
        uv *= mat2(1.6, 1.2, -1.2, 1.6);
        w *= 0.5;
    }
    return f;
}

// --- Main Pipeline ---

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalizing coordinates and correcting aspect ratio.
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float t = iTime * 0.15;
    
    // 1. DOMAIN WARPING
    // We use FBM to displace the coordinates of another FBM.
    // 'q' creates the first layer of swirls.
    vec2 q = vec2(fbm(uv + vec2(0.0, t)), fbm(uv + vec2(1.0, t)));
    
    // 'r' uses 'q' as an input, creating the second, tighter layer of warping.
    vec2 r = vec2(fbm(uv + 1.2 * q + vec2(1.7, 9.2) + 0.15 * t), 
                  fbm(uv + 1.2 * q + vec2(8.3, 2.8) + 0.126 * t));
                  
    // The final value 'f' is the accumulation of these warps.
    float f = fbm(uv + r);
    
    // 2. PROCEDURAL COLORING
    // Blend between Deep Violet, Emerald Green, and Ochre based on noise values.
    vec3 col = mix(vec3(0.15, 0.02, 0.35), vec3(0.02, 0.25, 0.1), clamp((f * f) * 4.0, 0.0, 1.0));
    col = mix(col, vec3(0.7, 0.5, 0.1), clamp(length(q) * 2.0 - 1.0, 0.0, 1.0));
    col = mix(col, vec3(0.9, 0.7, 0.2), clamp(length(r.x) * 3.0 - 1.5, 0.0, 1.0));
    
    // 3. GOLDEN VEIN LAYER
    // We create "veins" by using smoothstep on a high-frequency noise pass warped by 'q'.
    float cell = fbm(uv * 6.0 + q * 3.0 - iTime * 0.1);
    float pattern = smoothstep(0.4, 0.45, cell) * smoothstep(0.55, 0.45, cell);
    
    vec3 goldTexture = vec3(0.8, 0.6, 0.1) * pattern * 2.5;
    // Animate the intensity of the gold veins.
    col += goldTexture * clamp(sin(iTime * 0.3) * 0.5 + 0.5, 0.0, 1.0);
    
    // 4. POST-PROCESS
    col *= 1.2;
    col -= length(uv) * 0.1; // Subtle center-focused lighting
    
    fragColor = vec4(col, 1.0);
}
