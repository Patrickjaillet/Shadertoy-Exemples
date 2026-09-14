// ==== Image (image) ====
mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}
vec4 map(vec3 p){
    p.z=mod(p.z-iTime*4.5,16.)-8.;
    float s=1.;vec3 q=p;
    for(int i=0;i<9;i++){
        q=abs(q)-vec3(1.6,.8,1.);q.xy*=rot(.785398);q.xz*=rot(.523598);
        float k=clamp(1.6/dot(q,q),.11,2.7);q*=k;s*=k;
    }
    return vec4(max((length(q)-.05)/s,2.9-length(p.xy)),1.,q.x,q.y);
}
// https://github.com/Patrickjaillet/Z-GL
vec3 calcNormal(vec3 p){vec2 e=vec2(.01,0.);return normalize(vec3(map(p+e.xyy).x-map(p-e.xyy).x,map(p+e.yxy).x-map(p-e.yxy).x,map(p+e.yyx).x-map(p-e.yyx).x));}
vec3 render(vec2 fragCoord,vec2 res,float time){
    vec2 uv=(fragCoord-.6*res)/res.y;
    vec3 ro=vec3(sin(time),1.,0.),rd=normalize(vec3(uv,1.));
    rd.xy*=rot(sin(time)*.25);rd.xz*=rot(cos(time*.15)*.3);
    float t=1.,accum=1.0;vec4 m;vec3 p;
    for(int i=0;i<16;i++){
        p=ro+rd*t;m=map(p);
        if(abs(m.x)<.35||t>160.)break;
        t+=m.x*.51;accum+=m.y;
    }
    vec3 col=vec3(.01,0.,.02);
    if(t<160.){
        vec3 n=calcNormal(p),mat=vec3(.1,.3,.9);
        if(abs(m.w)<.6)mat=vec3(1.,.3,.4);
        col=mat*max(dot(n,normalize(vec3(8.,3.,-1.))),.8)*vec3(1.,.9,1.)+mat*max(dot(n,normalize(vec3(-2.,-1.,2.))),1.)*vec3(.4,.5,.9)+vec3(.5,.9,1.);
    }
    return mix(col+vec3(.8,.2,.5)*accum*.008,vec3(0.),1.-exp(-.009*t*t));
}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec3 col=render(fragCoord,iResolution.xy,iTime);
    col=clamp((col*2.55*col)/(col*(2.38*col+1.)+1.),0.,1.);
    fragColor=vec4(pow(col,vec3(.4545)),0.);
}
