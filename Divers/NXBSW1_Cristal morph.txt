// ==== Image (image) ====
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

float sdGyroid(vec3 p, float scale, float thickness, float bias) {
    p *= scale;
    return abs(dot(sin(p), cos(p.zxy)) - bias) / scale - thickness;
}

vec4 map(vec3 p, float t) {
    vec3 p1 = p;
    p1.xy *= rot(t * 0.2);
    p1.xz *= rot(t * 0.3);
    
    float crystal = sdOctahedron(p1, 1.8);
    for(float i = 0.0; i < 4.0; i++) {
        p1 = abs(p1) - 0.4;
        p1.xy *= rot(1.0 + i);
        p1.zy *= rot(0.5 - i);
        crystal = min(crystal, sdOctahedron(p1, 1.2 - i * 0.3));
    }
    
    vec3 p2 = p;
    float l1 = sdGyroid(p2, 4.0, 0.03, 0.3);
    float l2 = sdGyroid(p2 * 1.8, 6.0, 0.02, 0.1);
    float liquid = smin(length(p2) - 1.5, l1, -0.4);
    liquid = smin(liquid, l2, -0.2);
    
    float wave = sin(p.x * 4.4 + t) * cos(p.y * 2.0 - t) * sin(p.z * 8.0 + t * 0.5);
    liquid += wave * 0.15;
    
    float morphFactor = smoothstep(-0.9, 0.2, sin(t * 0.4) * 1.2);
    
    float d = mix(crystal, liquid, morphFactor);
    float mat = mix(0.0, 1.0, morphFactor);
    
    return vec4(p, d);
}

vec3 getNormal(vec3 p, float t) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, t).w - map(p - e.xyy, t).w,
        map(p + e.yxy, t).w - map(p - e.yxy, t).w,
        map(p + e.yyx, t).w - map(p - e.yyx, t).w
    ));
}

float getAO(vec3 p, vec3 n, float t) {
    float occ = 0.0;
    float sca = 1.0;
    for(float i = 0.0; i < 5.0; i++) {
        float hr = 0.01 + 0.12 * i / 4.0;
        vec3 aopos = n * hr + p;
        float dd = map(aopos, t).w;
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    
    vec3 ro = vec3(0.0, 0.0, -5.5 + sin(t * 0.5) * 1.5);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    ro.yz *= rot(sin(t * 0.1) * 0.3);
    ro.xz *= rot(t * 0.15);
    rd.yz *= rot(sin(t * 0.1) * 0.3);
    rd.xz *= rot(t * 0.15);
    
    float dO = 0.0;
    vec4 scene = vec4(0.0);
    bool hit = false;
    
    for(int i = 0; i < 75; i++) {
        vec3 p = ro + rd * dO;
        scene = map(p, t);
        if(abs(scene.w) < 0.001) {
            hit = true;
            break;
        }
        if(dO > 12.0) break;
        dO += scene.w * 0.75;
    }
    
    vec3 col = vec3(0.02, 0.01, 0.04) * (1.0 - length(uv) * 0.5);
    
    if(hit) {
        vec3 p = ro + rd * dO;
        vec3 n = getNormal(p, t);
        vec3 r = reflect(rd, n);
        
        vec3 lightPos1 = vec3(4.0, 5.0, -4.0);
        vec3 lightPos2 = vec3(-4.0, -3.0, -2.0);
        vec3 l1 = normalize(lightPos1 - p);
        vec3 l2 = normalize(lightPos2 - p);
        
        float dif1 = clamp(dot(n, l1), 0.4, 1.0);
        float dif2 = clamp(dot(n, l2), 0.0, 1.0);
        float spe1 = pow(clamp(dot(r, l1), 0.0, 1.0), 32.0);
        float spe2 = pow(clamp(dot(r, l2), 0.0, 1.0), 16.0);
        float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 4.0);
        float ao = getAO(p, n, t);
        
        float morphFactor = smoothstep(-0.2, 0.2, sin(t * 0.4) * 1.2);
        
        vec3 crystalColor = abs(sin(p.zxy * 0.8 + vec3(0.0, 2.0, 4.0))) * 0.6 + 0.4;
        crystalColor += vec3(0.2, 0.8, 0.9) * (sin(p.x * 10.0) * 0.5 + 0.5);
        
        vec3 liquidColor = mix(vec4(0.9, 0.1, 0.4, 1.0), vec4(0.3, 0.05, 0.6, 1.0), sin(p.y * 2.0 + t) * 0.5 + 0.5).rgb;
        liquidColor += r * 0.3;
        
        vec3 baseColor = mix(crystalColor, liquidColor, morphFactor);
        
        col = baseColor * (dif1 * 0.8 + dif2 * 0.3 + 0.15);
        col += vec3(0.9, 0.9, 1.0) * spe1 * (1.0 - morphFactor * 0.4);
        col += vec3(0.9, 0.4, 0.7) * spe2 * morphFactor;
        col += vec3(0.5, 0.8, 1.0) * fre * 0.6;
        col *= ao;
        
        col = mix(col, vec3(1.00, 0.00, 0.04), 1.0 - exp(-0.02 * dO * dO));
    }
    
    col = pow(col, vec3(0.4545));
    col = smoothstep(0.0, 1.0, col);
    
    fragColor = vec4(col, 1.0);
}
