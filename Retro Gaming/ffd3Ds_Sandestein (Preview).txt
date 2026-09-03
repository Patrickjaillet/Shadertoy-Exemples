// ==== Image (image) ====
// Phase 1 : NUM_ENEMIES, MAX_RAY_STEPS, CHASE_RANGE, ATTACK_RANGE, hash() et mapId() sont désormais
// dans Common (partagés), la carte étant générée dans BufferA au lieu d'être codée en dur ici.
// iChannels de ce buffer :
//   iChannel0 = BufferB (état joueur + machine à états du jeu)
//   iChannel1 = BufferC (Phase 3 : état + FSM des ennemis, remplace l'ancienne lecture sur BufferB)
//   iChannel2 = BufferD (Phase 2 : props/décor, cf. 3.2.3)
//   iChannel3 = BufferA (carte générée, pour le raycast des murs — inchangé dans son rôle)
#define FOV 1.05

vec3 texBrick(vec2 uv) {
    vec2 brickUV = uv * vec2(8.0, 4.0);
    if (fract(brickUV.y * 0.5) > 0.5) brickUV.x += 0.5;
    vec2 f = fract(brickUV);
    vec2 mortar = step(vec2(0.05, 0.1), f) * step(f, vec2(0.95, 0.9));
    float m = mortar.x * mortar.y;
    float noise = hash(floor(brickUV)) * 0.15 + 0.85;
    vec3 brickColor = vec3(0.65, 0.15, 0.1) * noise;
    vec3 mortarColor = vec3(0.7);
    return mix(mortarColor, brickColor, m);
}

vec3 texMetal(vec2 uv) {
    vec2 f = fract(uv * 4.0);
    float rivets = length(abs(f - 0.5) - 0.35);
    float rMask = smoothstep(0.08, 0.05, rivets);
    float panel = step(0.02, f.x) * step(f.x, 0.98) * step(0.02, f.y) * step(f.y, 0.98);
    vec3 col = mix(vec3(0.2), vec3(0.45, 0.48, 0.5), panel);
    return mix(col, vec3(0.8, 0.85, 0.9), rMask);
}

vec3 texBlueWall(vec2 uv) {
    float stripe = step(0.1, abs(sin(uv.x * 31.4159)));
    vec3 col = mix(vec3(0.1, 0.3, 0.7), vec3(0.05, 0.15, 0.4), stripe);
    float noise = hash(floor(uv * 64.0)) * 0.1;
    return col + noise;
}

// 3.2.4 : textures procédurales pour les props (mis ici, avec texBrick/texMetal/texBlueWall dont
// c'est le pattern d'origine, plutôt que dans Common qui n'a jamais porté ces fonctions).
vec3 texSandbag(vec2 uv) {
    vec2 rowUV = uv * vec2(3.0, 6.0);
    if (fract(rowUV.y * 0.5) > 0.5) rowUV.x += 0.5;
    vec2 f = fract(rowUV);
    float bulge = smoothstep(0.0, 0.5, f.x) * smoothstep(1.0, 0.5, f.x);
    float noise = hash(floor(rowUV)) * 0.2 + 0.8;
    vec3 base = vec3(0.55, 0.48, 0.32) * noise;
    return base * (0.75 + 0.25 * bulge);
}

vec3 texRust(vec2 uv) {
    float n1 = hash(floor(uv * 10.0));
    float n2 = hash(floor(uv * 30.0) + 17.3);
    vec3 metal = vec3(0.35, 0.22, 0.15);
    vec3 rust = vec3(0.5, 0.25, 0.08);
    return mix(metal, rust, smoothstep(0.4, 0.9, n1 * 0.6 + n2 * 0.4));
}

vec3 texWood(vec2 uv) {
    float grain = sin(uv.y * 40.0 + hash(floor(uv.y * 6.0) * vec2(1.0)) * 6.0) * 0.5 + 0.5;
    float plank = step(0.03, fract(uv.x * 4.0));
    vec3 col = mix(vec3(0.28, 0.18, 0.1), vec3(0.38, 0.25, 0.14), grain * 0.5 + 0.3);
    return col * (0.6 + 0.4 * plank);
}

vec3 texCrate(vec2 uv) {
    vec3 wood = texWood(uv);
    vec2 f = fract(uv * 2.0);
    float band = step(0.85, max(f.x, f.y)) + step(f.x, 0.15) + step(f.y, 0.15);
    return mix(wood, vec3(0.15, 0.13, 0.1), clamp(band, 0.0, 1.0) * 0.6);
}

// Bug corrigé (découvert en Phase 2) : les IDs de matériau assignés par BufferA::materialFor
// (1.3 : 1=mur extérieur, 2=brique, 3=métal/bunker, 4=bleu/QG) n'étaient plus alignés avec ce
// switch depuis le passage à la carte data-driven (Phase 1) — les murs de brique "standard"
// (ID 2) s'affichaient avec la texture métal, et le QG (ID 4) tombait dans le cas par défaut.
vec3 getTexture(float ID, vec2 uv) {
    if (ID == 1.0) return texBrick(uv);     // mur extérieur
    if (ID == 2.0) return texBrick(uv);     // brique standard
    if (ID == 3.0) return texMetal(uv);     // bunker
    if (ID == 4.0) return texBlueWall(uv);  // QG
    return vec3(0.8, 0.6, 0.2);             // réservé (pilier, etc.)
}

vec3 shadeGrad(vec3 base, float t, float contrast) {
    vec3 dark = base * (1.0 - contrast * 0.7);
    vec3 light = mix(base, vec3(1.0), contrast * 0.6);
    return mix(dark, light, smoothstep(0.0, 1.0, clamp(t, 0.0, 1.0)));
}

float softBox(vec2 p, vec2 lo, vec2 hi, float aa) {
    vec2 d = min(p - lo, hi - p);
    float m = min(d.x, d.y);
    return smoothstep(0.0, aa, m);
}

float softCircle(vec2 p, vec2 c, float r, float aa) {
    float d = r - length(p - c);
    return smoothstep(0.0, aa, d);
}

// 3.2.3 : apparence des props — quad local `p2` en [0,1]x[0,1] (bas = 0), une ou deux formes
// simples par type (contrairement aux ennemis, pas besoin d'un corps articulé).
vec4 drawProp(float type, float variant, vec2 p2, float aa) {
    vec3 col = vec3(0.0);
    float a = 0.0;
    if (type == PROP_SANDBAG) {
        float body = softBox(p2, vec2(0.05, 0.0), vec2(0.95, 0.55), aa);
        vec3 c = texSandbag(p2 * vec2(2.0, 3.0) + variant);
        col = mix(col, c, body); a = max(a, body);
    } else if (type == PROP_BARBWIRE) {
        float post = softBox(p2, vec2(0.46, 0.0), vec2(0.54, 0.55), aa);
        col = mix(col, vec3(0.1, 0.08, 0.06), post); a = max(a, post);
        float zig = abs(fract(p2.x * 6.0 + p2.y * 2.0) - 0.5);
        float line = smoothstep(0.1, 0.0, zig) * step(0.05, p2.y) * step(p2.y, 0.5);
        col = mix(col, vec3(0.05), line); a = max(a, line * 0.85);
    } else if (type == PROP_CRATE) {
        float body = softBox(p2, vec2(0.08, 0.0), vec2(0.92, 0.85), aa);
        vec3 c = texCrate(p2 * 2.0 + variant * 0.3);
        col = mix(col, c, body); a = max(a, body);
    } else if (type == PROP_BARREL) {
        float body = softBox(p2, vec2(0.22, 0.0), vec2(0.78, 0.85), aa);
        float cap = softCircle(p2, vec2(0.5, 0.85), 0.28, aa);
        vec3 c = texRust(p2 * vec2(1.0, 3.0) + variant);
        col = mix(col, c, max(body, cap)); a = max(a, max(body, cap));
    } else if (type == PROP_POSTER) {
        float frame = softBox(p2, vec2(0.28, 0.35), vec2(0.72, 0.95), aa);
        col = mix(col, texWood(p2 * 3.0), frame); a = max(a, frame);
        float band = softBox(p2, vec2(0.32, 0.75), vec2(0.68, 0.88), aa);
        vec3 bandCol = variant < 2.0 ? vec3(0.55, 0.1, 0.08) : vec3(0.35, 0.35, 0.3);
        col = mix(col, bandCol, band); a = max(a, band);
    } else if (type == PROP_RUBBLE) {
        float body = max(softCircle(p2, vec2(0.3, 0.05), 0.22, aa),
            max(softCircle(p2, vec2(0.6, 0.08), 0.28, aa), softCircle(p2, vec2(0.8, 0.03), 0.16, aa)));
        float noise = hash(floor(p2 * 8.0) + variant) * 0.3 + 0.5;
        col = mix(col, vec3(0.2, 0.18, 0.16) * noise, body); a = max(a, body);
    } else if (type == PROP_JERRICAN) {
        float body = softBox(p2, vec2(0.25, 0.0), vec2(0.75, 0.7), aa);
        vec3 base = variant < 2.0 ? vec3(0.45, 0.12, 0.08) : vec3(0.25, 0.32, 0.14);
        col = mix(col, base, body); a = max(a, body);
        float cross = max(softBox(p2, vec2(0.46, 0.15), vec2(0.54, 0.55), aa),
            softBox(p2, vec2(0.35, 0.31), vec2(0.65, 0.39), aa)) * body;
        col = mix(col, vec3(0.92), cross);
    } else if (type == PROP_MIRADOR) {
        float body = max(softBox(p2, vec2(0.42, 0.0), vec2(0.58, 0.75), aa), softBox(p2, vec2(0.15, 0.75), vec2(0.85, 0.9), aa));
        col = mix(col, vec3(0.12, 0.1, 0.08), body); a = max(a, body);
    }
    return vec4(col, a);
}

// ===== 5.2 : police vectorielle minimale (option A du roadmap) =====
// Alphabet réduit au strict nécessaire pour les textes du jeu (titre + prompts + score), plutôt
// que l'alphabet complet : chaque lettre est un ensemble de 2 à 7 segments (le tracé s'inspire du
// 7-segments pour les lettres qui s'y prêtent, avec des diagonales dédiées pour N/Q/R/Z). Rendu en
// SDF de segments avec contour, cohérent avec l'effet "pochoir militaire" recherché en 5.2.2.
float sdSeg(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

#define CH_A 0
#define CH_C 1
#define CH_D 2
#define CH_E 3
#define CH_I 4
#define CH_L 5
#define CH_N 6
#define CH_P 7
#define CH_Q 8
#define CH_R 9
#define CH_S 10
#define CH_T 11
#define CH_U 12
#define CH_Z 13
#define CH_0 14
#define CH_1 15
#define CH_2 16
#define CH_3 17
#define CH_4 18
#define CH_5 19
#define CH_6 20
#define CH_7 21
#define CH_8 22
#define CH_9 23
#define CH_SPACE 24

// Glyphe dans [0,1]^2 (bas=0). TL/TR/ML/MR/BL/BR = coins et milieux de bord, comme un afficheur
// 7-segments (A=haut, B=haut-droit, C=bas-droit, D=bas, E=bas-gauche, F=haut-gauche, G=milieu).
float glyphDist(int ch, vec2 p) {
    vec2 TL = vec2(0.0, 1.0), TR = vec2(1.0, 1.0), ML = vec2(0.0, 0.5), MR = vec2(1.0, 0.5), BL = vec2(0.0, 0.0), BR = vec2(1.0, 0.0);
    vec2 TM = vec2(0.5, 1.0), BM = vec2(0.5, 0.0);
    float d = 1e5;
    if (ch == CH_SPACE) return d;
    else if (ch == CH_A) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); }
    else if (ch == CH_C) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, BL, BR)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); }
    else if (ch == CH_D) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); }
    else if (ch == CH_E) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_I) { d = min(d, sdSeg(p, TM, BM)); }
    else if (ch == CH_L) { d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_N) { d = min(d, sdSeg(p, BL, TL)); d = min(d, sdSeg(p, BR, TR)); d = min(d, sdSeg(p, TL, BR)); }
    else if (ch == CH_P) { d = min(d, sdSeg(p, BL, TL)); d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, ML, MR)); }
    else if (ch == CH_Q) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, vec2(0.5, 0.35), BR)); }
    else if (ch == CH_R) { d = min(d, sdSeg(p, BL, TL)); d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, ML, BR)); }
    else if (ch == CH_S) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_T) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TM, BM)); }
    else if (ch == CH_U) { d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); }
    else if (ch == CH_Z) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, ML, BL)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_0) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); }
    else if (ch == CH_1) { d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); }
    else if (ch == CH_2) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, ML, BL)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_3) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_4) { d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); }
    else if (ch == CH_5) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BL, BR)); }
    else if (ch == CH_6) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BL, BR)); d = min(d, sdSeg(p, BL, ML)); }
    else if (ch == CH_7) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); }
    else if (ch == CH_8) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, BL, ML)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); }
    else if (ch == CH_9) { d = min(d, sdSeg(p, TL, TR)); d = min(d, sdSeg(p, TR, MR)); d = min(d, sdSeg(p, MR, BR)); d = min(d, sdSeg(p, BR, BL)); d = min(d, sdSeg(p, ML, TL)); d = min(d, sdSeg(p, ML, MR)); }
    return d;
}

