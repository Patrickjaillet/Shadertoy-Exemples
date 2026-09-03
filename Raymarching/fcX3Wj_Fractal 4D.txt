// ==== Image (image) ====
// =======================================
// Credits : Patrick JAILLET - https://openshader.xo.je
// =======================================
vec3 ACESFilm(vec3 x) {
float a = 2.51;
float b = 0.03;
float c = 2.43;
float d = 0.59;
float e = 0.14;
return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = fragCoord / iResolution.xy;
vec2 dist = (uv - 0.5);

vec3 col;
col.r = texture(iChannel0, uv - dist * 0.01).r;
col.g = texture(iChannel0, uv).g;
col.b = texture(iChannel0, uv + dist * 0.01).b;

vec3 bloom = vec3(0.0);
for(float i = -1.0; i <= 1.0; i++) {
    for(float j = -1.0; j <= 1.0; j++) {
        bloom += texture(iChannel0, uv + vec2(i, j) * 0.004).rgb;
    }
}
col += (bloom / 9.0) * 0.4;

col = ACESFilm(col * 1.2);
col = pow(col, vec3(0.95)); 

col *= smoothstep(1.3, 0.4, length(dist));
float grain = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
col += (grain - 0.5) * 0.02;

fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// =======================================
// Credits : Patrick JAILLET - https://openshader.xo.je
// =======================================
mat2 rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

// Bruit 3D simplifié pour les éclairs
float hash(vec3 p) {
p = fract(p * 0.1031);
p += dot(p, p.yzx + 33.33);
return fract((p.x + p.y) * p.z);
}

float noise(vec3 p) {
vec3 i = floor(p);
vec3 f = fract(p);
f = f * f * (3.0 - 2.0 * f);
return mix(mix(mix(hash(i + vec3(0, 0, 0)), hash(i + vec3(1, 0, 0)), f.x),
mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x),
mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
float v = 0.0;
float a = 0.5;
mat3 m = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
for(int i = 0; i < 4; i++) {
v += a * noise(p);
p = m * p * 2.02;
a *= 0.5;
}
return v;
}

// Champ stellaire multicouche
vec3 starField(vec3 rd, float warp) {
vec3 col = vec3(0.0);
for(float i = 0.0; i < 3.0; i++) {
vec3 p = rd * (150.0 + i * 100.0);
vec3 ip = floor(p);
vec3 fp = fract(p);
float h = hash(ip); // hash simplifié suffit ici
if(h > 0.98) {
float twinkle = sin(iTime * (1.0 + h) + h * 100.0) * 0.5 + 0.5;
float d = length(fp - 0.5);
// Étirement radial des étoiles (Motion Blur spatial)
float star = 0.002 / (d * d + 0.0005 / (1.0 + warp * 120.0));
vec3 starCol = mix(vec3(0.6, 0.8, 1.0), vec3(1.0, 0.9, 0.7), h);
col += star * starCol * twinkle * pow(h, 20.0) * 2.5;
}
}
return col;
}

// Distance Field Fractal 4D
float map(vec3 p) {
float transition = 0.5 + 0.5 * sin(iTime * 0.3);
vec4 z = vec4(p, 0.0);
vec4 cJulia = vec4(-0.21, 0.62, 0.21, 0.15) + 0.03 * cos(iTime * 0.4 + vec4(0, 1, 2, 3));
vec4 cMandel = vec4(p, 0.0);
vec4 c = mix(cMandel, cJulia, transition);
float dz2 = 1.0;
float m2 = 0.0;
for(int i = 0; i < 16; i++) {
dz2 *= 4.0 * dot(z, z);
z = vec4(z.x * z.x - dot(z.yzw, z.yzw), 2.0 * z.x * z.yzw) + c;
m2 = dot(z, z);
if(m2 > 4.0) break;
}
return 0.25 * sqrt(m2 / dz2) * log(m2);
}

// Normales de surface
vec3 calcNormal(vec3 p) {
vec2 e = vec2(0.0005, 0.0);
return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy), map(p + e.yyx) - map(p - e.yyx)));
}

