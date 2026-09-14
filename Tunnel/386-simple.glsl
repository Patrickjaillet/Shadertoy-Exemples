// ==== Image (image) ====
#define cQ vec3(.22,.07,.08)
#define cP vec2(J*1.05,j*2.)
#define cO step(.5,i(C*71.3))
#define cN floor((t+.72)*2.2)
#define cM az(y*.37+aE*.14+.3)
#define cL step(.35,i(C*27.7))
#define cK aZ(f,z,U,V,W,E,K,A)
#define cJ vec3(0.)
#define cI floor(c.z/g)
#define cH smoothstep(ae-.06,ae,abs(j))
#define cG step(.12,i(floor(iTime*18.)+y*13.))
#define al 3.14159265
mat2 ay(float l){float F=cos(l),B=sin(l);return mat2(F,-B,B,F);}
float i(float a){return fract(sin(a*127.13)*43758.5453);}
float ap(vec2 a){a=fract(a*vec2(123.34,456.21));a+=dot(a,a+45.32);return fract(a.x*a.y);}

float bn(vec2 a){
vec2 d=floor(a),M=fract(a);M=M*M*(M);
float l=ap(d),aa=ap(d+vec2(1,0)),F=ap(d+vec2(0,1)),ab=ap(d+vec2(1,1));
return mix(mix(l,aa,M.x),mix(F,ab,M.x),M.y);
}

float N(vec2 a){float B=0.,l=.5;for(int d=0;d++<5;){B+=l*bn(a);a*=2.03;l*=.5;}return B;}

vec3 az(float f){
return .65+.35*cos(6.2831853*(vec3(.8,.3,.15)*f+vec3(.1,.2,.35)));
}

float aA(vec2 m,float bo){
float n=length(m),l=atan(m.y,m.x),aq=8.*floor(i(bo+3.)*4.),q=0.;

q+=smoothstep(.14,0.,n)*2.2;
q+=smoothstep(.02,0.,abs(n-.3))*1.2;
q+=smoothstep(.02,0.,abs(n-.55))*1.2;
q+=smoothstep(.025,0.,abs(n-.8))*.9;

float bp=pow(.5+.5*cos(l*aq),8.);
q+=bp*smoothstep(.96,.1,n)*1.3;

float bq=pow(.5+.5*cos(l*aq+.5*al/aq),10.);
q+=bq*smoothstep(.6,.05,abs(n-.45))*1.;

float aB=pow(.5+.5*cos(l*aq*2.),32.);
q+=aB*smoothstep(.85,.08,n)*.8;

q*=smoothstep(1.1,.8,n);

return q;
}

float G(vec3 a,vec3 aa,float ac){
a=abs(a)-aa;
vec3 m=max(a,0.);
return length(m)+min(max(m.x,max(m.y,m.z)),0.)-ac;
}

const float g=2.2;
const float r=1.7;
const float u=1.15;

vec2 O(vec2 l,vec2 aa){return l.x<aa.x?l:aa;}

vec2 ad(vec3 a){
float H=abs(a.x),j=mod(a.z,g)-.5*g,am=mod(a.z-.5*g,g)-.5*g;

vec2 k=vec2(a.y+u,6.);
k=O(k,vec2(u-a.y,4.));
k=O(k,vec2(r-H,1.));

float aR=.22,aC=.28,br=G(vec3(H-(r-.5*aR),a.y,am),vec3(.5*aR-.01,u-.05,aC-.01),.05);
k=O(k,vec2(br,2.));

float bs=G(vec3(H-(r-.17),a.y-(u-.15),am),vec3(.16,.14,aC+.09),.04),bt=G(vec3(H-(r-.17),a.y+(u-.17),am),vec3(.16,.16,aC+.09),.04);
k=O(k,vec2(min(bs,bt),2.));

float bu=G(vec3(H-(r-.07),a.y-(u-.12),0.),vec3(.07,.04,1e3),.04),bv=G(vec3(H-(r-.07),a.y+(u-.16),0.),vec3(.07,.06,1e3),.04);
k=O(k,vec2(min(bu,bv),8.));

float bw=G(vec3(H-(r-.19),a.y-.38,am),vec3(.04,.12,.04),.03);
k=O(k,vec2(bw,7.));

float bx=G(vec3(a.x,a.y-(u-.05),am),vec3(1e3,.05,.1),.03),by=G(vec3(H-(r-.55),a.y-(u-.05),0.),vec3(.05,.05,1e3),.03);
k=O(k,vec2(min(bx,by),8.));

return k;
}

