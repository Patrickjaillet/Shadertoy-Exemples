// ==== Image (image) ====
// ==========================================================
// NAME : ORGANIC PASTEL NACRE TUNNEL - IMAGE
//==========================================================
// Post-processing pass for the bloom effect.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

vec3 getScene(vec2 uv) {
    return texture(iChannel0, uv).rgb;
}

vec3 getBloom(vec2 uv) {
    vec3 blur = vec3(0);
    float samples = 16.0;
    float quality = 1.0 / iResolution.y;
    float spread = 14.0; 
    
    for(float i=0.0; i<samples; i++) {
        float angle = i * 6.28318 / samples;
        vec2 offset = vec2(cos(angle), sin(angle)) * quality * spread;
        blur += getScene(uv + offset) * 0.15;
        blur += getScene(uv + offset * 0.5) * 0.3;
        blur += getScene(uv - offset * 0.7) * 0.2;
    }
    
    return blur / (samples * (0.15 + 0.3 + 0.2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 scene = getScene(uv);
    vec3 bloomCol = getBloom(uv);
    
    float threshold = 0.85;
    float softKnee = 0.2;
    float luma = dot(bloomCol, vec3(0.299, 0.587, 0.114));
    float bloomWeight = smoothstep(threshold, threshold + softKnee, luma);
    
    vec3 finalBloom = bloomCol * bloomWeight;
    float bloomIntensity = 1.6;
    vec3 col = scene + finalBloom * bloomIntensity;
    
    col = col / (col + vec3(1.0));
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// ==========================================================
// NAME : ORGANIC PASTEL NACRE TUNNEL - BUFFER A
//==========================================================
// Core raymarching engine with camera path logic, nacre lighting,
// pink/yellow fog, and volumetric blue smoke flowing to the camera.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define MAX_STEPS 120
#define SURF_DIST 0.001
#define MAX_DIST 50.0

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float Hash31(vec3 p) {
    p = fract(p * vec3(123.34, 456.21, 789.18));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y * p.z);
}

float Noise31(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = Hash31(i);
    float b = Hash31(i + vec3(1.0, 0.0, 0.0));
    float c = Hash31(i + vec3(0.0, 1.0, 0.0));
    float d = Hash31(i + vec3(1.0, 1.0, 0.0));
    float e = Hash31(i + vec3(0.0, 0.0, 1.0));
    float fg = Hash31(i + vec3(1.0, 0.0, 1.0));
    float g = Hash31(i + vec3(0.0, 1.0, 1.0));
    float h = Hash31(i + vec3(1.0, 1.0, 1.0));
    return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
               mix(mix(e, fg, f.x), mix(g, h, f.x), f.y), f.z);
}

float FBM(vec3 p) {
    float f = 0.0;
    float amp = 0.5;
    // La fumée avance vers la caméra
    p.z -= iTime * 1.5;
    for(int i=0; i<4; i++) {
        f += Noise31(p) * amp;
        p *= 2.0;
        p.xy *= Rot(0.3);
        amp *= 0.5;
    }
    return f;
}

vec2 getPathOffset(float z) {
    float x = sin(z * 0.15) * 3.5;
    float y = cos(z * 0.12) * 2.5;
    return vec2(x, y);
}

vec2 GetDist(vec3 p) {
    vec2 bend = getPathOffset(p.z);
    p.xy -= bend;
    p.xy *= Rot(p.z * 0.08 + iTime * 0.05);
    
    float angle = atan(p.x, p.y);
    float r = length(p.xy);
    float tunnelRadius = 4.5;
    
    float organic = sin(angle * 5.0 + p.z * 0.5 + iTime * 0.3) * 0.4;
    organic += sin(angle * 8.0 - p.z * 0.8 + iTime * 0.5) * 0.2;
    
    float noiseVal = Noise31(vec3(angle * 2.5, p.z * 0.4, iTime * 0.15));
    organic += noiseVal * 0.7;

    float d = tunnelRadius - (r + organic);
    return vec2(d * 0.6, 1.0);
}

vec2 RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    float id = -1.0;
    for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        vec2 dS = GetDist(p);
        dO += dS.x;
        id = dS.y;
        if(dO > MAX_DIST || abs(dS.x) < SURF_DIST) break;
    }
    return vec2(dO, id);
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p).x;
    vec2 e = vec2(0.01, 0);
    vec3 n = d - vec3(
        GetDist(p - e.xyy).x,
        GetDist(p - e.yxy).x,
        GetDist(p - e.yyx).x
    );
    return normalize(n);
}

