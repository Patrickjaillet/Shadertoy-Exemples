// ==== Image (image) ====
void mainImage(out vec4 fragColor,in vec2 fragCoord){
    F bass=smoothstep(.2,.8,texture(iChannel0,vec2(.03,0.)).x);
    F mid=smoothstep(.2,.8,texture(iChannel0,vec2(.25,0.)).x);
    F high=smoothstep(.2,.8,texture(iChannel0,vec2(.75,0.)).x);
    F bp=pow(abs(sin(iTime*PI*2.1667)),8.);
    vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
    float t=iTime;
    float sec=mod(t,20.);
    
    vec4 A=texture(iChannel1,fragCoord/iResolution.xy);
    vec4 B=texture(iChannel2,fragCoord/iResolution.xy);
    
    vec2 m=fragCoord/iResolution.xy*.6-vec2(.4,-.6);
    vec3 n=vec3(m,.3),f=vec3(.7,-8.,-2.7),g=vec3(0.);
    float c=0.,d=0.,bb=0.;
    vec3 h[8]=vec3[8](vec3(.98,.7,.75),vec3(.98,.82,.65),vec3(.99,.96,.68),vec3(.72,.93,.78),
                      vec3(.67,.88,.95),vec3(.73,.76,.96),vec3(.88,.72,.95),vec3(.95,.75,.87));
    for(float e=0.;e<90.;++e){
        float o=clamp(min(c*bb,.6)/41.3,0.,1.);float ii=mod(e*.15+c*2.+t*.2,8.);
        int j=int(ii);int p=(j+1)&7;g+=o*mix(h[j],h[p],smoothstep(0.,1.,fract(ii)));
        bb=.7;f+=n*c*d*.4+1e-4;vec3 a=f;d=max(length(a),1e-4);
        a=vec3(log(d)-t*.7,exp(-a.z/d)+.23,atan(a.y,a.x));a.y-=1.;c=a.y;
        for(;bb<1603.;bb+=bb)c+=dot(sin(a.zxx*bb),.9-cos(a.yzy*bb))/bb*.28;
    }
    vec3 psy=g*(1.+bass*.6+high*.3);
    
    float fadeA=smoothstep(0.,1.,sec)*smoothstep(20.,18.,sec);
    float fadeB=smoothstep(2.,4.,sec)*smoothstep(16.,14.,sec);
    float fadePsy=smoothstep(6.,8.,sec)*smoothstep(18.,16.,sec);
    
    vec3 col=mix(A.rgb,B.rgb,fadeB);
    col=mix(col,psy,fadePsy*(.6+mid*.4));
    
    col*=1.+bp*bass*.8;
    col=mix(col,col.gbr,.12*sin(t+bass*4.));
    col+=.06*sin(col*12.+t)*high;
    col*=smoothstep(1.4,.3,length(uv));
    
    fragColor=vec4(col,1.);
}