vec3 bz(vec3 a){
const vec2 I=vec2(1.,-1.);
const float ac=.0018;
return normalize(I.xyy*ad(a+I.xyy*ac).x+I.yyx*ad(a+I.yyx*ac).x
+I.yxy*ad(a+I.yxy*ac).x+I.xxx*ad(a+I.xxx*ac).x);
}

float bA(vec3 c,vec3 o){
float aS=0.,aT=1.;
for(int d=0;d<5;d++){
float v=.01+.1*float(d)/4.,ab=ad(c+v*o).x;
aS+=aT*(v-ab);
aT*=.95;
}
return clamp(1.-2.5*aS,0.,1.);
}

void bB(vec3 c,float x,out vec3 h,out vec3 P,out float p,out float s,out float Q){
float j=mod(c.z,g)-.5*g,y=cI;

h=vec3(.2);P=cJ;p=0.;s=.5;Q=0.;

if(x<1.5){
float t=c.y/u,ae=.62,aD=1.-cH,aU=.52+.34*sqrt(max(0.,1.-pow(j/ae,2.))),an=aD*step(-.7,t)*step(t,aU),aE=cN;
vec3 aF=cM;
float bC=(.5+.5*sin(t*22.))*(.5+.5*sin(j*40.)),bD=.5+.5*sin((t+j*1.6)*20.)*sin((t-j*1.6)*20.),bE=N(vec2(j*25.,t*25.))*.1;
vec3 bF=vec3(.3,.22,.18)*(.6+.4*N(vec2(j*8.,t*8.)));
h=mix(bF,vec3(.12),an);
P=aF*an*(.6+.4*bC+.3*bD-bE)*3.5;
Q=an*.8;
float aV=smoothstep(.025,0.,abs(t-aU))*aD
+smoothstep(.02,0.,abs(t+.7))*aD;
h=mix(h,vec3(.8,.55,.25),clamp(aV,0.,1.));
p=clamp(aV,0.,1.)*.7;
s=mix(.6,.2,p);
}else if(x<2.5||(x>7.5)){
h=vec3(.75,.58,.28);
float bG=mod(c.z-.5*g,g)-.5*g,bH=.5+.5*sin(bG*70.);
h*=.8+.2*bH;
p=.8;s=.25;
}else if(x<4.5){
float J=c.x/r;
vec3 aG=vec3(.12,.08,.1);
vec2 m=cP*1.18;
float q=aA(m,y);
vec3 bI=vec3(1.,.35,.15);
P=bI*q*4.;
h=aG;
s=.6;
}else if(x<6.5){
float bJ=N(vec2(c.x*2.,c.z*.5));
h=mix(vec3(.12,.08,.08),vec3(.45,.05,.05),smoothstep(.4,.7,bJ));
p=.1;s=.15;
}else{
float aH=cG;
P=vec3(1.5,.6,.2)*16.*aH;
h=vec3(.7,.4,.18);
p=.8;s=.2;
}
}

vec3 aW(vec3 c,vec3 o,vec3 e,vec3 h,float p,float s,float Q){
float y=cI;

vec3 b=cJ,bK=vec3(.18,.12,.14);
b+=h*bK;

vec3 R[4];
vec3 S[4];

float aH=cG;

R[0]=normalize(vec3(.15,1.,.2));S[0]=vec3(.7,.3,.35);
R[1]=normalize(vec3(.1,-1.,.2));S[1]=vec3(.4,.18,.18);
R[2]=normalize(vec3(-sign(c.x)*1.,.15,.15));S[2]=vec3(1.2,.45,.22);
R[3]=normalize(vec3(0.,0.,1.));S[3]=vec3(1.5,.8,.3)*8.*aH;

for(int d=0;d<4;d++){
float bL=max(dot(o,R[d]),0.);
vec3 v=normalize(R[d]-e);
float aX=mix(16.,1024.,1.-s),aB=pow(max(dot(o,v),0.),aX)*aX/16.;
b+=h*S[d]*bL*1.2;
b+=S[d]*aB*mix(.3,2.,p);
float bM=max(dot(o,-R[2]),0.);
b+=S[2]*Q*bM*.8*h;
}

if(p>.01||s<.2){
vec3 n=reflect(e,o),bN=vec3(.7,.25,.12)*.8;
float ar=pow(1.-max(dot(-e,o),0.),3.),bO=mix(p*.5+.15*ar,p+.5*ar,s);
b+=bN*clamp(bO,0.,1.);
}

b*=bA(c,o);
return b;
}

