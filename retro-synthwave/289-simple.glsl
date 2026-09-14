// ==== Image (image) ====
void drawChar(inout vec3 col, vec3 textCol, vec2 uv, vec2 pos, vec2 size, int charCode) {
    vec2 p = (uv - pos) / size;
    if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0) {
        vec2 fontUV = (vec2(mod(float(charCode), 16.0), 15.0 - floor(float(charCode) / 16.0)) + p) / 16.0;
        float alpha = texture(iChannel0, fontUV).r;
        col = mix(col, textCol, alpha);
    }
}

void drawText(inout vec3 col, vec3 textCol, vec2 uv, vec2 startPos, vec2 charSize, int chars[16], int len) {
    for (int i = 0; i < 16; i++) {
        if (i >= len) break;
        drawChar(col, textCol, uv, startPos + vec2(float(i) * charSize.x, 0.0), charSize, chars[i]);
    }
}

void renderScene(in vec2 U, out vec3 col, out float hi, out vec2 hv, out float z, out vec3 ac, out vec3 bc, out float t) {
vec2 R=iResolution.xy,u=(U-.5*R)/R.y;
float T=iTime,p=6.,mt=1.,tv=mod(T,p),si=floor(T/p),mp=smoothstep(0.,mt,tv),g=si+mp,pt=max(0.,tv-mt),pd=p-mt,zi=smoothstep(.2,1.2,pt),zo=1.-smoothstep(pd-1.,pd-.2,pt);
z=zi*zo;z*=z*(3.-2.*z);
float ai=mod(floor(g),10.),sm=mod(ai,5.);
vec3 ro=vec3(0,0,2.2),rd=normalize(vec3(u,-1.6));
ac=(sm<1.)?vec3(1,.15,.25):(sm<2.)?vec3(.1,.55,1):(sm<3.)?vec3(1,.75,.05):(sm<4.)?vec3(.05,.85,.45):vec3(.65,.2,.95);
bc=mix(vec3(.015,.015,.02),ac*.08,1.-length(u)*.8);
bc+=ac*sin(u.x*3.+T*.5)*.008;
float bi=floor(g),pr=fract(g);t=0.;hi=-1.;hv=vec2(0);
for(int i=0;i<64;i++){
vec3 P=ro+rd*t;float md=1e5,ci=0.;vec2 cv=vec2(0);
for(float sl=-3.;sl<=3.;sl+=1.){
float sI=bi+sl,rp=sl-pr,aw=exp(-rp*rp*25.),sp=(rp<0.)?-1.:1.;if(abs(rp)<1e-4)sp=0.;
float bs=rp*1.15,ss=sp*(2.8+abs(rp)*1.5),tx=mix(bs,ss,z*(1.-aw)),ty=sin(rp*1.2)*.08*(1.-z),tz=mix((1.-cos(rp*.6))*.8,-1.25,aw*z)+z*(1.-aw)*2.,ry=-rp*.25*(1.-z);
vec3 pos=vec3(tx,ty,tz),dn=vec3(.5,.35,.02)*(1.+smoothstep(1.5,0.,abs(rp))*.15),bd=mix(dn,vec3(1.777,1,.02),aw*z),q=P-pos;
float cR=cos(ry),sR=sin(ry);vec2 xz=q.xz*mat2(cR,-sR,sR,cR);q.x=xz.x;q.z=xz.y;
vec3 aQ=abs(q)-bd;float d=length(max(aQ,0.))+min(max(aQ.x,max(aQ.y,aQ.z)),0.)-.025;
if(d<md){md=d;ci=mod(sI,10.);cv=(q.xy/bd.xy)*.5+.5;}}
if(md<.001){hi=ci;hv=cv;break;}
if(t>7.)break;t+=md*.85;}
col=bc;
if(hi>=0.){
vec3 P=ro+rd*t,N;vec2 e=vec2(.001,0);
for(int ax=0;ax<3;ax++){
vec3 pO=P+(ax==0?e.xyy:ax==1?e.yxy:e.yyx),pN=P-(ax==0?e.xyy:ax==1?e.yxy:e.yyx);float d1=1e5,d2=1e5;
for(float sl=-3.;sl<=3.;sl+=1.){
float rp=sl-pr,aw=exp(-rp*rp*25.),sp=(rp<0.)?-1.:1.;if(abs(rp)<1e-4)sp=0.;
float bs=rp*1.15,ss=sp*(2.8+abs(rp)*1.5),tx=mix(bs,ss,z*(1.-aw)),ty=sin(rp*1.2)*.08*(1.-z),tz=mix((1.-cos(rp*.6))*.8,-1.25,aw*z)+z*(1.-aw)*2.,ry=-rp*.25*(1.-z);
vec3 pos=vec3(tx,ty,tz),bd=mix(vec3(.5,.35,.02)*(1.+smoothstep(1.5,0.,abs(rp))*.15),vec3(1.777,1,.02),aw*z),q1=pO-pos;
float cR=cos(ry),sR=sin(ry);vec2 xz1=q1.xz*mat2(cR,-sR,sR,cR);q1.x=xz1.x;q1.z=xz1.y;
vec3 aQ1=abs(q1)-bd;d1=min(d1,length(max(aQ1,0.))+min(max(aQ1.x,max(aQ1.y,aQ1.z)),0.)-.025);
vec3 q2=pN-pos;vec2 xz2=q2.xz*mat2(cR,-sR,sR,cR);q2.x=xz2.x;q2.z=xz2.y;
vec3 aQ2=abs(q2)-bd;d2=min(d2,length(max(aQ2,0.))+min(max(aQ2.x,max(aQ2.y,aQ2.z)),0.)-.025);}
if(ax==0)N.x=d1-d2;if(ax==1)N.y=d1-d2;if(ax==2)N.z=d1-d2;}
N=normalize(N);
vec3 L=normalize(vec3(.4,.8,.9)),wc=vec3(0);
float df=max(dot(N,L),0.),sc=pow(max(dot(reflect(-L,N),-rd),0.),32.),lI=mix(1.,.9,z),ty=mod(hi,5.);
if(ty<1.){
vec2 u=hv*R,j=R;float c=T*.5,k=cos(c),l=sin(c),e=.005,i=0.,A=i,n=A,p,q,g,r;mat2 m=mat2(k,-l,l,k);
vec3 d=normalize(vec3((u-.5*j)/j.y,.4)),x=clamp(abs(fract(c/6.+vec3(1,2./3.,1./3.))*6.-3.)-1.,0.,1.),h=vec3(0),B,f,tc;
d.xz*=m;d.yz*=m;vec4 wF=vec4(0);
for(int o=0;o<128;o++){
h+=d*e;p=length(h)+1e-5;B=h/p;q=0.;g=1.5;f=B;r=log(p*2.)-c*.7;
for(int s=0;s<5;s++){tc=cos(f*g*3.14159+vec3(r,c,c*1.3));q+=abs(dot(tc,vec3(.215)))/g;n+=tc.y/g;f.xy*=mat2(1,1.8,0,.1);f.yz*=mat2(.8,1,.7,.1);r*=1.25;g*=1.5;}
++A;e=max(abs(q)*.13,0.);i+=e;wF+=(1.+sin(vec4(1,.4,-.5,0)))*exp(-e*80.)*(.15/(1.+i*.1));
if(i>0.){d*=0.;e+=1e-3;}}
wF.rgb=mix(wF.rgb,x*wF.a,.47);wc=tanh(wF.rgb*.36);
}else if(ty<2.){
vec2 o=hv*R,p=R;float c=T,t0=floor(c*.08),t2=fract(c*.08);t2=t2*t2*(3.-2.*t2);
float pu=1.+.25*sin(c*3.14159),b=.4,g=0.,h=1.;vec4 j=vec4(0);
vec3 a=vec3(0),d=vec3(0,0,-1.),k=.5-vec3(o,0)/p.y;
for(int i=0;i<54;i++){
if(h<.005)k=vec3(0);a=(d+=k*max(b,.001));float e=c*.15,f=c*.1;mat2 q=mat2(cos(e),-sin(e),sin(e),cos(e)),r=mat2(cos(f),-sin(f),sin(f),cos(f));
a.zy*=q;a.xz*=r;a.z=fract(a.z+.5)-.5;g=2.;a=-abs(a);
float p1=sin(t0*1.3)*.5,p2=cos(t0*1.7)*.5,p3=sin(t0*2.1)*.5,np1=sin((t0+1.)*1.3)*.5,np2=cos((t0+1.)*1.7)*.5,np3=sin((t0+1.)*2.1)*.5;
float c1=mix(p1,np1,t2),c2=mix(p2,np2,t2),c3=mix(p3,np3,t2);
for(int l=0;l<14;l++){a=abs(a)-(.3+c1*.1);float s=dot(a,a);b=(5.5+c2*2.)/max(s,0.);g*=b;a=abs(a)*b-(2.5+c3*.5);}
h=length(d);b=min(abs(h),length(a.xz)/g);vec3 m=(.5+.5*cos(c*.6+d.xyx*1.2+vec3(0,.8,1.6)+length(a)*.05))*(.6+.4*sin(c*2.5+float(i)*.1));
j+=vec4(m,1.)*(.07*pu)/exp(b*220.);}
wc=clamp(j.rgb*1.2+.05,0.,1.);
}else if(ty<3.){
vec2 n=hv*R,h=R;float e=T;vec3 c=vec3(0),g=vec3(0,0,-.3);g.xy+=vec2(sin(e),cos(e*.3))*.5;
vec3 i=vec3((n*2.-h)/h.y,.5);float d=0.,b=d,p=b;
for(int j=0;j<135;j++){
vec3 a=g;float r2=e*.4;a.yz*=mat2(cos(r2),-sin(r2),sin(r2),cos(r2));b=3.8;a=1.-abs(a);
for(int k=0;k<3;k++){a=abs(a)-1.;d=4.2/min(dot(a,a),1.9);b*=d;a=abs(a)*d-3.8;a.z+=4.2;}
d=length(a.xz)/b;float l=max(d,0.);p+=l;g+=i*l;c+=vec3(exp(-d*40.6))*.015;}
wc=1.-exp(-pow(c,vec3(4.2)));
}else if(ty<4.){
vec2 u=hv*R;vec3 k=normalize(vec3((u+u-1.4*R)/R.y,1)),l=vec3(.5,0,.1),a=vec3(.447,.894,.179),c,i;
l.yz*=mat2(cos(T*.1+vec4(0,33,11,0)));float s=sin(T*.15),g=cos(T*.15),b=1.-g;
k=mat3(b*a.x*a.x+g,b*a.x*a.y-a.z*s,b*a.z*a.x+a.y*s,b*a.x*a.y+a.z*s,b*a.y*a.y+g,b*a.y*a.z-a.x*s,b*a.z*a.x-a.y*s,b*a.y*a.z+a.x*s,b*a.z*a.z+g)*k;
vec4 wF=vec4(0);float m=0.,e,j,h;mat2 I=mat2(cos(-3.5814+vec4(0,33,11,0)));
for(int A=0;A<91&&m<=47.6;A++){
c=l+k*m;h=max(length(c),1e-4);i=fract(vec3(log(h)-T*.25,c.y/h,atan(c.z,c.x))*.7957)-.5;j=.4;c=i;
for(int B=0;B<12;B++){c=abs(c)-vec3(.42,.49,.66);c.xz*=I;float C=1.5/max(dot(c,c),1e-8);c=c*C-vec3(.1,.5,.4);j*=C;}
e=max((length(c.xz)-.2)/max(j,1e-4),1e-4);m+=e;wF+=vec4(sin(vec3(0,1,1.8)-i.z*8.7+T)*.5+.65,1)*.015/(e*80.+.74);}
wc=min(wF.rgb,.8);
}else{
vec2 w=hv*R,p=R;float h=T*.3,q=h*.3,r=sin(q),s=cos(q),i=1.,j=0.,l=0.;mat2 e=mat2(s,-r,r,s);
vec3 B=vec3(0,0,-3.),C=normalize(vec3((w*2.-p)/p.y,1.5)),c=vec3(0),m=normalize(vec3(sin(h*-6.5),cos(h*-5.6),-8.));
m.xz*=e;m.yz*=e;
for(int b=0;b<60;b++){
vec3 a=B+C*i,aN=a;aN.xz*=e;aN.yz*=e;aN.xy=abs(mod(aN.xy+1.,32.));float fN=.5;
for(int cI=0;cI<5;cI++){aN=mod(aN-1.,2.)-1.;float gN=dot(aN,aN)*.5;fN/=gN;aN=abs(aN)/gN;}
vec3 n1=aN*24.5,nb1=floor(n1),nc1=fract(n1);nc1*=nc1*(3.-2.*nc1);
vec3 m1=vec3(444.,397.,491.);float n31=mix(mix(mix(fract(dot(nb1,m1)),fract(dot(nb1+vec3(1,0,0),m1)),nc1.x),mix(fract(dot(nb1+vec3(0,1,0),m1)),fract(dot(nb1+vec3(1,1,0),m1)),nc1.x),nc1.y),mix(mix(fract(dot(nb1+vec3(0,0,1),m1)),fract(dot(nb1+vec3(1,0,1),m1)),nc1.x),mix(fract(dot(nb1+vec3(0,1,1),m1)),fract(dot(nb1+1.,m1)),nc1.x),nc1.y),nc1.z);
vec3 n2=aN*58.,nb2=floor(n2),nc2=fract(n2);nc2*=nc2*(3.-2.*nc2);
float n32=mix(mix(mix(fract(dot(nb2,m1)),fract(dot(nb2+vec3(1,0,0),m1)),nc2.x),mix(fract(dot(nb2+vec3(0,1,0),m1)),fract(dot(nb2+vec3(1,1,0),m1)),nc2.x),nc2.y),mix(mix(fract(dot(nb2+vec3(0,0,1),m1)),fract(dot(nb2+vec3(1,0,1),m1)),nc2.x),mix(fract(dot(nb2+vec3(0,1,1),m1)),fract(dot(nb2+1.,m1)),nc2.x),nc2.y),nc2.z);
float g=aN.x/fN+(n31*.5+n32*.25)/fN*.09,k=abs(g),n=.00015/(.008+k*48.);i+=k*.12;
vec3 aS=a+m*.03;aS.xz*=e;aS.yz*=e;aS.xy=abs(mod(aS.xy+1.,32.));float fS=.5;
for(int cI=0;cI<5;cI++){aS=mod(aS-1.,2.)-1.;float gS=dot(aS,aS)*.5;fS/=gS;aS=abs(aS)/gS;}
vec3 sn1=aS*24.5,sb1=floor(sn1),sc1=fract(sn1);sc1*=sc1*(3.-2.*sc1);
float sn31=mix(mix(mix(fract(dot(sb1,m1)),fract(dot(sb1+vec3(1,0,0),m1)),sc1.x),mix(fract(dot(sb1+vec3(0,1,0),m1)),fract(dot(sb1+vec3(1,1,0),m1)),sc1.x),sc1.y),mix(mix(fract(dot(sb1+vec3(0,0,1),m1)),fract(dot(sb1+vec3(1,0,1),m1)),sc1.x),mix(fract(dot(sb1+vec3(0,1,1),m1)),fract(dot(sb1+1.,m1)),sc1.x),sc1.y),sc1.z);
vec3 sn2=aS*58.,sb2=floor(sn2),sc2=fract(sn2);sc2*=sc2*(3.-2.*sc2);
float sn32=mix(mix(mix(fract(dot(sb2,m1)),fract(dot(sb2+vec3(1,0,0),m1)),sc2.x),mix(fract(dot(sb2+vec3(0,1,0),m1)),fract(dot(sb2+vec3(1,1,0),m1)),sc2.x),sc2.y),mix(mix(fract(dot(sb2+vec3(0,0,1),m1)),fract(dot(sb2+vec3(1,0,1),m1)),sc2.x),mix(fract(dot(sb2+vec3(0,0,1),m1)),fract(dot(sb2+vec3(1,0,1),m1)),sc2.x),sc2.y),sc2.z);
float sG=aS.x/fS+(sn31*.5+sn32*.25)/fS*.09;
n*=clamp(abs(sG)/(k+.001),.8,.5);j+=n;float tV=.0004/(.04+k*48.);l+=tV;
vec3 pH=vec3(fract(i+float(b)*.002),.32,.95);vec4 pC=vec4(1.,-5.5/7.6,0,5.);
c+=pH.z*mix(pC.xxx,clamp(abs(fract(pH.xxx+pC.xyz)*.6-pC.www)-pC.xxx,1.,.2),pH.y)*(n+tV);
if(j>=1.||i>=27.2)break;}
c=pow(clamp(c/max(j+l,.0001)*(pow(clamp(j,0.,1.),1.2)+l),0.,1.),vec3(1));wc=c/(.18+c*.34);}
vec2 bo=abs(hv-.5);float bD=max(bo.x,bo.y),iB=smoothstep(.46,.485,bD),iZ=smoothstep(.44,.46,bD)*(1.-iB);
float T=iTime;
float pG=length(max(bo-.46,0.))*25.-T*4.;
vec3 aC=ac*1.5*(.6+.4*sin(pG))+.2*vec3(sin(T*2.),cos(T*3.),sin(T*1.5));
vec3 fS=mix(wc,mix(vec3(.85),aC,.5),iB*(1.-z));fS=mix(fS,vec3(.05),iZ*(1.-z));
col=fS*(df*lI+.12)+sc*.25*(1.-z);col=mix(col,bc,smoothstep(2.5,6.,t)*(1.-z));}
}