float charMask(int ch, vec2 uv, float strokeW, float aa) {
    if (uv.x < -0.2 || uv.x > 1.2 || uv.y < -0.2 || uv.y > 1.2) return 0.0;
    return smoothstep(strokeW, strokeW - aa, glyphDist(ch, uv));
}

// `msg` : chaîne encodée en codes CH_*, taille fixe (complétée par CH_SPACE) ; `len` = longueur utile.
// `origin` = (centre horizontal, bas) du bloc de texte, dans les mêmes unités que `p` (hudUV, voir
// mainImage). `cw`/`chh` = largeur/hauteur d'un caractère dans ces mêmes unités.
#define TEXT_MAX_LEN 16
float drawText(int msg[TEXT_MAX_LEN], int len, vec2 p, vec2 origin, float cw, float chh, float strokeW, float aa) {
    float totalW = float(len) * cw;
    vec2 local = p - origin + vec2(totalW * 0.5, 0.0);
    if (local.y < -0.1 * chh || local.y > chh * 1.1) return 0.0;
    int idx = int(floor(local.x / cw));
    if (idx < 0 || idx >= len) return 0.0;
    vec2 cellUV = vec2(fract(local.x / cw), local.y / chh);
    return charMask(msg[idx], cellUV, strokeW, aa / chh);
}

const int TITLE_LEN = 10;
const int TITLE_MSG[TEXT_MAX_LEN] = int[TEXT_MAX_LEN](CH_S, CH_A, CH_N, CH_D, CH_E, CH_S, CH_T, CH_E, CH_I, CH_N, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE);

const int SUB_LEN = 7;
const int SUB_MSG[TEXT_MAX_LEN] = int[TEXT_MAX_LEN](CH_C, CH_L, CH_I, CH_Q, CH_U, CH_E, CH_Z, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE);

const int PAUSE_LEN = 5;
const int PAUSE_MSG[TEXT_MAX_LEN] = int[TEXT_MAX_LEN](CH_P, CH_A, CH_U, CH_S, CH_E, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE);

