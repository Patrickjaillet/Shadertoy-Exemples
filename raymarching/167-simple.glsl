// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime * 0.15;
    float shapeTime = iTime * 0.08;
    float morphPhase = fract(shapeTime * 2.0);
    float lerpM = smoothstep(0.0, 1.0, morphPhase);
    float id0 = floor(shapeTime * 2.0);
    float id1 = id0 + 1.0;
    
    vec4 s0A = fract(sin(vec4(id0 * 12.989, id0 * 78.233, id0 * 37.719, id0 * 91.312)) * 43758.545);
    vec4 s1A = fract(sin(vec4(id1 * 12.989, id1 * 78.233, id1 * 37.719, id1 * 91.312)) * 43758.545);
    vec4 sA = mix(s0A, s1A, lerpM);
    
    vec4 s0B = fract(cos(vec4(id0 * 45.123, id0 * 12.345, id0 * 89.123, id0 * 55.555)) * 23145.145);
    vec4 s1B = fract(cos(vec4(id1 * 45.123, id1 * 12.345, id1 * 89.123, id1 * 55.555)) * 23145.145);
    vec4 sB = mix(s0B, s1B, lerpM);
    
    float camTime = iTime * 0.15;
    
    float camDist = 30.0 + (sin(camTime * 0.413) * 0.5 + cos(camTime * 0.671) * 0.5) * 12.0;
    float camAzimuth = camTime * 0.4 + sin(camTime * 0.72) * 1.5;
    float camElevation = sin(camTime * 0.31) * 1.2 + cos(camTime * 0.49) * 0.5;
    
    vec3 ro = vec3(
        cos(camElevation) * sin(camAzimuth),
        sin(camElevation),
        cos(camElevation) * cos(camAzimuth)
    ) * camDist;
    
    vec3 ta = vec3(0.0);
    
    vec3 cw = normalize(ta - ro);
    float roll = sin(camTime * 0.25) * 0.2;
    vec3 cp = vec3(sin(roll), cos(roll), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    
    float fov = 1.1 + (sin(camTime * 0.54) * 0.5 + cos(camTime * 0.81) * 0.5) * 0.2;
    vec3 rd = normalize(uv.x * cu + uv.y * cv + fov * cw);
    
    float focusDist = length(ta - ro);
    
    vec3 finalColor = vec3(0.0);
    
    for (int i = 0; i < 600; i++) {
        float fi = float(i);
        vec3 h = fract(sin(vec3(fi * 12.989, fi * 78.233, fi * 37.719)) * 43758.545);
        
        float life = fract(time * (0.01 + 0.03 * h.z) + h.y);
        
        float fId0 = mod(id0, 105.0);
        float fId1 = mod(id1, 105.0);
        
        float a0 = fId0 * 0.31415 + h.x * 6.2831;
        float a1 = fId1 * 0.31415 + h.x * 6.2831;
        
        vec3 pos0;
        pos0.x = (3.0 + s0A.x * 4.0) * sin(a0 * (1.0 + s0A.y * 2.0)) * cos(a0 * s0A.z);
        pos0.y = (3.0 + s0A.y * 4.0) * sin(a0 * (1.0 + s0A.z * 2.0)) * sin(a0 * s0A.x);
        pos0.z = (3.0 + s0A.z * 4.0) * cos(a0 * (1.0 + s0A.x * 2.0));
        
        vec3 pos1;
        pos1.x = (3.0 + s1A.x * 4.0) * sin(a1 * (1.0 + s1A.y * 2.0)) * cos(a1 * s1A.z);
        pos1.y = (3.0 + s1A.y * 4.0) * sin(a1 * (1.0 + s1A.z * 2.0)) * sin(a1 * s1A.x);
        pos1.z = (3.0 + s1A.z * 4.0) * cos(a1 * (1.0 + s1A.x * 2.0));
        
        vec3 targetPos = mix(pos0, pos1, lerpM);
        
        targetPos += (h - 0.5) * 1.5 * sin(life * 3.14159) * sA.w;
        
        mat3 rotP = mat3(
            cos(time * 0.3), 0.0, sin(time * 0.3),
            0.0, 1.0, 0.0,
            -sin(time * 0.3), 0.0, cos(time * 0.3)
        );
        targetPos = rotP * targetPos;
        
        vec3 pDiff = targetPos - ro;
        float zDepth = dot(pDiff, rd);
        
        if (zDepth > 0.1) {
            vec3 projP = ro + rd * zDepth;
            
            float focus = abs(zDepth - focusDist);
            float size = 0.08 + 0.15 * h.y + focus * 0.015;
            
            float distSqr = dot(projP - targetPos, projP - targetPos);
            
            float sprite = exp(-distSqr / (size * size + 0.001));
            float core = exp(-distSqr / (size * size * 0.1 + 0.001));
            
            float intensity = (sprite * 0.4 + core * 2.5) / (zDepth * 0.03 + 1.0);
            float fade = smoothstep(0.0, 0.15, life) * smoothstep(1.0, 0.7, life);
            
            vec3 pCol = 0.5 + 0.5 * cos(6.2831 * (h.xyz * 2.0 + time * 0.4 + sB.yzw));
            
            finalColor += pCol * intensity * fade * (1.2 + sB.y * 1.5);
        }
    }
    
    finalColor = 1.0 - exp(-finalColor * (0.8 + sA.x * 0.4));
    finalColor = pow(finalColor, vec3(0.4545));
    
    vec2 vignette = uv;
    finalColor *= 1.0 - dot(vignette, vignette) * 0.3;
    
    fragColor = vec4(finalColor, 1.0);
}
