// ==== Image (image) ====
// ==========================================================
// NAME : INDUSTRIAL TECHNO TUNNEL
// ==========================================================
// DESCRIPTION : A brutalist audio visualizer featuring heavy 
// bass-synced distortion, a volumetric "strobe" effect, and 
// an industrial color palette. It uses space twisting and 
// interference patterns to create rhythmic geometric chaos.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define PI 3.14159265359
#define N normalize

// --- Mathematical Utilities ---

// Standard 2D rotation matrix for coordinate transformation.
mat2 rot(float a){
    float s=sin(a), c=cos(a);
    return mat2(c,-s,s,c);
}

// --- Audio Data (FFT) ---
// These helpers sample specific frequencies from iChannel0.
float bass(){
    return texture(iChannel0, vec2(0.02,0)).x;
}
float mid(){
    return texture(iChannel0, vec2(0.15,0)).x;
}
float high(){
    return texture(iChannel0, vec2(0.6,0)).x;
}

// --- Aesthetics & Geometry ---

// Industrial Palette: Blends ashy blacks, cold steels, and blood reds.
vec3 industrialPalette(float t){
    vec3 steel = vec3(.4,.4,.45);
    vec3 blood = vec3(.8,.05,.02);
    vec3 ash   = vec3(.08,.08,.08);

    // Dynamic mixing based on audio input and distance
    return mix(ash, mix(steel, blood, t), t);
}

// Pattern Function: The core volumetric shape generator.
// Creates a combination of rings and radial slices (interference).
float pattern(vec3 p, float k){
    // Twist the space based on depth (Z) and audio intensity (k)
    p.xy *= rot(p.z*.5 + iTime*.6 + k);
    
    // Convert to Polar Coordinates for geometric repetition
    float r = length(p.xy);
    float a = atan(p.y,p.x);

    // High-frequency sine waves create the "teeth" and "rings"
    float rings  = sin(r*18. - iTime*5.);
    float cuts   = sin(a*12. + iTime*2.);

    // Resulting distance field
    return abs(rings*cuts)*.6 + r - (1.1 + k*.3);
}

// --- Main Pipeline ---

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // Center and normalize UVs
    vec2 uv = (fragCoord - .5*iResolution.xy)/iResolution.y;

    // Capture audio signals for real-time modulation
    float B = bass();
    float M = mid();
    float H = high();

    // Camera: Ray Origin (ro) kicks back based on the bass pulse
    vec3 ro = vec3(0,0,-3.5 - B*2.);
    vec3 rd = N(vec3(uv,1));

    float t=0.;
    vec3 col=vec3(0);
    float acc=0.;

    // Volumetric Raymarcher: Accumulates light instead of just finding a surface
    for(int i=0;i<100;i++){
        vec3 p = ro + rd*t;

        // Sample the pattern with audio distortion
        float d = pattern(p, B*2.);
        
        // "Hit" intensity: Sharp exponential glow near the geometry
        float hit = exp(-abs(d)*7.);

        // Color based on the industrial palette and bass
        vec3 c = industrialPalette(B + length(p)*.15);

        // Accumulate color and density (glow factor)
        col += c * hit * (.05 + B*.1);
        acc += hit;

        // Step the ray forward (clamped to prevent overstepping)
        t += clamp(d*.45, .015, .2);
    }

    // --- Post-Processing Effects ---

    // MENTAL OVERLOAD STROBE
    // Creates a rapid flashing effect synced to high-intensity bass peaks.
    float strobe = smoothstep(.6,.9,sin(iTime*8. + B*12.));
    col *= 1. + strobe*.6;

    // Kick Flash: Sudden burst of red on heavy bass hits
    col += vec3(.9,.1,.05) * B * .8;

    // Industrial Contrast & Gamma Correction
    col *= acc*1.4;
    col = pow(col, vec3(.55));

    // Brutal Vignette: Strong darkening at the edges to focus on the center
    col *= smoothstep(1.2,.3,length(uv));

    // Output final color to screen
    fragColor = vec4(col,1);
}
