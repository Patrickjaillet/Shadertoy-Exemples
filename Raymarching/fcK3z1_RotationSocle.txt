// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// https://x.com/JailletPatrick
mat2 s(float a){
    float b=cos(a),c=sin(a);
    return mat2(b,-c,c,b);
}
void mainImage(out vec4 t,in vec2 u){
    vec2 j=iResolution.xy,k=(u-.5*j)/j.y;
    float g=iTime,l=1.,m=g*.4;
    vec3 n=vec3(sin(m)*l,1.2,-cos(m)*l),v=vec3(0.,-.8,0.),h=normalize(v-n),o=normalize(cross(vec3(0.,1.,0.),h)),w=cross(h,o),A=normalize(k.x*o+k.y*w+.8*h),b=vec3(0.);
    float d=0.;
    for(int p=0;p<108;p++){
        vec3 e=n+A*d;
        float q=length(e)+.016,B=atan(e.x,e.z),C=acos(clamp(e.y/q,-1.,0.));
        vec3 a=vec3(log(q)-g*0.,sin(B*8.)*.5,cos(C*2.)*.5)*2.;
        a=sin(a*1.5707963);
        float f=2.,r=0.;
        for(int i=0;i<8;i++){
            a=abs(a)/clamp(f,.25,1.1)-vec3(.3,.35,.6);
            a.yz*=s(.523598+float(i)*.08);
            f=dot(a,a)+0.;
            r+=exp(-f);
        }
        float c=length(a.xz)/max(f,.001)*.24;
        c=max(c,.001);
        float D=.0012/(c*c+.0015);
        vec3 E=.5+.5*cos(vec3(0.,.78,.95)+r*.63+g*0.);
        b+=E*D*exp(-d*.1);
        d+=c*.2;
        if(d>8.)break;
    }
    b=pow(b,vec3(.77));
    b=mix(b,smoothstep(0.,1.,b),.35);
    t=vec4(b,1.);
}
