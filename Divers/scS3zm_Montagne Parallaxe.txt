// ==== Image (image) ====
// By Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Fix by FabriceNeyret2 - https://www.shadertoy.com/user/FabriceNeyret2
#define PI 3.14159265359
#define TEMPS iTime

float hachage21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float bruit21(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hachage21(i + vec2(0.0, 0.0)), hachage21(i + vec2(1.0, 0.0)), u.x),
               mix(hachage21(i + vec2(0.0, 1.0)), hachage21(i + vec2(1.0, 1.0)), u.x), u.y);
}

float obtenir_hauteur(float x, float graine, int type) {
    float h = 0.0;
    if (type == 0) {
        h = sin(x * 0.2 + graine) * 0.5 + sin(x * 0.5) * 0.2;
    } else if (type == 1) {
        h = abs(sin(x * 4.0 + graine)) * 0.3 + bruit21(vec2(x * 6.0, graine)) * 0.1;
    } else {
        h = sin(x * 1.5 + graine) * 0.05 + bruit21(vec2(x * 10.0, graine)) * 0.02;
    }
    return h;
}

vec3 calculer_pbr(vec3 normale, vec3 vue, vec3 lumiere, vec3 albedo, float rugosite, float metallique, vec3 eclat_lumiere) {
    vec3 mi_chemin = normalize(lumiere + vue);
    float n_dot_l = max(dot(normale, lumiere), 0.0);
    float n_dot_h = max(dot(normale, mi_chemin), 0.0);
    
    vec3 diffuse = albedo * n_dot_l;
    
    float spec = pow(n_dot_h, mix(100.0, 5.0, rugosite));
    vec3 speculaire = vec3(spec) * mix(vec3(0.04), albedo, metallique);
    
    return (diffuse + speculaire) * eclat_lumiere;
}

void mainImage(out vec4 couleur_fragment, in vec2 coord_fragment) {
    vec2 uv = (coord_fragment - 0.5 * iResolution.xy) / iResolution.y;
    float oscillation = sin(TEMPS * 0.2);
    
    vec3 pos_lumiere = vec3(sin(TEMPS * 0.5) * 0.5, 0.4, 0.5);
    vec3 couleur_soleil = vec3(1.0, 0.8, 0.5);
    
    vec3 ciel = mix(vec3(0.1, 0.2, 0.4), vec3(0.4, 0.6, 0.9), uv.y + 0.5);
    vec3 couleur_finale = ciel;
    vec3 accumulation_bloom = vec3(0.0);

    float lueur_soleil = pow(max(0.0, 1.0 - length(uv - pos_lumiere.xy) / 0.4), 4.0);
    accumulation_bloom += couleur_soleil * lueur_soleil * 1.5;

    for(int i = 1; i <= 30; i++) {
        float i_f = float(i);
        float p = i_f / 30.0;
        
        float vitesse = oscillation * pow(p, 2.5) * 12.0;
        int categorie = (i <= 10) ? 0 : (i <= 20) ? 1 : 2;
        
        float amp = (categorie == 0) ? 0.4 : (categorie == 1) ? 0.2 : 0.08;
        float y_off = 0.3 - (p * 0.9);
        
        float h = obtenir_hauteur(uv.x + vitesse, i_f * 5.0, categorie) * amp + y_off;
        
        if (uv.y < h) {
            float eps = 0.01;
            float h_gauche = obtenir_hauteur(uv.x - eps + vitesse, i_f * 5.0, categorie) * amp + y_off;
            float h_droite = obtenir_hauteur(uv.x + eps + vitesse, i_f * 5.0, categorie) * amp + y_off;
            vec3 n = normalize(vec3(h_gauche - h_droite, eps * 2.0, 0.2));
            
            vec3 albedo;
            float rugosite = 0.8;
            float metallique = 0.0;
            
            if (categorie == 0) albedo = vec3(0.4, 0.5, 0.7);
            else if (categorie == 1) albedo = vec3(0.2, 0.4, 0.1);
            else albedo = vec3(0.3, 0.2, 0.1);
            
            vec3 dir_lumiere = normalize(pos_lumiere - vec3(uv, 0.0));
            vec3 pbr = calculer_pbr(n, vec3(0, 0, 1), dir_lumiere, albedo, rugosite, metallique, couleur_soleil * 2.0);
            
            float brume = pow(1.0 - p, 3.0);
            pbr = mix(pbr, ciel, brume);
            

            // Fix by FabriceNeyret2 - https://www.shadertoy.com/user/FabriceNeyret2
            float pix = 1.5/iResolution.y, bord = smoothstep(0., pix, h - uv.y); 
            if( uv.y < h ) couleur_finale = mix(pbr, vec3(0), smoothstep(pix, 0., abs(h-pix - uv.y)));
            
            float intensite_bloom = max(0.0, dot(pbr, vec3(0.33)) - 0.7);
            accumulation_bloom += pbr * intensite_bloom * bord;
        }
    }

    vec3 resultat = couleur_finale + accumulation_bloom * 0.6;
    resultat = resultat / (resultat + vec3(1.0));
    resultat = pow(resultat, vec3(0.4545));
    
    couleur_fragment = vec4(resultat, 1.0);
}
