// ==== Image (image) ====
vec3 ACESFilm(vec3 x) {
    const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

vec2 distort(vec2 uv, float k) {
    vec2 c = uv - 0.5;
    float r2 = dot(c, c);
    return uv + c * k * r2;
}

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float dist = distance(uv, vec2(0.5));
    vec3 col;
    col.r = texture(iChannel0, distort(uv, 0.004 * dist)).r;
    col.g = texture(iChannel0, distort(uv, 0.0)).g;
    col.b = texture(iChannel0, distort(uv, -0.004 * dist)).b;
    col = ACESFilm(col * 1.3);
    col = pow(col, vec3(0.4545));
    float vign = pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.15);
    col *= mix(vec3(0.4, 0.45, 0.5), vec3(1.02), vign);
    float grain = (hash12(uv + iTime) - 0.5) * 0.015;
    col += grain;
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
#define S 1.73205080757
#define PI 3.14159265359
#define SAMPLE_COUNT 16.0
#define MAX_DIST 60.0
#define ITERATIONS 110
#define BOKEH_STRENGTH 0.08
#define FOCUS_DIST 0.45

float hash12(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

mat2 rot(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }

float sdHexPrism(vec3 p, vec2 h) {
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0 * min(dot(k.xy, p.xy), 0.0) * k.xy;
    p.xy -= vec2(clamp(p.x, -k.z * h.x, k.z * h.x), h.x);
    return max(p.z - h.y, length(p.xy) * sign(p.y));
}

vec2 map(vec3 p) {
    vec2 s = vec2(1.0, S), h = s * 0.5;
    vec2 p1 = mod(p.xy, s) - h, p2 = mod(p.xy - h, s) - h;
    vec2 p_hex = (dot(p1, p1) < dot(p2, p2)) ? p1 : p2;
    vec2 id = p.xy - p_hex;
    float anim = 0.5 + 0.5 * sin(iTime * 1.2 + dot(id, vec2(0.3, 0.5)));
    float d = sdHexPrism(vec3(p_hex, p.z), vec2(0.35 + 0.05 * anim, 0.1 + 0.9 * anim));
    return vec2(d, anim);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(map(p+e.xyy).x - map(p-e.xyy).x,
                          map(p+e.yxy).x - map(p-e.yxy).x,
                          map(p+e.yyx).x - map(p-e.yyx).x));
}

vec3 shadePBR(vec3 p, vec3 n, vec3 rd, float id_anim, float ao) {
    vec3 tex = texture(iChannel1, p.xy * 0.5).rgb;
    float microRough = tex.r * 0.1;
    vec3 ld = normalize(vec3(1.5, 2.0, -2.5));
    vec3 h = normalize(ld - rd);
    vec3 f0 = vec3(0.98); 
    float roughness = mix(0.01, 0.07, id_anim) + microRough;
    float a2 = roughness * roughness;
    float nh = max(dot(n, h), 0.0);
    float D = a2 / (PI * pow(nh * nh * (a2 - 1.0) + 1.0, 2.0));
    vec3 F = f0 + (1.0 - f0) * pow(1.0 - max(dot(h, -rd), 0.0), 5.0);
    
    vec3 refDir = reflect(rd, n + (tex - 0.5) * 0.012);
    // Correction textureLod : s'assurer que iChannel2 est une Cubemap
    vec3 env = texture(iChannel2, refDir, roughness * 8.0).rgb;
    
    float sh = 1.0;
    for(float i=1.0; i<6.0; i++) {
        float h_dist = map(p + ld * i * 0.15).x;
        sh = min(sh, h_dist * 12.0);
        if(sh < 0.01) break;
    }
    
    return (F * D * clamp(sh, 0.0, 1.0)) + (env * F * ao);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 totalCol = vec3(0.0);
    float t_seed = hash12(fragCoord + iTime);
    for(float s = 0.0; s < SAMPLE_COUNT; s++) {
        vec2 jitter = (vec2(hash12(vec2(s, t_seed)), hash12(vec2(t_seed, s))) - 0.5) / iResolution.y;
        vec2 uv = (fragCoord / iResolution.xy - 0.5) * vec2(iResolution.x / iResolution.y, 1.0) + jitter;
        vec2 bokeh = (vec2(hash12(vec2(s+1.0, t_seed)), hash12(vec2(t_seed+1.0, s))) - 0.5) * BOKEH_STRENGTH;
        uv += bokeh * smoothstep(0.0, 1.5, length(uv) - FOCUS_DIST);
        
        float path = iTime * 0.35;
        vec3 ro = vec3(3.5 * cos(path), 2.5 * sin(path), -4.5 + cos(path*0.5));
        vec3 lookAt = vec3(0.5 * sin(path * 2.0), 0.0, 0.0);
        vec3 fwd = normalize(lookAt - ro), rgt = normalize(cross(vec3(0.0, 0.0, 1.0), fwd)), up = cross(fwd, rgt);
        vec3 rd = normalize(fwd + uv.x * rgt + uv.y * up);
        
        float t_dist = 0.0;
        vec2 res = vec2(0.0);
        for(int i = 0; i < ITERATIONS; i++) {
            res = map(ro + rd * t_dist);
            if(abs(res.x) < 0.0005 || t_dist > MAX_DIST) break;
            t_dist += res.x;
        }
        
        vec3 col = texture(iChannel2, rd).rgb * 0.15;
        if(t_dist < MAX_DIST) {
            vec3 p = ro + rd * t_dist;
            vec3 n = getNormal(p);
            float ao = 0.0, sca = 1.0;
            for(float i=1.0; i<5.0; i++) {
                float h_dist = i * 0.1;
                ao += (h_dist - map(p + n * h_dist).x) * sca;
                sca *= 0.75;
            }
            col = shadePBR(p, n, rd, res.y, clamp(1.0 - ao, 0.0, 1.0));
            col *= exp(-0.02 * t_dist);
        }
        totalCol += col;
    }
    vec4 prev = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = vec4(mix(prev.rgb, totalCol / SAMPLE_COUNT, 0.15), 1.0);
}
