// ==== Image (image) ====
#define R iResolution.xy
#define T iTime

float h12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float h31(vec3 p3) {
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float n3D(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(h31(p + vec3(0.0, 0.0, 0.0)), h31(p + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(h31(p + vec3(0.0, 1.0, 0.0)), h31(p + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(h31(p + vec3(0.0, 0.0, 1.0)), h31(p + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(h31(p + vec3(0.0, 1.0, 1.0)), h31(p + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z) * 2.0 - 1.0;
}

float mapC(vec3 p, int lod) {
    vec3 q = p - vec3(0.0, 0.1, 1.0) * T;
    float f = 0.0;
    float a = 0.5;
    for(int i = 0; i < 4; i++) {
        if(i >= lod) break;
        f += a * n3D(q);
        q = q * 2.02;
        a *= 0.5;
    }
    return clamp(1.5 - p.y - 2.0 + 1.75 * f, 0.0, 1.0);
}

mat3 setCam(vec3 ro, vec3 ta, float cr) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    return mat3(cu, cv, cw);
}

vec4 rmC(vec3 ro, vec3 rd, vec3 bg, vec2 px) {
    vec4 sum = vec4(0.0);
    float t = 0.05 * h12(px);
    vec3 sun = vec3(-0.7071, 0.0, -0.7071);
    
    for(int i = 0; i < 60; i++) {
        vec3 pos = ro + t * rd;
        if(pos.y < -3.0 || pos.y > 2.0 || sum.a > 0.99) break;
        
        int lod = t < 15.0 ? 4 : (t < 30.0 ? 3 : 2);
        float den = mapC(pos, lod);
        
        if(den > 0.01) {
            float dif = clamp((den - mapC(pos + 0.3 * sun, lod)) / 0.6, 0.0, 1.0);
            vec3 lin = vec3(1.0, 0.6, 0.3) * dif + vec3(0.91, 0.98, 1.05);
            vec4 col = vec4(mix(vec3(1.0, 0.95, 0.8), vec3(0.25, 0.3, 0.35), den), den);
            col.xyz *= lin;
            col.xyz = mix(col.xyz, bg, 1.0 - exp(-0.003 * t * t));
            col.w *= 0.4;
            col.rgb *= col.a;
            sum += col * (1.0 - sum.a);
        }
        t += max(0.06, 0.05 * t);
    }
    return clamp(sum, 0.0, 1.0);
}

vec3 bgR(vec3 ro, vec3 rd, vec2 px) {
    vec3 sun = vec3(-0.7071, 0.0, -0.7071);
    float sunVal = clamp(dot(sun, rd), 0.0, 1.0);
    vec3 col = vec3(0.6, 0.71, 0.75) - rd.y * 0.2 * vec3(1.0, 0.5, 1.0) + 0.075;
    col += 0.2 * vec3(1.0, 0.6, 0.1) * pow(sunVal, 8.0);
    vec4 res = rmC(ro, rd, col, px);
    col = col * (1.0 - res.w) + res.xyz;
    col += vec3(0.2, 0.08, 0.04) * pow(sunVal, 3.0);
    return col;
}

float fS(float x, float t) {
    float v = 0.0;
    float sx = max(abs(x), 1e-4);
    for(float i = 0.4; i < 10.0; i *= 2.0) {
        v += sin((t + log(sx * sx)) / i) * x;
    }
    return v / 3.0;
}

float dS(vec2 p, float t) {
    float y = fS(p.x, t);
    float dy = (fS(p.x + 1e-3, t) - fS(p.x - 1e-3, t)) / 2e-3;
    return abs(p.y - y) / sqrt(1.0 + dy * dy);
}

vec3 pS(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (vec3(1.0) * t + vec3(0.0, 0.33, 0.67)));
}

vec3 fgR(vec2 uv, vec2 coff) {
    vec3 c = vec3(0.0);
    int aa = 3;
    for(int i = 0; i < aa; i++) {
        for(int j = 0; j < aa; j++) {
            vec2 o = (vec2(float(i), float(j)) / float(aa) - 0.5) * 2.0 / R.y;
            vec2 puv = uv + o;
            
            vec3 sC = vec3(0.0);
            for(int k = 0; k < 3; k++) {
                vec2 cuv = puv;
                if(k == 0) cuv += coff;
                if(k == 2) cuv -= coff;
                
                float dist = dS(cuv, T);
                float y = fS(cuv.x, T);
                float fill = smoothstep(0.01, -0.01, cuv.y - y);
                float line = smoothstep(0.015, 0.0, dist);
                float glow = 0.005 / (dist * dist + 1e-4);
                
                vec3 col = pS(cuv.x * 0.2 + T * 0.15);
                sC[k] = mix(col[k] * 0.2, col[k], fill) + col[k] * glow * 1.5 + line;
            }
            c += sC;
        }
    }
    return c / float(aa * aa);
}

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 O, in vec2 U) {
    vec2 uv = (U * 2.0 - R) / R.y;
    vec2 m = iMouse.xy / R;
    vec2 p = (2.0 * U - R) / R.y;
    
    vec3 ro = 4.0 * normalize(vec3(sin(3.0 * m.x), 0.8 * m.y, cos(3.0 * m.x))) - vec3(0.0, 0.1, 0.0);
    vec3 ta = vec3(0.0, -1.0, 0.0);
    mat3 ca = setCam(ro, ta, 0.07 * cos(0.25 * T));
    vec3 rd = ca * normalize(vec3(p, 1.5));
    
    vec3 bg = bgR(ro, rd, U);
    
    vec2 nuv = U / R - 0.5;
    vec2 coff = normalize(nuv) * 10. * length(nuv) * length(nuv);
    
    vec3 fg = fgR(uv, coff);
    
    vec3 comp = bg + fg;
    comp *= 0.8 - smoothstep(0.4, 1.5, length(nuv) * 1.5);
    comp = aces(comp * 1.4);
    
    comp += (h12(U + T) - 0.5) * 0.05;
    
    O = vec4(comp, 1.0);
}
