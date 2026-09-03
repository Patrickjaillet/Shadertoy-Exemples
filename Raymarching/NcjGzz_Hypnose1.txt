// ==== Image (image) ====
precision highp float;

mat2 rotation(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float fusion_douce(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

float eponge_folle(vec3 p, float morph) {
    p.xy *= rotation(morph * 1.5);
    p.yz *= rotation(morph * 0.7);
    
    float d = max(abs(p.x), max(abs(p.y), abs(p.z))) - 1.0;
    float s = 1.0;
    
    for(int i = 0; i < 4; i++) {
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= (2.2 + 1.8 * sin(morph * 0.5 + float(i)));
        
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        
        float c = (min(da, min(db, dc)) - 1.0 + 0.3 * sin(morph * 2.0)) / s;
        d = max(d, c);
        
        p.xz *= rotation(0.5 * morph);
    }
    return d;
}

float carte(vec3 p) {
    float temps_morph = iTime * 0.4;
    float d1 = eponge_folle(p, temps_morph);
    
    vec3 p_sph = p;
    p_sph.xz *= rotation(iTime);
    float d2 = length(p_sph) - (1.3 + 0.6 * sin(temps_morph * 1.3));
    
    float distortion = sin(p.x * 3.0 + iTime) * sin(p.y * 3.0 + iTime) * 0.1;
    return fusion_douce(d1, d2, 0.15) + distortion;
}

vec4 trajectoire_4D(int i) {
    i = i % 12;
    float angle = float(i) * 0.5235;
    return vec4(
        sin(angle * 2.0) * 4.5, 
        cos(angle * 1.5) * 3.5, 
        sin(angle + iTime * 0.2) * 4.0, 
        cos(angle * 0.9) * 2.0
    );
}

vec4 calculer_morphing(float t) {
    float v = t * 0.5;
    int i = int(floor(v));
    float f = fract(v);
    vec4 p0 = trajectoire_4D(i - 1), p1 = trajectoire_4D(i), p2 = trajectoire_4D(i + 1), p3 = trajectoire_4D(i + 2);
    return 0.5 * ((2.0 * p1) + (-p0 + p2) * f + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * f * f + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * f * f * f);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec2 uv_psy = uv * 3.0;
    float motif = sin(uv_psy.x + iTime) + cos(uv_psy.y + iTime);
    vec3 fond = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4) + motif);
    fond *= 0.3 + 0.7 * sin(length(uv) * 8.0 - iTime * 4.0);
    
    vec4 m4 = calculer_morphing(iTime);
    vec3 oeil = m4.xyz;
    oeil = normalize(oeil) * (3.5 + 1.5 * sin(iTime * 0.25));
    
    vec3 cible = vec3(0.0);
    vec3 axe_z = normalize(cible - oeil);
    vec3 axe_x = normalize(cross(axe_z, vec3(sin(iTime * 0.1), 1, 0)));
    vec3 axe_y = cross(axe_x, axe_z);
    vec3 rayon = normalize(uv.x * axe_x + uv.y * axe_y + (1.2 + 0.4 * sin(iTime * 0.5)) * axe_z);
    
    float dist = 0.0;
    float d_prec = 0.0;
    for(int i = 0; i < 96; i++) {
        d_prec = carte(oeil + rayon * dist);
        if(d_prec < 0.0004 || dist > 18.0) break;
        dist += d_prec;
    }
    
    vec3 couleur = fond * 0.35;
    if(dist < 18.0) {
        vec3 p = oeil + rayon * dist;
        vec2 e = vec2(0.001, 0);
        vec3 normale = normalize(vec3(carte(p+e.xyy)-carte(p-e.xyy), carte(p+e.yxy)-carte(p-e.yxy), carte(p+e.yyx)-carte(p-e.yyx)));
        
        float eclairage = max(dot(normale, normalize(vec3(1, 2, 3))), 0.0);
        float brillance = pow(max(dot(reflect(rayon, normale), normalize(vec3(1, 2, 3))), 0.0), 40.0);
        
        vec3 couleur_obj = 0.5 + 0.5 * cos(iTime + p.yxy + vec3(0, 2, 4));
        couleur_obj.xy *= rotation(iTime * 0.5);
        
        couleur = couleur_obj * eclairage + brillance;
        couleur = mix(couleur, fond, 1.0 - exp(-0.04 * dist * dist));
    }
    
    fragColor = vec4(pow(couleur, vec3(0.4545)), 1.0);
}
