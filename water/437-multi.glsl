// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
#define j iResolution.xy
void mainImage(out vec4 g,vec2 b)
{
vec2 c=(b-.5*j)/iResolution.y,d=b/j,e=normalize(c);
float f=length(c)*.006;

vec3 a;
a.r=texture(iChannel0,d+e*f).r;
a.g=texture(iChannel0,d).g;
a.b=texture(iChannel0,d-e*f).b;

float h=1.-smoothstep(.38,1.35,length(c*1.25));
a*=.58+.42*h;

a=max(vec3(0.),(a*(2.51*a+.03))/(a*(2.43*a+.59)+.14));

float i=fract(sin(dot(b,vec2(12.9898,78.233)))*43758.5453);
a+=(i-.5)*.035;

g=vec4(a,1.);
}

// ==== Buffer A (buffer) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
#define ap iResolution.xy
#define ao 3.14159265359
#define I 6.28318530718
#define J 2.399963229728653
const float K[48]=float[](
2.,3.,5.,7.,11.,13.,17.,19.,
23.,29.,31.,37.,41.,43.,47.,53.,
59.,61.,67.,71.,73.,79.,83.,89.,
97.,101.,103.,107.,109.,113.,127.,131.,
137.,139.,149.,151.,157.,163.,167.,173.,
179.,181.,191.,193.,197.,199.,211.,223.
);

const float d[12]=float[](
14.134725,21.02204,25.010858,30.424876,
32.935062,37.586178,40.918719,43.327073,
48.005151,49.773832,52.970321,56.446248
);

float L(vec2 p)
{
float q=max(length(p),.002),x=log(q*5.),b=0.;

b+=cos(x*d[0])*.24;
b+=cos(x*d[1])*.21;
b+=cos(x*d[2])*.19;
b+=cos(x*d[3])*.17;
b+=cos(x*d[4])*.15;
b+=cos(x*d[5])*.13;
b+=cos(x*d[6])*.12;
b+=cos(x*d[7])*.1;
b+=cos(x*d[8])*.09;
b+=cos(x*d[9])*.08;
b+=cos(x*d[10])*.07;
b+=cos(x*d[11])*.06;

return b;
}

vec4 M(vec2 p,float c)
{
float y=0.;
vec3 g=vec3(0.);

for(int r=0;r<48;r++)
{
float h=K[r],j=fract(c*.15+h*.137),q=j*j*2.8,z=h*J+j*2.;

vec2 N=vec2(cos(z),sin(z))*q,A=p-N;

float l=dot(A,A),s=sqrt(l),m=j*(1.-j)*4.,O=h*.071,P=.42+fract(h*.137)*.2,B=c*P+O,x=s-mod(B,1.35),C=s-mod(B+.34,1.35),w=exp(-x*x*10000.)+.42*exp(-C*C*6250.);
y+=w*exp(-s*1.25)*m;

float Q=.75+fract(h*.317)*1.35,t=.5+.5*sin(c*Q+h*1.731),R=t*t,i=R*sqrt(t),S=exp(-l/(.000045+i*.00006)),T=exp(-l/(.00018+i*.00024)),U=exp(-l/(.0008+i*.00075));

vec3 u=mix(vec3(1.,.08,.008),vec3(1.,.82,.2),fract(h*.173));

g+=U*u*(.035+i*.085)*m;
g+=T*u*(.2+i*.8)*m;
g+=S*u*(1.+i*3.5)*m;
}

return vec4(g,y);
}

float V(vec2 a,float c)
{
float b=fract(sin(dot(a,vec2(12.9898,78.233)))*43758.5453),v=b*b,D=v*v*v;
return D*D*(.5+.5*sin(c*3.+b*I));
}

vec3 W(vec2 a,float c)
{
float n=c*.018;
a=mat2(cos(n),-sin(n),sin(n),cos(n))*a;

vec4 E=M(a,c);
vec3 e=vec3(0.);

float X=E.w,Y=L(a),Z=.92+.08*sin(c*1.7),w=X*(.55+.45*(.5+.5*Y))*Z,x=w*w,aa=x*x;

e+=vec3(.015,.18,1.)*w;
e+=vec3(.48,.025,.85)*x*.45;
e+=vec3(1.,.1,.008)*aa*.35;

e+=vec3(.08,.025,.15)*V(a,c);
e+=E.rgb;

float ab=exp(-dot(a,a)*9.);
e+=vec3(1.,.08,.005)*ab*.025;

return e;
}

vec2 ac(vec2 a,float c)
{
float f=c*.22,F=sin(f*.37)*.03+sin(f*.17)*.01,ad=1.+sin(f*.23)*.03;

vec2 ae=vec2(
sin(f*.19)*.02+cos(f*.113)*.01,
cos(f*.23)*.02+sin(f*.053)*.01
);

float g=cos(F),G=sin(F);

a=mat2(g,-G,G,g)*a;

float af=1.+sin(f*.11+length(a)*2.)*.015;

a*=af;
a/=ad;
a+=ae;

return a;
}

void mainImage(out vec4 ag,vec2 H)
{
vec2 a=(H-.5*ap)/iResolution.y;
a*=1.25;
float c=iTime*.55;

a=ac(a,iTime);

vec2 k=H/ap;
vec3 ah=W(a,c),ai=texture(iChannel0,k).rgb;
vec2 o=1./ap;

vec3 aj=texture(iChannel0,k+vec2(o.x,0.)).rgb,ak=texture(iChannel0,k-vec2(o.x,0.)).rgb,al=texture(iChannel0,k+vec2(0.,o.y)).rgb,am=texture(iChannel0,k-vec2(0.,o.y)).rgb,an=ai*.5+aj*.125+ak*.125+al*.125+am*.125,e=mix(ah,an,.875)*.988;

ag=vec4(e,1.);
}
