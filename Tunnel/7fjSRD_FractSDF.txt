// ==== Image (image) ====
#define R iResolution
#define T iTime
#define L length
#define S sin
#define C cos
#define V vec3
#define M mat2

M r(float a){float s=S(a),c=C(a);return M(c,-s,s,c);}

V P(float z){return V(S(z*.35)*6.5+C(z*.1)*2.,C(z*.22)*5.5+S(z*.15)*2.5,z);}

float B(V p,V b){V q=abs(p)-b;return L(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);}

float f(V p,float t,out V c,out float e){
    V h=P(p.z),q=p;
    q.xy-=h.xy;
    q.xy*=r(p.z*.15);
    float n=-(L(q.xy)-.5),z=floor(q.z/10.);
    q.z=mod(q.z,10.)-5.;
    q.xy*=r(z*.785+t*.2);
    q.yz*=r(t*.15);
    float s=1.,o=1e4,a=1e4;
    for(int j=0;j<14;j++){
        q=abs(q)-V(1.1,1.4,.8);
        if(q.x<q.y)q.xy=q.yx;
        if(q.x<q.z)q.xz=q.zx;
        if(q.y<q.z)q.yz=q.zy;
        q.xy*=r(.35+t*.02);
        float d=dot(q,q),l=2.8/clamp(d,.12,1.6);
        q*=l;s*=l;o=min(o,d);a=min(a,abs(q.y));
    }
    e=pow(clamp(1.1-a*.4,0.,1.),16.);
    V c1=mix(V(.01,.2,.8),V(.9,.02,.4),clamp(o*.25,0.,1.)),
      c2=mix(V(1,.6,.1),V(.05,.9,.5),S(z*3.14)*.5+.5);
    c=mix(c1,c2,step(.6,fract(z*.41)));
    return max(n,B(q,V(.5,4.,.1))/s);
}

void mainImage(out vec4 O,vec2 U){
    vec2 u=(U-.5*R.xy)/R.y;
    float m=T*.5,tr=1.,t=fract(S(dot(U,vec2(12.9,78.2))+T)*437.5)*.04;
    V ro=P(m),fw=normalize(P(m+2.5)-ro),rt=normalize(cross(V(0,1,0),fw)),up=cross(fw,rt);
    float rl=S(m*.3)*.4+C(m*.6)*.15;
    V rrt=rt*C(rl)+up*S(rl),rup=up*C(rl)-rt*S(rl),
      rd=normalize(fw*(1.1+.4*C(m*.15))+u.x*rrt+u.y*rup),va=V(0);
    for(int i=0;i<200;i++){
        V p=ro+rd*t,fc;float e,d=f(p,m,fc,e),s=max(abs(d),.0015);
        V l=fc*(2.+pow(.5+.5*S(T*4.-t*.3),24.)*15.+e*30.);
        va+=l*(1e-6/(abs(d)+.00001))*exp(-t*.065)*(.079/pow(1.72-.85*dot(rd,fw),1.5))*tr;
        tr*=exp(-s*(.065+e*.5));
        if(tr<.0001||t>60.)break;
        t+=s*.75;
    }
    V c=mix(V(.001,.002,.005)*(1.-L(u)),va*2.2,1.-tr)*1.4;
    c=clamp((c*(2.51*c+.03))/(c*(2.43*c+.59)+.14),0.,1.);
    O=vec4(pow(c,V(.4545))*smoothstep(0.,.15,pow(16.*U.x/R.x*U.y/R.y*(1.-U.x/R.x)*(1.-U.y/R.y),.3)),1);
}
