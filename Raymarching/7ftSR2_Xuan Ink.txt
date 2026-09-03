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
float h(vec2 p){
    p=fract(p*vec2(123.34,456.21));
    return fract(p.x*p.y+dot(p,p+45.32)*p.x*p.y);
}

float n(vec2 p){
    vec2 i=floor(p),f=fract(p),u=f*f*(3.-2.*f);
    return mix(mix(h(i),h(i+vec2(1,0)),u.x),mix(h(i+vec2(0,1)),h(i+1.),u.x),u.y);
}

void mainImage(out vec4 O,vec2 C){
    vec2 R=iResolution.xy,u=C/R,v=(C-.5*R)/R.y;
    
    vec2 s=u*vec2(1200,600);
    float T=n(s),N=n(s*.4+15.),
          p=sin(s.x*.08+T*7.)*cos(s.y*.08+N*7.)*.035+h(u*1500.)*.06;
          
    vec3 c=(vec3(.95,.91,.83)-p)*(1.-length(v)*.45);
    
    float m=0.;
    for(int i=0;i<49;i++)
        m+=texture(iChannel0,u-vec2(.015,.022)+(vec2(i%7-3,i/7-3))*4./R).a;
        
    c=mix(c,c*vec3(.18,.14,.11),m/49.*.72);
    
    vec4 I=texture(iChannel0,u);
    float d=length(v)*.0025;
    vec3 k=vec3(texture(iChannel0,u+vec2(d,0)).r,I.g,texture(iChannel0,u-vec2(d,0)).b);
    
    c=mix(c,k,I.a)+(h(u+iTime*.05)-.5)*.02;
    
    c=clamp(c*(2.51*c+.03)/(c*(2.43*c+.59)+.14),0.,1.);
    O=vec4(pow(c,vec3(1./2.2)),1);
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
mat2 y(float g){
float z=cos(g),A=sin(g);
return mat2(z,-A,A,z);
}

float k(vec2 b){
b=fract(b*vec2(123.34,456.21));
b+=dot(b,b+45.32);
return fract(b.x*b.y);
}

float H(vec2 b){
vec2 a=floor(b),q=fract(b),r=q*q*(q);
return mix(mix(k(a),k(a+vec2(1.,0.)),r.x),
mix(k(a+vec2(0.,1.)),k(a+vec2(1.)),r.x),r.y);
}

float i(vec2 b){
float B=0.,g=.5;
mat2 I=y(.5);
for(int a=0;a++<5;){
B+=g*H(b);
b=I*b*2.02;
g*=.5;
}
return B;
}

float J(vec2 b,vec2 g,vec2 K,float L,float M){
vec2 C=b-g,l=K-g;
float D=clamp(dot(C,l)/dot(l,l),0.,1.),c=mix(L,M,D);
return length(C-l*D)-c;
}

void mainImage(out vec4 N,vec2 O){
vec2 m=(O-.5*iResolution.xy)/iResolution.y;

float n=mod(iTime*.8,12.);

vec2 P=vec2(
i(m*4.+vec2(0.,iTime*.02))-.5,
i(m*4.+vec2(iTime*.02,1.))-.5
)*.035,b=m+P;

vec3 E=vec3(.03,.02,.025),Q=vec3(.82,.12,.08);

vec2 d[7];
vec2 h[7];
vec2 c[7];
float e[7];
float f[7];

d[0]=vec2(-.45,.32);h[0]=vec2(.4,.35);c[0]=vec2(.028,.022);e[0]=.5;f[0]=1.;
d[1]=vec2(-.02,.48);h[1]=vec2(-.06,-.42);c[1]=vec2(.045,.026);e[1]=1.6;f[1]=1.4;
d[2]=vec2(-.08,.18);h[2]=vec2(-.42,-.25);c[2]=vec2(.035,.012);e[2]=3.1;f[2]=1.1;
d[3]=vec2(-.02,.14);h[3]=vec2(.42,-.28);c[3]=vec2(.026,.052);e[3]=4.3;f[3]=1.2;
d[4]=vec2(-.28,-.06);h[4]=vec2(.28,-.06);c[4]=vec2(.022);e[4]=5.6;f[4]=.8;
d[5]=vec2(-.45,-.34);h[5]=vec2(.46,-.32);c[5]=vec2(.038,.016);e[5]=6.5;f[5]=1.3;
d[6]=vec2(.25,-.32);h[6]=vec2(.38,-.22);c[6]=vec2(.018,.035);e[6]=7.9;f[6]=.6;

float o=0.,s=0.,R=i(b*vec2(220.,22.));

for(int a=0;a<7;a++){
float p=clamp((n-e[a])/f[a],0.,1.);
if(p>0.){
vec2 S=mix(d[a],h[a],p);
float T=mix(c[a].x,c[a].y,p),F=J(b,d[a],S,c[a].x,T),G=smoothstep(.01,-.005,F),U=smoothstep(.22,.75,R);
G*=mix(.55,1.,U);

float V=clamp(n-(e[a]+p*f[a]),0.,3.),W=i(b*35.+float(a))*.045*smoothstep(0.,2.,V),X=smoothstep(.03+W,-.01,F)*.35;

o=max(o,G);
s=max(s,X);
}
}

vec3 Y=mix(E*1.8,E,smoothstep(0.,.8,o));
float t=clamp(o+s,0.,1.);
vec3 u=Y;

float v=8.8;
if(n>v){
float Z=smoothstep(v,v+.3,n);
vec2 j=m-vec2(.44,-.32);
j*=y(.05);

float w=max(abs(j.x),abs(j.y))-.085;
w+=(i(j*50.)-.5)*.018;

if(w<0.){
float x=smoothstep(.005,-.008,w)*Z,aa=i(j*85.);
x*=smoothstep(.18,.55,aa);

u=mix(u,Q,x);
t=max(t,x*.92);
}
}

N=vec4(u,t);
}