// 6.2 : écran de victoire — "REUSSI", choisi (comme "PERDU") pour rester dans l'alphabet réduit.
const int WIN_LEN = 6;
const int WIN_MSG[TEXT_MAX_LEN] = int[TEXT_MAX_LEN](CH_R, CH_E, CH_U, CH_S, CH_S, CH_I, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE, CH_SPACE);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec4 state0 = texelFetch(iChannel0, ivec2(0, 0), 0);
    vec4 state1 = texelFetch(iChannel0, ivec2(1, 0), 0);
    vec4 state2 = texelFetch(iChannel0, ivec2(2, 0), 0);
    float gameState = texelFetch(iChannel0, TX_GAME_STATE, 0).x;

    vec2 rayOrigin = state0.xy;
    float angle = state0.z;
    float bobPhase = state0.w;
    float bobAmt = state1.x;
    float playerHealth = state1.z;
    float score = state2.y;
    float muzzleFlashTimer = state2.z;
    float playerDeathTimer = state2.w;

    // Phase 3 : les ennemis (pos/pv/timer + état FSM) vivent désormais dans BufferC.
    vec4 enemies[NUM_ENEMIES];
    float enemyFsmState[NUM_ENEMIES];
    for (int i = 0; i < NUM_ENEMIES; i++) {
        enemies[i] = texelFetch(iChannel1, ivec2(i * TEXELS_PER_ENEMY + 0, 0), 0);
        enemyFsmState[i] = texelFetch(iChannel1, ivec2(i * TEXELS_PER_ENEMY + 1, 0), 0).x;
    }

    float verticalBob = sin(bobPhase) * 0.025 * bobAmt;
    float horizontalBob = cos(bobPhase * 0.5) * 0.015 * bobAmt;
    vec2 bobbing = vec2(horizontalBob, verticalBob);

    uv += bobbing;

    vec2 rayDir = normalize(vec2(cos(angle), sin(angle)) + vec2(-sin(angle), cos(angle)) * uv.x * FOV);

    // 2.2.6 : DDA factorisé dans Common, carte lue depuis iChannel3 (BufferA) via texelFetch.
    int side;
    float wallType;
    float perpWallDist = raycastWallDist(rayOrigin, rayDir, iChannel3, side, wallType);

    vec3 color = vec3(0.0);

    float wallHeight = 1.0 / perpWallDist;
    float wallStart = -wallHeight * 0.5;
    float wallEnd = wallHeight * 0.5;

    if (uv.y > wallEnd) {
        vec2 floorUV = rayOrigin + rayDir * (0.5 / uv.y);
        float check = mod(floor(floorUV.x) + floor(floorUV.y), 2.0);
        color = mix(vec3(0.15), vec3(0.25), check) * (1.0 - min(1.0, length(floorUV - rayOrigin) * 0.15));
    } else if (uv.y < wallStart) {
        float ceilDist = -0.5 / uv.y;
        vec2 ceilUV = rayOrigin + rayDir * ceilDist;
        // 3.2.6 : cour du poste de garde à ciel ouvert — dégradé de ciel nuageux au lieu de la grille.
        ivec2 ceilCell = ivec2(floor(ceilUV));
        bool outdoor = ceilCell.x >= 48 && ceilCell.x <= 58 && ceilCell.y >= 6 && ceilCell.y <= 14;
        vec3 ceilTex;
        if (outdoor) {
            float cloud = hash(floor(ceilUV * 3.0)) * 0.5 + hash(floor(ceilUV * 7.0)) * 0.3;
            ceilTex = mix(vec3(0.42, 0.44, 0.46), vec3(0.62, 0.64, 0.65), clamp(cloud, 0.0, 1.0));
        } else {
            ceilTex = vec3(0.1, 0.1, 0.12);
            vec2 grid = abs(fract(ceilUV - 0.5) - 0.5) / fwidth(ceilUV);
            float line = min(grid.x, grid.y);
            ceilTex += vec3(0.2, 0.4, 0.8) * (1.0 - min(line, 1.0)) * 0.5;
        }
        color = ceilTex * (1.0 - min(1.0, ceilDist * 0.15));
    } else {
        float wallX = (side == 0) ? rayOrigin.y + perpWallDist * rayDir.y : rayOrigin.x + perpWallDist * rayDir.x;
        wallX = fract(wallX);

        float texY = (uv.y - wallStart) / (wallEnd - wallStart);
        vec2 wallUV = vec2(wallX, texY);

        color = getTexture(wallType, wallUV);
        if (side == 1) color *= 0.7;

        float ao = smoothstep(0.0, 0.1, texY) * smoothstep(1.0, 0.9, texY);
        color *= mix(0.4, 1.0, ao);

        float fog = exp(-perpWallDist * 0.18);
        color = mix(vec3(0.02, 0.02, 0.05), color, fog);
        color *= mix(1.0, 1.35, exp(-perpWallDist * 0.35));
    }

    vec2 dirV = vec2(cos(angle), sin(angle));
    vec2 rightV = vec2(-dirV.y, dirV.x);

    float bestEnemyDist = 1e5;
    vec3 enemyColor = vec3(0.0);
    float enemyAlpha = 0.0;

    for (int i = 0; i < NUM_ENEMIES; i++) {
        vec4 e = enemies[i];
        if (e.z <= 0.0 && e.w > 2.2) continue;
        vec2 rel = e.xy - rayOrigin;
        float f = dot(rel, dirV);
        float sdv = dot(rel, rightV);
        if (f < 0.15 || f > MAX_RANGE || f >= perpWallDist || f >= bestEnemyDist) continue;

        float shrink = e.z <= 0.0 ? clamp(1.0 - e.w / 1.6, 0.0, 1.0) : 1.0;
        if (shrink <= 0.02) continue;

        float halfWidth = 0.30 / (f * FOV);
        float uvCenter = sdv / (f * FOV);
        if (abs(uv.x - uvCenter) > halfWidth * 1.15) continue;

        float fullH = 1.0 / f;
        float eHeight = fullH * 0.86 * shrink;
        float eBottom = -fullH * 0.5;
        float eTop = eBottom + eHeight;
        if (uv.y < eBottom - 0.02 || uv.y > eTop + 0.02) continue;

        float sx = (uv.x - (uvCenter - halfWidth)) / (halfWidth * 2.0);
        float sy = (uv.y - eBottom) / eHeight;
        float aa = 0.02 / max(f, 0.5);

        float fsmState = enemyFsmState[i];
        bool moving = e.z > 0.0 && fsmState != ST_ALERT && fsmState != ST_ATTACK;
        float legPhase = iTime * 5.2 + float(i) * 2.1;
        float legSwing = moving ? sin(legPhase) * 0.05 : 0.02;

        vec3 armor = vec3(0.24, 0.30, 0.18);
        vec3 cloth = vec3(0.16, 0.16, 0.14);
        vec3 skin = vec3(0.72, 0.55, 0.42);
        vec3 metal = vec3(0.22, 0.21, 0.2);
        vec3 helmet = vec3(0.2, 0.24, 0.15);

        float deathTilt = e.z <= 0.0 ? clamp(e.w * 0.9, 0.0, 0.55) : 0.0;
        vec2 p2 = vec2(sx, sy);
        p2.x += deathTilt * (sy - 0.2);

        vec3 lc = vec3(0.0);
        float la = 0.0;

        float bootL = softBox(p2, vec2(0.27 + legSwing, 0.0), vec2(0.45 + legSwing, 0.09), aa);
        float bootR = softBox(p2, vec2(0.55 - legSwing, 0.0), vec2(0.73 - legSwing, 0.09), aa);
        lc = mix(lc, vec3(0.05, 0.05, 0.05), bootL); la = max(la, bootL);
        lc = mix(lc, vec3(0.05, 0.05, 0.05), bootR); la = max(la, bootR);

        float legL = softBox(p2, vec2(0.29 + legSwing, 0.09), vec2(0.45 + legSwing, 0.36), aa);
        float legR = softBox(p2, vec2(0.55 - legSwing, 0.09), vec2(0.71 - legSwing, 0.36), aa);
        vec3 legCol = shadeGrad(cloth, (sy - 0.09) / 0.27, 0.4);
        lc = mix(lc, legCol, legL); la = max(la, legL);
        lc = mix(lc, legCol, legR); la = max(la, legR);

        float torso = softBox(p2, vec2(0.14, 0.34), vec2(0.86, 0.74), aa);
        vec3 torsoCol = shadeGrad(armor, (sy - 0.34) / 0.40, 0.55);
        lc = mix(lc, torsoCol, torso); la = max(la, torso);

        float belt = softBox(p2, vec2(0.14, 0.34), vec2(0.86, 0.39), aa);
        lc = mix(lc, vec3(0.08, 0.07, 0.06), belt); la = max(la, belt);

        float padL = softBox(p2, vec2(0.10, 0.62), vec2(0.28, 0.74), aa);
        float padR = softBox(p2, vec2(0.72, 0.62), vec2(0.90, 0.74), aa);
        vec3 padCol = shadeGrad(armor * 1.15, (sy - 0.62) / 0.12, 0.6);
        lc = mix(lc, padCol, padL); la = max(la, padL);
        lc = mix(lc, padCol, padR); la = max(la, padR);

        float rifle = softBox(p2, vec2(0.06, 0.47 + legSwing * 0.3), vec2(0.94, 0.55 + legSwing * 0.3), aa);
        vec3 rifleCol = shadeGrad(metal, (sy - 0.47) / 0.08, 0.7);
        lc = mix(lc, rifleCol, rifle); la = max(la, rifle);

        float neck = softBox(p2, vec2(0.42, 0.74), vec2(0.58, 0.80), aa);
        lc = mix(lc, shadeGrad(skin, 0.5, 0.3), neck); la = max(la, neck);

        float head = softCircle(p2, vec2(0.5, 0.90), 0.115, aa);
        vec3 headCol = shadeGrad(helmet, (p2.y - 0.79) / 0.22, 0.6);
        lc = mix(lc, headCol, head); la = max(la, head);

        float visor = softBox(p2, vec2(0.40, 0.865), vec2(0.60, 0.905), aa * 0.6);
        lc = mix(lc, vec3(0.03, 0.03, 0.03), visor); la = max(la, visor);

        // 4.4.8 : couleur d'œil selon l'état FSM — retour visuel clair sur la vigilance de l'ennemi.
        float eyeGlow = e.z > 0.0 ? 1.0 : 0.0;
        float eyeL = softCircle(p2, vec2(0.445, 0.885), 0.018, aa * 0.4);
        float eyeR = softCircle(p2, vec2(0.555, 0.885), 0.018, aa * 0.4);
        vec3 eyeColByState = (fsmState == ST_PATROL) ? vec3(0.5, 0.45, 0.3) :
            (fsmState == ST_ALERT || fsmState == ST_SEARCH) ? vec3(1.0, 0.55, 0.05) :
            vec3(1.0, 0.1, 0.05); // CHASE / ATTACK
        vec3 eyeCol = eyeColByState * eyeGlow;
        lc = mix(lc, eyeCol, eyeL * eyeGlow); la = max(la, eyeL * eyeGlow);
        lc = mix(lc, eyeCol, eyeR * eyeGlow); la = max(la, eyeR * eyeGlow);

        float hitFlash = e.z > 0.0 ? smoothstep(0.15, 0.0, e.w) : 0.0;
        lc = mix(lc, vec3(1.0, 0.95, 0.9), hitFlash * 0.75);
        if (e.z <= 0.0) lc = mix(lc, vec3(0.35, 0.05, 0.05), 0.55);

        float fog2 = exp(-f * 0.15);
        lc = mix(vec3(0.02, 0.02, 0.05), lc, fog2);

        if (la > 0.02) {
            enemyColor = lc;
            enemyAlpha = la;
            bestEnemyDist = f;
        }
    }

    // 3.2.3 : second passage de sprite pour le décor (BufferD), même principe que les ennemis
    // (billboard face caméra, occlusion contre perpWallDist) mais formes bien plus simples (7.2 :
    // early-out dès qu'un mur ou un prop plus proche est trouvé, avant tout calcul de forme).
    float bestPropDist = 1e5;
    vec3 propColor = vec3(0.0);
    float propAlpha = 0.0;

    for (int pi = 0; pi < MAX_PROPS; pi++) {
        // Adressage par index linéaire (Common), doit correspondre à l'écriture de BufferD.
        vec4 prop = texelFetch(iChannel2, texelForIndex(pi, iChannel2), 0);
        float ptype = prop.x;
        if (ptype == PROP_NONE) continue;
        vec2 ppos = prop.yz;
        float pvariant = prop.w;

        vec2 rel = ppos - rayOrigin;
        float f = dot(rel, dirV);
        // 7.2 : culling par distance précoce (avant toute largeur/hauteur/forme), pour éviter que
        // les props dispersés à travers de longues lignes de vue dégagées (cour, dépôt) coûtent
        // quoi que ce soit une fois hors de MAX_RANGE, même si `perpWallDist` ne les avait pas
        // déjà exclus (sightline ouverte sans mur avant MAX_RAY_STEPS).
        if (f < 0.15 || f > MAX_RANGE || f >= perpWallDist || f >= bestPropDist) continue;
        float sdv = dot(rel, rightV);

        float propHalfWidth = (ptype == PROP_MIRADOR ? 0.55 : ptype == PROP_BARBWIRE ? 0.5 : 0.4) / (f * FOV);
        float uvCenter = sdv / (f * FOV);
        if (abs(uv.x - uvCenter) > propHalfWidth * 1.1) continue;

        float propWorldHeight =
            ptype == PROP_MIRADOR ? 2.2 : ptype == PROP_BARREL ? 0.9 : ptype == PROP_POSTER ? 1.3 :
            ptype == PROP_SANDBAG ? 0.55 : ptype == PROP_BARBWIRE ? 0.9 : ptype == PROP_CRATE ? 0.85 :
            ptype == PROP_JERRICAN ? 0.55 : 0.35; // PROP_RUBBLE
        float fullH = 1.0 / f;
        float pHeight = fullH * propWorldHeight;
        float pBottom = -fullH * 0.5;
        float pTop = pBottom + pHeight;
        if (uv.y < pBottom - 0.02 || uv.y > pTop + 0.02) continue;

        float sx = (uv.x - (uvCenter - propHalfWidth)) / (propHalfWidth * 2.0);
        float sy = (uv.y - pBottom) / pHeight;
        float paa = 0.02 / max(f, 0.5);

        vec4 shape = drawProp(ptype, pvariant, vec2(sx, sy), paa);
        if (shape.a > 0.02) {
            float fog3 = exp(-f * 0.15);
            propColor = mix(vec3(0.02, 0.02, 0.05), shape.rgb, fog3);
            propAlpha = shape.a;
            bestPropDist = f;
        }
    }

    // Ordre de profondeur entre le prop et l'ennemi les plus proches (tous deux devant le mur touché).
    if (bestEnemyDist < bestPropDist) {
        color = mix(color, propColor, propAlpha);
        color = mix(color, enemyColor, enemyAlpha);
    } else {
        color = mix(color, enemyColor, enemyAlpha);
        color = mix(color, propColor, propAlpha);
    }

    // 3.2.5 : ambiance "front de guerre" — assombrissement léger + teinte sépia/verdâtre discrète,
    // appliquée avant le HUD pour ne pas ternir la lisibilité de la vie/reticule/pips.
    color *= 0.94;
    color = mix(color, vec3(0.5, 0.46, 0.36), 0.08);

    vec2 screenUV = fragCoord / iResolution.xy;

    vec2 gunUV = screenUV - vec2(0.5, 0.0);
    gunUV.x -= horizontalBob * 1.4;
    gunUV.y += verticalBob * 1.4;
    float recoil = muzzleFlashTimer / 0.12;
    gunUV.y -= recoil * 0.05;
    gunUV.x += recoil * 0.01;

    vec3 gunColorFinal = vec3(0.0);
    float gunAlpha = 0.0;
    float gaa = 0.004;

    float stock = softBox(gunUV, vec2(-0.045, -0.10), vec2(0.045, 0.03), gaa);
    vec3 stockCol = shadeGrad(vec3(0.12, 0.10, 0.08), (gunUV.y + 0.10) / 0.13, 0.5);
    gunColorFinal = mix(gunColorFinal, stockCol, stock); gunAlpha = max(gunAlpha, stock);

    float grip = softBox(gunUV, vec2(-0.03, -0.09), vec2(0.02, 0.02), gaa);
    gunColorFinal = mix(gunColorFinal, vec3(0.06, 0.05, 0.05), grip); gunAlpha = max(gunAlpha, grip);

    float body = softBox(gunUV, vec2(-0.058, 0.02), vec2(0.058, 0.20), gaa);
    vec3 bodyCol = shadeGrad(vec3(0.20, 0.19, 0.18), (gunUV.x + 0.058) / 0.116, 0.75);
    gunColorFinal = mix(gunColorFinal, bodyCol, body); gunAlpha = max(gunAlpha, body);

    float mag = softBox(gunUV, vec2(-0.022, -0.14), vec2(0.022, 0.04), gaa);
    vec3 magCol = shadeGrad(vec3(0.14, 0.13, 0.12), (gunUV.x + 0.022) / 0.044, 0.6);
    gunColorFinal = mix(gunColorFinal, magCol, mag); gunAlpha = max(gunAlpha, mag);

    float sight = softBox(gunUV, vec2(-0.006, 0.20), vec2(0.006, 0.25), gaa);
    gunColorFinal = mix(gunColorFinal, vec3(0.05), sight); gunAlpha = max(gunAlpha, sight);

    float barrel = softBox(gunUV, vec2(-0.026, 0.19), vec2(0.026, 0.40), gaa);
    vec3 barrelCol = shadeGrad(vec3(0.10, 0.10, 0.11), (gunUV.x + 0.026) / 0.052, 0.85);
    gunColorFinal = mix(gunColorFinal, barrelCol, barrel); gunAlpha = max(gunAlpha, barrel);

    float rail = softBox(gunUV, vec2(-0.058, 0.11), vec2(0.058, 0.135), gaa);
    gunColorFinal = mix(gunColorFinal, vec3(0.28, 0.27, 0.26), rail); gunAlpha = max(gunAlpha, rail);

    float specEdge = softBox(gunUV, vec2(-0.058, 0.02), vec2(-0.048, 0.20), gaa) + softBox(gunUV, vec2(0.048, 0.02), vec2(0.058, 0.20), gaa);
    gunColorFinal += vec3(0.15) * clamp(specEdge, 0.0, 1.0) * body;

    // 5.1 : arme/reticule/flash uniquement visibles en jeu (PLAYING ou PAUSED), pas en BOOT/INTRO/GAMEOVER.
    bool showHud = (gameState == GS_PLAYING || gameState == GS_PAUSED);

    if (showHud && gunAlpha > 0.02) {
        color = mix(color, gunColorFinal, gunAlpha);
    }

    if (showHud && muzzleFlashTimer > 0.0) {
        vec2 flashUV = gunUV - vec2(0.0, 0.40);
        float flashDist = length(flashUV * vec2(1.0, 0.7)) / 0.075;
        float flashMask = smoothstep(1.0, 0.0, flashDist) * (muzzleFlashTimer / 0.12);
        color += vec3(1.0, 0.8, 0.35) * flashMask * 1.4;
        color += vec3(1.0, 0.7, 0.3) * 0.06 * (muzzleFlashTimer / 0.12) * smoothstep(1.0, 0.0, length(screenUV - vec2(0.5, 0.32)) * 2.0);
    }

    vec2 reticle = abs(screenUV - 0.5);
    if (showHud && ((reticle.x < 0.002 && reticle.y < 0.01) || (reticle.y < 0.003 && reticle.x < 0.006))) {
        color = mix(color, vec3(1.0, 0.0, 0.0), 0.8);
    }

    color *= 0.5 + 0.5 * pow(16.0 * screenUV.x * screenUV.y * (1.0 - screenUV.x) * (1.0 - screenUV.y), 0.25);

    // Coordonnées partagées par le HUD (mini-carte/compteurs) et les écrans d'état plus bas.
    vec2 hudUV = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float txtAA = 1.5 / iResolution.y;
    float strokeW = 0.16;

    if (showHud) {
        vec2 barPos = screenUV - vec2(0.03, 0.94);
        if (barPos.x > 0.0 && barPos.x < 0.2 && barPos.y > -0.02 && barPos.y < 0.02) {
            float fillX = playerHealth / 100.0 * 0.2;
            vec3 barColor = barPos.x < fillX ? mix(vec3(0.8, 0.15, 0.1), vec3(0.2, 0.8, 0.2), playerHealth / 100.0) : vec3(0.15);
            color = mix(color, barColor, 0.85);
        }

        for (int i = 0; i < 10; i++) {
            if (float(i) >= score) break;
            vec2 pipPos = screenUV - vec2(0.97 - float(i) * 0.025, 0.05);
            if (abs(pipPos.x) < 0.008 && abs(pipPos.y) < 0.008) {
                color = mix(color, vec3(0.9, 0.75, 0.1), 0.9);
            }
        }

        if (playerHealth < 35.0) {
            float pulse = 0.25 + 0.15 * sin(iTime * 6.0);
            float vig = smoothstep(0.9, 0.2, length(screenUV - 0.5));
            color = mix(color, vec3(0.5, 0.0, 0.0), (1.0 - vig) * pulse * (1.0 - playerHealth / 35.0));
        }

        // 6.5 : dégâts de contact — flash directionnel (côté de l'écran d'où vient le coup) plutôt
        // qu'une vignette globale, en complément du pulse ci-dessus. Lu directement sur BufferC
        // (iChannel1), qui a déjà calculé ce tick pour son propre texel de contrôle.
        vec4 aiControl = texelFetch(iChannel1, TX_AI_CONTROL, 0);
        if (aiControl.w > 0.5) {
            float rel = aiControl.z - angle;
            rel = mod(rel + PI, 2.0 * PI) - PI; // [-PI, PI], 0 = attaque de face
            float side = sign(rel);
            float edgeDist = abs(screenUV.x - (0.5 + side * 0.5));
            float edgeFlash = smoothstep(0.55, 0.0, edgeDist) * (0.3 + 0.2 * sin(iTime * 18.0));
            color = mix(color, vec3(0.85, 0.05, 0.03), edgeFlash);
        }

        // 6.1/6.3 : mini-carte (coin haut-droit) + marqueurs objectif (QG) et menace (ennemi le
        // plus proche en CHASE/ATTACK). Simplification assumée : fenêtre locale autour du joueur
        // (rayon fixe), pas de mémoire "zone explorée" persistante (éviterait un budget de texels
        // et des écritures supplémentaires rien que pour du fog-of-war).
        vec2 mmCenterUV = vec2(0.885, 0.86);
        float mmRadiusUV = 0.1;
        vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
        vec2 toMM = (screenUV - mmCenterUV) * aspect;
        float mmDist = length(toMM);
        if (mmDist < mmRadiusUV) {
            float worldRadius = 9.0;
            float mmScale = worldRadius / mmRadiusUV;
            vec2 worldOffset = rightV * toMM.x * mmScale + dirV * toMM.y * mmScale;
            ivec2 mmCell = ivec2(floor(rayOrigin + worldOffset));
            float mmId = mapId(mmCell, iChannel3);
            vec3 mmCol = mmId > 0.0 ? vec3(0.13, 0.12, 0.11) : vec3(0.5, 0.47, 0.4);
            color = mix(color, mmCol, 0.92);

            if (mmDist < mmRadiusUV * 0.055) color = mix(color, vec3(0.95, 0.9, 0.35), 1.0); // joueur

            // Marqueur objectif (or) et menace (rouge), projetés sur le disque, clampés au bord
            // (6.3 : "indicateur de direction ... vers l'objectif ou le dernier ennemi qui a repéré").
            vec2 objRel = OBJECTIVE_POS - rayOrigin;
            vec2 objLocal = vec2(dot(objRel, rightV), dot(objRel, dirV)) / mmScale;
            float objLen = length(objLocal);
            if (objLen > mmRadiusUV * 0.88) objLocal *= (mmRadiusUV * 0.88) / max(objLen, 0.0001);
            if (length(toMM - objLocal) < mmRadiusUV * 0.06) color = mix(color, vec3(0.95, 0.75, 0.15), 1.0);

            float bestThreatDist = 1e5;
            vec2 threatPos = vec2(0.0);
            bool hasThreat = false;
            for (int i = 0; i < NUM_ENEMIES; i++) {
                if (enemies[i].z <= 0.0) continue;
                float st = enemyFsmState[i];
                if (st != ST_CHASE && st != ST_ATTACK) continue;
                float dEnemy = distance(enemies[i].xy, rayOrigin);
                if (dEnemy < bestThreatDist) { bestThreatDist = dEnemy; threatPos = enemies[i].xy; hasThreat = true; }
            }
            if (hasThreat) {
                vec2 thRel = threatPos - rayOrigin;
                vec2 thLocal = vec2(dot(thRel, rightV), dot(thRel, dirV)) / mmScale;
                float thLen = length(thLocal);
                if (thLen > mmRadiusUV * 0.88) thLocal *= (mmRadiusUV * 0.88) / max(thLen, 0.0001);
                if (length(toMM - thLocal) < mmRadiusUV * 0.06) color = mix(color, vec3(0.95, 0.15, 0.1), 1.0);
            }
        }
        float mmEdge = smoothstep(mmRadiusUV, mmRadiusUV - fwidth(mmDist) * 2.0, mmDist) -
            smoothstep(mmRadiusUV - fwidth(mmDist) * 2.0, mmRadiusUV - fwidth(mmDist) * 4.0, mmDist);
        color = mix(color, vec3(0.04), mmEdge * 0.6);

        // 6.4 : compteur d'ennemis restants, à côté de la mini-carte (réutilise aiControl ci-dessus).
        int aliveInt = int(aiControl.y + 0.5);
        int tensA = aliveInt / 10;
        int onesA = aliveInt - tensA * 10;
        int aliveMsg[TEXT_MAX_LEN];
        for (int k = 0; k < TEXT_MAX_LEN; k++) aliveMsg[k] = CH_SPACE;
        int aliveLen;
        if (tensA > 0) { aliveMsg[0] = CH_0 + tensA; aliveMsg[1] = CH_0 + onesA; aliveLen = 2; }
        else { aliveMsg[0] = CH_0 + onesA; aliveLen = 1; }
        float aliveH = 0.028;
        vec2 aliveOrigin = vec2((mmCenterUV.x - 0.5) * aspect.x - mmRadiusUV - aliveH * 0.4, (mmCenterUV.y - 0.5) - aliveH * 0.5);
        float aliveMask = drawText(aliveMsg, aliveLen, hudUV, aliveOrigin, aliveH * 0.62, aliveH, strokeW, txtAA);
        color = mix(color, vec3(0.85, 0.3, 0.15), aliveMask);
    }

    // 5.2 : écrans d'état avec la police vectorielle définie plus haut. Textes volontairement
    // courts (alphabet réduit à ce qui est strictement nécessaire, cf. note roadmap 5.2) : le titre
    // "SANDESTEIN" est imposé par 5.3 ; le prompt "CLIQUEZ" et le message de défaite "PERDU" sont
    // des raccourcis assumés plutôt que "cliquez pour commencer" / "mission échouée".

    if (gameState == GS_BOOT) {
        color = vec3(0.0);
    } else if (gameState == GS_INTRO) {
        color *= 0.35;

        // 5.2.2 : effet d'entrée "radio de guerre" — flicker occasionnel plutôt qu'une révélation
        // lettre par lettre (qui demanderait de mémoriser un timer d'entrée d'état supplémentaire).
        float flicker = 1.0 - 0.5 * step(0.985, hash(vec2(floor(iTime * 14.0), 0.0)));
        float titleH = 0.1;
        float titleMask = drawText(TITLE_MSG, TITLE_LEN, hudUV, vec2(0.0, 0.1), titleH * 0.62, titleH, strokeW, txtAA);
        float titleGlow = drawText(TITLE_MSG, TITLE_LEN, hudUV, vec2(0.0, 0.1), titleH * 0.62, titleH, strokeW * 2.5, txtAA * 4.0);
        vec3 titleCol = vec3(0.88, 0.8, 0.5) * flicker;
        color += titleCol * titleGlow * 0.3;
        color = mix(color, titleCol, titleMask);

        float pulse = 0.5 + 0.5 * sin(iTime * 2.2);
        float subH = 0.032;
        float subMask = drawText(SUB_MSG, SUB_LEN, hudUV, vec2(0.0, -0.22), subH * 0.62, subH, strokeW, txtAA);
        color = mix(color, vec3(0.9, 0.85, 0.6), subMask * pulse);
    } else if (gameState == GS_PAUSED) {
        color *= 0.4;
        color = mix(color, vec3(0.5), 0.08);
        float pauseH = 0.07;
        float pauseMask = drawText(PAUSE_MSG, PAUSE_LEN, hudUV, vec2(0.0, -0.03), pauseH * 0.62, pauseH, strokeW, txtAA);
        color = mix(color, vec3(0.85), pauseMask);
    } else if (gameState == GS_GAMEOVER) {
        color = mix(color, vec3(0.35, 0.02, 0.02), 0.55);

        // "PERDU" + score (jusqu'à 2 chiffres), un seul message combiné.
        int scoreVal = int(score);
        int tens = scoreVal / 10;
        int ones = scoreVal - tens * 10;
        int overMsg[TEXT_MAX_LEN];
        for (int k = 0; k < TEXT_MAX_LEN; k++) overMsg[k] = CH_SPACE;
        overMsg[0] = CH_P; overMsg[1] = CH_E; overMsg[2] = CH_R; overMsg[3] = CH_D; overMsg[4] = CH_U;
        int overLen;
        if (tens > 0) { overMsg[6] = CH_0 + tens; overMsg[7] = CH_0 + ones; overLen = 8; }
        else { overMsg[6] = CH_0 + ones; overLen = 7; }

        float msgH = 0.075;
        float msgMask = drawText(overMsg, overLen, hudUV, vec2(0.0, 0.08), msgH * 0.62, msgH, strokeW, txtAA);
        color = mix(color, vec3(0.9, 0.75, 0.2), msgMask);

        if (playerDeathTimer > PLAYER_RESPAWN_TIME) {
            float pulse = 0.5 + 0.5 * sin(iTime * 2.2);
            float subH = 0.032;
            float subMask = drawText(SUB_MSG, SUB_LEN, hudUV, vec2(0.0, -0.2), subH * 0.62, subH, strokeW, txtAA);
            color = mix(color, vec3(0.9, 0.85, 0.6), subMask * pulse);
        }
    } else if (gameState == GS_VICTORY) {
        // 6.2 : écran de victoire, symétrique du GAMEOVER (teinte verte au lieu de rouge).
        color = mix(color, vec3(0.05, 0.3, 0.08), 0.5);

        int scoreVal = int(score);
        int tens = scoreVal / 10;
        int ones = scoreVal - tens * 10;
        int winScoreMsg[TEXT_MAX_LEN];
        for (int k = 0; k < TEXT_MAX_LEN; k++) winScoreMsg[k] = CH_SPACE;
        for (int k = 0; k < WIN_LEN; k++) winScoreMsg[k] = WIN_MSG[k];
        int winLen;
        if (tens > 0) { winScoreMsg[WIN_LEN + 1] = CH_0 + tens; winScoreMsg[WIN_LEN + 2] = CH_0 + ones; winLen = WIN_LEN + 3; }
        else { winScoreMsg[WIN_LEN + 1] = CH_0 + ones; winLen = WIN_LEN + 2; }

        float msgH = 0.075;
        float msgMask = drawText(winScoreMsg, winLen, hudUV, vec2(0.0, 0.08), msgH * 0.62, msgH, strokeW, txtAA);
        color = mix(color, vec3(0.75, 0.95, 0.5), msgMask);

        if (playerDeathTimer > PLAYER_RESPAWN_TIME) {
            float pulse = 0.5 + 0.5 * sin(iTime * 2.2);
            float subH = 0.032;
            float subMask = drawText(SUB_MSG, SUB_LEN, hudUV, vec2(0.0, -0.2), subH * 0.62, subH, strokeW, txtAA);
            color = mix(color, vec3(0.9, 0.85, 0.6), subMask * pulse);
        }
    }

    color += (hash(fragCoord + iTime) - 0.5) * 0.025;

    fragColor = vec4(color, 1.0);
}

