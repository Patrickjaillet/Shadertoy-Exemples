// ==== Image (image) ====
#define VITESSE 1.0
#define NIVEAU_EAU -0.6
#define COULEUR_LUMIERE vec3(1.0, 0.8, 0.5)
#define ESPACEMENT_LUMIERES 5.0
#define COULEUR_EAU_BLEUE vec3(0.05, 0.3, 0.8)

float TAU = 6.2831853;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    return fract(p.x * p.y + dot(p, p + 45.32));
}

float get_curve(float z) {
    return sin(z * 0.25) * 1.2;
}

float texture_briques(vec2 p) {
    vec2 p_b = p * vec2(4.0, 8.0);
    vec2 id = floor(p_b);
    p_b = fract(p_b);
    if(mod(id.y, 2.0) == 1.0) p_b.x = fract(p_b.x + 0.5);
    float res = 1.0;
    if(p_b.x < 0.03 || p_b.x > 0.97 || p_b.y < 0.03 || p_b.y > 0.97) res = 0.15;
    return res * (0.7 + 0.3 * hash(id));
}

float map(vec3 p) {
    float curve = get_curve(p.z);
    p.x -= curve;
    float tunnel = 1.2 - length(p.xy);
    float vagues = 0.02 * sin(p.x * 12.0 + iTime) * cos(p.z * 8.0 + iTime);
    float eau = p.y - (NIVEAU_EAU + vagues);
    float p1 = length(p.xy - vec2(-1.0, -0.4)) - 0.15;
    float p2 = length(p.xy - vec2(1.0, 0.2)) - 0.08;
    return min(min(tunnel, eau), min(p1, p2));
}

vec3 get_lights(vec3 p, vec3 n, vec3 rd) {
    vec3 total = vec3(0.0);
    float z_base = floor(p.z / ESPACEMENT_LUMIERES) * ESPACEMENT_LUMIERES;
    for(float i = -1.0; i <= 1.0; i++) {
        float z_l = z_base + i * ESPACEMENT_LUMIERES;
        vec3 l_pos = vec3(get_curve(z_l), 1.1, z_l);
        vec3 l_dir = l_pos - p;
        float d = length(l_dir);
        float atten = 1.2 / (1.0 + d * d * 0.15);
        total += COULEUR_LUMIERE * max(0.0, dot(n, l_dir / d)) * atten;
    }
    return total;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float z_c = iTime * VITESSE;
    vec3 ro = vec3(get_curve(z_c), 0.0, z_c);
    vec3 look = vec3(get_curve(z_c + 1.0), 0.0, z_c + 1.0);
    vec3 ww = normalize(look - ro), uu = normalize(cross(ww, vec3(0,1,0))), vv = normalize(cross(uu, ww));
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);
    
    vec3 glow = vec3(0.0);
    float t = 0.0, d;
    
    for(int i = 0; i < 90; i++) {
        vec3 p = ro + rd * t;
        d = map(p);

        vec3 p_g = p;
        p_g.x -= get_curve(p_g.z);
        p_g = abs(mod(p_g, 1.5) - 0.75); 
        float d_g = length(p_g - vec3(0.0, -0.3, 0.0)) - 0.01;
        glow += 0.005 / (abs(d_g) + 0.02) * vec3(0.2, 1.0, 0.5); 
        
        if(d < 0.001 || t > 30.0) break;
        t += d * 0.8;
    }
    
    vec3 col = glow; 
    
    if(t < 30.0) {
        vec3 p = ro + rd * t, n = normalize(vec3(map(p+vec3(0.001,0,0))-map(p-vec3(0.001,0,0)), map(p+vec3(0,0.001,0))-map(p-vec3(0,0.001,0)), map(p+vec3(0,0,0.001))-map(p-vec3(0,0,0.001))));
        bool eau = p.y < (NIVEAU_EAU + 0.05);
        vec3 p_rel = p; p_rel.x -= get_curve(p.z);
        
        if(length(p_rel.xy - vec2(-1.0, -0.4)) < 0.2 || length(p_rel.xy - vec2(1.0, 0.2)) < 0.1) {
            col += vec3(0.1) * get_lights(p, n, rd);
        } else if(!eau) {
            // "6/2PI" correction applied here
            col += vec3(0.4, 0.3, 0.2) * texture_briques(vec2(atan(p_rel.y, p_rel.x) * 6.0 / TAU, p.z)) * get_lights(p, n, rd);
        } else {
            float fres = pow(1.0 + dot(rd, n), 4.0);
            // Correction applied to refraction/reflection mapping as well
            vec3 refr = texture_briques(vec2(atan(p_rel.y, p_rel.x) * 6.0 / TAU, p.z + 0.2)) * COULEUR_EAU_BLEUE * 0.2;
            col += mix(refr, vec3(0.5, 0.7, 1.0) * 0.3, clamp(fres, 0.1, 0.8)) * get_lights(p, n, rd);
        }
        col *= exp(-0.07 * t);
    }
    
    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}