vec3 bP(vec3 T,vec3 e){
float aI=1e9,aY=e.y>1e-4?(u-T.y)/e.y:aI,bQ=e.x>1e-4?(r-T.x)/e.x:aI,bR=e.x<-1e-4?(-r-T.x)/e.x:aI,aJ=min(aY,min(bQ,bR));
vec3 as=T+e*max(aJ,0.);

float y=floor(as.z/g),j=mod(as.z,g)-.5*g;

vec3 F;
if(aJ==aY){
float J=as.x/r;
vec2 m=cP*1.18;
float q=aA(m,y);
F=vec3(1.2,.4,.18)*q+vec3(.12,.06,.04);
}else{
float t=clamp(as.y/u,-1.,1.),ae=.62,aE=cN;
vec3 aF=cM;
float an=(1.-cH)*step(-.7,t);
F=aF*an*2.2+vec3(.15,.08,.05);
}

vec3 at=cQ;
return mix(F,at,smoothstep(12.,60.,aJ));
}

void aZ(float f,out float z,out float U,out float V,out float W,out float E,out float K,out float A){
float X=0.,af=0.;

z=0.;
U=1.;
V=0.;
W=0.;
E=0.;
K=0.;
A=0.;

for(int d=0;d<20;d++){
float C=float(d),w=5.+i(C*13.1)*8.,aK=cL,au=(3.+i(C*41.3)*5.)*aK,ba=w+au,bS=(i(C*53.9)<.5)?1.:-1.,ag=cO,Y=mix(1.,2.5,ag),ah=mix(5.,10.5,ag);

if(f>=X&&(f<X+ba||d==19)){
float ai=f-X;
U=Y;

if(ai<w){
z=smoothstep(0.,1.2,ai)*(1.-smoothstep(w-1.2,w,ai));
K=af+ai*1.1*Y;
A=ai*ah;
}else{
float aj=(ai-w)/max(au,.001);
z=0.;
K=af+w*1.1*Y;
A=w*ah;

float bT=smoothstep(0.,.25,aj)*(1.-smoothstep(.4,.55,aj)),bb=smoothstep(.35,.65,aj)*(1.-smoothstep(.85,1.,aj));
E=smoothstep(.6,.82,aj)*(1.-smoothstep(.88,1.,aj));

V=-.9*bT+.1*bb;
W=bS*al*smoothstep(0.,1.,bb);
}
break;
}

X+=ba;
af+=w*1.1*Y;
}
}

void bU(vec2 a,float f,out float v,out vec2 bc,out float bd){
v=0.;
bc=vec2(0.);
bd=0.;

float X=0.,af=0.;

for(int aL=0;aL<20;aL++){
float C=float(aL),w=5.+i(C*13.1)*8.,aK=cL,au=(3.+i(C*41.3)*5.)*aK,ag=cO,Y=mix(1.,2.5,ag),ah=mix(5.,10.5,ag),bV=w*ah/al;
int bW=int(floor(bV));

for(int B=0;B<40;B++){
if(B>=bW)break;

float aM=float(B),bX=X+(aM*al)/ah,L=f-bX;

if(L>0.&&L<3.5){
float bY=(mod(aM,2.)==0.?.3:-.3),bZ=af+((aM*al)/ah)*1.1*Y;
vec2 ca=vec2(bY,bZ),ab=a-ca;
float ao=length(ab),cb=1.8,cc=L*cb,Z=ao-cc,aN=1./(1.+ao*1.2),av=mix(1.,1.8,ag),cd=sin(Z*16.)*exp(-abs(Z)*2.2)*exp(-L*.9)*aN*av;
v+=cd*.15;

vec2 ce=ao>.0001?ab/ao:vec2(0.);
float cf=(16.*cos(Z*16.)-sign(Z)*2.2*sin(Z*16.))*exp(-abs(Z)*2.2)*exp(-L*.9)*aN*av;
bc+=ce*cf*.15;

float cg=smoothstep(.05,0.,abs(Z))*exp(-L)*aN*av,ch=smoothstep(.3,0.,ao)*smoothstep(0.,.08,L)*exp(-L*3.5)*av;
bd+=(cg*1.2+ch*2.5);
}
}

X+=w+au;
af+=w*1.1*Y;
}
}

vec3 ci(vec3 c,vec3 o,vec3 e,float x){
vec3 h,P;float p,s,Q;
bB(c,x,h,P,p,s,Q);
vec3 b=P+aW(c,o,e,h,p,s,Q);
return b;
}

