// ==== Image (image) ====
float hache(vec2 p) {
    vec2 p2 = fract(p * vec2(123.34, 456.21));
    p2 = p2 + dot(p2, p2 + 45.32);
    return fract(p2.x * p2.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float temps4D = iTime * 0.7 + sin(iTime * 1.5) * 0.3; 
    float dist4D = length(uv);
    float angle4D = atan(uv.y, uv.x);
    
    dist4D = tan(dist4D * 2.5 - temps4D); 
    vec2 uv4D = vec2(cos(angle4D), sin(angle4D)) * dist4D;
    
    vec2 gv = uv4D * (8.0 + sin(temps4D) * 4.0); 
    vec2 id = floor(gv);
    gv = fract(gv) - 0.5;
    
    float h = hache(id);
    float dCentre = length(gv);
    float masqueSponge = smoothstep(0.45, 0.4, dCentre);
    
    float pores = step(0.6, hache(id + floor(gv * 12.0)));
    vec3 colSponge = vec3(1.0, 0.85, 0.1); 
    colSponge = mix(colSponge, vec3(0.4, 0.3, 0.0), pores * 0.8);
    
    vec3 couleurBase = vec3(0.0);
    if (masqueSponge > 0.5) {
        couleurBase = colSponge * (0.8 + 0.5 * h);
        couleurBase += vec3(1.0, 0.4, 0.0) * (1.0 - dCentre * 2.0) * 0.5;
    }
    
    vec3 bloom = vec3(0.0);
    float poidsTotal = 0.0;
    
    for(float x = -2.0; x <= 2.0; x += 1.0) {
        for(float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * 0.02;
            float dist_attenuation = exp(-length(vec2(x, y)) * 1.5);
            
            float d_sample = length(fract(gv + offset) - 0.5);
            float m_sample = smoothstep(0.45, 0.1, d_sample);
            
            if(m_sample > 0.1) {
                bloom += vec3(1.0, 0.6, 0.1) * m_sample * dist_attenuation;
                poidsTotal += dist_attenuation;
            }
        }
    }
    
    if(poidsTotal > 0.0) {
        bloom /= poidsTotal;
    }
    
    vec3 finalCol = couleurBase + bloom * 0.7;
    
    finalCol += vec3(0.1, 0.05, 0.2) * exp(-length(uv) * 2.0);
    finalCol *= (0.9 + 0.1 * sin(iTime * 15.0));
    
    fragColor = vec4(pow(finalCol, vec3(0.8)), 1.0);
}
