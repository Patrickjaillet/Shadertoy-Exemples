// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
**************************************************************/
#define F float
F H(float p){p=fract(p);p*=p;p*=p+p;return fract(p);}
mat2 R(float a){F c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
F S(vec3 p,F r){return length(p)-r;}
F B(vec3 p,vec3 b){vec3 q=abs(p)-b;return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);}
F T(vec3 p,vec2 t){return length(vec2(length(p.xz)-t.x,p.y))-t.y;}
F O(vec3 p,F s){p=abs(p);return(p.x+p.y+p.z-s)*.57735027;}

F G(int c,vec2 u){
    if(u.x<0.||u.x>1.||u.y<0.||u.y>1.)return 0.;
    return texture(iChannel1,(vec2(mod(F(c),16.),15.-floor(F(c)/16.))+u)/16.).r;
}

F L1(vec2 u,F s){
    u/=s;int a[10]=int[](83,65,78,68,69,70,74,79,82,68);
    u.x+=2.75;u.y+=.5;int i=int(floor(u.x/.55));
    if(i<0||i>=10)return 0.;
    return G(a[i],vec2(fract(u.x/.55),u.y));
}

F L2(vec2 u,F s){
    u/=s;int a[8]=int[](80,114,101,115,101,110,116,115);
    u.x+=2.2;u.y+=.5;int i=int(floor(u.x/.55));
    if(i<0||i>=8)return 0.;
    return G(a[i],vec2(fract(u.x/.55),u.y));
}

F L3(vec2 u,float s){
    u/=s;int a[15]=int[](84,101,99,104,110,111,32,68,101,109,111,32,50,48,50);
    u.x+=4.4;u.y+=.5;int i=int(floor(u.x/.55));
    if(i<0||i>=16)return 0.;
    return G(i<15?a[i]:54,vec2(fract(u.x/.55),u.y));
}

vec3 P(F t,F m){
    vec3 a=mix(vec3(.7),mix(vec3(.5),vec3(.3,.4,.6),clamp(m-1.,0.,1.)),step(.5,m)),
         b=mix(vec3(1),mix(vec3(.5),vec3(.8,.5,.4),clamp(m-1.,0.,1.)),step(.5,m)),
         c=mix(vec3(1),mix(vec3(2,1,0),vec3(1),clamp(m-1.,0.,1.)),step(.5,m)),
         d=mix(vec3(0,.33,.67),mix(vec3(.5,.2,.25),vec3(.1,.5,.8),clamp(m-1.,0.,1.)),step(.5,m));
    if(m>2.5){a=b=vec3(.5);c=vec3(1,.7,.4);d=vec3(0,.15,.2);}
    return a+b*cos(6.28318530718*(c*t+d));
}

vec3 TP(vec2 u,F t,F b,F m,F h,F K){
    vec2 c=u*vec2(23,32);
    if(K>.5&&K<=1.5)c=u*vec2(12,64);
    if(K>1.5&&K<=2.5)c=u*vec2(40,16);
    if(K>2.5)c=u*vec2(8,80);
    vec2 id=floor(c);id.y=mod(id.y,192.);
    F ch=H(dot(id,vec2(12.9898,78.233))),lt=.05+h*.03;
    vec2 f=fract(c);
    F gx=smoothstep(0.,lt,f.x)*smoothstep(0.,lt,1.-f.x),
         gy=smoothstep(0.,lt,f.y)*smoothstep(0.,lt,1.-f.y),
         g=gx*gy;
    if(K>.5&&K<=1.5)g=step(.1,g);
    if(K>1.5&&K<=2.5)g=sin(g*6.28318);
    if(K>2.5)g=smoothstep(.2,.3,g*f.x);
    vec3 base=P(ch+t*.04,K)*(.3+b*.15);
    F vs=K>2.5?16.:K>1.5?1.:K>.5?8.:3.,
         vp=fract(u.x*vs-t*(1.3+b*.4)+ch*5.),
         v=smoothstep(.05,0.,abs(vp-.5));
    vec3 vc=P(ch+.2+m*.15,K);
    return base*g+vc*v*(1.3+m*.6)+(1.-g)*vc*(.15+h*.2);
}

