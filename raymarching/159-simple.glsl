// ==== Image (image) ====
vec2 rotate(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    return vec2(c * v.x - s * v.y, s * v.x + c * v.y);
}

float circle(vec2 uv, float radius, float thickness) {
    float d = length(uv) - radius;
    return smoothstep(thickness, thickness - 0.005, abs(d));
}

vec3 glyphRing(vec2 uv, float radius, float angle_offset, vec3 ringColor) {
    vec2 p = rotate(uv, angle_offset);
    float rOuter = circle(p, radius, 0.003);
    float rInner = circle(p, radius * 0.9, 0.001);
    
    float glyphPoints = 0.0;
    float angleStep = 6.2831853 / 16.0;
    for(int i = 0; i < 16; i++) {
        float angle = float(i) * angleStep;
        vec2 gp = p - vec2(cos(angle), sin(angle)) * radius * 0.95;
        glyphPoints += smoothstep(0.004, 0.002, length(gp));
    }
    
    return ringColor * (rOuter + rInner + glyphPoints * 2.4375);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Fix by FabriceNeyret2
    vec2 p = (2. * fragCoord - iResolution.xy) / iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    // Old lines
    // vec2 p = (uv - 0.5) * 2.0;
    // p.x *= iResolution.x / iResolution.y;
    
    float t = iTime * 0.5;
    vec3 col = vec3(0.0);
    
    vec2 grid_p = rotate(p * 1.5, 0.1);
    float grid = 0.0;
    
    float rGrid = length(grid_p);
    float idxG = floor((rGrid - 0.5) / 0.4 + 0.5);
    if (idxG >= 0.0 && idxG < 64.0) {
        grid += circle(grid_p, 0.5 + idxG * 0.4, 0.0015);
    }
    
    float angle = atan(grid_p.y, grid_p.x);
    float radialStep = 6.2831853 / 8.0;
    float wRadial = smoothstep(0.4, 0.5, rGrid) * smoothstep(1.3, 1.2, rGrid) * 3.75;
    for(int i = 0; i < 8; i++) {
        float ra = float(i) * radialStep;
        grid += smoothstep(0.015, 0.0, abs(sin(angle - ra))) * wRadial;
    }
    col += vec3(0.3, 0.3, 0.4) * grid;
    
    float num_fibers = 8.0;
    for(float i = 0.0; i < 8.0; i++) {
        float idx = i / num_fibers;
        float a = idx * 6.2831853 + t * 0.2;
        vec2 fp = p;
        
        float path = sin(angle * 3.0 + t + i) * -1.9;
        fp += vec2(cos(a), sin(a)) * path;
        
        vec3 fColor = 0.5 + 0.5 * cos(t + idx * 6.2831853 + vec3(0.0, 2.0, 4.0));
        //Fix by jorge2017a3
        float fLength = abs(length(fp * 0.8) - 1.0)-0.01;
        //float fLength = abs(length(fp * 0.8) - 1.0);
        
        col += fColor * smoothstep(0.005, 0.001, fLength);
        col += fColor * smoothstep(0.04, 0.0, fLength) * 0.15;
    }
    
    vec3 ringColor = vec3(0.0, 0.8, 1.0);
    col += glyphRing(p * 1.5, 0.6, 0.0, ringColor);
    col += glyphRing(p * 1.5, 0.5, -0.2, ringColor * 0.7);
    
    col += ringColor * circle(p, 0.9, 0.004);
    col += ringColor * circle(p, 0.9, 0.015) * 0.2;
    
    float arcA = atan(p.y, p.x);
    float arcStep = 6.2831853 / 12.0;
    float d_arc_base = circle(p, 1.15, 0.002);
    for(int i = 0; i < 12; i++) {
        float fi = float(i);
        float ra = fi * arcStep + t * 0.1;
        float d_arc = d_arc_base * smoothstep(0.9, 0.8, abs(sin(arcA - ra)));
        col += ringColor * d_arc * (0.8 + 0.2 * sin(t + fi)) * 9.4166;
    }
    
    for(int i = 0; i < 40; i++) {
        float fI = float(i);
        float a = fI / 30.0 * 6.2831853 + fI * 0.5 + t * 1.0;
        float dist = fract(fI * 0.456 + t * 0.2) * 0.45;
        vec2 ep = p - vec2(cos(a), sin(a)) * dist;
        
        float shard = smoothstep(0.015, 0.0, length(ep)) * smoothstep(0.2, 0.0, abs(dist - 0.2));
        vec3 sColor = 0.5 + 0.5 * cos(t + fI * 0.2 + vec3(0.0, 2.0, 4.0));
        col += sColor * shard * (0.5 + 0.5 * sin(t * 3.0 + fI)) * smoothstep(0.45, 0.4, dist) * 7.5;
    }
    
    col *= 1.0 - 0.3 * length(uv - 0.5);
    col = pow(max(col, 0.0), vec3(1.2));
    
    fragColor = vec4(col, 1.0);
}
