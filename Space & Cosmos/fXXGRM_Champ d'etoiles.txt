// ==== Image (image) ====
float k(vec2 d){
    vec3 a=fract(vec3(d.xyx)*.1031);
    a+=dot(a,a.yzx+33.33);
    return fract((a.x+a.y)*a.z);
}// https://github.com/Patrickjaillet/Z-GL-Shadertoy
vec2 u(vec2 d){
    vec3 a=fract(vec3(d.xyx)*vec3(.1031,.103,.0973));
    a+=dot(a,a.yzx+33.33);
    return fract((a.xx+a.yz)*a.zy);
}
mat2 p(float a){
    float b=sin(a),c=cos(a);
    return mat2(c,-b,b,c);
}
vec3 v(vec2 g,float h,float w,float l){
    vec2 q=fract(g*h)-.5,m=floor(g*h);
    vec3 r=vec3(0.);
    for(int b=-1;b<=1;b++)for(int a=-1;a<=1;a++){
        vec2 i=vec2(float(a),float(b)),e=u(m+i+l);
        float s=w*(.3+e.x*.7)+e.y*6.28,j=(.04+.12*k(m+i+l+121.3))*(sin(s)*.5+.5);
        vec2 d=i+e-.5;
        float f=length(q-d);
        vec3 n=mix(vec3(.5,.7,1.),vec3(1.,.5,.3),k(m+i+l+45.1));
        n=mix(n,vec3(1.,.9,.7),e.x*e.y);
        float x=(j*.015)/(f+5e-4),y=(j*.003)/(f*f+8e-5);
        vec2 o=(q-d)*p(s*.5);
        float t=pow(max(0.,1.-abs(o.x*o.y*1e3)),12.)*(j*.1/(f+.01));
        t+=pow(max(0.,1.-abs(o.x)),50.)*(j*.05/(f+.01));
        r+=(x+y+t)*n;
    }
    return r;
}
void mainImage(out vec4 j,in vec2 f){
    vec2 g=(f-.5*iResolution.xy)/iResolution.y;
    float d=iTime*.15;
    vec2 l=vec2(sin(d*.5),cos(d*.3))*2.;
    float m=sin(d*.2)*.4;
    vec3 a=vec3(0.);
    float n=k(f+iTime);
    for(float e=0.;e<1.;e+=1./8.){
        float b=fract(e-d*.5),h=mix(15.,.05,b),o=smoothstep(0.,.4,b)*smoothstep(1.,.8,b);
        vec2 i=g;
        i*=p(m*b);
        i+=l*b;
        a+=v(i,h,iTime,e*951.4)*o;
    }
    a=pow(a,vec3(.8));
    a*=1.2;
    vec2 q=f/iResolution.xy;
    float r=length(q-.5);
    a*=smoothstep(1.2,.3,r);
    a+=(n-.5)*.012;
    vec3 s=a*a;
    a+=s*.3;
    a=mix(a,vec3(dot(a,vec3(.299,.587,.114))),-.1);
    j=vec4(clamp(a,0.,1.),1.);
}
