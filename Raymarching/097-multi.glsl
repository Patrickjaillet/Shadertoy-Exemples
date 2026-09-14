// ==== Image (image) ====
#define r c.rgb
void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec4 c=texture(iChannel0,fragCoord/iResolution.xy);
    float t=iTime,rb=texture(iChannel1,vec2(.03,0)).x,b=smoothstep(.2,.8,rb);
    r*=1.+.1*b;r=mix(r,r,.08*sin(t));
    fragColor=c;
}

// ==== Buffer A (buffer) ====
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
F L1(vec2 u,F s){u/=s;int a[10]=int[](83,65,78,68,69,70,74,79,82,68);u.x+=2.75;u.y+=.5;int i=int(floor(u.x/.55));if(i<0||i>=10)return 0.;return G(a[i],vec2(fract(u.x/.55),u.y));}
F L2(vec2 u,F s){u/=s;int a[8]=int[](80,114,101,115,101,110,116,115);u.x+=2.2;u.y+=.5;int i=int(floor(u.x/.55));if(i<0||i>=8)return 0.;return G(a[i],vec2(fract(u.x/.55),u.y));}
F L3(vec2 u,float s){u/=s;int a[15]=int[](84,101,99,104,110,111,32,68,101,109,111,32,50,48,50);u.x+=4.4;u.y+=.5;int i=int(floor(u.x/.55));if(i<0||i>=16)return 0.;return G(i<15?a[i]:54,vec2(fract(u.x/.55),u.y));}
vec3 P(F t,F m){
    vec3 a=mix(vec3(.7),mix(vec3(.5),vec3(.3,.4,.6),clamp(m-1.,0.,1.)),step(.5,m)),
         b=mix(vec3(1),mix(vec3(.5),vec3(.8,.5,.4),clamp(m-1.,0.,1.)),step(.5,m)),
         c=mix(vec3(1),mix(vec3(2,1,0),vec3(1),clamp(m-1.,0.,1.)),step(.5,m)),
         d=mix(vec3(0,.33,.67),mix(vec3(.5,.2,.25),vec3(.1,.5,.8),clamp(m-1.,0.,1.)),step(.5,m));
    if(m>2.5){a=b=vec3(.5);c=vec3(1,.7,.4);d=vec3(0,.15,.2);}
    return a+b*cos(6.283185*(c*t+d));
}
vec3 TP(vec2 u,F t,F b,F m,F h,F K){
    vec2 c=u*vec2(23,32);if(K>.5&&K<=1.5)c=u*vec2(12,64);if(K>1.5&&K<=2.5)c=u*vec2(40,16);if(K>2.5)c=u*vec2(8,80);
    vec2 id=floor(c);id.y=mod(id.y,192.);F ch=H(dot(id,vec2(12.9898,78.233))),lt=.05+h*.03;vec2 f=fract(c);
    F gx=smoothstep(0.,lt,f.x)*smoothstep(0.,lt,1.-f.x),gy=smoothstep(0.,lt,f.y)*smoothstep(0.,lt,1.-f.y),g=gx*gy;
    if(K>.5&&K<=1.5)g=step(.1,g);if(K>1.5&&K<=2.5)g=sin(g*6.28318);if(K>2.5)g=smoothstep(.2,.3,g*f.x);
    vec3 base=P(ch+t*.04,K)*(.3+b*.15);F vs=K>2.5?16.:K>1.5?1.:K>.5?8.:3.,vp=fract(u.x*vs-t*(1.3+b*.4)+ch*5.),v=smoothstep(.05,0.,abs(vp-.5));
    vec3 vc=P(ch+.2+m*.15,K);return base*g+vc*v*(1.3+m*.6)+(1.-g)*vc*(.15+h*.2);
}
vec3 RT(vec2 p,F t,F b,F m,F h,F K){
    if(K>.5&&K<=1.5)p=abs(p)*(1.2+b*.1);else if(K>1.5&&K<=2.5){p=R(.785398)*p;p=abs(p)-.2;p*=.8-b*.1;}
    else if(K>2.5)p=vec2(p.x/(1.+.5*abs(p.y)),p.y/(1.+.5*abs(p.x)))*(.9+b*.05);else p*=.75-b*.05;
    F a=atan(p.y,p.x),r=length(p);if(K<=.5)a+=sin(.5*r-.5*t);else if(K<=1.5)a+=cos(1.5*r+.8*t);else if(K<=2.5)a+=sin(2.*a+t)*.2;else a+=sin(r*8.-t*2.)*.15;
    F hv=.5+.5*cos(a),s=smoothstep(.4,.5,hv);vec2 u=vec2(t*(.6+b*.3)+1./(r+.1*s),a/3.14159265);
    vec3 col=TP(u,t,b,m,h,K);col*=1.-.6*(smoothstep(0.,.3,hv)-smoothstep(.5,1.,hv))*r;
    vec3 fc=K>2.5?vec3(.6,.1,.8):K>1.5?vec3(.1,.7,.4):K>.5?vec3(.8,.2,.1):vec3(.4,.5,.7);
    col=mix(col*fc,col,smoothstep(0.,.5,r))*r*(1.+b*.2);vec3 glow=vec3(0);
    for(int i=0;i<80;i++){F fi=F(i),sp=.25+H(fi*12.4+1.),ph=fract(t*sp+H(fi*30.8+8.)),rp=1.5*ph,ap=H(fi*5.3+3.)*6.283+ .6*sin(.3*t+fi)+sin(.5*rp-.5*t);
        F da=atan(sin(a-ap),cos(a-ap)),dr=r-rp,al=da*max(rp,.05),m2=K>2.5?5.:K>1.5?18.:K>.5?2.:9.,d2=al*al+dr*dr*m2,sz=mix(.0006,.0022,H(fi*36.4))*(1.+h*1.2),fa=smoothstep(0.,.85,ph);
        glow+=sz/(d2+sz)*P(H(fi*11.3)+h*.1,K)*(1.5+fa)*(1.+m*.5);}return col+glow;
}
F MO(vec3 p,F o,F b,F m){p.xy*=R(iTime*.8);p.xz*=R(iTime*.5);F s=.45+b*.25;if(o<.5)return S(p,s);if(o<1.5)return B(p,vec3(s*.75));if(o<2.5)return T(p,vec2(s*.7,s*.25+m*.05));return O(p,s*1.1);}
vec3 GO(vec3 p,F o,F b,F m){vec2 e=vec2(.001,0);return normalize(vec3(MO(p+e.xyy,o,b,m)-MO(p-e.xyy,o,b,m),MO(p+e.yxy,o,b,m)-MO(p-e.yxy,o,b,m),MO(p+e.yyx,o,b,m)-MO(p-e.yyx,o,b,m)));}
F SText(vec2 u,F t,F scale){u/=scale;u.y-=sin(u.x*2.5+t*4.)*.2;u.x+=t*3.5;int txt[54]=int[](83,65,78,68,69,70,74,79,82,68,32,42,42,42,32,84,69,67,72,78,79,32,68,69,77,79,32,42,42,42,32,50,48,50,54,32,42,42,42,32,83,72,65,68,69,82,84,79,89,46,67,79,77,32);
    F spacing=.5,totalLen=54.*spacing;u.x=mod(u.x,totalLen);int idx=int(floor(u.x/spacing));if(idx<0||idx>=54)return 0.;return G(txt[idx],vec2(fract(u.x/spacing),u.y+.5));}