void mainImage(out vec4 O,in vec2 U){
vec2 R=iResolution.xy;
float floorLevel = R.y * 0.15;
vec3 col;
if(U.y < floorLevel){
vec2 rU = vec2(U.x, 2.0 * floorLevel - U.y);
float hi; vec2 hv; float z; vec3 ac, bc; float t;
renderScene(rU, col, hi, hv, z, ac, bc, t);
float dist = (floorLevel - U.y) / floorLevel;
col *= mix(0.4, 0.05, dist);
col += vec3(0.02, 0.03, 0.05) * dist;
} else {
float hi; vec2 hv; float z; vec3 ac, bc; float t;
renderScene(U, col, hi, hv, z, ac, bc, t);
}
vec2 sU=U/R;vec3 fsc=vec3(0);
float T=iTime,p=6.,mt=1.,tv=mod(T,p),si=floor(T/p),mp=smoothstep(0.,mt,tv),g=si+mp,pt=max(0.,tv-mt),pd=p-mt,zi=smoothstep(.2,1.2,pt),zo=1.-smoothstep(pd-1.,pd-.2,pt),z=zi*zo;
z*=z*(3.-2.*z);
float ai=mod(floor(g),10.),tF=mod(ai,5.);
vec3 ac=(tF<1.)?vec3(1,.15,.25):(tF<2.)?vec3(.1,.55,1):(tF<3.)?vec3(1,.75,.05):(tF<4.)?vec3(.05,.85,.45):vec3(.65,.2,.95);
if(tF<1.){
vec2 u=sU*R,j=R;float c=T*.5,k=cos(c),l=sin(c),e=.005,i=0.,A=i,n=A,p,q,g,r;mat2 m=mat2(k,-l,l,k);
vec3 d=normalize(vec3((u-.5*j)/j.y,.4)),x=clamp(abs(fract(c/6.+vec3(1,2./3.,1./3.))*6.-3.)-1.,0.,1.),h=vec3(0),B,f,tc;
d.xz*=m;d.yz*=m;vec4 wF=vec4(0);
for(int o=0;o<128;o++){
h+=d*e;p=length(h)+1e-5;B=h/p;q=0.;g=1.5;f=B;r=log(p*2.)-c*.7;
for(int s=0;s<5;s++){tc=cos(f*g*3.14159+vec3(r,c,c*1.3));q+=abs(dot(tc,vec3(.215)))/g;n+=tc.y/g;f.xy*=mat2(1,1.8,0,.1);f.yz*=mat2(.8,1,.7,.1);r*=1.25;g*=1.5;}
++A;e=max(abs(q)*.13,0.);i+=e;wF+=(1.+sin(vec4(1,.4,-.5,0)))*exp(-e*80.)*(.15/(1.+i*.1));
if(i>0.){d*=0.;e+=1e-3;}}
wF.rgb=mix(wF.rgb,x*wF.a,.47);fsc=tanh(wF.rgb*.36);
}else if(tF<2.){
vec2 o=sU*R,p=R;float c=T,t0=floor(c*.08),t2=fract(c*.08);t2=t2*t2*(3.-2.*t2);
float pu=1.+.25*sin(c*3.14159),b=.4,g=0.,h=1.;vec4 j=vec4(0);
vec3 a=vec3(0),d=vec3(0,0,-1.),k=.5-vec3(o,0)/p.y;
for(int i=0;i<54;i++){
if(h<.005)k=vec3(0);a=(d+=k*max(b,.001));float e=c*.15,f=c*.1;mat2 q=mat2(cos(e),-sin(e),sin(e),cos(e)),r=mat2(cos(f),-sin(f),sin(f),cos(f));
a.zy*=q;a.xz*=r;a.z=fract(a.z+.5)-.5;g=2.;a=-abs(a);
float p1=sin(t0*1.3)*.5,p2=cos(t0*1.7)*.5,p3=sin(t0*2.1)*.5,np1=sin((t0+1.)*1.3)*.5,np2=cos((t0+1.)*1.7)*.5,np3=sin((t0+1.)*2.1)*.5;
float c1=mix(p1,np1,t2),c2=mix(p2,np2,t2),c3=mix(p3,np3,t2);
for(int l=0;l<14;l++){a=abs(a)-(.3+c1*.1);float s=dot(a,a);b=(5.5+c2*2.)/max(s,0.);g*=b;a=abs(a)*b-(2.5+c3*.5);}
h=length(d);b=min(abs(h),length(a.xz)/g);vec3 m=(.5+.5*cos(c*.6+d.xyx*1.2+vec3(0,.8,1.6)+length(a)*.05))*(.6+.4*sin(c*2.5+float(i)*.1));
j+=vec4(m,1.)*(.07*pu)/exp(b*220.);}
fsc=clamp(j.rgb*1.2+.05,0.,1.);
}else if(tF<3.){
vec2 n=sU*R,h=R;float e=T;vec3 c=vec3(0),g=vec3(0,0,-.3);g.xy+=vec2(sin(e),cos(e*.3))*.5;
vec3 i=vec3((n*2.-h)/h.y,.5);float d=0.,b=d,p=b;
for(int j=0;j<135;j++){
vec3 a=g;float r2=e*.4;a.yz*=mat2(cos(r2),-sin(r2),sin(r2),cos(r2));b=3.8;a=1.-abs(a);
for(int k=0;k<3;k++){a=abs(a)-1.;d=4.2/min(dot(a,a),1.9);b*=d;a=abs(a)*d-3.8;a.z+=4.2;}
d=length(a.xz)/b;float l=max(d,0.);p+=l;g+=i*l;c+=vec3(exp(-d*40.6))*.015;}
fsc=1.-exp(-pow(c,vec3(4.2)));
}else if(tF<4.){
vec2 u=sU*R;vec3 k=normalize(vec3((u+u-1.4*R)/R.y,1)),l=vec3(.5,0,.1),a=vec3(.447,.894,.179),c,i;
l.yz*=mat2(cos(T*.1+vec4(0,33,11,0)));float s=sin(T*.15),g=cos(T*.15),b=1.-g;
k=mat3(b*a.x*a.x+g,b*a.x*a.y-a.z*s,b*a.z*a.x+a.y*s,b*a.x*a.y+a.z*s,b*a.y*a.y+g,b*a.y*a.z-a.x*s,b*a.z*a.x-a.y*s,b*a.y*a.z+a.x*s,b*a.z*a.z+g)*k;
vec4 wF=vec4(0);float m=0.,e,j,h;mat2 I=mat2(cos(-3.5814+vec4(0,33,11,0)));
for(int A=0;A<91&&m<=47.6;A++){
c=l+k*m;h=max(length(c),1e-4);i=fract(vec3(log(h)-T*.25,c.y/h,atan(c.z,c.x))*.7957)-.5;j=.4;c=i;
for(int B=0;B<12;B++){c=abs(c)-vec3(.42,.49,.66);c.xz*=I;float C=1.5/max(dot(c,c),1e-8);c=c*C-vec3(.1,.5,.4);j*=C;}
e=max((length(c.xz)-.2)/max(j,1e-4),1e-4);m+=e;wF+=vec4(sin(vec3(0,1,1.8)-i.z*8.7+T)*.5+.65,1)*.015/(e*80.+.74);}
fsc=min(wF.rgb,.8);
}else{
vec2 w=sU*R,p=R;float h=T*.3,q=h*.3,r=sin(q),s=cos(q),i=1.,j=0.,l=0.;mat2 e=mat2(s,-r,r,s);
vec3 B=vec3(0,0,-3.),C=normalize(vec3((w*2.-p)/p.y,1.5)),c=vec3(0),m=normalize(vec3(sin(h*-6.5),cos(h*-5.6),-8.));
m.xz*=e;m.yz*=e;
for(int b=0;b<60;b++){
vec3 a=B+C*i,aN=a;aN.xz*=e;aN.yz*=e;aN.xy=abs(mod(aN.xy+1.,32.));float fN=.5;
for(int cI=0;cI<5;cI++){aN=mod(aN-1.,2.)-1.;float gN=dot(aN,aN)*.5;fN/=gN;aN=abs(aN)/gN;}
vec3 n1=aN*24.5,nb1=floor(n1),nc1=fract(n1);nc1*=nc1*(3.-2.*nc1);
vec3 m1=vec3(444.,397.,491.);float n31=mix(mix(mix(fract(dot(nb1,m1)),fract(dot(nb1+vec3(1,0,0),m1)),nc1.x),mix(fract(dot(nb1+vec3(0,1,0),m1)),fract(dot(nb1+vec3(1,1,0),m1)),nc1.x),nc1.y),mix(mix(fract(dot(nb1+vec3(0,0,1),m1)),fract(dot(nb1+vec3(1,0,1),m1)),nc1.x),mix(fract(dot(nb1+vec3(0,0,1),m1)),fract(dot(nb1+vec3(1,0,1),m1)),nc1.x),nc1.y),nc1.z);
vec3 n2=aN*58.,nb2=floor(n2),nc2=fract(n2);nc2*=nc2*(3.-2.*nc2);
float n32=mix(mix(mix(fract(dot(nb2,m1)),fract(dot(nb2+vec3(1,0,0),m1)),nc2.x),mix(fract(dot(nb2+vec3(0,1,0),m1)),fract(dot(nb2+vec3(1,1,0),m1)),nc2.x),nc2.y),mix(mix(fract(dot(nb2+vec3(0,0,1),m1)),fract(dot(nb2+vec3(1,0,1),m1)),nc2.x),mix(fract(dot(nb2+vec3(0,0,1),m1)),fract(dot(nb2+vec3(1,0,1),m1)),nc2.x),nc2.y),nc2.z);
float g=aN.x/fN+(n31*.5+n32*.25)/fN*.09,k=abs(g),n=.00015/(.008+k*48.);i+=k*.12;
vec3 aS=a+m*.03;aS.xz*=e;aS.yz*=e;aS.xy=abs(mod(aS.xy+1.,32.));float fS=.5;
for(int cI=0;cI<5;cI++){aS=mod(aS-1.,2.)-1.;float gS=dot(aS,aS)*.5;fS/=gS;aS=abs(aS)/gS;}
vec3 sn1=aS*24.5,sb1=floor(sn1),sc1=fract(sn1);sc1*=sc1*(3.-2.*sc1);
float sn31=mix(mix(mix(fract(dot(sb1,m1)),fract(dot(sb1+vec3(1,0,0),m1)),sc1.x),mix(fract(dot(sb1+vec3(0,1,0),m1)),fract(dot(sb1+vec3(1,1,0),m1)),sc1.x),sc1.y),mix(mix(fract(dot(sb1+vec3(0,0,1),m1)),fract(dot(sb1+vec3(1,0,1),m1)),sc1.x),mix(fract(dot(sb1+vec3(0,0,1),m1)),fract(dot(sb1+vec3(1,0,1),m1)),sc1.x),sc1.y),sc1.z);
vec3 sn2=aS*58.,sb2=floor(sn2),sc2=fract(sn2);sc2*=sc2*(3.-2.*sc2);
float sn32=mix(mix(mix(fract(dot(sb2,m1)),fract(dot(sb2+vec3(1,0,0),m1)),sc2.x),mix(fract(dot(sb2+vec3(0,1,0),m1)),fract(dot(sb2+vec3(1,1,0),m1)),sc2.x),sc2.y),mix(mix(fract(dot(sb2+vec3(0,0,1),m1)),fract(dot(sb2+vec3(1,0,1),m1)),sc2.x),mix(fract(dot(sb2+vec3(0,0,1),m1)),fract(dot(sb2+vec3(1,0,1),m1)),sc2.x),sc2.y),sc2.z);
float sG=aS.x/fS+(sn31*.5+sn32*.25)/fS*.09;
n*=clamp(abs(sG)/(k+.001),.8,.5);j+=n;float tV=.0004/(.04+k*48.);l+=tV;
vec3 pH=vec3(fract(i+float(b)*.002),.32,.95);vec4 pC=vec4(1.,-5.5/7.6,0,5.);
c+=pH.z*mix(pC.xxx,clamp(abs(fract(pH.xxx+pC.xyz)*.6-pC.www)-pC.xxx,1.,.2),pH.y)*(n+tV);
if(j>=1.||i>=27.2)break;}
c=pow(clamp(c/max(j+l,.0001)*(pow(clamp(j,0.,1.),1.2)+l),0.,1.),vec3(1));fsc=c/(.18+c*.34);}
col=mix(col,fsc,smoothstep(.96,1.,z));
vec2 bV=U/R;if(bV.y>.89||bV.y<.09){
float bA=(1.-smoothstep(.4,.95,z))*.95,eg=abs(mod(bV.y,.09)-.09);
col=mix(col,mix(vec3(.02),ac*1.3,smoothstep(.004,0.,eg)),bA);}

vec2 charSz = vec2(28.0, 42.0);
int txtTop[16];
txtTop[0]=51; txtTop[1]=68; txtTop[2]=32; txtTop[3]=67; txtTop[4]=65; txtTop[5]=82; txtTop[6]=79; txtTop[7]=85; txtTop[8]=83; txtTop[9]=69; txtTop[10]=76;
vec2 posTop = vec2((R.x - 11.0 * charSz.x) * 0.5, R.y - 54.0);
drawText(col, vec3(1.0), U, posTop, charSz, txtTop, 11);

int txtBot[16];
txtBot[0]=83; txtBot[1]=65; txtBot[2]=78; txtBot[3]=68; txtBot[4]=69; txtBot[5]=70; txtBot[6]=74; txtBot[7]=79; txtBot[8]=82; txtBot[9]=68;
vec2 posBot = vec2((R.x - 10.0 * charSz.x) * 0.5, 12.0);
drawText(col, vec3(1.0), U, posBot, charSz, txtBot, 10);

O=vec4(clamp(col,0.,1.),1.);}