// ==== Buffer A (buffer) ====
// ===== Sandestein — BufferA : génération du labyrinthe (Phase 1) =====
// Nouveau rôle (cf. roadmap section 1.1) : BufferA ne gère plus le joueur, il génère UNE FOIS
// (à iFrame == 0) le labyrinthe 63x63 et l'écrit dans une grille de texels compressée
// (4 cellules/texel, cf. Common::mapCellRaw), puis n'y touche plus (passthrough).
//
// iChannel0 = BufferA (self) — nécessaire pour le passthrough après génération.
//
// Algorithme (2.2.1) : backtracking itératif (pile explicite `stack[]`, pas de récursion GLSL)
// sur une grille logique 31x31, "gonflée" en grille de rendu 63x63 (cellule = 2 texels, mur = 1 texel).
// Comme les threads d'un fragment shader ne partagent pas d'état pendant une même frame, la génération
// est rejouée intégralement et indépendamment par chaque texel concerné (déterministe : même seed
// partout => même résultat), qui n'en extrait que sa propre valeur. Coût borné (31*31*2 pas max par
// texel, ~993 texels concernés) : tient largement dans une seule frame (cf. 2.3).

#define MAX_STACK 1024   // >= LOGICAL_N*LOGICAL_N (961)

bool cellVisited(int visitedBits[31], int ci) {
    int word = ci >> 5;
    int bit = ci & 31;
    return ((visitedBits[word] >> bit) & 1) == 1;
}

void setVisited(inout int visitedBits[31], int ci) {
    int word = ci >> 5;
    int bit = ci & 31;
    visitedBits[word] = visitedBits[word] | (1 << bit);
}

// Rejoue tout le DFS et renvoie si la cellule de rendu `target` fait partie du "sol" creusé.
// (2.2.1 : cœur du labyrinthe — sans les salles/ouvertures/matériaux, ajoutés ensuite.)
bool mazeCarvesTarget(ivec2 target, int seed) {
    int visitedBits[31];
    for (int i = 0; i < 31; i++) visitedBits[i] = 0;

    int stack[MAX_STACK];
    stack[0] = 0; // cellule logique de départ (0,0)
    setVisited(visitedBits, 0);
    int sp = 1;

    if (target == ivec2(1, 1)) return true; // cellule de départ toujours creusée

    int dxs[4]; dxs[0] = 1; dxs[1] = -1; dxs[2] = 0; dxs[3] = 0;
    int dys[4]; dys[0] = 0; dys[1] = 0; dys[2] = 1; dys[3] = -1;

    int counter = 0;
    bool found = false;
    for (int step = 0; step < LOGICAL_N * LOGICAL_N * 2; step++) {
        if (sp <= 0) break;
        int ci = stack[sp - 1];
        int cx = ci - (ci / LOGICAL_N) * LOGICAL_N;
        int cy = ci / LOGICAL_N;

        int nbCi[4]; int nbDx[4]; int nbDy[4];
        int nbCount = 0;
        for (int k = 0; k < 4; k++) {
            int nx = cx + dxs[k];
            int ny = cy + dys[k];
            if (nx >= 0 && nx < LOGICAL_N && ny >= 0 && ny < LOGICAL_N) {
                int nci = ny * LOGICAL_N + nx;
                if (!cellVisited(visitedBits, nci)) {
                    nbCi[nbCount] = nci; nbDx[nbCount] = dxs[k]; nbDy[nbCount] = dys[k];
                    nbCount++;
                }
            }
        }

        if (nbCount == 0) {
            sp--;
            continue;
        }

        counter++;
        int pick = int(mazeHash(cx, cy, seed + counter) * float(nbCount));
        pick = min(pick, nbCount - 1);
        int nci = nbCi[pick];
        int nx = cx + nbDx[pick];
        int ny = cy + nbDy[pick];
        setVisited(visitedBits, nci);

        int rx = 2 * cx + 1; int ry = 2 * cy + 1;
        int nrx = 2 * nx + 1; int nry = 2 * ny + 1;
        int wx = (rx + nrx) / 2; int wy = (ry + nry) / 2;

        if (target == ivec2(wx, wy) || target == ivec2(nrx, nry)) found = true;

        stack[sp] = nci;
        sp++;
    }
    return found;
}

bool inRoom(ivec2 p, ivec2 lo, ivec2 hi) {
    return p.x >= lo.x && p.x <= hi.x && p.y >= lo.y && p.y <= hi.y;
}

// 2.2.4 — matériau par zone, assigné à la génération (pas au rendu).
float materialFor(ivec2 p, float baseId) {
    if (baseId != 1.0) return baseId; // sol / salle déjà tranché
    if (inRoom(p, ivec2(44, 44), ivec2(60, 60))) return 3.0; // bunker -> métal
    if (inRoom(p, ivec2(0, 0), ivec2(18, 18)))   return 4.0; // QG -> mur bleu
    return 2.0; // brique standard partout ailleurs
}

