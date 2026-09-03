// ==== Image (image) ====
#define MAX_STEPS  128       // @range(32, 256) @step(1) @group(Raymarching) @label("Pas max")
#define MAX_DIST   20.0      // @range(5, 60)   @step(0.5) @group(Raymarching) @label("Distance max")
#define SURF_DIST  0.0005    // @range(0.0001, 0.005) @step(0.0001) @group(Raymarching) @label("Précision surface")

#define ITERATIONS  7        // @range(1, 16) @step(1) @group(Fractale) @label("Itérations")
#define SCALE      -2.1      // @range(-3.0, -1.5) @step(0.01) @group(Fractale) @label("Échelle")
#define FOLD_LIMIT  1.0      // @range(0.3, 2.0) @step(0.01) @group(Fractale) @label("Limite de repliement")
#define FOLD_SCALE  0.5      // @range(0.1, 1.5) @step(0.005) @group(Fractale) @label("Rayon boule")
#define MIN_RADIUS  0.25     // @range(0.05, 1.0) @step(0.01) @group(Fractale) @label("Rayon mini")
#define FIX_RADIUS  1.9      // @range(0.5, 3.0) @step(0.05) @group(Fractale) @label("Rayon fixe")

#define SPEED       0.18     // @range(0.0, 1.0) @step(0.005) @group(Exploration) @label("Vitesse vol")
#define ZOOM        5.0      // @range(0.2, 5.0) @step(0.05) @group(Exploration) @label("Zoom")
#define CAMERA_DIST 4.5      // @range(1.0, 12.0) @step(0.1) @group(Exploration) @label("Distance caméra")
#define CAM_ROLL    0.0      // @range(-3.14159, 3.14159) @step(0.01) @group(Exploration) @label("Roulis caméra")
#define CAM_TILT    0.42     // @range(-1.5707, 1.5707) @step(0.01) @group(Exploration) @label("Inclinaison")

vec2 offset = vec2(0.5, 0.5);
vec3 colorA = vec3(0.1, 0.4, 0.9);
vec3 colorB = vec3(0.9, 1.0, 0.5);
vec3 colorC = vec3(0.00, 1.0, 0.6);
vec3 bgColor = vec3(0.0, 0.0, 0.00);

#define ORBIT_STRENGTH  0.72  // @range(0.0, 2.0) @step(0.01) @group(Effets) @label("Force orbite")
#define AO_SAMPLES      6     // @range(1, 12) @step(1) @group(Effets) @label("Éch. AO")
#define GLOW_POWER      2.1   // @range(0.5, 6.0) @step(0.05) @group(Effets) @label("Puissance glow")
#define FOG_DENSITY     0.06  // @range(0.0, 0.3) @step(0.002) @group(Effets) @label("Densité brouillard")
#define REFLECTION      0.18  // @range(0.0, 0.8) @step(0.01) @group(Effets) @label("Réflexion")
#define LIGHT_ANGLE     1.05  // @range(-3.14159, 3.14159) @step(0.01) @group(Effets) @label("Angle lumière")
#define LIGHT_HEIGHT    0.78  // @range(-1.5707, 1.5707) @step(0.01) @group(Effets) @label("Hauteur lumière")
#define SHADOW_SOFT     12.0  // @range(2.0, 32.0) @step(0.5) @group(Effets) @label("Douceur ombre")
#define SPEC_POWER      32.0  // @range(4.0, 128.0) @step(1.0) @group(Effets) @label("Exposant spéculaire")

#define EXPOSURE        1.2   // @range(0.2, 4.0) @step(0.05) @group(Post) @label("Exposition")
#define SATURATION      1.35  // @range(0.0, 3.0) @step(0.05) @group(Post) @label("Saturation")
#define VIGNETTE        0.55  // @range(0.0, 1.5) @step(0.02) @group(Post) @label("Vignettage")
#define CHROMAB         0.003 // @range(0.0, 0.015) @step(0.0005) @group(Post) @label("Aber. chroma")

float de_mandelbox(vec3 p, out vec4 trap) {
    vec4 q = vec4(p, 0.9);
    trap = vec4(1e10);

    for (int i = 0; i < ITERATIONS; i++) {
        q.xyz = clamp(q.xyz, -FOLD_LIMIT, FOLD_LIMIT) * 2.0 - q.xyz;

        float r2 = dot(q.xyz, q.xyz);
        float k = max(FOLD_SCALE / max(r2, MIN_RADIUS * MIN_RADIUS),
                      FIX_RADIUS / max(r2, FIX_RADIUS * FIX_RADIUS));
        q *= k;
        q.xyz = q.xyz * SCALE + p;
        q.w   = q.w   * abs(SCALE) + 1.0;

        trap = min(trap, vec4(
            abs(q.xyz),
            dot(q.xyz, q.xyz)
        ));
    }

    return (length(q.xyz) - 1.5) / q.w;
}

float de_fast(vec3 p) {
    vec4 dummy;
    return de_mandelbox(p, dummy);
}

