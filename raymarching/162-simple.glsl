// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // --- GESTION DU TEMPS ET BULLET TIME ---
    float rawTime = iTime;
    
    // Vitesse du temps qui oscille (bullet time cyclique)
    float speed = mix(0.08, 1.0, .5 + .5 * cos(rawTime * .4));
    
    // Progression temporelle fluide intégrant des pauses ralenties
    float t = rawTime * .25 + sin(rawTime * .4) * 1.5;
    
    vec2 r = iResolution.xy;
    vec3 u = vec3(0);
    vec3 U[8] = vec3[8](
        vec3(1, .55, .35),
        vec3(.3, .75, .95),
        vec3(.95, .85, .4),
        vec3(.65, .45, .85),
        vec3(.35, .9, .65),
        vec3(1, .4, .65),
        vec3(.45, .6, 1),
        vec3(.9, .95, .5)
    );

    // Flou de mouvement réactif à la vitesse
    float blur = .03 * speed;

    for (float h = 0.; h < 4.; h++) {
        float v = t + (h * .25 - .5) * blur;
        
        // --- MORPHING EN CONTINU ---
        float e = .5 + .5 * sin(v * .8);
        
        float c = v * 0.73;
        float d = v * 0.73 + 1.0;
        float k = 0.;
        float G = v * .2;
        
        float ac = mix(2.4 + .2 * cos(c * 1.5), 2.4 + .2 * cos(d * 1.5), e);

        // --- CAMÉRA STRICTEMENT FIXE FACE AU FRACTAL ---
        vec3 C = vec3(0.0, 1.5, 2.6); // Position fixe
        vec3 target = vec3(0.0, 0.0, 0.0); // Point d'impact au centre
        
        vec3 j = normalize(target - C);
        vec3 D = normalize(cross(j, vec3(0, 1, 0)));
        vec3 Z = cross(D, j);
        
        vec3 _ = normalize(vec3((fragCoord - .5 * r) / r.y, 1.2) * mat3(D, Z, j));
        vec3 F = C;
        vec3 l = vec3(0);
        
        vec3 J = mix(
            vec3(1, .8 + .2 * sin(c), .8 + .2 * sin(c)),
            vec3(1, .8 + .2 * sin(d), .8 + .2 * sin(d)),
            e
        );
        
        mat2 aa = mat2(cos(G), -sin(G), sin(G), cos(G));
        mat2 ab = mat2(.995, -.1, .1, .995);

        for (int n = 0; n < 80; n++) {
            vec3 a = F;
            a.zx *= ab;
            a.yz *= aa;
            float K = 1.;
            float L = 1e2;
            int M = 0;

            for (int p = 0; p < 8; p++) {
                a = ac * clamp(a, -J, J) - a;
                float q = dot(a, a);
                if (q < L) {
                    L = q;
                    M = p;
                }
                float N = 1.2 / clamp(q, 0., 1.);
                a *= N;
                K *= N;
            }

            float g = length(a) / K;
            float s = abs(k - 2.8) * .12;
            float P = .005 + s * .05;
            float Q = 1. + s * 8.;
            float R = max(g * .3, .005 + s * .02);
            vec3 O = U[M];

            if (g < P) {
                l += mix(vec3((1. - float(n) / 80.) * 1.4), O * (1. - float(n) / 80.) * 1.4, .35) * smoothstep(P, 0., g);
                break;
            }

            l += O * (.045 / Q) * exp(-g * (1.8 / Q));
            k += R;
            F += _ * R;
            if (k > 7.7) break;
        }

        u += min(l * 1.2, vec3(1));
    }

    fragColor = vec4(u * .25, 1);
}
