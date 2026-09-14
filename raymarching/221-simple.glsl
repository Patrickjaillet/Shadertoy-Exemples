// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
mat2 l(float b){
    float a=sin(b);
    float c=cos(b);
    return mat2(c,-a,a,c);
}
void mainImage(out vec4 m,in vec2 n){
    vec2 o=1.-n.xy/iResolution.y;
    vec3 p=vec3(.5,0.,-1.);
    vec3 q=vec3(o,1.);
    vec3 d=p;
    vec3 e=vec3(0.);
    float f=0.;
    float c=.001;
    for(float g=0.;g<97.;g+=1.){
        vec3 h=q;
        if(c<0.){
            h=d*12.;
        }
        d+=h*c;
        vec3 a=d;
        a.yz*=l(iTime*.5);
        a.z=fract(a.z+iTime)-.5;
        float b=atan(a.x,a.y);
        float r=length(a.xy);
        a.xy=vec2(cos(b*6.),sin(b*6.))*r;
        a=.5-abs(a);
        float i=2.7;
        for(int j=0;j<7;j++){
            a=abs(a)-.65;
            float s=clamp(dot(a,a),0.,1.6);
            float k=7.2/s;
            i*=k;
            a=abs(a)*k-3.9;
            a.z+=3.8;
        }
        c=length(a.xz)/max(i,0.);
        float t=max(c,0.);
        float u=.01/exp(t*104.8);
        e+=vec3(u);
        f+=max(c,.001);
        if(f>22.3)break;
    }
    m=vec4(e,1.);
}
