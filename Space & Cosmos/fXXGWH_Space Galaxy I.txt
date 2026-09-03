// ==== Image (image) ====
#define PI 3.14159265359
#define TAU 6.28318530718
#define MAX_STEPS 160
#define MAX_DIST 60.0

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hache(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

float bruit(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(mix(hache(i + vec3(0, 0, 0)), hache(i + vec3(1, 0, 0)), f.x),
            mix(hache(i + vec3(0, 1, 0)), hache(i + vec3(1, 1, 0)), f.x), f.y),
        mix(mix(hache(i + vec3(0, 0, 1)), hache(i + vec3(1, 0, 1)), f.x),
            mix(hache(i + vec3(0, 1, 1)), hache(i + vec3(1, 1, 1)), f.x), f.y),
        f.z);
}

float fbm(vec3 p) {
    float v = 0.0, a = 0.5;
    mat3 m = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
    for (int i = 0; i < 6; i++) {
        v += a * bruit(p);
        p = m * p * 2.1;
        a *= 0.5;
    }
    return v;
}

float galaxieCentrale(vec3 p, float t) {
    float r = length(p.xz);
    float h = abs(p.y);
    float angle = atan(p.z, p.x);
    float distortion = fbm(p * 0.4 + t * 0.1) * 1.5;
    float bulbe = exp(-length(p) * 1.2) * 8.0;
    float spiral_count = 2.0;
    float spiral_strength = 2.5;
    float arm_warp = sin(angle * spiral_count - pow(r, 0.6) * 2.5 + t * 0.2 + distortion);
    float arm = pow(max(0.0, arm_warp), 4.0) * exp(-r * 0.15) * exp(-h * 5.0);
    float disque = exp(-r * 0.25) * exp(-h * 12.0) * 0.6;
    float poussiere = smoothstep(0.3, 0.7, fbm(p * 1.8 - t * 0.1));
    float densite = (bulbe + arm * spiral_strength + disque) * poussiere;
    return max(0.0, densite * smoothstep(25.0, 12.0, r));
}

vec3 couleurVolume(vec3 p, float d, float t) {
    float r = length(p.xz);
    float h = abs(p.y);
    vec3 colCoeur = vec3(1.0, 0.9, 0.7) * 2.0;
    vec3 colArm = vec3(0.2, 0.5, 1.0) * 1.5;
    vec3 colVoid = vec3(0.5, 0.1, 0.8);
    float m1 = smoothstep(0.0, 4.0, r);
    float m2 = smoothstep(4.0, 15.0, r);
    vec3 col = mix(colCoeur, colArm, m1);
    col = mix(col, colVoid, m2);
    float temp = fbm(p * 0.5 + t);
    col += vec3(1.0, 0.4, 0.2) * pow(temp, 3.0) * smoothstep(2.0, 8.0, r) * exp(-h * 2.0);
    return col;
}

vec3 getStarField(vec2 uv, float zoom, float time, float seed) {
    vec2 gv = fract(uv * zoom) - 0.5;
    vec2 id = floor(uv * zoom);
    vec3 col = vec3(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offs = vec2(float(x), float(y));
            vec2 n = hash22(id + offs + seed);
            float pTime = time * (0.3 + n.x * 0.7) + n.y * 6.28;
            float size = (0.04 + 0.12 * hash12(id + offs + seed + 121.3)) * (sin(pTime) * 0.5 + 0.5);
            vec2 p = offs + n - 0.5;
            float d = length(gv - p);
            vec3 starCol = mix(vec3(0.5, 0.7, 1.0), vec3(1.0, 0.5, 0.3), hash12(id + offs + seed + 45.1));
            starCol = mix(starCol, vec3(1.0, 0.9, 0.7), n.x * n.y);
            float light = (size * 0.015) / (d + 0.0005);
            float glow = (size * 0.003) / (d * d + 0.00008);
            vec2 r_uv = (gv - p) * rot(pTime * 0.5);
            float rays = pow(max(0.0, 1.0 - abs(r_uv.x * r_uv.y * 1000.0)), 12.0) * (size * 0.1 / (d + 0.01));
            rays += pow(max(0.0, 1.0 - abs(r_uv.x)), 50.0) * (size * 0.05 / (d + 0.01));
            col += (light + glow + rays) * starCol;
        }
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.2;
    
    vec3 ro = vec3(22.0 * cos(t * 0.4), 8.0 + 4.0 * sin(t * 0.3), 22.0 * sin(t * 0.4));
    vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.8 * cw);

    float pas = MAX_DIST / float(MAX_STEPS);
    float jitter = hache(vec3(fragCoord, iFrame)) * pas;
    vec3 p = ro + rd * jitter;
    
    vec4 res = vec4(0.0);
    float T = 1.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        if (T < 0.01 || length(p) > MAX_DIST) break;
        float d = galaxieCentrale(p, t);
        if (d > 0.01) {
            vec3 col = couleurVolume(p, d, t);
            float sigma = d * 1.8;
            float dT = exp(-sigma * pas);
            res.rgb += T * (col - col * dT);
            T *= dT;
        }
        p += rd * pas;
    }

    vec3 starField = vec3(0.0);
    vec2 starUV = uv;
    float starT = iTime * 0.15;
    vec2 camPath = vec2(sin(starT * 0.5), cos(starT * 0.3)) * 2.0;
    float camRot = sin(starT * 0.2) * 0.4;
    
    for (float i = 0.0; i < 1.0; i += 1.0/8.0) {
        float depth = fract(i - starT * 0.5);
        float zoom = mix(15.0, 0.05, depth);
        float fade = smoothstep(0.0, 0.4, depth) * smoothstep(1.0, 0.8, depth);
        vec2 p_uv = starUV;
        p_uv *= rot(camRot * depth);
        p_uv += camPath * depth;
        starField += getStarField(p_uv, zoom, iTime, i * 951.4) * fade;
    }

    vec3 finalCol = res.rgb + starField * T;
    
    finalCol = pow(finalCol, vec3(0.8));
    finalCol *= 1.2;
    vec2 screenUv = fragCoord / iResolution.xy;
    float vign = length(screenUv - 0.5);
    finalCol *= smoothstep(1.2, 0.3, vign);
    
    float noise = hash12(fragCoord + iTime);
    finalCol += (noise - 0.5) * 0.012;
    
    vec3 bloom = finalCol * finalCol;
    finalCol += bloom * 0.3;
    finalCol = mix(finalCol, vec3(dot(finalCol, vec3(0.299, 0.587, 0.114))), -0.1);
    
    fragColor = vec4(clamp(finalCol, 0.0, 1.0), 1.0);
}