float hachage(float n){return fract(cos(n)*114514.1919);}
mat2 rotation2(float a){vec2 v=sin(vec2(1.570796,0.)+a);return mat2(v,-v.y,v.x);}
float bruit(in vec3 x){vec3 p=floor(x);vec3 f=smoothstep(0.,1.,fract(x));float n=p.x+p.y*10.+p.z*100.;return mix(mix(mix(hachage(n),hachage(n+1.),f.x),mix(hachage(n+10.),hachage(n+11.),f.x),f.y),mix(mix(hachage(n+100.),hachage(n+101.),f.x),mix(hachage(n+110.),hachage(n+111.),f.x),f.y),f.z);}
mat3 matrice=mat3(0.,1.6,1.2,-1.6,.72,-.96,-1.2,-.96,1.28);
float mbf(vec3 p){float f=.5*bruit(p);p=matrice*p;f+=.25*bruit(p);p=matrice*p;f+=.1666*bruit(p);p=matrice*p;f+=.0834*bruit(p);return f;}
vec2 chemin(float z){float a=sin(z*.11),b=cos(z*.14);return vec2(a*4.-b*1.5,b*1.7+a*1.5);}
float geometrie(vec3 p){p.xy-=chemin(p.z);return min(p.y+3.,5.-length(p.xy*vec2(1.,.8)));}
vec3 tracageVoxel(vec3 o,vec3 d,out vec3 masque,out float t){vec3 p=floor(o);vec3 di=1./(d+step(abs(d),vec3(1e-8))*1e-8);vec3 dp=sign(d);vec3 dt=di*dp;vec3 mt=(p-o+.5+.5*dp)*di;masque=vec3(0.);for(int i=0;i<64;i++){if(geometrie(p+.5)<0.)break;masque=step(mt.xyz,mt.yzx)*step(mt.xyz,mt.zxy);mt+=masque*dt;p+=masque*dp;}t=dot(masque,(p-o+.5-.5*dp)*di);return p+.5;}
float ombreVoxel(vec3 o,vec3 d,float fin){vec3 p=floor(o);vec3 di=1./(d+step(abs(d),vec3(1e-8))*1e-8);vec3 dp=sign(d);vec3 dt=di*dp;vec3 mt=(p-o+.5+.5*dp)*di;vec3 masque=vec3(0.);float dd=1.;for(int i=0;i<16;i++){dd=geometrie(p+.5);if(dd<0.)break;float ta=dot(masque,(p-o+.5-.5*dp)*di);if(ta>fin)break;masque=step(mt.xyz,mt.yzx)*step(mt.xyz,mt.zxy);mt+=masque*dt;p+=masque*dp;}return step(0.,dd)*.7+.3;}
vec4 oaVoxel(vec3 p,vec3 d1,vec3 d2){vec4 cote=vec4(geometrie(p+d1),geometrie(p+d2),geometrie(p-d1),geometrie(p-d2));vec4 coin=vec4(geometrie(p+d1+d2),geometrie(p-d1+d2),geometrie(p-d1-d2),geometrie(p+d1-d2));cote=step(cote,vec4(0.));coin=step(coin,vec4(0.));return 1.-(cote+cote.yzwx+max(coin,cote*cote.yzwx))/3.;}
float calculerOAVoxel(vec3 pv,vec3 ps,vec3 d,vec3 m){vec4 oa=oaVoxel(pv-sign(d+1e-8)*m,m.zxy,m.yzx);ps=fract(ps);vec2 uv=ps.yz*m.x+ps.zx*m.y+ps.xy*m.z;return mix(mix(oa.z,oa.w,uv.x),mix(oa.y,oa.x,uv.x),uv.y);}
vec4 renduVolumetrique(vec3 o,vec3 d,float dm,vec3 pl){vec4 s=vec4(0.);float t=0.,dt=dm/24.;for(int i=0;i<24;i++){if(t>dm||s.a>.99)break;vec3 p=o+d*t;float dens=smoothstep(.4,1.,mbf(p*.15));if(dens>0.){vec3 dl=normalize(pl-p);float dist=length(pl-p);float densL=smoothstep(.4,1.,mbf(p+dl*.8));float omb=exp(-densL*3.);float ph=pow(max(dot(d,dl),0.),2.)*.6+.4;float att=1./(1.+dist*dist*.05);vec3 colD=vec3(1.,.85,.6)*att*ph*omb*2.5;vec3 colA=mix(vec3(1.,.95,.9),vec3(.5,.6,.7),dens);float a=dens*(1.-s.a)*.4;s+=vec4((colA+colD)*a,a);}t+=dt;}return s;}
vec3 voxelScene(vec2 uv,float t,float b,float m,float h){
    vec3 o=vec3(0.,.5,t*4.);o.xy+=chemin(o.z);vec3 c=o+vec3(0.,0.,1.);c.xy+=chemin(c.z);
    vec3 av=normalize(c-o);vec3 dr=normalize(cross(av,vec3(0.,1.,0.)));vec3 ha=cross(dr,av);
    vec3 dir=normalize(av+uv.x*dr+uv.y*ha);dir.xy*=rotation2(chemin(c.z).x/24.);
    vec3 masque;float tt;vec3 pv=tracageVoxel(o,dir,masque,tt);vec3 col=vec3(0.);
    vec3 pl=o+vec3(0.,2.,5.);pl.xy+=chemin(pl.z);
    if(tt<60.){vec3 ps=o+dir*tt;vec3 n=-(masque*sign(dir+1e-8));vec3 dl=normalize(pl-ps);float dist=length(pl-ps);
        float dif=max(dot(n,dl),0.);float spe=pow(max(dot(reflect(-dl,n),-dir),0.),32.);float oa=calculerOAVoxel(pv,ps,dir,masque);
        float omb=ombreVoxel(ps+n*.01,dl,dist);float att=1./(1.+dist*.1);vec3 tex=vec3(.9,.92,.95)*(.8+.2*bruit(ps*4.));
        col=tex*(dif+.2)+vec3(1.)*spe;col*=att*omb*oa;}
    vec4 vol=renduVolumetrique(o,dir,min(tt,60.),pl);col=mix(col,vol.rgb,vol.a);col=mix(col,vec3(.7,.8,.9),smoothstep(0.,1.,tt/60.));
    return pow(clamp(col,0.,1.),vec3(.45));
}

