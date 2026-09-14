// ==== Image (image) ====
#define OCTAVES 5

float hash(vec2 p) {
    vec2 st = fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
    return st.x;
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbmFold(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < OCTAVES; i++) {
        p = abs(p) - vec2(0.5);
        p *= 1.2;

        value += amplitude * abs(noise(p * frequency) - 0.5) * 2.0;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

float drawDigit(vec2 p, int digit) {
    p *= 1.8;
    vec2 absP = abs(p);
    float seg = 0.0;

    float t = 0.08;
    float h = 0.45;

    bool a = (digit != 1 && digit != 4);
    bool b = (digit != 5 && digit != 6);
    bool c = (digit != 2);
    bool d = (digit != 1 && digit != 4 && digit != 7);
    bool e = (digit == 0 || digit == 2 || digit == 6 || digit == 8);
    bool f = (digit != 1 && digit != 2 && digit != 3 && digit != 7);
    bool g = (digit != 0 && digit != 1 && digit != 7);

    if (a && absP.y > h - t && absP.y < h + t && absP.x < h) seg = 1.0;
    if (b && absP.x > h - t && absP.x < h + t && p.y > 0.0 && absP.y < h) seg = 1.0;
    if (c && absP.x > h - t && absP.x < h + t && p.y < 0.0 && absP.y < h) seg = 1.0;
    if (d && absP.y > -h - t && absP.y < -h + t && absP.x < h) seg = 1.0;
    if (e && absP.x > -h - t && absP.x < -h + t && p.y < 0.0 && absP.y < h) seg = 1.0;
    if (f && absP.x > -h - t && absP.x < -h + t && p.y > 0.0 && absP.y < h) seg = 1.0;
    if (g && absP.y > -t && absP.y < t && absP.x < h) seg = 1.0;

    return seg;
}

float drawChar(vec2 uv, int ascii) {
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 0.0;
    vec2 fontUV = (vec2(mod(float(ascii), 16.0), 15.0 - floor(float(ascii) / 16.0)) + uv) / 16.0;
    return texture(iChannel1, fontUV).r;
}

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdStar(vec2 p, float r, float n, float m) {
    float an = 3.14159265 / n;
    float en = 3.14159265 / m;
    vec2 acs = vec2(cos(an), sin(an));
    vec2 ecs = vec2(cos(en), sin(en));

    float bn = mod(atan(p.x, p.y), 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= r * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p) * sign(p.x);
}

float sdHexagon(vec2 p, float r) {
    vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

float sdCross(vec2 p, vec2 b, float r) {
    p = abs(p);
    p = (p.y > p.x) ? p.yx : p.xy;
    vec2 q = p - b;
    float k = max(q.y, q.x);
    vec2 w = (k > 0.0) ? q : vec2(b.y - p.x, -k);
    return sign(k) * length(max(w, 0.0)) + r;
}

float sdHeart(vec2 p) {
    p.x = abs(p.x);
    if (p.y + p.x > 1.0)
        return sqrt(dot(p - vec2(0.25, 0.75), p - vec2(0.25, 0.75))) - 0.35355;
    return sqrt(min(dot(p - vec2(0.00, 1.00), p - vec2(0.00, 1.00)),
                    dot(p - 0.5 * max(p.x + p.y, 0.0), p - 0.5 * max(p.x + p.y, 0.0)))) * sign(p.x - p.y);
}

float sdTorus(vec2 p, float r1, float r2) {
    return abs(length(p) - r1) - r2;
}

float sdGear(vec2 p, float r, float teeth) {
    float a = atan(p.y, p.x);
    float d = length(p) - r;
    d += sin(a * teeth) * 0.08;
    return d;
}

float sdVesica(vec2 p, float r, float d) {
    p = abs(p);
    float b = sqrt(r * r - d * d);
    return ((p.y - b) * d > p.x * b) ? length(p - vec2(0.0, b))
                                    : length(p - vec2(-d, 0.0)) - r;
}

float sdSpiral(vec2 p, float turns) {
    float a = atan(p.y, p.x);
    float r = length(p);
    float d = r - (a + 3.14159265) / (2.0 * 3.14159265) * 0.3;
    return abs(mod(d, 0.15) - 0.075) - 0.02;
}

float getSingleSDF(int id, vec2 p, float kick) {
    if (id == 0) return sdCircle(p, 0.35 + kick * 0.1);
    if (id == 1) return sdBox(p, vec2(0.3 + kick * 0.15));
    if (id == 2) return sdStar(p, 0.4 + kick * 0.2, 5.0, 2.5);
    if (id == 3) return sdHexagon(p, 0.35 + kick * 0.1);
    if (id == 4) return sdCross(p, vec2(0.35, 0.12), 0.02) - kick * 0.05;
    if (id == 5) return sdHeart(p * 1.5 - vec2(0.0, 0.2)) * 0.6 - kick * 0.05;
    if (id == 6) return sdTorus(p, 0.3, 0.08 + kick * 0.05);
    if (id == 7) return sdGear(p, 0.35, 8.0) - kick * 0.05;
    if (id == 8) return sdVesica(p, 0.4, 0.2) - kick * 0.05;
    return sdSpiral(p, 3.0) - kick * 0.03;
}

int pseudoRandomObj(int seed) {
    return int(mod(float(seed) * 7.0 + 3.0, 10.0));
}

float psychedelicMorphSDF(vec2 p, float t, float kick) {
    float angle = t * 2.0 + kick * 1.5;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    p = rot * p;

    float speed = t * 0.8;
    int currentSeed = int(floor(speed));
    float morphFactor = smoothstep(0.0, 1.0, fract(speed));

    int objA = pseudoRandomObj(currentSeed);
    int objB = pseudoRandomObj(currentSeed + 1);

    float dA = getSingleSDF(objA, p, kick);
    float dB = getSingleSDF(objB, p, kick);

    float d = mix(dA, dB, morphFactor);

    float distortion = sin(atan(p.y, p.x) * 8.0 + t * 5.0) * (0.05 + kick * 0.1);
    return d + distortion;
}

vec2 getShaderMode(vec2 uv, int mode) {
    float r = length(uv) + 1e-5;
    float a = atan(uv.y, uv.x);
    
    if (mode == 0) return vec2(log(r), a);
    if (mode == 1) return vec2(log2(r), a * 1.5);
    if (mode == 2) return vec2(log(r) * 0.43429, a);
    if (mode == 3) return vec2(log(abs(uv.x) + abs(uv.y) + 1e-5), a);
    if (mode == 4) return vec2(log(dot(uv, uv) + 1e-5) * 0.5, a + log(r));
    if (mode == 5) {
        float k = 3.14159 / 3.0;
        float ma = mod(a, k) - k * 0.5;
        return vec2(log(r), abs(ma));
    }
    if (mode == 6) {
        vec2 invUV = uv / (dot(uv, uv) + 1e-5);
        return vec2(log(length(invUV) + 1e-5), atan(invUV.y, invUV.x));
    }
    if (mode == 7) return vec2(log(r) + sin(a * 4.0) * 0.3, a);
    if (mode == 8) return vec2(log(abs(uv.x) + 1e-5), log(abs(uv.y) + 1e-5));
    return vec2(log(r), a + sin(log(r) * 5.0) * 0.5);
}

vec3 renderScene(vec2 uv, int mode, float demoTime, float kick, float kickToggle, float audioLow, float audioMid, float audioHigh) {
    float inversionCycle = sin(demoTime * (3.14159265 / 5.0));
    float inversionFactor = smoothstep(-0.2, 0.2, inversionCycle) * 2.0 - 1.0;
    float transitionPeak = 1.0 - abs(inversionFactor);

    vec2 st = getShaderMode(uv, mode);

    float logR = (st.x - demoTime * 0.8) * inversionFactor;
    logR += sin(logR * 3.0 + demoTime * 2.0) * 0.25;

    float twistAmount = kick * 5.0 * kickToggle;
    float logTwist = logR * twistAmount;

    float angleMod = st.y + logTwist + transitionPeak * 2.5 * sin(demoTime * 2.0);

    float angleCos = cos(angleMod * 2.0);
    float angleSin = sin(angleMod * 2.0);

    vec2 seamlessUV = vec2(logR, angleCos + angleSin * 0.5);

    float pattern = fbmFold(seamlessUV * 1.5);

    vec3 audioFreqs = vec3(audioLow, audioMid, audioHigh);

    vec3 baseCol = 0.5 + 0.5 * cos(demoTime + logR + vec3(0.0, 2.0, 4.0) + pattern * 3.0);
    vec3 col = baseCol + (audioFreqs * 1.2 * sin(logR * 8.0 + vec3(0.0, 2.09, 4.18)));

    col *= pattern * (1.2 + audioFreqs * 0.8);

    float depth = smoothstep(0.0, 0.3, length(uv));
    return col * depth;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float bass  = texture(iChannel0, vec2(0.01, 0.25)).x;
    float low   = texture(iChannel0, vec2(0.08, 0.25)).x;
    float mid   = texture(iChannel0, vec2(0.25, 0.25)).x;
    float high  = texture(iChannel0, vec2(0.70, 0.25)).x;

    float kick = pow(bass, 2.5);

    if (iTime < 5.0) {
        float remaining = 5.0 - iTime;
        int currentDigit = int(ceil(remaining));
        float subSecond = fract(remaining);

        float pulse = pow(1.0 - subSecond, 3.0);
        
        uv *= (1.0 - pulse * 0.15);

        float r = length(uv);
        float ring = smoothstep(0.01, 0.0, abs(r - (0.4 + pulse * 0.1)));

        float digitMask = drawDigit(uv, currentDigit);

        vec3 bgCol = 0.5 + 0.5 * cos(iTime * 2.0 + vec3(0.0, 2.0, 4.0) + r * 5.0);
        bgCol *= (0.15 + pulse * 0.25);

        vec3 digitCol = vec3(1.0, 0.2, 0.4) * digitMask;
        vec3 ringCol = vec3(0.2, 0.8, 1.0) * ring;

        vec3 finalCol = bgCol + digitCol + ringCol + vec3(pulse * 0.2);

        fragColor = vec4(pow(max(finalCol, vec3(0.0)), vec3(0.4545)), 1.0);
        return;
    }

    float demoTime = iTime - 5.0;

    float kickBeatIndex = floor(demoTime * 2.0 + (kick * 0.5));
    float kickToggle = mod(kickBeatIndex, 2.0);

    float sequenceTime = demoTime / 3.5;
    int modeA = int(mod(floor(sequenceTime), 10.0));
    int modeB = int(mod(floor(sequenceTime) + 1.0, 10.0));
    float transitionPhase = fract(sequenceTime);

    float transitionImpact = smoothstep(0.75, 1.0, transitionPhase);
    
    float rnd = hash(vec2(iTime * 50.0, floor(uv.y * 40.0)));
    float lineGlitch = step(0.92 - transitionImpact * 0.25, rnd);

    if (lineGlitch > 0.5) {
        uv.x += (hash(vec2(floor(uv.y * 30.0), iTime * 60.0)) - 0.5) * (0.1 + transitionImpact * 0.4);
    }

    float zoomShock = 1.0 + transitionImpact * sin(transitionPhase * 31.4159) * 0.3;
    uv *= zoomShock;

    float shakeIntensity = kick * 0.15 + transitionImpact * 0.2;
    vec2 shakeOffset = vec2(
        noise(vec2(iTime * 40.0, 0.0)) - 0.5,
        noise(vec2(0.0, iTime * 40.0)) - 0.5
    ) * shakeIntensity;

    float tPath = demoTime * 0.8;
    vec2 tunnelOffset = vec2(
        noise(vec2(tPath * 0.6, 1.5)) - 0.5 + sin(tPath * 0.3) * 0.4,
        noise(vec2(2.5, tPath * 0.6)) - 0.5 + cos(tPath * 0.4) * 0.4
    ) * (0.4 + kick * 0.3);

    uv += shakeOffset + tunnelOffset;

    int currentMode = (transitionPhase > 0.5) ? modeB : modeA;

    float chromaDist = 0.005 + transitionImpact * 0.04 + kick * 0.015;
    
    vec3 col;
    col.r = renderScene(uv * (1.0 + chromaDist), currentMode, demoTime, kick, kickToggle, low, mid, high).r;
    col.g = renderScene(uv, currentMode, demoTime, kick, kickToggle, low, mid, high).g;
    col.b = renderScene(uv * (1.0 - chromaDist), currentMode, demoTime, kick, kickToggle, low, mid, high).b;

    float scanline = sin(fragCoord.y * 1.5 + iTime * 20.0) * 0.05;
    col -= scanline;

    float strobe = step(0.5, sin(iTime * 50.0)) * transitionImpact;
    if (strobe > 0.5 && rnd > 0.4) {
        col = 1.0 - col;
    }

    if (transitionImpact > 0.8 && hash(vec2(iTime * 100.0, 1.0)) > 0.6) {
        col += vec3(0.4, 0.6, 1.0) * kick;
    }

    if (iTime >= 45.0) {
        float objTime = iTime - 45.0;
        
        vec2 rawUV = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
        
        float dist = psychedelicMorphSDF(rawUV, objTime, kick);
        
        float objGlow = 0.015 / (abs(dist) + 0.01);
        objGlow *= (1.0 + kick * 2.0);
        
        float objFill = smoothstep(0.01, -0.01, dist);
        
        vec3 objCol = 0.5 + 0.5 * cos(objTime * 3.0 + dist * 10.0 + vec3(0.0, 2.0, 4.0));
        objCol += vec3(0.2, 0.8, 1.0) * objGlow;
        
        col = mix(col, col + objCol, objFill * 0.6 + objGlow * 0.4);

        float beatCounter = objTime * 4.0 * max(kick, 0.5);
        int letterIdx = int(floor(beatCounter));

        if (letterIdx < 9) {
            int chars[9];
            chars[0] = 83;
            chars[1] = 65;
            chars[2] = 78;
            chars[3] = 68;
            chars[4] = 69;
            chars[5] = 70;
            chars[6] = 74;
            chars[7] = 79;
            chars[8] = 82;

            int activeChar = chars[letterIdx];

            vec2 textUV = rawUV;
            float textScale = 2.2 + sin(fract(beatCounter) * 3.14159) * 0.4;
            textUV *= textScale;
            textUV += vec2(0.5);

            float charMask = drawChar(textUV, activeChar);
            vec3 textCol = vec3(1.0, 0.9, 0.3) * (1.2 + kick * 1.5);
            col = mix(col, textCol, charMask);
        }
    }

    col = pow(max(col, vec3(0.0)), vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
