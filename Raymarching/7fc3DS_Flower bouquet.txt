// ==== Image (image) ====
// Golfing 401 Chars - sandefjord
void mainImage(out vec4 O,vec2 u){
    O-=O;
    vec3 R=iResolution,a;
    for(float e=0.,h=0.,b,c,i,d;h++<90.;
        e+=b,O.rgb+=.01-(.0121+.0099*clamp(abs(mod(vec3(5.9,3.7,2)-log(c)*.926,6.5)-5.7)-.9,0.,1.))/exp(b*420.))
    for(a=vec3((u+u-R.xy)/R.y*e*.225,e-2.1),a.xz*=mat2(cos(iTime*.1+vec4(0,33,11,0))),a.y+=.8,b=5.5,c=4.,i=0.;
        i++<9.;
        b=min(b,length(a.xz+a.y/d/8.5)/c))a.xz=abs(a.xz-.49),d=dot(a,a),c/=d,a/=d,a.y=1.75-a.y;}

/* Golfing 447 Chars by poyo - https://www.shadertoy.com/user/poyo
void mainImage(out vec4 l,vec2 m){
    vec2 f=iResolution.xy;
    float e=0.,h=0.,q;
    vec3 g,a;
    g*=0.;
    for(;h++<90.;){
        a=vec3((m-.5*f)/f.y*e*.45,e-2.1);
        a.xz*=mat2(cos(iTime*.1+vec4(0,33,11,0)));
        a.y+=.8;
        float b=5.5,p,c=4.,i=0.,d;
        for(;i++<9.;)
            a.xz=abs(a.xz-.49),
            d=dot(a,a),
            c/=d,
            a/=d,
            a.y=1.75-a.y,
            p=a.y/d/8.5,
            b=min(b,length(a.zx+p)/c);
        e+=b;
        q=.62-log(c)/21.6;
        g+=.01-(.022+.022*(.45*clamp(abs(mod(q*20.+vec3(0,4.3,2.6),6.5)-5.7)-.9,0.,1.)-.45))/exp(b*420.);
    }
    l.rgb=g;
}*/
