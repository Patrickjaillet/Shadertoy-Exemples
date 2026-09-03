// ==== Image (image) ====
#define MAX_STEPS 256
#define SURF_DIST .0005
#define MAX_DIST 120.
#define PI 3.14159265359

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float Hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

vec3 GetSky(vec3 rd) {
    vec3 sunDir = normalize(vec3(0.8, 0.35, -1.0));
    float cosTheta = dot(rd, sunDir);
    float rayleighPhase = 0.75 * (1.0 + cosTheta * cosTheta);
    vec3 betaR = vec3(5.8e-3, 1.35e-2, 3.31e-2); 
    vec3 betaM = vec3(21e-3); 
    float zenith = acos(max(0.0, rd.y));
    float opticalDepth = 1.0 / (cos(zenith) + 0.15 * pow(93.885 - (zenith * 180.0 / PI), -1.253));
    vec3 transmission = exp(-(betaR + betaM) * opticalDepth);
    float g = 0.82;
    float miePhase = (1.0 - g * g) / (4.0 * PI * pow(1.0 + g * g - 2.0 * g * cosTheta, 1.5));
    vec3 col = (betaR * rayleighPhase + betaM * miePhase) / (betaR + betaM);
    vec3 skyCol = col * (1.0 - transmission);
    return skyCol * vec3(1.0, 0.92, 0.85);
}

