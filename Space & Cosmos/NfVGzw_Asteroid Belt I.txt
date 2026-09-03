// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software

mat2 rotate2D(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

mat3 rotate3D(float angle, vec3 axis) {
    vec3 a = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat3(
        oc * a.x * a.x + c,       oc * a.x * a.y - a.z * s, oc * a.z * a.x + a.y * s,
        oc * a.x * a.y + a.z * s, oc * a.y * a.y + c,       oc * a.y * a.z - a.x * s,
        oc * a.z * a.x - a.y * s, oc * a.y * a.z + a.x * s, oc * a.z * a.z + c
    );
}

float fastHash(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

float fastNoise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float n000 = fastHash(i);
    float n100 = fastHash(i + vec3(1.0, 0.0, 0.0));
    float n010 = fastHash(i + vec3(0.0, 1.0, 0.0));
    float n110 = fastHash(i + vec3(1.0, 1.0, 0.0));
    float n001 = fastHash(i + vec3(0.0, 0.0, 1.0));
    float n101 = fastHash(i + vec3(1.0, 0.0, 1.0));
    float n011 = fastHash(i + vec3(0.0, 1.0, 1.0));
    float n111 = fastHash(i + vec3(1.0, 1.0, 1.0));

    vec4 n4_0 = vec4(n000, n100, n010, n110);
    vec4 n4_1 = vec4(n001, n101, n011, n111);
    
    vec2 n2_0 = mix(n4_0.xz, n4_0.yw, f.x);
    vec2 n2_1 = mix(n4_1.xz, n4_1.yw, f.x);
    
    float n_0 = mix(n2_0.x, n2_0.y, f.y);
    float n_1 = mix(n2_1.x, n2_1.y, f.y);

    return mix(n_0, n_1, f.z);
}

float fastFbm(vec3 p) {
    float value = 0.0;
    float amp = 0.5;
    mat3 rot = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
    
    value += amp * fastNoise3D(p); p = rot * p * 2.04; amp *= 0.50;
    value += amp * fastNoise3D(p); p = rot * p * 2.02; amp *= 0.50;
    value += amp * fastNoise3D(p);
    
    return value;
}

vec3 nebulaDensityFast(vec3 p) {
    vec3 q = p * 0.25 + vec3(iTime * 0.02, -iTime * 0.015, iTime * 0.01);
    
    float n1 = fastFbm(q);
    float n2 = fastFbm(q * 1.8 + vec3(n1 * 1.8));

    float density = smoothstep(0.40, 0.85, n1 * n2 * 2.5);
    if (density <= 0.001) return vec3(0.0);

    vec3 colA = vec3(0.05, 0.35, 0.85);
    vec3 colB = vec3(0.95, 0.15, 0.55);
    vec3 colC = vec3(0.10, 0.85, 0.65);

    vec3 color = mix(colA, colB, n1);
    color = mix(color, colC, n2 * n2);
    color += vec3(0.5, 0.2, 0.8) * pow(n2, 3.0) * 2.0;

    return color * density;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.3 * iResolution.xy) / iResolution.y;
    vec3 rayOrigin = vec3(0.0, 0.0, -2.5);
    vec3 rayDir = normalize(vec3(uv, 0.5));

    mat3 camRot = rotate3D(iTime * 0.03, vec3(0.1, 1.0, 0.2));
    rayDir = camRot * rayDir;

    vec3 finalColor = vec3(0.0);
    vec3 nebulaAccum = vec3(0.0);
    float transmittance = 1.0;
    float totalDist = 0.0;
    bool hit = false;
    vec3 glowAccum = vec3(0.0); // Accumulateur de glow

    float jitter = fastHash(vec3(fragCoord, iTime)) * 0.05;
    totalDist += jitter;

    vec3 lightPos = vec3(sin(iTime * 0.2) * 4.0, cos(iTime * 0.15) * 3.0, 2.0);

    for (int i = 0; i < 72; i++) {
        vec3 p = rayOrigin + rayDir * totalDist;

        float rawRadius = length(p);
        float radius = sqrt(rawRadius * rawRadius + 0.1);

        float logR = log(radius);
        float angle = atan(p.z, p.x);
        float axial = p.y / radius;

        vec3 logP = vec3(logR - iTime * 0.04, axial, angle * 0.63661977);
        logP.xz *= rotate2D(iTime * 0.03 + logR * 0.2);

        vec3 foldP = logP;
        float scaleAcc = 1.0;

        for (int j = 0; j < 6; j++) {
            foldP = abs(mod(foldP - 0.8, 2.0) - 1.0);
            foldP.yz *= rotate2D(0.78539816);
            
            float dotP = dot(foldP, foldP);
            dotP = clamp(dotP, 0.30, 3.3);
            
            foldP = foldP / dotP - vec3(0.0, 0.3, 0.8);
            scaleAcc /= dotP;
        }

        float boxSdf = max(abs(foldP.x), max(abs(foldP.y), abs(foldP.z))) - 0.3;
        float cylinderSdf = length(foldP.xz) - 0.10;
        float localSdf = max(boxSdf, -cylinderSdf);

        float sdf = (localSdf / scaleAcc) * radius;

        float glowFactor = 0.001 / (abs(sdf) + 0.005); 
        vec3 glowColor = 0.6 + 0.4 * cos(vec3(0.0, 1.5, 3.3) + foldP.z * -8.1 + iTime * 0.5);
        glowAccum += glowColor * glowFactor * transmittance * 0.2; 

        if (transmittance > 0.05 && (i % 2 == 0)) {
            vec3 nebCol = nebulaDensityFast(p);
            float stepLen = max(abs(sdf) * 0.8, 0.08);
            float density = length(nebCol);
            
            if (density > 0.001) {
                float opticalDepth = density * stepLen * 0.5;
                float stepTransmittance = exp(-opticalDepth);
                
                vec3 lDir = normalize(lightPos - p);
                float lightAtten = 1.0 / (1.0 + dot(lightPos - p, lightPos - p) * 0.05);
                float forwardScattering = pow(max(dot(rayDir, lDir), 0.0), 3.0) * 1.2;
                
                vec3 stepEmission = nebCol * (1.0 + forwardScattering) * lightAtten;
                nebulaAccum += stepEmission * (1.0 - stepTransmittance) * transmittance;
                transmittance *= stepTransmittance;
            }
        }

        if (abs(sdf) < 0.0015) {
            vec3 normal = normalize(vec3(
                sin(foldP.x * 40.0),
                cos(foldP.y * 40.0),
                sin(foldP.z * 2.9)
            ));

            vec3 lightDir = normalize(vec3(0.0, 0.0, 6.0));
            float diff = max(dot(normal, lightDir), 0.0);

            vec3 baseColor = 0.6 + 0.0 * cos(vec3(0.0, 1.5, 3.3) + foldP.z * -8.1 + iTime * 0.5);
            finalColor = baseColor * diff;
            hit = true;
            break;
        }

        totalDist += sdf * 0.55;

        if (totalDist > 25.0 || transmittance < 0.02) {
            break;
        }
    }

    if (!hit) {
        finalColor = vec3(0.0);
    }

    finalColor = finalColor * transmittance + nebulaAccum + glowAccum;

    vec3 bgGrad = mix(vec3(0.005, 0.008, 0.02), vec3(0.02, 0.01, 0.04), uv.y + 0.5);
    finalColor += bgGrad * transmittance * 0.5;

    finalColor = finalColor / (1.0 + finalColor * 0.65);
    finalColor = pow(finalColor, vec3(0.85));

    fragColor = vec4(finalColor, 1.0);
}
