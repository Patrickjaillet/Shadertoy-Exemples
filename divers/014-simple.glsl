// ==== Image (image) ====
#define STEPS 64
#define VOL_STEPS 48
#define L_STEPS 3
#define PI 3.14159265359

const mat3 m3 = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
const mat3 m3i = mat3(0.00, -0.80, -0.60, 0.80, 0.36, -0.48, 0.60, -0.48, 0.64);

float hash(vec3 p) {
    p = fract(p * vec3(443.8975, 397.2973, 491.1871));
    p += dot(p.xyz, p.yzx + 19.19);
    return fract(p.x * p.y * p.z);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    vec2 o = vec2(1.0, 0.0);
    return mix(
        mix(mix(hash(i + o.yyy), hash(i + o.xyy), f.x),
            mix(hash(i + o.yxy), hash(i + o.xxy), f.x), f.y),
        mix(mix(hash(i + o.yyx), hash(i + o.xyx), f.x),
            mix(hash(i + o.yxx), hash(i + o.xxx), f.x), f.y), 
        f.z
    );
}

float fbm(vec3 p) {
    float f = 0.0, a = 0.5;
    for(int i = 0; i < 5; i++) {
        f += a * noise(p);
        p = m3 * p * 2.2;
        a *= 0.48;
    }
    return f;
}

float fbm_fast(vec3 p) {
    float f = 0.0, a = 0.5;
    f += a * noise(p); p = p * 2.04; a *= 0.5;
    f += a * noise(p); p = p * 2.02; a *= 0.5;
    f += a * noise(p);
    return f / 0.875;
}

vec2 getTornadoPos(float t) {
    float x = noise(vec3(t * 0.12, 0.0, 0.0)) * 14.0 - 7.0;
    float z = noise(vec3(0.0, 0.0, t * 0.12)) * 14.0 - 7.0;
    return vec2(x, z);
}

float terrain(vec2 p) {
    vec3 p3 = vec3(p * 0.15, 0.0);
    float h = noise(p3) * 3.5;
    p3 = m3 * p3 * 2.5;
    h += noise(p3) * 1.2;
    p3 = m3 * p3 * 3.0;
    h += noise(p3) * 0.3;
    float path = smoothstep(0.5, 7.5, abs(p.x + sin(p.y * 0.08) * 6.0));
    return h * path - 3.5;
}

vec2 mapDebris(vec3 p, vec2 tPos, float h) {
    vec2 pXZ = p.xz - tPos;
    float r = length(pXZ);
    if (r > 12.0 || r < 0.6 + h * 0.25 || p.y > 5.5) return vec2(100.0, 1.0);
    
    float ang = atan(pXZ.y, pXZ.x) + iTime * 18.0 / (r + 0.3);
    vec3 q = vec3(r * 4.0, p.y * 4.0 - iTime * 7.0, ang * 2.5);
    vec3 id = floor(q);
    vec3 fq = fract(q) - 0.5;
    
    float hsh = hash(id);
    float d = length(max(abs(fq) - 0.03 * hsh, 0.0)) * 0.25;
    if (hsh > 0.15) d = 100.0;
    return vec2(d, 1.0);
}

float mapVol(vec3 p, vec2 tPos, float h, out float outLgt) {
    vec2 pXZ = p.xz - tPos;
    float r = length(pXZ);
    float coreR = 0.4 + exp(h * 0.32) * 0.85;
    float dBase = r - coreR;
    
    if (dBase > 5.5) { outLgt = 0.0; return 0.0; }
    
    float ang = atan(pXZ.y, pXZ.x) + iTime * 7.5 - h * 1.15;
    vec3 wp = vec3(r * cos(ang), p.y, r * sin(ang)) * 1.4 + vec3(0.0, -iTime * 4.5, 0.0);
    
    float n = fbm_fast(wp + fbm_fast(wp * 2.0) * 0.3);
    float dens = smoothstep(5.0, -0.8, dBase) * n;
    
    float groundDust = smoothstep(2.0, -0.5, h) * smoothstep(7.0, 0.5, r) * n * 1.8;
    dens = max(dens, groundDust);
    dens *= smoothstep(-4.5, -2.8, p.y);
    
    float fl = step(0.96, fract(sin(floor(iTime * 14.0)) * 43758.5453));
    float arc = length(pXZ + vec2(noise(p * 2.0), noise(p * 2.0 + 8.0)) * 1.8);
    outLgt = smoothstep(1.4, 0.0, arc) * fl * exp(-max(0.0, p.y - 1.5) * 0.25);
    
    return max(0.0, dens * 24.0);
}

float hg(float g, float costh) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * costh, 1.5));
}

vec4 cCyl(vec3 ro, vec3 rd, vec2 center, float radius, float heightMin, float heightMax) {
    vec2 o = ro.xz - center;
    vec2 d = rd.xz;
    float a = dot(d, d);
    float b = 2.0 * dot(o, d);
    float c = dot(o, o) - radius * radius;
    float det = b * b - 4.0 * a * c;
    if (det < 0.0) return vec4(-1.0);
    det = sqrt(det);
    float t1 = (-b - det) / (2.0 * a);
    float t2 = (-b + det) / (2.0 * a);
    float tmin = max(0.0, min(t1, t2));
    float tmax = max(0.0, max(t1, t2));
    float zMin1 = ro.y + rd.y * tmin;
    float zMin2 = ro.y + rd.y * tmax;
    if ((zMin1 < heightMin && zMin2 < heightMin) || (zMin1 > heightMax && zMin2 > heightMax)) return vec4(-1.0);
    return vec4(tmin, tmax, 0.0, 1.0);
}

