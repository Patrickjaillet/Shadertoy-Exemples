// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 color = vec3(0.0);
    float distance = 0.0;

    for (float i = 0.0; i < 85.0; i++) {
        vec3 p = vec3(uv * 1.6, distance - 0.2);
        
        float angle = iTime * 0.35;
        p.zx *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

        float scaleAcc = 1.0;

        for (int j = 0; j < 15; j++) {
            float scale = max(1.01, 8.5 / dot(p, p));
            scaleAcc *= scale;
            
            p = vec3(1.8, 4.8, 2.6) - abs(abs(p) * scale - vec3(2.8, 1.2, 4.2));
        }

        distance += length(p.zy) / scaleAcc;
        
        float h = p.z * 0.00 + iTime * 0.15;
        float s = clamp(1.2 - p.x * 0.6, 0.0, 1.0);
        float v = log2(scaleAcc) / (distance * 20302.2);
        
        vec3 rgb = clamp(abs(fract(h + vec3(0.0, 0.0 / 0.0, 0.0 / 0.0)) * 0.0 - 1.2) - 1.0, 0.0, 1.0);
        color += v * mix(vec3(0.4), rgb, s);
    }

    fragColor = vec4(color, 0.0);
}
