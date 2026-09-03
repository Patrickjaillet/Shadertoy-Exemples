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

float amount = 0.005;
vec3 col;
col.r = texture(iChannel0, uv + vec2(amount, 0)).r;
col.g = texture(iChannel0, uv).g;
col.b = texture(iChannel0, uv - vec2(amount, 0)).b;

vec3 bloom = vec3(0);
for(float i = -2.0; i <= 2.0; i++) {
    for(float j = -2.0; j <= 2.0; j++) {
        bloom += texture(iChannel0, uv + vec2(i, j) * 0.005).rgb;
    }
}
col += (bloom / 25.0) * 0.4;

col = ACESFilm(col * 0.8);

float r = length(uv - 0.5);
col *= smoothstep(0.8, 0.2, r);

float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
col += (noise - 0.5) * 0.02;

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

float sdBox(vec3 p, vec3 b) {
vec3 q = abs(p) - b;
return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float shape1(vec3 p) {
float d = sdBox(p, vec3(1.));
float s = 1.;
for(int i = 0; i < 3; i++) {
vec3 a = mod(p * s, 2.) - 1.;
s *= 3.;
vec3 r = abs(1. - 3. * abs(a));
d = max(d, (min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x))) - 1.) / s);
}
return d;
}

float shape2(vec3 p) {
float s = 1.2;
for(int i = 0; i < 6; i++) {
p = abs(p) - 0.5;
p.xy *= rot(0.5);
p.xz *= rot(0.2);
p = p * 1.6 - 0.3;
s *= 1.6;
}
return length(p) / s;
}

float shape3(vec3 p) {
float d = length(p) - 1.2;
for(int i=0; i<4; i++) {
p = abs(p) - 0.4;
p.xy *= rot(iTime * 0.1);
d = min(d, sdBox(p, vec3(0.2, 0.8, 0.2)));
}
return d;
}

float shape4(vec3 p) {
p = mod(p + 1.0, 2.0) - 1.0;
return length(p) - 0.4;
}

float map(vec3 p) {
float loopTime = mod(iTime, 120.0);
float mCycle = loopTime / 3.0;
int id = int(mod(floor(mCycle), 4.0));
float f = smoothstep(0.0, 1.0, fract(mCycle));

float d1, d2;
if(id == 0) { d1 = shape1(p); d2 = shape2(p); }
else if(id == 1) { d1 = shape2(p); d2 = shape3(p); }
else if(id == 2) { d1 = shape3(p); d2 = shape4(p); }
else { d1 = shape4(p); d2 = shape1(p); }

return mix(d1, d2, f);
}

vec3 getCamPos(int id, float t) {
vec3 p;
float angle = t * 0.2;
if(id == 0) p = vec3(5. * cos(angle), 2, 5. * sin(angle));
else if(id == 1) p = vec3(3, 4, 3);
else if(id == 2) p = vec3(-4, 1, 5);
else if(id == 3) p = vec3(0.1, 7, 0.1);
else p = vec3(6, -2, 0);
return p;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
float t = iTime;
float loopTime = mod(t, 120.0);

float camCycle = loopTime / 5.0;
int cId1 = int(mod(floor(camCycle), 5.0));
int cId2 = int(mod(floor(camCycle) + 1.0, 5.0));
float f = smoothstep(0.1, 0.9, fract(camCycle));

vec3 ro = mix(getCamPos(cId1, t), getCamPos(cId2, t), f);
vec3 ta = vec3(0, 0, 0);
vec3 fw = normalize(ta - ro);
vec3 ri = normalize(cross(vec3(0, 1, 0), fw));
vec3 up = cross(fw, ri);
vec3 rd = normalize(fw + uv.x * ri + uv.y * up);

float d = 0.0, obj;
vec3 col = vec3(0);
for(int i = 0; i < 70; i++) {
    vec3 p = ro + rd * d;
    obj = map(p);
    if(obj < 0.001 || d > 25.0) break;
    d += obj;
    col += (0.5 + 0.5 * cos(d * 0.2 + vec3(0, 2, 4))) * 0.012 / (obj + 0.04);
}

fragColor = vec4(col, d);
}
