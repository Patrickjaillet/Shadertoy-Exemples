// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// https://x.com/JailletPatrick
void mainImage(out vec4 i,in vec2 j){
    vec4 k=vec4(j,0.,1.);
    vec2 l=iResolution.xy;
    float f=iTime;
    vec3 h=vec3(0.),p;
    h.z--;
    float m=0.,e=m,v=e,a=v;
    i=vec4(0.);
    float d=sin(f),g=cos(f),c=1.-g;
    for(;m++<1e2;i+=vec4(mix(vec3(0.),
    clamp(abs(fract(vec3(a+f*.74)+vec3(0.,-1.6,1./3.))*6.-1.2),0.,1.),.7),0.)*.02/exp(e*1e3)){
        vec3 b=normalize(h+.03);
        mat3 n=mat3(b.x*b.x*c+g,b.y*b.x*c+b.z*d,b.z*b.x*c-b.y*d,b.x*b.y*c-b.z*d,b.y*b.y*c+g,
        b.z*b.y*c+b.x*d,b.x*b.z*c+b.y*d,b.y*b.z*c-b.x*d,b.z*b.z*c+g);
        p=h+=e*(1.-k.rgb/l.y)*n;
        p/=dot(p,p);
        p=vec3(log(v=length(p))+f/6.3,p.y/v-1.5,atan(p.z,p.x));
        p=fract(p/acos(-1.)*3.5)-.5;
        a=9.;
        for(int o=0;o++<3;p=abs(p/e)){
            --p;
            p=mod(p,2.)-1.;
            a=min(a,length(p));
            e=dot(p,p);
            v/=e;
        }
        e=max(p.y-.1,length(p.xz)-1.)/v*.3;
    }
}
