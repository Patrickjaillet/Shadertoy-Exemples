// ==== Image (image) ====
// https://github.com/Patrickjaillet/Z-GL

mat2 rotation(in float angle)
{
    float c = cos(angle), s = sin(angle);
    return mat2(c, s, -s, c);
}

const mat3 matrice_bruit = mat3(0.33338, 0.56034, -0.71817, -0.87887, 0.32651, -0.15323, 0.15162, 0.69596, 0.61339) * 1.93;

float magnitude2(vec2 p)
{
    return dot(p, p);
}

float interpolation_lineaire(in float min_val, in float max_val, in float x)
{
    return clamp((x - min_val) / (max_val - min_val), 0., 1.);
}

float parametre_global = 0.;

vec2 deplacement(float t)
{
    return vec2(sin(t * 0.22), cos(t * 0.175)) * 2.;
}

vec2 carte(vec3 p)
{
    vec3 p2 = p;
    p2.xy -= deplacement(p.z).xy;
    p.xy *= rotation(sin(p.z + iTime) * (0.1 + parametre_global * 0.05) + iTime * 0.09);
    float cylindre = magnitude2(p2.xy);
    float distance_accumulee = 0.;
    p *= .61;
    float amplitude_fractale = 1.;
    float frequence = 1.2;
    float amplitude_distorsion = 0.2 + parametre_global * 0.1;
    
    for(int i = 0; i < 10; i++)
    {
        p += sin(p.zxy * 0.75 * frequence + iTime * frequence * 1.5) * amplitude_distorsion;
        distance_accumulee -= abs(dot(cos(p), sin(p.yzx)) * amplitude_fractale);
        amplitude_fractale *= 0.55;
        frequence *= 1.35;
        p = p * matrice_bruit;
    }
    
    distance_accumulee = abs(distance_accumulee + parametre_global * 2.5) + parametre_global * .2 - 2.2;
    return vec2(distance_accumulee + cylindre * 0.15 + 0.18, cylindre);
}

vec3 couleur_feu(float densite)
{
    vec3 col = mix(vec3(1.0, 0.1, 0.01), vec3(1.2, 0.5, 0.1), densite);
    col = mix(col, vec3(1.5, 1.3, 0.9), pow(densite, 2.5));
    return col;
}

vec4 rendu(in vec3 origine_rayon, in vec3 direction_rayon, float temps)
{
    vec4 resultat = vec4(0);
    float distance_marche = 1.2;
    float brouillard_precedent = 0.;
    
    for(int i = 0; i < 30; i++)
    {
        if(resultat.a > 0.98) break;

        vec3 position_actuelle = origine_rayon + distance_marche * direction_rayon;
        vec2 donnees_carte = carte(position_actuelle);
        
        float densite = clamp(donnees_carte.x - 0.25, 0., 1.) * 1.4;
        float lissage_distance = clamp((donnees_carte.x + 1.8), 0., 3.);
        
        if (donnees_carte.x > 0.5)
        {
            float chaleur = densite * interpolation_lineaire(4.5, -1.0, donnees_carte.x);
            float diffusion = clamp((densite - carte(position_actuelle + 0.4).x) / 4.0, 0.01, 1.0);
            
            vec3 feu = couleur_feu(chaleur);
            feu *= (0.5 + 2.0 * diffusion);
            
            vec4 couleur_pas = vec4(feu, chaleur * 0.6);
            couleur_pas.rgb *= couleur_pas.a;
            resultat = resultat + couleur_pas * (1. - resultat.a);
        }
        
        float coefficient_brouillard = exp(distance_marche * 0.18 - 2.8);
        resultat.rgb += vec3(0.2, 0.02, 0.0) * clamp(coefficient_brouillard - brouillard_precedent, 0., 1.) * 0.3;
        brouillard_precedent = coefficient_brouillard;
        
        distance_marche += clamp(0.45 - lissage_distance * lissage_distance * 0.04, 0.08, 0.25);
    }
    return clamp(resultat, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{	
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    
    float temps = iTime * 2.8;
    vec3 origine_camera = vec3(0, 0, temps);
    origine_camera += vec3(sin(iTime * 0.8) * 0.4, cos(iTime * 0.4) * 0.2, 0);
        
    float amplitude_deplacement = 0.85;
    origine_camera.xy += deplacement(origine_camera.z) * amplitude_deplacement;
    
    vec3 cible_regard = origine_camera - vec3(deplacement(temps + 4.0) * amplitude_deplacement, temps + 4.0);
    float oscillation_angle = sin(iTime * 0.5) * 3.14159265;
    cible_regard.xz *= rotation(oscillation_angle);
    
    vec3 avant = normalize(cible_regard);
    vec3 droite = normalize(cross(avant, vec3(0, 1, 0)));
    vec3 haut = normalize(cross(droite, avant));
    vec3 direction_rayon = normalize((p.x * droite + p.y * haut) * 1.15 - avant);
    
    direction_rayon.xy *= rotation(-deplacement(temps + 3.5).x * 0.15);
    parametre_global = smoothstep(-0.4, 0.4, sin(iTime * 0.2));
    
    vec4 scene = rendu(origine_camera, direction_rayon, temps);
    vec3 couleur_finale = scene.rgb;
    
    couleur_finale = 1.0 - exp(-couleur_finale * 1.8);
    couleur_finale = pow(couleur_finale, vec3(0.7, 0.8, 1.0));
    
    couleur_finale *= pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.15) * 0.8 + 0.2;
    
    fragColor = vec4(couleur_finale, 1.0);
}
