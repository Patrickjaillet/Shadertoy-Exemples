// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 base = texture(iChannel0, uv).rgb;
    vec3 bloom = texture(iChannel1, uv).rgb;
    
    vec3 col = base + bloom * 0.2;
    col = pow(col, vec3(0.4545));
    col *= smoothstep(1.3, 0.5, length(uv - 0.5));
    
    fragColor = vec4(col, 1.0);
}

// ==== Common (common) ====
#define TEMPS (sin(iTime*.6)*16.+iTime*1e2)
#define POSITION(z) (vec3(cos((z)*.011)*16.+cos((z) * .012) * 24., cos((z)*.01)*4., (z)))
#define ROTATION(a) mat2(cos(a+vec4(0,33,11,0)))
#define NORMALISER normalize

float sdBoite(vec3 p, float taille) {
    vec3 d = abs(p) - taille;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float hachage(float n) { return fract(sin(n) * 43758.5453); }

vec3 couleurHachage(float n) {
    return vec3(hachage(n), hachage(n + 1.0), hachage(n + 2.0));
}

vec3 getOrbPos(float id, float t) {
    float h = hachage(id);
    vec3 p = vec3((hachage(id * 13.0) - 0.5) * 45.0, 
                  (hachage(id * 17.0) - 0.5) * 25.0, 
                  (hachage(id * 19.0) - 0.5) * 30.0);
    p.xy += sin(t * (0.6 + h) + h * 100.0 * vec2(1.1, 1.4)) * 12.0;
    return p;
}

// ==== Buffer A (buffer) ====
vec4 lumieres;

float carte(vec3 p) {
    vec3 traj = POSITION(p.z);
    vec2 pRel = p.xy - traj.xy;
    
    float v = sin(p.x * 0.5 + iTime * 2.0) * cos(p.z * 0.3 + iTime) * 0.5;
    float eau = min(p.y - (traj.y - 15.0) + v, (traj.y + 15.0) - p.y + v);
    
    float zF = mod(p.z, 20.0) - 10.0;
    float c1 = sdBoite(vec3(pRel - sin(p.z/12.+vec2(0,1.3))*12. + vec2(sin(iTime*50.), cos(iTime*55.))*0.5, zF), 2.0);
    float c2 = sdBoite(vec3(pRel - sin(p.z/16.+vec2(0,.7))*16. + vec2(cos(iTime*80.), sin(iTime*85.))*0.7, zF), 3.0);

    lumieres += vec4(4.0, 0.2, 0.1, 0.0) / (0.8 + abs(c1));
    lumieres += vec4(0.1, 0.5, 4.0, 0.0) / (0.7 + abs(c2));
    lumieres += vec4(0.05, 0.1, 0.2, 0.0) * 0.1 / (0.4 + abs(eau));

    float dO = 1e9;
    for(float i=0.0; i<5.0; i++) {
        vec3 col = couleurHachage(i * 31.0);
        for(float j=0.0; j<12.0; j++) {
            float dt = j * 0.25;
            float vie = 1.0 - (dt/3.0);
            if(dt > 3.0) break;
            
            vec3 oP = getOrbPos(i, iTime - dt);
            vec3 pO = vec3(pRel - oP.xy, mod(p.z, 100.0) - 50.0 - oP.z);
            float d = length(pO) - (0.15 * vie);
            if(j == 0.0) dO = min(dO, d);
            
            float intens = (j == 0.0) ? 6.0 : (1.5 * vie);
            lumieres += vec4(col * intens, 0.0) / (0.6 + abs(d));
            lumieres += vec4(col * intens * 0.2, 0.0) / (1.2 + length(vec3(pO.xy, eau)) + abs(eau));
        }
    }
    return min(eau, min(min(c1, c2), dO));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy*0.5)/iResolution.y;
    vec3 pc = POSITION(TEMPS), target = POSITION(TEMPS + 2.0);
    vec3 f = NORMALISER(target - pc), r = NORMALISER(vec3(f.z, 0, -f.x)), u = cross(r, f);
    vec3 rd = NORMALISER(mat3(r, u, f) * vec3(ROTATION(sin(TEMPS*0.005)*0.4)*uv, 1.0));
    
    float d = 0.0, p;
    vec4 col = vec4(0);
    for(int i=0; i<80; i++) {
        vec3 pos = pc + rd * d;
        vec4 lS = lumieres; lumieres = vec4(0);
        p = carte(pos) * 0.7;
        col += lumieres * 0.02;
        lumieres = lS;
        d += p;
        if(p < 0.01 || d > 450.0) break;
    }
    fragColor = vec4(tanh(col.rgb / 5.0 * exp(vec3(0.6, 0.2, 0.1) * d / -800.0)), 1.0);
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 col = vec4(0);
    float g[5] = float[](0.227, 0.194, 0.121, 0.054, 0.016);
    col = texture(iChannel0, uv) * g[0];
    for(int i=1; i<5; i++) {
        col += texture(iChannel0, uv + vec2(float(i)/iResolution.x, 0.0)) * g[i];
        col += texture(iChannel0, uv - vec2(float(i)/iResolution.x, 0.0)) * g[i];
    }
    fragColor = col;
}
