// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

float map(vec3 p, float t) {
    p.xy *= rot(t * 0.1);
    p.xz *= rot(t * 0.15);
    
    float d = 1e5;
    float globalScale = 1.0;
    
    for (int i = 0; i < 4; i++) {
        p = abs(p) - vec3(1.2, 0.9, 1.4);
        
        p.xy *= rot(0.62);
        p.zy *= rot(0.45);
        
        float r1 = 2.4 - float(i) * 0.3;
        float r2 = 0.35 + sin(p.z * 1.5 + t) * 0.08;
        float torus = sdTorus(p, vec2(r1, r2));
        
        float d1 = sin(p.x * 22.0) * cos(p.y * 22.0) * sin(p.z * 22.0);
        float d2 = cos(p.x * 48.0) * sin(p.y * 48.0);
        float pattern = mix(d1, d2, 0.5 + 0.5 * sin(t * 0.5)) * 0.035;
        
        torus = max(torus, -(torus + 0.008));
        torus += pattern;
        
        d = min(d, torus * globalScale);
        
        p *= 1.35;
        globalScale /= 1.35;
    }
    return d;
}

vec3 getNormal(vec3 p, float t) {
    vec2 e = vec2(0.002, 0.0);
    return normalize(vec3(
        map(p + e.xyy, t) - map(p - e.xyy, t),
        map(p + e.yxy, t) - map(p - e.yxy, t),
        map(p + e.yyx, t) - map(p - e.yyx, t)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.6;
    
    vec3 ro = vec3(0.0, 0.0, -5.5);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    ro.xz *= rot(sin(t * 0.2) * 0.4);
    rd.xz *= rot(sin(t * 0.2) * 0.4);
    
    float dO = 0.0;
    float dS = 0.0;
    vec3 p = vec3(0.0);
    bool hit = false;
    
    for(int i = 0; i < 75; i++) {
        p = ro + rd * dO;
        dS = map(p, t);
        dO += dS * 0.85;
        if(dO > 12.0 || abs(dS) < 0.001) {
            if(abs(dS) < 0.001) hit = true;
            break;
        }
    }
    
    vec3 color = vec3(0.02);
    
    if(hit) {
        vec3 n = getNormal(p, t);
        vec3 l1 = normalize(vec3(1.5, 3.0, -4.0));
        vec3 l2 = normalize(vec3(-2.0, -1.0, 2.0));
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0);
        
        vec3 r = reflect(rd, n);
        float spec = pow(max(dot(r, l1), 0.0), 32.0);
        
        float ao = clamp(map(p + n * 0.12, t) / 0.12, 0.0, 1.0);
        ao *= clamp(map(p + n * 0.35, t) / 0.35, 0.0, 1.0);
        
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 3.0);
        
        color = vec3(0.1) * ao;
        color += vec3(0.55) * diff1 * ao;
        color += vec3(0.25) * diff2 * ao;
        color += vec3(0.4) * fre * ao;
        color += vec3(0.7) * spec * ao;
        
        color *= exp(-0.18 * dO);
    }
    
    color = pow(color, vec3(0.95));
    color = smoothstep(0.0, 1.0, color);
    
    vec2 screenUV = fragCoord / iResolution.xy;
    float vignette = screenUV.x * screenUV.y * (1.0 - screenUV.x) * (1.0 - screenUV.y);
    color *= clamp(pow(16.0 * vignette, 0.3), 0.0, 1.0);
    
    fragColor = vec4(color, 1.0);
}
