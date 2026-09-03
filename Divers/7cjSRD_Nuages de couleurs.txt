// ==== Image (image) ====
float N(vec3 p){
    vec3 i=floor(p),f=fract(p);
    f=f*f*(3.-2.*f);
    float n=dot(i,vec3(1,57,113));
    vec4 h=fract(sin(vec4(n,n+1.,n+57.,n+58.))*43758.5),
         j=fract(sin(vec4(n+113.,n+114.,n+170.,n+171.))*43758.5);
    return mix(mix(mix(h.x,h.y,f.x),mix(h.z,h.w,f.x),f.y),
               mix(mix(j.x,j.y,f.x),mix(j.z,j.w,f.x),f.y),f.z);
}

float F(vec3 p,float t){
    float v=0.,a=.5;
    mat3 m=mat3(0,.8,.6,-.8,.36,-.48,-.6,-.48,.64);
    for(int i=0;i<5;i++)v+=a*N(p+t),p=m*p*2.02,a*=.5;
    return v;
}

void mainImage(out vec4 o,vec2 u){
    vec2 r=iResolution.xy,v=(u+u-r)/r.y;
    float t=iTime*.4,i=0.,d,e;
    vec3 c=vec3(0),p,rd=normalize(vec3(v,1));
    for(;i<1.;i+=.02){
        d=i*6.;
        p=rd*d;
        p.z+=t;
        e=smoothstep(.4,.6,F(p,t));
        c+=e*(.5+.5*cos(t+d+vec3(0,2,4)))*exp(-d*.5)*.15;
    }
    o=vec4(tanh(c+c),1);
}