vec3 GetPastelPalette(float t) {
    vec3 base = vec3(0.95);
    vec3 r = vec3(0.3, 0.8, 0.9);
    vec3 g = vec3(0.9, 0.7, 0.9);
    vec3 b = vec3(0.8, 0.9, 0.7);
    return base + 0.1 * cos(6.28318 * (t * vec3(1.0, 1.2, 1.4) + vec3(0.0, 0.33, 0.67)));
}

vec3 GetFogPalette(float t) {
    vec3 r = vec3(1.0, 0.85, 0.85); 
    vec3 y = vec3(1.0, 0.98, 0.75); 
    return mix(r, y, sin(t * 3.14159) * 0.5 + 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 m = iMouse.xy / iResolution.xy;
    
    float speed = 3.5;
    float time = iTime * speed;
    float lookAhead = 2.5;

    vec3 ro = vec3(getPathOffset(time), time);
    vec3 target = vec3(getPathOffset(time + lookAhead), time + lookAhead);
    
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(fwd, vec3(0, 1, 0)));
    vec3 up = normalize(cross(right, fwd));
    
    float fov = 1.0;
    vec3 rd = normalize(fwd * fov + uv.x * right + uv.y * up);

    if(iMouse.z > 0.0) {
        rd.xz *= Rot((m.x - 0.5) * 1.5);
        rd.yz *= Rot((m.y - 0.5) * 1.0);
    }

    vec2 rm = RayMarch(ro, rd);
    float d = rm.x;
    vec3 col = vec3(0);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        vec3 amb = GetPastelPalette(p.z * 0.01) * 0.2;
        float diff = dot(n, normalize(vec3(0.3, 0.5, -0.6))) * 0.5 + 0.5;
        vec3 diffCol = GetPastelPalette(p.z * 0.15 + iTime * 0.1); 
        
        float fresnel = pow(1.0 + dot(rd, n), 4.0);
        float iridFactor = r.y * 0.5 + 0.5 + Noise31(r * 3.0 + iTime * 0.05) * 0.1;
        vec3 iridCol = GetPastelPalette(iridFactor + p.z * 0.01 + 0.6);
        float spec = pow(max(dot(r, normalize(vec3(-0.3, -0.5, 0.6))), 0.0), 24.0);
        
        col = amb + diffCol * diff * 0.5;
        col += iridCol * fresnel * 2.5;
        col += vec3(1.0, 0.99, 0.98) * spec * 2.0;
        
        float fog = 1.0 - exp(-d * 0.11);
        vec3 fogColBase = GetFogPalette(p.z * 0.004 + iTime * 0.01); 
        vec3 fogCol = fogColBase * 0.22; 
        col = mix(col, fogCol, fog);
    } else {
        col = GetPastelPalette(uv.y * 0.5 + 0.5 + iTime * 0.05) * 0.15;
    }
    
    // --- BLUE VOLUMETRIC SMOKE ---
    float stepLen = min(d, MAX_DIST) / 30.0;
    vec3 vp = ro + rd * (Hash31(vec3(uv, iTime)) * stepLen); 
    vec3 sCol = vec3(0.0);
    float sDen = 0.0;
    
    for(int i=0; i<30; i++) {
        if(vp.z > ro.z + d) break;
        
        vec2 bend = getPathOffset(vp.z);
        float distCenter = length(vp.xy - bend);
        float mask = smoothstep(4.0, 1.0, distCenter); 
        
        float nVal = FBM(vp * 0.7);
        float den = smoothstep(0.45, 0.8, nVal) * mask; 
        
        if(den > 0.0) {
            vec3 cloudColor = mix(vec3(0.4, 0.55, 0.9), vec3(0.7, 0.85, 1.0), nVal);
            float alpha = den * stepLen * 1.8;
            alpha = (1.0 - sDen) * alpha;
            sCol += cloudColor * alpha;
            sDen += alpha;
            if(sDen > 0.99) break;
        }
        vp += rd * stepLen;
    }
    
    col = mix(col, sCol, sDen);
    // -----------------------------
    
    fragColor = vec4(col, 1.0);
}
