// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software

void mainImage(out vec4 n,in vec2 o){
    vec2 g=iResolution.xy,p=o;
    float d=iTime,q=1.+sin(d*.35)*.8;
    vec3 r=vec3(.25*sin(d*.4),q,-3.2);
    vec2 s=(.5*g-p.xy)/g.y;
    float h=0.;
    vec3 i=vec3(0.);
    for(float j=0.;j<82.;++j){
        vec3 a=vec3(s*1.6,h-.9)+r;
        float k=d*.22,l=sin(k),m=cos(k);
        mat2 t=mat2(m,-l,l,m);
        a.xz*=t;
        float b=3.5,e=b,c;
        for(int f=0;f<12;f++){
            if(f>3){
                float u=length(a)/c*.6;
                b=min(b,length(a.xz+u)/e-.0065);
                a.xz=abs(a.xz)-.68;
            }
            else a=abs(a)-.9;
            c=dot(a,a);
            e/=c;
            a/=c;
            a.y=1.75-a.y;
        }
        h+=b;
        vec3 v=vec3(4.,2.5,1.5);
        i+=v*.008/exp(a.y/e+b*60.);
    }
    n=vec4(i,1.);
}
