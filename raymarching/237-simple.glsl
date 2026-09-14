// ==== Image (image) ====
mat2 k(float c){
    float a=cos(c),b=sin(c);
    return mat2(a,-b,b,a);
}

void mainImage(out vec4 l,in vec2 m){
    vec4 f=vec4(0.);
    float d=iTime;
    vec3 n=normalize(vec3((m-.5*iResolution.xy)/iResolution.y,1.)),g=vec3(0.,0.,-1.);
    float e=.01;
    for(int h=0;h<100;h++){
        g+=n*max(e,.001);
        vec3 a=g;
        a.zy*=k(d*3.14159/6.);
        a.xz*=k(d*3.14159/8.);
        a.z=fract(a.z+d*.35)-.5;
        float b=2.;
        a=.5-abs(a);
        for(int i=0;i<9;i++){
            a=abs(a)-.7;
            float o=min(dot(a,a),2.),j=6./max(o,.01);
            b*=j;
            a=abs(a)*j-4.;
            a.z+=3.;
        }
        e=length(a.xz)/max(b,1e-4);
        float c=length(a)*.05+d*.5;
        f+=.01/exp(e*1e3)*(1.+sin(vec4(1.,4.,6.,0.)+c));
    }
    l=tanh(f*1.5);
}
