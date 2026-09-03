// ==== Image (image) ====
mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

float ghost(vec3 p, float t) {
    vec3 gp = p;
    float gz = t * 65. + 15.; 
    gp.z -= gz;
    gp.xy -= vec2(sin(gz * .05) * 10., cos(gz * .03) * 8.);
    gp.x += sin(t * 5. + p.z * .2) * 2.;
    gp.y += cos(t * 3. + p.z * .1) * 2.;
    
    float body = length(gp * vec3(1, 1.2, .4)) - 2.5;
    float tail = length(gp.xy) * .5 + abs(gp.z) * .1 - 1.;
    return max(body, -tail) + sin(p.x * 3. + t * 10.) * .1;
}

float map(vec3 p) {
    vec2 path = vec2(sin(p.z * .05) * 10., cos(p.z * .03) * 8.);
    vec3 q = p;
    q.xy -= path;
    q.xy *= rot(p.z * .02);
    
    vec3 b = abs(q);
    float tunnel = -max(b.x, b.y) + 12.;
    float ribs = max(tunnel, (12.5 - max(b.x, b.y)) - abs(sin(p.z * .4)) * .5);
    
    vec3 pq = mod(q, 4.) - 2.;
    float details = length(pq.xy) - .2;
    
    return max(ribs, -details);
}

void mainImage(out vec4 o, vec2 u) {
    vec3 R = iResolution, col = vec3(0);
    float t = iTime, d = 0., i, h, gh;

    float cz = t * 55.;
    vec2 cp = vec2(sin(cz * .05) * 10., cos(cz * .03) * 8.);
    vec2 target_p = vec2(sin((cz + 10.) * .05) * 10., cos((cz + 10.) * .03) * 8.);
    
    vec3 ro = vec3(cp, cz);
    vec3 fw = normalize(vec3(target_p - cp, 10.));
    vec3 ri = normalize(cross(vec3(0, 1, 0), fw));
    vec3 up = cross(fw, ri);
    vec3 D = normalize(mat3(ri, up, fw) * vec3((u + u - R.xy) / R.y, 1.8));

    for(i = 0.; i < 110.; i++) {
        vec3 p = ro + D * d;
        h = map(p);
        gh = ghost(p, t);
        
        float dist = min(h, gh);
        if(abs(dist) < .001 * d || d > 500.) break;
        

        float gGlow = 0.05 / (abs(gh) + .5);
        col += vec3(.4, .8, 1.) * gGlow * exp(-d * .02);
        

        float envGlow = 0.01 / (abs(h) + .02);
        col += (.5 + .5 * cos(vec3(0, 2, 4) + p.z * .02 + t)) * envGlow * exp(-d * .01);
        
        d += dist * .6;
    }

    vec3 p = ro + D * d;
    vec3 n = normalize(vec3(
        map(p + vec3(.01, 0, 0)) - map(p - vec3(.01, 0, 0)),
        map(p + vec3(0, .01, 0)) - map(p - vec3(0, .01, 0)),
        map(p + vec3(0, 0, .01)) - map(p - vec3(0, 0, .01))
    ));

    float fog = exp(-d * .003);
    float spec = pow(max(0., dot(reflect(D, n), fw)), 16.);
    
    if(gh < h) {
        col += vec3(.7, .9, 1.) * fog;
    } else {
        col += spec * fog * .3;
    }
    
    col = mix(col, vec3(.01, .02, .05), 1. - fog);
    o = vec4(pow(tanh(col * 1.2), vec3(.4545)), 1);
    
    vec2 uv = u / R.xy;
    o *= pow(16. * uv.x * uv.y * (1. - uv.x) * (1. - uv.y), .12);
}
