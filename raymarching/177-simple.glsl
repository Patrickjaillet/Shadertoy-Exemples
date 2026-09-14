// ==== Image (image) ====
bool isPrime(int n) {
    if (n <= 1) return false;
    if (n == 2 || n == 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
}

vec2 getSpiralPos(int n) {
    float r = 0.06 * sqrt(float(n));
    float theta = float(n) * 2.39996323;
    return vec2(r * cos(theta), r * sin(theta));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    uv *= 2.2;
    
    float t = iTime * 3.0;
    
    float z[5];
    z[0] = 14.1347;
    z[1] = 21.0220;
    z[2] = 25.0108;
    z[3] = 30.4248;
    z[4] = 32.9350;
    
    float bg = 0.0;
    vec2 z_uv = uv * 1.5;
    float d_orig = length(z_uv);
    
    for(int i = 0; i < 5; i++) {
        float freq = z[i];
        bg += sin(freq * d_orig - iTime) * cos(freq * z_uv.x * 0.5 + iTime * 0.5);
    }
    bg *= 0.15;
    
    vec3 col = vec3(0.02, 0.05, 0.12) + vec3(0.15, 0.05, 0.25) * bg;
    
    float waves = 0.0;
    vec3 pointsCol = vec3(0.0);
    
    for (int i = 1; i < 400; i++) {
        vec2 pos = getSpiralPos(i);
        float d = length(uv - pos);
        
        float pBase = smoothstep(0.015, 0.005, d);
        pointsCol += vec3(0.2, 0.3, 0.4) * pBase;
        
        if (isPrime(i)) {
            waves += sin(15.0 * d - t) * exp(-4.0 * d) * 0.15;
            
            float pPrime = smoothstep(0.025, 0.005, d);
            pointsCol += vec3(1.0, 0.8, 0.2) * pPrime;
        }
    }
    
    col += vec3(0.1, 0.6, 1.0) * waves;
    col += pointsCol;
    
    fragColor = vec4(col, 1.0);
}
