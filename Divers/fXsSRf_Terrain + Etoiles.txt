// ==== Image (image) ====
float hash12(vec2 p){
    vec3 p3=fract(vec3(p.xyx)*.1031);
    p3+=dot(p3,p3.yzx+33.33);
    return fract((p3.x+p3.y)*p3.z);
}

vec2 hash22(vec2 p){
    vec3 p3=fract(vec3(p.xyx)*vec3(.1031,.103,.0973));
    p3+=dot(p3,p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

mat2 rot(float a){
    float s=sin(a),c=cos(a);
    return mat2(c,-s,s,c);
}

vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

mat2 rot2d(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float fbm(vec3 p) {
    float s = 1.0;
    float e = 0.0;
    for (int j = 0; j < 6; j++) {
        vec3 sampling = p.zxy * s;
        e += dot(sin(sampling) - 0.5, 0.8 - sin(p.yzx * s)) / s * 0.35;
        s *= 2.15;
    }
    return e;
}

float sdfTerrain(vec3 p, float t, out vec3 data) {
    vec2 uv = p.xz * 0.035;
    uv.y -= t * 0.25;
    
    vec4 tex = textureLod(iChannel0, uv * 0.15, 0.0);
    float noise = (tex.r + tex.g + tex.b) * 0.3333;
    
    vec2 p_rot = p.xz * rot(0.5);
    float baseTerrain = sin(p_rot.x * 0.03 + sin(p_rot.y * 0.025)) * 4.5 + cos(p_rot.y * 0.015) * 3.0;
    
    float microTerrain = fbm(vec3(p.xz * 0.12, p.y * 0.08)) * 4.0;
    float h = baseTerrain + microTerrain + noise * 1.8;
    
    float sediment = fbm(p * 0.45) * 0.5 + 0.5;
    data = vec3(noise, h, sediment);
    return p.y - h;
}

vec3 getStarField(vec2 uv, float zoom, float time, float seed) {
    vec2 gv = fract(uv * zoom) - .5;
    vec2 id = floor(uv * zoom);
    
    vec2 n = hash22(id + seed);
    float pTime = time * (.3 + n.x * .7) + n.y * 6.28;
    float size = (.04 + .15 * hash12(id + seed + 121.3)) * (sin(pTime) * .5 + .5);
    
    float d = length(gv - (n - .5));
    vec3 starCol = mix(vec3(.4, .65, 1.), vec3(1., .45, .25), hash12(id + seed + 45.1));
    starCol = mix(starCol, vec3(1., .95, .8), n.x * n.y);
    
    float light = (size * .012) / (d + 3e-4);
    float glow = (size * .0025) / (d * d + 5e-5);
    
    vec2 r_uv = (gv - (n - .5)) * rot(pTime * .4);
    float rays = pow(max(0., 1. - abs(r_uv.x * r_uv.y * 1.2e3)), 14.) * (size * .12 / (d + .008));
    rays += pow(max(0., 1. - abs(r_uv.x)), 65.) * (size * .06 / (d + .008));
    
    return (light + glow + rays) * starCol;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    
    vec3 rd = normalize(vec3(uv, 1.2));
    vec3 ro = vec3(0.0, 7.5 + sin(t * 0.3) * 2.0, t * 11.0);
    
    rd.xy *= rot2d(sin(t * 0.03) * 0.04);
    rd.xz *= rot2d(cos(t * 0.05) * 0.07);
    
    vec3 col = vec3(0.0);
    float dO = 0.01;
    vec3 terrainData = vec3(0.0);
    bool hit = false;
    
    for (int i = 0; i < 180; i++) {
        vec3 p = ro + rd * dO;
        float dS = sdfTerrain(p, t, terrainData);
        if (abs(dS) < 0.0008 * dO) {
            hit = true;
            break;
        }
        if (dO > 220.0) break;
        dO += dS * 0.45;
    }
    
    vec3 p = ro + rd * dO;
    float noise = terrainData.x;
    float h = terrainData.y;
    float sediment = terrainData.z;
    
    vec2 eps = vec2(0.004, 0.0);
    vec3 dummy;
    vec3 n = vec3(0.0, 1.0, 0.0);
    
    if (hit) {
        vec3 n_f = vec3(
            sdfTerrain(p + eps.xyy, t, dummy) - sdfTerrain(p - eps.xyy, t, dummy),
            2.0 * eps.x,
            sdfTerrain(p + eps.yyx, t, dummy) - sdfTerrain(p - eps.yyx, t, dummy)
        );
        
        vec2 eps_macro = vec2(0.06, 0.0);
        vec3 n_m = vec3(
            sdfTerrain(p + eps_macro.xyy, t, dummy) - sdfTerrain(p - eps_macro.xyy, t, dummy),
            2.0 * eps_macro.x,
            sdfTerrain(p + eps_macro.yyx, t, dummy) - sdfTerrain(p - eps_macro.yyx, t, dummy)
        );
        
        n = normalize(n_f * 0.65 + n_m * 0.35);
        
        float slope = 1.0 - n.y;
        float heightFactor = smoothstep(-6.0, 10.0, p.y);
        
        vec3 rockBase = mix(vec3(0.018, 0.015, 0.022), vec3(0.05, 0.045, 0.055), noise);
        vec3 rockHigh = mix(vec3(0.08, 0.07, 0.09), vec3(0.18, 0.15, 0.2), sediment);
        vec3 rockColor = mix(rockBase, rockHigh, heightFactor);
        
        float microSlopeNoise = hash12(floor(p.xz * 15.0));
        float snowMask = smoothstep(0.42, 0.22, slope + microSlopeNoise * 0.08) * smoothstep(0.8, 3.8, p.y + noise * 2.2);
        vec3 snowColor = vec3(0.92, 0.94, 0.98) * (1.0 + vec3(noise * 0.08));
        
        vec3 matColor = mix(rockColor, snowColor, snowMask);
        
        vec3 lightDir = normalize(vec3(0.55, 0.65, -0.52));
        
        float shadow = 1.0;
        float shDist = 0.05;
        float shadowStep = 0.08;
        for(int si = 0; si < 28; si++) {
            float hData = sdfTerrain(p + lightDir * shDist, t, dummy);
            if(hData < 0.001) { 
                shadow = 0.0; 
                break; 
            }
            shadow = min(shadow, 14.0 * hData / shDist);
            shDist += max(shadowStep, hData * 0.75);
            shadowStep *= 1.03;
            if(shDist > 30.0) break;
        }
        shadow = clamp(shadow, 0.08, 1.0);
        
        float diffuse = max(dot(n, lightDir), 0.0);
        float wrapDiffuse = max(dot(n, lightDir) * 0.6 + 0.4, 0.0);
        
        vec3 skyColor = vec3(0.02, 0.015, 0.045);
        vec3 groundColor = vec3(0.003, 0.001, 0.008);
        vec3 bounceColor = vec3(0.04, 0.05, 0.1);
        
        vec3 lin = vec3(0.0);
        lin += wrapDiffuse * vec3(1.4, 1.15, 0.95) * shadow;
        lin += max(0.0, n.y) * skyColor * 3.5;
        lin += max(0.0, -n.y) * groundColor * 5.0;
        lin += max(0.0, dot(n, vec3(-lightDir.x, 0.0, -lightDir.z))) * bounceColor * (2.2 * (1.0 - snowMask));
        
        col = matColor * lin;
        
        vec3 halfDir = normalize(lightDir - rd);
        float specular = pow(max(dot(n, halfDir), 0.0), mix(24.0, 12.0, snowMask));
        col += vec3(specular * mix(0.05, 0.5, snowMask) * shadow * (0.3 + 0.7 * wrapDiffuse));
        
        float r_view = max(dot(reflect(rd, n), lightDir), 0.0);
        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        col += mix(vec3(0.0), vec3(0.15, 0.2, 0.35) * fresnel, snowMask * shadow);
    }
    
    float starTime = t * 0.1;
    vec2 camPath = vec2(sin(starTime * 0.4), cos(starTime * 0.25)) * 2.5;
    float camRot = sin(starTime * 0.15) * 0.35;
    vec3 starFieldCol = vec3(0.0);
    
    vec2 starUV = rd.xy * 0.75;
    
    for (float i = 0.0; i < 1.0; i += 1.0 / 4.0) {
        float depth = fract(i - starTime * 0.4);
        float zoom = mix(16.0, 0.05, depth);
        float fade = smoothstep(0.0, 0.35, depth) * smoothstep(1.0, 0.75, depth);
        vec2 p_uv = starUV;
        p_uv *= rot(camRot * depth);
        p_uv += camPath * depth;
        starFieldCol += getStarField(p_uv, zoom, t, i * 1143.7) * fade;
    }
    
    starFieldCol = pow(starFieldCol, vec3(0.75)) * 1.3;
    vec3 bloom = starFieldCol * starFieldCol;
    starFieldCol += bloom * 0.4;
    
    vec3 horizonColor = vec3(0.002, 0.0005, 0.006);
    vec3 bg = mix(horizonColor, starFieldCol, clamp(rd.y * 1.4 + 0.15, 0.0, 1.0));
    
    float nebula = fbm(vec3(rd.xy * 1.5, starTime * 0.05)) * 0.5 + 0.5;
    bg += hsv(0.72 + nebula * 0.05, 0.8, 0.02) * smoothstep(-0.1, 0.6, rd.y);
    
    if (hit) {
        float extinction = 1.0 - exp(-0.00015 * dO * dO);
        col = mix(col, bg, extinction);
        
        float volFog = 0.0;
        float fogStep = dO / 15.0;
        float fp = 0.0;
        for(int fi = 0; fi < 15; fi++) {
            vec3 pos = ro + rd * fp;
            volFog += max(0.0, 1.0 - (pos.y * 0.15)) * exp(-fp * 0.015);
            fp += fogStep;
        }
        col += vec3(0.015, 0.01, 0.025) * (volFog * 0.04) * (1.0 - extinction);
    } else {
        col = bg;
    }
    
    col = max(vec3(0.0), col - 0.004);
    col = (col * (6.2 * col + 0.5)) / (col * (6.2 * col + 1.7) + 0.06);
    
    col *= 1.35 - length(uv) * 0.75;
    
    fragColor = vec4(col, 1.0);
}