// Calcule l'ID de tuile final pour une cellule de rendu (coeur DFS + salles + ouvertures + matériaux).
float generateCellAt(ivec2 p, int seed) {
    if (p.x <= 0 || p.x >= MAP_W - 1 || p.y <= 0 || p.y >= MAP_H - 1) return 1.0; // bordure extérieure

    bool floorCell = mazeCarvesTarget(p, seed);
    float id = floorCell ? 0.0 : 1.0;

    // 2.2.2 — salles rectangulaires forcées (QG, bunker, dépôt, poste de garde), anneau de murs autour conservé.
    if (inRoom(p, ivec2(6, 6), ivec2(12, 12)))   id = 0.0; // QG (intérieur)
    if (inRoom(p, ivec2(48, 48), ivec2(58, 58))) id = 0.0; // bunker central (intérieur)
    if (inRoom(p, ivec2(6, 48), ivec2(14, 58)))  id = 0.0; // dépôt de munitions
    if (inRoom(p, ivec2(48, 6), ivec2(58, 14)))  id = 0.0; // poste de garde / cour

    // 2.2.3 — ouvertures secondaires (~5% des murs restants), pour casser l'aspect arborescent.
    if (id > 0.0 && mazeHash(p.x, p.y, seed + 9999) < 0.05) id = 0.0;

    // 2.2.4 — matériau par zone
    id = materialFor(p, id);

    return id;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    ivec2 fc = ivec2(floor(fragCoord));
    // Adressage par index linéaire (Common) : robuste même si le buffer est plus étroit que
    // MAP_TEXELS (~993) — voir la note dans Common au-dessus de texelForIndex/indexForTexel.
    int idx = indexForTexel(fc, iChannel0);

    float genDone = texelFetch(iChannel0, txGenDone(iChannel0), 0).x;
    if (iFrame > 0 && genDone > 0.5) {
        fragColor = texelFetch(iChannel0, fc, 0); // 2.3 : carte figée une fois générée
        return;
    }

    int seed = 1337; // seed fixe pour l'instant (debug) ; à faire varier (iDate) pour changer de disposition

    // ---- Grille de carte compressée (4 cellules/texel) ----
    if (idx < MAP_TEXELS) {
        vec4 packed = vec4(0.0);
        for (int channel = 0; channel < 4; channel++) {
            int cellIdx = idx * 4 + channel;
            if (cellIdx >= MAP_W * MAP_H) continue;
            int px = cellIdx - (cellIdx / MAP_W) * MAP_W;
            int py = cellIdx / MAP_W;
            float id = generateCellAt(ivec2(px, py), seed);
            float v = id / 255.0;
            if (channel == 0) packed.x = v;
            else if (channel == 1) packed.y = v;
            else if (channel == 2) packed.z = v;
            else packed.w = v;
        }
        fragColor = packed;
        return;
    }

    // ---- 2.2.5 — spawn joueur ----
    if (idx == TX_PLAYER_SPAWN_IDX) {
        fragColor = vec4(1.5, 1.5, 0.0, 0.0); // cellule de départ du DFS, toujours praticable
        return;
    }

    // ---- 4.4.7 — spawns ennemis générés dynamiquement (au lieu d'un tableau codé en dur) ----
    // On tire, pour chaque ennemi i, une cellule "sol" pseudo-aléatoire (hash déterministe sur i+seed)
    // parmi les cellules impaires de la grille logique (centres de cellule, toujours praticables côté
    // DFS), en rejetant celles trop proches du spawn joueur (case de départ du DFS, 2.2.5).
    if (idx >= TX_ENEMY_SPAWN_BASE_IDX && idx < TX_ENEMY_SPAWN_BASE_IDX + NUM_ENEMIES) {
        int i = idx - TX_ENEMY_SPAWN_BASE_IDX;
        vec2 playerSpawn = vec2(1.5, 1.5);
        vec2 chosen = vec2(31.5, 31.5); // repli : centre de la carte, toujours praticable
        for (int attempt = 0; attempt < 24; attempt++) {
            float h1 = mazeHash(i, attempt, seed + 5000);
            float h2 = mazeHash(i, attempt, seed + 6000);
            int lx = int(h1 * float(LOGICAL_N));
            int ly = int(h2 * float(LOGICAL_N));
            ivec2 p = ivec2(2 * lx + 1, 2 * ly + 1); // centre de cellule logique -> grille de rendu
            float id = generateCellAt(p, seed);
            vec2 cell = vec2(p) + 0.5;
            if (id == 0.0 && distance(cell, playerSpawn) > 10.0) {
                chosen = cell;
                break;
            }
        }
        fragColor = vec4(chosen, 0.0, 0.0);
        return;
    }

    if (idx == TX_GEN_DONE_IDX) {
        fragColor = vec4(1.0, 0.0, 0.0, 0.0); // génération marquée terminée dès cette frame
        return;
    }

    fragColor = vec4(0.0);
}

// ==== Common (common) ====
// ===== Sandestein — Common =====
// Phase 1 : constantes et fonctions partagées par tous les buffers.
// La carte n'est plus codée en dur : elle est générée dans BufferA (labyrinthe 63x63)
// et lue ici via texelFetch, ce qui permet à Image/BufferB/BufferC de partager la même
// source de vérité (plus de duplication de mapId()).

#define LOGICAL_N 31            // grille logique de cellules (impaire) avant "gonflage"
#define MAP_W 63                // grille de rendu = 2*LOGICAL_N + 1
#define MAP_H 63
#define MAP_TEXELS 993          // ceil(MAP_W*MAP_H / 4) texels pour la carte compressée (4 cellules/texel RGBA)

#define NUM_ENEMIES 12           // 4.4.7 : relevé de 5 à 12 (spawns générés dynamiquement, cf. BufferA)
#define PLAYER_RADIUS 0.35
#define ENEMY_RADIUS 0.3
#define WALK_SPEED 2.6
#define RUN_SPEED 4.6
#define ROT_SPEED 2.6
#define MOUSE_SENS 0.0035
#define ENEMY_SPEED 1.15
#define PATROL_SPEED 0.55        // 4.1 : vitesse réduite en état PATROL
#define CHASE_RANGE 9.0
#define ATTACK_RANGE 0.9
#define CONTACT_DPS 18.0
#define FIRE_RATE 0.32
#define GUN_DAMAGE 34.0
#define MAX_RANGE 14.0
#define RESPAWN_TIME 6.0
#define PLAYER_RESPAWN_TIME 2.5
#define MAX_RAY_STEPS 128       // 7.1 : relevé de 64 à 96 puis 128 — le DDA avance d'un pas par axe
                                 // franchi (pas par cellule traversée), donc une diagonale plein
                                 // cadre sur 63x63 peut demander jusqu'à ~124 pas (62 en x + 62 en y)

// --- Phase 3 : IA ennemie (§4 du roadmap) ---
#define VISION_HALF_ANGLE 0.62     // ~35°, demi-angle du cône de vision (4.2)
#define ALERT_REACT_TIME 0.4       // pause "réaction" avant de charger en CHASE (4.1)
#define SEARCH_SCAN_TIME 3.0       // durée de scan en SEARCH avant retour PATROL (4.1)
#define NOISE_RANGE 6.0            // rayon d'alerte sonore : sprint ou tir proche (4.2/4.4.5)
#define GROUP_ALERT_RANGE 7.0      // rayon d'alerte de groupe entre ennemis (4.4.6)
#define STUCK_TIME_THRESHOLD 1.0   // durée de faible progression avant de longer le mur (4.3.2)
#define TEXELS_PER_ENEMY 3         // 4.4.2 : (pos,pv,timer) / (état FSM,facing,lastKnownPos) / (waypoint,stateTimer,stuck,wallFollowSign)

#define ST_PATROL 0.0
#define ST_ALERT 1.0
#define ST_CHASE 2.0
#define ST_SEARCH 3.0
#define ST_ATTACK 4.0

// ---------- Adressage robuste des texels "table" (indépendant de la largeur du buffer) ----------
// Bug corrigé : la carte compressée (MAP_TEXELS ≈ 993) et ses texels de contrôle étaient adressés
// comme une seule ligne (`ivec2(N, 0)`), en supposant le buffer au moins aussi large que N. Si le
// canvas/preview Shadertoy est plus étroit que ça (fenêtre réduite, panneau de code large, preview
// en petite résolution...), `texelFetch` hors-texture renvoie silencieusement 0 : `BufferA` ne se
// voit alors jamais "terminé" et regénère la carte à CHAQUE frame (~7.6M pas de DFS/frame → gros
// coup de fps), et `BufferB` ne voit jamais `genDone`, restant bloqué en `GS_BOOT` (écran noir en
// permanence). Fix : les entrées sont adressées par un **index linéaire**, converti en (x,y) via la
// résolution RÉELLE du buffer cible (`textureSize`), qui utilise donc toute la hauteur disponible
// dès que la largeur ne suffit plus plutôt que de sortir du buffer.
ivec2 texelForIndex(int idx, sampler2D tex) {
    int w = max(textureSize(tex, 0).x, 1);
    return ivec2(idx - (idx / w) * w, idx / w);
}

int indexForTexel(ivec2 texel, sampler2D tex) {
    int w = max(textureSize(tex, 0).x, 1);
    return texel.y * w + texel.x;
}

// --- Texels de contrôle écrits par BufferA, juste après la grille de carte ---
#define TX_GEN_DONE_IDX (MAP_TEXELS + 0)          // 1.0 une fois la génération terminée
#define TX_PLAYER_SPAWN_IDX (MAP_TEXELS + 1)      // xy = point de spawn du joueur
#define TX_ENEMY_SPAWN_BASE_IDX (MAP_TEXELS + 2)  // + i = spawn de l'ennemi i (xy), i in [0, NUM_ENEMIES)

ivec2 txGenDone(sampler2D mapTex) { return texelForIndex(TX_GEN_DONE_IDX, mapTex); }
ivec2 txPlayerSpawn(sampler2D mapTex) { return texelForIndex(TX_PLAYER_SPAWN_IDX, mapTex); }
ivec2 txEnemySpawn(int i, sampler2D mapTex) { return texelForIndex(TX_ENEMY_SPAWN_BASE_IDX + i, mapTex); }

// --- Phase 4 (partielle) : machine à états de jeu, stockée par BufferB dans son propre texel ---
#define TX_GAME_STATE ivec2(8, 0)  // x = gameState, y = wasInputDown (edge detect), z/w réservés
#define GS_BOOT 0.0      // génération carte/décor en cours, écran masqué
#define GS_INTRO 1.0     // écran titre, simulation gelée, en attente d'un clic/touche
#define GS_PLAYING 2.0   // partie en cours
#define GS_PAUSED 3.0    // pause (touche P/Echap)
#define GS_GAMEOVER 4.0  // joueur mort définitivement, en attente de retour à l'INTRO
#define GS_VICTORY 5.0   // objectif atteint, en attente de retour à l'INTRO

// --- Phase 5 : objectif de jeu (6.2) ---
#define TARGET_KILLS 15.0        // score à atteindre pour gagner
#define OBJECTIVE_POS vec2(9.0, 9.0)  // centre de la salle QG (roadmap 2.2.2 : (6,6)-(12,12))
#define OBJECTIVE_RADIUS 3.0     // distance (cellules) pour valider "a atteint le QG"

#define PI 3.14159265359

// --- Phase 2 : décor / props (§3 du roadmap), générés une fois par BufferD ---
#define MAX_PROPS 128         // 3.2.2 : table de taille fixe
#define PROP_NONE 0.0
#define PROP_SANDBAG 1.0      // sacs de sable (autour des zones stratégiques)
#define PROP_BARBWIRE 2.0     // barbelés (bords extérieurs de la carte)
#define PROP_CRATE 3.0        // caisses de munitions (grandes salles)
#define PROP_BARREL 4.0       // barils/tonneaux (dépôt)
#define PROP_POSTER 5.0       // panneau/affiche (couloirs intérieurs)
#define PROP_RUBBLE 6.0       // gravats (zones "bombardées")
#define PROP_JERRICAN 7.0     // jerricans (dispersés)
#define PROP_MIRADOR 8.0      // tourelle de guet / mirador (cour du poste de garde)
#define TX_PROP_BASE 0        // props stockés aux texels [0, MAX_PROPS) de BufferD, format (type,x,y,variant)

// --- Phase 3 : événement joueur -> IA, écrit par BufferB, lu par BufferC (même frame, C après B) ---
#define TX_PLAYER_AI_EVENT ivec2(9, 0) // x=bruyant(sprint/tir proche 0-1), y=indexCibleTouchée(-1 sinon), z=dégâts infligés, w=réservé
// --- Phase 3 : retour IA -> joueur, écrit par BufferC, lu par BufferB (frame suivante, C tourne après B) ---
#define TX_AI_CONTROL ivec2(NUM_ENEMIES * TEXELS_PER_ENEMY, 0) // x=dégâts au joueur ce tick, y=nb ennemis vivants, z/w réservés

// ---------- Hash / bruit ----------
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Hash entier déterministe utilisé par le générateur de labyrinthe (BufferA).
// Arithmétique en uint pour rester dans un comportement défini (pas d'overflow signé).
float mazeHash(int x, int y, int seed) {
    uint ux = uint(x) * 374761393u + uint(y) * 668265263u + uint(seed) * 2246822519u;
    ux = (ux ^ (ux >> 13u)) * 1274126177u;
    ux = ux ^ (ux >> 16u);
    return float(ux & 0xFFFFFFu) / float(0xFFFFFFu);
}

