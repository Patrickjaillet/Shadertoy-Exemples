// ==== Image (image) ====
float hash21(float p){
    return fract(sin(p*127.1)*43758.5453123);
}

vec2 hash22(vec2 p){
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p)*43758.5453123);
}

mat2 rot(float a){
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

void petalLayer(
    vec2 uv, float t, float seed,
    float numPetals, float rOffset, float pLen, float pShape,
    float rotSpeed, float rotPhase,
    vec3 colBase, vec3 colTip, float sheen,
    out vec3 outCol, out float outAlpha
){
    vec2 p = uv * rot(t*rotSpeed + rotPhase);

    p += 0.02 * vec2(sin(p.y*5.0 + t*1.4 + seed), cos(p.x*5.0 - t*1.1 + seed));

    float a = atan(p.y, p.x);
    float r = length(p) - rOffset;

    float cell = 6.2831853 / numPetals;
    float aMod = mod(a + cell*0.5, cell) - cell*0.5;
    float halfCell = cell*0.5;

    float na = clamp(aMod/halfCell, -1.0, 1.0);
    float profile = cos(na*1.57079632679);
    float widthShape = pow(max(profile, 0.0), pShape);

    float edgeR = pLen * widthShape;
    float feather = 0.05*pLen + 0.005;

    float maskOuter = smoothstep(edgeR, edgeR - feather, r);
    float maskInner = smoothstep(-feather, 0.0, r);
    float mask = maskOuter * maskInner;

    float rr = clamp(r/max(edgeR, 1e-4), 0.0, 0.8);
    vec3 grad = mix(colBase, colTip, rr);

    float midrib = 0.55 + 0.45*profile;
    grad *= midrib;

    grad += 0.05*sin(r*45.0 - aMod*14.6 + t*2.8);

    float spec = pow(max(0.0, 1.0 - abs(na)), 11.4) * smoothstep(edgeR*0.08, edgeR, r);
    grad += sheen*spec;

    outCol = grad;
    outAlpha = mask;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = (fragCoord - 0.5*iResolution.xy) / iResolution.y;
    float t = iTime * 0.35;

    vec3 col = vec3(0.05, 0.015, 0.03) + 0.06*vec3(1.0, 0.35, 0.45) * (1.0 - smoothstep(0.0, 1.2, length(uv)));

    for(float i = 0.0; i < 18.0; i++){
        vec2 rnd = hash22(vec2(i, i*3.17 + 1.0));
        vec2 pos = (rnd - 0.5) * 2.3;
        pos += 0.06*vec2(sin(t*0.3 + i), cos(t*0.25 + i*0.1));
        float d = length(uv - pos);
        float size = mix(0.008, 0.03, hash21(i + 7.0));
        float glow = size / (d + size*0.5) * 0.018;
        vec3 sparkCol = mix(vec3(1.0,0.6,0.7), vec3(1.0,0.85,0.55), hash21(i + 21.0));
        col += glow*sparkCol;
    }

    float haloShadow = smoothstep(0.55, 0.30, length(uv)) * 0.25;
    col *= 1.0 - haloShadow*0.4;

    float breathe = 0.7 + 0.02*sin(iTime*0.6);

    const float NUM_LAYERS = 12.0;
    for(float L = 0.0; L < NUM_LAYERS; L++){
        float ln = L/(NUM_LAYERS - 1.0);

        float numPetals = floor(mix(8.0, 5.0, ln) + 0.5);
        float rOffset   = mix(0.34, 0.02, ln) * breathe;
        float pLen      = mix(0.50, 0.26, ln) * breathe;
        float pShape    = mix(1.0, 1.9, ln);
        float rotSpeed  = 0.05 + 0.01*L;
        float rotPhase  = L*0.6 + sin(L*2.1)*0.3;
        float sheen     = mix(0.22, 0.42, ln);

        vec3 colBase = mix(vec3(0.35,0.02,0.08), vec3(0.65,0.10,0.18), ln);
        vec3 colTip  = mix(vec3(0.10,0.2,0.33), vec3(1.0,0.38,0.39), ln);

        vec3 layerCol; float layerAlpha;
        petalLayer(uv, t, L*13.7, numPetals, rOffset, pLen, pShape, rotSpeed, rotPhase, colBase, colTip, sheen, layerCol, layerAlpha);

        col = mix(col, layerCol, layerAlpha);
    }

    vec2 pc = uv * rot(t*0.4);
    float rc = length(pc);
    float ac = atan(pc.y, pc.x);

    float discR = 0.075*breathe;
    float discMask = smoothstep(discR, discR - 0.015, rc);
    vec3 discCol = mix(vec3(0.9,0.35,0.12), vec3(0.55,0.06,0.12), smoothstep(0.0, discR, rc));
    col = mix(col, discCol, discMask);

    float stamenCount = 22.0;
    float cellA = 6.2831853/stamenCount;
    float angRounded = floor(ac/cellA + 0.5)*cellA;
    vec2 dotPos = (discR*0.9)*vec2(cos(angRounded), sin(angRounded));
    float dDot = length(pc - dotPos);
    float pollenMask = smoothstep(0.02, 0.008, dDot) * smoothstep(discR*1.3, discR*0.5, rc);
    vec3 pollenCol = vec3(1.0, 0.82, 0.35);
    col = mix(col, pollenCol, pollenMask);

    col += discMask*0.2*vec3(1.0,0.55,0.25)*exp(-rc*10.0);

    col += pow(max(col - 0.6, 0.0), vec3(2.0))*0.35;
    col *= smoothstep(1.4, 0.35, length(uv));

    fragColor = vec4(tanh(col*1.15), 1.0);
}
