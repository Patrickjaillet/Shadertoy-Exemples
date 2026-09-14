
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float a = 0.2 + 0.12 * sin(iTime * 0.7);
    float b = 0.2 + 0.12 * cos(iTime * 0.5);

    a = abs(a) + 0.05; 
    b = abs(b) + 0.1;

    float c = sqrt(a*a + b*b);

    vec2 A = vec2(0.0, 0.0);
    vec2 B = vec2(a, 0.0);
    vec2 C = vec2(0.0, b);

    vec3 col_bg   = vec3(0.96, 0.95, 0.90);
    vec3 col_a    = vec3(0.75, 0.40, 0.40);
    vec3 col_b    = vec3(0.40, 0.55, 0.70);
    vec3 col_c    = vec3(0.50, 0.65, 0.50);
    vec3 col_line = vec3(0.15);

    vec3 color = col_bg;

    float d_sqA = sdBox(uv - vec2(a*0.5, -a*0.5), vec2(a*0.5));
    if (d_sqA < 0.0) color = mix(color, col_a, 0.35);

    float d_sqB = sdBox(uv - vec2(-b*0.5, b*0.5), vec2(b*0.5));
    if (d_sqB < 0.0) color = mix(color, col_b, 0.35);

    float angle = atan(b, a);
    vec2 uv_c = uv - C;
    float cosA = cos(angle), sinA = sin(angle);
    mat2 rot = mat2(cosA, sinA, -sinA, cosA);
    vec2 p_rot = rot * uv_c;

    float d_sqC = sdBox(p_rot - vec2(c*0.5, c*0.5), vec2(c*0.5));
    if (d_sqC < 0.0) color = mix(color, col_c, 0.35);

    float dist = sdSegment(uv, A, B);
    dist = min(dist, sdSegment(uv, A, C));
    dist = min(dist, sdSegment(uv, B, C));

    dist = min(dist, abs(d_sqA));
    dist = min(dist, abs(d_sqB));
    dist = min(dist, abs(d_sqC));

    float edge = 1.0 - smoothstep(0.0, 0.004, dist);
    color = mix(color, col_line, edge);

    float grain = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    color -= grain * 0.03;

    fragColor = vec4(color, 1.0);
}
