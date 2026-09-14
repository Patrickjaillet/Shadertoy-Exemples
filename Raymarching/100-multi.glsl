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
vec3 getBuffer(vec2 uv) {
    return texture(iChannel0, uv).rgb;
}

vec3 chromaticAberration(vec2 uv, float amount) {
    vec2 dist = uv - 0.5;
    vec3 col;
    col.r = getBuffer(uv + dist * amount).r;
    col.g = getBuffer(uv).g;
    col.b = getBuffer(uv - dist * amount).b;
    return col;
}

vec3 bloom(vec2 uv) {
    vec3 blur = vec3(0.0);
    vec2 texel = 1.0 / iResolution.xy;
    float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
    
    blur += getBuffer(uv) * weights[0];
    for (int i = 1; i < 5; i++) {
        vec2 offset = vec2(float(i)) * texel * 3.0;
        blur += getBuffer(uv + vec2(offset.x, 0.0)) * weights[i];
        blur += getBuffer(uv - vec2(offset.x, 0.0)) * weights[i];
        blur += getBuffer(uv + vec2(0.0, offset.y)) * weights[i];
        blur += getBuffer(uv - vec2(0.0, offset.y)) * weights[i];
    }
    return blur;
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float dist = length(uv - 0.5);
    
    vec3 col = chromaticAberration(uv, 0.015 * dist);
    
    vec3 bloomCol = bloom(uv);
    col += bloomCol * 0.8;
    
    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    col = pow(clamp(col, 0.0, 1.0), vec3(1.0 / 2.2));
    
    col *= smoothstep(0.8, 0.25, dist);
    col += (hash(uv + fract(iTime)) - 0.5) * 0.03;
    
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
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 st = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float k = sin(iTime * 0.5);
    float base = 3.0 + k * abs(k);
    
    float angle = iTime * 0.05;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 uv = rot * st + 0.5;
    
    float holeMask = 0.0;
    float iterationWeight = 0.0;
    
    for(int i = 0; i < 6; i++) {
        vec2 cell = floor(mod(uv * 3.0, 3.0));
        if(cell == vec2(1.0)) {
            holeMask = 1.0;
            iterationWeight = float(i) / 6.0;
            break;
        }
        uv *= base;
    }
    
    vec3 colBackground = 0.5 + 0.5 * cos(iTime + st.xyx + vec3(0.0, 2.0, 4.0));
    vec3 colStructure = 0.5 + 0.5 * sin(iTime * 1.5 + vec3(4.0, 1.0, 2.0));
    
    vec3 targetColor = mix(colStructure, vec3(0.01, 0.01, 0.03), holeMask);
    targetColor += (1.0 - holeMask) * colBackground * 0.6;
    targetColor += iterationWeight * vec3(0.2, 0.5, 0.8) * (1.0 - holeMask);
    
    vec3 prevColor = texture(iChannel0, fragCoord / iResolution.xy).rgb;
    vec3 finalColor = mix(targetColor, prevColor, 0.35);
    
    fragColor = vec4(finalColor, 1.0);
}
