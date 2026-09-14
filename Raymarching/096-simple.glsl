// ==== Image (image) ====
float fAtan(float x) {
    return (9.8696044 * x) / (4.0 + sqrt(34.0 + 39.4784176 * x * x));
}

float fAtan2(float y, float x) {
    float ax = abs(x);
    float ay = abs(y);
    if (ax > ay) {
        float a = fAtan(y / x);
        return x < 0.0 ? (y < 0.0 ? a - 3.14159265 : a + 3.14159265) : a;
    } else {
        float a = fAtan(x / y);
        return y < 0.0 ? -1.57079632 - a : 1.57079632 - a;
    }
}

mat2 r2d(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

vec4 map(vec3 p, float t) {
    float g = 0.0;
    vec3 orig = p;
    
    for(int i = 0; i < 5; i++) {
        float r = length(p.xy);
        float phi = fAtan2(p.y, p.x);
        
        phi += t * 0.1 + float(i) * 0.4;
        p.x = r * cos(phi);
        p.y = r * sin(phi);
        
        p.xy = abs(p.xy) - vec2(0.0, -0.8);
        p.xy *= r2d(0.523);
        
        float theta = fAtan2(p.z, p.x);
        float r2 = length(p.xz);
        theta -= r * 0.15;
        p.x = r2 * cos(theta);
        p.z = r2 * sin(theta);
        
        p.yz = abs(p.yz) - vec2(0.0, 0.5);
        p.yz *= r2d(0.785);
    }
    
    float d1 = sdBox(p, vec3(0.3, 0.3, 2.0));
    float d2 = length(p.xy) - 0.05;
    float d = min(d1, d2);
    
    g += 0.1 / (0.1 + d2 * d2 * 10.0);
    
    float m = fAtan2(orig.z, length(orig.xy));
    
    return vec4(d * 0.4, g, m, length(p));
}

vec3 getNormal(vec3 p, float t) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, t).x - map(p - e.xyy, t).x,
        map(p + e.yxy, t).x - map(p - e.yxy, t).x,
        map(p + e.yyx, t).x - map(p - e.yyx, t).x
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    float t = iTime * 0.5;
    
    vec3 ro = vec3(0.0, 0.0, -6.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    ro.xz *= r2d(t * 0.15);
    rd.xz *= r2d(t * 0.15);
    ro.yz *= r2d(t * 0.08);
    rd.yz *= r2d(t * 0.08);
    
    float dO = 0.0;
    float glow = 0.0;
    vec4 res = vec4(0.0);
    bool hit = false;
    
    for(int i = 0; i < 107; i++) {
        vec3 p = ro + rd * dO;
        res = map(p, t);
        glow += res.y;
        if(res.x < 0.001) {
            hit = true;
            break;
        }
        if(dO > 36.0) break;
        dO += res.x;
    }
    
    vec3 col = vec3(0.0);
    
    if(hit) {
        vec3 p = ro + rd * dO;
        vec3 n = getNormal(p, t);
        vec3 l = normalize(vec3(1.0, 2.0, -3.0));
        l.xz *= r2d(t);
        
        float diff = max(dot(n, l), 0.0);
        float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 23.1);
        float ao = clamp(res.w * 0.2, 0.0, 1.0);
        
        float hue = res.z * 0.5 + t * 0.05;
        vec3 baseColor = 0.5 + 0.5 * cos(vec3(0.0, 2.0, 4.0) + hue * 6.28318);
        
        col = baseColor * (diff * 0.8 + 0.2) + vec3(spec * 0.6);
        col *= ao;
        col = mix(col, vec3(0.01, 0.02, 0.05), 1.0 - exp(-0.08 * dO * dO));
    } else {
        col = vec3(0.005, 0.008, 0.015) * (1.0 + uv.y);
    }
    
    vec3 glowColor = 0.5 + 0.5 * cos(vec3(1.0, 3.0, 5.0) + (t * 0.2) * 6.28318);
    col += glowColor * glow * 0.025;
    
    col = pow(col, vec3(0.4545));
    col = clamp(col, 0.0, 1.0);
    col = col * col * (4.2 - 2.1 * col);
    
    fragColor = vec4(col, 1.0);
}
