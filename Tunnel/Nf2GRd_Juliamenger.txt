// ==== Image (image) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
void mainImage(out vec4 o, in vec2 u) {
    vec2 uv = u / iResolution.xy;
    
    vec3 col = vec3(0);
    float total = 0.0;
    for(float x = -1.5; x <= 1.5; x += 1.0) {
        for(float y = -1.5; y <= 1.5; y += 1.0) {
            vec2 off = vec2(x, y) / iResolution.xy;
            col += texture(iChannel0, uv + off).rgb;
            total++;
        }
    }
    col /= total;
    
    vec3 a = vec3(2.51), b = vec3(0.03), c = vec3(2.43), d = vec3(0.59), e = vec3(0.14);
    col = clamp((col*(a*col+b))/(col*(c*col+d)+e), 0.0, 1.0);
    
    o = vec4(pow(col, vec3(0.4545)), 1.0);
}

// ==== Buffer A (buffer) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
#define T (iTime * 0.5)

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdMenger(vec3 p) {
    float d = max(abs(p.x), max(abs(p.y), abs(p.z))) - 1.2;
    float s = 1.0;
    for(int m=0; m<3; m++) {
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float da = max(r.x, r.y), db = max(r.y, r.z), dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / s;
        d = max(d, c);
    }
    return d;
}

float sdJulia(vec3 p) {
    vec4 z = vec4(p, 0.0);
    vec4 c = vec4(-0.4, 0.5, 0.1, 0.0);
    float md2 = 1.0, nz2 = dot(z,z);
    for(int i=0; i<5; i++) {
        md2 *= 4.0 * nz2;
        z = vec4(z.x*z.x-z.y*z.y-z.z*z.z-z.w*z.w, 2.0*z.x*z.y, 2.0*z.x*z.z, 2.0*z.x*z.w) + c;
        nz2 = dot(z,z);
        if(nz2 > 4.0) break;
    }
    return 0.25 * sqrt(nz2/md2) * log(nz2);
}

float sdSpaghetti(vec3 p) {
    vec2 q = p.xy;
    q *= rot(p.z * 0.3);
    float s1 = length(q + vec2(sin(p.z)*4.0, cos(p.z)*4.0)) - 1.5;
    float s2 = length(q - vec2(sin(p.z)*4.0, cos(p.z)*4.0)) - 1.5;
    return min(s1, s2);
}

float map(vec3 p) {
    vec3 q = p;
    q.z = mod(p.z, 8.0) - 4.0;
    
    float d1 = sdJulia(q * 1.1) / 1.1;
    float d2 = sdMenger(q * 1.1) / 1.1;
    float d3 = sdSpaghetti(q);
    
    float m1 = smoothstep(-0.5, 0.5, sin(T));
    float m2 = smoothstep(-0.5, 0.5, sin(T + 2.1));
    float m3 = smoothstep(-0.5, 0.5, sin(T + 4.2));
    
    float d = mix(d1, d2, m1);
    d = mix(d, d3, m2);
    d = mix(d, d1, m3);
    
    return d * 0.6; 
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0001, 0); 
    return normalize(vec3(map(p+e.xyy)-map(p-e.xyy),
                          map(p+e.yxy)-map(p-e.yxy),
                          map(p+e.yyx)-map(p-e.yyx)));
}

void mainImage(out vec4 o, in vec2 u) {
    vec2 uv = (u - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, iTime * 3.0), rd = normalize(vec3(uv, 1.2));
    
    float t = 0.0, d;
    for(int i=0; i<150; i++) {
        d = map(ro + rd * t);
        if(abs(d) < 0.0001 || t > 30.0) break;
        t += d * 0.4; 
    }
    
    vec3 col = vec3(0.01, 0.01, 0.02);
    if(t < 30.0) {
        vec3 p = ro + rd * t, n = getNormal(p), r = reflect(rd, n);
        float fre = pow(1.0 + dot(rd, n), 5.0);
        
        vec3 refl = mix(vec3(0.05, 0.1, 0.2), vec3(1, 0.9, 0.8), pow(max(0.0, dot(r, vec3(0,1,0.5))), 10.0));
        refl += vec3(0.5, 0.7, 1.0) * pow(max(0.0, dot(r, vec3(1,0,0))), 30.0);
        
        col = refl * (0.1 + 0.9 * fre);
        col *= clamp(map(p + n * 0.5) / 0.5, 0.0, 1.0);
        col += 2.0 * pow(max(0.0, dot(r, normalize(vec3(0.3, 1, 0.2)))), 120.0);
    }
    
    o = vec4(col, t);
}
