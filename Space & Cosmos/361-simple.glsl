// ==== Image (image) ====
// ==========================================================
// NAME : SPACETIME FABRIC DISTORTION
// ==========================================================
// DESCRIPTION : A conceptual visualization of General Relativity. 
// A moving mass "warps" a 3D grid system. The shader uses 
// space-warping functions and raymarching to render the distorted 
// coordinate fabric and the central gravitating body.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- Animation Logic ---

// Calculates the 3D orbital path of the "Mass" over time
vec3 getMassPos(float t) {
    return vec3(sin(t * 0.8) * 2.5, cos(t * 0.4) * 1.0, cos(t * 0.8) * 2.5);
}

// --- Space Warping ---

// This function "pulls" the coordinate system toward the mass.
// It simulates the distortion of a grid by a gravitational well.
vec3 warpSpace(vec3 p, vec3 massPos) {
    vec3 toMass = massPos - p;
    float dist = length(toMass);
    // Strength follows an inverse square law: $1/d^2$. 
    // This is the mathematical basis for Newtonian gravity.
    float strength = 1.2 / (dist * dist + 0.2);
    // Displace the point 'p' toward the mass based on the calculated strength.
    return p + normalize(toMass) * strength;
}

// --- Scene Mapping (SDF) ---

float map(vec3 p) {
    vec3 massPos = getMassPos(iTime);
    
    // 1. Spacetime Grid
    // Apply a subtle "pulsing" expansion to the space
    float lambda = 0.03 * sin(iTime * 0.5);
    vec3 pGrid = p * (1.0 + lambda);
    
    // Warp the grid coordinates based on the mass position
    pGrid = warpSpace(pGrid, massPos);
    
    // Create a repeating 3D grid using the fract() function
    vec3 q = fract(pGrid) - 0.5;
    float thickness = 0.02;
    
    // Define the grid as three intersecting cylinders (X, Y, and Z axes)
    float gridX = length(q.yz) - thickness;
    float gridY = length(q.xz) - thickness;
    float gridZ = length(q.xy) - thickness;
    float grid = min(min(gridX, gridY), gridZ);
    
    // 2. The Gravitating Body
    // A simple sphere representing the source of the gravity
    float massSphere = length(p - massPos) - 0.3;
    
    // Return the union (minimum) of the grid and the sphere
    return min(grid, massSphere);
}

// --- Raymarching Engine ---

float raymarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i=0; i<128; i++) {
        vec3 p = ro + rd * dO;
        float dS = map(p);
        dO += dS;
        if(dO > 30.0 || dS < 0.001) break;
    }
    return dO;
}

// Finite difference method to calculate surface normals for lighting
vec3 getNormal(vec3 p) {
    float d = map(p);
    vec2 e = vec2(0.005, 0.0);
    vec3 n = d - vec3(
        map(p-e.xyy),
        map(p-e.yxy),
        map(p-e.yyx));
    return normalize(n);
}

// --- Main Pipeline ---

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalizing screen coordinates
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // 1. Camera Setup
    float camTime = iTime * 0.2;
    vec3 ro = vec3(5.0 * sin(camTime), 3.0, 5.0 * cos(camTime)); // Camera orbits the scene
    vec3 lookAt = vec3(0.0, 0.0, 0.0);
    
    // Build View Matrix
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x*r + uv.y*u);

    // 2. Rendering logic
    float d = raymarch(ro, rd);
    vec3 col = vec3(0.01, 0.02, 0.05); // Deep space background color
    
    if(d < 30.0) {
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 massPos = getMassPos(iTime);
        float distToMass = length(p - massPos);
        
        // Basic diffuse lighting
        vec3 lightDir = normalize(vec3(1.0, 2.0, -1.0));
        float diff = max(dot(n, lightDir), 0.1);
        
        // Determine object color: Blue for the grid, Beige for the mass
        vec3 objCol = vec3(0.1, 0.6, 0.9) * diff;
        if(distToMass < 0.31) {
            objCol = vec3(1.0, 0.9, 0.7);
        }
        
        // Volumetric Glow: Intensifies near the mass
        float energyGlow = 1.5 / (distToMass * distToMass * 5.0 + 0.1);
        objCol += vec3(1.0, 0.6, 0.2) * energyGlow;
        
        // Distance fog: Fades objects into the dark background
        col = mix(objCol, col, 1.0 - exp(-0.05 * d));
    }
    
    // Gamma correction
    col = pow(col, vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
