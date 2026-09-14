// ==== Image (image) ====
void mainImage(out vec4 j,vec2 n){
    vec2 k=iResolution.xy,d=1.1*(n*2.-k)/k.y,e=d;
    float f=0.,g=f,h=.98*sin(iTime*.5);
    for(float a=0.;a<168.;a++){
        float b=dot(e,e);
        if(b>16.){
            f=a,g=b;
            break;
        }
        float l=atan(e.y,e.x)*7.;
        vec2 c=vec2(pow(b,3.5)*vec2(cos(l),sin(l)))+vec2(7.04,1.);
        e=mix(c,vec2(c.y,-c.x),h);
    }
    if(f==0.){
        j=vec4(.3,.3,.3,1.);
        return;
    }
    float m=f+.2-log2(log(g)/1.5)/2.807355,i=pow(m/221.9,.35);
    vec3 o=vec3(1.,.75,0.),p=i<.25?mix(vec3(.05,0.,0.),vec3(.9,.15,0.),i*4.):o;
    p+=o*(1./(6.2*abs(sin(7.*atan(e.y,e.x)+m*1.2-iTime*2.5))))*(1.+.6*sin(iTime+m*.1)),p+=vec3(.26,.38,0.)*exp(-.79*m)*.8,j=vec4(clamp(mix(vec3(0.),p,smoothstep(.02,.15,i)),.3,1.),1.);
}
