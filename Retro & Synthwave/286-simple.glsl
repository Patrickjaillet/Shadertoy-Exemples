// ==== Image (image) ====
float getChar(int ascii, vec2 uv) {
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 0.0;
    vec2 charCoord = vec2(mod(float(ascii), 16.0), 15.0 - floor(float(ascii) / 16.0));
    vec2 fontUv = (charCoord + uv) / 16.0;
    return texture(iChannel0, fontUv).r;
}

float printLine1(vec2 uv) {
    int msg[35] = int[](
        71, 85, 82, 85, 32, 77, 69, 68, 73, 84, 65, 84, 73, 79, 78, 32,
        35, 48, 48, 48, 48, 48, 48, 48, 52, 46, 48, 48, 48, 48, 48, 48, 48, 51, 32
    );
    
    float charIndex = floor(uv.x * 35.0);
    vec2 charUv = vec2(fract(uv.x * 35.0), uv.y);
    
    int ascii = 32;
    int idx = int(charIndex);
    if (idx >= 0 && idx < 35) {
        ascii = msg[idx];
    }
    
    return getChar(ascii, charUv);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    float t = iTime;

    float borderThickness = 0.03;
    vec2 boxSize = vec2(0.8, 0.12);
    
    float inBorder = step(uv.x, borderThickness) + step(1.0 - borderThickness, uv.x) +
                     step(uv.y, borderThickness) + step(1.0 - borderThickness, uv.y);
    inBorder = clamp(inBorder, 0.0, 1.0);
    
    vec2 boxUv = (uv - 0.5) * 2.0;
    float inBox = step(abs(boxUv.x), boxSize.x) * step(abs(boxUv.y), boxSize.y);

    float flash = mod(t * 2.5, 2.0);
    bool isRed = flash < 1.0;

    vec3 col = vec3(0.0);

    if (inBorder > 0.5) {
        col = isRed ? vec3(1.0, 0.0, 0.0) : vec3(0.0);
    } else if (inBox > 0.5) {
        vec2 textUv = (boxUv + boxSize) / (boxSize * 2.0);
        textUv.y = (textUv.y - 0.35) * 3.0;
        
        float textMask = printLine1(textUv);
        col = mix(vec3(0.0), vec3(1.0, 0.0, 0.0), textMask);
    } else {
        col = vec3(0.0);
    }

    float scanline = sin(uv.y * iResolution.y * 1.5) * 0.1;
    col -= scanline;

    fragColor = vec4(col, 1.0);
}