// (keyDown() a été déplacée dans BufferB : le tab Common de Shadertoy est validé isolément, sans
// iChannel qui lui soit propre, donc une référence directe à `iChannel0` ici fait échouer sa
// compilation — contrairement à mapId/resolveCollision/raycastWallDist/hasLineOfSight ci-dessous,
// qui reçoivent leur sampler2D en paramètre et n'ont donc pas ce problème.)

// ---------- Lecture de la carte compressée (1.3 : 4 cellules par texel RGBA) ----------
int mapCellRaw(ivec2 p, sampler2D mapTex) {
    int idx = p.y * MAP_W + p.x;
    int texelIdx = idx / 4;
    ivec2 texel = texelForIndex(texelIdx, mapTex);
    vec4 packed = texelFetch(mapTex, texel, 0);
    int channel = idx - texelIdx * 4;
    float v = (channel == 0) ? packed.x : (channel == 1) ? packed.y : (channel == 2) ? packed.z : packed.w;
    return int(v * 255.0 + 0.5);
}

float mapId(ivec2 p, sampler2D mapTex) {
    if (p.x <= 0 || p.x >= MAP_W - 1 || p.y <= 0 || p.y >= MAP_H - 1) return 1.0;
    return float(mapCellRaw(p, mapTex));
}

// ---------- Collision cercle vs cellules pleines (2.2.6) ----------
vec2 resolveCollision(vec2 p, float radius, sampler2D mapTex) {
    ivec2 ip = ivec2(floor(p));
    for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
            ivec2 cell = ip + ivec2(dx, dy);
            if (mapId(cell, mapTex) > 0.0) {
                vec2 nearest = clamp(p, vec2(cell), vec2(cell) + 1.0);
                vec2 delta = p - nearest;
                float dist = length(delta);
                if (dist < radius && dist > 0.0001) {
                    p += (delta / dist) * (radius - dist);
                }
            }
        }
    }
    return p;
}

// ---------- DDA générique (4.4.1 : factorisation réutilisée par tir / LOS / rendu) ----------
// Retourne la distance le long de `dir` (normalisé) jusqu'au mur touché.
// outSide = 0 si mur vertical (touché en X), 1 si horizontal (touché en Y).
// outWallType = ID de la tuile touchée (2.2.6 : lu depuis `mapTex`, plus de fonction en dur).
float raycastWallDist(vec2 origin, vec2 dir, sampler2D mapTex, out int outSide, out float outWallType) {
    ivec2 mapPos = ivec2(floor(origin));
    vec2 deltaDist = abs(vec2(length(dir)) / dir);
    ivec2 stepDir = ivec2(sign(dir));
    vec2 sideDist = (sign(dir) * (vec2(mapPos) - origin) + (sign(dir) * 0.5 + 0.5)) * deltaDist;

    int side = 0;
    float wallType = 0.0;
    for (int i = 0; i < MAX_RAY_STEPS; i++) {
        if (sideDist.x < sideDist.y) {
            sideDist.x += deltaDist.x;
            mapPos.x += stepDir.x;
            side = 0;
        } else {
            sideDist.y += deltaDist.y;
            mapPos.y += stepDir.y;
            side = 1;
        }
        wallType = mapId(mapPos, mapTex);
        if (wallType > 0.0) break;
    }
    outSide = side;
    outWallType = wallType;
    return (side == 0) ?
        (float(mapPos.x) - origin.x + (1.0 - float(stepDir.x)) * 0.5) / dir.x :
        (float(mapPos.y) - origin.y + (1.0 - float(stepDir.y)) * 0.5) / dir.y;
}

float centerRayWallDist(vec2 origin, float angle, sampler2D mapTex) {
    int side; float wt;
    return raycastWallDist(origin, vec2(cos(angle), sin(angle)), mapTex, side, wt);
}

// Ligne de vue directe entre deux points (Phase 3 - IA), bornée par MAX_RAY_STEPS.
bool hasLineOfSight(vec2 a, vec2 b, sampler2D mapTex) {
    vec2 dir = b - a;
    float dist = length(dir);
    if (dist < 0.0001) return true;
    dir /= dist;
    int side; float wt;
    float wallDist = raycastWallDist(a, dir, mapTex, side, wt);
    return wallDist > dist;
}

// 4.2 : cône de vision — `facing` en radians, `halfAngle` en radians.
bool inVisionCone(vec2 enemyPos, float facing, vec2 target, float halfAngle) {
    vec2 toTarget = target - enemyPos;
    if (dot(toTarget, toTarget) < 0.0001) return true;
    toTarget = normalize(toTarget);
    float ang = acos(clamp(dot(vec2(cos(facing), sin(facing)), toTarget), -1.0, 1.0));
    return ang < halfAngle;
}

// 4.3 (simplifié) : direction de déplacement court-terme vers `target`, en évitant les murs proches
// et en longeant le mur quand `wallFollow` est actif (échappe aux coins où le direct vers la cible
// est bloqué). Remplace un flow-field global (trop coûteux à maintenir en O(cellules) par frame côté
// GLSL) par un steering local à 8 directions candidates, bon marché (quelques raycasts courts) et
// suffisant pour ne plus traverser les murs / rester scotché dans un angle.
vec2 steerTowards(vec2 pos, vec2 target, sampler2D mapTex, bool wallFollow, float wallFollowSign) {
    vec2 desired = target - pos;
    float d = length(desired);
    if (d < 0.0001) return vec2(0.0);
    desired /= d;

    if (wallFollow) {
        // Tangente au mur le plus proche : on tourne desired de ±90° et on garde ce cap
        // jusqu'à ce que le suivi de mur libère à nouveau un chemin direct (géré par l'appelant).
        float s = wallFollowSign;
        return vec2(-desired.y * s, desired.x * s);
    }

    float offsets[7];
    offsets[0] = 0.0; offsets[1] = 0.5; offsets[2] = -0.5; offsets[3] = 1.0;
    offsets[4] = -1.0; offsets[5] = 1.6; offsets[6] = -1.6;
    float baseAngle = atan(desired.y, desired.x);
    float clearance = ENEMY_RADIUS + 0.35;

    for (int k = 0; k < 7; k++) {
        float a = baseAngle + offsets[k];
        vec2 dir = vec2(cos(a), sin(a));
        int side; float wt;
        float wd = raycastWallDist(pos, dir, mapTex, side, wt);
        if (wd > clearance) return dir;
    }
    return desired; // tout est bloqué à courte distance : avance quand même, resolveCollision freinera
}

// ==== Buffer B (buffer) ====
// ===== Sandestein — BufferB : état joueur + machine à états du jeu =====
// Phase 3 (roadmap §1.1) : les ennemis (position/PV/FSM) ont déménagé dans BufferC, qui est
// maintenant leur source de vérité. BufferB ne fait plus que :
//   - gérer le joueur (déplacement, tir, vie, score) et la machine à états du jeu (Phase 4 partielle) ;
//   - sélectionner la cible du tir en lisant les positions/PV des ennemis dans BufferC (iChannel3) ;
//   - publier un petit "événement joueur" pour l'IA (TX_PLAYER_AI_EVENT, Common) : bruit
//     (sprint/tir) et résultat du tir (cible touchée + dégâts), lu par BufferC la même frame
//     (BufferC s'exécute après BufferB) ;
//   - encaisser les dégâts de contact infligés par les ennemis, publiés par BufferC dans
//     TX_AI_CONTROL — lu ici avec un retard d'une frame (BufferC tourne après BufferB dans l'ordre
//     des passes), ce qui est sans conséquence pour un dégât continu (tick de dt).
//
// iChannel0 = Keyboard
// iChannel1 = BufferA (carte générée + spawns)
// iChannel2 = BufferB (self)
// iChannel3 = BufferC (ennemis : ciblage du tir + dégâts de contact subis)

// Déplacée depuis Common (voir note là-bas) : référence directe à iChannel0, valable seulement ici.
bool keyDown(int code) {
    return texelFetch(iChannel0, ivec2(code, 0), 0).x > 0.5;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 s0 = texelFetch(iChannel2, ivec2(0, 0), 0);
    vec4 s1 = texelFetch(iChannel2, ivec2(1, 0), 0);
    vec4 s2 = texelFetch(iChannel2, ivec2(2, 0), 0);
    vec4 gs = texelFetch(iChannel2, TX_GAME_STATE, 0);

    vec2 pos = s0.xy;
    float angle = s0.z;
    float bobPhase = s0.w;

    float bobAmt = s1.x;
    float prevMouseX = s1.y;
    float playerHealth = s1.z;
    float fireCooldown = s1.w;

    float prevMouseDown = s2.x;
    float score = s2.y;
    float muzzleFlashTimer = s2.z;
    float playerDeathTimer = s2.w;

    float gameState = gs.x;
    float prevConfirmDown = gs.y;
    float prevPauseDown = gs.z;

    if (iFrame < 1) {
        vec4 playerSpawn = texelFetch(iChannel1, txPlayerSpawn(iChannel1), 0);
        pos = playerSpawn.xy;
        angle = 0.0;
        bobPhase = 0.0;
        bobAmt = 0.0;
        prevMouseX = iMouse.x;
        playerHealth = 100.0;
        fireCooldown = 0.0;
        prevMouseDown = 0.0;
        score = 0.0;
        muzzleFlashTimer = 0.0;
        playerDeathTimer = 0.0;
        gameState = GS_BOOT;
        prevConfirmDown = 0.0;
        prevPauseDown = 0.0;
    }

    float dt = min(iTimeDelta, 0.05);
    if (dt <= 0.0) dt = 0.016;

    // ---- 5.1 : entrées génériques pour les transitions d'état (confirm = clic/espace/entrée) ----
    bool confirmDown = iMouse.z > 0.0 || keyDown(32) || keyDown(13);
    bool confirmPressed = confirmDown && prevConfirmDown < 0.5;
    bool pauseDown = keyDown(80) || keyDown(27); // P / Echap
    bool pausePressed = pauseDown && prevPauseDown < 0.5;

    // ---- BOOT -> INTRO : dès que la génération de carte (BufferA) est terminée ----
    if (gameState == GS_BOOT) {
        float genDone = texelFetch(iChannel1, txGenDone(iChannel1), 0).x;
        if (genDone > 0.5) gameState = GS_INTRO;
    } else if (gameState == GS_INTRO) {
        if (confirmPressed) gameState = GS_PLAYING;
    } else if (gameState == GS_PLAYING) {
        if (pausePressed) gameState = GS_PAUSED;
    } else if (gameState == GS_PAUSED) {
        if (pausePressed) gameState = GS_PLAYING;
    } else if (gameState == GS_GAMEOVER || gameState == GS_VICTORY) {
        playerDeathTimer += dt;
        if (playerDeathTimer > PLAYER_RESPAWN_TIME && confirmPressed) {
            // 5.1 : "Rejouer" — nouvelle partie complète (position, vie, score). Les ennemis se
            // réinitialisent eux-mêmes côté BufferC en lisant ce même gameState (voir BufferC).
            vec4 playerSpawn = texelFetch(iChannel1, txPlayerSpawn(iChannel1), 0);
            pos = playerSpawn.xy;
            angle = 0.0;
            playerHealth = 100.0;
            score = 0.0;
            playerDeathTimer = 0.0;
            gameState = GS_INTRO;
        }
    }

    prevConfirmDown = confirmDown ? 1.0 : 0.0;
    prevPauseDown = pauseDown ? 1.0 : 0.0;

    bool simActive = (gameState == GS_PLAYING);
    bool alive = playerHealth > 0.0;

    if (simActive) {
        if (alive) {
            if (keyDown(37)) angle -= ROT_SPEED * dt;
            if (keyDown(39)) angle += ROT_SPEED * dt;
            if (iMouse.z > 0.0) angle += (iMouse.x - prevMouseX) * MOUSE_SENS;
        }
    }
    prevMouseX = iMouse.x;

    float forward = 0.0;
    float strafe = 0.0;
    if (simActive && alive) {
        if (keyDown(87) || keyDown(90) || keyDown(38)) forward += 1.0;
        if (keyDown(83) || keyDown(40)) forward -= 1.0;
        if (keyDown(68)) strafe += 1.0;
        if (keyDown(65) || keyDown(81)) strafe -= 1.0;
    }

    bool running = keyDown(16);
    float speed = running ? RUN_SPEED : WALK_SPEED;
    bool moving = (forward != 0.0 || strafe != 0.0);

    if (simActive && moving) {
        float len = length(vec2(forward, strafe));
        forward /= len;
        strafe /= len;
        vec2 dirV = vec2(cos(angle), sin(angle));
        vec2 rightV = vec2(-dirV.y, dirV.x);
        vec2 delta = (dirV * forward + rightV * strafe) * speed * dt;
        pos = resolveCollision(pos + vec2(delta.x, 0.0), PLAYER_RADIUS, iChannel1);
        pos = resolveCollision(pos + vec2(0.0, delta.y), PLAYER_RADIUS, iChannel1);
    }

    if (simActive) {
        bobAmt += ((moving ? 1.0 : 0.0) - bobAmt) * min(1.0, dt * 8.0);
        if (moving) bobPhase += dt * speed * 3.2;
    }

    bool mouseDownNow = iMouse.z > 0.0;
    if (simActive) {
        fireCooldown = max(0.0, fireCooldown - dt);
        muzzleFlashTimer = max(0.0, muzzleFlashTimer - dt);
    }

    // ---- 4.4.5 : événement à destination de l'IA (bruit + résultat du tir) ----
    int hitTargetIdx = -1;
    float hitDamage = 0.0;
    bool justFired = false;

    if (simActive && alive && mouseDownNow && prevMouseDown < 0.5 && fireCooldown <= 0.0) {
        fireCooldown = FIRE_RATE;
        muzzleFlashTimer = 0.12;
        justFired = true;
        vec2 dirV = vec2(cos(angle), sin(angle));
        vec2 rightV = vec2(-dirV.y, dirV.x);
        float wallDist = centerRayWallDist(pos, angle, iChannel1);
        int bestIdx = -1;
        float bestDist = MAX_RANGE;
        for (int k = 0; k < NUM_ENEMIES; k++) {
            vec4 ek = texelFetch(iChannel3, ivec2(k * TEXELS_PER_ENEMY + 0, 0), 0);
            if (ek.z <= 0.0) continue;
            vec2 rel = ek.xy - pos;
            float f = dot(rel, dirV);
            float sdv = dot(rel, rightV);
            if (f > 0.15 && f < wallDist && f < bestDist && abs(sdv) < 0.4) {
                bestDist = f;
                bestIdx = k;
            }
        }
        if (bestIdx >= 0) {
            hitTargetIdx = bestIdx;
            hitDamage = GUN_DAMAGE;
            vec4 targetEnemy = texelFetch(iChannel3, ivec2(bestIdx * TEXELS_PER_ENEMY + 0, 0), 0);
            if (targetEnemy.z - GUN_DAMAGE <= 0.0) score += 1.0; // prédiction déterministe, cf. BufferC
        }
    }
    prevMouseDown = mouseDownNow ? 1.0 : 0.0;

    bool noisy = simActive && ((running && moving) || justFired);

    // ---- 4.4 : dégâts de contact reçus des ennemis (agrégés par BufferC, TX_AI_CONTROL, frame précédente) ----
    if (simActive && alive) {
        float damageFromEnemies = texelFetch(iChannel3, TX_AI_CONTROL, 0).x;
        playerHealth = max(0.0, playerHealth - damageFromEnemies);
    }
    alive = playerHealth > 0.0;

    if (simActive && !alive) {
        gameState = GS_GAMEOVER;
        playerDeathTimer = 0.0;
    } else if (simActive && alive && (score >= TARGET_KILLS || distance(pos, OBJECTIVE_POS) < OBJECTIVE_RADIUS)) {
        // 6.2 : objectif — N eliminations OU atteindre le QG en vie.
        gameState = GS_VICTORY;
        playerDeathTimer = 0.0;
    }

    ivec2 fc = ivec2(floor(fragCoord));
    if (fc.y == 0 && fc.x == 0) {
        fragColor = vec4(pos, angle, bobPhase);
    } else if (fc.y == 0 && fc.x == 1) {
        fragColor = vec4(bobAmt, prevMouseX, playerHealth, fireCooldown);
    } else if (fc.y == 0 && fc.x == 2) {
        fragColor = vec4(prevMouseDown, score, muzzleFlashTimer, playerDeathTimer);
    } else if (fc == TX_GAME_STATE) {
        fragColor = vec4(gameState, prevConfirmDown, prevPauseDown, 0.0);
    } else if (fc == TX_PLAYER_AI_EVENT) {
        fragColor = vec4(noisy ? 1.0 : 0.0, float(hitTargetIdx), hitDamage, 0.0);
    } else {
        fragColor = vec4(0.0);
    }
}

