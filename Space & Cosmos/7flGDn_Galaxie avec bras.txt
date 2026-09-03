// ==== Image (image) ====
// Par : Patrick JAILLET

#define PI  3.14159265359
#define TAU 6.28318530718
#define MAX_STEPS 128
#define MAX_DIST  50.0

float hache(vec3 p) { return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453); }

float bruit(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f*f*(3.0 - 2.0*f);
    return mix(
        mix(mix(hache(i+vec3(0,0,0)), hache(i+vec3(1,0,0)), f.x),
            mix(hache(i+vec3(0,1,0)), hache(i+vec3(1,1,0)), f.x), f.y),
        mix(mix(hache(i+vec3(0,0,1)), hache(i+vec3(1,0,1)), f.x),
            mix(hache(i+vec3(0,1,1)), hache(i+vec3(1,1,1)), f.x), f.y),
        f.z);
}

float fbm(vec3 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * bruit(p);
        p *= 2.5; a *= 0.5;
    }
    return v;
}

float galaxieCentrale(vec3 p, float t) {
    vec3 q = p / 1.5; 
    float r = length(q.xz);
    float h = abs(q.y);
    
    float bulbe = exp(-length(q) * 1.6) * 5.5;
    float disque = exp(-r * 0.18) * exp(-h * 14.0);
    
    float angle = atan(q.z, q.x);
    float spirale = sin(angle * 8.0 - r * 1.4 + t * 0.4);
    spirale = pow(max(0.0, spirale), 2.0);
    
    float textureGaz = fbm(q * 1.1 + t * 0.05);
    float final = (bulbe + disque * (1.2 + spirale * 2.5)) * textureGaz;
    
    return max(0.0, final * smoothstep(22.0, 10.0, r));
}

vec3 couleurVolume(vec3 p, float d) {
    float r = length(p.xz) / 1.5;
    vec3 colCoeur = vec3(1.0, 0.98, 0.85);
    vec3 colDisque = vec3(0.35, 0.65, 1.0);
    vec3 colExt = vec3(0.55, 0.25, 0.9);
    
    vec3 col = mix(colCoeur, colDisque, smoothstep(0.8, 5.0, r));
    col = mix(col, colExt, smoothstep(5.0, 16.0, r));
    
    return col * (2.0 + d * 3.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    
    float t = iTime * 0.3;
    
    float amplitude = 18.0;
    float posX = sin(t) * amplitude;
    float posZ = sin(t * 2.0) * (amplitude * 0.5);
    float posY = 4.0 + cos(t) * 2.0;
    
    vec3 ro = vec3(posX, posY, posZ);
    
    vec3 ta = vec3(sin(t * 0.5) * 2.0, 0, 0);
    
    vec3 f = normalize(ta - ro);
    vec3 ri = normalize(cross(vec3(0,1,0), f));
    vec3 u = cross(f, ri);
    vec3 rd = mat3(ri, u, f) * normalize(vec3(uv, 1.4));

    float pas = MAX_DIST / float(MAX_STEPS);
    vec3 acc = vec3(0.0);
    float trans = 1.0;
    vec3 p = ro + rd * hache(vec3(uv, iTime)) * pas;

    for (int i = 0; i < MAX_STEPS; i++) {
        if (trans < 0.01) break;
        float d = galaxieCentrale(p, iTime * 0.3);
        if (d > 0.01) {
            vec3 c = couleurVolume(p, d);
            float abs = exp(-d * pas * 1.6);
            acc += c * d * trans * 4.5 * (1.0 - abs);
            trans *= abs;
        }
        p += rd * pas;
    }

    vec3 fond = vec3(0.0);
    vec3 p_et = floor(rd * 350.0);
    if (hache(p_et) > 0.998) fond = vec3(pow(hache(p_et + 1.0), 18.0));

    vec3 colFinal = acc + fond * trans;
    colFinal = colFinal / (1.0 + colFinal);
    colFinal = pow(colFinal, vec3(0.9));
    
    fragColor = vec4(clamp(colFinal, 0.0, 1.0), 1.0);
}
