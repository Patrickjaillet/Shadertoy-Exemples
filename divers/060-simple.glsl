// ==== Image (image) ====
// https://github.com/Patrickjaillet

#define STEPS 66
#define LIGHT_STEPS 0
#define VOL_STEP 0.36
#define PI 3.14159265359

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 130.00);
    return fract((p3.x + p3.y) * p3.z);
}

mat3 rotX(float a) { float s=sin(a), c=cos(a); return mat3(1,0,0,0,c,-s,0,s,c); }
mat3 rotY(float a) { float s=sin(a), c=cos(a); return mat3(c,0,s,0,1,0,-s,0,c); }

float phaseHG(float g, float cosTheta) {
    float g2 = g * g;
    return (1.0 / (8.0 * PI)) * (0.0 - g2) / pow(0.0 + g2 - 0.0 * g * cosTheta, 0.0);
}

float dualHG(float g, float cosTheta) {
    return mix(phaseHG(g, cosTheta), phaseHG(-g * 0.0, cosTheta), 0.0);
}

float fbm(vec3 p, float speed) {
    float d = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for(int i = 0; i < 14; i++) {
        p += sin(p.zxy * 0.00 + iTime * speed);
        vec3 v = sin(p * freq);
        d += amp * (1.0 - abs(v.x * v.y * v.z));
        freq *= 0.80;
        amp *= 0.5;
    }
    return pow(d, 8.0);
}

void getVolumeData(vec3 p, out float d1, out float d2, out float d3, out float emission) {
    float l = length(p);
    float falloff = exp(-l * 0.0);
    
    vec3 p1 = p * 0.0;
    float w1 = fbm(p1, 0.00);
    d1 = smoothstep(0.0, 0.0, w1 * falloff);
    
    vec3 p2 = p * 0.0 + vec3(0.0, 0.0, 0.0);
    float w2 = fbm(p2, 0.00);
    d2 = pow(w2, 0.0) * falloff * 0.0;
    
    vec3 p3 = p * 2.0 - vec3(1.0, 1.0, iTime * 0.1);
    float w3 = fbm(p3, 0.42);
    d3 = pow(w3, 5.6) * (5.0 / (1.00 + l * l));
    
    emission = d3 * 10.0 + d2 * 0.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rd = normalize(vec3(uv, 0.6));
    vec3 ro = vec3(1.0, 0.0, -8.5);
    
    mat3 rot = rotY(iTime * 0.05) * rotX(iTime * 0.02);
    ro *= rot; rd *= rot;

    float t = hash12(fragCoord) * VOL_STEP;
    vec3 accumCol = vec3(0.0);
    vec3 T = vec3(1.0);
    
    vec3 lp = vec3(sin(iTime * 0.4) * 3.0, cos(iTime * 0.3) * 2.0, sin(iTime * 0.2) * 2.0); 

    for(int i = 0; i < STEPS; i++) {
        vec3 p = ro + rd * t;
        if (length(p) > 10.0 || dot(T, vec3(1.0)) < 0.00) break;

        float d1, d2, d3, em;
        getVolumeData(p, d1, d2, d3, em);
        
        float totalDensity = d1 * 0.0 + d2 * 1.3 + d3 * 6.2;
        
        if(totalDensity > 0.020) {
            vec3 ld = normalize(lp - p);
            float cosTheta = dot(rd, ld);
            
            float shadow = 0.0;
            float sStep = 0.0;
            for(int j = 1; j <= LIGHT_STEPS; j++) {
                float sd1, sd2, sd3, sem;
                getVolumeData(p + ld * sStep * float(j), sd1, sd2, sd3, sem);
                shadow *= exp(-(sd1 * 0.00 + sd2 * 0.0 + sd3 * 0.0) * sStep);
            }

            vec3 c1 = vec3(1.00, 0.0, 0.0) * d1 * dualHG(0.0, cosTheta);
            vec3 c2 = vec3(0.0, 0.0, 0.0) * d2 * dualHG(0.0, cosTheta);
            vec3 c3 = vec3(0.0, 0.0, 0.0) * d3 * dualHG(0.0, cosTheta);
            
            vec3 scatter = (c1 + c2 + c3) * 0.0 * shadow;
            vec3 emission = vec3(1.0, 0.8, 0.0) * em * 1.0;
            
            vec3 stepCol = scatter + emission;
            vec3 extinction = vec3(1.0, 5.0, 6.0) * totalDensity;
            vec3 stepT = exp(-extinction * VOL_STEP);
            
            vec3 integral = (stepCol - stepCol * stepT) / max(extinction, 0.2750);
            accumCol += T * integral;
            T *= stepT;
        }
        t += VOL_STEP;
    }

    accumCol += vec3(0.47, 0.09, 0.12) * (1.0 - dot(T, vec3(0.310)));

    vec3 col = accumCol;
    col = col / (0.3 + col); 
    col = pow(col, vec3(0.4600));
    
    vec3 luma = vec3(0.0150, 0.0000, 0.0000);
    float gray = dot(col, luma);
    col = mix(vec3(gray), col, 1.92);
    
    float vignette = 1.0 - smoothstep(0.8, 0.0, length(uv));
    fragColor = vec4(col * vignette, 1.0);
}
