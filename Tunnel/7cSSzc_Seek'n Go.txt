// ==== Image (image) ====
const vec3 RAY_PARAMS = vec3(160.0, 0.0003, 90.0);
const vec3 LIGHT_COLOR = vec3(0.05, 0.85, 1.0);
const vec3 LIGHT_ACCENT = vec3(0.95, 0.25, 0.85);
const vec2 LOOP_PARAMS = vec2(16.0, 48.0);

mat2 rot(float a) {
    vec2 s = sin(vec2(a, a + 1.5707963));
    return mat2(s.y, -s.x, s.x, s.y);
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

float sStep(float x) {
    return x * x * x * (x * (x * 6. - 15.) + 10.);
}

struct Motion { float t; float look; float tilt; };

Motion getCinematicSequence(float time) {
    float phase = mod(time, LOOP_PARAMS.x) / LOOP_PARAMS.x;
    float t_p, look = 0., tilt = 0., p;
    
    if (phase < .25) {
        t_p = mix(0., 12., sStep(phase / .25));
    } else if (phase < .625) {
        p = (phase - .25) / .375;
        t_p = 12.;
        float s = sStep(p);
        look = sin(s * 6.2831853) * 1.3;
        tilt = cos(s * 6.2831853) * 0.4;
        float fade = smoothstep(0., .1, p) * smoothstep(1., .9, p);
        look *= fade; tilt *= fade;
    } else {
        t_p = mix(12., LOOP_PARAMS.y, sStep((phase - .625) / .375));
    }
    return Motion(floor(time / LOOP_PARAMS.x) * LOOP_PARAMS.y + t_p, look, tilt);
}

vec3 getPath(float z) {
    return vec3(sin(z * .12) * 7. + cos(z * .05) * 2., cos(z * .11) * 4. + sin(z * .08) * 3., z);
}

float map(vec3 p) {
    vec3 q = p;
    q.xy -= getPath(q.z).xy;
    q.xy *= rot(q.z * .04 + iTime * .05);
    float d = max(abs(q.x), abs(q.y)) - 14., s = 1.0;
    for(int i = 0; i < 4; i++) {
        vec3 r = abs(1. - 3.2 * abs(mod(q * s, 2.) - 1.));
        d = max(d, (min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x))) - 1.) / (s *= 2.85));
    }
    return d;
}

float surfaceNoise(vec3 p) {
    return (sin(p.x * 30.0) * sin(p.y * 30.0) * sin(p.z * 30.0)) * 0.003;
}

vec3 getNormal(vec3 p, float t) {
    float eps = max(0.0005, 0.00015 * t);
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
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.15 * float(i) / 4.0;
        float d = map(p + h * n);
        occ += (h - d) * sca;
        sca *= 0.90;
        if(occ > 0.35) break;
    }
    return clamp(1.0 - 2.8 * occ, 0.0, 1.0);
}

float calcSoftShadow(vec3 ro, vec3 rd, float mint, float maxt, float k) {
    float res = 1.0;
    float t = mint;
    float ph = 1e10;
    for(int i = 0; i < 32; i++) {
        float h = map(ro + rd * t);
        float y = h * h / (2.0 * ph);
        float d = sqrt(h * h - y * y);
        res = min(res, k * d / max(0.0, t - y));
        ph = h;
        t += clamp(h, 0.015, 0.25);
        if(res < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

float distributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;
    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = 3.14159265359 * denom * denom;
    return num / max(denom, 0.00001);
}

float geometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    return NdotV / (NdotV * (1.0 - k) + k);
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = geometrySchlickGGX(NdotV, roughness);
    float ggx1 = geometrySchlickGGX(NdotL, roughness);
    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness) {
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 renderScene(vec2 uv, float dither) {
    Motion m = getCinematicSequence(iTime);
    vec3 ro = getPath(m.t), 
         tar = getPath(m.t + 5.),
         cw = normalize(tar - ro),
         ri = normalize(cross(cw, vec3(0, 1, 0))),
         up = cross(ri, cw);
    
    cw = normalize(cw + ri * m.look + up * m.tilt);
    
    vec3 cu = normalize(cross(cw, vec3(0, 1, 0))), 
         cv = cross(cu, cw), 
         rd = normalize(uv.x * cu + uv.y * cv + cw * (1.6 - abs(m.look) * .3)),
         lP = getPath(m.t + 7.0),
         col = vec3(0);

    float t = dither * 0.05;
    float d = 0.0;
    float bloom = 0.0;
    
    for(int i = 0; i < int(RAY_PARAMS.x); i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        
        float dL = length(p - lP);
        bloom += exp(-dL * 0.3) * 0.012;
        
        if(d < RAY_PARAMS.y || t > RAY_PARAMS.z) break;
        t += d * 0.65;
    }
    
    vec3 fogColor = vec3(0.002, 0.004, 0.012);

    if(t < RAY_PARAMS.z) {
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
        
        vec3 kS = F;
        vec3 kD = (vec3(1.0) - kS) * (1.0 - metallic);
        
        vec3 numerator = NDF * G * F;
        float denominator = 4.0 * max(dot(n, v), 0.0) * max(dot(n, lDir), 0.0) + 0.00001;
        vec3 specular = numerator / denominator;
        
        float NdotL = max(dot(n, lDir), 0.0);
        float attenuation = 55.0 / (1.0 + lDist * lDist * 0.035);
        vec3 radiance = mix(LIGHT_COLOR, LIGHT_ACCENT, sin(p.z * 0.05) * 0.5 + 0.5) * attenuation;
        
        vec3 Lo = (kD * albedo / 3.14159265359 + specular) * radiance * NdotL * shadow;
        
        vec3 r = reflect(-v, n);
        vec3 envSpec = mix(LIGHT_ACCENT * 0.25, LIGHT_COLOR * 0.75, smoothstep(-0.5, 0.8, r.y));
        vec3 F_env = fresnelSchlickRoughness(max(dot(n, v), 0.0), F0, roughness);
        vec3 ambient = (kD * albedo + envSpec * F_env) * 0.25 * ao;
        
        col = Lo + ambient;
        col *= smoothstep(RAY_PARAMS.z, RAY_PARAMS.z * 0.6, t);
    } else {
        col = fogColor;
    }
    
    vec3 lightEmissive = mix(LIGHT_COLOR, LIGHT_ACCENT, sin(iTime * 0.5) * 0.5 + 0.5);
    col += lightEmissive * bloom;
    
    col = mix(col, fogColor, 1.0 - exp(-0.015 * t));
    
    return col;
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;
    
    float dither = hash12(fragCoord + vec2(iTime * 123.45));
    
    float caDist = length(uv) * 0.008;
    vec3 col;
    col.r = renderScene(uv * (1.0 + caDist), dither).r;
    col.g = renderScene(uv, dither).g;
    col.b = renderScene(uv * (1.0 - caDist), dither).b;
    
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    
    vec3 finalColor = pow(max(col, 0.0), vec3(1.0 / 2.2));
    finalColor *= 1.1 - length(uv) * 0.5;
    
    finalColor += (dither - 0.5) * (1.0 / 255.0);
    
    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}
