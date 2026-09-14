// ==== Image (image) ====
// ==========================================================
// NAME : NAVIER-STOKES LAMINAR FLOW
//==========================================================
// This shader visualizes fluid streamlines derived from 
// simplified Navier-Stokes principles. It represents a 
// steady-state flow where the velocity field is warped by 
// submerged obstacles. The camera follows a central 
// streamline, passing through "pressure nodes" (holes) 
// where the fluid velocity is highest and the pressure 
// gradient allows for a clear passage.
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

// A simple divergence-free velocity field approximation
vec2 GetVelocity(vec3 p) {
    float flow = sin(p.z * 0.4 + iTime * 2.0);
    float eddy = cos(p.z * 0.2) * 1.5;
    return vec2(flow, eddy);
}

float GetDist(vec3 p) {
    // 1. The Laboratory Floor (Mahogany)
    float d = p.y + 3.0;
    
    // 2. Streamline Visualization (Brass Tubes)
    // We use a repetition of space and warp it based on a "flow field"
    vec3 pStream = p;
    
    // Create grid of streamlines
    float gridScale = 4.0;
    vec2 id = floor(pStream.xy / gridScale);
    pStream.xy = mod(pStream.xy, gridScale) - gridScale * 0.5;
    
    // Warp the streamlines based on Z-position (simulating fluid displacement)
    vec2 vel = GetVelocity(p);
    pStream.xy += vel * 0.5;
    
    // Cylinder SDF for the tubes
    float tubes = length(pStream.xy) - 0.15;
    
    // 3. The "Holes" (Pressure Nodes)
    // We create a passage for the camera by clearing a cylinder 
    // where the pressure gradient is zero.
    float tunnel = length(p.xy - GetVelocity(p) * -0.5) - 2.0;
    tubes = max(tubes, -tunnel);
    
    d = min(d, tubes);
    
    // Safety multiplier to handle field warping
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
    
    // Camera Logic: Trajectory along the central streamline
    float speed = iTime * 6.0;
    vec3 ro = vec3(0.0, 0.0, speed);
    
    // Compensate for the flow field warp to stay in the "hole"
    vec2 camWarp = GetVelocity(ro) * -0.5;
    ro.xy += camWarp;
    
    // Look ahead logic
    vec3 lookTarget = vec3(0.0, 0.0, speed + 2.0);
    lookTarget.xy += GetVelocity(lookTarget) * -0.5;
    
    vec3 f = normalize(lookTarget - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float d = RayMarch(ro, rd);
    vec3 col = vec3(0.02, 0.015, 0.01); // Dark Room
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        
        vec3 lp = vec3(2.0, 10.0, speed + 5.0);
        float dif = clamp(dot(n, normalize(lp - p)), 0.0, 1.0);
        
        // Materials: Polished Brass and Mahogany
        vec3 mat = vec3(0.8, 0.6, 0.2); // Brass Streamlines
        if(p.y < -2.9) {
            mat = vec3(0.15, 0.05, 0.02); // Dark Wood Floor
        }
        
        col = mat * (dif + 0.1);
        
        // Specular for a "wet" fluid look on the brass
        vec3 ref = reflect(rd, n);
        float spec = pow(max(0.0, dot(ref, normalize(lp - p))), 32.0);
        col += spec * 0.4;
        
        // Fog for depth
        col = mix(col, vec3(0.02, 0.015, 0.01), 1.0 - exp(-0.02 * d));
    }

    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}
