// ==== Image (image) ====
void mainImage(out vec4 o, in vec2 FC) {
    o = vec4(0.0);
    vec2 r = iResolution.xy;
    float t = iTime;
    vec3 p, q = vec3(0.0, 0.2, -1.8);
    
    for(float j, i, e, v, u; i++ < 130.; o += 0.007 / exp(3e3 / (v * vec4(0.2, 0.8, 0.3, 1.0) + e * 4e6))) {
        p = q += vec3((FC.xy - 0.5 * r) / r.y, 1) * e;
        
        // Modification des fractales pour imiter la structure divergente et étalée de la canopée de l'arbre
        for(j = e = v = 7.; j++ < 21.; e = min(e, max(length(p.xz = abs(p.xz * mat2(cos(j + t*0.2), -sin(j + t*0.2), sin(j + t*0.2), cos(j + t*0.2))) - vec2(0.1 + 0.05 * j, 0.4)) - 0.015 / u, abs(p.y) - 1.5) / v)) {
            v /= u = dot(p, p), p /= u + 0.01;
            // Étalement horizontal caractéristique de la ramification supérieure
            p.x *= 1.4;
        }
    }
}
