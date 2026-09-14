// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// ****************************************************
/* GOLFED CODE
void mainImage(out vec4 O,vec2 F){
    vec3 d=normalize(vec3((F-.5*iResolution.xy)/iResolution.y,1)),p,q=vec3(0,.5,-1.8);
    float t=iTime*.15,c=cos(t),s=sin(t),g=0.,e,v,i=0.,u;
    for(O-=O;i++<110.;){
        p=q+d*g;
        p.xz*=mat2(c,-s,s,c);
        e=5.;v=5.6;
        for(int j=0;j<11;j++)
            p.xz=abs(p.xz)-.68,
            u=dot(p,p),v/=u,p/=u,
            p.y=1.65-p.y,
            e=min(e,max(length(p.xz)-.015/u,p.y)/v);
        g+=e;
        O.rgb+=.018*mix(vec3(.8),clamp(abs(fract(.65-log(v)*.08-i*.003+vec3(.8,2.86,.33))*2.2+.7)-.8,0.,.9),.75)/exp(e*168.6);
    }
    O.rgb=pow(smoothstep(0.,1.,O.rgb),vec3(.45));
}
*/
mat2 r(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

vec3 h(float h,float s,float v){
    vec4 k=vec4(0.8,2.857,0.333,-0.7);
    return v*mix(k.xxx,clamp(abs(fract(h+k.xyz)*2.2-k.www)-k.xxx,0.,0.9),s);
}

void mainImage(out vec4 O,vec2 F){
    vec2 R=iResolution.xy;
    vec3 d=normalize(vec3((F-.5*R)/R.y,1)),p,q=vec3(0,.5,-1.8);
    float t=iTime*.15,g=0.,e,v;
    O-=O;
    for(float i=0.;i<110.;i++){
        p=q+d*g;
        p.xz*=r(t);
        e=5.;v=5.6;
        for(int j=0;j<11;j++){
            p.xz=abs(p.xz)-.68;
            float u=dot(p,p);
            v/=u;p/=u;
            p.y=1.65-p.y;
            e=min(e,max(length(p.xz)-.015/u,p.y)/v);
        }
        g+=e;
        O.rgb+=h(.65-log(v)*.08-i*.003,.75,.018)/exp(e*168.6);
    }
    O.rgb=pow(smoothstep(0.,1.,O.rgb),vec3(.45));
    O.a=1.;
}
