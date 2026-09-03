// ==== Image (image) ====
const float p=3.1415927e0;
mat2 g(float c){
    float a=cos(c);
    float b=sin(c);
    return mat2(a,-b,b,a);
}
void mainImage(out vec4 q,in vec2 r){
    vec2 h=iResolution.xy;
    float i=iTime;
    vec4 j=vec4(.1);
    float b=1.;
    float d=0.;
    float e=0.;
    for(float k=0.;k<80.;k++){
        vec3 a=vec3((r.xy*1.8-h)/h.y*b,b-3.);
        mat2 l=g(i*.3);
        a.xz*=l;
        a.yz*=l;
        float m=length(a)+1e-5;
        float c=abs(atan(a.x,a.z));
        a=vec3(log(m)-i*.2,a.y/m,c)*1.591549;
        d=1.;
        for(int n=0;n<4;n++){
            a=abs(mod(a-1.,1.9)-.95)-.19;
            a.xy*=g(p/5.5);
            float o=dot(a,a)*1.+0.;
            d/=o;
            a/=o;
        }
        e=.35/(d+1e-4);
        b+=e;
        float s=.03/exp(e*1.5e3+b*.8);
        vec3 t=vec3(0.,0.,.9);
        vec3 u=vec3(.5,.1,.8);
        vec3 v=vec3(.9,.2,.4);
        vec3 w=vec3(1.,.7,.2);
        float f=clamp((b-1.)/10.,0.,1.);
        vec3 A=mix(mix(t,u,smoothstep(1.,.21,f)),mix(v,w,smoothstep(0.,0.,f)),step(.08,f));
        j+=vec4(s*A,0.);
    }
    q=clamp(j,0.,1.);
}
