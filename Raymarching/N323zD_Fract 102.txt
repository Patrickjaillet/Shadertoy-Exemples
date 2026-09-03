// ==== Image (image) ====
mat3 r3d(float a, vec3 axis) {
    vec3 n = normalize(axis);
    float s = sin(a), c = cos(a), r = 1. - c;
    return mat3(
        n.x * n.x * r + c, n.y * n.x * r + n.z * s, n.z * n.x * r - n.y * s,
        n.x * n.y * r - n.z * s, n.y * n.y * r + c, n.z * n.y * r + n.x * s,
        n.x * n.z * r + n.y * s, n.y * n.z * r - n.x * s, n.z * n.z * r + c
    );
}

float de(vec3 p, out vec3 outQ, out float outS, mat3 m2) {
    vec3 q = p;
    float s = 1.0;
    for (int j = 0; j < 8; j++) {
        q = abs(q * m2) - vec3(0.65, 0.8, 0.55);
        float r2 = dot(q, q);
        float k = 1.35 / clamp(r2, 0.02, 0.9);
        q *= k;
        s *= k;
    }
    float d = (length(q.xy) - 0.04) / s;
    d = max(d, -(length(p) - 1.5));
    outQ = q;
    outS = s;
    return d;
}

vec3 getNormal(vec3 p, mat3 m2, float currentS) {
    vec2 eps = vec2(0.0001, 0.0);
    vec3 dummyQ;
    float dummyS;
    return normalize(vec3(
        de(p + eps.xyy, dummyQ, dummyS, m2) - de(p - eps.xyy, dummyQ, dummyS, m2),
        de(p + eps.yxy, dummyQ, dummyS, m2) - de(p - eps.yxy, dummyQ, dummyS, m2),
        de(p + eps.yyx, dummyQ, dummyS, m2) - de(p - eps.yyx, dummyQ, dummyS, m2)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -5.0);
    vec3 rd = normalize(vec3(uv, 1.6));
    
    float tk = iTime * 0.05;
    mat3 m1 = r3d(tk, vec3(0.3, 1.0, 0.2));
    mat3 m2 = r3d(tk * 0.7, vec3(-0.5, 0.2, 1.0));
    
    vec3 col = mix(vec3(0.002, 0.001, 0.005), vec3(0.01, 0.0, 0.02), length(uv));
    vec3 glow = vec3(0.0);
    
    float dO = 0.0;
    bool hit = false;
    vec3 hitP, hitQ;
    float hitS = 1.0;
    
    for (int i = 0; i < 120; i++) {
        vec3 p = (ro + rd * dO) * m1;
        vec3 q;
        float s;
        float d = de(p, q, s, m2);
        
        glow += exp(-40.0 * abs(d)) * (1.0 + vec3(sin(tk + p.z) * 0.5 + 0.5, cos(tk * 1.3 + p.x) * 0.5 + 0.5, 1.0));
        
        if (d < 0.0001) {
            hit = true;
            hitP = p;
            hitQ = q;
            hitS = s;
            break;
        }
        dO += d * 0.45;
        if (dO > 12.0) break;
    }
    
    if (hit) {
        vec3 n = getNormal(hitP, m2, hitS);
        vec3 ld = normalize(vec3(0.5, 0.8, -0.4));
        
        float diff = max(dot(n, ld), 0.0);
        float spec = pow(max(dot(reflect(rd * m1, n), ld), 0.0), 128.0);
        
        float occ = 1.0;
        float sca = 1.0;
        for (int i = 1; i <= 5; i++) {
            float hr = 0.01 + 0.12 * float(i) / 5.0;
            vec3 dummyQ;
            float dummyS;
            float dd = de(hitP + n * hr, dummyQ, dummyS, m2);
            occ += (dd - hr) * sca;
            sca *= 0.95;
        }
        float ao = clamp(occ, 0.0, 1.0) * clamp(1.0 / (1.0 + hitS * 0.05), 0.0, 1.0);
        
        vec3 h = fract(tk * 0.3 + hitP.z * 0.2 + vec3(0.0, 0.333, 0.666));
        vec3 base = clamp(abs(h * 6.0 - 3.0) - 1.0, 0.0, 1.0);
        base = mix(base, vec3(1.0), 0.15);
        
        col = mix(base * diff, vec3(spec), 0.8) * ao;
        col += vec3(0.3, 0.6, 1.0) * pow(1.0 - max(dot(-rd * m1, n), 0.0), 5.0) * ao;
    }
    
    col += glow * 0.006;
    col = mix(col, vec3(dot(col, vec3(0.2126, 0.7152, 0.0722))), -0.25);
    
    fragColor = vec4(pow(1.0 - exp(-2.4 * col), vec3(1.0 / 2.2)), 1.0);
}