vec3 render(vec3 ro, vec3 rd, vec2 uv, vec2 shake) {
    vec3 col = vec3(0.0);
    float jitter = hash(vec3(uv, fract(iTime)));
    float t = 0.2 * jitter;
    float dstep = 0.22;
    float trans = 1.0;
    
    vec3 sunDir = normalize(vec3(0.55, 0.38, -0.75));
    vec3 sunCol = vec3(1.3, 1.05, 0.88) * 15.0;
    vec3 ambCol = vec3(0.11, 0.14, 0.22) * 2.8;
    
    float ph = hg(0.62, dot(rd, sunDir)) * 0.65 + hg(-0.30, dot(rd, sunDir)) * 0.35;
    
    float tG = 160.0;
    if (rd.y < 0.0) {
        float tgTemp = -(ro.y + 3.5) / rd.y;
        if(tgTemp < tG) {
            for(int i = 0; i < 48; i++) {
                vec3 pG = ro + rd * tgTemp;
                float hG = pG.y - terrain(pG.xz);
                if(abs(hG) < 0.015) { tG = tgTemp; break; }
                tgTemp += hG * 0.72;
                if(tgTemp > 160.0) break;
            }
        }
    }

    vec2 tPosCurrent = getTornadoPos(iTime);
    vec4 bounds = cCyl(ro, rd, tPosCurrent, 15.0, -4.5, 6.5);
    
    float vStart = max(t, bounds.x);
    float vEnd = min(tG, bounds.y > 0.0 ? bounds.y : 160.0);
    vEnd = min(vEnd, 65.0);
    
    t = vStart + dstep * jitter;
    
    if (bounds.y > 0.0 && vStart < vEnd) {
        for(int i = 0; i < VOL_STEPS; i++) {
            if(trans < 0.008 || t > vEnd) break;
            vec3 p = ro + rd * t;
            float h = p.y + 3.5;
            
            float lgt = 0.0;
            float dens = mapVol(p, tPosCurrent, h, lgt);
            vec2 debData = mapDebris(p, tPosCurrent, h);
            
            if(debData.x < 0.04) {
                float dif = max(0.0, dot(sunDir, normalize(p)));
                col += trans * vec3(0.025, 0.018, 0.012) * dif * 16.0;
                trans *= 0.04;
            }
            
            if(dens > 0.005 || lgt > 0.0) {
                float sh = 0.0;
                vec3 lp = p;
                float ls = 0.45;
                
                for(int j = 0; j < L_STEPS; j++) {
                    lp += sunDir * ls;
                    float dummyLgt;
                    sh += mapVol(lp, tPosCurrent, lp.y + 3.5, dummyLgt);
                    ls *= 1.6;
                }
                
                vec3 scatt = sunCol * exp(-sh * 0.45) * ph;
                scatt += ambCol * exp(-dens * 0.22);
                scatt += vec3(0.68, 0.83, 1.0) * lgt * 340.0;
                
                col += trans * scatt * dens * dstep;
                trans *= exp(-dens * dstep);
            }
            t += dstep;
            dstep *= 1.038;
        }
    }
    
    if (tG < 160.0 && tG < vEnd && trans > 0.008) {
        t = tG;
    }
    
    if (t >= tG && tG < 160.0) {
        vec3 pG = ro + rd * tG;
        vec2 e = vec2(0.015, 0.0);
        vec3 n = normalize(vec3(
            terrain(pG.xz + e.xy) - terrain(pG.xz - e.xy),
            e.x * 2.0,
            terrain(pG.xz + e.yx) - terrain(pG.xz - e.yx)
        ));
        
        float dif = max(0.0, dot(n, sunDir));
        float sh = 0.0;
        vec3 lp = pG;
        float ls = 0.55;
        for(int j = 0; j < 6; j++) {
            lp += sunDir * ls;
            float dummyLgt;
            sh += mapVol(lp, tPosCurrent, lp.y + 3.5, dummyLgt);
            ls *= 1.7;
        }
        
        vec3 pG_static = pG - vec3(shake.x, shake.y, 0.0);
        vec3 tex = mix(vec3(0.16, 0.11, 0.07), vec3(0.23, 0.18, 0.13), fbm_fast(pG_static * 2.5));
        tex *= 0.45 + 0.55 * noise(pG_static * 12.0);
        col += trans * tex * (dif * sunCol * exp(-sh * 0.4) + ambCol);
        trans = 0.0;
    }
    
    if (trans > 0.0) {
        vec3 sky = mix(vec3(0.07, 0.11, 0.17), vec3(0.22, 0.27, 0.32), smoothstep(-0.2, 0.45, rd.y));
        float cloudNoise = fbm_fast(rd * 3.5 + vec3(iTime * 0.08, 0.0, 0.0));
        sky = mix(sky, vec3(0.13, 0.16, 0.20), smoothstep(0.25, 0.75, cloudNoise));
        sky += sunCol * pow(max(0.0, dot(rd, sunDir)), 52.0) * 0.75;
        col += sky * trans;
    }
    
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float shakeX = noise(vec3(iTime * 16.0, 0.0, 0.0)) * 0.035;
    float shakeY = noise(vec3(0.0, iTime * 16.0, 0.0)) * 0.035;
    vec2 shake = vec2(shakeX, shakeY);
    
    vec3 ro = vec3(shakeX, -0.5 + shakeY, -24.0);
    vec3 rd = normalize(vec3(uv, 1.25));
    
    vec3 col = render(ro, rd, uv, shake);
    
    col *= 0.92;
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    col = pow(clamp(col, 0.0, 1.0), vec3(0.4545));
    
    vec2 cuv = fragCoord / iResolution.xy;
    col *= 0.45 + 0.55 * pow(16.0 * cuv.x * cuv.y * (1.0 - cuv.x) * (1.0 - cuv.y), 0.14);
    
    fragColor = vec4(col, 1.0);
}
