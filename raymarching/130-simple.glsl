
void mainImage(out vec4 a,vec2 b){
    vec3 c=iResolution,p;
    for(float e,g,d;e++<99.;a+=vec4(1,.5,1,1)*exp(-d*6.)){
        a=e<2.?vec4(0):a,p=vec3((b+b-c.xy)/c.y*g,g-3.),p.xz*=mat2(cos(iTime*.4+vec4(0,11,33,0))),p.yz*=mat2(cos(iTime*.2+vec4(0,11,33,0)));
        g+=max(abs(d=length(cos(p)+sin(p.zxy))-.6)*.2,.02);
    }
    a=tanh(a*.03);
}
