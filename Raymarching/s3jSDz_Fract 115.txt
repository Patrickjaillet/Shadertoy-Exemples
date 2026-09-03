// ==== Image (image) ====
#define MAX_STEPS 64
#define MAX_DIST 20.0
#define SURF_DIST 0.001

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float map(vec3 p, float iterations) {
    p.xz *= rot(iTime * 0.2);
    p.xy *= rot(iTime * 0.15);
    
    float scale = 1.0;
    float dist = 100.0;
    float floorIter = floor(iterations);
    float fractIter = fract(iterations);
    
    for(int i = 0; i < 10; i++) {
        if(float(i) > floorIter) break;
        p = abs(p) - vec3(0.9, 0.5, 0.6);
        p.xz *= rot(1.0);
        p.xy *= rot(0.6);
        
        float k = 1.7 / clamp(dot(p, p), 0.0, 0.9);
        p *= k;
        scale *= k;
        
        float d = sdBox(p, vec3(1.0)) / scale;
        if(float(i) >= floorIter) {
            dist = mix(dist, d, fractIter);
        } else {
            dist = d;
        }
    }
    
    return dist;
}

vec3 getNormal(vec3 p, float iterations) {
    vec2 e = vec2(0.000, 0.0);
    return normalize(vec3(
        map(p + e.xyy, iterations) - map(p - e.xyy, iterations),
        map(p + e.yxy, iterations) - map(p - e.yxy, iterations),
        map(p + e.yyx, iterations) - map(p - e.yyx, iterations)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, -3);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    float iterations = 5.5 + 4.5 * sin(iTime * 0.3);
    
    float dO = 0.0;
    float acc = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = map(p, iterations);
        dO += dS;
        if(abs(dS) < SURF_DIST || dO > MAX_DIST) break;
        acc += exp(-dS * 19.8);
    }
    
    vec3 p = ro + rd * dO;
    vec3 n = getNormal(p, iterations);
    vec3 l = normalize(vec3(1, 2, -3));
    
    float diff = clamp(dot(n, l), 0.0, 1.0);
    float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 32.0);
    
    vec3 col = vec3(0.1, 0.2, 0.5) * diff + spec;
    col += acc * 0.05 * vec3(0.8, 0.4, 0.2);
    
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
