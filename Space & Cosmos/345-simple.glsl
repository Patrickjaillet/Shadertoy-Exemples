// ==== Image (image) ====
#define AA 1

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
// https://github.com/Patrickjaillet/Z-GL
float get_e(vec3 p, out float R_out, float time) {
    float R = length(p);
    R_out = R;
    vec3 q_prime = vec3(log2(R) - time * 0.5, exp2(R - p.z / R), time * 0.3 - atan(p.x, p.y) * 2.0);
    q_prime.y -= 1.0;
    
    float e = q_prime.y;
    float s = 4.0;
    for (int i = 0; i < 6; i++) { 
        e += dot(cos(q_prime.xz * s), sin(q_prime.xx * s + R + 1.0)) / s;
        s *= 2.0;
    }
    return e;
}

vec4 render(vec2 fragCoord, vec2 resolution, float time, out float rawGlow, out vec3 rayDir, out float structAlpha) {
    vec2 uv = (fragCoord - 0.5 * resolution.xy) / resolution.y;
    
    float orbitSpeed = time * 0.25;
    vec3 ro = vec3(cos(orbitSpeed) * 0.85, sin(time * 0.15) * 0.3 + 0.2, sin(orbitSpeed) * 0.85);
    vec3 target = vec3(sin(time * 0.1) * 0.05, cos(time * 0.05) * 0.05, 0.0);
    
    vec3 forward = normalize(target - ro);
    vec3 up = vec3(sin(time * 0.05) * 0.02, 1.0, 0.0);
    vec3 right = cross(up, forward);
    vec3 up_prime = cross(forward, right);
    
    vec3 rd = normalize(forward + uv.x * right * 0.55 + uv.y * up_prime * 0.55);
    rayDir = rd;
    
    float t = 0.02;
    float e;
    float R_de;
    vec3 current_pos;
    vec4 fragColor = vec4(0.0);
    float glow_accum = 0.0;
    float alpha_accum = 0.0;
    
    for (float i = 0.0; i < 140.0; i++) {
        current_pos = ro + rd * t;
        e = get_e(current_pos, R_de, time);
        
        float abs_e = abs(e);
        vec3 col_step = vec3(0.009) - exp(-abs_e * 180.0) * 0.08 * vec3(R_de + current_pos.z, 0.4, 0.25);
        
        col_step *= mix(vec3(1.0, 0.15, 0.05),
                        mix(vec3(0.8, 0.0, 0.95),
                            vec3(0.05, 0.45, 1.0),
                            smoothstep(0.4, 1.6, R_de)),
                        smoothstep(0.0, 0.4, R_de));
        
        float alpha = smoothstep(0.04, 0.0, abs_e);
        float weight = alpha * (1.0 - smoothstep(1.2, 3.5, t));
        fragColor.rgb += col_step * weight;
        alpha_accum += weight * (1.0 - alpha_accum);
        
        glow_accum += 1.0 / (1.0 + abs_e * 220.0) * (1.0 - smoothstep(0.0, 3.0, t));
        
        if (alpha_accum > 0.98 || t > 4.5) break;
        
        t += max(0.0004, abs_e * 0.04);
    }
    
    fragColor.rgb += vec3(0.75, 0.05, 1.0) * glow_accum * 0.022;
    
    rawGlow = glow_accum * 0.022;
    structAlpha = clamp(alpha_accum, 0.0, 1.0);
    
    return fragColor;
}

vec3 aces_tonemap(vec3 color) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 color = vec3(0.0);
    float glow = 0.0;
    vec3 rd = vec3(0.0);
    float structAlpha = 0.0;
    
    #if AA > 1
    for (int m = 0; m < AA; m++) {
        for (int n = 0; n < AA; n++) {
            vec2 offset = vec2(float(m), float(n)) / float(AA) - 0.5;
            float sampleGlow = 0.0;
            vec3 sampleRd = vec3(0.0);
            float sampleAlpha = 0.0;
            vec4 sampleColor = render(fragCoord + offset, iResolution.xy, iTime, sampleGlow, sampleRd, sampleAlpha);
            color += sampleColor.rgb;
            glow += sampleGlow;
            rd += sampleRd;
            structAlpha += sampleAlpha;
        }
    }
    color /= float(AA * AA);
    glow /= float(AA * AA);
    rd /= float(AA * AA);
    structAlpha /= float(AA * AA);
    #else
    float finalGlow = 0.0;
    vec3 finalRd = vec3(0.0);
    float finalAlpha = 0.0;
    vec4 finalColor = render(fragCoord, iResolution.xy, iTime, finalGlow, finalRd, finalAlpha);
    color = finalColor.rgb;
    glow = finalGlow;
    rd = finalRd;
    structAlpha = finalAlpha;
    #endif
    
    vec3 totalStars = vec3(0.0);
    
    vec2 starUV1 = rd.xy / (abs(rd.z) + 0.0001) * 12.0;
    vec2 ipos1 = floor(starUV1);
    vec2 fpos1 = fract(starUV1);
    float n1 = hash(ipos1);
    if (n1 > 0.94) {
        vec2 center1 = vec2(hash(ipos1 + 11.4), hash(ipos1 + 43.7)) * 0.6 + 0.2;
        float d1 = length(fpos1 - center1);
        float pulse1 = sin(iTime * 2.5 + n1 * 6.28) * 0.4 + 0.6;
        totalStars += vec3(smoothstep(0.035 * pulse1, 0.0, d1) * n1 * 1.5);
    }
    
    vec2 starUV2 = rd.xy / (abs(rd.z) + 0.0001) * 26.0;
    vec2 ipos2 = floor(starUV2);
    vec2 fpos2 = fract(starUV2);
    float n2 = hash(ipos2);
    if (n2 > 0.96) {
        vec2 center2 = vec2(hash(ipos2 + 73.1), hash(ipos2 + 19.5)) * 0.6 + 0.2;
        float d2 = length(fpos2 - center2);
        float pulse2 = sin(iTime * 4.0 + n2 * 6.28) * 0.3 + 0.7;
        totalStars += vec3(smoothstep(0.025 * pulse2, 0.0, d2) * n2 * 0.8);
    }
    
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722)) * 1.5;
    vec3 bwColor = vec3(luma);
    
    vec3 backgroundStars = totalStars * (1.0 - structAlpha);
    bwColor += backgroundStars;
    
    float bloomThreshold = 0.02;
    float bloomIntensity = 3.5;
    float bloomFactor = smoothstep(bloomThreshold, 0.1, glow) * glow * bloomIntensity;
    bwColor += vec3(bloomFactor);
    
    bwColor = pow(bwColor, vec3(1.0 / 2.2));
    bwColor = aces_tonemap(bwColor);
    
    fragColor = vec4(bwColor, 1.0);
}