// ==== Buffer C (buffer) ====
// ===== Sandestein — BufferC : état + IA des ennemis (Phase 3, roadmap §4) =====
// BufferC devient la source de vérité des ennemis (déplacée depuis BufferB, cf. roadmap §1.1) :
// position, PV, état de la FSM (PATROL/ALERT/CHASE/SEARCH/ATTACK), direction du regard, dernière
// position connue du joueur, index de waypoint de patrouille, et un petit état de "suivi de mur"
// anti-blocage. Format (4.4.2) : TEXELS_PER_ENEMY (3) texels par ennemi :
//   T0 = (pos.x, pos.y, pv, timerÉvénement)         — timerÉvénement = temps depuis le dernier coup
//                                                       reçu (vivant) ou depuis la mort (mort)
//   T1 = (fsmState, facing, lastKnownPlayerPos.x, lastKnownPlayerPos.y)
//   T2 = (waypointIndex, stateTimer, stuckTimer, wallFollowSign)
// + un texel de contrôle TX_AI_CONTROL : (dégâts infligés au joueur ce tick, nb d'ennemis vivants, -, -)
//
// Coût : comme pour BufferA (2.2.1), le calcul "lourd" (LOS/steering, plusieurs raycasts courts) est
// gardé par un test sur `fc` : seuls les NUM_ENEMIES*TEXELS_PER_ENEMY + 1 texels utiles exécutent la
// mise à jour complète d'un ennemi (recalculée en triple redondance, une fois par texel de sortie —
// bon marché vu le nombre d'ennemis). Tous les autres pixels du buffer retournent immédiatement :
// le coût est donc indépendant de la résolution d'écran, à l'inverse d'un calcul en tête de fonction
// comme BufferB (acceptable là-bas car sans raycast lourd par ennemi).
//
// Pathfinding (4.3) : un flow-field global BFS recalculé en continu serait le plus "correct", mais son
// coût (propagation sur ~4000 cellules) est disproportionné ici vu le nombre d'ennemis réellement actifs
// à la fois. On lui préfère un steering local à courte portée (Common::steerTowards, 7 directions
// candidates testées par raycast court) + une détection de blocage (stuckTimer) qui bascule
// temporairement en "suivi de mur" pour s'échapper d'un cul-de-sac — comportement robuste sur un
// labyrinthe qui contient des boucles (2.2.3), au prix de trajets parfois sous-optimaux plutôt
// qu'un plus court chemin garanti.
//
// iChannel0 = BufferA (carte générée, spawns)
// iChannel1 = BufferB (état joueur : pos/angle, health, gameState, événement de tir/bruit)
// iChannel2 = BufferC (self)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    ivec2 fc = ivec2(floor(fragCoord));

    int totalTexels = NUM_ENEMIES * TEXELS_PER_ENEMY;
    bool isEnemyTexel = (fc.y == 0 && fc.x < totalTexels);
    bool isControlTexel = (fc == TX_AI_CONTROL);
    if (!isEnemyTexel && !isControlTexel) {
        fragColor = vec4(0.0);
        return;
    }

    int i = isEnemyTexel ? (fc.x / TEXELS_PER_ENEMY) : 0;
    int slot = isEnemyTexel ? (fc.x - i * TEXELS_PER_ENEMY) : 0;
    int base = i * TEXELS_PER_ENEMY;

    // ---- lecture de l'état courant de l'ennemi i ----
    vec4 t0 = texelFetch(iChannel2, ivec2(base + 0, 0), 0);
    vec4 t1 = texelFetch(iChannel2, ivec2(base + 1, 0), 0);
    vec4 t2 = texelFetch(iChannel2, ivec2(base + 2, 0), 0);

    vec2 pos = t0.xy;
    float health = t0.z;
    float eventTimer = t0.w;

    float fsmState = t1.x;
    float facing = t1.y;
    vec2 lastKnownPlayerPos = t1.zw;

    float waypointIndex = t2.x;
    float stateTimer = t2.y;
    float stuckTimer = t2.z;
    float wallFollowSign = t2.w;

    // ---- état du joueur (BufferB, même frame : B tourne avant C) ----
    vec4 pState0 = texelFetch(iChannel1, ivec2(0, 0), 0);
    vec4 pState1 = texelFetch(iChannel1, ivec2(1, 0), 0);
    vec4 aiEvent = texelFetch(iChannel1, TX_PLAYER_AI_EVENT, 0);
    float gameState = texelFetch(iChannel1, TX_GAME_STATE, 0).x;

    vec2 playerPos = pState0.xy;
    float playerHealth = pState1.z;
    bool playerAlive = playerHealth > 0.0;
    bool noisy = aiEvent.x > 0.5;
    int hitTargetIdx = int(aiEvent.y);
    float hitDamage = aiEvent.z;

    bool simActive = (gameState == GS_PLAYING);

    float dt = min(iTimeDelta, 0.05);
    if (dt <= 0.0) dt = 0.016;

    if (iFrame < 1) {
        vec4 espawn = texelFetch(iChannel0, txEnemySpawn(i, iChannel0), 0);
        pos = espawn.xy;
        health = 100.0;
        eventTimer = 0.0;
        fsmState = ST_PATROL;
        facing = mazeHash(i, 7, 42) * 6.2831853;
        lastKnownPlayerPos = pos;
        waypointIndex = 0.0;
        stateTimer = 0.0;
        stuckTimer = 0.0;
        wallFollowSign = (mazeHash(i, 3, 99) < 0.5) ? -1.0 : 1.0;
    } else if (simActive) {
        // ---- dégâts reçus ce tick (BufferB a choisi sa cible en lisant notre frame précédente) ----
        if (health > 0.0 && hitTargetIdx == i) {
            health -= hitDamage;
            eventTimer = 0.0; // relance le flash de coup encaissé
        }

        eventTimer += dt;

        if (health <= 0.0) {
            // Mort : plus de FSM, juste le décompte avant respawn (Image.txt gère l'animation/cleanup).
            if (eventTimer > RESPAWN_TIME) {
                vec4 espawn = texelFetch(iChannel0, txEnemySpawn(i, iChannel0), 0);
                pos = espawn.xy;
                health = 100.0;
                eventTimer = 0.0;
                fsmState = ST_PATROL;
                stateTimer = 0.0;
                stuckTimer = 0.0;
            }
        } else {
            // ---- 4.2 : perception ----
            float distToPlayer = distance(pos, playerPos);
            bool los = playerAlive && hasLineOfSight(pos, playerPos, iChannel0);
            bool seesPlayer = los && distToPlayer < CHASE_RANGE &&
                (inVisionCone(pos, facing, playerPos, VISION_HALF_ANGLE) || (noisy && distToPlayer < NOISE_RANGE));
            bool hearsPlayer = playerAlive && noisy && distToPlayer < NOISE_RANGE;

            // ---- 4.4.6 : alerte de groupe — un ennemi en CHASE avec LOS sur un ennemi patrouillant/alerté le réveille ----
            bool groupAlerted = false;
            if (fsmState == ST_PATROL || fsmState == ST_ALERT) {
                for (int k = 0; k < NUM_ENEMIES; k++) {
                    if (k == i) continue;
                    vec4 ok0 = texelFetch(iChannel2, ivec2(k * TEXELS_PER_ENEMY + 0, 0), 0);
                    vec4 ok1 = texelFetch(iChannel2, ivec2(k * TEXELS_PER_ENEMY + 1, 0), 0);
                    if (ok0.z <= 0.0 || ok1.x != ST_CHASE) continue;
                    if (distance(pos, ok0.xy) < GROUP_ALERT_RANGE && hasLineOfSight(pos, ok0.xy, iChannel0)) {
                        groupAlerted = true;
                        break;
                    }
                }
            }

            stateTimer += dt;

            // ---- 4.1 : transitions de la FSM ----
            if (fsmState == ST_PATROL) {
                if (seesPlayer || hearsPlayer || groupAlerted) {
                    fsmState = ST_ALERT;
                    stateTimer = 0.0;
                    lastKnownPlayerPos = playerPos;
                }
            } else if (fsmState == ST_ALERT) {
                if (seesPlayer) lastKnownPlayerPos = playerPos;
                if (stateTimer > ALERT_REACT_TIME) {
                    fsmState = ST_CHASE;
                    stateTimer = 0.0;
                }
            } else if (fsmState == ST_CHASE) {
                if (seesPlayer) {
                    lastKnownPlayerPos = playerPos;
                    if (distToPlayer < ATTACK_RANGE) {
                        fsmState = ST_ATTACK;
                        stateTimer = 0.0;
                    }
                } else if (!hearsPlayer) {
                    fsmState = ST_SEARCH;
                    stateTimer = 0.0;
                }
            } else if (fsmState == ST_ATTACK) {
                if (distToPlayer > ATTACK_RANGE * 1.3 || !playerAlive) {
                    fsmState = seesPlayer ? ST_CHASE : ST_SEARCH;
                    stateTimer = 0.0;
                } else if (seesPlayer) {
                    lastKnownPlayerPos = playerPos;
                }
            } else if (fsmState == ST_SEARCH) {
                if (seesPlayer) {
                    fsmState = ST_CHASE;
                    stateTimer = 0.0;
                    lastKnownPlayerPos = playerPos;
                } else if (distance(pos, lastKnownPlayerPos) < 0.6) {
                    // arrivé sur la dernière position connue : scanne, puis abandonne
                    if (stateTimer > SEARCH_SCAN_TIME) {
                        fsmState = ST_PATROL;
                        stateTimer = 0.0;
                        waypointIndex += 1.0;
                    }
                }
            }

            // ---- déplacement selon l'état ----
            vec2 target = pos;
            float moveSpeed = 0.0;
            bool wantMove = true;
            if (fsmState == ST_PATROL) {
                // 2-4 points de patrouille autour du spawn, dérivés par hash (pas de stockage supplémentaire).
                vec4 espawn = texelFetch(iChannel0, txEnemySpawn(i, iChannel0), 0);
                int wp = int(mod(waypointIndex, 3.0));
                float wa = mazeHash(i, wp * 11 + 1, 17) * 6.2831853;
                float wr = 2.0 + mazeHash(i, wp * 11 + 2, 19) * 2.5;
                target = espawn.xy + vec2(cos(wa), sin(wa)) * wr;
                moveSpeed = PATROL_SPEED;
                if (distance(pos, target) < 0.5) waypointIndex += 1.0;
            } else if (fsmState == ST_ALERT) {
                wantMove = false; // pause de réaction, tourne vers la cible (facing géré plus bas)
            } else if (fsmState == ST_CHASE) {
                target = seesPlayer ? playerPos : lastKnownPlayerPos;
                moveSpeed = ENEMY_SPEED;
            } else if (fsmState == ST_SEARCH) {
                target = lastKnownPlayerPos;
                moveSpeed = ENEMY_SPEED * 0.7;
                if (distance(pos, lastKnownPlayerPos) < 0.6) wantMove = false; // scan sur place
            } else if (fsmState == ST_ATTACK) {
                wantMove = false;
            }

            if (wantMove && moveSpeed > 0.0) {
                bool wallFollow = stuckTimer > STUCK_TIME_THRESHOLD;
                vec2 dir = steerTowards(pos, target, iChannel0, wallFollow, wallFollowSign);
                vec2 beforeMove = pos;
                vec2 moved = resolveCollision(pos + dir * moveSpeed * dt, ENEMY_RADIUS, iChannel0);
                float actualMove = distance(moved, beforeMove);
                float intendedMove = moveSpeed * dt;
                if (intendedMove > 0.001 && actualMove < intendedMove * 0.25) {
                    stuckTimer += dt;
                } else {
                    stuckTimer = max(0.0, stuckTimer - dt * 2.0);
                }
                pos = moved;
                if (length(moved - beforeMove) > 0.001) facing = atan(moved.y - beforeMove.y, moved.x - beforeMove.x);
            } else {
                stuckTimer = max(0.0, stuckTimer - dt * 2.0);
                if (fsmState == ST_SEARCH) {
                    facing += dt * 1.8; // scan sur place (4.1 : "rotation sur place")
                } else if (distance(target, pos) > 0.01 && (fsmState == ST_ALERT || fsmState == ST_ATTACK)) {
                    vec2 toTarget = target - pos;
                    facing = atan(toTarget.y, toTarget.x);
                }
            }
            // Les dégâts au contact (ST_ATTACK à portée) sont agrégés une seule fois, dans le
            // texel de contrôle plus bas, plutôt que recalculés ici pour chacun des 3 texels de l'ennemi.
        }
    }

    // ---- écriture de l'état mis à jour (les 3 texels partagent le même calcul ci-dessus) ----
    if (isEnemyTexel) {
        if (slot == 0) fragColor = vec4(pos, health, eventTimer);
        else if (slot == 1) fragColor = vec4(fsmState, facing, lastKnownPlayerPos);
        else fragColor = vec4(waypointIndex, stateTimer, stuckTimer, wallFollowSign);
        return;
    }

    // ---- texel de contrôle : agrège dégâts au joueur + nb d'ennemis vivants ce tick ----
    // 6.5 : on retient aussi le relèvement (bearing) monde vers l'un des attaquants de ce tick,
    // pour que `Image` puisse afficher un flash de dégâts directionnel plutôt qu'une vignette globale.
    float totalDamage = 0.0;
    float aliveCount = 0.0;
    float attackerBearing = 0.0;
    float underAttack = 0.0;
    if (simActive) {
        for (int k = 0; k < NUM_ENEMIES; k++) {
            vec4 ok0 = texelFetch(iChannel2, ivec2(k * TEXELS_PER_ENEMY + 0, 0), 0);
            vec4 ok1 = texelFetch(iChannel2, ivec2(k * TEXELS_PER_ENEMY + 1, 0), 0);
            if (ok0.z <= 0.0) continue;
            aliveCount += 1.0;
            if (ok1.x == ST_ATTACK && playerAlive && distance(ok0.xy, playerPos) <= ATTACK_RANGE) {
                totalDamage += CONTACT_DPS * dt;
                if (underAttack < 0.5) {
                    vec2 rel = ok0.xy - playerPos;
                    attackerBearing = atan(rel.y, rel.x);
                    underAttack = 1.0;
                }
            }
        }
    }
    fragColor = vec4(totalDamage, aliveCount, attackerBearing, underAttack);
}

