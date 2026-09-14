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
vec3 l(float m){
vec3 a=vec3(.5),n=vec3(.5),o=vec3(1.),p=vec3(0.,.33,.67);
return a+n*cos(6.28318*(o*m+p));
}

void mainImage(out vec4 q,vec2 r){
vec2 b=r/iResolution.xy;

vec2 dir = b - 0.5;
float dist = length(dir);
float mask = smoothstep(0.1, 0.7, dist);

vec3 acc = vec3(0.);
float totalWeight = 0.;
int samples = 12;

for(int i = 0; i < 12; i++){
    float offset = (float(i) / 11. - 0.5) * 0.08 * mask;
    vec2 uv = b + normalize(dir) * offset;
    
    vec4 e=texture(iChannel0,uv);
    vec3 c=e.rgb;
    float f=e.a;

    vec3 g=c+1.;
    float h=length(g);

    vec3 ip=1./iResolution.xyx,s=texture(iChannel0,uv+ip.xz).rgb,t=texture(iChannel0,uv+ip.zy).rgb,a=normalize(cross(s-c,t-c));
    if(length(a)<.1||isnan(a.x))a=vec3(0.,0.,1.);

    vec3 j=normalize(vec3(.5,.8,-.6));
    float u=max(dot(a,j),.1),v=clamp(1.-(f*2.5),.05,1.);

    vec3 w=cos(log(max(h,.001))*1.+vec3(4.5,.5,8.))+2.126,x=l(dot(g,vec3(.15))+iTime*.05),k=mix(w,x,.4);

    float y=dot(k,vec3(.2126,.7152,.0722)),z=y/max(h,.001);

    vec3 d=k*(f+z*.3);
    d*=u*v;

    d+=pow(max(dot(reflect(-j,a),vec3(0.,0.,-1.)),0.),16.)*.4;

    acc += d;
    totalWeight += 1.;
}

vec3 d = acc / totalWeight;

q=vec4(tanh(d),1.);
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
#define C a.z
#define B a.x
#define A a.y
mat3 p(float e,vec3 a){
a=normalize(a);
float f=cos(e),d=sin(e),c=1.-f;
return mat3(
B*B*c+f,A*B*c+C*d,C*B*c-A*d,
B*A*c-C*d,A*A*c+f,C*A*c+B*d,
B*C*c+A*d,A*C*c-B*d,C*C*c+f
);
}

void mainImage(out vec4 q,vec2 r){
vec2 s=(r.xy*2.972-iResolution.xy)/iResolution.y;
vec3 t=normalize(vec3(s,1.)),a=gl_FragCoord.wwz;
if(dot(a,a)<.0001)a=vec3(.5773);

float h=iTime/4.,e=h-sin(h),u=exp(cos(h));
mat3 v=p(e,a);

float j=0.,k=0.,g=0.,i=1.;
vec3 b=vec3(0.);

float l=1e4,w=0.;

for(float m=0.;m++<150.;){
b=t*k*v-1.;
b.z-=u;

i=7.4;

for(float n=0.;n++<8.;){
float o=dot(b,b)*.76;
i/=o;
b=abs(b/o+1.)-1.;
l=min(l,dot(b,b));
}

g=b.y/i;
k-=g;
j+=exp(0.)/450.4;
w++;

if(abs(g)<.0001)break;
}

q=vec4(b,j);
}
