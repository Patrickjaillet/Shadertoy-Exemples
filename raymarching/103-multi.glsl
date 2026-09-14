// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
               mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x), u.y);
}

float xuanFibersHeavy(vec2 uv) {
    vec2 st1 = uv * vec2(250.0, 80.0);
    float angle1 = noise(st1 * 0.08) * 6.28;
    st1 += vec2(cos(angle1), sin(angle1)) * 2.5;
    float fiber1 = smoothstep(0.2, 0.65, noise(st1));

    vec2 st2 = uv * vec2(50.0, 400.0);
    float angle2 = noise(st2 * 0.04) * 6.28;
    st2 += vec2(cos(angle2), sin(angle2)) * 3.0;
    float fiber2 = smoothstep(0.2, 0.7, noise(st2));

    vec2 st3 = uv * vec2(150.0, 150.0);
    float fiber3 = smoothstep(0.25, 0.6, noise(st3));

    float microGrain = noise(uv * 800.0) * 0.6 + noise(uv * 1600.0) * 0.4;
    float pulpSplotches = smoothstep(0.35, 0.75, noise(uv * 12.0));
    
    return microGrain * 0.3 + fiber1 * 0.35 + fiber2 * 0.35 + fiber3 * 0.2 + pulpSplotches * 0.25;
}

vec3 aces(vec3 color) {
    float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 cenUV = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 paperBase = vec3(0.97, 0.94, 0.84);
    vec3 fiberColor = vec3(0.60, 0.50, 0.38);
    
    float fibers = xuanFibersHeavy(uv);
    vec3 paperCol = mix(paperBase, fiberColor, clamp(fibers * 0.85, 0.0, 1.0));
    
    vec4 painting = texture(iChannel0, uv);
    
    if (textureSize(iChannel0, 0).x < 2) {
        float d = length(cenUV);
        float inkMask = smoothstep(0.3, 0.28, d + noise(uv * 20.0) * 0.03);
        painting = vec4(vec3(0.05, 0.05, 0.08), inkMask);
    }
    
    vec2 shadowOffset = vec2(-0.015, -0.02);
    float shadowMask = 0.0;
    vec2 texel = 1.0 / iResolution.xy;
    
    if (textureSize(iChannel0, 0).x >= 2) {
        for (int x = -2; x <= 2; x++) {
            for (int y = -2; y <= 2; y++) {
                vec2 offset = vec2(float(x), float(y)) * texel * 3.0;
                shadowMask += texture(iChannel0, uv + shadowOffset + offset).a;
            }
        }
        shadowMask /= 25.0;
    } else {
        float d = length(cenUV - shadowOffset);
        shadowMask = smoothstep(0.32, 0.25, d + noise((uv + shadowOffset) * 20.0) * 0.03);
    }
    
    vec3 inkShadowColor = vec3(0.2, 0.16, 0.12);
    paperCol = mix(paperCol, paperCol * inkShadowColor, shadowMask * 0.6);

    vec3 col = mix(paperCol, painting.rgb, painting.a * 0.95);
    
    col *= 1.0 - length(cenUV) * 0.3;
    
    col = aces(col);
    col = pow(col, vec3(1.0 / 2.2));
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    mat2 m = rot(0.5);
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p = m * p * 2.0;
        a *= 0.5;
    }
    return v;
}

float sdPetal(vec2 p) {
    p.x = abs(p.x);
    if (p.y > 1.0) return length(p - vec2(0.0, 1.0));
    if (p.y < 0.0) return length(p);
    return max(p.x - sin(p.y * 3.1415) * 0.3, -p.y);
}

float sdLeaf(vec2 p) {
    float d1 = length(p - vec2(0.3, 0.0)) - 0.5;
    float d2 = length(p + vec2(0.3, 0.0)) - 0.5;
    return max(d1, d2);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec2 p = uv * 2.2;
    p.y += 0.2;
    
    vec3 col = vec3(0.0);
    float alpha = 0.0;
    
    vec3 inkColor = vec3(0.08, 0.06, 0.05);
    vec3 mineralGreen = vec3(0.15, 0.42, 0.28);
    vec3 cinnabarRed = vec3(0.82, 0.22, 0.20);
    vec3 pearlWhite = vec3(0.96, 0.94, 0.88);
    vec3 goldCore = vec3(0.92, 0.72, 0.20);

    vec2 lp = p + vec2(0.3, 0.4);
    lp *= rot(-0.6);
    float dL = sdLeaf(lp);
    if (dL < 0.0) {
        float leafMask = smoothstep(0.0, -0.01, dL);
        vec3 leafCol = mix(mineralGreen * 0.4, mineralGreen, p.y + 0.5);
        leafCol += fbm(p * 15.0) * 0.05;
        
        float stroke = smoothstep(0.015, 0.0, abs(dL));
        stroke += smoothstep(0.01, 0.0, abs(lp.x)) * smoothstep(0.5, -0.5, lp.y);
        
        col = mix(leafCol, inkColor, clamp(stroke, 0.0, 1.0));
        alpha = leafMask;
    }

    vec2 fp = p - vec2(0.0, 0.2);
    fp += vec2(sin(iTime * 0.5) * 0.02, cos(iTime * 0.5) * 0.01);
    
    for (int i = 0; i < 12; i++) {
        float angle = float(i) * 0.5235 + sin(float(i)) * 0.1;
        vec2 rp = rot(angle) * fp;
        float scale = 0.6 + sin(float(i) * 1.3) * 0.15;
        vec2 petalP = rp / scale;
        
        petalP += (fbm(petalP * 4.0) - 0.5) * 0.08;
        
        float dP = sdPetal(petalP) * scale;
        
        if (dP < 0.0) {
            float pMask = smoothstep(0.0, -0.01, dP);
            float grad = smoothstep(0.0, 0.5, length(petalP));
            vec3 pCol = mix(pearlWhite, cinnabarRed, grad);
            pCol += (fbm(petalP * 20.0) - 0.5) * 0.08;
            
            float stroke = smoothstep(0.008, 0.0, abs(dP));
            
            vec3 layerCol = mix(pCol, inkColor, stroke * 0.9);
            col = mix(col, layerCol, pMask);
            alpha = max(alpha, pMask);
        }
    }

    float dCenter = length(fp) - 0.12;
    if (dCenter < 0.0) {
        float cMask = smoothstep(0.0, -0.01, dCenter);
        vec3 cCol = goldCore + (fbm(fp * 30.0) - 0.5) * 0.15;
        float stroke = smoothstep(0.008, 0.0, abs(dCenter));
        col = mix(col, mix(cCol, inkColor, stroke), cMask);
        alpha = max(alpha, cMask);
    }

    fragColor = vec4(col, alpha);
}
