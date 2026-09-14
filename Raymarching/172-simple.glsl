// ==== Image (image) ====
#define MENGER_ITER 4
#define JULIA_ITER 80
#define MAX_STEPS 100
#define SURF_DIST 0.001
#define MAX_DIST 25.0
#define SAMPLES 2

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * t + d + iTime * 0.1));
}

vec3 getIridescence(vec3 p, vec3 n, float t) {
    float d = dot(p, n) * 0.3 + t * 0.1;
    return 0.6 + 0.4 * cos(6.28318 * (d + vec3(0.1, 0.4, 0.7)));
}

vec3 getJuliaBackground(vec2 uv, float t) {
    vec2 c = vec2(-0.745 + sin(t * 0.2) * 0.1, 0.11 + cos(t * 0.3) * 0.1);
    vec2 z = uv * 1.5;
    float iter = 0.0;
    float m2 = 0.0;
    for(int i = 0; i < JULIA_ITER; i++) {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
        m2 = dot(z, z);
        if(m2 > 10.0) break;
        iter++;
    }
    if (iter >= float(JULIA_ITER)) return vec3(0.98, 0.98, 1.0);
    float dist = iter - log2(log2(m2)) + 4.0;
    return palette(dist * 0.05);
}

float sdMengerTorus(vec3 p, float t) {
    float r1 = 2.2; 
    float r2 = 0.58;
    float angle = atan(p.z, p.x);
    vec2 cp = vec2(length(p.xz) - r1, p.y);
    cp *= Rot(angle * 3.0 + t * 0.3); 
    vec3 q = vec3(cp, angle * r1);
    q += sin(q.zxy * 3.5 + t) * 0.05;
    float d = length(max(abs(q) - vec3(r2), 0.0));
    float s = 1.0;
    for (int i = 0; i < MENGER_ITER; i++) {
        vec3 a = mod(q * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float c = (min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x))) - 1.0) / s;
        d = max(d, c);
    }
    return d;
}

float GetDist(vec3 p, float t) {
    float d = sdMengerTorus(p, t);
    vec3 dp = p;
    dp.xz *= Rot(t * 0.1);
    dp = mod(dp + 2.5, 5.0) - 2.5;
    return min(d, length(dp) - 0.04);
}

vec3 GetNormal(vec3 p, float t) {
    float d = GetDist(p, t);
    vec2 e = vec2(0.001, 0);
    return normalize(d - vec3(GetDist(p-e.xyy, t), GetDist(p-e.yxy, t), GetDist(p-e.yyx, t)));
}

vec3 render(vec2 uv, float t) {
    vec3 ro = vec3(6.5 * sin(t * 0.1), 2.5 * cos(t * 0.08), 6.5 * cos(t * 0.1));
    vec3 lookat = vec3(0, 0, 0);
    vec3 f = normalize(lookat - ro), r = normalize(cross(vec3(0,1,0), f)), u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float dO = 0.0;
    for(int i=0; i<MAX_STEPS; i++) {
        float dS = GetDist(ro + rd * dO, t);
        if(abs(dS) < SURF_DIST || dO > MAX_DIST) break;
        dO += dS * 0.75;
    }

    vec3 col = getJuliaBackground(uv, t);

    if(dO < MAX_DIST) {
        vec3 p = ro + rd * dO;
        vec3 n = GetNormal(p, t);
        vec3 refR = reflect(rd, n);
        
        float dRef = 0.0;
        for(int i=0; i<40; i++) {
            float dS = GetDist((p + n * 0.01) + refR * dRef, t);
            if(abs(dS) < SURF_DIST || dRef > 5.0) break;
            dRef += dS;
        }
        
        vec3 refCol = getJuliaBackground(uv + refR.xy * 0.15, t);
        if(dRef < 5.0) {
            vec3 pRef = (p + n * 0.01) + refR * dRef;
            vec3 nRef = GetNormal(pRef, t);
            refCol = getIridescence(pRef, nRef, t) * 0.5;
        }

        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        vec3 iris = getIridescence(p, n, t);
        float diff = clamp(dot(n, normalize(vec3(1, 2, 3))), 0.2, 1.0);
        
        col = mix(iris * diff, refCol, 0.2 + 0.8 * fresnel);
        col += pow(fresnel, 3.0) * 0.4;
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 finalCol = vec3(0);

    for(int i=0; i<SAMPLES; i++) {
        float t = iTime - (float(i) / float(SAMPLES)) * 0.02;
        finalCol += render(uv, t);
    }
    
    finalCol /= float(SAMPLES);
    finalCol = pow(finalCol, vec3(0.4545)); 
    finalCol *= 1.0 - length(uv) * 0.1; 
    
    fragColor = vec4(finalCol, 1.0);
}
