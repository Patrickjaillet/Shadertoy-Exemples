// ==== Image (image) ====
const int ETAPES_MARCHE = 64;
const float HAUTEUR_MER = 0.6;
const float CHOPI_MER = 4.0;
const float VITESSE_MER = 0.8;
const float FREQ_MER = 0.16;
const vec3 BASE_MER = vec3(0.0, 0.02, 0.05);
const vec3 COULEUR_EAU_MER = vec3(0.4, 0.5, 0.3) * 0.15;
const mat2 MAT_OCT = mat2(1.6, 1.2, -1.2, 1.6);

float hachage(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hachage(float n) {
    return fract(sin(n) * 43758.5453123);
}
// https://github.com/Patrickjaillet/Z-GL-Shadertoy
float bruit(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return -1.0 + 2.0 * mix(mix(hachage(i + vec2(0, 0)), hachage(i + vec2(1, 0)), u.x),
                         mix(hachage(i + vec2(0, 1)), hachage(i + vec2(1, 1)), u.x), u.y);
}

float vague_octave(vec2 uv, float choppy) {
    uv += bruit(uv);
    vec2 wv_raw = 1.0 - abs(sin(uv));
    vec2 swv = abs(cos(uv));
    vec2 wv = mix(wv_raw, swv, wv_raw);
    return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
}

float carte_mer(vec3 p, int iterations) {
    float freq = FREQ_MER;
    float amp_dyn = HAUTEUR_MER;
    float choppy = CHOPI_MER;
    vec2 uv_mer = p.xz; uv_mer.x *= 0.75;
    float h = 0.0;
    float t_mer = iTime * VITESSE_MER;
    for(int i = 0; i < iterations; i++) {
        float d = vague_octave((uv_mer + t_mer) * freq, choppy) + vague_octave((uv_mer - t_mer) * freq, choppy);
        h += d * amp_dyn;
        uv_mer *= MAT_OCT; freq *= 1.9; amp_dyn *= 0.22;
        choppy = mix(choppy, 1.0, 0.2);
    }
    return p.y - h;
}

float eclair_dynamique(vec2 uv, float graine, float echelle, float p_x_max) {
    float id_f = floor(iTime * 12.0 + graine);
    float f_chance = hachage(vec2(id_f, graine));
    if(f_chance < 0.94) return 0.0;
    float p_x = (hachage(vec2(id_f, 1.2)) - 0.5) * p_x_max;
    uv.x -= p_x;
    float distorsion = bruit(uv * 0.5 * echelle + iTime * 0.2 + graine) * 1.2 / echelle;
    float axe = abs(uv.x + distorsion + bruit(uv * 5.0 * echelle - iTime * 10.0) * 0.2 / echelle);
    float scintillement = hachage(iTime * 50.0 + graine);
    return (0.005 / axe + 0.0015 / pow(axe, 1.4)) * scintillement;
}

vec3 obtenir_ciel(vec3 dir, vec2 uv_ecran, float flash) {
    vec3 col = (vec3(0.002, 0.005, 0.01) + vec3(0.6, 0.7, 1.1) * flash * 0.5) * (2.2 - dir.y);
    vec2 uv_n = dir.xz / (max(dir.y, 0.001));
    float den = 0.0, a = 0.5;
    vec2 uv_v = uv_n * 0.1 + iTime * 0.01;
    for(int i=0; i<6; i++) { den += a * bruit(uv_v); uv_v *= MAT_OCT; a *= 0.5; }
    den = smoothstep(0.2, 0.9, den * smoothstep(0.0, 0.2, dir.y));
    col = mix(col, mix(vec3(0.005, 0.01, 0.02), vec3(0.6, 0.8, 1.2) * flash * 2.5, den * 0.6), den);
    
    vec2 uv_e = dir.xy / (max(dir.y, 0.01) + 0.08);
    col += eclair_dynamique(uv_e, 0.0, 1.0, 10.0) * vec3(0.75, 0.85, 1.1);
    
    float id_p = floor(iTime * 14.0 + 314.15);
    if(hachage(vec2(id_p, 314.15)) > 0.95) {
        float p_x_impact = (hachage(vec2(id_p, 1.2)) - 0.5) * 1.8;
        float disto = bruit(vec2(uv_ecran.y * 2.0, iTime)) * 0.15;
        float axe_p = abs(uv_ecran.x - p_x_impact + disto);
        float filament = (0.003 / axe_p + 0.001 / pow(axe_p, 1.4)) * hachage(iTime * 50.0);
        col += filament * vec3(0.8, 0.9, 1.2) * 5.0 * step(-0.1, dir.y);
    }
    return col;
}

vec3 normale_mer(vec3 p, float eps) {
    vec3 n;
    n.y = carte_mer(p, 10);
    n.x = carte_mer(vec3(p.x + eps, p.y, p.z), 10) - n.y;
    n.z = carte_mer(vec3(p.x, p.y, p.z + eps), 10) - n.y;
    n.y = eps;
    return normalize(n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    float flash_synchro = 0.0;
    for(int i = 0; i < 4; i++) {
        float id = floor(t * (13.0 + float(i)));
        flash_synchro = max(flash_synchro, step(0.93, hachage(vec2(id, float(i)))) * hachage(id + 1.1));
    }

    vec3 ori = vec3(0.0, 3.5, t * 5.0);
    vec3 dir = normalize(vec3(uv, -1.8));
    vec3 col = vec3(0.0);
    
    vec3 col_brume_fond = vec3(0.005, 0.008, 0.015) + flash_synchro * vec3(0.4, 0.5, 0.7) * 0.5;

    if(dir.y < -0.01) {
        float tm = 0.0, tx = 150.0;
        float hm = carte_mer(ori, 4), hx = carte_mer(ori + dir * tx, 4);
        vec3 p = ori;
        for(int i = 0; i < ETAPES_MARCHE; i++) {
            float tmid = mix(tm, tx, hm / (hm - hx));
            p = ori + dir * tmid;
            float hmid = carte_mer(p, 4);
            if(hmid < 0.0) { tx = tmid; hx = hmid; } else { tm = tmid; hm = hmid; }
        }
        
        vec3 n = normale_mer(p, 0.008);
        float fresnel = pow(clamp(1.0 - dot(n, -dir), 0.0, 1.0), 4.0) * 0.6;
        vec3 ref = obtenir_ciel(reflect(dir, n), uv, flash_synchro);
        vec3 refr = BASE_MER + pow(max(dot(n, vec3(0, 1, 0)), 0.0), 80.0) * COULEUR_EAU_MER;
        col = mix(refr, ref, fresnel);
        col += pow(max(dot(reflect(dir, n), normalize(vec3(0, 0.5, 1.0))), 0.0), 120.0) * flash_synchro * 2.0;
        
        float id_p = floor(t * 14.0 + 314.15);
        if(hachage(vec2(id_p, 314.15)) > 0.95) {
            float pos_x_impact = (hachage(vec2(id_p, 1.2)) - 0.5) * 1.8;
            float d_colonne = abs(uv.x - pos_x_impact);
            col += exp(-d_colonne * 4.0) * vec3(0.7, 0.85, 1.2) * 2.0 * hachage(t * 50.0);
        }
        
        float distance_p = length(p - ori);
        float brouillard = exp(-distance_p * 0.025);
        col = mix(col_brume_fond, col, brouillard);
    } else {
        col = obtenir_ciel(dir, uv, flash_synchro);
        float brouillard_ciel = smoothstep(0.0, 0.12, dir.y);
        col = mix(col_brume_fond, col, brouillard_ciel);
    }

    col = (col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14);
    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
//*====================================================================================*//
//                                                                                      //
//  _______ _______ _______ _______ _______ _______ _______ _____  _______ ______       //
// |   |   |    ___|_     _|   _   |     __|   |   |   _   |     \|    ___|   __ \      //
// |       |    ___| |   | |       |__     |       |       |  --  |    ___|      <      //
// |__|_|__|_______| |___| |___|___|_______|___|___|___|___|_____/|_______|___|__|      //
//                                                                                      //
//======================================================================================//
//:: [ Optimized for NVIDIA GeForce GT 1030 GDDR5 2Go ] ::                              //
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

float hachage(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hachage(vec2 p) {
    float h = dot(p, vec2(127.1, 311.7));	
    return fract(sin(h) * 43758.5453123);
}

float hachage3d(vec3 p) {
    p = fract(p * vec3(.1031, .1030, .0973));
    p += dot(p, p.zyx + 33.33);
    return fract((p.x + p.y) * p.z);
}

float bruit3d(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(hachage3d(i), hachage3d(i + vec3(1, 0, 0)), f.x),
                   mix(hachage3d(i + vec3(0, 1, 0)), hachage3d(i + vec3(1, 1, 0)), f.x), f.y),
               mix(mix(hachage3d(i + vec3(0, 0, 1)), hachage3d(i + vec3(1, 0, 1)), f.x),
                   mix(hachage3d(i + vec3(0, 1, 1)), hachage3d(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

float foudre_acoustique(float t, float t_impact, float force) {
    float dt = t - t_impact;
    if (dt < 0.0 || dt > 4.0) return 0.0;

    float env_claquement = exp(-dt * 35.0);
    float craquement = hachage(t * 44100.0) * env_claquement;

    float env_detonation = exp(-dt * 2.0) * smoothstep(0.0, 0.01, dt);
    float detonation = bruit3d(vec3(t * 110.0, 0.0, 0.0)) * env_detonation;

    float roulement = 0.0;
    for(float i = 1.0; i < 4.0; i++) {
        float f = 12.0 * i;
        float env_roule = exp(-dt * (0.25 * i)) * (0.4 / i);
        roulement += bruit3d(vec3(t * f, t * 1.5, i)) * env_roule * sin(dt * f);
    }
    
    return (craquement * 0.4 + detonation * 0.6 + roulement * 0.3) * force * smoothstep(4.0, 2.5, dt);
}

vec2 mainSound(int samp, float time) {
    float signal = 0.0;
    
    for (float i = 0.0; i < 60.0; i++) {
        float t_verif = time - i * 0.05;
        
        float id_g = floor(t_verif * 10.0);
        float flash_g = step(0.96, bruit3d(vec3(id_g, 0.0, 0.0))) * bruit3d(vec3(id_g, 0.5, 0.5));
        if(flash_g > 0.0) {
            float t_impact = id_g / 10.0;
            if(abs(t_verif - t_impact) < 0.02) {
                signal += foudre_acoustique(time, t_impact + 0.1, flash_g * 0.6);
            }
        }

        for(int j = 0; j < 3; j++) {
            float fi = float(j);
            float cadence = 12.0 + fi;
            float id_f = floor(t_verif * cadence);
            float f_indiv = step(0.94, hachage(vec2(id_f, fi))) * hachage(vec2(id_f, fi + 0.1));
            
            if(f_indiv > 0.0) {
                float t_impact = id_f / cadence;
                if(abs(t_verif - t_impact) < 0.02) {
                    signal += foudre_acoustique(time, t_impact + 0.05, f_indiv);
                }
            }
        }
    }
    
    signal = tanh(signal * 2.0);
    return vec2(signal) * 0.35;
}
