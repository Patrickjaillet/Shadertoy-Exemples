// ==== Image (image) ====
// Patrick JAILLET

#define MAX_STEPS 120
#define MAX_DIST 40.0
#define SURF_DIST 0.001

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float mandelbulb(vec3 p) {
    vec3 z = p;
    float dr = 1.0;
    float r = 0.0;
    float power = 8.0 + sin(iTime * 0.2) * 1.5;

    for(int i = 0; i < 6; i++) {
        r = length(z);
        if(r > 4.0) break;
        
        r = max(r, 0.00001);
        float theta = acos(clamp(z.z / r, -1.0, 1.0));
        float phi = atan(z.y, z.x);
        
        dr = pow(r, power - 1.0) * power * dr + 1.0;
        
        float zr = pow(r, power);
        theta *= power;
        phi *= power;
        
        z = zr * vec3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
        z += p;
    }
    return 0.5 * log(r) * r / dr;
}

float map(vec3 p) {
    vec3 q = p;
    
    q.xy *= rot(q.z * 0.08);
    
    float r2 = dot(q.xy, q.xy);
    float scale = 1.5 / max(r2, 0.05); 
    q.xy *= scale;
    
    q.z = mod(q.z, 2.0) - 1.0;
    
    float d = mandelbulb(q);
    
    d = d / scale;
    
    float safeZone = length(p.xy) - 0.2;
    return max(d, -safeZone);
}

float raymarch(vec3 ro, vec3 rd) {
    float d = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        float ds = map(p);
        d += ds;
        if(abs(ds) < SURF_DIST * d || d > MAX_DIST) break;
    }
    return d;
}

vec3 normal(vec3 p) {
    vec2 e = vec2(0.002, 0.0);
    vec3 n = vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    );
    return normalize(n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float speed = iTime * 0.8;
    vec3 ro = vec3(0.0, 0.0, speed);
    
    vec3 look = vec3(sin(iTime*0.5)*0.2, cos(iTime*0.3)*0.2, speed + 2.0);
    
    vec3 f = normalize(look - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);
    
    float d = raymarch(ro, rd);
    vec3 col = vec3(0.0);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = normal(p);
        
        vec3 light = normalize(ro - p + vec3(0.0, 0.0, 1.0));
        
        float dif = max(dot(n, light), 0.0);
        float spec = pow(max(dot(reflect(rd, n), light), 0.0), 16.0);
        
        vec3 mat = mix(vec3(0.4, 0.35, 0.3), vec3(0.7, 0.65, 0.55), sin(p.z * 5.0) * 0.5 + 0.5);
        
        float ao = clamp(map(p + n * 0.1) * 10.0, 0.0, 1.0);
        
        col = mat * (dif * 0.8 + 0.2);
        col += spec * 0.3;
        col *= ao;
    }
    
    float fog = exp(-0.08 * d);
    vec3 bgColor = vec3(0.05, 0.04, 0.03);
    col = mix(bgColor, col, fog);
    
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
