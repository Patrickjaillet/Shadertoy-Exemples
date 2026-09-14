// ==== Image (image) ====
// ==========================================================
// NAME : SHINY VORTEX
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

#define PI 3.14159265
#define TAU 6.2831853

mat2 rot2(float a){ float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

float hash21(vec2 p){
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec3 p){
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f*f*(3.0-2.0*f);
    float n = dot(i, vec3(1.0, 57.0, 113.0));
    return mix(mix(mix(hash21(vec2(n+0.0,0)), hash21(vec2(n+1.0,0)), f.x),
                   mix(hash21(vec2(n+57.0,0)), hash21(vec2(n+58.0,0)), f.x), f.y),
               mix(mix(hash21(vec2(n+113.0,0)), hash21(vec2(n+114.0,0)), f.x),
                   mix(hash21(vec2(n+170.0,0)), hash21(vec2(n+171.0,0)), f.x), f.y), f.z);
}

float sdBox(vec2 p, float b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    vec2 iR = iResolution.xy;
    vec2 uv = (fragCoord - iR * 0.5) / iR.y;

    // --- FOND ÉTOILÉ EN SENS INVERSE (Anti-horaire) ---
    // On utilise un signe positif pour iTime dans la rotation inverse
    vec2 starUV = uv * rot2(iTime * 0.15); 
    float stars = pow(hash21(starUV * 450.0), 130.0) * 1.8;
    vec3 col = vec3(stars * 0.4, stars * 0.6, stars * 1.0);

    float r = length(uv);
    float a = atan(uv.y, uv.x);

    // Paramètres pour le vortex sans coupure
    float repeatA = 12.0; // Nombre de divisions angulaires
    float spiralA = (a / TAU) * repeatA; 
    float logR = log(max(r, 0.001)) * 2.5;

    // Coordonnées de la grille (st.x = profondeur, st.y = angle spiralé)
    vec2 st = vec2(logR - iTime * 0.8, spiralA + logR * 0.4);
    vec2 id = floor(st);
    vec2 f = fract(st) - 0.5;

    vec3 accumulation = vec3(0);

    // Rendu des cellules voisines pour le bloom et les débordements
    for(float y=-1.0; y<=1.0; y++) {
        for(float x=-1.0; x<=1.0; x++) {
            vec2 nId = id + vec2(x, y);
            
            // On rend l'ID périodique sur l'angle pour éviter la coupure à gauche
            vec2 correctId = nId;
            correctId.y = mod(nId.y, repeatA); 
            
            vec2 nF = f - vec2(x, y);
            
            float h = hash21(correctId);
            if(h < 0.28) continue; 
            
            // Couleur Albedo
            vec3 albedo = 0.5 + 0.5 * cos(h * 10.0 + iTime * 0.6 + vec3(0, 1.5, 3.0));
            float size = 0.18 * smoothstep(0.0, 0.45, r);
            float d = sdBox(nF, size);
            
            // --- NORMALE SIMULÉE POUR LE BRILLANT (PBR) ---
            vec2 eps = vec2(0.01, 0.0);
            vec3 normal = normalize(vec3(
                sdBox(nF + eps.xy, size) - sdBox(nF - eps.xy, size),
                sdBox(nF + eps.yx, size) - sdBox(nF - eps.yx, size),
                0.25 // Profondeur apparente
            ));
            
            // Éclairage spéculaire (Brillance)
            vec3 lightDir = normalize(vec3(sin(iTime), cos(iTime * 0.5), 1.0));
            float spec = pow(max(dot(normal, normalize(lightDir + vec3(0,0,1))), 0.0), 50.0);
            float diff = max(dot(normal, lightDir), 0.0);
            
            // Texture marbrée
            float t = noise(vec3(nF * 12.0, iTime * 0.2 + h * 4.0));
            
            // Accumulation de la lumière (Masque interne + Glow externe)
            float glow = exp(-max(d, 0.0) * 22.0);
            float mask = smoothstep(0.01, -0.01, d);
            vec3 cubeCol = albedo * (diff + 0.3) + spec * 1.2 + (albedo * t * 0.4);
            
            accumulation += (cubeCol * mask + albedo * glow * 0.7) * (0.7 + h * 0.5);
        }
    }

    col += accumulation;
    
    // Assombrissement progressif vers le centre du vortex
    col *= smoothstep(0.0, 0.35, r);
    
    // Tonemapping et correction gamma
    col = col / (1.25 + col * 0.4);
    fragColor = vec4(pow(max(col, 0.0), vec3(0.4545)), 1.0);
}
