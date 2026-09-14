// ==== Image (image) ====
#define R(a) mat2(cos(a+vec4(0,11,33,0)))
void mainImage(out vec4 O, vec2 F){
    vec3 r=iResolution,p,d=normalize(vec3(F-.5*r.xy,r.y));
    float t=iTime*.2,l=.2,h,s,k,w;
    for(O=vec4(0);O.w++<99.;O+=vec4(7,5,3,0)*h*.003){
        p=vec3(0,0,-.4)+d*l;
        p.xy*=R(t);p.xz*=R(t*.7);
        h=1.;s=.9;
        for(int j=0;j++<12;)
            p=abs(p)-0.1,k=2.5/max(dot(p,p),0.3),p*=k,s*=k,h+=exp(-2.9*p.y);
        w=(length(p.xz)-.1)/s;
        if(abs(w)<1e-4||l>60.)break;
        l+=w;
    }
    O*=0.3-l*0.05;
}
