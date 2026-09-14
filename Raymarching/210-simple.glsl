// ==== Image (image) ====
void mainImage(out vec4 U,in vec2 I){
    const float j[5]=float[5](8.,3.,8.,6.,10.);
    const vec3 k[5]=vec3[5](vec3(0.),vec3(0.),vec3(.3,.2,.5),vec3(-.5,.1,.4),vec3(.1,-.3,.2));
    const float l[5]=float[5](0.,0.,1.,1.,.7);
    const vec3 c[8]=vec3[8](vec3(.95,.15,.1),vec3(.98,.5,.05),vec3(.95,.85,.1),vec3(.1,.85,.25),vec3(.05,.75,.95),vec3(.2,.3,.95),vec3(.65,.15,.9),vec3(.95,.2,.6));
    vec3 h=vec3(0.);
    for(int u=0;u<2;u++)for(int v=0;v<2;v++){
        vec2 V=(vec2(float(v),float(u))/2.-.5)/iResolution.y,J=(I-.5*iResolution.xy)/iResolution.y+V;
        float w=iTime*.2;
        vec3 z=vec3(2.5*sin(w),1.3*cos(w*.7),2.5*cos(w)),W=vec3(0.),A=normalize(W-z),K=normalize(cross(A,vec3(0.,1.,0.))),X=cross(K,A),B=normalize(A+J.x*K+J.y*X);
        float m=0.,L=m;
        vec3 n=W;
        float o=L;
        for(int E=0;E<256;E++){
            vec3 a=z+B*o;
            float e,jmix;
            vec3 F;
            float N=25.,O=mod(iTime,N),G=O/5.;
            int f=int(floor(G))%5,q=(f+1)%5;
            float P=fract(G),r=smoothstep(.8,1.,P);
            e=mix(j[f],j[q],r);
            F=mix(k[f],k[q],r);
            jmix=mix(l[f],l[q],r);
            vec3 b=a;
            float s=1.,d,Q=4.,H=0.;
            vec3 t=vec3(1e10);
            for(int i=0;i<16;i++){
                d=length(b);
                if(d>Q)break;
                t=min(t,abs(b));
                float g=acos(b.z/d),C=atan(b.y,b.x);
                s=pow(d,e-1.)*e*s+1.;
                float R=pow(d,e);
                g*=e;
                C*=e;
                b=R*vec3(sin(g)*cos(C),sin(C)*sin(g),cos(g));
                b+=mix(a,F,jmix);
                ++H;
            }
            m=H/16.;
            n=t;
            float D=.5*log(d)*d/s;
            L+=exp(-3.*D)*(1.+m*2.);
            o+=D;
            if(o>60.||abs(D)<2e-4)break;
        }
        float M=o;
        vec3 p=vec3(0.);
        if(M<60.){
            vec3 a=z+B*M,C;
            {
                vec2 e=vec2(.001,0.);
                vec3 ao[6],Y[6]=vec3[6](a+e.xyy,a-e.xyy,a+e.yxy,a-e.yxy,a+e.yyx,a-e.yyx);
                float b[6];
                for(int q=0;q<6;q++){
                    vec3 N=Y[q];
                    float f,jmixS;
                    vec3 O;
                    float Z=25.,_=mod(iTime,Z),P=_/5.;
                    int r=int(floor(P))%5,D=(r+1)%5;
                    float aa=fract(P),E=smoothstep(.8,1.,aa);
                    f=mix(j[r],j[D],E);
                    O=mix(k[r],k[D],E);
                    jmixS=mix(l[r],l[D],E);
                    vec3 g=N;
                    float F=1.,d,ab=4.;
                    for(int i=0;i<16;i++){
                        d=length(g);
                        if(d>ab)break;
                        float s=acos(g.z/d),G=atan(g.y,g.x);
                        F=pow(d,f-1.)*f*F+1.;
                        float ac=pow(d,f);
                        s*=f;
                        G*=f;
                        g=ac*vec3(sin(s)*cos(G),sin(G)*sin(s),cos(s));
                        g+=mix(N,O,jmixS);
                    }
                    b[q]=.5*log(d)*d/F;
                }
                float ad=b[0]-b[1],ae=b[2]-b[3],af=b[4]-b[5];
                C=normalize(vec3(ad,ae,af));
            }
            float H=.5;
            vec3 Q=vec3(3.*cos(iTime*H),1.5*sin(iTime*H*.7),3.*sin(iTime*H)),R=normalize(Q-a);
            float S=length(Q-a),ag=1.5/(1.+.3*S*S),ah=max(dot(C,R),0.);
            vec3 ai=normalize(R-B);
            float aj=pow(max(dot(C,ai),0.),64.)*.5,ak=.25,al=.8+.2*(1.-m),t=(ah*.8+aj)*ag+ak;
            t*=al;
            t=pow(t,1.1);
            vec3 T;
            {
                float d=smoothstep(0.,1.5,length(a)),e=smoothstep(0.,.8,n.x),f=smoothstep(0.,.8,n.y),g=smoothstep(0.,.8,n.z),i=smoothstep(0.,1.,m),q=smoothstep(-1.,1.,sin(a.x*4.+a.y*4.)),r=smoothstep(-1.,1.,cos(a.z*6.));
                vec3 b=c[0];
                b=mix(b,c[1],d);
                b=mix(b,c[2],e);
                b=mix(b,c[3],f);
                b=mix(b,c[4],g);
                b=mix(b,c[5],i);
                b=mix(b,c[6],q);
                b=mix(b,c[7],r);
                T=b;
            }
            p=T*t;
        }
        else{
            float a=1.-exp(-7.2);
            p=mix(vec3(0.),vec3(.05),a);
        }
        vec3 am=mix(c[4],c[1],sin(iTime*.3)*.5+.5);
        p+=am*L*.015;
        h+=p;
    }
    h/=4.;
    vec2 an=(I-.5*iResolution.xy)/iResolution.y;
    h=mix(h,vec3(.08),1.-exp(-.5*length(an)));
    U=vec4(h,1.);
}