vec3 cj(vec2 D,float f){
float z,U,V,W,E,K,A;
cK;

float ck=(i(f*80.)-.5)*.18*E,cl=(i(f*80.+17.1)-.5)*.18*E,cm=(i(f*80.+31.4)-.5)*.12*E,aw=(U>1.5?1.8:1.),be=(abs(sin(A))*.07*aw-.035*aw)*z,bf=(cos(A*.5)*.05*aw)*z,cn=(sin(A*.5)*.02*aw)*z;

vec3 T=vec3(bf,-.25+be,K),e=vec3(D,1.35);
e.yz*=ay(.05+V+be*.2+cl);
e.xz*=ay(W+bf*.3+ck);
e.xy*=ay(cn+.015*sin(f*.3)+cm);
e=normalize(e);

float ak=0.;vec2 v=vec2(1e9,0.);bool bg=false;
for(int d=0;d++<120;){
vec3 c=T+e*ak;
v=ad(c);
if(v.x<.001*ak+.0006){bg=true;break;}
ak+=v.x*.93;
if(ak>120.)break;
}

vec3 b=cJ,at=cQ;

if(bg){
vec3 c=T+e*ak,o=bz(c);
float x=v.y;

if(x>5.5&&x<6.5){
float J=c.x/r,y=cI,j=mod(c.z,g)-.5*g,bh=abs(J),co=0.;
vec2 aO=vec2(0.);
float bi=0.;
bU(c.xz,f,co,aO,bi);

float bj=N(vec2(c.x*3.,c.z*1.4)),cp=smoothstep(.45,.5,abs(N(vec2(c.x*2.2+bj,c.z*1.1))-.5)*2.);

vec3 aG=vec3(.1,.04,.04)*(1.+.7*cp)+vec3(.18,.05,.05)*bj*.25,cq=vec3(-aO.x,0.,-aO.y)*.8,aP=normalize(o+cq+vec3((N(vec2(c.x*8.,c.z*4.))-.5)*.03,0.,
(N(vec2(c.z*8.,c.x*4.))-.5)*.03)),cr=az(y*.31+.3);
float cs=1.-smoothstep(.62,.78,abs(j)/(.5*g)),ct=smoothstep(.4,.45,bh)*(1.-smoothstep(.8,.9,bh))*cs;
vec3 cu=cr*ct*2.5;

vec2 m=vec2(J*1.4,j*2.)*1.35;
float cv=aA(m,y+13.);
vec3 cw=vec3(1.2,.35,.15)*cv*1.8,n=reflect(e,aP),cx=bP(c+o*.01,n);

float ar=pow(1.-max(dot(-e,aP),0.),4.),cy=.6+.35*ar;

b=aG+cu+cw;
b=mix(b,cx,cy);

vec3 cz=vec3(1.2,.6,.3);
b+=cz*clamp(bi,0.,2.5);

b+=aW(c,aP,e,b,0.,.03,0.)*.15;
b+=vec3(1.2,.45,.18)*exp(-J*J*12.)*.6;

}else
b=ci(c,o,e,x);


float cA=1.-exp(-ak*.008);
b=mix(b,at,smoothstep(0.,1.,cA)*.5);

}else
b=at;


return b;
}

void mainImage(out vec4 cB,vec2 bk){
vec3 b=cJ;
float f=iTime;

vec2 D=(bk-.5*iResolution.xy)/iResolution.y;

float n=length(D),aQ=.5+.5*sin(f*1.5),cC=mix(.1,.85,aQ);

D*=1.+cC*(n*n);
D*=1.-.25*aQ;

float z,U,V,W,E,K,A;
cK;

float cD=sin(D.y*30.+f*10.)*cos(D.x*20.+f*8.)*.005*abs(sin(A))*z;
D+=cD;

b=cj(D,f);

vec2 bl=D;
float cE=exp(-dot(bl*vec2(1.,1.2),bl*vec2(1.,1.2))*25.);
b+=vec3(1.,.35,.15)*cE*.55;

vec2 ax=bk/iResolution.xy;
float cF=mix(.1,.2,aQ);
b*=.6+.4*pow(16.*ax.x*ax.y*(1.-ax.x)*(1.-ax.y),cF);

float bm=dot(b,vec3(.299,.587,.114));
b+=b*smoothstep(.3,1.2,bm)*.4;
b=mix(vec3(bm),b,1.25);

b=pow(max(b,0.),vec3(.85));
b=b/(1.+b*.1);

b=clamp(b,0.,1.);

cB=vec4(b,1.);
}
