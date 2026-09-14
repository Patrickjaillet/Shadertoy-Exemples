
void mainImage(out vec4 n,in vec2 o){
    vec2 c=(o-.5*iResolution.xy)/iResolution.y;
    float j=dot(c,c),d=iTime*.35;
    vec2 e=vec2(0.);
    float k=.7,i=k,f=1.;
    mat2 l=mat2(cos(f),-sin(f),sin(f),cos(f));
    for(int g=0;g<13;g++){
        c=l*c;
        e=l*e;
        vec2 a=c*i+e+vec2(d*.7-float(g)*0.,d*.2+float(g)*.73);
        float m=sin(a.x*1.4+d)+cos(a.y*3.6-j*4.);
        vec2 p=vec2(cos(a.y+m-d),sin(a.x-m+d));
        e+=p*.63;
        float q=1./i;
        k+=(dot(cos(a),sin(a.yx))+.5)*q;
        i*=1.19;
    }
    vec4 r=vec4(0.),s=vec4(1.,0.,.55,0.),t=vec4(.98,.7,.15,1.),u=vec4(.1,.85,.65,1.);
    float h=k*.4;
    vec3 b=r.rgb*(sin(h*2.+0.)*.5+.5)+s.rgb*(cos(h*2.5+1.57)*.5+.5)+t.rgb*(sin(h*12.+0.)*1.+.9)+u.rgb*(cos(h*1.5+4.71)*.5+.5);
    b*=exp(-j*3.1);
    b=clamp(b,0.,1.);
    b=pow(b,vec3(1.));
    n=vec4(b,1.);
}