vec3 RT(vec2 p,F t,F b,F m,F h,F K){
    if(K>.5&&K<=1.5){p=abs(p)*(1.2+b*.1);}
    else if(K>1.5&&K<=2.5){p=R(.785398)*p;p=abs(p)-.2;p*=.8-b*.1;}
    else if(K>2.5){p=vec2(p.x/(1.+.5*abs(p.y)),p.y/(1.+.5*abs(p.x)))*(.9+b*.05);}
    else{p*=.75-b*.05;}
    F a=atan(p.y,p.x),r=length(p);
    if(K<=.5)a+=sin(.5*r-.5*t);
    else if(K<=1.5)a+=cos(1.5*r+.8*t);
    else if(K<=2.5)a+=sin(2.*a+t)*.2;
    else a+=sin(r*8.-t*2.)*.15;
    F hv=.5+.5*cos(a),s=smoothstep(.4,.5,hv);
    vec2 u=vec2(t*(.6+b*.3)+1./(r+.1*s),a/3.14159265359);
    vec3 col=TP(u,t,b,m,h,K);
    col*=1.-.6*(smoothstep(0.,.3,hv)-smoothstep(.5,1.,hv))*r;
    vec3 fc=K>2.5?vec3(.6,.1,.8):K>1.5?vec3(.1,.7,.4):K>.5?vec3(.8,.2,.1):vec3(.4,.5,.7);
    col=mix(col*fc,col,smoothstep(0.,.5,r))*r*(1.+b*.2);
    vec3 glow=vec3(0);
    for(int i=0;i<121;i++){
        F fi=F(i),
             sp=.25+H(fi*12.4+1.),
             ph=fract(t*sp+H(fi*30.8+8.)),
             rp=1.5*ph,
             ap=H(fi*5.3+3.)*6.2831853+.6*sin(.3*t+fi)+sin(.5*rp-.5*t),
             da=atan(sin(a-ap),cos(a-ap)),
             dr=r-rp,
             al=da*max(rp,.05),
             m2=K>2.5?5.:K>1.5?18.:K>.5?2.:9.,
             d2=al*al+dr*dr*m2,
             sz=mix(.0006,.0022,H(fi*36.4+10.9))*(1.+h*1.2),
             fa=smoothstep(0.,.85,ph);
        glow+=sz/(d2+sz)*P(H(fi*11.3+5.)+h*.1,K)*(1.5+fa)*(1.+m*.5);
    }
    return col+glow;
}

F MO(vec3 p,F o,F b,F m){
    p.xy*=R(iTime*.8);p.xz*=R(iTime*.5);
    F s=.45+b*.25; 
    if(o<.5)return S(p,s);
    if(o<1.5)return B(p,vec3(s*.75));
    if(o<2.5)return T(p,vec2(s*.7,s*.25+m*.05));
    return O(p,s*1.1);
}

vec3 GO(vec3 p,F o,F b,F m){
    vec2 e=vec2(.001,0);
    return normalize(vec3(
        MO(p+e.xyy,o,b,m)-MO(p-e.xyy,o,b,m),
        MO(p+e.yxy,o,b,m)-MO(p-e.yxy,o,b,m),
        MO(p+e.yyx,o,b,m)-MO(p-e.yyx,o,b,m)
    ));
}

