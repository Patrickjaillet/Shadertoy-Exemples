// ==== Image (image) ====
#define G(z) vec2(sin(z*.144+sin(z*.096))*2.8, cos(z*.108+cos(z*.132))*2.2)

float map(vec3 p, float time) {
    vec2 q = p.xy - G(p.z);
    float t = 1e10;
    for(float j=0.; j<3.; j++) {
        float a = j*2.1 + p.z*.35;
        t = min(t, length(q - vec2(cos(a), sin(a)) * (1.2 + sin(p.z*.6 + time*.35) * .25)) - .04);
    }
    float b = -length(q) + 1.6 + sin(p.z*.4 - time*1.4) * .15 + sin(p.x*.6) * sin(p.y*.6) * sin(p.z*.6) * .18 - sin(p.z*12. + atan(q.y, q.x) * 6.) * .04;
    return min(b, t);
}

void mainImage(out vec4 O, vec2 C) {
    vec3 r = iResolution, n, l, c = vec3(0), 
         o = vec3(G(iTime*4.), iTime*4.), 
         d = normalize(vec3((C - .5*r.xy)/r.y, 1.1));
    
    float t=0., i=0., g, d0, d1, d2, d3;
    for(; i++<80. && t<30.; t+=g*.6) {
        g = map(o + d*t, iTime);
    }

    if(t < 30.) {
        vec3 p = o + d*t;
        vec2 e = vec2(.005, 0);
        d0 = map(p, iTime);
        n = normalize(vec3(d0 - map(p-e.xyy, iTime), d0 - map(p-e.yxy, iTime), d0 - map(p-e.yyx, iTime)));
        l = normalize(vec3(0, 0, 3));
        
        float f = pow(1. - max(dot(n, -d), 0.), 4.),
              v = smoothstep(.95, 1., sin(p.z*18. + sin(p.x)*sin(p.y)*sin(p.z)*6.)),
              h = clamp(map(p + n*.3, iTime)*3.3, 0., 1.);
              
        c = (mix(vec3(.03, 0, .02), vec3(.1, .15, .3), f) * max(dot(n, l), 0.) + pow(max(dot(reflect(-l, n), -d), 0.), 32.) * .5 + f * .4) * h 
            + vec3(.9, .1, .2) * v * (sin(iTime*2.4 + p.z*1.5) * .5 + .5) * 2.;
    }
    
    c = mix(c, vec3(0.005, 0.002, 0.01), 1. - exp(-2e-3 * t * t * t));
    O = vec4(pow(c, vec3(.4545)), 1) * smoothstep(1.3, .3, length((C - .5*r.xy)/r.y));
}