// ==== Common (common) ====
#define F float
#define PI 3.14159265359
F H(F p){p=fract(p);p*=p;p*=p+p;return fract(p);}
mat2 R(F a){F c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
vec3 P(F t,F m){
    vec3 a=mix(vec3(.7),mix(vec3(.5),vec3(.3,.4,.6),clamp(m-1.,0.,1.)),step(.5,m));
    vec3 b=mix(vec3(1),mix(vec3(.5),vec3(.8,.5,.4),clamp(m-1.,0.,1.)),step(.5,m));
    vec3 c=mix(vec3(1),mix(vec3(2,1,0),vec3(1),clamp(m-1.,0.,1.)),step(.5,m));
    vec3 d=mix(vec3(0,.33,.67),mix(vec3(.5,.2,.25),vec3(.1,.5,.8),clamp(m-1.,0.,1.)),step(.5,m));
    if(m>2.5){a=b=vec3(.5);c=vec3(1,.7,.4);d=vec3(0,.15,.2);}
    return a+b*cos(6.283185*(c*t+d));
}

// ==== Buffer A (buffer) ====
#define LOIN 60.0
float hachage(float n){return fract(cos(n)*114514.1919);}
mat2 rotation2(float a){vec2 v=sin(vec2(1.570796,0.)+a);return mat2(v,-v.y,v.x);}
float bruit(in vec3 x){
    vec3 p=floor(x);vec3 f=smoothstep(0.,1.,fract(x));
    float n=p.x+p.y*10.+p.z*100.;
    return mix(mix(mix(hachage(n),hachage(n+1.),f.x),mix(hachage(n+10.),hachage(n+11.),f.x),f.y),
               mix(mix(hachage(n+100.),hachage(n+101.),f.x),mix(hachage(n+110.),hachage(n+111.),f.x),f.y),f.z);
}
mat3 matrice=mat3(0.,1.6,1.2,-1.6,.72,-.96,-1.2,-.96,1.28);
float mbf(vec3 p){
    float f=.5*bruit(p);p=matrice*p;f+=.25*bruit(p);p=matrice*p;
    f+=.1666*bruit(p);p=matrice*p;f+=.0834*bruit(p);return f;
}
vec2 chemin(float z){float a=sin(z*.11);float b=cos(z*.14);return vec2(a*4.-b*1.5,b*1.7+a*1.5);}
float geometrie(vec3 p){p.xy-=chemin(p.z);float n=5.-length(p.xy*vec2(1.,.8));return min(p.y+3.,n);}
vec3 tracageVoxel(vec3 o,vec3 d,out vec3 masque,out float t){
    vec3 p=floor(o);vec3 ds=d+step(abs(d),vec3(1e-8))*1e-8;
    vec3 di=1./ds;vec3 dp=sign(ds);vec3 dt=di*dp;vec3 mt=(p-o+.5+.5*dp)*di;masque=vec3(0.);
    for(int i=0;i<64;i++){if(geometrie(p+.5)<0.)break;masque=step(mt.xyz,mt.yzx)*step(mt.xyz,mt.zxy);mt+=masque*dt;p+=masque*dp;}
    t=dot(masque,(p-o+.5-.5*dp)*di);return p+.5;
}
float ombreVoxel(vec3 o,vec3 d,float fin){
    vec3 p=floor(o);vec3 ds=d+step(abs(d),vec3(1e-8))*1e-8;vec3 di=1./ds;vec3 dp=sign(ds);
    vec3 dt=di*dp;vec3 mt=(p-o+.5+.5*dp)*di;vec3 masque=vec3(0.);float dd=1.;
    for(int i=0;i<16;i++){dd=geometrie(p+.5);if(dd<0.)break;float ta=dot(masque,(p-o+.5-.5*dp)*di);if(ta>fin)break;
    masque=step(mt.xyz,mt.yzx)*step(mt.xyz,mt.zxy);mt+=masque*dt;p+=masque*dp;}return step(0.,dd)*.7+.3;
}
vec4 oaVoxel(vec3 p,vec3 d1,vec3 d2){
    vec4 cote=vec4(geometrie(p+d1),geometrie(p+d2),geometrie(p-d1),geometrie(p-d2));
    vec4 coin=vec4(geometrie(p+d1+d2),geometrie(p-d1+d2),geometrie(p-d1-d2),geometrie(p+d1-d2));
    cote=step(cote,vec4(0.));coin=step(coin,vec4(0.));return 1.-(cote+cote.yzwx+max(coin,cote*cote.yzwx))/3.;
}
float calculerOAVoxel(vec3 pv,vec3 ps,vec3 d,vec3 m){
    vec4 oa=oaVoxel(pv-sign(d+1e-8)*m,m.zxy,m.yzx);ps=fract(ps);
    vec2 uv=ps.yz*m.x+ps.zx*m.y+ps.xy*m.z;return mix(mix(oa.z,oa.w,uv.x),mix(oa.y,oa.x,uv.x),uv.y);
}
vec4 renduVolumetrique(vec3 o,vec3 d,float dm,vec3 pl){
    vec4 s=vec4(0.);float t=0.;float dt=dm/24.;
    for(int i=0;i<24;i++){if(t>dm||s.a>.99)break;vec3 p=o+d*t;float dens=smoothstep(.4,1.,mbf(p*.15));
    if(dens>0.){vec3 dl=normalize(pl-p);float dist=length(pl-p);float densL=smoothstep(.4,1.,mbf(p+dl*.8));
    float ombre=exp(-densL*3.);float phase=pow(max(dot(d,dl),0.),2.)*.6+.4;float att=1./(1.+dist*dist*.05);
    vec3 colD=vec3(1.,.85,.6)*att*phase*ombre*2.5;vec3 colA=mix(vec3(1.,.95,.9),vec3(.5,.6,.7),dens);
    vec3 col=colA+colD;float a=dens*(1.-s.a)*.4;s+=vec4(col*a,a);}t+=dt;}return s;
}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
    F b=smoothstep(.2,.8,texture(iChannel0,vec2(.03,0.)).x);
    F m=smoothstep(.2,.8,texture(iChannel0,vec2(.25,0.)).x);
    F h=smoothstep(.2,.8,texture(iChannel0,vec2(.75,0.)).x);
    vec2 uv=(fragCoord-iResolution.xy*.5)/iResolution.y;
    vec3 o=vec3(0.,.5,iTime*4.+b*2.);o.xy+=chemin(o.z);
    vec3 cible=o+vec3(0.,0.,1.);cible.xy+=chemin(cible.z);
    vec3 av=normalize(cible-o);vec3 dr=normalize(cross(av,vec3(0.,1.,0.)));vec3 ha=cross(dr,av);
    vec3 dir=normalize(av+(PI/2.)*uv.x*dr+(PI/2.)*uv.y*ha);dir.xy*=rotation2(chemin(cible.z).x/24.);
    vec3 masque;float t;vec3 pv=tracageVoxel(o,dir,masque,t);
    vec3 col=vec3(0.);vec3 pl=o+vec3(0.,2.,5.);pl.xy+=chemin(pl.z);
    if(t<LOIN){vec3 ps=o+dir*t;vec3 n=-(masque*sign(dir+1e-8));vec3 dl=normalize(pl-ps);float dist=length(pl-ps);
    float diff=max(dot(n,dl),0.);float spec=pow(max(dot(reflect(-dl,n),-dir),0.),32.);
    float oa=calculerOAVoxel(pv,ps,dir,masque);float omb=ombreVoxel(ps+n*.01,dl,dist);float att=1./(1.+dist*.1);
    vec3 tex=vec3(.9,.92,.95)*(.8+.2*bruit(ps*4.));col=tex*(diff+.2)+vec3(1.)*spec;col*=att*omb*oa;}
    vec4 vol=renduVolumetrique(o,dir,min(t,LOIN),pl);col=mix(col,vol.rgb,vol.a);
    col=mix(col,vec3(.7,.8,.9),smoothstep(0.,1.,t/LOIN));
    col*=1.+b*.4+m*.2;fragColor=vec4(pow(clamp(col,0.,1.),vec3(.4545)),1.);
}