vec3 fireLogo(vec2 uv,float t,float impact){
    vec2 cu=uv;if(mod(t,24.)>12.)cu*=R(sin(t*.5)*.2);
    vec2 dist=vec2(H(dot(cu*2.5+t*.8,vec2(12.9898,78.233))));cu+=(dist-.5)*.04*(1.+impact*2.);
    vec2 fu=cu*.7;fu.y-=t*.6;float f1=H(dot(fu+t*.2,vec2(12.9898,78.233))),f2=H(dot(fu*1.5-t*.4,vec2(12.9898,78.233)));
    float fs=smoothstep(.2,.9,f1*f2+.25-length(cu)*.5);vec3 col=mix(vec3(.01,0.,0.),vec3(1.,.1,.05),fs);
    col=mix(col,vec3(1.,.4,.1),smoothstep(.4,.7,fs));col=mix(col,vec3(1.,.8,.2),smoothstep(.7,1.,fs));
    float ry=t*.9,cy=cos(ry),r=.45;vec2 pt[5];for(int i=0;i<5;i++){float a=1.5*3.14159+float(i)*1.25664;vec2 b=vec2(cos(a),sin(a))*r;pt[i]=vec2(b.x*cy,b.y);}
    float d=1e10;for(int i=0;i<5;i++)d=min(d,length(cu-pt[i]));float rd=length(vec2(cu.x/(abs(cy)+.01),cu.y));d=min(d,min(abs(rd-.48),abs(rd-.52)));
    float pulse=1.+.3*sin(t*5.);float dg=(.012*pulse+impact*.15)/max(d,.001);vec3 lc=mix(vec3(1.,.1,.05),vec3(1.,.8,.2),impact);
    col+=lc*dg*.6;col+=lc*smoothstep(.004*(1.+impact*5.),0.,d);
    vec2 pu=cu*2.;pu.y-=t*1.5;float part=pow(H(dot(pu*3.,vec2(12.9898,78.233))),12.)*50.*smoothstep(.2,-.6,cu.y);
    col+=mix(vec3(1.,.1,.05),vec3(1.,.8,.2),H(dot(pu,vec2(12.9898,78.233))))*part*(1.+impact*10.);
    col*=smoothstep(1.5,.3,length(uv));return pow(col,vec3(.85));
}

