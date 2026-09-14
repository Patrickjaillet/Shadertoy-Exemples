// ==== Image (image) ====
vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

mat2 rot2d(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 rd = normalize(vec3(uv, 0.8));
    vec3 ro = vec3(0.0, 0.0, -1.0);
    
    float t = iTime;
    
    rd.xy *= rot2d(t * 0.05);
    rd.xz *= rot2d(sin(t * 0.1) * 0.1);
    
    vec3 p = ro;
    vec3 col = vec3(0.0);
    float dist = 0.0;
    float stepDist = 0.0;
    float radius = 0.0;

    for (float i = 0.0; i < 120.0; i++) {
        radius = length(p);
        
        vec3 p_log = vec3(
            log(radius) - t * 0.8,
            exp(0.8 - p.z / radius) - 1.0,
            //atan(p.y, p.x) + t * 0.4
            
            // Fix by Chimel - https://www.shadertoy.com/user/Chimel
            atan(p.y, p.x+0.001*(1.-abs(sign(p.x)))) + t * 0.4
        );

        vec2 texUV = vec2(p_log.x, p_log.z * 0.1591);
        vec4 tex = textureLod(iChannel0, texUV, 0.0);
        float noise = (tex.r + tex.g + tex.b) * 0.333;

        float s = 1.0;
        float e = p_log.y + noise * 0.1;
        
        for (int j = 0; j < 8; j++) {
            vec3 sampling = p_log.yzz * s;
            e += dot(sin(sampling) - 0.5, 0.8 - sin(p_log.zxx * s)) / s * 0.3;
            s *= 2.0;
        }

        stepDist = e;
        
        float intensity = min(stepDist * s, 0.7 - stepDist) / 35.0;
        intensity = clamp(intensity, 0.0, 1.0);
        
        float hue = fract(p_log.z * 0.1591 + p_log.x * 0.05 + noise * 0.1 + t * 0.05);
        float sat = 0.65 + noise * 0.35;
        
        vec3 spectralColor = hsv(hue, sat, intensity);
        
        float scattering = 1.0 / (1.0 + stepDist * stepDist * 40.0);
        col += spectralColor * (0.5 + noise) * scattering * (1.0 - i / 120.0);
        
        p += rd * max(stepDist * radius * 0.18, 0.002);
        
        if (radius > 25.0) break;
    }

    col = mix(col, vec3(0.005, 0.002, 0.01), 1.0 - exp(-0.01 * radius * radius));
    
    col = pow(col, vec3(0.4545));
    
    col = col * col * (3.0 - 2.0 * col);
    
    col *= 1.25 - length(uv) * 0.65;
    
    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
