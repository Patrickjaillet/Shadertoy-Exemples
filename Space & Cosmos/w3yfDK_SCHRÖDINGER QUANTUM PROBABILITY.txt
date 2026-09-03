// ==== Image (image) ====
// ==========================================================
// NAME : SCHRODINGER QUANTUM PROBABILITY
// ==========================================================
// This shader visualizes the probability density of a 
// quantum particle, specifically inspired by the 2p 
// hydrogen orbitals. The structure represents the region 
// where the wave function squared (|psi|^2) is highest. 
// The camera travels through the nodal planes—the mathematical 
// "holes" where the probability of finding the particle 
// is exactly zero.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MAX_STEPS 100
#define SURF_DIST 0.001
#define MAX_DIST 80.0

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// SDF for a 2p-style orbital (simplified dumbbell)
float sdOrbital(vec3 p, float scale) {
    float r = length(p);
    // Added 0.0001 to avoid division by zero error at the origin
    float costheta = p.y / (r + 0.0001);
    float density = (r * r) * (costheta * costheta) * exp(-r * 0.8);
    
    // Render the isosurface where probability exceeds threshold
    return (0.15 - density) * scale;
}

float GetDist(vec3 p) {
    // Floor (Old Laboratory Parquet)
    float d = p.y + 3.0;
    
    // Repeat orbitals along the Z axis
    float zInterval = 10.0;
    float zIndex = floor(p.z / zInterval);
    vec3 pOrbit = p;
    pOrbit.z = mod(pOrbit.z, zInterval) - zInterval * 0.5;
    
    // Quantum Phase Rotation
    float phase = iTime * 2.0 + zIndex;
    pOrbit.xy *= Rot(phase * 0.2);
    
    // Orbital geometry
    float orbital = sdOrbital(pOrbit, 2.0);
    
    // Clear a passage through the nodes for the camera
    float hole = length(pOrbit.xz) - 1.2;
    orbital = max(orbital, -hole);
    
    d = min(d, orbital);
    
    // 0.6 multiplier to prevent raymarching overstepping on curved density
    return d * 0.6;
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
    }
    return dO;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.01, 0);
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx));
    return normalize(n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // Camera trajectory through the nodal plane
    float speed = iTime * 5.0;
    vec3 ro = vec3(0.0, 0.0, speed);
    
    // Subtle "Uncertainty" movement
    ro.x += sin(iTime * 1.5) * 0.15;
    ro.y += cos(iTime * 1.1) * 0.15;
    
    vec3 lookat = vec3(0.0, 0.0, speed + 1.0);
    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float d = RayMarch(ro, rd);
    vec3 col = vec3(0.01, 0.01, 0.02); // Deep Oxford Blue
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        
        vec3 lp = vec3(2.0, 5.0, speed + 2.0);
        float dif = clamp(dot(n, normalize(lp - p)), 0.0, 1.0);
        
        // Materials: Academic Brass and Dark Wood
        vec3 mat = vec3(0.8, 0.6, 0.3); 
        if(p.y < -2.9) {
            float wood = smoothstep(0.1, 0.0, abs(fract(p.x * 2.0) - 0.5));
            mat = mix(vec3(0.1, 0.05, 0.02), vec3(0.05, 0.02, 0.01), wood);
        }
        
        col = mat * (dif + 0.1);
        
        // Quantum phase pulse
        float pulse = sin(p.z * 0.5 - iTime * 3.0) * 0.5 + 0.5;
        col += vec3(0.4, 0.6, 1.0) * pulse * 0.15;
        
        col = mix(col, vec3(0.01, 0.01, 0.02), 1.0 - exp(-0.02 * d));
    }

    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}
