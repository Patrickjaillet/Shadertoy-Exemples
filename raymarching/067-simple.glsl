// ==== Image (image) ====
// https://github.com/Patrickjaillet/Z-GL

void mainImage(out vec4 O,vec2 C){
    vec3 r=vec3(0,1,-18.6),p,d=normalize(vec3((C-.5*iResolution.xy)/iResolution.y,2.5));
    float t=iTime*.4,g=0.,i,j,s,k,m=.5+.5*sin(t*.5),z=0.;
    mat2 a=mat2(cos(t),sin(t),-sin(t),cos(t));
    r.xz*=a;d.xz*=a;r.yz*=a;d.yz*=a;
    vec3 o=mix(vec3(.8,1.2,.4),vec3(1.5,.2,1.1),m),
         l=mix(vec3(1,.5,1.8),vec3(2.2,1.1,.3),m);
    for(i=0.;i<50.;i++){
        p=r+d*z;s=1.2;
        for(j=0.;j<9.;j++){
            p=abs(p)-o;
            if(p.x<p.y)p.xy=p.yx;
            if(p.x<p.z)p.xz=p.zx;
            if(p.y<p.z)p.yz=p.zy;
            p=p*1.6-l*s;s*=.9;
            k=.9+m*.4;
            float s=sin(k),c=cos(k),h=sin(k*.5),u=cos(k*.5);
            p.xy*=mat2(c,s,-s,c);
            p.yz*=mat2(u,h,-h,u);
        }
        float e=(length(p)-(.2+m*.15))*pow(1.6,-8.);
        g+=exp(-e*38.4)*.07;
        if(e<1e-4||z>16.9)break;
        z+=e*.2;
    }
    vec3 c=mix(vec3(1,.2,.05),vec3(1,.5,.1),m)*g;
    c+=vec3(1,.9,.3)*pow(g,2.5);
    O=vec4(mix(c,vec3(.02,.01,.05),1.-exp(-.05*z)),1);
}
