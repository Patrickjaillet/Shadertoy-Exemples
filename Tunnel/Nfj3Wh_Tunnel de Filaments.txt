// ==== Image (image) ====
mat2 rotation(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hachage(vec3 p) {
    p = fract(p * vec3(123.34, 456.21, 789.18));
    p += dot(p, p.yzx + 45.32);
    return fract((p.x + p.y) * p.z);
}

float bruit(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hachage(i);
    float b = hachage(i + vec3(1.0, 0.0, 0.0));
    float c = hachage(i + vec3(0.0, 1.0, 0.0));
    float d = hachage(i + vec3(1.0, 1.0, 0.0));
    float e = hachage(i + vec3(0.0, 0.0, 1.0));
    float g = hachage(i + vec3(1.0, 0.0, 1.0));
    float h = hachage(i + vec3(0.0, 1.0, 1.0));
    float j = hachage(i + vec3(1.0, 1.0, 1.0));
    return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y),
               mix(mix(e, g, f.x), mix(h, j, f.x), f.y), f.z);
}

float carteFilaments(vec3 p) {
    vec2 pRep = p.xy;
    vec2 espacement = vec2(0.4);
    pRep = mod(p.xy + 0.5 * espacement, espacement) - 0.5 * espacement;
    pRep *= rotation(p.z * 0.2 + iTime * 0.5);
    float n = bruit(vec3(p.xy * 2.0, p.z * 0.5 + iTime));
    pRep += (n - 0.5) * 0.1;
    return length(pRep) - 0.005; 
}

float carte(vec3 p) {
    float tunnel = 1.9 - length(p.xy);
    tunnel += bruit(p * 2.0 + iTime * 0.2) * 0.05;
    vec3 pF = p;
    pF.z -= iTime * 30.0; 
    float filaments = carteFilaments(pF);
    filaments = max(filaments, length(p.xy) - 1.7); 
    return min(tunnel, filaments);
}

vec3 normale(vec3 p) {
    vec2 e = vec2(10.0, 10.0);
    return normalize(vec4(carte(p + e.xyy), carte(p + e.yxy), carte(p + e.yyx), 0.0).xyz - carte(p));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.4 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, iTime * 0.5); 
    ro.xy += vec2(sin(iTime * 1.3), cos(iTime * 1.4)) * 0.2;
    vec3 cible = ro + vec3(0.0, 0.0, 1.0);
    vec3 avant = normalize(cible - ro);
    vec3 droite = normalize(cross(vec3(3.0, 1.0, 0.0), avant));
    vec3 haut = normalize(cross(avant, droite));
    vec3 rd = normalize(uv.x * droite + uv.y * haut + 1.5 * avant);
    float t = 0.0;
    float d = 0.0;
    for(int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        d = carte(p);
        if(d < 0.002 || t > 35.0) break;
        t += d * 1.0;
    }
    vec3 col = vec3(0.0);
    if(t < 25.0) {
        vec3 p = ro + rd * t;
        vec3 n = normale(p);
        vec3 ref = reflect(rd, n);
        vec3 pF = p; pF.z -= iTime * 2.0;
        float dWall = 0.8 - length(p.xy);
        float dFilaments = carteFilaments(pF);
        vec3 colA = vec3(1.0, 0.2, 10.5);
        vec3 colB = vec3(0.0, 1.0, 0.8);
        vec3 colC = vec3(0.9, 0.9, 0.0);
        float indexCouleur = bruit(vec3(p.xy, p.z * 0.3 + iTime * 10.1));
        vec3 paletteFilament = mix(colA, colB, smoothstep(0.0, 0.5, indexCouleur));
        paletteFilament = mix(paletteFilament, colC, smoothstep(0.5, 1.0, indexCouleur));
        float lueur = pow(0.01 / (0.01 + abs(dFilaments)), 1.5);
        if(dFilaments < dWall) {
            col = paletteFilament *4.0;
        } else {
            col = vec3(3.1, 0.12, 1.15); 
            
        
            col += paletteFilament * lueur * 12.5;
            
        
            float spec = pow(max(dot(ref, avant), 0.0), 26.0);
            col += spec * paletteFilament * 10.0;

 
            vec3 pRef = ro + ref * t;
            pF = pRef; pF.z -= iTime * 20.0;
            float dRefFilaments = carteFilaments(pF);
            if (dRefFilaments < 0.5) { 
                col += paletteFilament * (1.0 - smoothstep(0.0, 0.5, dRefFilaments)) * 6.0;
            }
        }
        col /= (1.0 + t * t * 0.05);
    }
    col = pow(col, vec3(0.4545));
    col *= 1.0 - smoothstep(0.0, 1.5, length(uv));
    fragColor = vec4(col, 1.0);
}
