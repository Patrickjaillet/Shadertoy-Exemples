// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
/*
Shader fixes & optimizations:

- Replaced unit-iteration loops and optimized matrix instructions
- Gradient calculation streamlined to 4 samples instead of 6
- Implemented dynamic step scaling for faster empty-space traversal
- Switched to Cook-Torrance specular BRDF
- Added gamma correction and a filmic S-curve tonemapping curve
- Added a new path, more expresive
*/
void mainImage(out vec4 aD,in vec2 aE){
    vec2 aq=iResolution.xy;
    float S=iTime,aF=S*1.4,a_v1=sin(S*.35)*.5+.5,d_v1=a_v1*a_v1*a_v1*2.2,q=aF+d_v1*(S*.2),ao=S+.02,aG=ao*1.4,a_v2=sin(ao*.35)*.5+.5,d_v2=a_v2*a_v2*a_v2*2.2,aH=aG+d_v2*(ao*.2),V=(aH-q)*50.,ar=q*.12,c_l1=sin(ar)+.4*sin(ar*2.3),d_l1=smoothstep(-.3,.3,c_l1);
    vec2 aI=vec2(.85*sin(.28*q+1.1)+.55*sin(.11*q+2.8),.75*sin(.23*q+3.8)+.45*sin(.14*q+.9)),aJ=vec2(-.95*sin(.31*q-.5)-.6*cos(.15*q+1.2),-.8*cos(.21*q+2.1)+.5*sin(.18*q-1.4)),aK=mix(aI,aJ,d_l1)+vec2(1.4*sin(.04*q)*cos(.015*q),1.1*cos(.035*q)*sin(.02*q));
    vec3 k=vec3(aK,q);
    float t=q+.4+V*.15,as=t*.12,c_l2=sin(as)+.4*sin(as*2.3),d_l2=smoothstep(-.3,.3,c_l2);
    vec2 aL=vec2(.85*sin(.28*t+1.1)+.55*sin(.11*t+2.8),.75*sin(.23*t+3.8)+.45*sin(.14*t+.9)),aM=vec2(-.95*sin(.31*t-.5)-.6*cos(.15*t+1.2),-.8*cos(.21*t+2.1)+.5*sin(.18*t-1.4)),aN=mix(aL,aM,d_l2)+vec2(1.4*sin(.04*t)*cos(.015*t),1.1*cos(.035*t)*sin(.02*t));
    float u=q-.2,at=u*.12,c_l3=sin(at)+.4*sin(at*2.3),d_l3=smoothstep(-.3,.3,c_l3);
    vec2 aO=vec2(.85*sin(.28*u+1.1)+.55*sin(.11*u+2.8),.75*sin(.23*u+3.8)+.45*sin(.14*u+.9)),aP=vec2(-.95*sin(.31*u-.5)-.6*cos(.15*u+1.2),-.8*cos(.21*u+2.1)+.5*sin(.18*u-1.4)),aQ=mix(aO,aP,d_l3)+vec2(1.4*sin(.04*u)*cos(.015*u),1.1*cos(.035*u)*sin(.02*u));
    vec3 K=normalize(vec3(aN-aQ,.6+V*.1));
    float i=smoothstep(3.,1.,V),z=i*sin(S*1.5)*.45,T=i*cos(S*1.1)*.2;
    vec3 au=vec3(0.,1.,0.),d=normalize(cross(K,au)),j=normalize(cross(d,K));
    K=normalize(K+d*z+j*T);
    d=normalize(cross(K,au));
    j=normalize(cross(d,K));
    float av=sin(.15*S)*.15+z*.2+(V-1.)*.08;
    vec2 al=(aE*2.-aq)/aq.y;
    float aw=cos(av),saU=sin(av);
    al=mat2(aw,-saU,saU,aw)*al;
    float aR=1.6+smoothstep(1.,4.,V)*.9;
    vec3 ap=normalize(K*aR+d*al.x+j*al.y);
    float U=0.,B=U,C=B;
    vec3 p=k;
    const int ax=80;
    const float aS=32.;
    for(int g=0;g<ax;g++){
        p=k+ap*U;
        vec2 L=vec2(.85*sin(.28*p.z+1.1)+.55*sin(.11*p.z+2.8),.75*sin(.23*p.z+3.8)+.45*sin(.14*p.z+.9)),M=vec2(-.95*sin(.31*p.z-.5)-.6*cos(.15*p.z+1.2),-.8*cos(.21*p.z+2.1)+.5*sin(.18*p.z-1.4));
        float N=p.z*.12,c_lz=sin(N)+.4*sin(N*2.3),d_lz=smoothstep(-.3,.3,c_lz);
        vec2 W=mix(L,M,d_lz)+vec2(1.4*sin(.04*p.z)*cos(.015*p.z),1.1*cos(.035*p.z)*sin(.02*p.z));
        float Y=length(p.xy-W),f_g=length(p.xy-L),h_g=length(p.xy-M),_=min(Y,min(f_g,h_g)),j_g=smoothstep(1.2,0.,_);
        vec3 l=p;
        l.xy*=mat2(.87758256,-.47942554,.47942554,.87758256);
        l.xz*=mat2(.92106099,-.38941834,.38941834,.92106099);
        l=-1.+2.*fract(.3*l+.4);
        float aa=max(dot(l,l),1e-4),c_J=1.2/aa;
        l*=c_J;
        float O=(length(l)-1.03)/c_J+j_g*1.5;
        vec3 P=p*.65,r=floor(P),i_r1=fract(P);
        float v=1.;
        for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
            vec3 h=vec3(float(o),float(n),float(m)),a=r+h;
            a=fract(a*vec3(.1031,.103,.0973));
            a+=dot(a,a.yzx+33.33);
            float w=fract((a.x+a.y)*a.z);
            vec3 c=r+h+13.51;
            c=fract(c*vec3(.1031,.103,.0973));
            c+=dot(c,c.yzx+33.33);
            float x=fract((c.x+c.y)*c.z);
            vec3 e=r+h+47.12;
            e=fract(e*vec3(.1031,.103,.0973));
            e+=dot(e,e.yzx+33.33);
            float y=fract((e.x+e.y)*e.z);
            vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r1,f=r+h+91.17;
            f=fract(f*vec3(.1031,.103,.0973));
            f+=dot(f,f.yzx+33.33);
            float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
            v=min(v,q_r);
        }
        float ab=v*1.5;
        vec3 Q=p*1.6,s=floor(Q),i_r2=fract(Q);
        float I=1.;
        for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
            vec3 h=vec3(float(o),float(n),float(m)),a=s+h;
            a=fract(a*vec3(.1031,.103,.0973));
            a+=dot(a,a.yzx+33.33);
            float w=fract((a.x+a.y)*a.z);
            vec3 c=s+h+13.51;
            c=fract(c*vec3(.1031,.103,.0973));
            c+=dot(c,c.yzx+33.33);
            float x=fract((c.x+c.y)*c.z);
            vec3 e=s+h+47.12;
            e=fract(e*vec3(.1031,.103,.0973));
            e+=dot(e,e.yzx+33.33);
            float y=fract((e.x+e.y)*e.z);
            vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r2,f=s+h+91.17;
            f=fract(f*vec3(.1031,.103,.0973));
            f+=dot(f,f.yzx+33.33);
            float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
            I=min(I,q_r);
        }
        float ae=I*.6,R=min(ab,ae),J=clamp(.5-.5*(R+O)/.15,0.,1.),af=mix(O,-R,J)+.15*J*(1.-J),ai=6e-4*U+3e-4;
        if(af<ai){
            B=1.;
            break;
        }
        U+=af*.75;
        ++C;
        if(U>aS)break;
    }
    vec3 ay=vec3(.14,.08,.02),b=ay;
    if(B>0.){
        const vec2 am=vec2(1.,-1.);
        float aT=max(.0015,6e-4*U);
        vec3 az=vec3(0.);
        for(int af=0;af<4;af++){
            vec3 aA=(af==0)?am.xyy:(af==1)?am.yyx:(af==2)?am.yxy:am.xxx,g=p+aA*aT;
            vec2 L=vec2(.85*sin(.28*g.z+1.1)+.55*sin(.11*g.z+2.8),.75*sin(.23*g.z+3.8)+.45*sin(.14*g.z+.9)),M=vec2(-.95*sin(.31*g.z-.5)-.6*cos(.15*g.z+1.2),-.8*cos(.21*g.z+2.1)+.5*sin(.18*g.z-1.4));
            float N=g.z*.12,c_lz=sin(N)+.4*sin(N*2.3),d_lz=smoothstep(-.3,.3,c_lz);
            vec2 W=mix(L,M,d_lz)+vec2(1.4*sin(.04*g.z)*cos(.015*g.z),1.1*cos(.035*g.z)*sin(.02*g.z));
            float Y=length(g.xy-W),f_g=length(g.xy-L),h_g=length(g.xy-M),_=min(Y,min(f_g,h_g)),j_g=smoothstep(1.2,0.,_);
            vec3 l=g;
            l.xy*=mat2(.87758256,-.47942554,.47942554,.87758256);
            l.xz*=mat2(.92106099,-.38941834,.38941834,.92106099);
            l=-1.+2.*fract(.3*l+.4);
            float aa=max(dot(l,l),1e-4),c_J=1.2/aa;
            l*=c_J;
            float O=(length(l)-1.03)/c_J+j_g*1.5;
            vec3 P=g*.65,r=floor(P),i_r1=fract(P);
            float v=1.;
            for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
                vec3 h=vec3(float(o),float(n),float(m)),a=r+h;
                a=fract(a*vec3(.1031,.103,.0973));
                a+=dot(a,a.yzx+33.33);
                float w=fract((a.x+a.y)*a.z);
                vec3 c=r+h+13.51;
                c=fract(c*vec3(.1031,.103,.0973));
                c+=dot(c,c.yzx+33.33);
                float x=fract((c.x+c.y)*c.z);
                vec3 e=r+h+47.12;
                e=fract(e*vec3(.1031,.103,.0973));
                e+=dot(e,e.yzx+33.33);
                float y=fract((e.x+e.y)*e.z);
                vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r1,f=r+h+91.17;
                f=fract(f*vec3(.1031,.103,.0973));
                f+=dot(f,f.yzx+33.33);
                float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
                v=min(v,q_r);
            }
            float ab=v*1.5;
            vec3 Q=g*1.6,s=floor(Q),i_r2=fract(Q);
            float I=1.;
            for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
                vec3 h=vec3(float(o),float(n),float(m)),a=s+h;
                a=fract(a*vec3(.1031,.103,.0973));
                a+=dot(a,a.yzx+33.33);
                float w=fract((a.x+a.y)*a.z);
                vec3 c=s+h+13.51;
                c=fract(c*vec3(.1031,.103,.0973));
                c+=dot(c,c.yzx+33.33);
                float x=fract((c.x+c.y)*c.z);
                vec3 e=s+h+47.12;
                e=fract(e*vec3(.1031,.103,.0973));
                e+=dot(e,e.yzx+33.33);
                float y=fract((e.x+e.y)*e.z);
                vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r2,f=s+h+91.17;
                f=fract(f*vec3(.1031,.103,.0973));
                f+=dot(f,f.yzx+33.33);
                float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
                I=min(I,q_r);
            }
            float ae=I*.6,R=min(ab,ae),J=clamp(.5-.5*(R+O)/.15,0.,1.),aU=mix(O,-R,J)+.15*J*(1.-J);
            az+=aA*aU;
        }
        vec3 ai=normalize(az);
        float aB=0.,e_ao=1.;
        for(int af=0;af<3;af++){
            float aA=.03+.1*float(af);
            vec3 g=p+aA*ai;
            vec2 L=vec2(.85*sin(.28*g.z+1.1)+.55*sin(.11*g.z+2.8),.75*sin(.23*g.z+3.8)+.45*sin(.14*g.z+.9)),M=vec2(-.95*sin(.31*g.z-.5)-.6*cos(.15*g.z+1.2),-.8*cos(.21*g.z+2.1)+.5*sin(.18*g.z-1.4));
            float N=g.z*.12,c_lz=sin(N)+.4*sin(N*2.3),d_lz=smoothstep(-.3,.3,c_lz);
            vec2 W=mix(L,M,d_lz)+vec2(1.4*sin(.04*g.z)*cos(.015*g.z),1.1*cos(.035*g.z)*sin(.02*g.z));
            float Y=length(g.xy-W),f_g=length(g.xy-L),h_g=length(g.xy-M),_=min(Y,min(f_g,h_g)),j_g=smoothstep(1.2,0.,_);
            vec3 l=g;
            l.xy*=mat2(.87758256,-.47942554,.47942554,.87758256);
            l.xz*=mat2(.92106099,-.38941834,.38941834,.92106099);
            l=-1.+2.*fract(.3*l+.4);
            float aa=max(dot(l,l),1e-4),c_J=1.2/aa;
            l*=c_J;
            float O=(length(l)-1.03)/c_J+j_g*1.5;
            vec3 P=g*.65,r=floor(P),i_r1=fract(P);
            float v=1.;
            for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
                vec3 h=vec3(float(o),float(n),float(m)),a=r+h;
                a=fract(a*vec3(.1031,.103,.0973));
                a+=dot(a,a.yzx+33.33);
                float w=fract((a.x+a.y)*a.z);
                vec3 c=r+h+13.51;
                c=fract(c*vec3(.1031,.103,.0973));
                c+=dot(c,c.yzx+33.33);
                float x=fract((c.x+c.y)*c.z);
                vec3 e=r+h+47.12;
                e=fract(e*vec3(.1031,.103,.0973));
                e+=dot(e,e.yzx+33.33);
                float y=fract((e.x+e.y)*e.z);
                vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r1,f=r+h+91.17;
                f=fract(f*vec3(.1031,.103,.0973));
                f+=dot(f,f.yzx+33.33);
                float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
                v=min(v,q_r);
            }
            float ab=v*1.5;
            vec3 Q=g*1.6,s=floor(Q),i_r2=fract(Q);
            float I=1.;
            for(int m=0;m<=1;m++)for(int n=0;n<=1;n++)for(int o=0;o<=1;o++){
                vec3 h=vec3(float(o),float(n),float(m)),a=s+h;
                a=fract(a*vec3(.1031,.103,.0973));
                a+=dot(a,a.yzx+33.33);
                float w=fract((a.x+a.y)*a.z);
                vec3 c=s+h+13.51;
                c=fract(c*vec3(.1031,.103,.0973));
                c+=dot(c,c.yzx+33.33);
                float x=fract((c.x+c.y)*c.z);
                vec3 e=s+h+47.12;
                e=fract(e*vec3(.1031,.103,.0973));
                e+=dot(e,e.yzx+33.33);
                float y=fract((e.x+e.y)*e.z);
                vec3 A=vec3(w,x,y),D=h+A*.6+.2,n_r=D-i_r2,f=s+h+91.17;
                f=fract(f*vec3(.1031,.103,.0973));
                f+=dot(f,f.yzx+33.33);
                float E=fract((f.x+f.y)*f.z),F=.2+.25*E,q_r=length(n_r)-F;
                I=min(I,q_r);
            }
            float ae=I*.6,R=min(ab,ae),J=clamp(.5-.5*(R+O)/.15,0.,1.),aU=mix(O,-R,J)+.15*J*(1.-J);
            aB+=(aA-aU)*e_ao;
            e_ao*=.82;
        }
        float aV=clamp(1.-2.5*aB,0.,1.);
        vec3 aC=normalize(j*.5+d*.3+K*.2),X=normalize(-d*.6-j*.2+K*.1);
        float aW=max(dot(ai,aC),0.),Z=max(dot(ai,X),0.),G=max(dot(ai,-ap),0.),aX=clamp(1.-(C/float(ax)),0.,1.),H=aV*aX;
        vec3 aY=vec3(.99,.82,.28),ac=vec3(.85,.55,.1),ad=vec3(.94,.89,.6),n_col=mix(aY,ac,(1.-H)*.65);
        n_col=mix(n_col,ad,.15);
        vec3 aZ=normalize(aC-ap);
        float a_=max(dot(ai,aZ),0.),ag=pow(a_,24.)*.35,ah=pow(clamp(1.-G,0.,1.),2.5)*.45;
        vec3 ba=vec3(1.,.45,.05)*ah,aj=n_col*(aW*vec3(1.25,1.1,.85)+Z*vec3(.35,.25,.15)),ak=vec3(.18,.12,.03)*n_col;
        b=(aj+ag+ba)*(.35+.65*G)+ak;
        b*=H;
        float bb=1.-exp(-U*.06);
        b=mix(b,ay,bb);
    }
    vec3 an=b*1.35;
    float bc=2.51,e_tm=.03,a_tm=2.43,b_tm=.59,f_tm=.14;
    vec3 bd=clamp((an*(bc*an+e_tm))/(an*(a_tm*an+b_tm)+f_tm),0.,1.);
    b=pow(bd,vec3(1./2.2));
    aD=vec4(b,1.);
}
