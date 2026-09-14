// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    float i=0., e, R, s;
    vec3 q, p, d = vec3(C/iResolution.xy-vec2(.5, -.6), .4);
    O = vec4(0);
    q.yz -= .5;
    for (; i++ < 200.;) {
        vec3 c = clamp(abs(mod(e*38.3+vec3(-12, -60, -20), -23.)-11.), 1., 1.);
        O.rgb += c*min(e*s, 1.-e)/127.6;
        s = 7.5;
        p = q += d*e*R*.5;
        R = length(p);
        p = vec3(log(R)-iTime*.5, exp(-p.z/R+.55), atan(p.x, p.y));
        e = --p.y;
        for (; s < 4e2; s += s)
            e -= abs(dot(cos(p.zxy*s), .3-sin(p*s)))/s;
    }
    O.a = smoothstep(0., 0., O.r+O.g+O.b);
// https://github.com/Patrickjaillet/Z-GL
    vec2 uv = C / iResolution.xy;
    float splat = 0.0;
    float aspect = iResolution.x / iResolution.y;

    for (float j = 1.0; j < 9.0; j++) {
        vec3 rand = fract(sin(vec3(j * 15.34, j * 93.71, j * 45.12)) * 43758.54);
        
        float cycle = 7.0;
        float id_cycle = floor((iTime + rand.z * cycle) / cycle);
        float t = mod(iTime + rand.z * cycle, cycle);
        
        if (t < 0.1) continue;

        vec2 seed = rand.xy + vec2(id_cycle * 23.41, id_cycle * 71.83);
        vec2 p_pos = fract(sin(seed) * 43758.54) * 0.8 + 0.1;
        float p_size = rand.z * 0.06 + 0.02;

        float impact = smoothstep(0.1, 0.2, t);
        float current_size = p_size * smoothstep(0.0, 0.1, t) * (1.0 - 0.2 * impact);

        vec2 to_center = (uv - p_pos) * vec2(aspect, 1.0);
        float dist = length(to_center);
        float angle = atan(to_center.y, to_center.x);

        float r_noise = sin(angle * 7.0 + j) * 0.35 + cos(angle * 14.0 - j) * 0.2 + sin(angle * 31.0) * 0.1;
        float radius = current_size * (1.0 + r_noise * (0.5 / (0.1 + t * 4.0)));
        float main_drop = smoothstep(radius, radius - 0.008, dist);

        float flow_progress = max(0.0, t - 0.15);
        float flow_len = pow(flow_progress, 0.7) * 0.45;
        
        float flow_mask = 0.0;
        float n_filaments = 3.0;
        
        for (float k = 0.0; k < n_filaments; k++) {
            float f_rand = fract(sin(j * 12.89 + k * 45.23 + id_cycle * 13.57) * 19.34);
            
            float f_angle = -1.5708 + (f_rand - 0.5) * 1.8;
            vec2 f_dir = vec2(cos(f_angle), sin(f_angle));
            
            float f_speed = 0.6 + 0.4 * fract(f_rand * 5.0);
            float cur_flow_len = flow_len * f_speed;
            
            vec2 f_origin = p_pos + f_dir * (current_size * 0.8);
            vec2 to_f = (uv - f_origin) * vec2(aspect, 1.0);
            
            float proj = dot(to_f, f_dir);
            vec2 ortho_vec = to_f - proj * f_dir;
            float ortho_dist = length(ortho_vec);
            
            if (proj > 0.0 && proj < cur_flow_len) {
                float seg = proj / cur_flow_len;
                
                float wave = sin(proj * 60.0 + j * 5.0 + id_cycle) * 0.003 * (1.0 - seg);
                ortho_dist += wave;

                float f_thick = current_size * 0.18 * pow(1.0 - seg, 1.5) * smoothstep(cur_flow_len, cur_flow_len - 0.02, proj);
                
                float f_drop_radius = f_thick * 1.3;
                float f_head = smoothstep(f_drop_radius, f_drop_radius - 0.005, length(to_f - f_dir * cur_flow_len));
                
                float f_body = smoothstep(f_thick, f_thick - 0.005, ortho_dist);
                
                flow_mask = max(flow_mask, max(f_body, f_head));
            }
        }

        splat = max(splat, max(main_drop, flow_mask));
    }

    vec3 ink_color = vec3(0.002, 0.002, 0.004);
    
    vec2 eps = vec2(0.003, 0.0);
    float spec = max(0.0, dot(normalize(vec3(0.2, 0.2, 1.0)), normalize(vec3(splat, splat, 1.0))));
    ink_color += vec3(0.1, 0.3, 0.5) * pow(spec, 8.0) * splat * 0.08;

    O.rgb = mix(O.rgb, ink_color, splat);
}