// Moteur de rendu principal (Raymarching)
vec3 renderScene(vec3 ro, vec3 rd, float t_max, vec3 sky, float warp) {
float t = 0.0, d;
float glow = 0.0, vol = 0.0, lightning = 0.0;

for(int i = 0; i < 90; i++) {
    vec3 p = ro + rd * t;
    d = map(p);
    glow += 0.01 / (0.01 + d * d);
    vol += exp(-d * 4.0) * 0.02; 
    
    // Accumulation des éclairs près de la surface pendant le Warp
    if(warp > 0.1) {
        float n = fbm(p * 8.0 + iTime * 20.0);
        lightning += exp(-d * 20.0) * pow(max(0.0, n - 0.3), 2.0) * 0.15;
    }
    
    if(d < 0.0005 || t > t_max) break;
    t += d * 0.9;
}

vec3 stars = starField(rd, warp);
vec3 col = vec3(0.0);
vec3 li = normalize(vec3(1.0, 2.0, 1.0));

if(t < t_max) {
    vec3 p = ro + rd * t;
    vec3 nor = calcNormal(p);
    vec3 baseCol = 0.5 + 0.5 * cos(iTime * 0.2 + vec3(0, 2, 4));
    float dif = clamp(dot(nor, li), 0.0, 1.0);
    float fre = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 4.0);
    col = baseCol * (dif + 0.1);
    col += vec3(1.0, 0.8, 0.6) * fre * 0.5;
} else {
    col = sky + stars;
}

// Application des effets atmosphériques
col = mix(col, sky + stars, 1.0 - exp(-0.15 * t)); // Distance Fog
col += vec3(0.3, 0.5, 1.0) * vol * (0.2 + warp * 4.0); // Volumetric Glow
col += glow * 0.001 * (0.5 + 0.5 * cos(iTime * 0.5 + vec3(0, 2, 5))); // Fractal Glow

// Application des éclairs bleutés pendant le Warp
col += vec3(0.5, 0.8, 1.0) * lightning * warp * 10.0;

return col;
}

// Système de caméras multi-positions
vec3 getCamPos(int id) {
float t = iTime;
if(id == 0) return vec3(4.8 * cos(t * 0.1), 1.8, 4.8 * sin(t * 0.1));
if(id == 1) return vec3(2.5, 3.5, 2.5);
if(id == 2) return vec3(-4.5, 1.2, 1.5);
if(id == 3) return vec3(1.0, 0.5, 4.5);
if(id == 4) return vec3(3.5, -0.5, -3.5);
return vec3(0.5, 5.0, 0.5);
}

// Calcul de l'image (Main)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
float t = iTime;
float cycle = t / 5.0;
int id1 = int(mod(floor(cycle), 6.0));
int id2 = int(mod(floor(cycle) + 1.0, 6.0));
float f = fract(cycle);

// Warp intensifié par une courbe de puissance 12
float warp = pow(sin(f * 3.14159), 12.0);
float interp = smoothstep(0.0, 1.0, f);

vec3 ro = mix(getCamPos(id1), getCamPos(id2), interp);
vec3 ta = vec3(0.0, -0.1, 0.0);
vec3 cw = normalize(ta - ro);
vec3 cu = normalize(cross(cw, vec3(0, 1, 0)));
vec3 cv = normalize(cross(cu, cw));

// Effet Vertigo : Le FOV change mais la caméra compense
float zoom = 1.5 + warp * 2.5;
// Distorsion de lentille sphérique (Fisheye dynamique)
float r2 = dot(uv, uv);
vec2 dUv = uv * (1.0 + r2 * warp * 1.5);

vec3 rd = normalize(dUv.x * cu + dUv.y * cv + zoom * cw);

vec3 sky = vec3(0.002, 0.005, 0.01);
vec3 col = renderScene(ro, rd, 20.0, sky, warp);

// Chromatic Bang pendant le Warp
col.rb *= 1.0 + warp * 0.5;
col += vec3(0.5, 0.7, 1.0) * warp * 0.4;

fragColor = vec4(col, 1.0);
}
