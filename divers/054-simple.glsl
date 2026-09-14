// ==== Image (image) ====
#define DROPS 24
#define SUBSTRATE_ROUGHNESS 0.85
#define GAIN 1.4
#define OCTAVES 8
#define LOOP_DURATION 12.0

vec4 hash42(vec2 p) {
    vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

vec3 noised(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec2 du = 30.0*f*f*(f*(f-2.0)+1.0);
    
    vec4 h = vec4(hash42(i).x, hash42(i+vec2(1.0,0.0)).y, 
                  hash42(i+vec2(0.0,1.0)).z, hash42(i+vec2(1.0,1.0)).w);
    
    float k0 = h.x;
    float k1 = h.y - h.x;
    float k2 = h.z - h.x;
    float k4 = h.x - h.y - h.z + h.w;

    return vec3(k0 + k1*u.x + k2*u.y + k4*u.x*u.y, 
                du*(vec2(k1,k2) + k4*u.yx));
}

float substrate_fbm(vec2 p, out vec2 grad) {
    float v = 0.0;
    float a = 0.5;
    vec2 d = vec2(0.0);
    for(int i=0; i<OCTAVES; i++) {
        vec3 n = noised(p);
        d += n.yz;
        v += a * n.x / (1.0 + dot(d,d));
        p = mat2(1.6, 1.2, -1.2, 1.6) * p;
        a *= 0.45;
    }
    grad = d;
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = mod(iTime, LOOP_DURATION);

    vec2 p_grad;
    float paper = substrate_fbm(uv * 8.0, p_grad);
    
    vec3 col = vec3(0.98, 0.97, 0.94);
    col -= paper * 0.06;
    col -= length(p_grad) * 0.02;

    float total_ink = 0.0;
    float total_height = 0.0;
    vec3 ink_albedo = vec3(0.0);
    
    for(int i=0; i<DROPS; i++) {
        vec4 data = hash42(vec2(float(i), 19.31));
        float birth = data.w * (LOOP_DURATION - 4.0);
        float age = t - birth;
        
        if(age > 0.0) {
            vec2 pos = (data.xy - 0.5) * 2.8;
            pos.x *= iResolution.x / iResolution.y;
            
            float fade_out = smoothstep(LOOP_DURATION, LOOP_DURATION - 1.5, t);
            float dry_factor = smoothstep(5.0, 8.0, age);
            float spread = 0.22 * pow(min(age, 6.0), 0.4);
            
            vec2 distort_uv = uv - pos;
            distort_uv += p_grad * 0.015 * min(age, 1.5);
            float dist = length(distort_uv);
            
            float radius = spread + (paper * 0.05 * clamp(age, 0.0, 2.0));
            float mask = smoothstep(radius, radius - 0.04, dist) * fade_out;
            
            float fringe = pow(smoothstep(radius - 0.08, radius, dist), 2.5) * mask;
            fringe += (1.0 - smoothstep(0.0, 0.02, abs(dist - radius))) * 0.5 * mask;
            
            float h = mask * (1.0 - dry_factor) * exp(-age * 0.2);
            
            vec3 drop_col = mix(vec3(0.02, 0.05, 0.2), vec3(0.4, 0.1, 0.6), fringe);
            drop_col = mix(drop_col, vec3(0.1, 0.0, 0.1), clamp(paper * 0.5, 0.0, 1.0));
            
            float weight = mask + fringe;
            total_ink = max(total_ink, weight);
            total_height = max(total_height, h);
            ink_albedo = max(ink_albedo, drop_col * weight);
        }
    }

    vec3 normal = normalize(vec3(
        dFdx(total_height * 15.0),
        dFdy(total_height * 15.0),
        1.0
    ));

    vec3 light_dir = normalize(vec3(1.0, 1.0, 2.0));
    float spec = pow(max(dot(normal, light_dir), 0.0), 64.0) * total_height;
    
    vec3 final_ink = ink_albedo * (1.0 - paper * 0.15);
    col = mix(col, final_ink, total_ink);
    col += spec * 0.4;
    
    col *= 1.0 - dot(uv, uv) * 0.3;
    col += (hash42(uv + t).x - 0.5) * 0.015;

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
