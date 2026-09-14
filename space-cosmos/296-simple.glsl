
#define MAX_STEPS 200
#define SURF_DIST 0.0001
#define MAX_DIST 150.0

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float Noise(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float FBM(vec3 p) {
    float f = 0.0;
    f += 0.5000 * Noise(p); p = p * 2.02;
    f += 0.2500 * Noise(p); p = p * 2.03;
    f += 0.1250 * Noise(p); p = p * 2.01;
    f += 0.0625 * Noise(p);
    return f;
}

float Voronoi(vec2 uv) {
    vec2 p = floor(uv);
    vec2 f = fract(uv);
    float min_dist = 1.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            float dist = distance(offset + 0.5 + 0.5 * sin(iTime + 6.2831 * (p + offset)), f);
            min_dist = min(min_dist, dist);
        }
    }
    return min_dist;
}

float sdOrbitalComplex(vec3 p, float scale) {
    float r = length(p);
    float costheta = p.y / (r + 0.0001);
    float baseDensity = (r * r) * (costheta * costheta) * exp(-r * 0.7);

    float displacement = FBM(p * 5.0 + iTime * 0.2) * 0.04;
    float density = baseDensity + displacement;

    float orbital = (0.12 - density) * scale;

    float costheta3 = (p.y * p.y * p.y) / (r * r * r + 0.0001);
    float density3 = (r * r * r) * (costheta3) * exp(-r * 0.9);
    orbital = min(orbital, (0.05 - density3) * scale);

    return orbital;
}

float sdStructure(vec3 p) {
    vec3 pOrig = p;

    float d = length(p.xy) - 5.5;

    float d2 = length(p.xy) - 5.0;
    vec2 st = p.xz * 0.1;
    st.x += iTime * 0.01;
    float pattern = smoothstep(0.01, 0.0, Voronoi(st * 5.0 + 10.0));
    d2 += pattern * 0.2;

    d = max(d, -d2);

    p.z = mod(p.z + 5.0, 10.0) - 5.0;
    float colRadius = 0.3;
    float col1 = length(p.xz + vec2(4.5, 0.0)) - colRadius;
    float col2 = length(p.xz + vec2(-4.5, 0.0)) - colRadius;
    d = min(d, min(col1, col2));

    return d;
}

float GetDist(vec3 p) {

    float d = p.y + 7.0;

    d = min(d, sdStructure(p));

    float zInterval = 15.0;
    float zIndex = floor(p.z / zInterval);
    vec3 pOrbit = p;
    pOrbit.z = mod(pOrbit.z, zInterval) - zInterval * 0.5;

    float phase = iTime * 1.5 + zIndex;
    pOrbit.xy *= Rot(phase * 0.15);

    float orbitalScale = 4.0;
    float orbital = sdOrbitalComplex(pOrbit, orbitalScale);

    float hole = length(pOrbit.xz) - 2.0;
    orbital = max(orbital, -hole);

    d = min(d, orbital);

    return d * 0.5;
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
    }
    return dO;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.005, 0);
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx));
    return normalize(n);
}

vec3 GetCosmicBackground(vec3 rd) {
    vec3 col = vec3(0.0);
    float f = 0.0;

    vec3 p = rd * 1.0;
    f += FBM(p * 2.0 + iTime * 0.1) * 0.5;
    f += FBM(p * 4.0 + iTime * 0.2) * 0.25;

    col += mix(vec3(0.01, 0.02, 0.05), vec3(0.1, 0.05, 0.2), f);

    float filament = FBM(p * 15.0 - iTime * 0.05);
    col += mix(vec3(0.0), vec3(0.2, 0.7, 0.9), filament) * 0.3;

    float stars = smoothstep(0.9995, 0.9999, Noise(rd * 300.0));
    col += vec3(stars);

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float speed = iTime * 3.0;
    vec3 ro = vec3(0.0, 0.0, speed);

    ro.x += sin(iTime * 1.0) * 0.1;
    ro.y += cos(iTime * 0.8) * 0.1;

    vec3 lookat = vec3(0.0, 0.0, speed + 1.0);
    vec3 f = normalize(lookat - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);

    float d = RayMarch(ro, rd);

    vec3 col = GetCosmicBackground(rd);

    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);

        vec3 lightPos1 = vec3(2.0, 10.0, speed + 5.0);
        vec3 lightPos2 = vec3(-10.0, -5.0, speed - 10.0);
        vec3 l1 = normalize(lightPos1 - p);
        vec3 l2 = normalize(lightPos2 - p);
        float dif1 = clamp(dot(n, l1), 0.0, 1.0);
        float dif2 = clamp(dot(n, l2), 0.0, 1.0);
        float spe1 = pow(clamp(dot(reflect(-l1, n), -rd), 0.0, 1.0), 32.0);
        float spe2 = pow(clamp(dot(reflect(-l2, n), -rd), 0.0, 1.0), 16.0);

        vec3 matOrbital = vec3(0.2, 0.5, 0.8);
        vec3 matStructure = vec3(0.6, 0.5, 0.3);
        vec3 matFloor = vec3(0.1, 0.1, 0.15);

        vec3 mat = matStructure;
        float roughness = 0.5;

        if(p.y < -6.9) {
             mat = matFloor;
             roughness = 0.8;
        } else if (abs(p.y) < 6.0 && length(p.xy) < 5.0) {
            mat = matOrbital;
            roughness = 0.1;
        }

        col = mat * (dif1 * vec3(1.0, 0.9, 0.7) + dif2 * vec3(0.5, 0.6, 0.9));
        col += spe1 * vec3(1.0, 0.9, 0.8) + spe2 * vec3(0.6, 0.7, 1.0);

        float pulse = sin(p.z * 0.3 - iTime * 2.5) * 0.5 + 0.5;

        vec3 glowColor = mix(vec3(0.1, 0.8, 1.0), vec3(0.8, 0.2, 1.0), pulse);
        col += glowColor * pulse * 0.4;

        float emissiveVoronoi = smoothstep(0.01, 0.0, Voronoi((p.xz + iTime * 0.1)* 5.0));
        if (p.y > -6.8 && length(p.xy) > 5.1 && p.y < 6.0) {
             col += matStructure * emissiveVoronoi * 0.5 * glowColor;
        }

        float fogFactor = 1.0 - exp(-0.015 * d);
        col = mix(col, GetCosmicBackground(rd), fogFactor);
    }

    col = pow(col, vec3(0.4545));
    col *= 1.1;
    col = clamp(col, 0.0, 1.0);

    fragColor = vec4(col, 1.0);
}
