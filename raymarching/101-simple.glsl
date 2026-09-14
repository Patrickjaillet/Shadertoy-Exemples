// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 cp5(vec2 z) {
    float x = z.x, y = z.y, x2 = x * x, y2 = y * y;
    return vec2(x * (x2 * x2 - 10.0 * x2 * y2 + 5.0 * y2 * y2), y * (5.0 * x2 * x2 - 10.0 * x2 * y2 + y2 * y2));
}

vec2 cp4(vec2 z) {
    float x = z.x, y = z.y, x2 = x * x, y2 = y * y;
    return vec2(x2 * x2 - 6.0 * x2 * y2 + y2 * y2, 4.0 * x * y * (x2 - y2));
}

float smax(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (a - b) / k, 0.0, 1.0);
    return mix(b, a, h) + k * h * (1.0 - h);
}

float map(vec3 p) {
    vec3 p0 = p;
    p *= 1.4;
    p.xz *= rot(iTime * 0.15349);
    p.yz *= rot(iTime * 0.10732);
    p.xy *= rot(sin(iTime * 0.12) * 1.5);

    vec3 rotationAxis = normalize(vec3(-4.0, sin(iTime) + 7.0, 0.0));
    float rotationAngle = iTime * 0.5;
    float cosineAngle = cos(rotationAngle);
    float sineAngle = sin(rotationAngle);
    p = p * cosineAngle - cross(rotationAxis, p) * sineAngle + rotationAxis * dot(rotationAxis, p) * (1.0 - cosineAngle);

    float w = (sin(iTime * 0.321) + sin(iTime * 0.413) * 0.5 + cos(iTime * 0.279) * 0.25) * 1.5;

    vec2 z1 = p.xy;
    vec2 z2 = vec2(p.z, w);

    vec2 v1 = cp5(z1);
    vec2 v2 = cp5(z2);
    
    float cx = sin(iTime * 0.215) * 1.8 * cos(iTime * 0.131);
    float cy = cos(iTime * 0.178) * 1.8 * sin(iTime * 0.194);
    
    vec2 val = v1 + v2 - vec2(cx, cy);

    float f = length(val);
    vec2 d1 = cp4(z1) * -4.2;
    vec2 d2 = cp4(z2) * 5.0;

    float grad = sqrt(dot(d1, d1) + dot(d2, d2) + 1e-4);
    float d = 0.5 * f / grad;

    float tk = 0.065 + sin(iTime * 0.45) * 0.045;
    d = abs(d) - tk;
    d /= 0.8;

    float bounds = length(p0) - 2.1;
    d = smax(d, bounds, 0.1);

    return d;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.001;
    return normalize(e.xyy * map(p + e.xyy) +
                     e.yyx * map(p + e.yyx) +
                     e.yxy * map(p + e.yxy) +
                     e.xxx * map(p + e.xxx));
}

float softshadow(vec3 ro, vec3 rd, float mint, float tmax, float k) {
    float res = 1.0;
    float t = mint;
    for(int i = 0; i < 30; i++) {
        float h = map(ro + rd * t);
        res = min(res, k * h / t);
        t += clamp(h, 0.005, 0.1);
        if(h < 0.001 || t > tmax) break;
    }
    return clamp(res, 0.0, 1.0);
}

float calcAO(vec3 pos, vec3 nor) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(pos + h * nor);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 1.5 * occ, 0.0, 1.0);
}

vec3 iridescence(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    vec3 volColor = vec3(0.0);
    float rayDistance = 0.0;
    
    vec3 shift = vec3(
        sin(iTime * 0.4) * 0.3 + 0.5,
        cos(iTime * 0.3) * 0.3 + 0.7,
        sin(iTime * 0.5) * 0.3 + 0.9
    );

    for (int step = 0; step < 16; step++) {
        vec3 vp = vec3(uv * (4.0 + sin(iTime) * 1.0), rayDistance + 0.1);
        
        vp.xy *= rot(iTime * 0.25);
        vp.yz *= rot(iTime * 0.18);
        
        float scale = 1.0;
        for (int i = 0; i < 5; i++) {
            vp = abs(vp) - shift;
            float factor = max(0.8, 2.0 / dot(vp, vp));
            vp *= factor;
            scale *= factor;
        }
        
        float density = length(vp.xy) / scale;
        rayDistance += density * 0.4;
        
        float hue = 0.6 + sin(iTime * 0.1) * 0.1;
        float val = scale * 0.0002;
        vec3 hsvBase = clamp(abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        vec3 rgb = val * mix(vec3(1.0), hsvBase, 0.5);
        
        volColor += rgb;
    }

    vec3 ro = vec3(0.0, 0.0, 3.9);
    
    vec3 p = vec3(uv * 3.0, 0.5);
    float angle = iTime * 0.2;
    p.xy *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    
    vec3 rd = normalize(p - ro);

    vec2 m = iMouse.xy / iResolution.xy;
    if(iMouse.z < 1.0) m = vec2(0.5, 0.5);

    mat2 rx = rot(m.y * 6.9500 - 2.4700);
    mat2 ry = rot(-m.x * 11.1500);
    ro.yz *= rx;
    rd.yz *= rx;
    ro.xz *= ry;
    rd.xz *= ry;

    float t = 0.0, d = 0.0, g = 0.0;
    float accumulatedDistance = 0.0;
    float accumulatedScale = 0.0;

    for(int i = 0; i < 200; i++) {
        vec3 pos = ro + rd * t;
        d = map(pos);
        if(abs(d) < 0.0005 || t > 10.0) break;
        t += d * 0.8;
        accumulatedDistance += abs(d);
        accumulatedScale += 1.0 / (0.01 + abs(d));
        g += 0.17 / (0.20 + abs(d));
    }

    float hue = 0.59;
    float saturation = 0.4 - accumulatedDistance * 0.05;
    float value = accumulatedScale / 4000.0;

    vec3 hueVector = mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0);
    vec3 pureColor = clamp(abs(hueVector - 3.0) - 1.0, 0.0, 1.0);
    vec3 finalRgbColor = value * mix(vec3(1.0), pureColor, saturation);

    vec3 col = (finalRgbColor + volColor) * (1.0 - length(uv) * 0.5);

    if(t < 10.0) {
        vec3 pos = ro + rd * t;
        vec3 nor = calcNormal(pos);
        vec3 lig = normalize(vec3(1.0, 0.9, 0.2));
        vec3 hal = normalize(lig - rd);
        vec3 ref = reflect(rd, nor);

        float dif = clamp(dot(nor, lig), 0.0, 1.0);
        float sha = softshadow(pos, lig, 0.02, 2.5, 16.0);
        float ao = calcAO(pos, nor);
        float fre = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 3.0);
        float spe = pow(clamp(dot(nor, hal), 0.0, 1.0), 32.0) * dif;

        vec3 base = finalRgbColor + volColor + vec3(0.05);
        col = base * ao;
        col += dif * sha * vec3(0.9, 0.95, 1.0) * ao;
        col += spe * sha * ao;

        vec3 iri = iridescence(dot(nor, -rd) * 2.0 + iTime * 0.1);
        col += fre * iri * ao * 0.8;

        float dom = smoothstep(-0.2, 0.8, ref.y);
        col += dom * vec3(0.02, 0.05, 0.1) * fre * ao;
    }

    col += vec3(0.7, 0.2, 0.9) * g * 0.0015;
    col += vec3(0.1, 0.4, 0.9) * g * g * 0.00005;

    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
