// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 st = fragCoord / iResolution.xy;
    vec2 u = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec4 s = texture(iChannel0, st);
    vec3 col = s.rgb;
    float depth = s.w;

    vec3 blur = vec3(0.0);
    float tw = 0.0;
    const float samples = 6.0;
    for(float i = 1.0; i < samples; i++) {
        float r = sqrt(i / samples);
        float angle = i * 2.399;
        vec2 offset = vec2(cos(angle), sin(angle)) * r * depth * 0.008;
        float w = 1.0 / (1.0 + i * 0.1);
        blur += texture(iChannel0, st + offset).rgb * w;
        tw += w;
    }
    
    col = mix(col, blur / tw, 0.5);
    
    col = ACESFilm(col * 1.1);
    col = pow(col, vec3(0.95)); 
    
    vec2 vuv = (st - 0.5) * iResolution.xy / iResolution.y;
    float vignette = smoothstep(1.2, 0.4, length(vuv));
    col *= mix(0.7, 1.0, vignette);
    
    float noise = (fract(sin(dot(st + iTime * 0.01, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.01;
    
    fragColor = vec4(col + noise, 1.0);
}

// ==== Common (common) ====
#define M(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define G(p,s,b) abs(dot(sin(p*s),cos((p*s).zxy))-b)/s

#define ITERATIONS 14
#define FORMUPARAM 0.53
#define VOLSTEPS 16
#define STEPSIZE 0.12
#define ZOOM 0.8
#define TILE 0.85
#define SPEED 0.008
#define BRIGHTNESS 0.0005
#define DARKMATTER 0.45
#define DISTFADING 0.72
#define SATURATION 0.85

float glowAcc = 0.0;

float df(vec3 p, float t) {
    p.xy *= M(p.z * 0.15); 
    p.z += t * 0.12; 
    p.y -= 0.3;
    float s = 10.8, m = 0.5, g = G(p, (1.35 + (sin(t * 0.01) * 0.5 + 0.5)), 1.5);
    vec3 q = p;
    for(int i = 0; i < 8; i++) {
        q += sin(q.zxy * 1.15 + t) * 0.18;
        g += (i < 2 ? -1.2 : 1.0) * G(q, s, 0.3) * m;
        s *= 1.85; m *= 0.62;
    }
    glowAcc += 0.005 / (0.015 + g * g);
    return g * 0.5;
}

vec3 gn(vec3 p, float t) {
    vec2 e = vec2(0.001, 0);
    return normalize(df(p, t) - vec3(df(p - e.xyy, t), df(p - e.yxy, t), df(p - e.yyx, t)));
}

vec3 getStarNest(vec3 dir, float t) {
    vec3 from = vec3(1.0, 0.5, 0.5) + vec3(t * SPEED * 2.0, t * SPEED, -2.0);
    float s = 0.1, fade = 1.0;
    vec3 v = vec3(0.0);
    for (int r = 0; r < VOLSTEPS; r++) {
        vec3 p = from + s * dir * 0.5;
        p = abs(vec3(TILE) - mod(p, vec3(TILE * 2.0)));
        float pa, a = pa = 0.0;
        for (int i = 0; i < ITERATIONS; i++) { 
            p = abs(p) / dot(p, p) - FORMUPARAM;
            a += abs(length(p) - pa);
            pa = length(p);
        }
        float dm = max(0.0, DARKMATTER - a * a * 0.001);
        a *= a * a;
        if (r > 6) fade *= 1.0 - dm;
        v += fade;
        v += vec3(s, s * s, s * s * s * s) * a * BRIGHTNESS * fade;
        fade *= DISTFADING;
        s += STEPSIZE;
    }
    v = mix(vec3(length(v)), v, SATURATION);
    return v * 0.01;
}

vec3 ACESFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

// ==== Buffer A (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 u = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    
    glowAcc = 0.0;
    vec3 ro = vec3(0.015 * cos(-t * 0.05), 0.015 * sin(-t * 0.05), 0.015 * sin(-t * 0.05));
    vec3 ww = normalize(-ro);
    vec3 uu = normalize(cross(ww, vec3(0, 1, 0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 rd = normalize(u.x * uu + u.y * vv + 2.5 * ww);
    
    float o = 0.0, s;
    for(int i = 0; i < 96; i++) {
        s = df(ro + rd * o, t);
        o += s;
        if(o > 10.0 || abs(s) < 0.0004) break;
    }

    vec3 bg = getStarNest(rd, t);
    vec3 col;

    if(o < 10.0) {
        vec3 p = ro + rd * o;
        vec3 n = gn(p, t);
        vec3 ref = reflect(rd, n);
        
        vec3 pt = p; 
        pt.xy *= M(pt.z * 0.15); pt.z += t * 0.12; pt.y -= 0.3;
        
        float b = G(pt, 10.8, 0.3);
        float v = (1.0 - G(pt + t * 0.02, 7.8, 0.4) * 4.0) * (1.0 - G(pt - t * 0.01, 4.8, 0.2) * 2.0);
        
        float fresnel = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 4.0);
        vec3 envSpec = texture(iChannel0, ref).rgb;
        vec3 envDiff = texture(iChannel0, n).rgb;
        
        float sp = pow(max(dot(ref, normalize(vec3(0.2, 0.6, 1.0))), 0.0), 180.0);
        
        vec3 material = mix(envDiff * 0.15, envSpec, fresnel * 0.8 + 0.1);
        vec3 pattern = smoothstep(-0.01, -0.06, b) * vec3(0.15, 0.45, 1.0) * v * 2.5;
        
        vec3 glowCol = vec3(0.0, 0.35, 1.0) * glowAcc * 0.0035;
        col = material + pattern + sp * 1.5 + glowCol;
    } else {
        vec3 glowCol = vec3(0.0, 0.35, 1.0) * glowAcc * 0.0035;
        col = bg + glowCol;
    }

    fragColor = vec4(mix(col, bg, smoothstep(6.0, 10.0, o)), o);
}
