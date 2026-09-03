// ==== Image (image) ====
#define sEPS 0.008
#define FAR 55.
#define ITER 100

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec4 hash41(float p) {
    vec4 p4 = fract(vec4(p) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

vec3 blackbody(float t) {
    vec3 col = vec3(pow(t, 2.0), pow(t, 5.0), pow(t, 20.0));
    return col * vec3(1.5, 0.9, 0.5);
}

vec3 aces(vec3 x) {
    return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14), 0.0, 1.0);
}

vec3 envMap(vec3 rd) {
    vec3 col = mix(vec3(0.02, 0.05, 0.12), vec3(0.15, 0.25, 0.45), rd.y * 0.5 + 0.5);
    vec3 lDir = normalize(vec3(1.0, 2.0, -1.0));
    float sun = pow(max(dot(rd, lDir), 0.0), 32.0);
    col += vec3(1.0, 0.8, 0.6) * sun * 1.5;
    col += blackbody(clamp(sin(rd.x * 6.0 + rd.z * 6.0) * 0.5 + 0.5, 0.0, 1.0)) * 0.3;
    return col;
}

float map(vec3 p) {
    p.xy *= rot(p.z * 0.1 + iTime * 0.05);
    p.xz *= rot(iTime * 0.02);
    
    vec3 pL = mod(p, 2.0) - 1.0;
    float x = smin(length(pL.xy), smin(length(pL.yz), length(pL.xz), 0.25), 0.25) - 0.15;
    
    float dps = 1e5;
    for(int i=0; i<4; i++) {
        vec4 h = hash41(float(i) + 15.0);
        float t = fract(iTime * 0.1 + h.w);
        vec3 pos = pL + (h.xyz - 0.5) * 1.8 * (1.0 - t);
        dps = smin(dps, length(pos) - 0.12 * t, 0.5);
    }
    return smin(x, dps, 0.3);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.005, 0);
    return normalize(vec3(map(p+e.xyy)-map(p-e.xyy), 
                          map(p+e.yxy)-map(p-e.yxy), 
                          map(p+e.yyx)-map(p-e.yyx)));
}

vec3 getEmptySpacePath(float t) {
    float id = floor(t);
    float f = fract(t);
    f = smoothstep(0.0, 1.0, f);

    vec3 posA = vec3(0.0, 0.0, id * 2.0);
    vec3 posB = vec3(0.0, 0.0, (id + 1.0) * 2.0);

    return mix(posA, posB, f);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t_anim = iTime * 0.5; 
    
    vec3 ro = getEmptySpacePath(t_anim);
    vec3 target = getEmptySpacePath(t_anim + 0.5);
    
    vec3 f = normalize(target - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0); 
    vec3 r = normalize(cross(cp, f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float t = 0.0, d;
    for(int i=0; i < ITER; i++) {
        d = map(ro + rd * t);
        if(d < sEPS || t > FAR) break;
        t += d * 0.75; 
    }

    vec3 col = envMap(rd) * 0.05;

    if(t < FAR) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 ld = normalize(vec3(1.0, 2.0, -1.0));
        vec3 refl = reflect(rd, n);
        
        vec3 cube = envMap(refl);
        
        float diff = max(dot(n, ld), 0.0);
        float spec = pow(max(dot(refl, ld), 0.0), 64.0);
        float fres = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 5.0);
        float ao = clamp(map(p + n * 0.2) / 0.2, 0.0, 1.0);
        
        float internalGlow = clamp(1.0 - length(mod(p, 2.0)-1.0), 0.0, 1.0);
        vec3 emit = blackbody(internalGlow) * 1.8;
        
        vec3 baseCol = mix(vec3(0.01), cube, 0.3 + fres * 0.7);
        col = (baseCol * diff + spec * cube + emit) * ao;
        col *= exp(-0.12 * t);
    }

    vec2 vuv = fragCoord / iResolution.xy;
    col *= pow(16.0 * vuv.x * vuv.y * (1.0 - vuv.x) * (1.0 - vuv.y), 0.12);
    
    col = aces(col * 1.2);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
