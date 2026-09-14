// ==== Image (image) ====
#define P(z) vec3(sin(z*.21)*11., cos(z*.31)*8., z + sin(z*.1)*2.)
#define R(a) mat2(cos(a+vec4(0,33,11,0)))

void mainImage(out vec4 o, vec2 u) {
    vec3 r=iResolution, Z, X, D, p, q, ro=P(iTime*.12);
    float d=0., s, i=0., j, l, w, t=iTime;

    Z = normalize(P(t*.12+7.)-ro);
    X = normalize(vec3(Z.z + sin(t*.2)*.3, sin(t*.1)*.2, -Z.x));

    D = vec3(R(sin(t*.22)*.6)*(u-r.xy*.5)/r.y, 1.4)
        *mat3(-X, cross(X,Z), Z);

    for(o*=i; i++<110.; ) {
        p = q = ro+D*d;
        p += cos(t*1.3 + p.yzx*.9 + sin(p.zxy*.7))*.25;

        s = dot(abs(p-floor(p)-.5), vec3(.35,.45,.4));

        p = q;
        p.xy += vec2(
            cos(t*.9 + p.z*.6 + sin(p.x)*.5),
            sin(t*.8 + p.z*.7 + cos(p.y)*.5)
        );

        for(j=0., w=1.; j++<8.; p*=l, w*=l)
            p.xy *= R(t*.13 + sin(p.z)*.3),
            p = abs(p)-.42,
            p.xz *= R(t*.37 + cos(p.x)*.2),
            l = 2.6/max(dot(p,p), .015);

        float dist_fractale = length(p)/w;

        s = min(s, dist_fractale);

        float dist_tunnel = .18 - length(q.xy - P(q.z*1.1).xy);

        d += max(dist_tunnel, s);

        o.rgb += (cos(p.zxy*.7 + t*1.2)*.01)/d/s;
    }

    o = tanh(o*o*1.3);
}
