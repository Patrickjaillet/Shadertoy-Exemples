// ==== Image (image) ====
#define R iResolution.xy
#define T iTime
#define M iMouse
#define MAX_STEPS 160
#define SURF_DIST 0.001
#define MAX_DIST 50.0

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    float s1 = 0.5 + 0.5 * sin(T * 0.4);
    float s2 = 0.5 + 0.5 * cos(T * 0.3);
    float warp = 1.0 + 0.3 * sin(p.z * 0.05 + T);
    p.xy *= rot(p.z * 0.02 * warp * s2);
    
    float scale = 1.0;
    for(int i = 0; i < 6; i++) {
        p.xy = abs(p.xy) - vec2(1.0, 1.5) * warp;
        p.xy *= rot(0.2 + s1 * 0.3);
        float s = 1.6 / clamp(dot(p.xy, p.xy), 0.25, 1.6);
        p.xy *= s;
        scale *= s;
    }
    
    float geom = (length(p.xy) - 0.18) / scale;
    float tunnel = -(length(p.xy) - 4.8 * warp);
    return max(geom, tunnel * 0.5);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.002, 0.0);
    return normalize(vec3(map(p+e.xyy)-map(p-e.xyy),
                          map(p+e.yxy)-map(p-e.yxy),
                          map(p+e.yyx)-map(p-e.yyx)));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        float dd = map(p + n * hr);
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

vec3 getPal(float t, float var) {
    vec3 c1 = vec3(0.95, 0.05, 0.4);
    vec3 c2 = vec3(0.05, 0.75, 1.0);
    vec3 c3 = vec3(0.4, 0.1, 0.9);
    float m = 0.5 + 0.5 * sin(t * 0.15 + var);
    return mix(mix(c1, c2, m), c3, 0.5 + 0.5 * cos(t * 0.25));
}

vec3 ace(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * R) / iResolution.y;
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    vec3 ro = vec3(0, 0, -4.5);
    vec3 rd = normalize(vec3(uv, 1.1));
    rd.xy *= rot(sin(T * 0.1) * 0.1);
    
    float t = 0.0 + 0.02 * dither, d;
    float glow = 0.0;
    float cloud = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        if(abs(d) < SURF_DIST || t > MAX_DIST) break;
        glow += exp(-d * 3.5) * (0.04 + 0.01 * sin(T + t));
        cloud += exp(-abs(d) * 1.5) * 0.02;
        t += d * 0.75;
    }
    
    vec3 col = vec3(0.005, 0.0, 0.01);
    
    if(t < MAX_DIST) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        float ao = getAO(p, n);
        float rim = pow(1.0 - max(dot(n, -rd), 0.0), 3.5);
        float diff = max(dot(n, normalize(vec3(1, 2, -1))), 0.0) * 0.5;
        
        vec3 base = getPal(p.z + T * 1.5, rim);
        col = base * (diff + 0.1) * ao;
        col += base * rim * 3.0 * ao;
        col = mix(col, vec3(0.01, 0.005, 0.02), 1.0 - exp(-0.035 * t));
    }
    
    col += getPal(T * 0.5, 0.0) * glow * 0.45;
    col += getPal(T * 0.8, 1.0) * cloud * 0.12;

    float r = length(uv);
    for(float i = 0.0; i < 6.0; i++) {
        float angle = i * 1.047;
        vec2 dir = vec2(cos(angle), sin(angle));
        float burst = 0.01 / (abs(dot(uv, dir)) + 0.02);
        col += getPal(T, i) * burst * 0.05 * exp(-r * 2.0);
    }
    
    col = ace(col * 1.8);
    col = pow(col, vec3(0.4545));
    
    float vign = smoothstep(1.4, 0.35, r);
    col *= vign;
    col += (dither - 0.5) * 0.008;

    fragColor = vec4(col, 1.0);
}
