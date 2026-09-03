// ==== Image (image) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

void mainImage(out vec4 couleur_fragment, in vec2 coordonnees_pixel) {
    vec2 uv = coordonnees_pixel / iResolution.xy;
    vec2 uv_centre = uv - 0.5;
    
    float distorsion = dot(uv_centre, uv_centre);
    vec2 uv_rouge = uv + uv_centre * distorsion * 0.04;
    vec2 uv_vert = uv + uv_centre * distorsion * 0.02;
    vec2 uv_bleu = uv;
    
    vec3 scene_principale;
    scene_principale.r = texture(iChannel0, uv_rouge).r;
    scene_principale.g = texture(iChannel0, uv_vert).g;
    scene_principale.b = texture(iChannel0, uv_bleu).b;
    
    vec3 accumulation_lueur = vec3(0.0);
    float diviseur_poids = 0.0;
    float taille_dispersion = 6.0;
    
    for(float axe_x = -taille_dispersion; axe_x <= taille_dispersion; axe_x++) {
        for(float axe_y = -taille_dispersion; axe_y <= taille_dispersion; axe_y++) {
            vec2 decalage_pixel = vec2(axe_x, axe_y) / iResolution.xy * 3.0;
            float poids_gaussien = exp(-(axe_x * axe_x + axe_y * axe_y) / 16.0);
            
            vec3 echantillon = texture(iChannel0, uv + decalage_pixel).rgb;
            float luminosite = dot(echantillon, vec3(0.299, 0.587, 0.114));
            
            vec3 echantillon_isole = echantillon * smoothstep(0.5, 0.9, luminosite);
            
            accumulation_lueur += echantillon_isole * poids_gaussien;
            diviseur_poids += poids_gaussien;
        }
    }
    
    accumulation_lueur /= diviseur_poids;
    
    vec3 image_finale = scene_principale + accumulation_lueur * 2.2;
    
    image_finale = vec3(1.0) - exp(-image_finale * 1.5);
    image_finale = pow(image_finale, vec3(1.0 / 2.2));
    
    float vignettage = 1.0 - dot(uv_centre, uv_centre) * 1.3;
    image_finale *= clamp(vignettage, 0.0, 1.0);
    
    couleur_fragment = vec4(image_finale, 1.0);
}

// ==== Common (common) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

#define MAXIMUM_PAS 150
#define DISTANCE_LIMITE 50.0
#define PRECISION_SURFACE 0.001

mat2 matrice_rotation(float angle) {
    float sinus = sin(angle);
    float cosinus = cos(angle);
    return mat2(cosinus, -sinus, sinus, cosinus);
}

vec2 chemin_camera(float profondeur) {
    return vec2(
        sin(profondeur * 0.15) * 2.5 + cos(profondeur * 0.05) * 1.2,
        cos(profondeur * 0.12) * 2.0 + sin(profondeur * 0.07) * 1.2
    );
}

float distance_cylindre(vec3 position, vec2 dimensions) {
    return length(position.xy) - dimensions.x;
}

vec2 structure_spaghetti(vec3 position) {
    vec3 position_deformee = position;
    
    position_deformee.xy -= chemin_camera(position_deformee.z);
    position_deformee.xy *= matrice_rotation(position_deformee.z * 0.2);
    
    vec2 index_domaine = floor(position_deformee.xy / 2.0);
    position_deformee.xy = mod(position_deformee.xy, 2.0) - 1.0;
    
    float distance_geometrie = distance_cylindre(position_deformee, vec2(0.12));
    float identifiant_couleur = fract(sin(dot(index_domaine, vec2(12.9898, 78.233))) * 43758.5453);
    
    return vec2(distance_geometrie, identifiant_couleur);
}

vec3 evaluer_normale(vec3 position) {
    vec2 decalage = vec2(0.001, 0.0);
    float distance_actuelle = structure_spaghetti(position).x;
    
    vec3 gradient = vec3(
        distance_actuelle - structure_spaghetti(position - decalage.xyy).x,
        distance_actuelle - structure_spaghetti(position - decalage.yxy).x,
        distance_actuelle - structure_spaghetti(position - decalage.yyx).x
    );
    
    return normalize(gradient);
}

float calculer_occlusion(vec3 position, vec3 normale) {
    float occlusion = 0.0;
    float echelle = 1.0;
    for(int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = structure_spaghetti(position + h * normale).x;
        occlusion += (h - d) * echelle;
        echelle *= 0.95;
    }
    return clamp(1.0 - 1.5 * occlusion, 0.0, 1.0);
}

// ==== Buffer A (buffer) ====
// --------------------------
// Credits: Patrick JAILLET      
// -------------------------- 
// https://kymatix.netlify.app  
// https://openshader.xo.je     
// --------------------------

