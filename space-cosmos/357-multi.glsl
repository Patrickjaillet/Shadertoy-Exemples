// ==== Image (image) ====
#define MAX_STEPS 100
#define SURF_DIST .002
#define MAX_DIST 60.

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 g_glow_col = vec3(0);

float sdSphere4D(vec4 p, float s) {
    return length(p) - s;
}

float GetDist(vec3 p) {
    float w = sin(iTime * 0.2) * 2.0; 
    vec4 p4 = vec4(p, w);
    float rot4D = iTime * 0.3;
    float s4 = sin(rot4D), c4 = cos(rot4D);
    float x = p4.x * c4 - p4.w * s4;
    float w2 = p4.x * s4 + p4.w * c4;
    p4.x = x;
    p4.w = w2;
    float sun = sdSphere4D(p4, 1.3);
    g_glow_col += vec3(1.0, 0.4, 0.1) * (0.015 / (0.01 + sun * sun));
    float scene = sun;
    float rings = 1e10;
    for(float i = 1.0; i <= 5.0; i++) {
        float radius = i * 2.8;
        vec2 q = vec2(length(p4.xz) - radius, p4.y);
        float ring = length(vec2(length(q) - 0.03, p4.w * 0.15));
        float n_balls = 4.0 + i;
        for(float j = 0.0; j < n_balls; j++) {
            float angle = j * (6.2831 / n_balls) + iTime * (0.4 / i);
            vec4 ballPos = vec4(sin(angle) * radius, 0, cos(angle) * radius, sin(iTime * 0.5 + i));
            float ball = sdSphere4D(p4 - ballPos, 0.22);
            vec3 c = palette(j / n_balls + i * 0.25);
            g_glow_col += c * (0.012 / (0.008 + ball * ball));
            scene = min(scene, ball);
        }
        rings = min(rings, ring);
    }
    float orbitRadius = 11.2;
    float planetAngle = iTime * 0.4;
    vec4 planetPos = vec4(sin(planetAngle)*orbitRadius, 0, cos(planetAngle)*orbitRadius, sin(iTime));
    float planet = sdSphere4D(p4 - planetPos, 0.5);
    g_glow_col += vec3(0.8, 0.9, 1.0) * (0.02 / (0.01 + planet * planet));
    scene = min(scene, rings);
    scene = min(scene, planet);
    return min(scene, p.y + 4.0);
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO=0.0;
    for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    return dO;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    return normalize(d - vec3(GetDist(p-e.xyy), GetDist(p-e.yxy), GetDist(p-e.yyx)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec3 bg = texture(iChannel0, fragCoord.xy / iResolution.xy).rgb;
    float camDist = 25.0;
    vec3 ro = vec3(sin(iTime * 0.15) * camDist, 10.0 + sin(iTime * 0.2) * 5.0, cos(iTime * 0.15) * camDist);
    vec3 lookat = vec3(0, 0, 0);
    vec3 f = normalize(lookat-ro), r = normalize(cross(vec3(0,1,0), f)), u = cross(f,r);
    vec3 rd = normalize(f + uv.x*r + uv.y*u);
    g_glow_col = vec3(0);
    float d = RayMarch(ro, rd);
    vec3 col = bg;
    if(d<MAX_DIST) {
        vec3 p = ro + rd * d, n = GetNormal(p);
        vec3 l = normalize(vec3(5, 20, 5) - p);
        float dif = clamp(dot(n, l), 0.0, 1.0);
        float spe = pow(max(0.0, dot(reflect(-l, n), -rd)), 24.0);
        vec3 mat = vec3(0.5); 
        if(p.y < -3.9) {
            float checks = mod(floor(p.x * 0.5) + floor(p.z * 0.5), 2.0);
            mat = mix(vec3(0.03), vec3(0.06), checks);
            vec3 ref = reflect(rd, n);
            if(ref.y > 0.0) mat += g_glow_col * 0.5;
        }
        col = mat * (dif + 0.1) + spe * 0.4;
        col = mix(col, bg, smoothstep(20.0, 55.0, d));
    }
    col += g_glow_col * 1.6;
    col *= 1.0 - length(uv) * 0.3;
    fragColor = vec4(pow(col, vec3(.4545)), 1.0);
}

// ==== Buffer A (buffer) ====
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 45.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 hash2(vec2 p) {
    float n = hash(p);
    return vec2(n, hash(p + n));
}

vec3 starColor(float h) {
    if(h < 0.3) return vec3(0.6, 0.8, 1.0); 
    if(h < 0.6) return vec3(1.0, 1.0, 1.0); 
    if(h < 0.8) return vec3(1.0, 0.9, 0.6); 
    return vec3(1.0, 0.5, 0.4);            
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float a = iTime * 0.05;
    mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
    uv *= rot;
    
    vec3 col = vec3(0);
    
    for(float i = 1.0; i < 6.0; i++) {
        float s = i * 7.73; // Utilisation d'un pas irrégulier pour éviter les alignements
        vec2 g = floor(uv * s);
        vec2 f = fract(uv * s) - 0.5;
        float h = hash(g);
        
        if(h > 0.91) {
            vec2 offset = (hash2(g) - 0.5) * 0.9;
            vec2 p = f - offset;
            float d = length(p);
            
            float twinkle = sin(iTime * (h * 8.0) + h * 6.28);
            twinkle = pow(max(0.0, twinkle), 6.0) * 2.5; 
            
            float m = 0.0012 / d;
            
            float rays = max(0.0, 1.0 - abs(p.x * p.y * 4000.0));
            m += rays * 0.2 * twinkle;
            
            float cross = max(0.0, 1.0 - abs(p.x * 150.0)) + max(0.0, 1.0 - abs(p.y * 150.0));
            m += cross * 0.1 * twinkle;

            col += m * starColor(hash(g + 1.3)) * (0.3 + twinkle) / i;
        }
    }
    
    fragColor = vec4(col, 1.0);
}
