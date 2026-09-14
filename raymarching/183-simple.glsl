// ==== Image (image) ====
mat2 rot(float a) {
float s = sin(a), c = cos(a);
return mat2(c, -s, s, c);
}

float sdSegment(vec3 p, vec3 a, vec3 b) {
vec3 pa = p - a, ba = b - a;
return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0., 1.));
}

void addLine(inout float d, vec3 p, vec3 a, vec3 b) {
d = min(d, sdSegment(p, a, b));
}

void drawFaceDetails(inout float d, vec3 p, vec3 v0, vec3 v1, vec3 v2, vec3 v3, bool isPyramid) {
vec3 c = (v0 + v1 + v2 + v3) * .25;

if (isPyramid) {
    vec3 n = normalize(cross(v1 - v0, v2 - v0)) * .6 + c;
    for(int i = 0; i < 4; i++) 
        addLine(d, p, i == 0 ? v0 : i == 1 ? v1 : i == 2 ? v2 : v3, n);
} else {
    vec3 right = normalize(v1 - v0), up = normalize(v3 - v0), lastPt, pt;
    for (int i = 0; i < 10; i++) {
        float a = float(i) * 1.256637, r = (i % 2 == 0) ? .35 : .14;
        pt = c + (right * cos(a) + up * sin(a)) * r;
        if (i > 0) addLine(d, p, lastPt, pt);
        lastPt = pt;
    }
}
}

float sceneSDF(vec3 p) {
float t = iTime * 1.2;
p.xz *= rot(t * .7);
p.xy *= rot(t * .9);
p.yz *= rot(t * .5);

vec3 v[8], a = vec3(.6);
for (int i = 0; i < 8; i++)
    v[i] = a * vec3((i & 1) != 0 ? 1. : -1., (i & 2) != 0 ? 1. : -1., (i & 4) != 0 ? 1. : -1.);

float d = 1e5;

for (int i = 0; i < 4; i++) {
    addLine(d, p, v[i], v[(i + 1) % 4]);
    addLine(d, p, v[i + 4], v[(i + 1) % 4 + 4]);
    addLine(d, p, v[i], v[i + 4]);
}

drawFaceDetails(d, p, v[0], v[1], v[2], v[3], false);
drawFaceDetails(d, p, v[5], v[4], v[7], v[6], false);
drawFaceDetails(d, p, v[4], v[0], v[3], v[7], true);
drawFaceDetails(d, p, v[1], v[5], v[6], v[2], true);
drawFaceDetails(d, p, v[3], v[2], v[6], v[7], false);
drawFaceDetails(d, p, v[4], v[5], v[1], v[0], true);

return d - .008;
}

void mainImage(out vec4 O, vec2 U) {
vec2 uv = (U - .5 * iResolution.xy) / iResolution.y;

vec3 ro = vec3(0, 0, -3.2), rd = normalize(vec3(uv, 1));

float t = 0., minDist = 1e5;

for (int i = 0; i < 64; i++) {
    float d = sceneSDF(ro + rd * t);
    minDist = min(minDist, d);
    if (d < .001 || t > 10.) break;
    t += d * .5;
}

vec3 col = ( .5 + .5 * cos(iTime * 2. + uv.xyx * 2. + vec3(0, 2, 4)) ) * exp(-minDist * 18.) * 1.2;

if (minDist < .01) col += smoothstep(.01, .001, minDist);

O = vec4(col, 1);
}