vec3 gridFaces(vec2 uv,float t,float b){
    float s=6.+sin(t*.5)*2.;vec2 i=uv*s,c=floor(i),a=fract(i)-.5;float j=t*(.5+length(c)*.1),k=sin(j),l=cos(j);a=mat2(l,-k,k,l)*a;
    float f=length(a),m=smoothstep(.46,.44,f);vec3 w=clamp(abs(mod(.9+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.),z=.8*mix(vec3(1.),w,.8);
    vec2 d=vec2(.15);d.y+=sin(t*5.+c.x)*.05;d.x+=cos(t*2.+c.y)*.05;
    float A=smoothstep(.08,.06,length(a-d))+smoothstep(.08,.06,length(a+vec2(d.x,-d.y)));
    float n=atan(a.y,a.x),o=smoothstep(.3,.28,f)*smoothstep(.25,.27,f),p=smoothstep(-2.,-1.8,n)*smoothstep(0.,-.2,n),B=.5+.5*sin(t*3.+c.x+c.y);
    o*=mix(p,1.-p,B);float C=clamp(A+o,0.,1.);vec3 D=mix(z,vec3(0.),C);vec3 e=mix(vec3(.02),D,m);
    float E=t*.1+length(c)*.05;vec3 H=clamp(abs(mod(E*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);e+=.2*mix(vec3(1.),H,.7)*(1.-m);
    e*=smoothstep(1.8,.5,length(uv));return e;
}

mat2 aa(float b){float c=cos(b),d=sin(b);return mat2(c,d,-d,c);}
float ee(float f){return abs(fract(f)-.5);}
vec3 gg(vec3 h){return vec3(abs(fract(h.z+abs(fract(h.y)-.5))-.5),abs(fract(h.z+abs(fract(h.x)-.5))-.5),abs(fract(h.y+abs(fract(h.x)-.5))-.5));}
float ii(vec3 h,float j){float k=1.,l=.1;vec3 m=h;for(float n=0.;n<=2.;n++){vec3 o=gg(m);h+=o+iTime*j;m*=2.;k*=1.5;h*=1.3;l+=ee(h.z+ee(h.x+ee(h.y)))/k;m+=.14;}return l;}
vec2 pp(float k){return vec2(sin(k*.12)*3.5+cos(k*.04)*1.5,cos(k*.09)*2.5+sin(k*.07)*1.2);}
float qq(vec3 h){vec2 r=pp(h.z);vec3 s=h;s.xy-=r;float t=5.5-length(s.xy);float u=ii(h*.25,0.);s.xy*=aa(h.z*.1);float v=length(s.xy+vec2(sin(h.z),cos(h.z))*1.5)-.8;return min(t,v)-u*.5;}
vec3 xx(vec3 h){vec2 y=vec2(-1.,1.)*.01;return normalize(y.yxx*qq(h+y.yxx)+y.xxy*qq(h+y.xxy)+y.xyx*qq(h+y.xyx)+y.yyy*qq(h+y.yyy));}
vec3 zz(float k){return vec3(pp(k),k);}
vec3 fractalTunnel(vec2 uv,float t){
    vec2 h=uv;h.x*=iResolution.x/iResolution.y;float ab=t*14.;vec3 ac=zz(ab),ad=zz(ab+2.);
    float ae=sin(t*.2)*.5;vec3 af=normalize(ad-ac);vec3 ag=vec3(sin(ae),cos(ae),0.);vec3 ah=normalize(cross(af,ag));vec3 ai=normalize(cross(ah,af));
    vec3 aj=normalize(h.x*ah+h.y*ai+1.3*af);float ak=0.,w=0.,al=0.;
    for(int n=0;n<90;n++){w=qq(ac+aj*ak);if(abs(w)<.005||ak>50.)break;ak+=w*.6;al+=max(0.,.35-w)*.09;}
    vec3 am=vec3(.01,.03,.05);if(ak<50.){vec3 an=ac+aj*ak;vec3 ao=xx(an);vec3 ap=normalize(vec3(.5,.8,-.2));
        float u=ii(an*.1,0.);float aq=clamp(dot(ao,ap),0.,1.);float ar=pow(clamp(1.+dot(ao,aj),0.,1.),3.);float as=clamp(qq(an+ao*1.2),0.,1.);
        am=mix(vec3(.05,.1,.25),vec3(.4,.6,.8),u);am=am*aq+ar*vec3(.7,.9,1.)*as;am*=as;}
    am+=vec3(.5,.75,1.)*al*(1.-length(h)*.15);am=sqrt(max(am,0.));am*=.4+.6*pow(16.*(.5+h.x*.5)*(.5+h.y*.5)*(1.-(.5+h.x*.5))*(1.-(.5+h.y*.5)),.35);
    return am*smoothstep(0.,1.5,t);
}

vec3 colorSpiral(vec2 uv,float t){
    vec2 m=uv*.65;vec3 n=vec3(m,.3),f=vec3(.7,-8.,-2.7),g=vec3(0.);float c=0.,d=0.,b=0.;
    vec3 h[8]=vec3[8](vec3(.98,.7,.75),vec3(.98,.82,.65),vec3(.99,.96,.68),vec3(.72,.93,.78),vec3(.67,.88,.95),vec3(.73,.76,.96),vec3(.88,.72,.95),vec3(.95,.75,.87));
    for(float e=0.;e<70.;++e){float o=clamp(min(c*b,.6)/41.3,0.,1.),i=mod(e*.15+c*2.+t*.2,8.);int j=int(i),p=(j+1)&7;
        g+=o*mix(h[j],h[p],smoothstep(0.,1.,fract(i)));b=.7;f+=n*c*d*.4+1e-4;vec3 a=f;d=max(length(a),1e-4);
        a=vec3(log(d)-t*.7,exp(-a.z/d)+.23,atan(a.y,a.x));a.y-=1.;c=a.y;for(;b<800.;b+=b)c+=dot(sin(a.zxx*b),.9-cos(a.yzy*b))/b*.28;}
    return g;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    F rb=texture(iChannel0,vec2(.03,0)).x,b=smoothstep(.2,.8,rb),m=smoothstep(.2,.8,texture(iChannel0,vec2(.25,0)).x),h=smoothstep(.2,.8,texture(iChannel0,vec2(.75,0)).x),t=iTime;
    F pi=floor(t/10.),tp=mod(t,10.),K=mod(pi+step(8.,tp)*step(.65,rb),4.);
    F bpm=130.,beat=t*(bpm/60.),beatIndex=floor(beat),isKickStep8=step(.5,rb)*step(7.5,mod(beatIndex,8.));
    vec2 p=(-iResolution.xy+2.*fragCoord)/iResolution.y;
    if(isKickStep8>0.)p+=(vec2(H(t*120.),H(t*120.+17.3))-.5)*.12*rb;
    p*=1.+.15*sin(t*2.+length(p)*4.)*b;p=mix(p,p*R(t*.3+m*2.),.3*h);

    F scene=mod(floor(t/8.),6.);
    vec3 col=vec3(0.);
    if(scene<1.)col=RT(p,t,b,m,h,K);
    else if(scene<2.)col=voxelScene(p,t,b,m,h);
    else if(scene<3.)col=fractalTunnel(p,t);
    else if(scene<4.)col=gridFaces(p,t,b);
    else if(scene<5.)col=colorSpiral(p,t);
    else col=RT(p,t,b,m,h,K);

    F fireT = mod(t, 8.0);
    if(fireT > 6.0){
        F impact = pow(abs(cos(t * 0.5)), 12.0);
        vec3 fl = fireLogo(p, t, impact);
        F a = smoothstep(6.0, 6.4, fireT) * smoothstep(8.0, 7.6, fireT);
        col = mix(col, fl, a * 0.95);
    }
    F op=mod(t,20.),aw=smoothstep(4.,5.5,op)-smoothstep(14.,15.5,op);
    if(aw>.001){F ot=mod(floor(t/20.),4.);vec3 ro=vec3(0,0,-2.2),rd=normalize(vec3(p,1.5)),pH;F dO=0.,dS=0.;bool hit=false;
        for(int i=0;i<48;i++){pH=ro+rd*dO;dS=MO(pH,ot,b,m);dO+=dS;if(dS<.001){hit=true;break;}if(dO>5.)break;}
        vec3 halo=P(t*.2,K)*(b*.25*aw/(dot(p,p)+.35));
        if(hit){vec3 N=GO(pH,ot,b,m),Ref=reflect(rd,N);vec2 rUV=Ref.xy/(abs(Ref.z)+.2);vec3 rc=RT(rUV,t,b,m,h,K);
            F fr=pow(1.-max(0.,dot(-rd,N)),3.);vec3 sp=vec3(1)*pow(max(0.,dot(Ref,vec3(0,0,-1))),16.)*(.5+h);col=mix(col,mix(rc*.85,vec3(1),fr*.4)+sp,aw);}
        col+=halo;}
    col+=P(sin(p.x*8.+t*3.)*cos(p.y*6.-t*2.5)+sin((p.x+p.y)*4.+t)*.5+t*.1,K)*.15*(.5+m);

    if(t<5.){F gl=smoothstep(3.5,5.,t);vec2 u1=p-vec2(0,.22),u2=p,u3=p-vec2(0,-.22);
        if(gl>0.){if(H(floor(u1.y*20.)+floor(t*30.))<gl*.8)u1.x+=(H(floor(u1.y*50.)+t*50.)-.5)*.25*gl;
            if(H(floor(u2.y*20.)+floor(t*30.))<gl*.8)u2.x+=(H(floor(u2.y*50.)+t*50.)-.5)*.25*gl;
            if(H(floor(u3.y*20.)+floor(t*30.))<gl*.8)u3.x+=(H(floor(u3.y*50.)+t*50.)-.5)*.25*gl;}
        F ta=clamp(L1(u1,.16)+L2(u2,.1)+L3(u3,.09),0.,1.)*(1.-smoothstep(4.2,5.,t));
        col=mix(col,vec3(1,.9,.7)+P(t*.5,0.)*.4+vec3(b*.6),ta);}
    vec2 su=p-vec2(0,-.65);F sh=SText(su-vec2(.02,-.02),t,.18),ta=SText(su,t,.18);
    col=mix(col,vec3(0),sh*.65);col=mix(col,P(t*.4+p.x*.2,K)*(1.3+h*.8)+vec3(b*.5),ta);

    col*=1.-.01*(15.+b*10.)*dot(p,p);
    if(t>45.){F rnd=H(floor(t*24.));col+=vec3(step(.35,rb)*step(.4,rnd)*rb*4.);}
    col=mix(col,col.gbr,.15*sin(t+b*3.));col+=.08*sin(col*10.+t)*m;
    fragColor=vec4(col,1);
}
