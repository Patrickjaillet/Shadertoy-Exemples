// ==== Image (image) ====
mat2 r2d(float a){float s=sin(a),c=cos(a);return mat2(c,-s,s,c);}
float fSDF(vec3 p,float t){
    float s=1.;
    for(int i=0;i<8;i++){
        p=abs(p)-vec3(5.4,7.6,6.7);
        p.xy*=r2d(t*-.1+float(i));
        p.yz*=r2d(t*.1);
        p*=1.8;s*=1.8;
    }
    return(length(p)-1.2)/s;
}
float map(vec3 p,float t){
    return max(length(p)-44.3+dot(sin(p*.5+t),cos(p.yzx-t))*4.3,fSDF(p*.3,t)*6.1);
}
vec3 getNormal(vec3 p,float t){
    vec2 e=vec2(.001,0.);
    return normalize(vec3(map(p+e.xyy,t)-map(p-e.xyy,t),map(p+e.yxy,t)-map(p-e.yxy,t),map(p+e.yyx,t)-map(p-e.yyx,t)));
// https://github.com/Patrickjaillet/Z-GL
}
void mainImage(out vec4 fragColor,vec2 fragCoord){
    vec2 uv=(fragCoord-iResolution.xy)/iResolution.y;
    vec3 ro=vec3(2.,-2.,-80.),rd=normalize(vec3(uv,1.5)),col=vec3(.4),p;
    mat2 rm=r2d(iTime*.15);ro.xz*=rm;rd.xz*=rm;
    float dO=0.;
    for(int i=0;i<50;i++){
        p=ro+rd*dO;
        float dS=map(p,iTime);
        col+=mix(vec3(1.,0.,1.),vec3(0.,.6,.4),sin(iTime+p.z*.1)*.5+.5)*exp(-dS)*.09;
        if(abs(dS)<.1||dO>100.)break;
        dO+=dS*.77;
    }
    if(dO<100.){
        vec3 n=getNormal(p,iTime);
        col+=vec3(1.,0.,0.)*max(dot(n,normalize(vec3(5.,0.,-1.))),0.)+vec3(1.,.9,.7)*.5;
    }
    col=mix(col,vec3(0.),1.-exp(-1e-05*dO*dO*dO))*(1.-smoothstep(1.,2.6,length(uv)));
    vec3 x=col*2.7;
    col=clamp((x*(5.15*x+.18))/(x*vec3(1.)+.23),0.,.8);
    fragColor=vec4(sqrt(col),0.);
}
