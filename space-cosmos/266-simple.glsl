
#define PI 3.14159265359
#define N normalize

mat2 rot(float a){
    float s=sin(a), c=cos(a);
    return mat2(c,-s,s,c);
}

float bass(){
    return texture(iChannel0, vec2(0.02,0)).x;
}
float mid(){
    return texture(iChannel0, vec2(0.15,0)).x;
}
float high(){
    return texture(iChannel0, vec2(0.6,0)).x;
}

vec3 industrialPalette(float t){
    vec3 steel = vec3(.4,.4,.45);
    vec3 blood = vec3(.8,.05,.02);
    vec3 ash   = vec3(.08,.08,.08);

    return mix(ash, mix(steel, blood, t), t);
}

float pattern(vec3 p, float k){

    p.xy *= rot(p.z*.5 + iTime*.6 + k);

    float r = length(p.xy);
    float a = atan(p.y,p.x);

    float rings  = sin(r*18. - iTime*5.);
    float cuts   = sin(a*12. + iTime*2.);

    return abs(rings*cuts)*.6 + r - (1.1 + k*.3);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){

    vec2 uv = (fragCoord - .5*iResolution.xy)/iResolution.y;

    float B = bass();
    float M = mid();
    float H = high();

    vec3 ro = vec3(0,0,-3.5 - B*2.);
    vec3 rd = N(vec3(uv,1));

    float t=0.;
    vec3 col=vec3(0);
    float acc=0.;

    for(int i=0;i<100;i++){
        vec3 p = ro + rd*t;

        float d = pattern(p, B*2.);

        float hit = exp(-abs(d)*7.);

        vec3 c = industrialPalette(B + length(p)*.15);

        col += c * hit * (.05 + B*.1);
        acc += hit;

        t += clamp(d*.45, .015, .2);
    }

    float strobe = smoothstep(.6,.9,sin(iTime*8. + B*12.));
    col *= 1. + strobe*.6;

    col += vec3(.9,.1,.05) * B * .8;

    col *= acc*1.4;
    col = pow(col, vec3(.55));

    col *= smoothstep(1.2,.3,length(uv));

    fragColor = vec4(col,1);
}