// ==== Buffer B (buffer) ====
#define RED vec3(1.,.1,.05)
#define ORANGE vec3(1.,.4,.1)
#define GOLD vec3(1.,.8,.2)
#define BLACK vec3(.01,0.,0.)
#define THICKNESS .004
#define GLOW .012
mat2 rot(float a){float s=sin(a),c=cos(a);return mat2(c,-s,s,c);}
float sdSegment(vec2 p,vec2 a,vec2 b){vec2 pa=p-a,ba=b-a;float h=clamp(dot(pa,ba)/dot(ba,ba),0.,1.);return length(pa-ba*h);}
float hash(vec2 p){return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1.,0.)),f.x),mix(hash(i+vec2(0.,1.)),hash(i+vec2(1.,1.)),f.x),f.y);}
float fbm(vec2 p){float v=0.;float a=.5;for(int i=0;i<8;i++){v+=a*noise(p);p=p*2.2+vec2(10.);a*=.5;}return v;}
mat2 a(in float b){float c=cos(b),d=sin(b);return mat2(c,d,-d,c);}
float e(in float f){return abs((f-floor(f))-.5);}
vec3 g(in vec3 h){return vec3(abs((h.z+abs((h.y-floor(h.y))-.5)-floor(h.z+abs((h.y-floor(h.y))-.5)))-.5),
abs((h.z+abs((h.x-floor(h.x))-.5)-floor(h.z+abs((h.x-floor(h.x))-.5)))-.5),
abs((h.y+abs((h.x-floor(h.x))-.5)-floor(h.y+abs((h.x-floor(h.x))-.5)))-.5));}
float i(in vec3 h,in float j){float k=1.,l=.1;vec3 m=h;for(float n=0.;n<=2.;n++){vec3 o=g(m);h+=(o+iTime*j);m*=2.;k*=1.5;h*=1.3;l+=(e(h.z+e(h.x+e(h.y))))/k;m+=.14;}return l;}
vec2 p(float k){return vec2(sin(k*.12)*3.5+cos(k*.04)*1.5,cos(k*.09)*2.5+sin(k*.07)*1.2);}
float q(vec3 h){vec2 r=p(h.z);vec3 s=h;s.xy-=r;float t=5.5-length(s.xy);float u=i(h*.25,0.);s.xy*=a(h.z*.1);
float v=length(s.xy+vec2(sin(h.z),cos(h.z))*1.5)-.8;return min(t,v)-u*.5;}
vec3 x(in vec3 h){vec2 y=vec2(-1.,1.)*.01;return normalize(y.yxx*q(h+y.yxx)+y.xxy*q(h+y.xxy)+y.xyx*q(h+y.xyx)+y.yyy*q(h+y.yyy));}
vec3 z(float k){return vec3(p(k),k);}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
    F bass=smoothstep(.2,.8,texture(iChannel0,vec2(.03,0.)).x);
    F mid=smoothstep(.2,.8,texture(iChannel0,vec2(.25,0.)).x);
    F high=smoothstep(.2,.8,texture(iChannel0,vec2(.75,0.)).x);
    F bp=pow(abs(sin(iTime*PI*2.1667)),8.);
    vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
    float t=iTime;
    float sec=mod(t,16.);
    vec3 col=vec3(0.);
    
    if(sec<2. || (sec>8.&&sec<10.)){
        float time=t*1.2;float cycle=mod(time,24.);
        vec2 camUV=uv;float impact=pow(abs(cos(time*.4)),20.)*bass;
        vec2 distortion=vec2(fbm(camUV*2.5+time*.8));camUV+=(distortion-.5)*.04*(1.+impact*2.);
        vec2 fireUV=camUV*.7;fireUV.y-=time*.6;
        float f1=fbm(fireUV+time*.2);float f2=fbm(fireUV*1.5-time*.4);
        float fireShape=smoothstep(.2,.9,f1*f2+.25-length(camUV)*.5);
        col=mix(BLACK,RED,fireShape);col=mix(col,ORANGE,smoothstep(.4,.7,fireShape));col=mix(col,GOLD,smoothstep(.7,1.,fireShape));
        float rotY=time*.9;float cosY=cos(rotY);float r=.45;vec2 pp[5];
        for(int i=0;i<5;i++){float aa=(1.5*PI)+float(i)*2.*PI/5.;vec2 base=vec2(cos(aa),sin(aa))*r;pp[i]=vec2(base.x*cosY,base.y);}
        float d=1e10;d=min(d,sdSegment(camUV,pp[0],pp[2]));d=min(d,sdSegment(camUV,pp[2],pp[4]));
        d=min(d,sdSegment(camUV,pp[4],pp[1]));d=min(d,sdSegment(camUV,pp[1],pp[3]));d=min(d,sdSegment(camUV,pp[3],pp[0]));
        float ringDist=length(vec2(camUV.x/(abs(cosY)+.01),camUV.y));float rings=min(abs(ringDist-.48),abs(ringDist-.52));d=min(d,rings);
        float pulse=1.+.3*sin(time*5.)*high;float d_glow=(GLOW*pulse+impact*.15)/max(d,.001);
        vec3 logoCol=mix(RED,GOLD,impact);col+=logoCol*d_glow*.6;col+=logoCol*smoothstep(THICKNESS*(1.+impact*5.),0.,d);
        vec2 partUV=camUV*2.;partUV.y-=time*1.5;float particles=pow(fbm(partUV*3.),12.)*50.;
        particles*=smoothstep(.2,-.6,camUV.y);col+=mix(RED,GOLD,noise(partUV))*particles*(1.+impact*10.);
        col*=smoothstep(1.2,.4,length(uv));if(impact>.8)col+= (sin(time*50.)*.5+.5)*impact*.2;
        col=pow(col,vec3(.85));
    }
    else if(sec<6. || (sec>10.&&sec<14.)){
        vec2 hh=uv;float bb=t;float ss=6.+sin(bb*.5)*2.+bass*3.;
        vec2 ii=hh*ss;vec2 cc=floor(ii);vec2 aa=fract(ii)-.5;
        float jj=bb*(.5+length(cc)*.1);float kk=sin(jj);float ll=cos(jj);aa=mat2(ll,-kk,kk,ll)*aa;
        vec3 ee=vec3(0.);float ff=length(aa);float mm=smoothstep(.46,.44,ff);
        float tt=.15+mid*.1;float uu=.8;float vv=1.;
        vec3 ww=clamp(abs(mod(tt*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);vec3 zz=vv*mix(vec3(1.),ww,uu);
        vec2 dd=vec2(.15);dd.y+=sin(bb*5.+cc.x)*.05*high;dd.x+=cos(bb*2.+cc.y)*.05*high;
        float AA=smoothstep(.08,.06,length(aa-dd))+smoothstep(.08,.06,length(aa-vec2(-dd.x,dd.y)));
        float nn=atan(aa.y,aa.x);float oo=smoothstep(.3,.28,ff)*smoothstep(.25,.27,ff);
        float pp=smoothstep(-2.,-1.8,nn)*smoothstep(0.,-.2,nn);float BB=.5+.5*sin(bb*3.+cc.x+cc.y);
        oo*=mix(pp,1.-pp,BB);float CC=clamp(AA+oo,0.,1.);vec3 DD=mix(zz,vec3(0.),CC);
        ee=mix(vec3(.02),DD,mm);float EE=bb*.1+length(cc)*.05;float FF=.7;float GG=.2;
        vec3 HH=clamp(abs(mod(EE*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);vec3 II=GG*mix(vec3(1.),HH,FF);
        ee+=II*(1.-mm);ee*=smoothstep(1.5,.5,length(hh));col=ee*(1.+bp*bass);
    }
    else{
        vec2 aa=fragCoord.xy/iResolution.xy;vec2 hh=aa-.5;hh.x*=iResolution.x/iResolution.y;
        float ab=t*14.+bass*4.;vec3 ac=z(ab);vec3 ad=z(ab+2.);float ae=sin(t*.2)*.5;
        vec3 af=normalize(ad-ac);vec3 ag=vec3(sin(ae),cos(ae),0.);vec3 ah=normalize(cross(af,ag));
        vec3 ai=normalize(cross(ah,af));vec3 aj=normalize(hh.x*ah+hh.y*ai+1.3*af);
        float ak=0.,ww=0.,al=0.;for(int n=0;n<110;n++){ww=q(ac+aj*ak);if(abs(ww)<.005||ak>50.)break;ak+=ww*.6;al+=max(0.,(.35-ww))*.09;}
        vec3 am=vec3(.01,.03,.05);if(ak<50.){vec3 an=ac+aj*ak;vec3 ao=x(an);vec3 ap=normalize(vec3(.5,.8,-.2));
        float uu=i(an*.1,0.);float aq=clamp(dot(ao,ap),0.,1.);float ar=pow(clamp(1.+dot(ao,aj),0.,1.),3.);
        float as=clamp(q(an+ao*1.2),0.,1.);am=mix(vec3(.05,.1,.25),vec3(.4,.6,.8),uu);am=am*aq+ar*vec3(.7,.9,1.)*as;am*=as;}
        float at=length(hh)*.15;am+=vec3(.5,.75,1.)*al*(1.-at);am=sqrt(max(am,0.));
        am*=.4+.6*pow(16.*aa.x*aa.y*(1.-aa.x)*(1.-aa.y),.35);col=am*smoothstep(0.,2.5,t)*(1.+high*.5);
    }
    fragColor=vec4(col,1.);
}
