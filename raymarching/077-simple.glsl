// ==== Image (image) ====
const float F=3.1415927e0;
mat2 c(float b){
    float d=cos(b),a=sin(b);
    return mat2(d,-a,a,d);
}// https://patrickjaillet.github.io/sandefjord-software
vec3 G(float b,float a,float d){
    vec3 e=clamp(abs(mod(b*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);
    return d*mix(vec3(1.),e,a);
}
float i(vec2 a){
    a=fract(a*vec2(123.34,456.21));
    a+=dot(a,a+45.32);
    return fract(a.x*a.y);
}
vec3 I(vec3 a){
    a=vec3(dot(a,vec3(127.1,311.7,74.7)),dot(a,vec3(269.5,183.3,246.1)),dot(a,vec3(113.5,271.9,124.6)));
    return fract(sin(a)*43758.5453);
}
vec3 s(vec2 b,float f,float g){
    vec2 a=floor(b),h=fract(b)-.5;
    float d=i(a),j=step(f,d);
    vec2 k=(vec2(i(a+3.1),i(a+7.7))-.5)*.4;
    float e=length(h-k),l=smoothstep(.05,0.,e),n=smoothstep(.3,0.,e)*.25,o=.55+.45*sin(g*2.+d*90.);
    vec3 m=mix(vec3(.75,.85,1.),vec3(1.,.85,.65),i(a+1.7));
    return j*(l+n)*o*m;
}
void mainImage(out vec4 J,in vec2 t){
    vec2 j=iResolution.xy;
    float b=iTime,u=(0.*b-.5/.19*cos(.19*b)-.4/.37*cos(.37*b+1.7)-.3/.61*cos(.61*b+4.2)-.2/.89*cos(.89*b+.6)),v=.35*sin(.13*b+2.1)+.22*sin(.31*b+.3)+.14*sin(.57*b+3.4),w=.3*sin(.17*b+4.)+.2*sin(.37*b+1.1)+.12*sin(.63*b+5.2),x=.28*sin(.11*b+1.2)+.16*sin(.27*b+3.7),K=b*.7;
    vec4 f=vec4(0.);
    float g=0.,n=g;
    for(float A=0.;A<120.;A++){
        vec3 a=vec3((t.xy-.5*j)/j.y*g,g-5.);
        a.xy*=c(x);
        a.yz*=c(w);
        a.xz*=c(v);
        vec3 o=a*1.3;
        o.z+=K;
        vec3 L=floor(o),k=I(L);
        float e=length(fract(o)-.5-(k-.5)*.4),l=smoothstep(.06,0.,e),M=smoothstep(.3,0.,e)*.35,N=step(.955,k.x)*(l+M),O=.7+.3*sin(b*4.+k.y*30.);
        vec3 P=mix(vec3(1.,.45,.15),vec3(.75,.85,1.),k.z);
        f.rgb+=N*O*P*.8/exp(g*.16);
        float B=max(length(a),1e-3);
        a=vec3(log(B)-u,a.y/B,atan(a.x,a.z));
        float C=0.,p=.6,D=C;
        for(float q=1.;q<40.;q*=2.){
            vec3 h=cos(a*q+u*.3);
            C+=p*sin(F*(h.x+h.y+h.z));
            D+=p*(h.x-h.z);
            p*=.28;
        }
        n=abs(C)*.4+.008;
        g+=n*.7+.01;
        vec3 m=G(1.+D,.36,1.);
        f+=vec4(m,0.)*.04/exp(n*24.+g*.14);
    }
    vec3 d=normalize(vec3((t.xy-.5*j)/j.y,1.));
    d.xy*=c(x);
    d.yz*=c(w);
    d.xz*=c(v);
    vec2 E=vec2(atan(d.x,d.z),asin(clamp(d.y,-1.,1.)));
    vec3 r=vec3(0.);
    r+=s(E*40.,.97,b)*.6;
    r+=s(E*72.+21.,.965,b)*.4;
    float Q=dot(f.rgb,vec3(.333)),R=exp(-Q*2.6);
    f.rgb+=r*R*1.2;
    J=vec4(f.rgb,1.);
}
