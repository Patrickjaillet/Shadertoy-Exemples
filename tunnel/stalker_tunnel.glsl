#define MAX_STEPS 180
#define MAX_DIST 90.0

const vec3 LIGHT_COLOR = vec3(0.05, 0.85, 1.0);
const vec3 LIGHT_ACCENT = vec3(0.95, 0.25, 0.85);
const vec3 FOG_COLOR = vec3(0.002, 0.004, 0.012);
const float PI = 3.14159265359;

mat2 rot(float a) {
    vec2 s = sin(vec2(a, a + 1.5707963));
    return mat2(s.y, -s.x, s.x, s.y);
}

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash12(vec2 p) {
    vec3 p3 = fract(p.xyx * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hash31(vec3 p) {
    p = fract(p * vec3(.1031, .1030, .0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

float stalk(float t) {
    return t * 1.1 + 1.6 * sin(t * .37) + .3 * sin(t * .91);
}

vec2 headLook(float t) {
    float period = 5.5;
    float k = floor(t / period);
    float f = fract(t / period);
    float a = smoothstep(.06, .16, f) * (1. - smoothstep(.5, .72, f));
    float b = smoothstep(.78, .84, f) * (1. - smoothstep(.9, .96, f));
    vec2 tgt = vec2(hash11(k) - .5, hash11(k + 7.3) - .5) * vec2(2.2, .6);
    vec2 tgt2 = vec2(hash11(k + 3.1) - .5, hash11(k + 11.7) - .5) * vec2(.8, .3);
    vec2 base = vec2(sin(t * .23) * .22 + sin(t * .57) * .08, sin(t * .19) * .07 - .05);
    vec2 jit = vec2(sin(t * 7.3) + sin(t * 11.7) * .6, sin(t * 8.9) + sin(t * 13.1) * .5) * .0035;
    return base + tgt * a + tgt2 * b + jit;
}

vec3 getPath(float z) {
    return vec3(sin(z * .12) * 7. + cos(z * .05) * 2., cos(z * .11) * 4. + sin(z * .08) * 3., z);
}

float map(vec3 p) {
    vec3 q = p;
    q.xy -= getPath(q.z).xy;
    q.xy *= rot(q.z * .04 + iTime * .05);
    float d = max(abs(q.x), abs(q.y)) - 14., s = 1.0;
    for (int i = 0; i < 4; i++) {
        vec3 r = abs(1. - 3.2 * abs(mod(q * s, 2.) - 1.));
        d = max(d, (min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x))) - 1.) / (s *= 2.85));
    }
    return d;
}

float surfaceNoise(vec3 p) {
    return (sin(p.x * 30.0) * sin(p.y * 30.0) * sin(p.z * 30.0)) * 0.003;
}

vec3 getNormal(vec3 p, float t) {
    float eps = max(0.0004, 0.0002 * t);
    vec2 e = vec2(eps, 0.0);
    vec3 n = vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    );
    vec3 bump = vec3(
        surfaceNoise(p + e.xyy) - surfaceNoise(p - e.xyy),
        surfaceNoise(p + e.yxy) - surfaceNoise(p - e.yxy),
        surfaceNoise(p + e.yyx) - surfaceNoise(p - e.yyx)
    );
    return normalize(n + bump * 2.0);
}

float calcAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 6; i++) {
        float h = 0.01 + 0.2 * float(i) / 5.0;
        float d = map(p + h * n);
        occ += (h - d) * sca;
        sca *= 0.9;
        if (occ > 0.35) break;
    }
    return clamp(1.0 - 2.8 * occ, 0.0, 1.0);
}

