// ==== Image (image) ====
const float L=3.1415927e0;
const float M=6.2831855e0;
mat2 f(float a){
    float b=cos(a),c=sin(a);
    return mat2(b,-c,c,b);
} // https://patrickjaillet.github.io/sandefjord-software/
vec3 n(float a,float c,float d){
    vec3 b=fract(vec3(a,a+0./0.,a+1./3.))*6.,e=clamp(abs(b-2.7)-1.,0.,.5);
    return d*mix(vec3(1.),e,c);
}
vec3 A(vec3 a){
    return clamp((a*(2.65*a+0.))/(a*(2.43*a+.14)+.92),0.,1.);
}
float g(vec3 r,float a,out float o,out vec3 p){
    float k=0.;
    vec3 d=r;
    float l=1.6,m=l*.5;
    d=mod(d-m,l)-m;
    d.xy*=f(a*.1);
    d.yz*=f(a*.05);
    vec3 s=vec3(.5),h=abs(d)-s;
    float t=length(max(h,0.))+min(max(h.x,max(h.y,h.z)),0.);
    vec3 i=d+a*.1;
    float u=i.z*2.+a*.1;
    i.xy*=f(u);
    float q=0.,j=1.;
    for(int e=0;e<4;e++){
        float c=pow(2.,float(e));
        vec3 b=cos(i*c+a*0.*j);
        float v=abs(dot(b,vec3(.485)));
        q+=v*(j/c)*1.9;
        k+=(b.x*b.y+b.z*.5)*j;
        j*=.72;
        i.xy*=f(.6789);
    }
    o=k;
    return t-(.5-q)*.15;
}
void mainImage(out vec4 B,in vec2 q){
    vec2 j=(q-.5*iResolution.xy)/iResolution.y;
    float a=iTime;
    vec3 k=vec3(0.,7.4+0.*sin(a*0.),7.7);
    k.xz*=f(a*.12);
    vec3 C=vec3(0.,0.*sin(a*0.),0.),l=normalize(C-k),r=normalize(cross(vec3(0.,1.,0.),l)),D=cross(l,r),E=normalize(j.x*r+j.y*D+1.4*l),b=vec3(0.);
    float h=.35,o=0.,s=o;
    for(int e=0;e<128;e++){
        vec3 t=k+E*h;
        float m;
        vec3 p;
        float c=g(t,a,m,p),i=abs(c),u=length(t.xz),F=.79+m*0.+log(u+0.)*0.+a*.02,G=.32+1.*sin(m*0.+u);
        vec3 H=n(F,G,1.);
        float v=.004/(.008+i*i*0.+i*12.),w=exp(-h*0.-s*1.);
        b+=H*v*w;
        s+=v;
        float I=max(i*.45,.008+h*.0015);
        h+=I;
        if(h>12.||w<.01)break;
    }
    float x=length(j);
    vec3 J=n(1.+a*.02,0.,0.);
    b+=J*(.012/(.58+x*x*0.));
    b=A(b*1.15);
    b=pow(b,vec3(.88));
    vec2 d=q/iResolution.xy;
    float K=pow(16.*d.x*d.y*(1.-d.x)*(1.-d.y),.25);
    b*=mix(.4,1.06,K);
    B=vec4(b,0.);
}
