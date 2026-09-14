// ==== Image (image) ====
// =======================================
// Credits : Patrick JAILLET - https://openshader.xo.je
// =======================================
vec3 ACESFilm(vec3 x) {
return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = fragCoord / iResolution.xy;

float chrom = 0.004;
vec3 col;
col.r = texture(iChannel0, uv + vec2(chrom, 0)).r;
col.g = texture(iChannel0, uv).g;
col.b = texture(iChannel0, uv - vec2(chrom, 0)).b;

vec3 bloom = vec3(0);
for(float x = -3.0; x <= 3.0; x++) {
    for(float y = -3.0; y <= 3.0; y++) {
        bloom += texture(iChannel0, uv + vec2(x, y) * 0.004).rgb;
    }
}
col += (bloom / 49.0) * 0.5;

col = ACESFilm(col * 1.2);

vec2 vuv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
col *= smoothstep(1.2, 0.4, length(vuv));

float grain = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
col += (grain - 0.5) * 0.04;

fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// =======================================
// Cinematic Multi-Cam Engine
// =======================================
// Système à 5 caméras avec transitions fluides et moteur de rendu fractal.
// =======================================
// Credits : Patrick JAILLET - https://openshader.xo.je
// =======================================
mat2 rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

float map(vec3 p) {
float s = 1.0;
for(int i = 0; i < 5; i++) {
p = abs(p) - 0.6;
p.xy *= rot(0.5);
p.yz *= rot(0.3);
p -= dot(cos(p * s * 3.0), vec3(0.02)) / s;
p += sin(p.yzx * 0.5) * 0.3;
s *= 1.5;
}
return length(p.yx) - 0.05;
}

vec3 getCamPos(int id, float t) {
if(id == 0) return vec3(0, 0, 6);
if(id == 1) return vec3(5, 2, 5);
if(id == 2) return vec3(-4, -3, 4);
if(id == 3) return vec3(0.1, 6, 0.1);
if(id == 4) return vec3(6, 0, -2);
return vec3(0, 0, 5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
float t = iTime;

float cycle = t / 5.0;
int id1 = int(mod(floor(cycle), 5.0));
int id2 = int(mod(floor(cycle) + 1.0, 5.0));
float f = smoothstep(0.0, 1.0, fract(cycle));

vec3 cam1 = getCamPos(id1, t);
vec3 cam2 = getCamPos(id2, t);
vec3 ro = mix(cam1, cam2, f);
vec3 ta = vec3(0, 0, 0);

vec3 fw = normalize(ta - ro);
vec3 ri = normalize(cross(vec3(0, 1, 0), fw));
vec3 up = cross(fw, ri);
vec3 rd = normalize(fw + uv.x * ri + uv.y * up);

float d = 0.0, obj;
vec3 col = vec3(0);
for(int i = 0; i < 80; i++) {
    vec3 p = ro + rd * d;
    obj = map(p);
    if(obj < 0.001 || d > 20.0) break;
    d += obj * 0.7;
    col += (0.6 + 0.4 * cos(d * 0.5 + vec3(0, 1, 2))) * 0.012 / (obj + 0.01);
}

fragColor = vec4(col, d);
}
