// ==== Image (image) ====
#define M_STEPS 120
#define S_DIST 0.001
#define M_DIST 60.0

vec3 gOrbitTrap = vec3(0.0);

mat2 Rot(float a) { 
    float s = sin(a), c = cos(a); 
    return mat2(c, -s, s, c); 
}

float sdSierpinski(vec3 p, float s) {
    float scale = 2.1;
    int iterations = 5;
    vec3 v1 = vec3(1.0, 1.0, 1.0);
    gOrbitTrap = vec3(10.0); 

    p /= s;
    for(int n = 0; n < iterations; n++) {
        if(p.x + p.y < 0.0) p.xy = -p.yx;
        if(p.x + p.z < 0.0) p.xz = -p.zx;
        if(p.y + p.z < 0.0) p.yz = -p.zy;
        p = p * scale - v1 * (scale - 1.0);
        gOrbitTrap.x = min(gOrbitTrap.x, abs(p.x));
        gOrbitTrap.y = min(gOrbitTrap.y, length(p.xy));
        gOrbitTrap.z = min(gOrbitTrap.z, dot(p, normalize(vec3(1.0))));
    }
    return (length(p) - 1.4) * pow(scale, -float(iterations)) * s;
}

float sdMenger(vec3 p, float s) {
    p /= s;
    vec3 d = abs(p) - 1.0;
    float res = min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
    float scale = 3.0;
    for(int n = 0; n < 4; n++) {
        vec3 a = mod(p * scale, 2.0) - 1.0;
        scale *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / scale;
        res = max(res, c);
        gOrbitTrap.y = min(gOrbitTrap.y, length(a.xy) * 0.5);
    }
    return res * s;
}

float sdBackgroundStructure(vec3 p) {
    p.xy *= Rot(p.z * 0.1); 
    vec3 grid = fract(p * 0.5) - 0.5; 
    grid.xz *= Rot(iTime * 0.3);
    return length(max(abs(grid) - 0.1, 0.0));
}

float GetDist(vec3 p) {
    float time = iTime * 0.15;
    p.xy *= Rot(p.z * 0.05 + time);
    float repeatZ = 8.0;
    float zId = floor((p.z + repeatZ * 0.5) / repeatZ);
    vec3 p_local = p;
    p_local.z = mod(p_local.z + repeatZ * 0.5, repeatZ) - (repeatZ * 0.5);
    vec3 p_obj = p_local;
    p_obj.xz *= Rot(time * 1.5 + zId);
    p_obj.xy *= Rot(time * 0.8);
    float obj = (mod(zId, 2.0) == 0.0) ? sdSierpinski(p_obj, 1.2) : sdMenger(p_obj, 1.0);
    float bg = sdBackgroundStructure(p_local) * 2.0; 
    float hole = length(p.xy) - 1.0;
    return min(max(obj, -hole), bg + 0.5); 
}

vec3 GetNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(GetDist(p) - vec3(GetDist(p-e.xyy), GetDist(p-e.yxy), GetDist(p-e.yyx)));
}

vec3 ACESTonemap(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 applyCRT(vec3 col, vec2 uv) {
    float scanline = sin(uv.y * iResolution.y * 1.5) * 0.1 + 0.9;
    float mask = sin(uv.x * iResolution.x * 2.0) * 0.05 + 0.95;
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 15.0;
    vignette = pow(vignette, 0.15);
    return col * scanline * mask * vignette;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 crtUV = fragCoord / iResolution.xy;
    vec2 centeredUV = crtUV - 0.5;
    float d_uv = dot(centeredUV, centeredUV);
    crtUV = crtUV + centeredUV * d_uv * 0.05; 

    float time = iTime;
    
    float shiftX = sin(time * 0.4) * 3.5; 
    
    vec3 ro = vec3(shiftX, 0.0, time * 3.0);
    
    vec3 lookAt = vec3(0.0, 0.0, ro.z + 3.0); 
    
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f * 1.1 + uv.x * r + uv.y * u);
    
    rd.xy *= Rot(sin(time * 0.1) * 0.15);

    vec3 finalCol = vec3(0.0);
    float t = 0.0;
    vec3 colA = vec3(1.0, 0.1, 0.5); 
    vec3 colB = vec3(0.0, 1.0, 0.9); 
    
    for(int i = 0; i < 90; i++) {
        vec3 p = ro + rd * t;
        float d = GetDist(p);
        vec3 col = mix(colA, colB, sin(p.z * 0.15 + time) * 0.5 + 0.5);
        col += exp(-gOrbitTrap.y * 12.0) * colB * 1.2;        
        
        if(d < 0.005) {
            vec3 n = GetNormal(p);
            finalCol += col * max(dot(n, -rd), 0.0) * 0.07;
            d = 0.15; 
        }
        finalCol += col * exp(-d * 3.0) * 0.14;
        t += max(d * 1.5, 0.06);
        if(t > M_DIST) break;
    }

    finalCol = ACESTonemap(finalCol * 2.0);
    finalCol = pow(finalCol, vec3(0.4545)); 
    finalCol = applyCRT(finalCol, crtUV);
    
    if (crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0) {
        finalCol = vec3(0.0);
    }

    fragColor = vec4(finalCol, 1.0);
}
