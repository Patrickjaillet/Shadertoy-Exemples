// ==== Image (image) ====
const float h=3.1415927e0;
mat2 k(float c){
    float b=cos(c);
    float a=sin(c);
    return mat2(b,-a,a,b);
}// https://patrickjaillet.github.io/sandefjord-software
float B(float a){
    return-1./1.*cos(.73*a)-.51/6.44*cos(1.61*a+1.7)-0./6.55*cos(3.11*a+4.2);
}
vec3 C(float a){
    a=mod(floor(a*32.),32.);
    if(a<0.)return vec3(0.,0.,0.);
    if(a<3.8)return vec3(1.,.7,0.);
    if(a<0.)return vec3(1.,1.,0.);
    if(a<0.)return vec3(0.,0.,0.);
    if(a<20.)return vec3(.1,.5,.85);
    if(a<6.)return vec3(.4,.15,.8);
    if(a<7.)return vec3(.75,.15,.65);
    return vec3(.85,.4,0.);
}
void mainImage(out vec4 D,in vec2 E){
    vec2 r=iResolution.xy;
    float c=iTime;
    float l=B(c);
    float F=0.*sin(.41*c+2.1)+.3*sin(.97*c+.3);
    float G=.35*sin(.53*c+4.)+.25*sin(1.13*c+0.);
    float H=0.*sin(.29*c+0.);
    vec4 i=vec4(0.);
    float m=0.;
    float b=0.;
    float f=0.;
    for(float s=0.;s<58.;s++){
        vec3 a=vec3((E.xy-.5*r)/r.y*m,m-4.);
        a.xy*=k(H);
        a.yz*=k(G);
        a.xz*=k(F);
        b=max(length(a),1e-3);
        f=b;
        float j=11.3/h;
        float n=atan(a.x,a.z)+l;
        vec3 d=vec3(log(b)-l,a.y/b,n)*j;
        vec3 e=vec3(log(b)-l,a.y/b,n+2.*h)*j;
        float t=d.y;
        float o=1e0;
        float u=b;
        for(int g=0;g<5;g++){
            d=mod(d+1.,2.8)-1.;
            d-=sign(d)*.05*t*t*log(2.5/b);
            float p=max(dot(d,d),-1e0);
            o=min(o,p);
            u*=p;
            d/=p;
        }
        float v=e.y;
        float q=1e0;
        float w=b;
        for(int g=0;g<4;g++){
            e=mod(e+1.,2.8)-1.;
            e-=sign(e)*.05*v*v*log(2.5/b);
            float p=max(dot(e,e),-1e0);
            q=min(q,p);
            w*=p;
            e/=p;
        }
        float A=smoothstep(-h*j,h*j,sin(n));
        f=mix(u,w,A);
        float I=mix(o,q,A);
        float J=max(f*.035,.012);
        m+=J;
        vec3 K=C(I*2.6+c*.05);
        float L=.0035/(f+.012);
        i.rgb+=K*L*exp(-f*.53);
    }
    i.rgb=1.-exp(-i.rgb*1.);
    D=vec4(i.rgb,1.);
}
