// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 res = iResolution, colorAcc = vec3(0.0), ro = vec3(0.0, 0.0, -3.8);
    float t = iTime;
    
    vec2 uv = (fragCoord - 0.5 * res.xy) / res.y;
    vec3 rd = normalize(vec3(uv, 1.4));
    // https://github.com/Patrickjaillet
    float angle = t * 0.084;
    vec3 axis = normalize(vec3(sin(t * 0.105), cos(t * 0.07), 0.8));
    float s3 = sin(angle), c3 = cos(angle), oc = 1.0 - c3;
    mat3 viewRot = mat3(
        oc * axis.x * axis.x + c3,          oc * axis.x * axis.y - axis.z * s3, oc * axis.z * axis.x + axis.y * s3,
        oc * axis.x * axis.y + axis.z * s3, oc * axis.y * axis.y + c3,          oc * axis.y * axis.z - axis.x * s3,
        oc * axis.z * axis.x - axis.y * s3, oc * axis.y * axis.z + axis.x * s3, oc * axis.z * axis.z + c3
    );
    ro *= viewRot; 
    rd *= viewRot;
    
    float g = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453) * 0.04;
    
    for (int i = 0; i < 120; i++) {
        vec3 p = ro + rd * g;
        
        float s_xz = sin(t * 0.21), c_xz = cos(t * 0.21);
        p.xz *= mat2(c_xz, -s_xz, s_xz, c_xz);
        
        float s_yz = sin(t * 0.315), c_yz = cos(t * 0.315);
        p.yz *= mat2(c_yz, -s_yz, s_yz, c_yz);
        
        float s = 1.0, e = 1.0;
        for (int j = 0; j < 5; j++) {
            p = vec3(0.1, 1.8, 1.1) - abs(abs(p) * e - vec3(1.4, -1.8, 0.7));
            e = 2.0 / clamp(dot(p, p), 0.08, 18.0);
            s *= e;
        }
        
        g += max(length(p) / s, 0.0005) * 0.45;
        
        vec3 p_hsv = abs(fract((length(p) * 0.08 + g * 0.02 + t * 0.15) + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
        colorAcc += (0.045 * mix(vec3(1.0), clamp(p_hsv - 1.0, 0.0, 1.0), 0.65)) * exp(-0.16 * g * g);
        
        if (g > 25.0) break;
    }
    
    fragColor = vec4(pow(max(colorAcc, 0.0), vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
vec2 mainSound(in int sampleRate, in float time) {
    float t = time;
    
    vec3 ro = vec3(0.0, 0.0, -3.8);
    vec3 rd = normalize(vec3(sin(t * 1.5) * 0.2, cos(t * 1.1) * 0.2, 1.4));
    
    float angle = t * 0.084;
    vec3 axis = normalize(vec3(sin(t * 0.105), cos(t * 0.07), 0.8));
    float s3 = sin(angle), c3 = cos(angle), oc = 1.0 - c3;
    mat3 viewRot = mat3(
        oc * axis.x * axis.x + c3,          oc * axis.x * axis.y - axis.z * s3, oc * axis.z * axis.x + axis.y * s3,
        oc * axis.x * axis.y + axis.z * s3, oc * axis.y * axis.y + c3,          oc * axis.y * axis.z - axis.x * s3,
        oc * axis.z * axis.x - axis.y * s3, oc * axis.y * axis.z + axis.x * s3, oc * axis.z * axis.z + c3
    );
    ro *= viewRot; 
    rd *= viewRot;
    
    float g = 0.0;
    vec3 colorAcc = vec3(0.0);
    
    for (int i = 0; i < 40; i++) {
        vec3 p = ro + rd * g;
        
        float s_xz = sin(t * 0.21), c_xz = cos(t * 0.21);
        p.xz *= mat2(c_xz, -s_xz, s_xz, c_xz);
        
        float s_yz = sin(t * 0.315), c_yz = cos(t * 0.315);
        p.yz *= mat2(c_yz, -s_yz, s_yz, c_yz);
        
        float s = 1.0, e = 1.0;
        for (int j = 0; j < 5; j++) {
            p = vec3(0.1, 1.8, 1.1) - abs(abs(p) * e - vec3(1.4, -1.8, 0.7));
            e = 2.0 / clamp(dot(p, p), 0.08, 18.0);
            s *= e;
        }
        
        g += max(length(p) / s, 0.005) * 0.5;
        
        vec3 p_hsv = abs(fract((length(p) * 0.08 + g * 0.02 + t * 0.15) + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
        colorAcc += (0.045 * mix(vec3(1.0), clamp(p_hsv - 1.0, 0.0, 1.0), 0.65)) * exp(-0.16 * g * g);
        
        if (g > 15.0) break;
    }
    
    float sigLeft = sin(colorAcc.r * 25.0 + t * 220.0 * 6.283185) * cos(colorAcc.g * 5.0);
    float sigRight = sin(colorAcc.b * 25.0 + t * 222.0 * 6.283185) * sin(colorAcc.g * 5.0);
    
    vec2 signal = vec2(sigLeft, sigRight) * (1.0 / (1.0 + g * 0.1));
    
    return clamp(signal * 0.12, -1.0, 1.0);
}
