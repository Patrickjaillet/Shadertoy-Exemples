// ==== Image (image) ====
// ==========================================================
// NAME : TRON RIDER
// ==========================================================
// DESCRIPTION : A stylized 80s-inspired scene. Features a 
// procedural neon grid, distance-fog mountains, a hover-bike 
// with squash/stretch movement, and a volumetric "smoke" trail 
// that tracks the vehicle's historical path.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.001
#define PI 3.14159265

// Palette Constants
#define COL_SKY_TOP vec3(0.1, 0.0, 0.2)
#define COL_SKY_BOT vec3(0.4, 0.0, 0.4)
#define COL_GRID    vec3(0.0, 0.8, 1.0)
#define COL_SMOKE_START vec3(1.0, 0.4, 0.1)
#define COL_SMOKE_END vec3(0.5, 0.5, 0.6)

// --- Mathematical Utilities ---

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float hash13(vec3 p3) {
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// 3D Noise for terrain and smoke textures
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(hash13(i + vec3(0,0,0)), hash13(i + vec3(1,0,0)), f.x),
                   mix(hash13(i + vec3(0,1,0)), hash13(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(hash13(i + vec3(0,0,1)), hash13(i + vec3(1,0,1)), f.x),
                   mix(hash13(i + vec3(0,1,1)), hash13(i + vec3(1,1,1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    float amp = 0.5;
    for(int i=0; i<3; i++) {
        f += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }
    return f;
}

// Smooth minimum for blending bike parts and terrain
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// --- Animation Logic ---

// Calculates bike position based on time to create a swaying, floating motion
vec3 getBikePos(float t) {
    vec3 pos = vec3(0.0, 0.7 + sin(t*2.0)*0.05, 0.0);
    pos.x -= sin(t) * 1.5;
    return pos;
}

// --- Scene Mapping ---

float GetDist(vec3 p) {
    float ground = p.y;
    
    // Terrain Motion
    float speed = iTime * 20.0;
    vec2 pos = p.xz;
    pos.y += speed; 
    
    // Mountains: High-amplitude sine waves combined with low-poly noise
    float noiseVal = sin(pos.y * 0.1) * sin(pos.x * 0.1) * 2.0;
    noiseVal += sin(pos.y * 0.5) * 0.5;
    
    float mountains = -p.y + abs(p.x) * 0.3 + noiseVal;
    
    // Terrain: Blends ground with distant mountains
    float terrain = smin(ground, mountains + 3.0 - smoothstep(0.0, 15.0, abs(p.x))*5.0, 2.0);
    
    // Bike Geometry
    vec3 bikeP = p - getBikePos(iTime);
    bikeP.xy *= rot(sin(iTime) * 0.2);

    float box = sdBox(bikeP, vec3(0.4, 0.2, 1.0));
    float wheelF = sdBox(bikeP - vec3(0.0, -0.2, 0.8), vec3(0.15, 0.35, 0.4));
    float wheelB = sdBox(bikeP - vec3(0.0, -0.2, -0.8), vec3(0.15, 0.35, 0.4));
    
    float bike = smin(box, smin(wheelF, wheelB, 0.1), 0.1);
    
    return min(terrain, bike);
}

// --- Lighting & Effects ---

// Procedural sky with stars
vec3 GetSky(vec3 rd, vec2 uv) {
    vec3 col = mix(COL_SKY_BOT, COL_SKY_TOP, rd.y * 2.0 + 0.5);
    float stars = pow(random(rd.xy * 20.0), 100.0) * 0.8;
    col += vec3(stars);
    return col;
}

// Neon Grid: Created using fract() and anti-aliased using derivatives (fwidth)
vec3 GetGrid(vec3 p, vec3 n) {
    float speed = iTime * 20.0;
    vec2 coord = p.xz + vec2(0.0, speed);
    
    vec2 grid = abs(fract(coord * 0.5) - 0.5) / fwidth(coord * 0.5);
    float line = min(grid.x, grid.y);
    float gridMask = 1.0 - min(line, 1.0);
    
    float fade = exp(-length(p.xz) * 0.02); // Fade grid into distance
    float centerLine = 1.0 - smoothstep(0.0, 0.1, abs(p.x));
    
    return COL_GRID * (gridMask + centerLine * 0.5) * fade * 2.0;
}

// Finite differences Normal calculation
vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.01, 0);
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    return normalize(n);
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO > MAX_DIST || dS < SURF_DIST) break;
    }
    return dO;
}

// --- Main Pipeline ---

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 2.0, -6.0);
    vec3 lookAt = vec3(0.0, 1.0, 0.0);
    float zoom = 0.9;
    
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f * zoom + r * uv.x + u * uv.y);

    float dSolid = RayMarch(ro, rd);
    
    vec3 col = vec3(0.0);
    vec3 pSolid = ro + rd * dSolid;
    
    // 1. Solid Object Shading (Terrain & Bike)
    if(dSolid < MAX_DIST) {
        vec3 n = GetNormal(pSolid);
        vec3 rRef = reflect(rd, n);
        col = vec3(0.05, 0.0, 0.1);
        col += GetGrid(pSolid, n); // Neon Grid
        
        float fresnel = pow(1.0 + dot(rd, n), 4.0);
        col += vec3(0.2, 0.5, 1.0) * fresnel * 0.5;
        
        vec3 skyRef = GetSky(rRef, uv);
        float refMask = smoothstep(0.8, 1.0, n.y); 
        col += skyRef * refMask * 0.5;
        
        // Bike Material Details
        if (pSolid.y > 0.1 && abs(pSolid.x) < 2.0 && abs(pSolid.z) < 2.0) {
            col = vec3(0.1);
            float stripes = sin(pSolid.z * 10.0 + iTime*10.0);
            col += vec3(1.0, 0.5, 0.0) * step(0.9, stripes) * 2.0; // Neon stripes
            col += vec3(0.0, 1.0, 1.0) * step(0.8, n.x);
        }
        // Background fog
        col = mix(col, COL_SKY_BOT, 1.0 - exp(-dSolid * 0.015));
    } else {
        col = GetSky(rd, uv);
        dSolid = MAX_DIST;
    }
    
    // 2. VOLUMETRIC TRAIL LOGIC
    // We integrate along the ray to calculate smoke density.
    vec3 smokeAcc = vec3(0.0);
    float smokeOpac = 0.0;
    
    vec3 currentBikePos = getBikePos(iTime);
    float speed = 20.0;
    
    float t = 0.0; 
    for(int i=0; i<30; i++) {
        vec3 p = ro + rd * t;
        if(t > dSolid) break;
        
        // To make the trail follow the bike, we calculate where the bike WAS 
        // based on the ray's current Z position.
        float timeOffset = (currentBikePos.z - p.z) / speed;
        vec3 historicBikePos = getBikePos(iTime - timeOffset);
        
        vec3 trailPos = p - historicBikePos;
        
        // Define trail boundaries
        if (trailPos.z < -0.5 && trailPos.z > -25.0 && p.y < 2.0 && p.y > 0.0) {
             float distToCenter = length(trailPos.xy);
             float noiseVal = fbm(p * 1.5 + vec3(0.0, iTime*2.0, -iTime*5.0));
             
             // Trail radius increases with distance from the bike
             float radius = 0.2 + abs(trailPos.z) * 0.05;
             float density = smoothstep(radius, 0.0, distToCenter - noiseVal * 0.4);
             
             // Smooth falloff at trail ends
             density *= smoothstep(-25.0, 0.0, trailPos.z);
             density *= smoothstep(-0.5, -2.0, trailPos.z);
             
             if(density > 0.001) {
                 vec3 smokeCol = mix(COL_SMOKE_START, COL_SMOKE_END, abs(trailPos.z) / 25.0);
                 float stepDensity = density * 0.2;
                 smokeAcc += smokeCol * stepDensity * (1.0 - smokeOpac);
                 smokeOpac += stepDensity;
                 if (smokeOpac >= 1.0) break;
             }
        }
        t += 0.5; 
    }
    
    // Final composite: Background + Smoke
    col = col * (1.0 - smokeOpac) + smokeAcc * 1.5;

    // Post-Processing
    col = col * 0.6 + 0.4 * col * col * (3.0 - 2.0 * col); // Contrast
    col *= 1.0 - dot(uv, uv) * 0.4; // Vignette
    col = pow(col, vec3(0.4545)); // Gamma Correction
    
    fragColor = vec4(col, 1.0);
}
