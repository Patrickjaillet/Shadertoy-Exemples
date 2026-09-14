// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// https://x.com/JailletPatrick
float i(float g){
    return fract(sin(g)*4.3758547e4);
}
float v(float b){
    float g=floor(b),a=fract(b);
    a=a*a*(3.-2.*a);
    return mix(i(g),i(g+1.),a);
}
float k(vec2 c,float a){
    return length(c)-a;
}
float w(vec2 c,vec2 a){
    vec2 f=abs(c)-a;
    return length(max(f,0.))+min(max(f.x,f.y),0.);
}
float E(vec2 c,float a){
    const float b=sqrt(3.);
    c.x=abs(c.x)-a;
    c.y=c.y+a/b;
    if(c.x+b*c.y>0.)c=vec2(c.x-b*c.y,-b*c.x-c.y)/2.;
    c.x-=clamp(c.x,-2.*a,0.);
    return-length(c)*sign(c.y);
}
vec4 o(float f,vec3 p,vec3 q,float a,float r,float b){
    float c=1.-smoothstep(0.,a,f),e=(1.-smoothstep(0.,a,f))*smoothstep(-a*2.5,-a*.5,f);
    vec3 d=mix(p,q,r);
    d=mix(d,vec3(.02),e*b);
    return vec4(d,c);
}
vec3 F(float b){
    vec3 c=vec3(.2,.45,.85),d=vec3(.85,.65,.55);
    float a=.5+.5*sin(iTime*.08);
    c=mix(vec3(.12,.15,.45),c,a);
    d=mix(vec3(.95,.5,.3),d,a);
    return mix(d,c,smoothstep(.15,.85,b));
}
vec4 G(vec2 b,float e,vec2 h){
    vec2 a=vec2(b.x*e-h.x,b.y-h.y);
    float f=length(a)-.11,c=exp(-length(a)*12.)*.6+exp(-length(a)*3.)*.25,r=smoothstep(-.08,.08,a.x*.7+a.y*.7);
    vec3 p=vec3(1.,.95,.5),q=vec3(1.,.55,.15);
    vec4 d=o(f,p,q,.006,r,.7);
    d.rgb+=c*vec3(1.,.75,.35);
    d.a=max(d.a,clamp(c,0.,1.));
    return d;
}
float s(vec2 c,float d,float j){
    float f=1e5,q=.05+d*.03,t=.9+d*.3;
    vec2 e=c+vec2(j*q,0.);
    float x=floor(e.x*t);
    for(int m=-2;m<=2;m++){
        float g=x+float(m),l=i(g*17.13+d*31.4);
        if(l<.2)continue;
        float r=(g+.5)/t,n=.015*sin(j*.8+g*2.5),A=.68+.08*i(g*3.1)-d*.06+n;
        vec2 h=vec2(r,A);
        float a=.09+.03*i(g*5.7)+n*.5,p=a*.75,B=a*.8,b=k(e-h,a);
        b=min(b,k(e-(h+vec2(a*.85,-.01)),p));
        b=min(b,k(e-(h-vec2(a*.75,-.01)),B));
        b=min(b,k(e-(h+vec2(a*.3,a*.45)),a*.6));
        b=min(b,k(e-(h-vec2(a*.3,-a*.35)),p*.65));
        f=min(f,b);
    }
    return f;
}
vec4 H(vec2 b,float e,float a,float d,vec2 h){
    vec2 c=vec2(b.x*e,b.y);
    float f=s(c,d,a);
    if(f>.02)return vec4(0.);
    vec2 n=vec2(.002,0.),g=normalize(vec2(s(c+n.xy,d,a)-s(c-n.xy,d,a),s(c+n.yx,d,a)-s(c-n.yx,d,a))),j=normalize(h-c);
    float l=clamp(dot(g,-j)*.5+.5,0.,1.),m=smoothstep(.3,.85,l);
    vec3 p=mix(vec3(1.,.99,.96),vec3(.88,.91,.96),d*.4),q=mix(vec3(.55,.58,.72),vec3(.38,.42,.58),d*.35);
    return o(f,p,q,.005,m,.75);
}
vec4 I(vec2 b,float e,float a){
    vec4 d=vec4(0.);
    for(int g=0;g<5;g++){
        float j=float(g),q=floor((a+j*17.1)/14.),t=mod(a+j*17.1,14.),x=.2+.12*i(q+j*3.1),A=.52+.28*i(q+j*7.9),B=e+.4-t*x,C=A+.03*sin(a*2.+j*1.5);
        vec2 c=vec2(b.x*e,b.y),f=c-vec2(B,C);
        float D=sin(a*14.+j*2.3),h=D*.55;
        vec2 m=f-vec2(-.012,0.);
        m=vec2(m.x*cos(h)-m.y*sin(h),m.x*sin(h)+m.y*cos(h));
        float J=w(m-vec2(-.012,.004),vec2(.012,.0025))-.001;
        vec2 n=f-vec2(.012,0.);
        n=vec2(n.x*cos(-h)-n.y*sin(-h),n.x*sin(-h)+n.y*cos(-h));
        float K=w(n-vec2(.012,.004),vec2(.012,.0025))-.001,l=k(f,.006),L=k(f-vec2(-.008,.002),.004),M=min(min(l,L),min(J,K));
        vec3 r=vec3(.12,.1,.18);
        vec4 p=o(M,r,r*.4,.002,0.,.8);
        d.rgb=mix(d.rgb,p.rgb,p.a);
        d.a=max(d.a,p.a);
    }
    return d;
}
float y(float b,float a){
    float l=0.,c=.5,d=1.2;
    for(int g=0;g<4;g++){
        l+=v(b*d+float(g)*1.3+a*.02)*c;
        d*=2.2;
        c*=.5;
    }
    return l;
}
vec4 N(vec2 b,float e,float a,float j){
    float h=b.x*e+j*.1,l=y(h,a),t=.25+l*.35,f=b.y-t,n=.005,r=step(0.,y(h-n,a)-y(h+n,a));
    vec3 p=vec3(.42,.38,.62),q=vec3(.2,.16,.38);
    vec4 d=o(f,p,q,.005,r,.7);
    float c=t+.12;
    if(b.y>c){
        float g=b.y-c;
        d.rgb=mix(d.rgb,vec3(.95,.95,1.),smoothstep(0.,.02,g));
    }
    d.a*=smoothstep(.15,.3,b.y);
    return d;
}
float u(float b,float a){
    return .1+.35*(.5*v(b*2.5+a*.05)+.25*v(b*5.7-a*.03)+.15*v(b*11.3+a*.08));
}
vec4 O(vec2 b,float e,float a,float j){
    float h=b.x*e+j*.35,l=u(h,a),t=.05+l,J=b.y-t,n=.01,K=step(0.,u(h-n,a)-u(h+n,a));
    vec3 L=vec3(.28,.75,.18),M=vec3(.11,.48,.07);
    vec4 d=o(J,L,M,.004,K,.8);
    d.a*=smoothstep(0.,.08,b.y);
    float B=.45,P=floor(h/B);
    for(int m=-1;m<=1;m++){
        float g=P+float(m);
        if(i(g*17.34)<.3)continue;
        float C=(g+.2+.6*i(g*23.1))*B,Q=.05+u(C,a);
        vec2 c=vec2(h,b.y),f=c-vec2(C,Q);
        float q=w(f-vec2(0.,.08),vec2(.015,.08))-.003,r=k(f-vec2(0.,.18),.1),x=(i(g*31.7)>.5)?k(f-vec2(.03,.2),.025):1e5,R=min(min(q,r),x);
        vec3 S=vec3(.55,.32,.12),T=vec3(.3,.15,.05),U=vec3(.2,.7,.15),V=vec3(.05,.4,.05),D=vec3(1.,.3,.2);
        float W=step(0.,f.x);
        vec3 p,shadowTree;
        if(q<r&&q<x){
            p=S;
            shadowTree=T;
        }
        else if(r<x){
            p=U;
            shadowTree=V;
        }
        else{
            p=D;
            shadowTree=D*.6;
        }
        vec4 A=o(R,p,shadowTree,.003,W,.7);
        d.rgb=mix(d.rgb,A.rgb,A.a);
        d.a=max(d.a,A.a);
    }
    return d;
}
vec4 X(vec2 b,float e,float a,float j){
    float t=3.2,h=b.x*e+j*.35,p=(floor(h/t)+.5)*t,C=.05+u(p,a);
    vec2 c=vec2(h,b.y),f=c-vec2(p,C);
    float l=E((f-vec2(0.,.22))*vec2(1.8,-1.),.18);
    l=max(l,-(f.y-.02));
    float n=k(f-vec2(0.,.21),.065);
    n=max(n,-(f.y-.21));
    float D=a*1.5+p,m=1e5;
    vec2 x=vec2(0.,.21);
    for(int g=0;g<4;g++){
        float d=D+float(g)*1.5707963;
        vec2 q=vec2(cos(d),sin(d)),A=f-x;
        float J=abs(dot(A,vec2(-q.y,q.x)))-.012,K=abs(dot(A,q)-.09)-.09;
        m=min(m,max(J,K));
    }
    float L=k(f-x,.018);
    m=min(m,L);
    float M=min(min(l,n),m);
    vec3 P=vec3(.8,.6,.3),Q=vec3(.5,.2,.2),R=vec3(.9,.85,.7),B=(l<n&&l<m)?P:((n<m)?Q:R);
    float r=step(0.,f.x);
    return o(M,B,B*.6,.003,r*.3,.8);
}
vec4 Y(vec2 b,float e,float a,float j){
    vec4 d=vec4(0.);
    float h=b.x*e+j*.8,t=30.,x=floor(h*t),C=.015*sin(b.y*10.+a*4.)*(1.-b.y*2.);
    for(int m=-1;m<=1;m++){
        float g=x+float(m),D=(g+.5+.4*(i(g*11.1)-.5))/t,l=.06+i(g*13.7)*.1;
        vec2 c=vec2(h,b.y),f=c-vec2(D,0.);
        f.x+=C*max(0.,f.y)*2.5;
        float J=w(f-vec2(0.,l*.5),vec2(.004,l*.5))-.001,r=step(0.,f.x);
        vec3 p=vec3(.2,.75,.1),q=vec3(.08,.4,.05);
        vec4 n=o(J,p,q,.002,r,.5);
        if(i(g*17.3)>.65){
            float K=l+.015,L=k(f-vec2(0.,K),.012);
            vec3 B=(i(g*19.1)>.5)?vec3(1.,.4,.4):vec3(.9,.9,.2);
            vec4 A=o(L,B,B*.5,.001,0.,.3);
            n.rgb=mix(n.rgb,A.rgb,A.a);
            n.a=max(n.a,A.a);
        }
        d.rgb=mix(d.rgb,n.rgb,n.a);
        d.a=max(d.a,n.a);
    }
    d.a*=smoothstep(0.,.03,b.y)*(1.-smoothstep(.18,.25,b.y));
    return d;
}
vec3 Z(vec2 b,vec3 d){
    float a=1.-length(b-.5)*.65;
    return d*max(0.,a);
}
void mainImage(out vec4 r,in vec2 t){
    vec2 b=t/iResolution.xy;
    float e=iResolution.x/iResolution.y,a=iTime,j=a*.25;
    if(iMouse.z>0.)j=(iMouse.x/iResolution.x)*8.;
    vec3 x=F(b.y);
    vec4 c=vec4(x,1.);
    vec2 h=vec2(e*.5,.75+.03*sin(a*.4));
    vec4 d=G(b,e,h);
    c.rgb=mix(c.rgb,d.rgb,d.a);
    for(int g=0;g<2;g++){
        vec4 f=H(b,e,a,float(g),h);
        c.rgb=mix(c.rgb,f.rgb,f.a);
    }
    vec4 l=I(b,e,a);
    c.rgb=mix(c.rgb,l.rgb,l.a);
    vec4 m=N(b,e,a,j);
    c.rgb=mix(c.rgb,m.rgb,m.a);
    vec4 n=O(b,e,a,j);
    c.rgb=mix(c.rgb,n.rgb,n.a);
    vec4 p=X(b,e,a,j);
    c.rgb=mix(c.rgb,p.rgb,p.a);
    vec4 q=Y(b,e,a,j);
    c.rgb=mix(c.rgb,q.rgb,q.a);
    c.rgb=Z(b,c.rgb);
    r=c;
}
