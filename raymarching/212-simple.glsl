// ==== Image (image) ====
mat2 h(float v) {
    float c = cos(v), s = sin(v);
    return mat2(c, -s, s, c);
}

vec3 l(float c, float s, float d) {
    vec3 a = clamp(abs(mod(c * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return d * mix(vec3(1.0), a, s);
}

float map(vec3 p, float t) {
    float sphere_dist = length(p) - 1.5;

    vec3 p_fold = p;
    p_fold.zx *= h(t * 1.2);
    p_fold.xy *= h(t * 0.8);
    
    float scale = 1.0;
    float e = 1.0;
    for(int k = 0; k < 8; k++) {
        p_fold = 2.2 - abs(p_fold * e - 0.4 / max(e, 0.001)) - sin(t * 0.5) * 0.05;
        float q = dot(p_fold * (2.0 - sin(t * 0.2) * 0.3), p_fold * 1.5);
        e = max(1.15, 4.5 / max(q, 0.005));
        scale *= e;
    }
    
    float fractal_dist = distance(p_fold.xz, p_fold.yx) / scale;
    fractal_dist = max(fractal_dist, 0.001);

    return max(sphere_dist, fractal_dist * 0.4); 
}

vec3 calcNormal(vec3 p, float t) {
    float eps = 0.001;
    vec2 k = vec2(1.0, -1.0);
    return normalize(
        k.xyy * map(p + k.xyy * eps, t) +
        k.yyx * map(p + k.yyx * eps, t) +
        k.yxy * map(p + k.yxy * eps, t) +
        k.xxx * map(p + k.xxx * eps, t)
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.25;
    
    vec3 ro = vec3(0.0, 0.0, -3.5);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    vec3 col = vec3(0.0);
    float t_march = 0.0;
    
    for(int g = 0; g < 160; g++) {
        vec3 p = ro + rd * t_march;
        float d = map(p, t);

         vec3 p_fold = p;
        p_fold.zx *= h(t * 1.2); p_fold.xy *= h(t * 0.8);
        float scale = 1.0; float e = 1.0;
        for(int k = 0; k < 8; k++) {
            p_fold = 2.2 - abs(p_fold * e - 0.4 / max(e, 0.001)) - sin(t * 0.5) * 0.05;
            float q = dot(p_fold * (2.0 - sin(t * 0.2) * 0.3), p_fold * 1.5);
            e = max(1.15, 4.5 / max(q, 0.005)); scale *= e;
        }
        float fractal_dist_pure = distance(p_fold.xz, p_fold.yx) / scale;

        float r = exp(-fractal_dist_pure * 24.0) * exp(-t_march * 0.15);
        col += l(1.5 + float(g) * 0.01 - t * 0.3, 0.85, r * 0.18);
        
        if(t_march > 30.0 || d < 0.001) break;
        t_march += d * 0.6;
    }
    
    vec3 final_col = col;
    float sphere_t = 0.0;
    float sphere_dist_travelled = 0.0;
    bool hit_sphere = false;
    for(int i = 0; i < 80; i++) {
        vec3 p = ro + rd * sphere_t;
        float d = length(p) - 1.5; 
        if(d < 0.001) { hit_sphere = true; break; }
        sphere_t += d;
        if(sphere_t > 30.0) break;
    }

    if(hit_sphere) {
        vec3 p = ro + rd * sphere_t;
        vec3 n = normalize(p);
        vec3 ref = reflect(rd, n);
        
        float fresnel = pow(1.0 - max(dot(-rd, n), 0.0), 3.0);
        float specular = pow(max(dot(ref, normalize(vec3(1.0, 2.0, -1.0))), 0.0), 32.0);
        
        final_col = col * 0.5 + fresnel * 0.5 + specular * 0.8;
        final_col *= 0.9 + 0.1 * n.y; 
        
        if(sphere_t > 1.5) final_col *= 0.1;
    }

    final_col = pow(final_col, vec3(0.4545));
    fragColor = vec4(final_col, 1.0);
}
/***********************************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____                       *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \                      *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |                     *
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |                     *
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/                      *
*            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]                                 *
************************************************************************************
* - Software:       https://patrickjaillet.github.io/sandefjord-software           *
* - Social Network: https://x.com/JailletPatrick                                   *
* - Music:          https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g       *
************************************************************************************
*           Software used for GLSL shader creation:                                *
*                ******************************                                    *
* GLSL shader design and value tweaking                                            *
* - Sliders-GL v1.0.1:                                                             *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl *
*                                                                                  *
* 100% safe Code Golfing                                                           *
* - µShader v3.0.1:                                                                *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader*
*                                                                                  *
* Formatting & Layout                                                              *
* - ShaderFmt v1.0.0:                                                              *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt  *
***********************************************************************************/