F SText(vec2 u, F t, F scale) {
    u /= scale;
    u.y -= sin(u.x * 2.5 + t * 4.0) * 0.2; 
    u.x += t * 3.5; 
    int txt[54] = int[](
        83,65,78,68,69,70,74,79,82,68,32,
        42,42,42,32,
        84,69,67,72,78,79,32,68,69,77,79,32,
        42,42,42,32,
        50,48,50,54,32,
        42,42,42,32,
        83,72,65,68,69,82,84,79,89,46,67,79,77,32
    );
    F spacing = 0.5;
    F totalLen = F(54) * spacing;
    u.x = mod(u.x, totalLen);
    int idx = int(floor(u.x / spacing));
    if(idx < 0 || idx >= 54) return 0.0;
    vec2 charUV = vec2(fract(u.x / spacing), u.y + 0.5);
    return G(txt[idx], charUV);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    F rb=texture(iChannel0,vec2(.03,0)).x,
         b=smoothstep(.2,.8,rb),
         m=smoothstep(.2,.8,texture(iChannel0,vec2(.25,0)).x),
         h=smoothstep(.2,.8,texture(iChannel0,vec2(.75,0)).x),
         t=iTime,
         pi=floor(t/10.),
         tp=mod(t,10.),
         K=mod(pi+step(8.,tp)*step(.65,rb),4.);

    F bpm = 130.0;
    F beat = t * (bpm / 60.0);
    F beatIndex = floor(beat);
    F isKickStep8 = step(0.5, rb) * step(7.5, mod(beatIndex, 8.0));
    
    vec2 p=(-iResolution.xy+2.*fragCoord)/iResolution.y;

    if(isKickStep8 > 0.0){
        vec2 shake = (vec2(H(t*120.0), H(t*120.0+17.3)) - 0.5) * 0.12 * rb;
        p += shake;
    }

    vec3 bg=RT(p,t,b,m,h,K),col=bg;
    F op=mod(t,20.),aw=smoothstep(4.,5.5,op)-smoothstep(14.,15.5,op);
    
    vec3 halo = vec3(0);

    if(aw>.001){
        F ot=mod(floor(t/20.),4.);
        vec3 ro=vec3(0,0,-2.2),rd=normalize(vec3(p,1.5)),pH;
        F dO=0.,dS=0.;bool hit=false;
        for(int i=0;i<48;i++){
            pH=ro+rd*dO;dS=MO(pH,ot,b,m);dO+=dS;
            if(dS<.001){hit=true;break;}
            if(dO>5.)break;
        }
        
        F dist = length(p);
        F glowIntensity = b * 0.25 * aw;
        vec3 glowColor = P(t * 0.2, K);
        halo = glowColor * (glowIntensity / (dist * dist + 0.35));

        if(hit){
            vec3 N=GO(pH,ot,b,m),Ref=reflect(rd,N);
            vec2 rUV=Ref.xy/(abs(Ref.z)+.2);
            vec3 rc=RT(rUV,t,b,m,h,K);
            F fr=pow(1.-max(0.,dot(-rd,N)),3.);
            vec3 sp=vec3(1)*pow(max(0.,dot(Ref,vec3(0,0,-1))),16.)*(.5+h),
                 oc=mix(rc*.85,vec3(1),fr*.4)+sp;
            col=mix(bg,oc,aw);
        }
        
        col += halo;
    }
    if(t<5.0){
        F gl=smoothstep(3.5,5.,t);
        vec2 u1=p-vec2(0,.22),u2=p,u3=p-vec2(0,-.22);
        if(gl>0.){
            if(H(floor(u1.y*20.)+floor(t*30.))<gl*.8)u1.x+=(H(floor(u1.y*50.)+t*50.)-.5)*.25*gl;
            if(H(floor(u2.y*20.)+floor(t*30.))<gl*.8)u2.x+=(H(floor(u2.y*50.)+t*50.)-.5)*.25*gl;
            if(H(floor(u3.y*20.)+floor(t*30.))<gl*.8)u3.x+=(H(floor(u3.y*50.)+t*50.)-.5)*.25*gl;
        }
        F t1=L1(u1,.16),t2=L2(u2,.1),t3=L3(u3,.09),
             ta=clamp(t1+t2+t3,0.,1.)*(1.-smoothstep(4.2,5.,t));
        vec3 tc=vec3(1,.9,.7)+P(t*.5,0.)*.4+vec3(b*.6);
        col=mix(col,tc,ta);
    }

    F scale = 0.18; 
    vec2 su = p - vec2(0.0, -0.65); 
    
    F shadow = SText(su - vec2(0.02, -0.02), t, scale);
    F textAlpha = SText(su, t, scale);
    vec3 textCol = P(t * 0.4 + p.x * 0.2, K) * (1.3 + h * 0.8) + vec3(b * 0.5);
    col = mix(col, vec3(0.0), shadow * 0.65);
    col = mix(col, textCol, textAlpha);

    col*=(1.-(15.+b*10.)*.01*dot(p,p));

    if(t > 45.0){
        F rnd = H(floor(t * 24.0));
        F isKick = step(.35, rb);
        F isRandom = step(.4, rnd);
        F flash = isKick * isRandom * rb * 4.0;
        col += vec3(flash);
    }

    fragColor=vec4(col,1);
}
