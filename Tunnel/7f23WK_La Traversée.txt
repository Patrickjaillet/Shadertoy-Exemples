// ==== Image (image) ====
#define LOIN 60.0
#define PI 3.14159265

float hachage(float n) { 
    return fract(cos(n) * 114514.1919); 
}

mat2 rotation2(float a) {
    vec2 v = sin(vec2(1.570796, 0.0) + a);
    return mat2(v, -v.y, v.x);
}

float bruit(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = smoothstep(0.0, 1.0, fract(x));
    float n = p.x + p.y * 10.0 + p.z * 100.0;
    return mix(mix(mix(hachage(n), hachage(n + 1.0), f.x), mix(hachage(n + 10.0), hachage(n + 11.0), f.x), f.y),
               mix(mix(hachage(n + 100.0), hachage(n + 101.0), f.x), mix(hachage(n + 110.0), hachage(n + 111.0), f.x), f.y), f.z);
}

mat3 matrice = mat3(0.00, 1.60, 1.20, -1.60, 0.72, -0.96, -1.20, -0.96, 1.28);

float mbf(vec3 p) {
    float f = 0.5000 * bruit(p); p = matrice * p;
    f += 0.2500 * bruit(p); p = matrice * p;
    f += 0.1666 * bruit(p); p = matrice * p;
    f += 0.0834 * bruit(p);
    return f;
}

vec2 chemin(float z) {
    float a = sin(z * 0.11);
    float b = cos(z * 0.14);
    return vec2(a * 4.0 - b * 1.5, b * 1.7 + a * 1.5);
}

float geometrie(vec3 p) {
    p.xy -= chemin(p.z);
    float n = 5.0 - length(p.xy * vec2(1.0, 0.8));
    return min(p.y + 3.0, n);
}

vec3 tracageVoxel(vec3 origine, vec3 direction, out vec3 masque, out float t) {
    vec3 p = floor(origine);
    vec3 dirSecurisee = direction + step(abs(direction), vec3(1e-8)) * 1e-8;
    vec3 dirInverse = 1.0 / dirSecurisee;
    vec3 dirPas = sign(dirSecurisee);
    vec3 deltaT = dirInverse * dirPas;
    vec3 maxT = (p - origine + 0.5 + 0.5 * dirPas) * dirInverse;
    
    masque = vec3(0.0);
    for(int i = 0; i < 64; i++) {
        if(geometrie(p + 0.5) < 0.0) break;
        masque = step(maxT.xyz, maxT.yzx) * step(maxT.xyz, maxT.zxy);
        maxT += masque * deltaT;
        p += masque * dirPas;
    }
    t = dot(masque, (p - origine + 0.5 - 0.5 * dirPas) * dirInverse);
    return p + 0.5;
}

float ombreVoxel(vec3 origine, vec3 direction, float fin) {
    vec3 p = floor(origine);
    vec3 dirSecurisee = direction + step(abs(direction), vec3(1e-8)) * 1e-8;
    vec3 dirInverse = 1.0 / dirSecurisee;
    vec3 dirPas = sign(dirSecurisee);
    vec3 deltaT = dirInverse * dirPas;
    vec3 maxT = (p - origine + 0.5 + 0.5 * dirPas) * dirInverse;
    
    vec3 masque = vec3(0.0);
    float d = 1.0;
    for(int i = 0; i < 16; i++) {
        d = geometrie(p + 0.5);
        if(d < 0.0) break;
        float tActuel = dot(masque, (p - origine + 0.5 - 0.5 * dirPas) * dirInverse);
        if(tActuel > fin) break;
        masque = step(maxT.xyz, maxT.yzx) * step(maxT.xyz, maxT.zxy);
        maxT += masque * deltaT;
        p += masque * dirPas;
    }
    return step(0.0, d) * 0.7 + 0.3;
}

