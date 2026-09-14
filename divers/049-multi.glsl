// ==== Image (image) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

void dessinerDrapeau(inout vec3 col, vec2 uv, float ang, int type, float flou) {
    vec2 p = rotation(ang) * (uv - vec2(0.5, 0.5));
    float vent = fbm_vent(p.xy, iTime) * 0.1;
    
    vec2 offset = vec2(0.0);
    if(type == 0) offset = vec2(-0.25, 0.1);
    if(type == 1) offset = vec2(0.25, 0.1);
    if(type == 2) offset = vec2(0.0, -0.15);
    
    float d = length(max(abs(p - offset - vec2(0.0, vent)) - vec2(0.25, 0.16), 0.0));
    float masque = smoothstep(flou, -flou, d);
    
    if(masque > 0.0) {
        vec3 dCol = vec3(0);
        vec2 dUV = (p - offset - vec2(-0.25, vent - 0.16)) / vec2(0.5, 0.32);
        dUV = clamp(dUV, 0.0, 1.0);

        if(type == 0) {
            if(dUV.x < 0.33) dCol = coulBleuF();
            else if(dUV.x < 0.66) dCol = coulBlanc();
            else dCol = coulRougeF();
        } 
        else if(type == 1) {
            dCol = coulRougeN();
            float hBlanc = smoothstep(flou, -flou, abs(dUV.y - 0.5) - 0.06);
            float vBlanc = smoothstep(flou, -flou, abs(dUV.x - 0.35) - 0.04);
            dCol = mix(dCol, coulBlanc(), max(hBlanc, vBlanc));
            
            float hBleu = smoothstep(flou, -flou, abs(dUV.y - 0.5) - 0.025);
            float vBleu = smoothstep(flou, -flou, abs(dUV.x - 0.35) - 0.015);
            dCol = mix(dCol, coulBleuN(), max(hBleu, vBleu));
        } 
        else {
            if(dUV.y > 0.66) dCol = coulNoirA();
            else if(dUV.y > 0.33) dCol = coulRougeA();
            else dCol = coulOrA();
        }
        
        dCol *= (0.7 + 0.3 * sin(p.x * 15.0 - iTime * 8.0));
        col = mix(col, dCol, masque);
    }
}

void mainImage(out vec4 O, vec2 F) {
    vec2 uv = F / iResolution.xy;
    float flou = 2.5 / iResolution.y;
    
    vec3 col = vec3(
        texture(iChannel0, uv + vec2(0.002, 0)).r,
        texture(iChannel0, uv).g,
        texture(iChannel0, uv - vec2(0.002, 0)).b
    );
    
    dessinerDrapeau(col, uv, 0.2, 0, flou);
    dessinerDrapeau(col, uv, -0.2, 1, flou);
    dessinerDrapeau(col, uv, 0.0, 2, flou);
    
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    col = pow(col, vec3(0.4545));
    
    O = vec4(col, 1.0);
}

// ==== Common (common) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

#define PI 3.14159265359

mat2 rotation(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 coulBleuF()  { return vec3(0.00, 0.14, 0.58); }
vec3 coulRougeF() { return vec3(0.93, 0.16, 0.22); }
vec3 coulRougeN() { return vec3(0.73, 0.05, 0.18); }
vec3 coulBleuN()  { return vec3(0.00, 0.12, 0.35); }
vec3 coulNoirA()  { return vec3(0.05, 0.05, 0.05); }
vec3 coulRougeA() { return vec3(0.86, 0.00, 0.00); }
vec3 coulOrA()    { return vec3(1.00, 0.80, 0.00); }
vec3 coulBlanc()  { return vec3(1.00, 1.00, 1.00); }

vec3 hache33(vec3 p3) {
    p3 = fract(p3 * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

float bruit3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(dot(hache33(i + vec3(0,0,0)), f - vec3(0,0,0)),
                       dot(hache33(i + vec3(1,0,0)), f - vec3(1,0,0)), f.x),
                   mix(dot(hache33(i + vec3(0,1,0)), f - vec3(0,1,0)),
                       dot(hache33(i + vec3(1,1,0)), f - vec3(1,1,0)), f.x), f.y),
               mix(mix(dot(hache33(i + vec3(0,0,1)), f - vec3(0,0,1)),
                       dot(hache33(i + vec3(1,0,1)), f - vec3(1,0,1)), f.x),
                   mix(dot(hache33(i + vec3(0,1,1)), f - vec3(0,1,1)),
                       dot(hache33(i + vec3(1,1,1)), f - vec3(1,1,1)), f.x), f.y), f.z);
}

float fbm_vent(vec2 p, float t) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * bruit3D(vec3(p * 2.0 - t * 2.0, t * 0.4));
        p *= 2.1; a *= 0.5;
    }
    return v;
}

// ==== Buffer A (buffer) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

float sdBox3D(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float scene(vec3 p) {
    float t = iTime;
    p.z = mod(p.z + t * 2.0, 6.0) - 3.0;
    p.xy *= rotation(t * 0.2);
    float d = sdBox3D(p, vec3(1.0)), s = 1.0;
    for(int m = 0; m < 3; m++) {
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float c = (min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x))) - 1.0) / s;
        d = max(d, c);
        p.xy *= rotation(t * 0.1);
    }
    return d;
}

void mainImage(out vec4 O, vec2 F) {
    vec2 uv = (F - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, 4), rd = normalize(vec3(uv, -1.8));
    
    vec3 col = pow(hache33(vec3(rd * 300.0)).rrr, vec3(40.0)) * 1.5;
    
    float t = 0.0;
    for(int i = 0; i < 60; i++) {
        float d = scene(ro + rd * t);
        if(d < 0.001 || t > 25.0) break;
        t += d;
    }
    
    if(t < 25.0) {
        vec3 p = ro + rd * t;
        col = mix(vec3(0.02, 0.05, 0.1), vec3(0.4, 0.6, 1.0) / t, 1.0 - exp(-0.15 * t));
    }
    
    vec4 prec = texture(iChannel0, F / iResolution.xy);
    O = mix(prec, vec4(col, 1.0), 0.15);
}
