
void mainImage(out vec4 O,vec2 u){
    O-=O;
    vec3 R=iResolution,a;
    for(float e=0.,h=0.,b,c,i,d;h++<90.;
        e+=b,O.rgb+=.01-(.0121+.0099*clamp(abs(mod(vec3(5.9,3.7,2)-log(c)*.926,6.5)-5.7)-.9,0.,1.))/exp(b*420.))
    for(a=vec3((u+u-R.xy)/R.y*e*.225,e-2.1),a.xz*=mat2(cos(iTime*.1+vec4(0,33,11,0))),a.y+=.8,b=5.5,c=4.,i=0.;
        i++<9.;
        b=min(b,length(a.xz+a.y/d/8.5)/c))a.xz=abs(a.xz-.49),d=dot(a,a),c/=d,a/=d,a.y=1.75-a.y;}