vec4 oaVoxel(vec3 p, vec3 d1, vec3 d2) {
    vec4 cote = vec4(geometrie(p + d1), geometrie(p + d2), geometrie(p - d1), geometrie(p - d2));
    vec4 coin = vec4(geometrie(p + d1 + d2), geometrie(p - d1 + d2), geometrie(p - d1 - d2), geometrie(p + d1 - d2));
    cote = step(cote, vec4(0.0));
    coin = step(coin, vec4(0.0));
    return 1.0 - (cote + cote.yzwx + max(coin, cote * cote.yzwx)) / 3.0;
}

float calculerOAVoxel(vec3 posVoxel, vec3 posSurface, vec3 direction, vec3 masque) {
    vec4 oa = oaVoxel(posVoxel - sign(direction + 1e-8) * masque, masque.zxy, masque.yzx);
    posSurface = fract(posSurface);
    vec2 uv = posSurface.yz * masque.x + posSurface.zx * masque.y + posSurface.xy * masque.z;
    return mix(mix(oa.z, oa.w, uv.x), mix(oa.y, oa.x, uv.x), uv.y);
}

vec4 renduVolumetrique(vec3 origine, vec3 direction, float distanceMax, vec3 posLumiere) {
    vec4 somme = vec4(0.0);
    float t = 0.0;
    float dt = distanceMax / 24.0;
    for(int i = 0; i < 24; i++) {
        if(t > distanceMax || somme.a > 0.99) break;
        vec3 p = origine + direction * t;
        float densite = smoothstep(0.4, 1.0, mbf(p * 0.15));
        
        if(densite > 0.0) {
            vec3 dirLum = normalize(posLumiere - p);
            float distLum = length(posLumiere - p);
            
            float densiteLum = smoothstep(0.4, 1.0, mbf(p + dirLum * 0.8));
            float ombre = exp(-densiteLum * 3.0);
            float phase = pow(max(dot(direction, dirLum), 0.0), 2.0) * 0.6 + 0.4;
            float attenuation = 1.0 / (1.0 + distLum * distLum * 0.05);
            
            vec3 couleurDispersion = vec3(1.0, 0.85, 0.6) * attenuation * phase * ombre * 2.5;
            vec3 couleurAmbiante = mix(vec3(1.0, 0.95, 0.9), vec3(0.5, 0.6, 0.7), densite);
            
            vec3 couleur = couleurAmbiante + couleurDispersion;
            float alpha = densite * (1.0 - somme.a) * 0.4;
            somme += vec4(couleur * alpha, alpha);
        }
        t += dt;
    }
    return somme;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;

    vec3 origine = vec3(0.0, 0.5, iTime * 4.0);
    origine.xy += chemin(origine.z);
    vec3 cible = origine + vec3(0.0, 0.0, 1.0);
    cible.xy += chemin(cible.z);

    vec3 avant = normalize(cible - origine);
    vec3 droite = normalize(cross(avant, vec3(0.0, 1.0, 0.0)));
    vec3 haut = cross(droite, avant);
    vec3 direction = normalize(avant + (PI / 2.0) * uv.x * droite + (PI / 2.0) * uv.y * haut);

    direction.xy *= rotation2(chemin(cible.z).x / 24.0);

    vec3 masque;
    float t;
    vec3 posVoxel = tracageVoxel(origine, direction, masque, t);

    vec3 couleur = vec3(0.0);
    
    vec3 posLumiere = origine + vec3(0.0, 2.0, 5.0);
    posLumiere.xy += chemin(posLumiere.z);

    if(t < LOIN) {
        vec3 posSurface = origine + direction * t;
        vec3 normaleSurface = -(masque * sign(direction + 1e-8));

        vec3 dirLum = normalize(posLumiere - posSurface);
        float distLum = length(posLumiere - posSurface);

        float diffusion = max(dot(normaleSurface, dirLum), 0.0);
        float speculaire = pow(max(dot(reflect(-dirLum, normaleSurface), -direction), 0.0), 32.0);

        float oa = calculerOAVoxel(posVoxel, posSurface, direction, masque);
        float ombrage = ombreVoxel(posSurface + normaleSurface * 0.01, dirLum, distLum);
        float attenuation = 1.0 / (1.0 + distLum * 0.1);

        vec3 couleurTexture = vec3(0.9, 0.92, 0.95) * (0.8 + 0.2 * bruit(posSurface * 4.0));
        couleur = couleurTexture * (diffusion + 0.2) + vec3(1.0) * speculaire;
        couleur *= attenuation * ombrage * oa;
    }

    vec4 volume = renduVolumetrique(origine, direction, min(t, LOIN), posLumiere);
    couleur = mix(couleur, volume.rgb, volume.a);

    couleur = mix(couleur, vec3(0.7, 0.8, 0.9), smoothstep(0.0, 1.0, t / LOIN));

    fragColor = vec4(pow(clamp(couleur, 0.0, 1.0), vec3(0.4545)), 1.0);
}

