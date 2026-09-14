// ==== Image (image) ====
const vec3 RAY_PARAMS = vec3(256.0, 0.0001, 100.0);
const vec3 LIGHT_BASE = vec3(0.12, 0.45, 0.95);
const vec2 LOOP_PARAMS = vec2(16.0, 48.0);
const float PI = 3.14159265359;

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hash12(vec2 p) {
    vec3 p3 = fract(p.xyx * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float sStep(float x) {
    float x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
}

struct Motion { float t; float look; float tilt; };

Motion getCinematicSequence(float time) {
    float phase = mod(time, LOOP_PARAMS.x) / LOOP_PARAMS.x;
    float t_p, look = 0.0, tilt = 0.0, p;
    if (phase < 0.25) {
        t_p = mix(0.0, 12.0, sStep(phase / 0.25));
    } else if (phase < 0.625) {
        p = (phase - 0.25) / 0.375;
        t_p = 12.0;
        float s = sStep(p);
        look = sin(s * PI * 2.0) * 1.3;
        tilt = cos(s * PI * 2.0) * 0.4;
        float fade = smoothstep(0.0, 0.1, p) * smoothstep(1.0, 0.9, p);
        look *= fade; tilt *= fade;
    } else {
        t_p = mix(12.0, LOOP_PARAMS.y, sStep((phase - 0.625) / 0.375));
    }
    return Motion(floor(time / LOOP_PARAMS.x) * LOOP_PARAMS.y + t_p, look, tilt);
}

vec3 getPath(float z) {
    return vec3(sin(z * 0.12) * 7.0 + cos(z * 0.05) * 2.0, cos(z * 0.11) * 4.0 + sin(z * 0.08) * 3.0, z);
}

vec3 getOrbPos(float time) {
    Motion m = getCinematicSequence(time);
    return getPath(m.t + 14.0 + sin(time * 2.0) * 2.0);
}

float map(vec3 p, float time) {
    vec3 q = p;
    q.xy -= getPath(q.z).xy;
    q.xy *= rot(q.z * 0.04 + time * 0.05);
    float d = max(abs(q.x), abs(q.y)) - 14.0;
    float s = 1.0;
    for(int i = 0; i < 5; i++) {
        vec3 r = abs(1.0 - 3.2 * abs(mod(q * s, 2.0) - 1.0));
        float c = min(max(r.x, r.y), min(max(r.y, r.z), max(r.z, r.x)));
        d = max(d, (c - 1.0) / s);
        s *= 2.85;
    }
    return min(d, length(p - getOrbPos(time)) - 0.9);
}

vec3 getNormal(vec3 p, float time) {
    vec2 e = vec2(0.0005, 0.0);
    return normalize(vec3(
        map(p + e.xyy, time) - map(p - e.xyy, time),
        map(p + e.yxy, time) - map(p - e.yxy, time),
        map(p + e.yyx, time) - map(p - e.yyx, time)
    ));
}

float calcAO(vec3 p, vec3 n, float time) {
    float occ = 0.0, sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + h * n, time);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

float calcSoftShadow(vec3 ro, vec3 rd, float mint, float tmax, float time) {
    float res = 1.0;
    float t = mint;
    float ph = 1e10;
    for(int i = 0; i < 64; i++) {
        float h = map(ro + rd * t, time);
        float y = h * h / (2.0 * ph);
        float d = sqrt(max(0.0, h * h - y * y));
        res = min(res, 10.0 * d / max(0.0, t - y));
        ph = h;
        t += h;
        if(res < 0.0001 || t > tmax) break;
    }
    return clamp(res, 0.0, 1.0);
}

float ggxDistribution(vec3 n, vec3 h, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float nDotH = max(dot(n, h), 0.0);
    float nDotH2 = nDotH * nDotH;
    float num = a2;
    float denom = (nDotH2 * (a2 - 1.0) + 1.0);
    return num / (PI * denom * denom);
}

float geometrySchlickGGX(float nDotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    return nDotV / (nDotV * (1.0 - k) + k);
}

float geometrySmith(vec3 n, vec3 v, vec3 l, float roughness) {
    float nDotV = max(dot(n, v), 0.0);
    float nDotL = max(dot(n, l), 0.0);
    return geometrySchlickGGX(nDotV, roughness) * geometrySchlickGGX(nDotL, roughness);
}

vec3 fresnelSchlick(float cosTheta, vec3 f0) {
    return f0 + (1.0 - f0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float henyeyGreenstein(float g, float costh) {
    return (1.0 - g * g) / (4.0 * PI * pow(1.0 + g * g - 2.0 * g * costh, 1.5));
}

vec3 render(vec2 uv, float time, vec2 fragCoord) {
    Motion m = getCinematicSequence(time);
    vec3 ro = getPath(m.t);
    vec3 tar = getPath(m.t + 5.0);
    vec3 cw = normalize(tar - ro);
    vec3 ri = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(ri, cw);
    
    cw = normalize(cw + ri * m.look + up * m.tilt);
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(uv.x * cu + uv.y * cv + cw * (1.6 - abs(m.look) * 0.3));
    
    vec3 oP = getOrbPos(time);
    float t = 0.0, d;
    float volAcc = 0.0;
    vec3 volCol = vec3(0.0);
    
    for(int i = 0; i < int(RAY_PARAMS.x); i++) {
        vec3 p = ro + rd * t;
        d = map(p, time);
        
        float distToOrb = length(p - oP);
        float density = exp(-distToOrb * 0.6);
        float hg = henyeyGreenstein(0.6, dot(rd, normalize(oP - p)));
        volCol += density * hg * LIGHT_BASE * 1.5 * d;
        
        if(d < RAY_PARAMS.y || t > RAY_PARAMS.z) break;
        t += d * 0.75;
    }
    
    vec3 col = vec3(0.0);
    
    if(t < RAY_PARAMS.z) {
        vec3 p = ro + rd * t;
        float distToOrb = length(p - oP);
        
        if(distToOrb < 1.0) {
            col = LIGHT_BASE * 50.0;
        } else {
            vec3 n = getNormal(p, time);
            vec3 v = -rd;
            vec3 l = normalize(oP - p);
            vec3 h = normalize(v + l);
            
            float distance = length(oP - p);
            float attenuation = 1.0 / (1.0 + distance * distance * 0.05);
            vec3 radiance = LIGHT_BASE * 200.0 * attenuation;
            
            vec3 albedo = vec3(0.02);
            float roughness = 0.3;
            float metallic = 0.8;
            
            vec3 f0 = mix(vec3(0.04), albedo, metallic);
            vec3 F = fresnelSchlick(max(dot(h, v), 0.0), f0);
            float NDF = ggxDistribution(n, h, roughness);
            float G = geometrySmith(n, v, l, roughness);
            
            vec3 numerator = NDF * G * F;
            float denominator = 4.0 * max(dot(n, v), 0.0) * max(dot(n, l), 0.0) + 0.0001;
            vec3 specular = numerator / denominator;
            
            vec3 kS = F;
            vec3 kD = vec3(1.0) - kS;
            kD *= 1.0 - metallic;
            
            float nDotL = max(dot(n, l), 0.0);
            float shadow = calcSoftShadow(p, l, 0.05, distance, time);
            float ao = calcAO(p, n, time);
            
            col = (kD * albedo / PI + specular) * radiance * nDotL * shadow * ao;
            
            vec3 r = reflect(-v, n);
            vec3 env = textureLod(iChannel0, r, roughness * 5.0).rgb;
            col += env * F * ao * 0.5;
            
            col *= smoothstep(RAY_PARAMS.z, 0.0, t);
        }
    }
    
    col += volCol * (0.85 + 0.15 * hash12(fragCoord + time));
    col = mix(col, vec3(0.005, 0.01, 0.02), 1.0 - exp(-0.01 * t));
    
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    return pow(max(col, 0.0), vec3(0.4545));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 tot = vec3(0.0);
    float bayer[4] = float[](0.0, 0.5, 0.75, 0.25);
    
    for(int m = 0; m < 4; m++) {
        vec2 off = vec2(float(m % 2), float(m / 2)) * 0.5;
        vec2 p = fragCoord + off;
        vec2 uv = (p - 0.5 * iResolution.xy) / iResolution.y;
        
        float timeOffset = (bayer[m] / 4.0) * (1.0 / 60.0); 
        tot += render(uv, iTime + timeOffset, p);
    }
    
    tot /= 4.0;
    
    vec2 uv0 = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    tot *= 1.15 * (1.0 - length(uv0) * 0.55);
    
    fragColor = vec4(tot, 1.0);
}
