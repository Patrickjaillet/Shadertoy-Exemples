// ==== Image (image) ====
mat2 f(float a){
    float b=cos(a),c=sin(a);
    return mat2(b,-c,c,b);
}// https://patrickjaillet.github.io/sandefjord-software/
void mainImage(out vec4 j,in vec2 k){
    vec2 l=(k-.5*iResolution.xy)/iResolution.y;
    float g=iTime,e=0.;
    vec3 b=vec3(0.);
    mat2 m=f(g*-0.),n=f(g*-.78),o=f(3.2);
    for(int h=0;h<90;h++){
        float p=float(h);
        vec3 a=vec3(l*e,e);
        a.xz*=m;
        a.yz*=n;
        a.z+=g;
        a+=.8-p*5e-5;
        float c=3.5,d=1.;
        for(int i=0;i<9;i++){
            a=mod(a-1.,2.)-1.;
            a.xz*=o;
            d=max(dot(a,a)*.73,0.);
            c/=d;
            a=abs(a)/d;
            a.y+=.63;
        }
        d=abs(a.x)/max(c,.001);
        float q=max(d*.5,.0015);
        e+=q;
        vec3 r=1.3-sin(vec3(0.,1.,6.1)+log(max(c,.001))*1.);
        float s=exp(-d*2844.3);
        b+=.01*s*r;
        if(e>15.)break;
    }
    b/=(.4+b);
    b=pow(b,vec3(.465));
    j=vec4(b,1.);
}