vec3 calculer_rendu(vec2 coordonnees_pixel, vec2 decalage_aa) {
    vec2 uv = (coordonnees_pixel + decalage_aa - 0.5 * iResolution.xy) / iResolution.y;
    
    float temps = iTime * 6.0;
    vec3 origine_camera = vec3(0.0, 0.0, temps);
    origine_camera.xy = chemin_camera(origine_camera.z);
    
    vec3 cible_camera = vec3(0.0, 0.0, temps + 2.0);
    cible_camera.xy = chemin_camera(cible_camera.z);
    
    vec3 direction_avant = normalize(cible_camera - origine_camera);
    vec3 direction_droite = normalize(cross(vec3(0.0, 1.0, 0.0), direction_avant));
    vec3 direction_haut = cross(direction_avant, direction_droite);
    
    vec3 direction_rayon = normalize(direction_droite * uv.x + direction_haut * uv.y + direction_avant * 0.8);
    direction_rayon.xy *= matrice_rotation(iTime * 0.1);
    
    float profondeur_totale = 0.0;
    vec2 donnees_surface;
    vec3 position_rayon;
    
    for(int iteration = 0; iteration < MAXIMUM_PAS; iteration++) {
        position_rayon = origine_camera + direction_rayon * profondeur_totale;
        donnees_surface = structure_spaghetti(position_rayon);
        
        if(donnees_surface.x < PRECISION_SURFACE || profondeur_totale > DISTANCE_LIMITE) break;
        profondeur_totale += donnees_surface.x;
    }
    
    vec3 couleur_rendu = vec3(0.0);
    
    if(profondeur_totale < DISTANCE_LIMITE) {
        vec3 normale_surface = evaluer_normale(position_rayon);
        float occlusion_ambiante = calculer_occlusion(position_rayon, normale_surface);
        
        vec3 palette_base = 0.5 + 0.4 * cos(iTime * 0.2 + donnees_surface.y * 6.28 + vec3(0.0, 0.8, 1.6));
        
        vec3 source_lumiere = normalize(vec3(sin(iTime), 1.0, cos(iTime)));
        float eclairage_diffus = max(dot(normale_surface, source_lumiere), 0.0);
        
        float fresnel = pow(1.0 - max(dot(normale_surface, -direction_rayon), 0.0), 5.0);
        
        vec3 direction_reflexion = reflect(direction_rayon, normale_surface);
        float profondeur_reflexion = 0.05;
        vec3 position_reflexion;
        float intensite_reflexion = 0.0;
        vec3 couleur_environnement = vec3(0.0);
        
        for(int etape_reflexion = 0; etape_reflexion < 40; etape_reflexion++) {
            position_reflexion = position_rayon + direction_reflexion * profondeur_reflexion;
            vec2 distance_reflexion = structure_spaghetti(position_reflexion);
            
            if(distance_reflexion.x < PRECISION_SURFACE) {
                intensite_reflexion = 1.0 - (profondeur_reflexion / 15.0);
                couleur_environnement = 0.5 + 0.4 * cos(iTime * 0.2 + distance_reflexion.y * 6.28 + vec3(0.0, 0.8, 1.6));
                break;
            }
            if(profondeur_reflexion > 15.0) break;
            profondeur_reflexion += distance_reflexion.x;
        }
        
        intensite_reflexion = clamp(intensite_reflexion, 0.0, 1.0);
        
        vec3 couleur_metal = mix(palette_base, vec3(1.0), 0.6);
        vec3 couleur_reflexion = couleur_environnement * intensite_reflexion * couleur_metal * (0.4 + 0.6 * fresnel);
        vec3 couleur_speculaire = vec3(pow(max(dot(reflect(-source_lumiere, normale_surface), -direction_rayon), 0.0), 64.0));
        
        couleur_rendu = (palette_base * eclairage_diffus * 0.05 * occlusion_ambiante) + couleur_reflexion + (couleur_speculaire * 2.0 * occlusion_ambiante);
        
        float attenuation_brouillard = exp(-0.04 * profondeur_totale);
        couleur_rendu = mix(vec3(0.0), couleur_rendu, attenuation_brouillard);
    }
    
    return couleur_rendu;
}

void mainImage(out vec4 couleur_fragment, in vec2 coordonnees_pixel) {
    vec3 accumulation_couleur = vec3(0.0);
    
    accumulation_couleur += calculer_rendu(coordonnees_pixel, vec2(0.25, 0.25));
    accumulation_couleur += calculer_rendu(coordonnees_pixel, vec2(0.75, 0.25));
    accumulation_couleur += calculer_rendu(coordonnees_pixel, vec2(0.25, 0.75));
    accumulation_couleur += calculer_rendu(coordonnees_pixel, vec2(0.75, 0.75));
    
    accumulation_couleur /= 4.0;
    
    couleur_fragment = vec4(accumulation_couleur, 1.0);
}