// ==== Buffer D (buffer) ====
// ===== Sandestein — BufferD : décor / props (Phase 2, roadmap §3) =====
// Génère UNE FOIS (à iFrame < 1, la carte de BufferA étant déjà prête cette même frame puisque
// l'ordre des passes est A→B→C→D→Image) une table fixe de MAX_PROPS (Common) éléments de décor
// thématiques "front européen 1939-45" (3.1), puis n'y touche plus (passthrough), exactement comme
// BufferA fige sa carte après génération (2.3).
//
// Format (3.2.2) : un texel par prop, à l'index `slot` = adresse du texel = (type, x, y, variant).
// `type = PROP_NONE` (0) si aucun emplacement valide n'a été trouvé pour ce slot (aucun prop dessiné
// par Image dans ce cas). Comme pour les spawns d'ennemis (BufferA, 4.4.7), chaque slot "rejoue"
// indépendamment une recherche déterministe (hash(slot, essai)) parmi des cellules candidates
// répondant à la règle de placement de son type — aucune coordination entre threads nécessaire.
//
// Simplification assumée (documentée en 3.3 du roadmap) : les props sont purement décoratifs, sans
// collision avec le joueur ni les ennemis. Ça garantit trivialement qu'aucun prop ne bloque un
// passage obligé, au prix d'un léger risque de clipping visuel (joueur/ennemi traversant un sac de
// sable) — acceptable pour du décor, et évite d'ajouter un canal iChannel supplémentaire à
// BufferB/BufferC (déjà à leur limite de 4 canaux) pour un budget gameplay marginal.
//
// iChannel0 = BufferA (carte générée, spawns)
// iChannel1 = BufferD (self, pour le passthrough après génération)

bool inRoom(ivec2 p, ivec2 lo, ivec2 hi) {
    return p.x >= lo.x && p.x <= hi.x && p.y >= lo.y && p.y <= hi.y;
}

// Rectangles des salles thématiques — dupliqués depuis BufferA::generateCellAt (2.2.2) : BufferD
// n'a pas accès aux fonctions locales de BufferA, donc on reproduit ici les mêmes coordonnées.
#define ROOM_QG_LO ivec2(6, 6)
#define ROOM_QG_HI ivec2(12, 12)
#define ROOM_BUNKER_LO ivec2(48, 48)
#define ROOM_BUNKER_HI ivec2(58, 58)
#define ROOM_DEPOT_LO ivec2(6, 48)
#define ROOM_DEPOT_HI ivec2(14, 58)
#define ROOM_POSTE_LO ivec2(48, 6)
#define ROOM_POSTE_HI ivec2(58, 14)

bool isFloor(ivec2 p, sampler2D mapTex) {
    return mapId(p, mapTex) == 0.0;
}

bool nearWallMaterial(ivec2 p, float matId, sampler2D mapTex) {
    return mapId(p + ivec2(1, 0), mapTex) == matId || mapId(p + ivec2(-1, 0), mapTex) == matId ||
           mapId(p + ivec2(0, 1), mapTex) == matId || mapId(p + ivec2(0, -1), mapTex) == matId;
}

bool nearAnyWall(ivec2 p, sampler2D mapTex) {
    return mapId(p + ivec2(1, 0), mapTex) > 0.0 || mapId(p + ivec2(-1, 0), mapTex) > 0.0 ||
           mapId(p + ivec2(0, 1), mapTex) > 0.0 || mapId(p + ivec2(0, -1), mapTex) > 0.0;
}

// 3.1 : détermine le type de prop associé à un slot (plage fixe par type) et sa règle de placement.
// Retourne vec4(type, x, y, variant), type == PROP_NONE si aucune cellule valide trouvée.
vec4 generatePropAt(int slot, sampler2D mapTex, vec2 playerSpawn) {
    float type = PROP_NONE;
    ivec2 roomLo = ivec2(0), roomHi = ivec2(0);
    bool restrictToRoom = false;
    float wallMatFilter = -1.0; // >=0 : exige un mur voisin de ce matériau

    if (slot < 24) { type = PROP_SANDBAG; wallMatFilter = 3.0; }       // autour du bunker (métal)
    else if (slot < 44) { type = PROP_BARBWIRE; }                       // bords extérieurs
    else if (slot < 64) { type = PROP_CRATE; }                          // grandes salles
    else if (slot < 80) { type = PROP_BARREL; restrictToRoom = true; roomLo = ROOM_DEPOT_LO; roomHi = ROOM_DEPOT_HI; }
    else if (slot < 96) { type = PROP_POSTER; }                         // couloirs intérieurs
    else if (slot < 108) { type = PROP_RUBBLE; }                        // dispersés
    else if (slot < 120) { type = PROP_JERRICAN; }                      // dispersés
    else { type = PROP_MIRADOR; restrictToRoom = true; roomLo = ROOM_POSTE_LO; roomHi = ROOM_POSTE_HI; } // cour du poste de garde

    for (int attempt = 0; attempt < 20; attempt++) {
        float h1 = mazeHash(slot, attempt, 7001);
        float h2 = mazeHash(slot, attempt, 7002);
        ivec2 p;
        if (restrictToRoom) {
            p = roomLo + ivec2(h1 * float(roomHi.x - roomLo.x + 1), h2 * float(roomHi.y - roomLo.y + 1));
        } else if (type == PROP_CRATE) {
            // 4 grandes salles au choix (3.2.1 : "caisses dans les grandes salles")
            int roomPick = int(mazeHash(slot, attempt, 7003) * 4.0);
            ivec2 lo = roomPick == 0 ? ROOM_QG_LO : roomPick == 1 ? ROOM_BUNKER_LO : roomPick == 2 ? ROOM_DEPOT_LO : ROOM_POSTE_LO;
            ivec2 hi = roomPick == 0 ? ROOM_QG_HI : roomPick == 1 ? ROOM_BUNKER_HI : roomPick == 2 ? ROOM_DEPOT_HI : ROOM_POSTE_HI;
            p = lo + ivec2(h1 * float(hi.x - lo.x + 1), h2 * float(hi.y - lo.y + 1));
        } else if (type == PROP_BARBWIRE) {
            p = ivec2(1, 1) + ivec2(h1 * float(MAP_W - 2), h2 * float(MAP_H - 2));
        } else {
            p = ivec2(1, 1) + ivec2(h1 * float(MAP_W - 2), h2 * float(MAP_H - 2));
        }

        if (!isFloor(p, mapTex)) continue;
        if (distance(vec2(p) + 0.5, playerSpawn) < 3.0) continue;

        bool ok = true;
        if (wallMatFilter >= 0.0) ok = nearWallMaterial(p, wallMatFilter, mapTex);
        if (type == PROP_BARBWIRE) {
            float edge = min(min(float(p.x), float(p.y)), min(float(MAP_W - 1 - p.x), float(MAP_H - 1 - p.y)));
            ok = ok && edge < 6.0 && nearAnyWall(p, mapTex);
        }
        if (type == PROP_POSTER) {
            ok = ok && (nearWallMaterial(p, 1.0, mapTex) || nearWallMaterial(p, 2.0, mapTex));
            ok = ok && !inRoom(p, ROOM_QG_LO, ROOM_QG_HI) && !inRoom(p, ROOM_BUNKER_LO, ROOM_BUNKER_HI);
        }
        if (type == PROP_RUBBLE) ok = ok && nearAnyWall(p, mapTex);

        if (ok) {
            float variant = floor(mazeHash(slot, attempt, 7004) * 4.0);
            vec2 jitter = (vec2(mazeHash(slot, attempt, 7005), mazeHash(slot, attempt, 7006)) - 0.5) * 0.4;
            return vec4(type, vec2(p) + 0.5 + jitter, variant);
        }
    }
    return vec4(PROP_NONE, 0.0, 0.0, 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    ivec2 fc = ivec2(floor(fragCoord));
    // Adressage par index linéaire (Common), robuste même si le buffer est plus étroit que
    // MAX_PROPS — même correctif que BufferA, voir la note dans Common. `Image` doit lire les props
    // avec la même fonction (`texelForIndex`), pas un `ivec2(pi, 0)` direct.
    int idx = indexForTexel(fc, iChannel1);

    float genDone = texelFetch(iChannel1, texelForIndex(MAX_PROPS, iChannel1), 0).x;
    if (iFrame > 0 && genDone > 0.5) {
        fragColor = texelFetch(iChannel1, fc, 0); // figé une fois généré, comme BufferA (2.3)
        return;
    }

    if (idx < MAX_PROPS) {
        vec2 playerSpawn = texelFetch(iChannel0, txPlayerSpawn(iChannel0), 0).xy;
        vec4 prop = generatePropAt(idx, iChannel0, playerSpawn);
        fragColor = prop;
        return;
    }

    if (idx == MAX_PROPS) {
        fragColor = vec4(1.0, 0.0, 0.0, 0.0); // marqueur "génération terminée"
        return;
    }

    fragColor = vec4(0.0);
}