float calcSoftShadow(vec3 ro, vec3 rd, float mint, float maxt, float k) {
    float res = 1.0;
    float t = mint;
    float ph = 1e10;
    for (int i = 0; i < 40; i++) {
        float h = map(ro + rd * t);
        float y = h * h / (2.0 * ph);
        float d = sqrt(max(h * h - y * y, 0.0));
        res = min(res, k * d / max(0.0001, t - y));
        ph = h;
        t += clamp(h, 0.012, 0.25);
        if (res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

float distributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float denom = NdotH * NdotH * (a2 - 1.0) + 1.0;
    return a2 / max(PI * denom * denom, 0.00001);
}

float geometrySchlickGGX(float NdotV, float roughness) {
    float r = roughness + 1.0;
    float k = (r * r) / 8.0;
    return NdotV / (NdotV * (1.0 - k) + k);
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    return geometrySchlickGGX(max(dot(N, V), 0.0), roughness) * geometrySchlickGGX(max(dot(N, L), 0.0), roughness);
}

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness) {
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 renderScene(vec2 uv, float dither) {
    float T = iTime;
    float s = stalk(T);
    float stepPhase = s * 2.4;

    vec3 pos = getPath(s);
    vec3 fw = normalize(getPath(s + 5.) - pos);
    vec3 ri = normalize(cross(fw, vec3(0, 1, 0)));
    vec3 up = cross(ri, fw);

    float bob = abs(sin(stepPhase)) * .055 - .03 + sin(T * 1.3) * .008;
    float sway = sin(stepPhase) * .035;
    vec3 ro = pos + up * bob + ri * sway;

    vec2 hl = headLook(T);
    vec3 cw = normalize(fw + ri * hl.x + up * hl.y);
    vec3 cu = normalize(cross(cw, vec3(0, 1, 0)));
    vec3 cv = cross(cu, cw);

    float roll = -hl.x * .07 + sin(stepPhase) * .012 + sin(T * .9) * .004;
    uv *= rot(roll);

    float focal = 1.7 - abs(hl.x) * .12 + sin(T * 1.1) * .01;
    vec3 rd = normalize(uv.x * cu + uv.y * cv + cw * focal);

    vec3 lP = getPath(s + 8.5);
    lP.xy += vec2(sin(T * .4), cos(T * .33)) * .6;

    float t = dither * 0.05;
    float d = 0.0;
    vec3 glow = vec3(0);
    float flick = .92 + .08 * sin(T * 13.0) * sin(T * 5.3);
    vec3 lCol = mix(LIGHT_COLOR, LIGHT_ACCENT, sin(T * 0.5) * 0.5 + 0.5);

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        float dL = length(p - lP);
        float dt = max(d * 0.7, 0.01);
        glow += lCol * (exp(-dL * 0.28) * 0.02 + exp(-dL * 1.4) * 0.05) * dt * flick;
        if (d < 0.0002 + 0.00025 * t || t > MAX_DIST) break;
        t += d * 0.7;
    }

    vec3 col = vec3(0);

    if (t < MAX_DIST) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p, t);
        vec3 v = -rd;

        vec3 lDir = lP - p;
        float lDist = length(lDir);
        lDir /= lDist;

        float ao = calcAO(p, n);
        float shadow = calcSoftShadow(p + n * 0.008, lDir, 0.02, lDist, 24.0);

        float detailNoise = hash31(floor(p * 8.0));
        vec3 baseAlbedo = mix(vec3(0.015, 0.025, 0.045), vec3(0.1, 0.14, 0.22), sin(p.z * 0.1) * 0.5 + 0.5);
        vec3 albedo = mix(baseAlbedo, baseAlbedo * 1.5, detailNoise * 0.3);

        float roughness = mix(0.08, 0.4, hash12(floor(p.xz * 3.0)));
        float metallic = mix(0.8, 0.95, detailNoise);

        vec3 F0 = mix(vec3(0.04), albedo, metallic);
        vec3 h = normalize(v + lDir);

        float NDF = distributionGGX(n, h, roughness);
        float G = geometrySmith(n, v, lDir, roughness);
        vec3 F = fresnelSchlick(max(dot(h, v), 0.0), F0);

        vec3 kD = (vec3(1.0) - F) * (1.0 - metallic);
        float denominator = 4.0 * max(dot(n, v), 0.0) * max(dot(n, lDir), 0.0) + 0.00001;
        vec3 specular = NDF * G * F / denominator;

        float NdotL = max(dot(n, lDir), 0.0);
        float attenuation = 55.0 * flick / (1.0 + lDist * lDist * 0.035);
        vec3 radiance = mix(LIGHT_COLOR, LIGHT_ACCENT, sin(p.z * 0.05) * 0.5 + 0.5) * attenuation;

        vec3 Lo = (kD * albedo / PI + specular) * radiance * NdotL * shadow;

        vec3 r = reflect(-v, n);
        vec3 envSpec = mix(LIGHT_ACCENT * 0.25, LIGHT_COLOR * 0.75, smoothstep(-0.5, 0.8, r.y));
        float spotRef = pow(max(dot(r, normalize(lP - p)), 0.0), 24.0);
        envSpec += lCol * spotRef * 1.5;
        vec3 F_env = fresnelSchlickRoughness(max(dot(n, v), 0.0), F0, roughness);
        vec3 ambient = (kD * albedo + envSpec * F_env) * 0.25 * ao;

        float pulse = 0.5 + 0.5 * sin(p.z * 0.4 - T * 0.8);
        vec3 emis = mix(LIGHT_COLOR, LIGHT_ACCENT, sin(p.z * 0.07) * 0.5 + 0.5) * pow(1.0 - ao, 3.0) * 0.14 * pulse;

        float rim = pow(1.0 - max(dot(n, v), 0.0), 4.0);
        vec3 rimCol = lCol * rim * 0.06 * ao;

        col = Lo + ambient + emis + rimCol;
        col *= smoothstep(MAX_DIST, MAX_DIST * 0.6, t);
    } else {
        col = FOG_COLOR;
    }

    float fogAmt = 1.0 - exp(-0.015 * t);
    vec3 fogTint = FOG_COLOR + lCol * 0.004 * (0.5 + 0.5 * dot(rd, normalize(lP - ro)));
    col = mix(col, fogTint, fogAmt);
    col += glow;

    return col;
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;

    float dither = hash12(fragCoord + vec2(iTime * 123.45));

    vec3 col = renderScene(uv, dither);

    float r2 = dot(uv, uv);
    col *= vec3(1.0 + r2 * 0.12, 1.0, 1.0 - r2 * 0.12);

    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);

    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));
    col = mix(vec3(luma), col, 1.12);
    col = mix(col, col * vec3(0.92, 1.0, 1.08), 0.5);

    vec3 finalColor = pow(max(col, 0.0), vec3(1.0 / 2.2));

    float vig = 1.0 - smoothstep(0.25, 1.05, length(uv * vec2(0.9, 1.1)));
    finalColor *= mix(0.35, 1.0, vig);

    float grain = hash12(fragCoord + fract(iTime) * 91.7) - 0.5;
    finalColor += grain * (1.6 / 255.0) * (1.5 - luma);
    finalColor += (dither - 0.5) * (1.0 / 255.0);

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}
