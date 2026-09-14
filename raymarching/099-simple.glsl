// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    
    vec2 shipPos = vec2(sin(iTime * 0.8) * 0.4, cos(iTime * 0.6) * 0.3);
    float shipAngle = iTime * 1.2;
    
    mat2 rotShip = mat2(cos(shipAngle), -sin(shipAngle), sin(shipAngle), cos(shipAngle));
    vec2 tip = shipPos + rotShip * vec2(0.0, 0.08);
    vec2 left = shipPos + rotShip * vec2(-0.04, -0.05);
    vec2 right = shipPos + rotShip * vec2(0.04, -0.05);
    vec2 back = shipPos + rotShip * vec2(0.0, -0.02);
    
    vec2 pa1 = uv - tip;
    vec2 ba1 = left - tip;
    float dShip = clamp(dot(pa1, ba1) / dot(ba1, ba1), 0.0, 1.0);
    float shipLine1 = length(pa1 - ba1 * dShip);
    
    vec2 pa2 = uv - tip;
    vec2 ba2 = right - tip;
    float dShip2 = clamp(dot(pa2, ba2) / dot(ba2, ba2), 0.0, 1.0);
    float shipLine2 = length(pa2 - ba2 * dShip2);
    
    vec2 pa3 = uv - left;
    vec2 ba3 = back - left;
    float dShip3 = clamp(dot(pa3, ba3) / dot(ba3, ba3), 0.0, 1.0);
    float shipLine3 = length(pa3 - ba3 * dShip3);
    
    vec2 pa4 = uv - right;
    vec2 ba4 = back - right;
    float dShip4 = clamp(dot(pa4, ba4) / dot(ba4, ba4), 0.0, 1.0);
    float shipLine4 = length(pa4 - ba4 * dShip4);
    
    float ship = min(min(shipLine1, shipLine2), min(shipLine3, shipLine4));
    
    float shotCycle = mod(iTime, 1.5);
    vec2 laserPos = shipPos + rotShip * vec2(0.0, 0.08 + shotCycle * 0.8);
    float laser = length(uv - laserPos);
    float laserMask = step(shotCycle, 0.8) * step(0.0, shotCycle);
    float laserDist = smoothstep(0.003, 0.0, laser) * laserMask;
    
    vec2 astPos1 = vec2(0.5 + sin(iTime * 0.5) * 0.6, 0.3 + cos(iTime * 0.4) * 0.4);
    vec2 astPos2 = vec2(-0.5 + cos(iTime * 0.3) * 0.5, -0.3 + sin(iTime * 0.6) * 0.4);
    vec2 astPos3 = vec2(0.2 + sin(iTime * 0.7) * 0.4, -0.4 + cos(iTime * 0.5) * 0.3);
    
    float astD1 = 1.0;
    for(int i=0; i<8; i++) {
        float a1 = float(i) * 0.785398;
        float a2 = float(i+1) * 0.785398;
        float r1 = 0.18 + 0.05 * sin(float(i) * 3.0 + iTime * 2.0);
        float r2 = 0.18 + 0.05 * sin(float(i+1) * 3.0 + iTime * 2.0);
        vec2 p1 = astPos1 + vec2(cos(a1), sin(a1)) * r1;
        vec2 p2 = astPos1 + vec2(cos(a2), sin(a2)) * r2;
        vec2 pa = uv - p1;
        vec2 ba = p2 - p1;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        astD1 = min(astD1, length(pa - ba * h));
    }
    
    float astD2 = 1.0;
    for(int i=0; i<8; i++) {
        float a1 = float(i) * 0.785398;
        float a2 = float(i+1) * 0.785398;
        float r1 = 0.12 + 0.04 * cos(float(i) * 2.5 - iTime * 3.0);
        float r2 = 0.12 + 0.04 * cos(float(i+1) * 2.5 - iTime * 3.0);
        vec2 p1 = astPos2 + vec2(cos(a1), sin(a1)) * r1;
        vec2 p2 = astPos2 + vec2(cos(a2), sin(a2)) * r2;
        vec2 pa = uv - p1;
        vec2 ba = p2 - p1;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        astD2 = min(astD2, length(pa - ba * h));
    }

    float astD3 = 1.0;
    for(int i=0; i<8; i++) {
        float a1 = float(i) * 0.785398;
        float a2 = float(i+1) * 0.785398;
        float r1 = 0.15 + 0.05 * sin(float(i) * 4.0 + iTime * 1.5);
        float r2 = 0.15 + 0.05 * sin(float(i+1) * 4.0 + iTime * 1.5);
        vec2 p1 = astPos3 + vec2(cos(a1), sin(a1)) * r1;
        vec2 p2 = astPos3 + vec2(cos(a2), sin(a2)) * r2;
        vec2 pa = uv - p1;
        vec2 ba = p2 - p1;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        astD3 = min(astD3, length(pa - ba * h));
    }
    
    float shipGlow = smoothstep(0.003, 0.0, ship);
    float asteroids = min(astD1, min(astD2, astD3));
    float astGlow = smoothstep(0.003, 0.0, asteroids);
    
    col += vec3(shipGlow);
    col += vec3(laserDist * 0.8, laserDist, laserDist * 0.8);
    col += vec3(astGlow);
    
    fragColor = vec4(col, 1.0);
}
