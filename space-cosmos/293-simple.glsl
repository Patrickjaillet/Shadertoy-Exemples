// ==== Image (image) ====
#define R iResolution.xy
#define T (iTime*.4)
#define r(a) mat2(cos(a),-sin(a),sin(a),cos(a))

mat3 r3(float a, vec3 v) {
    float s=sin(a), c=cos(a), i=1.-c;
    v = normalize(v);
    return mat3(
        c+i*v.x*v.x, i*v.x*v.y-s*v.z, i*v.x*v.z+s*v.y,
        i*v.y*v.x+s*v.z, c+i*v.y*v.y, i*v.y*v.z-s*v.x,
        i*v.z*v.x-s*v.y, i*v.z*v.y+s*v.x, c+i*v.z*v.z
    );
}

void mainImage(out vec4 O, vec2 FC) {
    vec2 uv = (FC-.5*R)/iResolution.y;
    vec3 ro = vec3(0, 0, -8.+sin(T)*2.), rd = normalize(vec3(uv, .4)), C = vec3(1);
    rd.xz *= r(sin(T*.5)*.4);
    rd.yz *= r(cos(T*.5)*.3);
    float td=0., gl=0.;
    for(float i=0.; i<218.; i++) {
        vec3 q = (ro+rd*td) * r3(T*.6+td*.02, vec3(1, .5, .3));
        float sc=1., d=9e9, a=0.;
        for(int k=0; k<4; k++) {
            float fk = float(k);
            q = abs(q)-vec3(.8, .9, .9);
            q.xy *= r(T*.2+fk);
            q.xz *= r(T*.13+fk*1.7);
            q.yz *= r(T*.11+fk*1.2);
            float l = dot(q, q);
            q = q*clamp(2.2/l, .15, 2.2)-vec3(.5, .2, .1);
            d = min(d, (length(q.xy)-.02)/sc);
            a += exp(-abs(l)*3.);
            sc *= 1.35;
        }
        d = abs(d)+1e-4;
        float fog = exp(-td*.07);
        gl += a*.02*fog;
        C += (1.+cos(vec3(1, .4, .5)*6.+2.*(log(sc)*.3+td*.27+T))) * (.008/.3)*fog + vec3(.2, .5, 1.)*a*.0009*fog;
        td += clamp(d*.45, .01, .5);
        if(td>90.) break;
    }
    C = mix(vec3(0), C+gl*vec3(.4, .7, 1.), exp(-td*.09)) * (1.-dot(uv, uv)*.5);
    O = vec4(pow(max(C, 0.), vec3(.4545)), 1);
}
