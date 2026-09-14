// ==== Image (image) ====
// https://github.com/Patrickjaillet/Z-GL

#define ITERATIONS 6
#define MAX_STEPS 80
#define SURF_DIST 0.002
#define MAX_DIST 80.

float g_glow = 0.0;
vec3 g_orbit = vec3(0.0);

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 palette(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (vec3(1.0, 1.0, 1.0) * t + vec3(0.26, 0.41, 0.55)));
}

float mandelbox(vec3 p) {
    vec3 p0 = p;
    float s = 1.0;
    g_orbit = vec3(0.0);
    for (int i = 0; i < ITERATIONS; i++) {
        p = clamp(p, -1.0, 1.0) * 2.0 - p;
        float r2 = dot(p, p);
        float k = max(1.15 / clamp(r2, 0.12, 1.0), 0.15);
        p *= k;
        s *= k;
        p += p0;
        if(i < 4) g_orbit += abs(p);
    }
    return (length(p) - 0.05) / s;
}

float map(vec3 p) {
    p.z += iTime * 0.8;
    vec3 p_inf = p;
    p_inf.z = mod(p.z, 18.0) - 9.0;
    p_inf.xy *= rot(p.z * 0.05);

    float d = mandelbox(p_inf / 3.5) * 3.5;
    float tunnels = length(p_inf.xy) - 5.8;
    d = max(d, -tunnels);
    
    g_glow += 0.015 / (0.02 + d * d);
    return d;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.005, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 4; i++) {
        float hr = 0.05 + 0.2 * float(i) / 3.0;
        float d = map(p + n * hr);
        occ += (hr - d) * sca;
        sca *= 0.8;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

vec3 render(vec2 uv) {
    float t = iTime * 2.0;
    vec3 ro = vec3(0.0, 0.0, t);
    vec3 target = vec3(sin(t * 0.1) * 2.0, cos(t * 0.1) * 2.0, t + 1.0);
    
    vec3 f = normalize(target - ro);
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(uv.x * r + uv.y * u + f * 1.2);

    float dO = 0.0;
    float dS;
    for (int i = 0; i < MAX_STEPS; i++) {
        dS = map(ro + rd * dO);
        if (abs(dS) < SURF_DIST * (1.0 + dO * 0.1) || dO > MAX_DIST) break;
        dO += dS * 1.1;
    }
    
    vec3 col = vec3(0.0);
    
    if (dO < MAX_DIST) {
        vec3 p = ro + rd * dO;
        vec3 n = getNormal(p);
        float ao = getAO(p, n);
        
        float depthLayer = floor(p.z / 18.0);
        vec3 mat = palette(depthLayer * 0.15 + length(g_orbit) * 0.02);
        
        float diff = max(dot(n, normalize(vec3(1, 2, -1))), 0.0);
        float fresnel = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 4.0);
        
        col = mat * diff + (0.1 * ao);
        col += fresnel * mat * 0.5;
        col *= ao;
        
        float fog = 1.0 - exp(-0.0004 * dO * dO);
        col = mix(col, vec3(0.005, 0.005, 0.01), fog);
    }
    
    vec3 glowCol = palette(floor((ro.z + rd.z * dO) / 18.0) * 0.15 + iTime * 0.05);
    col += glowCol * g_glow * 0.015;
    
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    g_glow = 0.0;
    
    vec3 col = render(uv);
    
    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
