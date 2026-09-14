// ==== Image (image) ====
void mainImage(out vec4 G,in vec2 H){
    vec2 I=(H-.5*iResolution.xy)/iResolution.y;
    float o=iTime*.15,j=smoothstep(-.2,.4,sin(o)),s=iTime*.1;
    vec3 k=vec3(sin(s)*18.,6.+sin(iTime*.3)*2.,cos(s)*18.),J=vec3(0.,1.,0.),p=normalize(J-k),K=vec3(sin(0.),cos(0.),0.),t=normalize(cross(p,K)),L=cross(t,p);
    mat3 M=mat3(t,L,p);
    vec3 e=M*normalize(vec3(I,1.5)),q=normalize(vec3(cos(o),sin(o),.4)),N=mix(vec3(1.,.6,.3),vec3(.35,.65,.95),clamp(e.y+.2,0.,1.)),O=mix(vec3(.02,.01,.08),vec3(.005,.005,.02),clamp(e.y+.2,0.,1.)),r=mix(N,O,j);
    float P=max(0.,dot(e,q));
    r+=vec3(1.,.8,.4)*pow(P,32.)*(1.-j);
    bool u=false;
    vec3 v=vec3(0.),w=v;
    int f=0;
    float A=0.;
    vec3 a=floor(k),B=1./e,l=sign(e),g=(a-k+.5+l*.5)*B,m=w;
    for(int C=0;C<128;C++){
        int c=0;
        if(a.y>=-10.){
            float D=sin(a.x*.1)*cos(a.z*.1)*3.;
            D+=sin(a.x*.25+a.z*.15)*1.5;
            float E=floor(D),n=floor(a.y);
            if(n<E)c=1;
            else if(n==E)c=2;
            else{
                vec2 b=floor(a.xz/8.)*8.+4.,h_noise=fract(b*vec2(123.34,456.21));
                h_noise+=dot(h_noise,h_noise+45.32);
                float Q=fract(h_noise.x*h_noise.y);
                if(Q>.6){
                    float F=sin(b.x*.1)*cos(b.y*.1)*3.;
                    F+=sin(b.x*.25+b.y*.15)*1.5;
                    float R=floor(F);
                    vec3 i=vec3(b.x,R+1.,b.y);
                    if(floor(a.x)==i.x&&floor(a.z)==i.z)if(n>=i.y&&n<i.y+4.)c=3;
                    vec3 S=i+vec3(0.,4.,0.);
                    if(length(floor(a)-S)<=2.2)c=4;
                }
            }
        }
        if(c>0){
            u=true;
            v=a;
            w=-m*l;
            f=c;
            A=length(a+.5-k);
            break;
        }
        m=step(g.xyz,g.yzx)*step(g.xyz,g.zxy);
        g+=m*l*B;
        a+=m*l;
    }
    vec3 d=r;
    if(u){
        vec3 b=vec3(1.);
        if(f==1)b=vec3(.45,.35,.23);
        else if(f==2)b=vec3(.25,.65,.15);
        else if(f==3)b=vec3(.35,.22,.1);
        else if(f==4)b=vec3(.12,.52,.18);
        vec3 c_noise=fract(v*vec3(.1031,.103,.0973));
        c_noise+=dot(c_noise,c_noise.yxz+33.33);
        vec3 i_noise=fract((c_noise.xxy+c_noise.yxx)*c_noise.zyx);
        b*=.85+.3*i_noise.x;

        if (f<=2 && w.y>0.5) {
            float t_hit=(v.y+0.5-k.y)/e.y;
            vec3 exactPos=k+e*t_hit;
            vec2 rp=exactPos.xz*3.5;
            vec2 r_id=floor(rp);
            vec2 r_fuv=fract(rp);
            float isRoach=0.0;
            float rShadow=1.0;
            
            for(int X=-1; X<=1; X++) {
                for(int Y=-1; Y<=1; Y++) {
                    vec2 off=vec2(float(X),float(Y));
                    vec2 cId=r_id+off;
                    vec2 h=fract(sin(vec2(dot(cId,vec2(127.1,311.7)),dot(cId,vec2(269.5,183.3))))*43758.5453);
                    if(h.x>0.4) continue;
                    
                    float rt=iTime*(1.5+h.y);
                    float dash=smoothstep(0.3,0.7,sin(rt*0.5+h.y*10.0));
                    float tM=rt*0.2+dash*rt*2.0;
                    vec2 lPos=vec2(0.5)+vec2(sin(tM),cos(tM*0.8))*0.35;
                    
                    float hide=sin(cId.x*0.5)*cos(cId.y*0.5+iTime*0.15);
                    float s_mult=1.0+step(0.7,h.y)*1.8;
                    float r_scale=smoothstep(-0.15,0.25,hide)*s_mult;
                    if(r_scale<0.01) continue;
                    
                    float tMp=(rt-0.05)*0.2+smoothstep(0.3,0.7,sin((rt-0.05)*0.5+h.y*10.0))*(rt-0.05)*2.0;
                    vec2 lPosp=vec2(0.5)+vec2(sin(tMp),cos(tMp*0.8))*0.35;
                    vec2 dir=normalize(lPos-lPosp+1e-4);
                    
                    vec2 diff=r_fuv-(off+lPos);
                    float ang=atan(dir.y,dir.x);
                    float r_cs=cos(ang),r_sn=sin(ang);
                    diff=mat2(r_cs,r_sn,-r_sn,r_cs)*diff;
                    diff/=max(r_scale,0.001);
                    
                    vec2 aDiff=vec2(abs(diff.x),abs(diff.y));
                    float lAnim=sin(iTime*60.0)*dash;
                    
                    float bd=length(diff*vec2(1.0,2.5))-0.04;
                    float lg1=length(vec2(aDiff.x-0.02,aDiff.y-0.06+lAnim*0.02))-0.004;
                    float lg2=length(vec2(diff.x,aDiff.y-0.06-lAnim*0.02))-0.004;
                    float lg3=length(vec2(aDiff.x+0.02,aDiff.y-0.06+lAnim*0.02))-0.004;
                    float ant=length(vec2(diff.x-0.06,aDiff.y-0.02))-0.003;
                    
                    float rd=min(bd,min(min(lg1,lg2),min(lg3,ant)));
                    if(rd<0.0) isRoach=1.0;
                    rShadow=min(rShadow,smoothstep(0.0,0.1,rd*r_scale));
                }
            }
            if(isRoach>0.5) b=vec3(0.05,0.01,0.005);
            else b*=mix(0.3,1.0,rShadow);
        }

        vec3 h_dir=q;
        if(h_dir.y<-.1)h_dir=-q;
        float n_dot=max(.05,dot(w,h_dir));
        vec3 C_color=mix(vec3(1.,.9,.7),vec3(.2,.3,.6),j),D_color=mix(vec3(.3,.4,.5),vec3(.05,.05,.12),j);
        d=b*(n_dot*C_color+D_color);
        float E_fog=1.-exp(-A*.025);
        d=mix(d,r,E_fog);
    }
    d=pow(d,vec3(.4545));
    G=vec4(d,1.);
}
