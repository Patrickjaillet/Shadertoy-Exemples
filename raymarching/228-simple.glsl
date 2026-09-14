// ==== Image (image) ====
const float PHI = 1.618033988749895;
const float TAU = 6.283185307179586;

mat2 e(float a){
    float b=cos(a),s=sin(a);
    return mat2(b,-s,s,b);
}

float n(vec3 a,vec3 b){
    vec3 c=abs(a)-b;
    return length(max(c,0.))+min(max(c.x,max(c.y,c.z)),0.);
}

vec2 o(vec2 a,vec2 b){
    return(a.x<b.x)?a:b;
}

float smin(float a, float b, float k){
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec2 g(vec3 a){
    vec2 f=vec2(1e5,0.);
    vec3 d=a;
    d.xz*=e(iTime*.15);
    d.yz*=e(iTime*.08);
    vec3 c=d;
    float j=1.,h=1e5,l=sin(iTime*.2)*TAU;
    for(int b=0;b<9;b++){
        c=abs(c)-vec3(0.,.18,.38)*pow(PHI,-float(b)*.1);
        c.xy*=e(PHI*2.39996);
        c.xz*=e(PHI*6.472+l);
        c*=1.38;
        j*=1.38;
        float m=n(c,vec3(.27,.4,.08))/j;
        h=min(h,m);
    }
    
    vec3 i=d;
    
    // Trajectoire en douceur sans rupture aux extremites
    float orbitProgress = iTime * 0.8;
    float orbitRadius = smoothstep(-0.2, 0.2, sin(iTime * 0.4)) * 1.1;
    
    vec3 cubeOffset = vec3(
        cos(orbitProgress) * orbitRadius,
        sin(orbitProgress * 2.0) * 0.25 * orbitRadius,
        sin(orbitProgress) * orbitRadius
    );
    
    i -= cubeOffset;
    
    i.xy*=e(iTime*.5);
    i.yz*=e(iTime*.3);
    
    // SDFs d'origines nettoyées de micro-imperfections
    float dBox = n(i, vec3(.06*PHI))-.02;
    float dSphere = length(i) - .085;
    float dTorus = length(vec2(length(i.xz) - .065, i.y)) - .022;
    
    // Morphing continu sans coutures visuelles via smin
    float mFactor = 0.5 + 0.5 * sin(iTime * 1.5);
    float morph1 = smin(dBox, dSphere, 0.04);
    float p = smin(morph1, dTorus, 0.04 * mFactor);
    p = mix(dBox, p, mFactor);
    
    f=o(f,vec2(h,1.));
    f=o(f,vec2(p,3.));
    return f;
}

vec3 t(vec3 a){
    vec2 b=vec2(1e-3,0.);
    return normalize(vec3(
        g(a+b.xyy).x-g(a-b.xyy).x,
        g(a+b.yxy).x-g(a-b.yxy).x,
        g(a+b.yyx).x-g(a-b.yyx).x
    ));
}

float u(vec3 a,vec3 f){
    float c=0.,d=1.;
    for(int b=0;b<5;b++){
        float h=.001+.15*float(b)/4.,i=g(a+h*f).x;
        c+=(h-i)*d;
        d*=.85;
    }
    return clamp(1.-3.1*c,0.,1.);
}

float v(vec3 j,vec3 d,float a,float c,float l){
    float f=1.,i=a;
    for(int b=0;b<74;b++){
        float h=g(j+d*i).x;
        f=min(f,l*h/i);
        i+=max(h*.5,.002);
        if(f<.001||i>c)break;
    }
    return clamp(f,0.,1.);
}

vec3 k(vec3 d){
    float a=dot(d,vec3(0.,1.,0.))*0.+0.;
    vec3 c=mix(vec3(.01,.015,.03),vec3(.08,.04,.01),a);
    float b=pow(max(dot(d,normalize(vec3(1.,.1,-1.5))),0.),32.);
    return c+vec3(1.,.8,.5)*b*2.;
}

void mainImage(out vec4 w,in vec2 A){
    vec2 B=(A-.5*iResolution.xy)/iResolution.y;
    vec3 j=vec3(0.,0.,-2.8),d=normalize(vec3(B,1.2));
    if(iMouse.z>0.){
        vec2 a=(iMouse.xy-.5*iResolution.xy)/iResolution.y*3.14159;
        j.yz*=e(-a.y);
        j.xz*=e(-a.x);
        d.yz*=e(-a.y);
        d.xz*=e(-a.x);
    }
    vec2 f=vec2(0.);
    float i=.01,C=10.;
    for(int b=0;b<300;b++){
        vec3 a=j+d*i;
        vec2 h=g(a);
        if(abs(h.x)<1e-4){
            f=vec2(i,h.y);
            break;
        }
        if(i>C)break;
        i+=h.x*.25;
    }
    vec3 c=vec3(.002,.003,.005);
    if(f.x>0.){
        vec3 a=j+d*f.x,b=t(a),l=-d,D=reflect(-l,b);
        float E=u(a,b);
        vec3 m=normalize(vec3(2.5,3.5,-2.)),F=normalize(vec3(-2.5,-1.5,1.));
        float p=v(a+b*.001,m,.01,4.,16.);
        vec3 q=vec3(1.,.78,.34),h=vec3(.39,.55,.15);
        if(f.y==3.){
            q=vec3(1.,.3,.1);
            h=vec3(.9,.1,.05);
        }
        float G=max(dot(b,m),0.),H=max(dot(b,F),0.);
        vec3 I=normalize(m+l);
        float J=max(dot(b,I),0.),K=pow(J,29.8),L=pow(1.-max(dot(b,l),0.),8.3);
        vec3 r=mix(q,vec3(1.),L),M=k(b)*h*.2,N=h*G*p*vec3(1.,1.,0.),O=h*H*0.*vec3(.5,.4,1.),P=r*K*6.*p,Q=k(D)*r*.8;
        c=(M+N+O+P+Q)*E;
        float R=exp(-f.x*0.);
        c=mix(vec3(.002,.003,.005),c,R);
    }
    else c=k(d)*.25;
    c/=(vec3(.6)+c);
    c=pow(c,vec3(.4545));
    w=vec4(c,1.);
}
