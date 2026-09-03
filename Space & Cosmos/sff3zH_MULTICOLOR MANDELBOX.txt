// ==== Image (image) ====
#define MAX_STEPS 128
#define MAX_DIST 40.0
#define SURF_DIST 0.001

// --- Mathematical Tools ---

mat2 Rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

// Fixed Box Fold with explicit vec3 bounds
void boxFold(inout vec3 v) {
v = clamp(v, vec3(-1.0), vec3(1.0)) * 2.0 - v;
}

// Sphere Fold logic
void sphereFold(inout vec3 v, inout float f) {
float r2 = dot(v, v);
if (r2 < 0.5) {
v *= 2.0;
f *= 2.0;
} else if (r2 < 1.0) {
v /= r2;
f /= r2;
}
}

float gTrap = 0.0;

// Mandelbox Distance Estimator
float GetDist(vec3 p) {
vec3 offset = p;
float dr = 1.0;
float scale = 2.4;
float trap = 1e10;

for (int i = 0; i < 12; i++) {
    boxFold(p);       
    sphereFold(p, dr); 
    
    p = p * scale + offset; 
    dr = dr * abs(scale) + 1.0;
    
    trap = min(trap, dot(p, p));
}

gTrap = trap;
return length(p) / abs(dr);
}

// --- Rendering Engine ---

float RayMarch(vec3 ro, vec3 rd) {
float dO = 0.0;
for (int i = 0; i < MAX_STEPS; i++) {
vec3 p = ro + rd * dO;
float dS = GetDist(p);
dO += dS;
if (dO > MAX_DIST || abs(dS) < SURF_DIST) break;
}
return dO;
}

vec3 GetNormal(vec3 p) {
float d = GetDist(p);
vec2 e = vec2(0.005, 0);
vec3 n = d - vec3(
GetDist(p - e.xyy),
GetDist(p - e.yxy),
GetDist(p - e.yyx));
return normalize(n);
}

vec3 GetPalette(float t) {
vec3 a = vec3(0.5, 0.5, 0.5);
vec3 b = vec3(0.5, 0.5, 0.5);
vec3 c = vec3(1.0, 0.7, 0.4);
vec3 d = vec3(0.0, 0.15, 0.20);
return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
vec2 mo = iMouse.xy / iResolution.xy;

// Interactive Camera
float yaw = (iMouse.z > 0.0) ? mo.x * 6.28 : iTime * 0.15;
float dist = (iMouse.z > 0.0) ? 5.0 + mo.y * 15.0 : 12.0;

vec3 ro = vec3(dist * cos(yaw), 2.0 * sin(iTime * 0.2), dist * sin(yaw));
vec3 lookat = vec3(0, 0, 0);

vec3 f = normalize(lookat - ro);
vec3 r = normalize(cross(vec3(0, 1, 0), f));
vec3 u = cross(f, r);
vec3 rd = normalize(f + uv.x * r + uv.y * u);

float d = RayMarch(ro, rd);
vec3 col = vec3(0.005, 0.008, 0.012); 

if (d < MAX_DIST) {
    vec3 p = ro + rd * d;
    vec3 n = GetNormal(p);
    vec3 l = normalize(vec3(5, 10, 5) - p);
    
    float diff = clamp(dot(n, l), 0.0, 1.0);
    float ao = clamp(1.0 - d / MAX_DIST, 0.0, 1.0);
    
    float trapVal = log(gTrap + 1.0) * 0.1;
    vec3 baseCol = GetPalette(trapVal + d * 0.05);
    
    col = baseCol * diff + (baseCol * 0.2);
    col *= ao;
    col = mix(col, vec3(0.005, 0.008, 0.012), 1.0 - exp(-0.05 * d));
}

col = pow(col, vec3(0.4545));
col *= 1.0 - length(uv) * 0.5;

fragColor = vec4(col, 1.0);
}
