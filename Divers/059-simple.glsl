// ==== Image (image) ====
mat2 rotate2D(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 col = vec4(0.0);
    vec3 f = vec3(0.6, 0.2, 2.0);
    vec3 p = vec3(0.0);
    
    float g = 0.0;
    float e = 0.0;
    float S = 0.0;
    float u = 0.0;

    mat2 M = rotate2D(iTime / 8.0);

    vec3 rayDir = vec3(fragCoord.xy / iResolution.y - vec2(1.0), -1.0);

    for (int i = 0; i < 50; i++) {
        p = rayDir * g;
        
        p.yz *= M * M;
        p -= vec3(1.0);
        p.yx *= M;
        
        S = 5.0;
        
        for (int j = 0; j < 20; j++) {
            p = 2.0 * clamp(p, -f, f) - p;
            u = dot(p, p) * (0.6 + g * 0.2);
            p /= u;
            S /= u;
        }

        e = 0.0005 + p.z / S;
        g -= e;
        
        p.z += 1.0;
        
        vec4 term = sin(vec4(3.0, 4.0, 5.0, 0.0) * exp(p.z) - log(abs(S)));
        col += exp(-e * e * 1e13 / S + term) / 100.0;
    }

    fragColor = col;
}
