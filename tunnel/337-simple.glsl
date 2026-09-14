// ==== Image (image) ====
#define CAM_SPEED 1.0
#define CAM_FOV 0.5
#define LOOKAHEAD 24.0

#define PATH_A1 6.5
#define PATH_A2 1.3
#define PATH_F1 0.34
#define PATH_F2 0.50
#define PATH_B1 1.8
#define PATH_B2 1.1
#define PATH_G1 0.12
#define PATH_G2 0.05

#define ROLL_SPEED 0.2
#define ROLL_FREQ 0.1

#define TORUS_THETA 2.09
#define TORUS_RADIUS 4.0
#define TUBE_RADIUS 0.18
#define MOD_Z 6.28

#define IFS_ITER 16
#define IFS_FOLD_X 1.0
#define IFS_FOLD_Y 0.4
#define IFS_FOLD_Z 1.0
#define IFS_ROT1 0.45
#define IFS_ROT2 0.25
#define IFS_SCALE 1.42
#define DENSITY_FALL 0.25

#define MAX_STEPS 128
#define MAX_DIST 60.0
#define STEP_FACTOR 0.6
#define SURF_DIST 0.001
#define DENSITY_ACC 0.05

#define ROUGHNESS 0.4
#define F0 0.09
#define DIFFUSE_STR 5.0

vec3 albedo = vec3(0.2, 0.05, 0.02);
vec3 emissive = vec3(1.0, 0.4, 0.1);
vec3 lightDir = vec3(0.5, 0.8, -0.5);

#define EXPOSURE 1.5
#define GAMMA 2.2
#define FOG_DENSITY 0.1

#define AO_STEPS 5
#define AO_START 0.01
#define AO_STEP 0.05
#define AO_FALLOFF 0.5

vec2 path(float z) {
    return vec2(
        sin(z * PATH_F1) * PATH_A1 + cos(z * PATH_F2) * PATH_A2,
        cos(z * PATH_G1) * PATH_B1 + sin(z * PATH_G2) * PATH_B2
    );
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p, out float density, out float mat) {
    vec2 tune = path(p.z);
    p.xy -= tune;
    p.xy *= rot(p.z * ROLL_FREQ + iTime * ROLL_SPEED);

    float r = length(p.xy);
    float theta = atan(p.y, p.x);
    vec3 q = vec3(theta * -TORUS_THETA,
                  r - TORUS_RADIUS,
                  mod(p.z, MOD_Z) - MOD_Z * 0.5);

    float s = 1.0;
    density = 0.0;
    for (int i = 0; i < IFS_ITER; i++) {
        q = abs(q) - vec3(IFS_FOLD_X, IFS_FOLD_Y, IFS_FOLD_Z);
        if (q.x < q.y) q.xy = q.yx;
        if (q.x < q.z) q.xz = q.zx;
        if (q.y < q.z) q.yz = q.zy;
        q.xy *= rot(IFS_ROT1);
        q.yz *= rot(IFS_ROT2);
        q *= IFS_SCALE;
        s *= IFS_SCALE;
        density += exp(-abs(q.y) * DENSITY_FALL);
    }
    mat = q.z;
    return (length(q.xy) - TUBE_RADIUS) / s;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.0005, 0.0);
    float d1, m;
    return normalize(vec3(
        map(p + e.xyy, d1, m) - map(p - e.xyy, d1, m),
        map(p + e.yxy, d1, m) - map(p - e.yxy, d1, m),
        map(p + e.yyx, d1, m) - map(p - e.yyx, d1, m)
    ));
}

float getAO(vec3 p, vec3 n) {
    float ao = 0.0, sca = 1.0;
    for (int i = 1; i <= AO_STEPS; i++) {
        float hr = AO_START + AO_STEP * float(i);
        float d, m;
        ao += (hr - map(p + n * hr, d, m)) * sca;
        sca *= AO_FALLOFF;
    }
    return clamp(1.0 - ao, 0.0, 1.0);
}

vec3 GGX(vec3 n, vec3 v, vec3 l, float roughness, vec3 f0, vec3 alb) {
    vec3 h = normalize(v + l);
    float dotNL = clamp(dot(n, l), 0.001, 1.0);
    float dotNV = clamp(dot(n, v), 0.001, 1.0);
    float dotNH = clamp(dot(n, h), 0.0, 1.0);
    float dotLH = clamp(dot(l, h), 0.0, 1.0);
    float alpha2 = pow(roughness, 4.0);
    float D = alpha2 / (3.14159 * pow(dotNH * dotNH * (alpha2 - 1.0) + 1.0, 2.0));
    vec3 F = f0 + (1.0 - f0) * pow(1.0 - dotLH, 5.0);
    float k = pow(roughness + 1.0, 2.0) / 8.0;
    float G = (dotNL / (dotNL * (1.0 - k) + k))
            * (dotNV / (dotNV * (1.0 - k) + k));
    return (D * F * G) / (4.0 * dotNL * dotNV) * alb
           + (1.0 - F) * alb / 3.14159;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float t = iTime * CAM_SPEED;
    vec3 ro = vec3(path(t), t);
    vec3 la = vec3(path(t + LOOKAHEAD), t + LOOKAHEAD);

    vec3 cz = normalize(la - ro);
    vec3 cx = normalize(cross(vec3(0.0, 1.0, 0.0), cz));
    vec3 cy = cross(cz, cx);
    vec3 rd = normalize(cx * uv.x + cy * uv.y + cz * CAM_FOV);

    float t_dist = 0.0, d, density, mat;
    float accum_density = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        d = map(ro + rd * t_dist, density, mat);
        accum_density += density * DENSITY_ACC;
        if (d < SURF_DIST || t_dist > MAX_DIST) break;
        t_dist += d * STEP_FACTOR;
    }

    vec3 p = ro + rd * t_dist;
    vec3 n = getNormal(p);
    vec3 l1 = normalize(vec3(lightDir.x, lightDir.y, -0.5));

    vec3 col = GGX(n, -rd, l1, ROUGHNESS, vec3(F0), albedo) * DIFFUSE_STR;
    col += emissive * accum_density * FOG_DENSITY;
    col *= getAO(p, n);
    col = 1.0 - exp(-col * EXPOSURE);

    fragColor = vec4(pow(col, vec3(1.0 / GAMMA)), 1.0);
}
