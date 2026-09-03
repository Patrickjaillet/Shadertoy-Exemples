// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    vec2 R = iResolution.xy;
    vec3 rd = normalize(vec3((U-.5*R)/R.y, 1.2)), ro = vec3(0,0,-5), col=vec3(0), 
         lp = vec3(5.*sin(iTime*.5), 4, 5.*cos(iTime*.5));
    float T = 1., t = 2. + fract(sin(dot(U, vec2(12.9, 78.2)))*437.5) * .1;
    for(int i=0; i<80; i++) {
        vec3 p = ro + rd * t, q = p;
        float d = 0., a = .5;
        for(int j=0; j<4; j++) {
            q = q*2.02 + vec3(0,0,iTime*.2);
            vec3 iq = floor(q), f = fract(q);
            f *= f*(3.-2.*f);
            vec2 b = vec2(1,0);
            #define h(p) fract(sin(dot(p, vec3(12.9,78.2,157.1)))*437.5)
            float n = mix(mix(mix(h(iq),h(iq+b.xyy),f.x),mix(h(iq+b.yxy),h(iq+b.xxy),f.x),f.y),
                          mix(mix(h(iq+b.yyx),h(iq+b.xyx),f.x),mix(h(iq+b.yxx),h(iq+b.xxx),f.x),f.y),f.z);
            d += a * n; a *= .5;
        }
        d = max(0., d*2. - (length(p)-2.2));
        if(d > .01) {
            float s = 0., v = .7;
            for(int k=0; k<4; k++) s += max(0., d * v); 
            float ph = .08 * (1.-.49) / pow(1.49-1.3*dot(rd,normalize(lp-p)), 1.5);
            vec3 S = (vec3(1,.9,.7)*25.*exp(-s)*ph + .01)*d;
            float tr = exp(-d*.1);
            col += T * (S - S*tr) / d;
            T *= tr;
        }
        if(T < .02) break;
        t += .08;
    }
    col = (col*2.51)/(col*2.43+.6);
    O = vec4(pow(col, vec3(.45)), 1);
}
