// ==== Image (image) ====
float w(vec3 p){
    float d=max(0.,.14-max(0.,length(p.xy)-.1)/.1)/.14,a=p.z*.4;
    p.xy*=mat2(cos(a),sin(a),-sin(a),cos(a));
    p.z+=iTime*.14;
    p=abs(fract((p+vec3(1.5,2,-1.5))*.1)-.5);
    for(int i=0;i<9;i++)p=abs(p)/dot(p,p)-.75;
    return length(p)*(1.+d*.5)+d*.5;
}

void mainImage(out vec4 o,vec2 c){
    vec2 r=iResolution.xy,u=(c-.5*r)/r.y;
    vec3 d=normalize(vec3(u,3.5)),f=vec3(0,0,-1),p,l=vec3(0);
    float v=5.,s=0.,z,L;
    for(;s<130.;s++){
        p=f+s*d*.1;
        z=p.z*1.2;
        L=length(p.xy*mat2(cos(z),sin(z),-sin(z),cos(z)));
        if(L>.1)v+=w(p)*(1.-s*.005);
    }
    v/=120.;
    l=vec3(v*1.6,pow(v,1.8),pow(v,5.)*.6);
    l+=vec3(1,.5,.2)*pow(.025*(1.+.15*sin(iTime*5.))/length(u),1.6);
    o=vec4(pow(max(vec3(0),mix(l,vec4(dot(l,vec3(.33))).xyz,-.2)),vec3(.8)),1);
}