//*====================================================================================*//
//                                                                                      //
//  _______ _______ _______ _______ _______ _______ _______ _____  _______ ______       //
// |   |   |    ___|_     _|   _   |     __|   |   |   _   |     \|    ___|   __ \      //
// |       |    ___| |   | |       |__     |       |       |  --  |    ___|      <      //
// |__|_|__|_______| |___| |___|___|_______|___|___|___|___|_____/|_______|___|__|      //
//                                                                                      //
//======================================================================================//
//:: [ GLSL / HLSL / WGSL / MSL / SPIR-V ] ::                                           //
//======================================================================================//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░▒░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒░░░░░░░░░░░░░░░░ ░░░▒░░░░░░░░░░░░░░░▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒░░░░░░░░░░░░░░░▒░░░░▒░░▒░░░░░░░░░▒▒░░░░░▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒░░░░░░░░░░░░░░░░░░░░▒▒▒░░▒▒▒░░▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░   ░░░░░░░░░▒▒▒░▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒░░░░░░░░░ ░▒▒▒▒▒░ ░░░░░░░▒░░░░▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ░ ▒░░░░░░░░░▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒░░░░░ ▒▒▓▒▓▒▒▒▒░░ ░░░░░░░▒▒░░░░░░░░░░░ ▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▓▓ ░░░ ▒▒▒▓▓▒▒░▓▒░░ ░░░░░░░▒▒▒▒░░░░░░░░░░░ ▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▓▒▒░░░▒▒▒▒▓▓▓░▓▓ ░░░░░░░░░▒▒▒▒▒▒░░░░░░░ ░░░░▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▓▒▓▓░▒▒▓▓▓▓▓▓░▓▓ ░ ░░░░░░▒▒▒▒▒▒▒▒░░░▒▒▒▒░░░░░▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▓▒▓▓▒▓▓▓▓▓▓▓▒▒▓▓ ░▒░░░░░░▒▒▒▒▒▒▒▒░▒▒▒▒▒░ ░░░░░▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▓░░░░▒░▓▓▓▓▓▓▓▓▒▒▒░░ ░░░░ ░▒▒▒▒▒▒▒▒░▓▒▒░░░▒▒▒▒▒░░▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▓▓▓▓▓▓▓▒░░▒▒▒▒▒▒░░▒▒▒░  ▒ ░▒▒▒▒▒▒░▒▒░ ▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░   ░▒▒▒▒▒▒▒▒▒▒▒▒░ ░░ ▒ ▒▒░ ░▒▒▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░    ░▒▒▒▒▒▒▒▒░ ░░░░░▒ ▒▒░░▒▒░░░  ▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░   ░░░░░░░░░░  ░░▒▒▒▒░░ ▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░ ░    ░░▒▒▒▒▒▒░▒░░░░▒▒▒▒▒  ░░▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░ ░░     ░░░░░░░░ ░▒▒▒░ ░▒░░░▒░░░ ▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░ ░▒▒▒▒▒▒░░░░░░░░░ ░░ ▒▒▒░░▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒░░░░  ░ ░ ░▒▒░░░░░░░░▒▒▒░░░ ▒▒▒▒▒▒▒▒//
//======================================================================================//
//:: [ CREDITS ] ::                                                                     //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
