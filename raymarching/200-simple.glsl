// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, s, -s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float map(vec3 p) {
    float t = iTime * 0.6;
    float pulse = pow(sin(t * 0.5) * 0.5 + 0.5, 4.0);
    float explosion = smoothstep(0.3, 0.9, pulse) * 4.5;
    
    p.xy *= rot(t * 0.15);
    p.xz *= rot(t * 0.25);
    
    float s = 1.0;
    for(int i = 0; i < 8; i++) {
        p = abs(p) - 0.5;
        if (p.x < p.y) p.yx = p.xy;
        if (p.x < p.z) p.zx = p.xz;
        if (p.y < p.z) p.zy = p.yz;
        
        float factor = 2.2 + explosion;
        p.x = p.x * factor - 0.8 * (factor - 1.0);
        p.y = p.y * factor - 0.8 * (factor - 1.0);
        p.z = p.z * factor;
        
        if(p.z > 0.5 * factor) p.z -= factor;
        
        s *= factor;
    }
    
    return sdBox(p, vec3(0.6, 0.2, 0.05)) / s;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0005, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + h * n);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t = iTime;
    float intense = pow(sin(t * 0.5) * 0.5 + 0.5, 12.0);
    vec2 shake = vec2(sin(t * 120.0), cos(t * 135.0)) * intense * 0.08;
    
    vec3 ro = vec3(0.0, 0.0, -3.8 + sin(t * 0.1) * 0.4);
    ro.xy += shake;
    
    vec3 lookat = vec3(shake * 2.0, 0.0);
    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);
    
    float t_dist = 0.0;
    float glow = 0.0;
    for(int i = 0; i < 128; i++) {
        float d = map(ro + rd * t_dist);
        if(d < 0.0005 || t_dist > 12.0) break;
        t_dist += d;
        glow += 1.0 / (1.0 + d * d * 80.0);
    }
    
    vec3 col = vec3(0.002, 0.005, 0.01);
    
    if(t_dist < 12.0) {
        vec3 p = ro + rd * t_dist;
        vec3 n = getNormal(p);
        vec3 l = normalize(vec3(2.0, 3.0, -4.0));
        vec3 l2 = normalize(vec3(-2.0, -1.0, 1.0));
        
        float diff = max(dot(n, l), 0.0);
        float diff2 = max(dot(n, l2), 0.0) * 0.3;
        float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 64.0);
        float fres = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 4.0);
        float ao = getAO(p, n);
        
        vec3 baseCol = mix(vec3(0.05, 0.1, 0.2), vec3(0.8, 0.9, 1.0), fres);
        col = baseCol * diff + vec3(0.1, 0.2, 0.3) * diff2;
        col += spec * vec3(1.0, 0.95, 0.8) * 1.5;
        col *= ao;
        
        col = mix(col, vec3(0.0), 1.0 - exp(-0.02 * t_dist * t_dist));
    }
    
    col += glow * vec3(0.05, 0.2, 0.5) * 0.015 * (1.0 + intense * 5.0);
    
    col = pow(col, vec3(0.4545));
    col *= 1.0 - length(uv) * 0.6;
    
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233) * t)) * 43758.5453);
    col += (noise - 0.5) * 0.02;

    fragColor = vec4(col, 1.0);
}
