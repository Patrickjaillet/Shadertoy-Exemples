// ==== Image (image) ====
#define MAX_STEPS 100
#define SURFACE_DIST 0.001
#define MAX_DIST 40.0
#define ITERATIONS 4

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.2, 0.1);
    vec3 b = vec3(0.5, 0.4, 0.3);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.15, 0.20);
    return a + b * cos(6.28318 * (c * t + d));
}

float hash(vec3 p) {
    p = fract(p * vec3(123.34, 456.21, 789.18));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec3(1.0, 0.0, 0.0));
    float c = hash(i + vec3(0.0, 1.0, 0.0));
    float d = hash(i + vec3(1.0, 1.0, 0.0));
    float e = hash(i + vec3(0.0, 0.0, 1.0));
    float g = hash(i + vec3(1.0, 0.0, 1.0));
    float h = hash(i + vec3(0.0, 1.0, 1.0));
    float j = hash(i + vec3(1.0, 1.0, 1.0));
    return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
               mix(mix(e, g, f.x), mix(h, j, f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < ITERATIONS; i++) {
        v += a * noise(p);
        p *= 2.1;
        a *= 0.55;
    }
    return v;
}

vec3 getSky(vec3 rd) {
    float t = iTime * 0.05;
    vec3 col = vec3(0.005, 0.002, 0.01);
    float n = fbm(rd * 1.5 + t);
    col += palette(n * 0.4) * 0.1;
    float stars = pow(hash(floor(rd * 400.0)), 50.0);
    col += stars * (0.5 + 0.5 * sin(iTime * 1.5 + hash(rd) * 6.28));
    return col;
}

float map(vec3 p) {
    float t = iTime * 0.5;
    float pulse = smoothstep(0.4, 0.6, sin(t * 2.5)) * 0.25;
    vec3 q = p;
    q.xy *= rot(t * 0.1);
    q.xz *= rot(t * 0.05);
    float n = fbm(q * 0.7 + t);
    float dCore = length(p) - (2.6 + n + pulse);
    float dDendrites = 1e10;
    
    float stretchFreq = 1.8;
    float bendFreq = 1.2;
    float stretchAmp = 0.8;
    float bendAmp = 0.6;

    const float count = 14.0;
    for(float i=0.0; i < count; i++) {
        vec3 pD = p;
        float angle = i * (6.28318 / count);
        
        pD.xy *= rot(angle + t * 0.1);
        pD.zy *= rot(i * 0.5 + t * 0.03);
        
        float elasticStretch = 2.2 + stretchAmp * sin(t * stretchFreq + i * 0.7);
        pD.x -= elasticStretch;
        
        float bend = bendAmp * sin(pD.x * bendFreq + t * 2.5 + i) * smoothstep(0.0, 4.0, pD.x);
        pD.yz += bend; 
        
        float thickness = 0.08 * (1.0 + n * 3.5);
        float dendrite = length(pD.yz) - thickness;
        
        dDendrites = smin(dDendrites, dendrite, 0.8);
    }
    return smin(dCore, dDendrites, 1.1);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.005, 0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    
    vec3 target = vec3(sin(t*0.4)*0.5, cos(t*0.3)*0.5, 0.0);
    float camDist = 14.0 + sin(t * 0.2) * 4.0;
    vec3 ro = vec3(camDist * cos(t*0.15), camDist * 0.4 * sin(t*0.1), camDist * sin(t*0.15));
    
    if(iMouse.z > 0.0) {
        float mX = (iMouse.x / iResolution.x - 0.5) * 6.28;
        float mY = (iMouse.y / iResolution.y - 0.5) * 3.0;
        ro = vec3(camDist * cos(mX), camDist * sin(mY), camDist * sin(mX));
    }
    
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0,1,0), fwd));
    vec3 up = cross(fwd, right);
    vec3 rd = normalize(fwd + uv.x * right + uv.y * up);

    vec3 col = getSky(rd);
    float d = 0.0;
    float glow = 0.0;
    float transparency = 1.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        float ds = map(p);
        
        glow += 0.05 / (0.2 + abs(ds));
        
        if(ds < SURFACE_DIST) {
            vec3 n = getNormal(p);
            vec3 viewDir = normalize(-rd);
            float fresnel = pow(clamp(1.0 - dot(n, viewDir), 0.0, 1.0), 5.0);
            float b = fbm(p * 0.4 + t * 0.5);
            vec3 baseCol = palette(b + length(p) * 0.05);
            
            float diff = max(dot(n, normalize(vec3(1,2,-1))), 0.0);
            vec3 surfCol = baseCol * (diff + 0.2) + fresnel * vec3(1.0, 0.8, 0.5);
            
            vec3 ref = reflect(rd, n);
            float spec = pow(max(dot(ref, viewDir), 0.0), 40.0);
            surfCol += spec * 0.6;
            
            col = mix(col, surfCol, transparency);
            transparency *= 0.15; 
            d += 0.1; 
            if(transparency < 0.01) break;
        }
        
        d += ds * 0.5;
        if(d > MAX_DIST) break;
    }
    
    col += glow * vec3(1.0, 0.4, 0.1) * 0.012;
    
    float vignette = 1.0 - dot(uv, uv) * 0.4;
    col *= vignette;
    
    col = smoothstep(-0.02, 1.1, col);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
