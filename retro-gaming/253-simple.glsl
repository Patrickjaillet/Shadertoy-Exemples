// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.1, 0.4, 0.8);
    
    vec2 p = uv;
    p.y -= 0.05;
    vec2 d = abs(p) - vec2(0.35, 0.4);
    float body = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - 0.05;
    body -= sin(uv.x * 40.0) * cos(uv.y * 40.0) * 0.01;
    col = mix(col, vec3(1.0, 0.9, 0.1), 1.0 - smoothstep(0.0, 0.01, body));

    vec2 pantsD = abs(uv - vec2(0.0, -0.38)) - vec2(0.38, 0.06);
    float pants = length(max(pantsD, 0.0)) + min(max(pantsD.x, pantsD.y), 0.0) - 0.02;
    col = mix(col, vec3(0.4, 0.2, 0.0), 1.0 - smoothstep(0.0, 0.01, pants));

    vec2 shirtD = abs(uv - vec2(0.0, -0.28)) - vec2(0.37, 0.05);
    float shirt = length(max(shirtD, 0.0)) + min(max(shirtD.x, shirtD.y), 0.0) - 0.02;
    col = mix(col, vec3(0.95), 1.0 - smoothstep(0.0, 0.01, shirt));

    float tie = min(length(max(abs(uv - vec2(0.0, -0.3)) - vec2(0.02, 0.02), 0.0)) - 0.01, length(max(abs(uv - vec2(0.0, -0.37)) - vec2(0.04, 0.05), 0.0)) - 0.01);
    col = mix(col, vec3(0.8, 0.1, 0.1), 1.0 - smoothstep(0.0, 0.01, tie));

    vec2 el = uv - vec2(-0.15, 0.1);
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, length(el) - 0.12));
    col = mix(col, vec3(0.2, 0.6, 0.9), 1.0 - smoothstep(0.0, 0.01, length(el) - 0.05));
    col = mix(col, vec3(0.0), 1.0 - smoothstep(0.0, 0.01, length(el) - 0.025));

    vec2 er = uv - vec2(0.15, 0.1);
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, length(er) - 0.12));
    col = mix(col, vec3(0.2, 0.6, 0.9), 1.0 - smoothstep(0.0, 0.01, length(er) - 0.05));
    col = mix(col, vec3(0.0), 1.0 - smoothstep(0.0, 0.01, length(er) - 0.025));

    float nose = length(max(abs(uv - vec2(0.0, 0.01)) - vec2(0.02, 0.03), 0.0)) - 0.02;
    col = mix(col, vec3(0.9, 0.8, 0.0), 1.0 - smoothstep(0.0, 0.01, nose));

    vec2 mp = uv - vec2(0.0, -0.04);
    float mouth = max(length(mp) - 0.12, -(length(mp - vec2(0.0, 0.06)) - 0.12));
    col = mix(col, vec3(0.4, 0.1, 0.1), 1.0 - smoothstep(0.0, 0.01, mouth));

    vec2 tp1 = uv - vec2(-0.03, -0.11);
    float tooth1 = length(max(abs(tp1) - vec2(0.01, 0.02), 0.0)) - 0.005;
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, tooth1));

    vec2 tp2 = uv - vec2(0.03, -0.11);
    float tooth2 = length(max(abs(tp2) - vec2(0.01, 0.02), 0.0)) - 0.005;
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, tooth2));

    fragColor = vec4(col, 1.0);
}
