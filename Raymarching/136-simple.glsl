// ==== Image (image) ====
void mainImage(out vec4 O,vec2 C){
    vec2 R=iResolution.xy,u=(C-.5*R)/R.y;
    float b=0.,T=iTime,s,c,m,d;
    for(int i=0;i<3;i++){
        float fi=float(i);
        vec2 p=u*(1.+fi);
        float a=T*.44+fi*.1+length(u);
        s=sin(a);c=cos(a);
        p*=mat2(c,-s,s,c);
        m=0.;
        for(int j=0;j<8;j++){
            float t=T+fi;
            s=sin(.15+.03*sin(t));c=cos(.15+.03*sin(t));
            p*=mat2(c,-s,s,c);
            p=abs(p)-vec2(.45,.35);
            if(p.x<p.y)p=p.yx;
            d=max(dot(p,p),.03);
            p=p*.54/d-vec2(sin(t),0);
            m+=exp(-d*16.);
        }
        b+=m;
    }
    O=vec4(1.-exp(-(vec3(b*.04))*(1.-smoothstep(1.,7.2,length(u)))*7.2),0);
}
