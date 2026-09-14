
void mainImage(out vec4 b,vec2 u){
    vec2 j=iResolution.xy;
    float c=iTime*.5,k=cos(c),l=sin(c),e=.005,i=0.,A=i,n=A,p,q,g,r;
    mat2 m=mat2(k,-l,l,k);
    vec3 d=normalize(vec3((u-.5*j)/j.y,.4)),x=clamp(abs(fract(c/6.+vec3(1,2./3.,1./3.))*6.-3.)-1.,0.,1.),h=vec3(0),B,f,t;
    d.xz*=m;
    d.yz*=m;
    b=vec4(0);
    for(int o=0;o<128;o++){
        h+=d*e;
        p=length(h)+1e-5;
        B=h/p;
        q=0.;
        g=1.5;
        f=B;
        r=log(p*2.)-c*.7;
        for(int s=0;s<5;s++){
            t=cos(f*g*3.14159+vec3(r,c,c*1.3));
            q+=abs(dot(t,vec3(.215)))/g;
            n+=t.y/g;
            f.xy*=mat2(1,1.8,0,.1);
            f.yz*=mat2(.8,1,.7,.1);
            r*=1.25;
            g*=1.5;
        }
        ++A;
        e=max(abs(q)*.13,0.);
        i+=e;
        b+=(1.+sin(vec4(1,.4,-.5,0)))*exp(-e*80.)*(.15/(1.+i*.1));
        if(i>0.){
            d*=0.;
            e+=1e-3;
        }
    }
    b.rgb=mix(b.rgb,x*b.a,.47);
    b=vec4(tanh(b.rgb*.36),1);
}
