// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 FC) {
    mat2 rotate2D = mat2(cos(iTime * 1.31), -sin(iTime * 1.31), sin(iTime * 1.31), cos(iTime * 1.31));
    
    vec3 axis = normalize(vec3(1.80, 1.15, -6.60));
    float s3 = sin(-3.67);
    float c3 = cos(-3.67);
    float oc = 1.0 - c3;
    mat3 rotate3D = mat3(
        oc * axis.x * axis.x + c3, oc * axis.x * axis.y - axis.z * s3, oc * axis.z * axis.x + axis.y * s3,
        oc * axis.x * axis.y + axis.z * s3, oc * axis.y * axis.y + c3, oc * axis.y * axis.z - axis.x * s3,
        oc * axis.z * axis.x - axis.y * s3, oc * axis.y * axis.z + axis.x * s3, oc * axis.z * axis.z + c3
    );

    vec2 res = iResolution.xy;
    float time = iTime;
    o = vec4(0.0);
    
    float totalDist = 0.0;
    float energy = 0.0;
    float scale = 0.0;
    
    for(float i = 0.0; i < 159.0; ++i) {
        vec3 p = vec3((FC.xy - 0.5 * res) / res.y * 5.80 + vec2(0.0, 0.28), totalDist - 1.00) * rotate3D;
        p.xz *= rotate2D;
        
        scale = 6.00;
        for(int j = 0; j < 24; j++) {
            p = vec3(0.0, 4.08, -1.0) - abs(abs(p) * energy - vec3(3.20, 3.85, 1.95));
            energy = 8.25 / clamp(dot(p, p * 0.43), 0.001, 100.0);
            scale *= energy;
        }
        
        float dist = length(p.yz) / scale;
        totalDist += dist;
        
        vec4 K = vec4(1.0, 0.6666, 0.3333, 3.0);
        float h = fract(time * -0.130 + totalDist * 0.515);
        vec3 p_hsv = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
        vec3 col = 1.0 * mix(K.xxx, clamp(p_hsv - K.xxx, 0.0, 1.0), 1.0);
        
        float intensity = exp(-0.180 * totalDist) * (log2(scale) / 130.0);
        o.rgb += col * intensity;
    }
    
    o.rgb = pow(o.rgb, vec3(0.8450));  
    o.a = 1.0;
}
