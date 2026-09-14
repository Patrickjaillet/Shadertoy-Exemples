// ==== Image (image) ====
mat2 m=mat2(1.6,1.2,-1.2,1.6);
float q(vec2 c){
    float f=dot(c,vec2(127.1,311.7));
    return fract(sin(f)*4.3758547e4);
}
float n(in vec2 c){
    vec2 b=floor(c),e=fract(c),a=e*e*(3.-2.*e);
    return-1.+2.*mix(mix(q(b+vec2(0.)),q(b+vec2(1.,0.)),a.x),mix(q(b+vec2(0.,1.)),q(b+vec2(1.)),a.x),a.y);
}
float F(vec2 c){
    float e=0.;
    e+=.5*n(c);
    c*=2.02;
    e+=.25*n(c);
    c*=2.03;
    e+=.125*n(c);
    c*=2.01;
    e+=.0625*n(c);
    return max(0.,e*.5+.5);
}
float j(vec2 g,float a){
    g+=n(g);
    vec2 b=1.-abs(sin(g)),c=abs(cos(g));
    b=mix(b,c,b);
    return pow(1.-pow(b.x*b.y,.65),a);
}
vec3 G(vec3 a,vec3 k){
    float d=max(dot(a,k),0.);
    vec3 b=mix(vec3(.4,.6,.9),vec3(.1,.3,.6),max(a.y,0.));
    b=mix(b,vec3(.8,.7,.6),pow(1.-max(a.y,0.),4.));
    vec3 f=vec3(1.,.85,.6)*pow(d,256.)*8.,g=vec3(1.,.7,.4)*pow(d,16.)*1.5;
    b+=f+g;
    if(a.y>0.){
        vec2 h=(a.xz/a.y)*.15+vec2(iTime*.015,iTime*.005);
        float c=F(h*3.);
        c=smoothstep(.35,.75,c);
        vec3 e=mix(vec3(.9,.92,.95),vec3(.2,.25,.35),smoothstep(0.,1.,a.y));
        e+=vec3(1.,.8,.5)*pow(d,8.)*c;
        b=mix(b,e,c*smoothstep(0.,.15,a.y));
    }
    return b;
}
vec3 H(vec3 c,vec3 l,vec3 k,vec3 r){
    float a=clamp(1.-dot(l,-r),0.,1.);
    a=pow(a,3.)*.65;
    vec3 b=reflect(r,l),e=G(b,k),f=vec3(.01,.09,.18)+pow(max(0.,dot(l,k)),80.)*(vec3(.8,.9,.6)*.25)*.12,o=mix(f,e,a);
    o+=(vec3(.8,.9,.6)*.25)*(c.y-.6)*.18;
    float d=pow(max(0.,dot(b,k)),4e2)*9.;
    d+=pow(max(0.,dot(b,k)),30.)*.6;
    o+=vec3(1.,.9,.7)*d;
    return o;
}
vec3 v(vec2 z,vec2 A){
    vec2 g=(z-.5*iResolution.xy)/iResolution.y+A;
    vec3 k=normalize(vec3(.3,.8,.5));
    vec2 p=g*6.+vec2(0.,iTime*1.2);
    float d=.16,h=.6,a=3.,i=iTime*1.2,f=0.;
    vec2 c=p;
    for(int b=0;b<7;b++){
        float e=j((c+i)*d,a);
        e+=j((c-i)*d,a);
        f+=e*h;
        c*=m;
        d*=1.9;
        h*=.22;
        a=mix(a,1.,.2);
    }
    vec3 B=vec3(p.x,f,p.y);
    float s=.02;
    d=.16;
    h=.6;
    a=3.;
    c=p+vec2(s,0.);
    float t=0.;
    for(int b=0;b<7;b++){
        float e=j((c+i)*d,a);
        e+=j((c-i)*d,a);
        t+=e*h;
        c*=m;
        d*=1.9;
        h*=.22;
        a=mix(a,1.,.2);
    }
    d=.16;
    h=.6;
    a=3.;
    c=p+vec2(0.,s);
    float u=0.;
    for(int b=0;b<7;b++){
        float e=j((c+i)*d,a);
        e+=j((c-i)*d,a);
        u+=e*h;
        c*=m;
        d*=1.9;
        h*=.22;
        a=mix(a,1.,.2);
    }
    vec3 l=normalize(vec3(f-t,s,f-u)),r=vec3(0.,-1.,0.),o=H(B,l,k,r);
    return max(o,0.);
}
mat2 I(float a){
    float d=sin(a),b=cos(a);
    return mat2(b,-d,d,b);
}
vec3 w(in float c,in vec3 a,in vec3 d,in vec3 b,in vec3 e){
    return a+d*cos(6.28318*(b*c+e));
}
void mainImage(out vec4 J,in vec2 i){
    vec3 K=vec3(.5),L=K,M=vec3(1.),N=vec3(0.,.33,.67),O=vec3(.8,.5,.4),P=vec3(.2,.4,.2),Q=vec3(2.,1.,1.),R=vec3(0.,.25,.25),S=vec3(.8,.2,.05);
    vec2 f=iResolution.xy,l=(i.xy-.5*f)/f.y;
    float z=iTime;
    vec4 d=vec4(0.);
    float g=0.,p=g,r=1e5,A=p,s=A;
    for(float B=0.;B<80.;++B){
        vec3 a=vec3(l*g*1.2,g-6.);
        a.xz*=I(z*.2);
        float h=2.,e=h,k;
        for(int b=0;b<12;b++){
            k=dot(a,a)+.001;
            e/=k;
            a/=k;
            a.y=1.7-a.y;
            if(b>3){
                h=min(h,length(a.xz+length(a)/k*.55)/e-.006);
                a.xz=abs(a.xz)-.7;
            }
            else a=abs(a)-.86;
        }
        r=min(r,h);
        float T=max(h,.001);
        g+=T;
        float U=log(e)*.1+z*.05;
        vec3 V=w(U,K,L,M,N),W=w(length(a.xz)*.5,O,P,Q,R);
        float o=.008*exp(-h*1e2),C=exp(-g*.15);
        d.rgb+=o*V*C;
        d.rgb+=S*.004/exp(a.y/e*2.)*W*C;
        p+=o*12.;
        A+=g*o;
        s+=o;
        if(g>30.)break;
    }
    float D=s>1e-4?(A/s):15.;
    vec2 X=vec2(.08,-.12)*(D*.15+.5);
    vec3 Y=v(i,X),Z=v(i,vec2(0.));
    float _=clamp(1.-p*.6,.2,1.);
    vec3 t=mix(Y*.35,Z,_),aa=vec3(.02,.08,.15);
    t=mix(t,aa,smoothstep(2.,25.,D)*.45);
    float E=exp(-p);
    d.rgb=d.rgb+t*E;
    float u=.055/(r+.01);
    u=pow(u,1.3);
    vec3 ab=vec3(.32,.55,1.)*u*E;
    d.rgb+=ab;
    d.rgb=d.rgb/(1.+d.rgb);
    float c=1.-.3*length((i/f)-.5);
    d.rgb*=c;
    d.rgb=pow(d.rgb,vec3(1./2.2));
    J=vec4(d.rgb,1.);
}
