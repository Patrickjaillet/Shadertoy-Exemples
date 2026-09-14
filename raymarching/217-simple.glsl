// ==== Image (image) ====
/*Golfed version:
- Stripped out all unused morphing variables (morphTime, morph, f2) and inactive modifiers (multipliers by 0.0).
- Inlined the hsv and rotate2D functions directly into the loop, and condensed the raymarching accumulation.
- Minified names, grouped declarations, and squeezed floats.

#define R(a) mat2(cos(a),-sin(a),sin(a),cos(a))
void mainImage(out vec4 C,vec2 U){
    vec2 r=iResolution.xy,uv=(U-.5*r)/r.y;
    float t=iTime,i,e=0.,R=0.,s=0.;
    vec3 q=vec3(.04,-1,-1.5),p,d=normalize(vec3(uv,.9)),o=vec3(0);
    for(i=0.;i<85.;i++){
        vec4 K=vec4(1,2./3.,1./3.,3);
        o+=.02*mix(K.xxx,clamp(abs(fract(K.xyz)*-20.-K.www)-K.xxx,0.,1.),0.)*clamp(min(e*s*.015,.9),0.,1.);
        s=5.9;
        q+=d*max(e,0.05)*R*.22;
        R=length(p=q);
        p=vec3(log(R+1.),exp(-p.y/R)-.7,atan(p.x,p.z));
        p.xz+=vec2(.0012,.0007);
        e=p.y-.9;
        p.xz*=R(t*.08+p.z*.05);
        for(int j=0;j<9;j++){
            vec3 sp=p*s;
            e+=dot(sin(sp.zxy),cos(sp.yzx*5.2))/s*.45;
            s*=1.9;
            if(s>1200.)break;
        }
        e+=length(abs(p)-vec3(.8,1.2,.7))*.03/s;
    }
    C=vec4(o+vec3(.18,.175,.46)*(.8-length(uv)),1);
}*/
mat2 rotate2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 hsv(float h, float s, float v) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(h + K.xyz) * -20.0 - K.www);
    return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec4 o = vec4(0.0);
    float i = 0.0, e = 0.0, R = 0.0, s = 0.0;
    vec3 q = vec3(0.04, -1.0, -1.5);
    vec3 p;
    vec2 uv = (fragCoord.xy - 0.5 * r) / r.y;
    vec3 d = normalize(vec3(uv, 0.9));
    float morphTime = t * 0.00;
    float morph = sin(morphTime) * 0.0 + 0.0;
    for (i = 0.0; i < 85.0; i++) {
        o.rgb += 0.020 * hsv(fract(0.00 * e + t * 0.000), 0.0, clamp(min(e * s * 0.015, 0.9), 0.0, 1.0));
        s = 5.9;
        q += d * max(e * 1.0, 0.05) * R * 0.22;
        p = q;
        R = length(p);
        p = vec3(log(R + 1.000) - t * 0.0, exp(-p.y / R * 1.0) - 0.7, atan(p.x, p.z + 0.0000));
        p.xz += vec2(0.0012, 0.0007);
        e = p.y - 0.9;
        mat2 rot = rotate2D(t * 0.08 + p.z * 0.05);
        p.xz = p.xz * rot;
        for (int j = 0; j < 9; j++) {
            vec3 sp = p * s;
            float f1 = dot(sin(sp.zxy), cos(sp.yzx * 5.2)) / s;
            float f2 = dot(cos(sp.xzy * 0.0), sin(sp.yxz)) / s * 0.0;
            e += mix(f1, f2, morph) * 0.45;
            s *= 1.9;
            if (s > 1200.0) break;
        }
        p = abs(p) - vec3(0.8, 1.2, 0.7);
        e += length(p) * 0.03 / s;
    }
    o.rgb = pow(o.rgb, vec3(1.00));
    o.rgb += vec3(0.180, 0.175, 0.46) * (0.8 - length(uv));
    fragColor = vec4(o.rgb, 1.0);
}
