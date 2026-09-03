// ==== Image (image) ====
void mainImage(out vec4 fragColor, vec2 fragCoord) {
    float time = iTime * 2.0;

    float angle = 0.5 + sin(time * 0.25);
    float sinAngle = sin(angle + 1.0 - cos(angle));
    float cosAngle = cos(angle + 1.0 - sin(angle));
    mat2 rotation = mat2(cosAngle, -sinAngle, sinAngle, cosAngle);

    vec3 cameraPosition = vec3(12.0 * sin(time * 0.25), 4.0 * cos(time * 0.5), time * 2.0);
    vec3 target = vec3(0.0, 0.0, time * 2.0 + 5.0);
    
    vec3 forward = normalize(target - cameraPosition);
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, forward);

    vec2 uv = (fragCoord - 0.5 * iResolution.xy);
    vec3 rayDirection = normalize(uv.x * right + uv.y * up + 1.2 * iResolution.y * forward);

    float totalDistance = 0.0;
    vec3 p = cameraPosition;
    vec4 accumulation = vec4(0.0);

    for (int i = 0; i < 40; i++) {
        vec3 q = p;
        q.z = mod(q.z, 10.0) - 5.0;
        
        float scale = 1.0;
        for (int j = 0; j < 4; j++) {
            q = abs(q) - 1.0;
            q.xy *= rotation;
            
            float dotQ = dot(q, q);
            float k = 1.2 / clamp(dotQ, 0.2, 1.0);
            q *= k;
            scale *= k;
        }

        float distance = max(length(q.xz) / scale, 0.005);
        totalDistance += distance;
        p += distance * rayDirection;

        float glow = 0.555 / exp(totalDistance / 20.0) / (6.0 + distance * 502.0);
        accumulation += vec4(glow);

        if (totalDistance > 25.0) break;
    }

    fragColor = accumulation;
}
