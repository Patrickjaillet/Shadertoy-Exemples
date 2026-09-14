// ==== Image (image) ====
// ==========================================================
// NAME : MAXWELL'S ELECTROMAGNETIC PROPAG
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MAX_STEPS 100
#define SURF_DIST .001
#define MAX_DIST 50.

// --- Utilities ---
mat2 rot(float a) {
float s=sin(a), c=cos(a);
return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
vec3 q = abs(p) - b;
return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float gGlow = 0.0;

float GetDist(vec3 p) {
// 1. Floor
float d = p.y + 2.0;

// Wave Parameters: $\lambda = 10.0$
float wavelength = 10.0;
float k = 6.2831 / wavelength;
float phase = iTime * 5.0;

float zIndex = floor(p.z * 1.2);
float zPos = (zIndex + 0.5) / 1.2;
float amplitude = sin(k * zPos - phase) * 2.5;

// Electric Ribs (E) - Vertical
vec3 pE = p;
pE.z -= zPos;
float eField = sdBox(pE - vec3(0, amplitude*0.5, 0), vec3(0.02, abs(amplitude)*0.5, 0.02));

// Magnetic Ribs (B) - Horizontal
float bAmplitude = sin(k * zPos - phase) * 2.5;
vec3 pB = p;
pB.z -= zPos;
float bField = sdBox(pB - vec3(bAmplitude*0.5, 0, 0), vec3(abs(bAmplitude)*0.5, 0.02, 0.02));

float fields = min(eField, bField);
float core = length(p.xy) - 0.01;
fields = min(fields, core);

gGlow += 0.01 / (0.01 + fields * fields);

d = min(d, fields);
return d;
}

float RayMarch(vec3 ro, vec3 rd) {
float dO=0.0;
for(int i=0; i<MAX_STEPS; i++) {
vec3 p = ro + rd*dO;
float dS = GetDist(p);
dO += dS;
if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
}
return dO;
}

vec3 GetNormal(vec3 p) {
float d = GetDist(p);
vec2 e = vec2(.01, 0);
vec3 n = d - vec3(
GetDist(p-e.xyy),
GetDist(p-e.yxy),
GetDist(p-e.yyx));
return normalize(n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
vec2 mo = iMouse.xy / iResolution.xy;

gGlow = 0.0;

// --- NEW SIDE CAMERA LOGIC ---
float speed = iTime * 5.0;

// Side offset (12 units) and Elevation (6 units)
// The mouse still allows for rotation around this new base position
float yaw = (iMouse.z > 0.0) ? (mo.x - 0.5) * 2.0 : 0.0;
float pitch = (iMouse.z > 0.0) ? (mo.y - 0.5) * 5.0 : 0.0;

// Origin shifted to the side (X) and up (Y)
vec3 ro = vec3(12.0, 6.0 + pitch, speed - 2.0);
ro.xz *= rot(yaw); // Allow mouse to "pan" from the side view

// Look slightly ahead of the current wave front
vec3 lookat = vec3(0, 0, speed + 4.0);

vec3 f = normalize(lookat-ro);
vec3 r = normalize(cross(vec3(0,1,0), f));
vec3 u = cross(f,r);
vec3 rd = normalize(f + uv.x*r + uv.y*u);

float d = RayMarch(ro, rd);
vec3 col = vec3(0.005, 0.005, 0.01); 

if(d<MAX_DIST) {
    vec3 p = ro + rd * d;
    vec3 n = GetNormal(p);
    vec3 ref = reflect(rd, n);
    vec3 lp = vec3(0, 10, speed + 5.0);
    vec3 ld = normalize(lp - p);
    float dif = clamp(dot(n, ld), 0.0, 1.0);
    float spe = pow(max(0.0, dot(ref, ld)), 64.0);
    
    vec3 mat = vec3(0.05); 
    
    if(p.y < -1.99) {
        mat = vec3(0.01);
        float grid = smoothstep(0.48, 0.5, abs(fract(p.z * 0.5) - 0.5));
        grid += smoothstep(0.48, 0.5, abs(fract(p.x * 0.5) - 0.5));
        mat += grid * 0.03;
    } else if(abs(n.y) > 0.7) {
        mat = vec3(1.0, 0.7, 0.2); // Gold E-Field
    } else {
        mat = vec3(0.9, 0.9, 1.0); // Chrome B-Field
    }
    
    col = mat * dif + spe * mat;
}

col += gGlow * vec3(0.8, 0.4, 0.1) * 0.012;
col = mix(col, vec3(0.005, 0.005, 0.01), 1.0 - exp(-0.02 * d));

// Vignette & Gamma
float vign = smoothstep(1.6, 0.4, length(uv));
col *= vign;
col = pow(col, vec3(.4545));

fragColor = vec4(col, 1.0);
}
