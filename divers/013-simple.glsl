// ==== Image (image) ====
#define MAX_STEPS 200
#define MAX_DIST 60.
#define SURF_DIST .0005
#define PI 3.14159265359
#define ACES(x) (x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14)

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdFractal(vec3 p) {
    float s = 1.0;
    for(int i = 0; i < 3; i++) {
        p = abs(p) - 1.2;
        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;
        p *= 1.8;
        s *= 1.8;
        p.z -= 0.5 * (s - 1.0);
    }
    return (length(p) - 1.5) / s;
}

float sdGyroid(vec3 p, float scale) {
    return abs(dot(sin(p * scale), cos(p.zxy * scale))) / scale - 0.02;
}

float map(vec3 p) {
    float time = iTime * 0.4;
    
    float r = length(p);
    float horizon = 0.8;
    if(r < horizon + 0.1) return 0.1; 
    
    float distortion = 1.0 + 0.15 * sin(r * 0.8 - time * 2.0);
    p /= distortion; 
    
    vec3 p1 = p;
    p1.xz *= rot(time * 0.5);
    p1.yz *= rot(time * 0.3);

    float m = clamp(sin(time * 0.5) * 0.5 + 0.5, 0.0, 1.0);
    
    float d1 = sdFractal(p1);
    float d2 = sdGyroid(p1, 3.5 + 1.5 * sin(time * 0.7));
    float d3 = (length(p1) - 2.8);
    
    float shape = mix(d1, d2, m);
    
    float k = 0.8 * (1.0 - 0.4 * m); 
    float res = smin(shape, d3, k);
    
    return res * 0.5 * distortion;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0005, 0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float weight = 1.0;
    for(int i = 1; i <= 10; i++) {
        float d = float(i) * 0.12;
        occ += weight * (d - map(p + n * d));
        weight *= 0.45;
    }
    return clamp(1.0 - occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float hash = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    vec3 ro = vec3(0, 0, -18.0);
    vec3 rd = normalize(vec3(uv, 2.5));
    
    float l = length(uv);
    rd.xy *= rot(0.15 * exp(-l * 1.5) * sin(iTime * 0.5));

    float d, t = 0.01;
    for(int i = 0; i < MAX_STEPS; i++) {
        d = map(ro + rd * t);
        if(abs(d) < SURF_DIST || t > MAX_DIST) break;
        t += d;
    }
    
    vec3 col = vec3(0.002, 0.004, 0.012) * (1.2 - l);
    
    if(t < MAX_DIST) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 r = reflect(rd, n);
        float ao = getAO(p, n);
        
        float vel = dot(n, -rd); 
        vec3 blueShift = vec3(0.3, 0.7, 1.8) * pow(max(0.0, vel), 3.0);
        vec3 redShift = vec3(1.8, 0.4, 0.1) * pow(max(0.0, 1.0 - vel), 2.0);
        vec3 spectral = mix(redShift, blueShift, 0.5 + 0.5 * sin(iTime + length(p) * 0.2));
        
        vec3 lightPos = vec3(8.0, 12.0, -8.0);
        vec3 lDir = normalize(lightPos - p);
        float diff = max(dot(n, lDir), 0.0);
        float fresnel = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 5.0);
        float spec = pow(max(dot(r, lDir), 0.0), 64.0);
        
        col = spectral * (diff + 0.05) * ao;
        col += spec * ao * 1.5;
        col += spectral * fresnel * 3.5;
        col *= exp(-0.02 * t);
    }
    
    vec3 bloom = vec3(0);
    float weights = 0.0;
    for(float i = -3.0; i <= 3.0; i++) {
        float w = exp(-0.6 * i * i);
        bloom += col * w;
        weights += w;
    }
    col += (bloom / weights) * 0.35;

    col = ACES(col);
    col = pow(col, vec3(0.4545));
    col += (hash - 0.5) * 0.004;
    
    fragColor = vec4(col, 1.0);
}
