// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 texUV = fragCoord / iResolution.xy;
    vec3 scene = texture(iChannel0, texUV).rgb;
    vec2 volum = texture(iChannel1, texUV).rg;
    
    vec3 cS = vec3(0.3, 0.9, 0.1), cF = vec3(0.4, 0.8, 0.2);
    vec3 col = scene + cS * volum.y * 0.018;
    col = mix(col, cF * 0.7, 1.0 - exp(-volum.x * 1.2));
    
    col *= 1.1 - length((fragCoord - 0.5 * iResolution.xy) / iResolution.y);
    fragColor = vec4(pow(max(col, 0.0), vec3(0.4545)), 1.0);
}

// ==== Common (common) ====
float hachage(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hachage2D(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float bruit(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hachage2D(i);
    float b = hachage2D(i + vec2(1.0, 0.0));
    float c = hachage2D(i + vec2(0.0, 1.0));
    float d = hachage2D(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float bruit3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 57.0 + i.z * 113.0;
    return mix(mix(mix(hachage(n), hachage(n + 1.0), u.x), mix(hachage(n + 57.0), hachage(n + 58.0), u.x), u.y),
               mix(mix(hachage(n + 113.0), hachage(n + 114.0), u.x), mix(hachage(n + 170.0), hachage(n + 171.0), u.x), u.y), u.z);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 6; i++) {
        v += a * bruit(p);
        p *= 2.1;
        a *= 0.5;
    }
    return v;
}

float fbm3D(vec3 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * bruit3D(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

float sdLustre(vec3 p) {
    float d = length(p.xy - vec2(0.0, 0.2)) - 0.05;
    return min(d, length(p.xz) - 0.02);
}

float sdAliens(vec3 p, float t) {
    float zR = mod(p.z - t * 15.0, 40.0) - 20.0;
    float d = 1e10, pa = 0.05, pf = 12.0, va = 0.02, vf = 28.0;
    vec3 pos[4];
    pos[0] = vec3(p.x, p.y - 2.1, zR);
    pos[1] = vec3(p.x - 1.7, p.y - 0.5, zR + 10.0);
    pos[2] = vec3(p.x + 1.7, p.y - 0.5, zR - 10.0);
    pos[3] = vec3(p.x - 0.5, p.y + 0.8, zR + 5.0);
    for(int i=0; i<4; i++) {
        float pulse = 0.2 + pa * (0.5 + 0.5 * sin(t * pf + float(i)));
        vec3 vib = va * (vec3(bruit3D(vec3(1.,2.,3.)+t*vf), bruit3D(vec3(4.,5.,6.)+t*vf), bruit3D(vec3(7.,8.,9.)+t*vf))-0.5);
        vec3 q = pos[i] + vib;
        d = min(d, length(q) - pulse + bruit(q.xz * 10.0) * 0.05);
    }
    return d * 0.6;
}

float carte(vec3 p, float t) {
    float v = 2.4 - length(vec2(p.x, p.y - 1.4));
    float m = 1.9 - abs(p.x);
    float s = p.y + 1.0 + fbm(p.xz * 3.0 + t * 0.5) * 0.12;
    float tun = min(min(v, m), s);
    vec3 pL = p;
    pL.z = mod(pL.z + 2.0, 4.0) - 2.0;
    float lus = min(sdLustre(pL - vec3(1.7, 0.5, 0.0)), sdLustre(pL - vec3(-1.7, 0.5, 0.0)));
    return min(min(tun, lus), sdAliens(p, t));
}

vec3 obtenirNormale(vec3 p, float t) {
    vec2 e = vec2(0.005, 0.0);
    return normalize(vec3(carte(p + e.xyy, t) - carte(p - e.xyy, t), carte(p + e.yxy, t) - carte(p - e.yxy, t), carte(p + e.yyx, t) - carte(p - e.yyx, t)));
}

// ==== Buffer A (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float cycle = smoothstep(-0.5, 0.5, sin(iTime * 0.6283));
    vec3 ro = vec3(0.0, 0.2, iTime * 0.8);
    vec3 rd = normalize(vec3(uv, 1.2));
    float aC = cycle * 3.14159, cA = cos(aC), sA = sin(aC);
    rd.xz *= mat2(cA, -sA, sA, cA);
    
    float t = 0.0, d;
    for (int i = 0; i < 80; i++) {
        d = carte(ro + rd * t, iTime);
        if (d < 0.001 || t > 25.0) break;
        t += d;
    }
    
    vec3 col = vec3(0.01), cS = vec3(0.3, 0.9, 0.1), cB = vec3(1.0, 0.5, 0.1);
    if (t < 25.0) {
        vec3 p = ro + rd * t, n = obtenirNormale(p, iTime);
        if (sdAliens(p, iTime) < 0.01) {
            col = vec3(0.02, 0.05, 0.02) + cS * pow(max(0.0, dot(n, -rd)), 2.0) * 0.4;
        } else {
            col = vec3(0.1) * fbm(p.xz * 2.0 + p.y * 1.5);
            vec2 pr = (p.y < -0.7) ? p.xz : vec2(atan(p.x, p.y - 1.4), p.z);
            float mS = smoothstep(0.35, 0.75, fbm(vec2(pr.x * 0.6, pr.y * 0.5 - iTime * 0.25) + fbm(pr * 2.5 + iTime * 0.5) * 0.4));
            col = mix(col, cS * 0.5, mS) + cS * mS * 0.8 * (0.8 + 0.2 * sin(iTime * 2.0 + p.z));
        }
        for(float i = 0.0; i < 3.0; i++) {
            float lZ = floor(p.z / 4.0 + 0.5 + i) * 4.0;
            vec3 pL = vec3(1.6, 0.7, lZ), pR = vec3(-1.6, 0.7, lZ);
            col += cB * (0.02 / pow(length(pL - p), 2.0) + 0.02 / pow(length(pR - p), 2.0));
            col += cB * (0.5 + 0.5 * sin(iTime * 10.0 + lZ)) * (smoothstep(0.1, 0.0, length(pL - p)) + smoothstep(0.1, 0.0, length(pR - p)));
        }
    }
    fragColor = vec4(col, t);
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float cycle = smoothstep(-0.5, 0.5, sin(iTime * 0.6283));
    vec3 ro = vec3(0.0, 0.2, iTime * 0.8), rd = normalize(vec3(uv, 1.2));
    float aC = cycle * 3.14159, cA = cos(aC), sA = sin(aC);
    rd.xz *= mat2(cA, -sA, sA, cA);

    float tMax = texture(iChannel0, fragCoord / iResolution.xy).a;
    float ab = 0.0, gl = 0.0, t = 0.0;
    for (int i = 0; i < 40; i++) {
        vec3 p = ro + rd * t;
        float d = carte(p, iTime);
        vec3 c = p * 0.4 - vec3(0.0, iTime * 0.2, p.z * 0.1);
        ab += smoothstep(0.4, 0.9, fbm3D(c + fbm3D(c * 1.5 + iTime * 0.3))) * (1.0 - smoothstep(0.0, 2.0, abs(p.x))) * 0.25;
        gl += 0.02 / (0.1 + d);
        t += 0.4;
        if (t > tMax || t > 25.0) break;
    }
    fragColor = vec4(ab, gl, 0.0, 1.0);
}