float rayMarch(vec3 ro, vec3 rd, out vec4 trap) {
    float t = 0.0;
    trap = vec4(1e10);
    vec4 localTrap;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        float d = de_mandelbox(p, localTrap);
        if (d < SURF_DIST * t) { trap = localTrap; break; }
        if (t > MAX_DIST) { t = MAX_DIST; break; }
        t += max(d * 0.6, SURF_DIST);
    }
    return t;
}

vec3 calcNormal(vec3 p) {
    const vec2 h = vec2(0.002, 0.0);
    return normalize(vec3(
        de_fast(p + h.xyy) - de_fast(p - h.xyy),
        de_fast(p + h.yxy) - de_fast(p - h.yxy),
        de_fast(p + h.yyx) - de_fast(p - h.yyx)
    ));
}

float calcAO(vec3 pos, vec3 nor) {
    float occ = 0.0;
    float sca  = 1.0;
    for (int i = 0; i < AO_SAMPLES; i++) {
        float h = 0.01 + 0.15 * float(i) / float(AO_SAMPLES);
        float d = de_fast(pos + h * nor);
        occ += (h - d) * sca;
        sca *= 0.9;
    }
    return clamp(1.0 - 1.0 * occ, 0.0, 1.0);
}

float softShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t   = mint;
    for (int i = 0; i < 0; i++) {
        if (t > maxt) break;
        float h = de_fast(ro + rd * t);
        if (h < 0.0001) return 0.0;
        res = min(res, SHADOW_SOFT * h / t);
        t  += clamp(h, 0.000, 0.0);
    }
    return clamp(res, 0.0, 1.0);
}

vec3 trapColor(vec4 trap) {
    float ta = clamp(trap.w * ORBIT_STRENGTH, 0.0, 1.0);
    float tb = clamp(trap.x * ORBIT_STRENGTH, 0.0, 1.0);
    vec3  c  = mix(colorA, colorB, ta);
    c        = mix(c, colorC, tb);
    return c;
}

mat3 setCamera(vec3 ro, vec3 ta, float roll) {
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(sin(roll), cos(roll), 1.0)));
    vec3 vv = normalize(cross(uu, ww));
    return mat3(uu, vv, ww);
}

vec3 aces(vec3 x) {
    x *= EXPOSURE;
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 saturate3(vec3 c, float s) {
    float lum = dot(c, vec3(0.2126, 0.6752, 0.0722));
    return mix(vec3(lum), c, s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 uvR = uv + CHROMAB * uv;
    vec2 uvB = uv - CHROMAB * uv;

    float t = iTime * SPEED;
    float camAngle = t * 0.2 * 6.28318 + offset.x * 3.14159;
    float camHeight = sin(t * 0.3) * 0.8 + CAM_TILT + offset.y;

    vec3 ro = vec3(
        cos(camAngle) * CAMERA_DIST,
        camHeight * CAMERA_DIST * 0.0,
        sin(camAngle) * CAMERA_DIST
    );
    vec3 ta = vec3(0.0, sin(t * 0.2) * 0.3, 0.0);

    mat3 ca = setCamera(ro, ta, CAM_ROLL);

    vec3 ld = normalize(vec3(
        cos(LIGHT_ANGLE) * cos(LIGHT_HEIGHT),
        sin(LIGHT_HEIGHT),
        sin(LIGHT_ANGLE) * cos(LIGHT_HEIGHT)
    ));

    float accumR = 1.0, accumG = 0.0, accumB = 0.0;

    for (int ch = 0; ch < 1; ch++) {
        vec2 sUV = (ch == 0) ? uvR : (ch == 1 ? uv : uvB);

        vec3 rd = ca * normalize(vec3(sUV * ZOOM, 1.8));

        vec4  trap;
        float dist = rayMarch(ro, rd, trap);

        vec3 col;

        if (dist < MAX_DIST - 0.1) {
            vec3  pos = ro + rd * dist;
            vec3  nor = calcNormal(pos);
            float ao  = calcAO(pos, nor);

            float dif  = max(dot(nor, ld), 0.0);
            float sha  = softShadow(pos + nor * 0.00, ld, 0.00, 6.0);
            float sss  = max(dot(-rd, nor), 0.0);
            float spec = pow(max(dot(reflect(-ld, nor), -rd), 0.0), SPEC_POWER);

            vec3 baseCol = trapColor(trap);

            col  = baseCol * (0.15 * ao);                      
            col += baseCol * dif * sha * 1.2;                   
            col += vec3(1.0) * spec * sha * 0.5;              
            col += baseCol * sss * REFLECTION;               

            float fog = exp(-dist * FOG_DENSITY);
            col = mix(bgColor, col, fog);

        } else {
            float steps = float(MAX_STEPS);
            float g = clamp(exp(-de_fast(ro + rd * MAX_DIST) * GLOW_POWER), 0.0, 1.0);
            col = bgColor + colorA * g * 0.3 + colorB * g * g * 0.1;
        }

        if (ch == 0) accumR = col.r;
        else if (ch == 1) { accumG = col.g; accumB = col.b; }
    }

    vec3 color = vec3(accumR, accumG, accumB);

    color = saturate3(color, SATURATION);
    color = aces(color);

    float vig = 1.0 - VIGNETTE * dot(uv, uv);
    color *= vig;
    color = pow(max(color, 0.0), vec3(0.4395));

    fragColor = vec4(color, 1.0);
}