vec3 ACESFilm(vec3 x) {
    float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

vec2 GetDist(vec3 p) {
    float t = iTime * 0.2;
    float ground = p.y + 2.5 + Hash21(p.xz * 0.1) * 0.01;
    vec2 res = vec2(ground, 1.0);
    vec3 pW = p - vec3(0, 2.5, 8.0);
    
    float support = 1e10;
    for(float i = -1.0; i <= 1.0; i += 2.0) {
        float xSide = i * 0.8;
        support = min(support, sdCapsule(pW, vec3(xSide, 0.0, 0.0), vec3(xSide * 2.8, -5.0, 3.0), 0.15));
        support = min(support, sdCapsule(pW, vec3(xSide, 0.0, 0.0), vec3(xSide * 2.8, -5.0, -3.0), 0.15));
        support = min(support, sdCapsule(pW, vec3(xSide * 2.0, -2.5, -1.8), vec3(xSide * 2.0, -2.5, 1.8), 0.08));
    }
    support = min(support, sdCapsule(pW, vec3(-1.0, 0, 0), vec3(1.0, 0, 0), 0.25));
    if(support < res.x) res = vec2(support, 2.0);

    vec3 pR = pW;
    pR.yz *= Rot(t);
    float ringOuter = abs(length(pR.yz) - 4.2) - 0.05;
    float ringInner = abs(length(pR.yz) - 4.1) - 0.03;
    float wheelStructure = max(min(ringOuter, ringInner), abs(pR.x) - 0.6);
    
    float angle = atan(pR.z, pR.y);
    float id = floor(angle / (2.0 * PI / 16.0) + 0.5);
    vec3 pSpoke = pR;
    pSpoke.yz *= Rot(-id * (2.0 * PI / 16.0));
    float spokes = min(length(pSpoke.xz - vec2(0.1, 0.0)) - 0.03, length(pSpoke.xz - vec2(-0.1, 0.0)) - 0.03);
    wheelStructure = min(wheelStructure, max(spokes, abs(pSpoke.y) - 4.2));
    if(wheelStructure < res.x) res = vec2(wheelStructure, 2.0);
    
    vec3 pC = pR;
    pC.yz *= Rot(-id * (2.0 * PI / 16.0));
    pC.y -= 4.2;
    pC.yz *= Rot(id * (2.0 * PI / 16.0) + t); 
    
    float body = sdBox(pC, vec3(0.4, 0.45, 0.35)) - 0.02;
    float interior = sdBox(pC, vec3(0.38, 0.43, 0.33));
    float glass = max(body, -interior);
    float seat = sdBox(pC - vec3(0, -0.2, 0), vec3(0.3, 0.1, 0.25));

    if(seat < res.x) res = vec2(seat, 3.0);
    if(glass < res.x) res = vec2(glass, 4.0);
    
    return res;
}

vec3 GetNormal(vec3 p) {
    vec2 e = vec2(.001, 0);
    return normalize(GetDist(p).x - vec3(GetDist(p - e.xyy).x, GetDist(p - e.yxy).x, GetDist(p - e.yyx).x));
}

float GetShadow(vec3 p, vec3 lightDir) {
    float res = 1.0, t = 0.02;
    for(int i=0; i<40; i++) {
        float h = GetDist(p + lightDir * t).x;
        if(h < 0.001) return 0.0;
        res = min(res, 16.0 * h / t);
        t += h;
        if(t > 30.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float cycle = mod(iTime, 24.0);
    vec3 ro, lookAt;
    float fov = 1.0;

    if(cycle < 6.0) {
        float t = cycle / 6.0;
        ro = vec3(15.0 * sin(t * PI * 0.5), 2.0 + t * 5.0, 15.0 * cos(t * PI * 0.5) + 8.0);
        lookAt = vec3(0, 2.5, 8.0);
    } else if(cycle < 12.0) {
        float t = (cycle - 6.0) / 6.0;
        ro = vec3(-8.0, 8.0 - t * 6.0, 8.0 + 10.0 * sin(t * PI));
        lookAt = vec3(0, 1.5, 8.0);
        fov = 1.5 - t * 0.5;
    } else if(cycle < 18.0) {
        float t = (cycle - 12.0) / 6.0;
        float angle = iTime * 0.2;
        vec3 target = vec3(0, 2.5, 8.0);
        vec3 orbit = vec3(6.0 * sin(angle), 4.5 * cos(angle), 6.0 * cos(angle));
        ro = target + orbit;
        lookAt = target;
        fov = 0.8;
    } else {
        float t = (cycle - 18.0) / 6.0;
        ro = vec3(2.0, -1.5, 2.0 + t * 4.0);
        lookAt = vec3(0, 6.0, 8.0);
        fov = 1.2;
    }

    vec3 f = normalize(lookAt - ro), r = normalize(cross(vec3(0, 1, 0), f)), u = cross(f, r);
    vec3 rd = normalize(f * fov + uv.x * r + uv.y * u);

    float dO = 0.0;
    vec2 dS;
    for(int i=0; i<MAX_STEPS; i++) {
        dS = GetDist(ro + rd * dO);
        if(abs(dS.x) < SURF_DIST || dO > MAX_DIST) break;
        dO += dS.x;
    }

    vec3 sky = GetSky(rd);
    vec3 col = sky;

    if(dO < MAX_DIST) {
        vec3 p = ro + rd * dO;
        vec3 n = GetNormal(p);
        vec3 ref = reflect(rd, n);
        vec3 sunDir = normalize(vec3(0.8, 0.4, -1.0));
        float shadow = GetShadow(p, sunDir);
        float diff = max(dot(n, sunDir), 0.0) * shadow;
        float fresnel = pow(clamp(1.0 + dot(rd, n), 0.0, 1.0), 5.0);
        
        if(dS.y == 1.0) {
            vec2 gv = fract(p.xz * 0.5) - 0.5;
            float line = smoothstep(0.48, 0.5, max(abs(gv.x), abs(gv.y)));
            vec3 groundCol = mix(vec3(0.06), vec3(0.12), line);
            groundCol = mix(groundCol, vec3(0.01), smoothstep(6.0, 5.5, length(p.xz - vec2(0, 8))));
            col = groundCol * (diff + 0.1) + GetSky(ref) * 0.1 * fresnel;
        } 
        else if(dS.y == 4.0) {
            vec3 refr = GetSky(refract(rd, n, 1.0/1.45));
            col = mix(refr, GetSky(ref), 0.1 + 0.9 * fresnel);
            dO += 0.05;
            for(int i=0; i<60; i++) {
                dS = GetDist(ro + rd * dO);
                if(abs(dS.x) < SURF_DIST || dO > MAX_DIST) break;
                dO += dS.x;
            }
            if(dO < MAX_DIST) {
                vec3 p2 = ro + rd * dO;
                vec3 n2 = GetNormal(p2);
                col *= (max(dot(n2, sunDir), 0.0) + 0.2);
            }
        }
        else {
            vec3 mat = (dS.y == 2.0) ? vec3(0.85) : vec3(0.8, 0.05, 0.05);
            col = mat * (diff + 0.15) + GetSky(ref) * fresnel * 0.6;
        }
        col = mix(col, sky, 1.0 - exp(-0.00005 * dO * dO * dO));
    }

    col = ACESFilm(col);
    col = pow(col, vec3(0.4545));
    
    float flash = smoothstep(0.1, 0.0, abs(mod(cycle, 6.0)));
    col = mix(col, vec4(0).rgb, flash);
    
    fragColor = vec4(col, 1.0);
}
