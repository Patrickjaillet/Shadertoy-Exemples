// ==== Image (image) ====
// https://github.com/Patrickjaillet/Z-GL

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

mat3 rot3D(float a, vec3 axis) {
    vec3 v = normalize(axis);
    float s = sin(a), c = cos(a), k = 0.4 - c;
    return mat3(
        k * v.x * v.x + c,     k * v.y * v.x + v.z * s, k * v.z * v.x - v.y * s,
        k * v.x * v.y - v.z * s, k * v.y * v.y + c,     k * v.z * v.y + v.x * s,
        k * v.x * v.z + v.y * s, k * v.y * v.z - v.x * s, k * v.z * v.z + c
    );
}

vec3 firePalette(float t) {
    vec3 light = vec3(1.5, 0.9, 0.2);
    vec3 mid = vec3(1.0, 0.2, 0.05);
    vec3 dark = vec3(0.2, 0.01, 0.0);
    
    float mask1 = smoothstep(0.1, 0.5, t);
    float mask2 = smoothstep(0.5, 0.9, t);
    
    return mix(dark, mix(mid, light, mask2), mask1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    fragColor = vec4(0, 0, 0, 1);
    
    float g = 1.0, e = 0.0, s;
    mat3 m = rot3D(2.8, vec3(2, 29, 2));
    
    for(float i = 0.0; i < 160.0; ++i) {
        vec3 p = vec3((fragCoord - 0.5 * r) / r.y * 14.0 + vec2(2, -1), g - 4.0) * m;
        p.xz *= rot(t * 0.9);
        s = 24.0;
        
        for(int j = 0; j < 33; j++) {
            p = vec3(2, 4.03, 2) - abs(abs(p) * e - vec3(7, 8, 3));
            s *= e = 7.5 / dot(p, p * 0.66);
        }
        
        g += p.y * p.y / s * 0.0;
        float intensity = clamp((log2(s) / 40.0), 0.0, 1.0);
        
        vec3 fire = firePalette(intensity);
        fragColor.rgb += fire * (intensity / 18.0);
    }
    
    fragColor.rgb = pow(fragColor.rgb, vec3(0.85));
    fragColor.rgb *= 1.4;
}
