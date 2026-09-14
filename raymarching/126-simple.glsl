// ==== Image (image) ====
void mainImage(out vec4 O,vec2 C){
    vec2 R=iResolution.xy,u=(C*2.-R)/R.y;
    float t=iTime,d=fract(sin(dot(C,vec2(12.9898,78.233)))*43758.5453)*.02;
    vec3 ro=vec3(0,0,-1.8),rd=normalize(vec3(u,1.4-length(u)*.25)),co=vec3(0);
    mat2 r1=mat2(cos(t*.3),sin(t*.3),-sin(t*.3),cos(t*.3));
    mat2 r2=mat2(cos(t*.2),sin(t*.2),-sin(t*.2),cos(t*.2));
    ro.yz*=r1;rd.yz*=r1;
    ro.xz*=r2;rd.xz*=r2;
    for(int i=0;i<350;i++){
        vec3 p=ro+rd*d;
        float l=length(p);
        if(l<.005){d+=.005;continue;}
        vec3 q=vec3(log(l)-t*.75,exp(-p.z/l+.5),atan(p.x,p.y));
        float e=q.y-1.,s=2.;
        for(int j=0;j<12;j++){
            e-=abs(dot(cos(q.zxy*s),vec3(.2)-sin(q*s)))/s*.42;
            s*=1.95;
        }
        vec3 cb=mix(.5+.5*cos(vec3(0,.35,.75)*6.28318+q.x*2.5-q.z*1.5+t*1.5),vec3(1,.3,.6),sin(l*8.-t*4.)*.5+.5);
        co+=cb*smoothstep(.04,0.,e)*.01*exp(-d*.3)+cb*.0015*exp(-d*.2);
        d+=max(abs(e*l*.3),.002);
        if(d>10.)break;
    }
    co=pow(1.-exp(-co*2.5),vec3(.4545));
    vec2 cu=C/R;
    co*=.5+.5*pow(16.*cu.x*cu.y*(1.-cu.x)*(1.-cu.y),.15);
    co+=(fract(sin(dot(cu+t*.4,vec2(12.9898,78.233)))*43758.5453)-.5)*.025;
    co=clamp(mix(co,vec3(dot(co,vec3(.393,.769,.189)),dot(co,vec3(.349,.686,.168)),dot(co,vec3(.272,.534,.131))),.95)*1.1,0.,1.);
    O=vec4(co,1);
}
