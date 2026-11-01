#define AA 2
#define PAS 56
#define ITER 7

const float PI = 3.14159265;

float hachage(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

mat2 rotation(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 teinte(float h) {
    vec3 p = abs(fract(h + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 20.0 - 3.0);
    vec3 v = mix(vec3(.2), vec3(1.0), smoothstep(1.2, 2.0, p));
    return 2.6 * mix(vec3(1.0), v, .7);
}

vec3 rendu(vec2 uv, float T, float dither) {
    mat2 rot1 = rotation(T * .2);
    mat2 rot2 = rotation(T * .15 + .3);
    mat2 rotInterne = mat2(.70710678, -.70710678, .70710678, .70710678);

    vec3 acc = vec3(.1);
    float d = dither * .015;

    for (int i = 0; i < PAS; i++) {
        vec3 p = vec3(uv * d, d);
        p.xz *= rot1;
        p.yz *= rot2;
        p.z += T * .6;
        p += 1.0;

        float orbite = 9.0;
        float orbite2 = 9.0;
        float echelle = 9.0;
        float st = 0.0;

        for (int j = 0; j < ITER; j++) {
            p = mod(p - 1.0, 2.0) - 1.0;
            p.yz *= rotInterne;
            orbite = min(orbite, length(p));
            orbite2 = min(orbite2, abs(dot(p, vec3(.5773503))));
            st = dot(p, p) * .6;
            echelle /= st;
            p /= st;
        }

        st = 1.0 / echelle;
        d += st;

        float h = fract(orbite + d * .08 + T * .04);
        float h2 = fract(orbite2 * .6 + d * .05 + T * .03 + .5);

        vec3 couleur = teinte(h);
        vec3 couleur2 = teinte(h2);

        vec3 chute = exp(-(st * 1200.0 * vec3(.96, 1.0, 1.05) + d * .15));
        float halo = exp(-(st * 420.0 + d * .2));

        acc += .006 * chute * couleur;
        acc += .00015 * halo * couleur2;
    }

    return min(acc, vec3(12.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float T = iTime;
    vec3 somme = vec3(0.0);

    for (int j = 0; j < AA; j++) {
        for (int i = 0; i < AA; i++) {
            int k = i + j * AA;
            vec2 off = (vec2(float(i), float(j)) + .5) / float(AA) - .5;
            vec2 fc = fragCoord + off;
            float dith = hachage(fc + vec2(T * 61.7) + float(k) * 13.1);

            vec2 uv = (fc * 2.0 - iResolution.xy) / iResolution.y;
            float Ts = T + (float(k) + dith) / float(AA * AA) * .02;

            float respiration = 1.0 + .02 * sin(Ts * .5);
            float roulis = sin(Ts * .31) * .02 + sin(Ts * 1.7) * .003;
            uv = rotation(roulis) * uv * respiration;
            uv += vec2(sin(Ts * .7) * .012, cos(Ts * .9) * .009);

            somme += rendu(uv, Ts, dith);
        }
    }

    vec3 x = somme / float(AA * AA);

    vec2 uv0 = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    float r2 = dot(uv0, uv0);
    x *= vec3(1.0 + r2 * .03, 1.0, 1.0 - r2 * .03);

    vec3 col = clamp((x * (2.51 * x + 0.03)) / (x * (1.68 * x + 0.59) + 0.14), 0.0, 1.0);

    col = mix(col, col * col * (3.0 - 2.0 * col), .25);

    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));
    col = mix(vec3(luma), col, 1.12);

    float vig = 1.0 - smoothstep(.6, 2.1, length(uv0));
    col *= mix(.4, 1.0, vig);

    float grain = hachage(fragCoord + fract(T) * 91.7) - .5;
    col += grain * (2.0 / 255.0) * (1.4 - luma);
    col += (hachage(fragCoord + T * 57.3) - .5) / 255.0;

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
