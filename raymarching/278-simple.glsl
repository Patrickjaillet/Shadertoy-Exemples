// ==== Image (image) ====
#define MAX_STEPS 100
#define SURF_DIST .001
#define MAX_DIST 20.

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return length(pa - ba*h) - r;
}

float getKey(int ascii) {
    return texelFetch(iChannel0, ivec2(ascii, 0), 0).x;
}

float GetDist(vec3 p, vec3 offset) {
    vec3 vertex = vec3(0) + offset;
    float d1 = sdCapsule(p, vertex, vec3(2, 4, 2), 0.025);
    float d2 = sdCapsule(p, vertex, vec3(-2, 4, 2), 0.025);
    float d3 = sdCapsule(p, vertex, vec3(0, 4, -3), 0.025);
    float lines = min(d1, min(d2, d3));
    float planeCycle = mod(iTime * 0.4, 2.0);
    float planes = 100.0;
    for(float i = 1.0; i <= 3.0; i++) {
        float h = i * 1.3 + planeCycle * 0.6;
        float thickness = 0.015;
        float pDist = abs(p.y - h) - thickness;
        float limit = length(p.xz - offset.xz) - (h * 0.65);
        pDist = max(pDist, limit);
        planes = min(planes, pDist);
    }
    return min(lines, planes);
}

float RayMarch(vec3 ro, vec3 rd, vec3 offset) {
    float dO=0.0;
    for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;
        float dS = GetDist(p, offset);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    return dO;
}

vec3 GetNormal(vec3 p, vec3 offset) {
    float d = GetDist(p, offset);
    vec2 e = vec2(.001, 0);
    vec3 n = d - vec3(
        GetDist(p-e.xyy, offset),
        GetDist(p-e.yxy, offset),
        GetDist(p-e.yyx, offset));
    return normalize(n);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;
    vec3 offset = vec3(0);
    offset.x += getKey(39) * 2.0; 
    offset.x -= getKey(37) * 2.0; 
    offset.z += getKey(38) * 2.0; 
    offset.z -= getKey(40) * 2.0; 
    vec3 ro = vec3(0, 4, -7);
    if(iMouse.z > 0.0) {
        ro.yz *= Rot(-m.y * 3.14 + 1.5);
        ro.xz *= Rot(-m.x * 6.28);
    } else {
        ro.xz *= Rot(iTime * 0.15);
    }
    vec3 lookat = vec3(0, 2.5, 0) + offset;
    vec3 f = normalize(lookat-ro);
    vec3 r = normalize(cross(vec3(0,1,0), f));
    vec3 u = cross(f,r);
    vec3 rd = normalize(f + uv.x*r + uv.y*u);
    vec3 col = vec3(0.96, 0.94, 0.90);
    float noise = fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
    col -= noise * 0.02;
    col *= 1.0 - dot(uv, uv) * 0.15;
    float d = RayMarch(ro, rd, offset);
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p, offset);
        vec3 ref = reflect(rd, n);
        vec3 lightPos = vec3(2, 5, -3);
        vec3 l = normalize(lightPos - p);
        float dif = clamp(dot(n, l), 0.0, 1.0);
        float spec = pow(max(0.0, dot(ref, l)), 32.0);
        vec3 material = vec3(0.85, 0.7, 0.3);
        col = material * (dif + 0.3) + spec * 0.6;
        col *= mix(0.8, 1.0, clamp(p.y / 5.0, 0.0, 1.0));
    }
    col = pow(col, vec3(.4545));
    fragColor = vec4(col, 1.0);
}
