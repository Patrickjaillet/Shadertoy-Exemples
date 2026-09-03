// ==== Image (image) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Kymatix VJ : https://kymatix.netlify.app
float bruit2(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3. - 2. * f);
    float a = fract(sin(dot(i, vec2(12.9898, 78.233))) * 43758.5453),
          b = fract(sin(dot(i + vec2(1, 0), vec2(12.9898, 78.233))) * 43758.5453),
          c = fract(sin(dot(i + vec2(0, 1), vec2(12.9898, 78.233))) * 43758.5453),
          d = fract(sin(dot(i + vec2(1, 1), vec2(12.9898, 78.233))) * 43758.5453);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm2(vec2 p, int oct) {
    float v = 0., a = .5, f = 1.;
    for(int i = 0; i < 6; i++) {
        if(i >= oct) break;
        v += a * bruit2(p * f);
        a *= .5; f *= 2.1;
    }
    return v;
}

float sdTerrain(vec3 p) {
    float dunes = fbm2(p.xz * 0.05, 4) * 6.0;
    float roche = fbm2(p.xz * 0.2, 6) * 1.5;
    return p.y - (dunes + roche);
}

vec3 couleurCiel(vec3 rd) {
    float gradient = clamp(rd.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 horizon = vec3(0.8, 0.5, 0.4);
    vec3 zenith = vec3(0.4, 0.2, 0.2);
    return mix(horizon, zenith, pow(gradient, 0.8));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float t_mouv = iTime * 0.3;
    float avancement = iTime * 10.0;
    
    vec3 ro = vec3(10.0 * sin(t_mouv), 8.0 + 2.0 * cos(t_mouv * 1.2), avancement);
    vec3 cible = vec3(15.0 * sin(t_mouv + 0.4), 6.0 + 2.0 * sin(t_mouv * 0.7), avancement + 20.0);
    
    float roulis = 0.15 * sin(t_mouv * 0.5);
    vec3 cw = normalize(cible - ro);
    vec3 cp = vec3(sin(roulis), cos(roulis), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(cu * uv.x + cv * uv.y + cw * 1.2);

    vec3 col = couleurCiel(rd);
    float dist = 0.0;
    
    for(int i = 0; i < 120; i++) {
        vec3 p = ro + rd * dist;
        float d = sdTerrain(p);
        if(d < 0.01 || dist > 110.0) break;
        dist += d * 0.6;
    }

    if(dist < 110.0) {
        vec3 p = ro + rd * dist;
        vec2 e = vec2(0.03, 0.0);
        vec3 n = normalize(vec3(
            sdTerrain(p + e.xyy) - sdTerrain(p - e.xyy),
            0.3,
            sdTerrain(p + e.yyx) - sdTerrain(p - e.yyx)
        ));
        
        vec3 lum = normalize(vec3(0.8, 0.6, 0.3));
        float diff = max(dot(n, lum), 0.0);
        float ombre = smoothstep(0.0, 0.4, n.y);
        
        vec3 sable = vec3(0.6, 0.3, 0.1);
        vec3 roche = vec3(0.3, 0.15, 0.1);
        vec3 albedo = mix(roche, sable, ombre);
        albedo *= 0.8 + 0.2 * bruit2(p.xz * 0.5);
        
        col = albedo * (diff + 0.15);
        
        float brume = 1.0 - exp(-0.0004 * dist * dist);
        col = mix(col, couleurCiel(rd), brume);
    }

    col = pow(col, vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
