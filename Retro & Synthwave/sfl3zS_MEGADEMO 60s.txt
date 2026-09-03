// ==== Image (image) ====
// ==========================================================
// NAME : MEGADEMO 60S LOOPED
// Credits : Patrick JAILLET
// https://openshader.xo.je

float getKick() {
    float v = 0.0;
    for (int i = 0; i < 4; i++)
        v += texture(iChannel0, vec2(float(i)/512.0, 0.75)).r;
    return clamp(v * 0.6, 0.0, 1.0);
}

float getHihat() {
    float v = 0.0;
    for (int i = 80; i < 110; i++)
        v += texture(iChannel0, vec2(float(i)/512.0, 0.75)).r;
    return clamp(v * 0.3, 0.0, 1.0);
}

#define T_JULIA_END    10.0
#define T_PLASMA_END   22.0
#define T_BLOB_END     34.0
#define T_ORGANIC_END  46.0
#define T_FLESH_END    60.0
#define T_MORPH        2.0

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float hash(float n)  { return fract(sin(n) * 43758.5453); }

float noise3d(vec3 x) {
    vec3 p = floor(x), f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y * 57.0 + p.z * 113.0;
    return mix(
        mix(mix(hash(n),     hash(n+1.0),  f.x),
            mix(hash(n+57.0),hash(n+58.0), f.x), f.y),
        mix(mix(hash(n+113.0),hash(n+114.0),f.x),
            mix(hash(n+170.0),hash(n+171.0),f.x), f.y), f.z);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
    return mix(b,a,h) - k*h*(1.0-h);
}

vec3 sceneJulia(vec2 fragCoord, float kick, float hihat, float tMod) {
    vec2 uv  = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    uv *= 1.5;
    float t  = tMod * 0.3;
    vec2 c   = vec2(0.7885*cos(t), 0.7885*sin(t)) + vec2(sin(t*0.7)*0.1, cos(t*0.5)*0.1);
    c += kick * vec2(0.08*sin(tMod*7.0), 0.06*cos(tMod*5.0));
    vec2 z = uv, dz = vec2(1.0, 0.0);
    float r2=0.0, iter=0.0, maxIter=200.0;
    for(float i=0.0; i<250.0; i++) {
        if(i>maxIter || r2>4.0) break;
        dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y+z.y*dz.x);
        z  = vec2(z.x*z.x-z.y*z.y, 2.0*z.x*z.y) + c;
        r2 = dot(z,z);
        iter++;
    }
    float d = clamp(0.5*sqrt(r2)*log(r2)/length(dz), 0.0, 1.0);
    vec3 totalLight = vec3(0.0);
    for(float i=0.0; i<40.0; i++) {
        float tt  = tMod*(0.2+i*0.01);
        float seed = i*12.345;
        vec2 orbPos = vec2(sin(tt*0.8+seed)*1.6 + cos(tt*1.2+seed*0.5)*0.4, cos(tt*0.9-seed)*1.0 + sin(tt*1.5+seed)*0.4);
        vec3 orbCol = 0.5 + 0.5*cos(6.28318*(vec3(1.0)*(seed*0.1+tMod*0.2)+vec3(0.263,0.416,0.557)));
        float dist  = length(uv0 - orbPos);
        float li    = (0.008 + hihat*0.05) / (0.001 + dist*dist);
        totalLight += orbCol * li;
    }
    vec3 col = (iter < maxIter) ? totalLight / (1.0 + d*80.0) : vec3(0.0);
    return pow(col, vec3(0.4545));
}

vec3 getPlasma(vec2 uv, float time) {
    float d = length(uv);
    vec3 col = vec3(0.5)+vec3(0.5)*cos(6.28318*(vec3(1.0)*d+vec3(0.263,0.416,0.557)));
    col += vec3(0.5)+vec3(0.5)*cos(6.28318*(vec3(1.0)*(abs(sin(uv.x*2.0+time)) + abs(cos(uv.y*2.0+time*0.5)))+vec3(0.263,0.416,0.557)));
    return pow(col, vec3(2.0));
}

float mapPlasma(vec3 p, float kick, float tMod) {
    vec3 po = p;
    po.xy *= rot(tMod*0.6);
    po.xz *= rot(tMod*0.8);
    float morph = smoothstep(-0.8,0.8,sin(tMod+kick));
    float dObj  = mix(length(max(abs(po)-vec3(0.7+kick*0.3),0.0)), length(po)-(0.9+kick*0.2), morph);
    return min(dObj, 5.0-p.z);
}

vec3 scenePlasma(vec2 fragCoord, float kick, float hihat, float tMod) {
    vec2 uv=(fragCoord*2.0-iResolution.xy)/iResolution.y;
    vec3 ro=vec3(0,0,-4), rd=normalize(vec3(uv,1.5));
    float t=0.0;
    for(int i=0;i<100;i++){
        float d=mapPlasma(ro+rd*t,kick, tMod);
        if(abs(d)<0.001 || t>20.0)break;
        t+=d;
    }
    vec3 col=vec3(0.0);
    if(t<20.0){
        vec3 p=ro+rd*t, e=vec3(0.001,0,0);
        vec3 n=normalize(vec3(mapPlasma(p+e.xyy,kick, tMod)-mapPlasma(p-e.xyy,kick, tMod), mapPlasma(p+e.yxy,kick, tMod)-mapPlasma(p-e.yxy,kick, tMod), mapPlasma(p+e.yyx,kick, tMod)-mapPlasma(p-e.yyx,kick, tMod)));
        vec3 l=normalize(vec3(2.0*sin(tMod),2,-3)-p);
        float fresnel=pow(1.0+dot(rd,n),2.0);
        if(p.z > 2.0) col=getPlasma(p.xy*0.3,tMod)*max(dot(n,l),0.0);
        else col=getPlasma(reflect(rd,n).xy+reflect(rd,n).z,tMod)*0.8 + fresnel*(0.5+hihat*2.0);
    }
    return pow(col/(col+vec3(1.0)), vec3(0.4545));
}

float mapBlob(vec3 p, float kick, float hihat, float tMod) {
    vec3 q=p;
    q.xz*=rot(tMod*0.1); q.yz*=rot(tMod*0.05);
    vec3 id=floor(q/4.0); q=mod(q,4.0)-2.0;
    float phase=sin(id.x*12.+id.y*3.+id.z*7.+tMod);
    q.xy*=rot(phase*0.5);
    float d1=length(vec2(length(q.xz)-(1.0+kick*0.3),q.y))-(0.3+hihat*0.2);
    vec3 q2=q; q2.xz*=rot(tMod*1.5+phase);
    float d2=length(q2-vec3(1,0,0))-(0.4+kick*0.2);
    float d=smin(d1,d2,0.4);
    d+=0.03*sin(p.x*3.0)*sin(p.y*2.5+tMod)*sin(p.z*3.0);
    return d*0.7;
}

vec3 sceneBlob(vec2 fragCoord, float kick, float hihat, float tMod) {
    vec2 p2=(-iResolution.xy+2.0*fragCoord)/iResolution.y;
    vec3 ro=vec3(4.0*cos(tMod*0.2),2.0+sin(tMod*0.14),4.0*sin(tMod*0.2));
    vec3 cw=normalize(-ro), cp2=vec3(0,1,0), cu=normalize(cross(cw,cp2)), cv=cross(cu,cw);
    vec3 rd=normalize(p2.x*cu+p2.y*cv+2.5*cw);
    float t=0.1;
    for(int i=0;i<128;i++){float h=mapBlob(ro+rd*t,kick,hihat, tMod);if(h<0.001*t||t>30.0)break;t+=h;}
    vec3 col=mix(vec3(1.0,0.95,0.9),vec3(0.9,0.95,1.0),rd.y*0.5+0.5);
    if(t<30.0){
        vec3 pos=ro+t*rd, e=vec3(0.001,0,0);
        vec3 nor=normalize(vec3(mapBlob(pos+e.xyy,kick,hihat, tMod)-mapBlob(pos-e.xyy,kick,hihat, tMod), mapBlob(pos+e.yxy,kick,hihat, tMod)-mapBlob(pos-e.yxy,kick,hihat, tMod), mapBlob(pos+e.yyx,kick,hihat, tMod)-mapBlob(pos-e.yyx,kick,hihat, tMod)));
        col=mix(vec3(1.0,0.8,0.9+kick*0.1), vec3(0.7,0.9,1.0), nor.y*0.5+0.5) + pow(max(dot(reflect(rd,nor),vec3(0,1,0)),0.0),8.0)*(0.4+hihat*2.0);
    }
    return pow(col, vec3(0.4545));
}

float mapOrganic(vec3 p, float kick, float tMod) {
    p.xy*=rot(p.z*0.05+tMod*0.1);
    float d=2.8-length(p.xy);
    d-=(sin(p.z*2.0+p.y*1.5)*0.3+sin(p.x*3.5+p.z*2.5)*0.15+(sin(p.x*7.0)*sin(p.y*8.0)*sin(p.z*6.0))*0.08)*(1.0+kick*0.5);
    return d*0.6;
}

vec3 sceneOrganic(vec2 fragCoord, float kick, float hihat, float tMod) {
    vec2 R=iResolution.xy, uv2=(fragCoord-0.5*R)/R.y;
    vec3 ro=vec3(0,0,tMod*4.0), rd=normalize(vec3(uv2,1.0));
    rd.yz*=rot(cos(tMod*0.25)*1.2); rd.xz*=rot(sin(tMod*0.4)*3.14159);
    float t=0.0;
    for(int i=0;i<120;i++){float d=mapOrganic(ro+rd*t,kick, tMod);if(d<0.001||t>60.0)break;t+=d;}
    vec3 p=ro+rd*t, e=vec3(0.01,0,0);
    vec3 n=normalize(vec3(mapOrganic(p+e.xyy,kick, tMod)-mapOrganic(p-e.xyy,kick, tMod), mapOrganic(p+e.yxy,kick, tMod)-mapOrganic(p-e.yxy,kick, tMod), mapOrganic(p+e.yyx,kick, tMod)-mapOrganic(p-e.yyx,kick, tMod)));
    float ooze=smoothstep(0.3,0.8,sin(p.y*6.0-tMod*3.5))*(1.0+hihat*2.0);
    vec3 c=mix(vec3(0.4,0.15,0.1),vec3(0.2,0.02,0.01),ooze*0.8)*max(dot(n,normalize(ro-p)),0.1);
    c+=vec3(1,0.8,0.7)*pow(max(dot(reflect(normalize(p-ro),n),-rd),0.0),64.0)*ooze*(2.5+kick*2.0);
    return pow(mix(c,vec3(0.08,0.02,0.03),1.0-exp(-t*0.06)),vec3(0.4545));
}

float mapFlesh(vec3 p, float kick, float tMod){
    vec3 q=p; q.xy-=vec2(-sin(q.z*0.2)*0.8,-cos(q.z*0.25)*0.8);
    float lumps=sin(p.z*1.5+tMod*(1.0+kick))*cos(p.x*2.0)*sin(p.y*2.5);
    return (2.5-noise3d((p+vec3(0,tMod*0.2,0))*0.8)*1.5+lumps*0.3-length(q.xy))*0.4;
}

vec3 sceneFlesh(vec2 fragCoord, float kick, float hihat, float tMod){
    vec2 p2=(-iResolution.xy+2.0*fragCoord)/iResolution.y;
    vec3 ro=vec3(-sin(tMod*0.16)*0.8,-cos(tMod*0.2)*0.8,tMod*0.8);
    vec3 ta=vec3(-sin((tMod*0.8+1.0)*0.2)*0.8,-cos((tMod*0.8+1.0)*0.25)*0.8,tMod*0.8+1.0);
    vec3 cw=normalize(ta-ro),cp3=vec3(0,1,0),cu=normalize(cross(cw,cp3)),cv=cross(cu,cw);
    vec3 rd=normalize(p2.x*cu+p2.y*cv+1.8*cw);
    float t=0.01;
    for(int i=0;i<120;i++){float h=mapFlesh(ro+rd*t,kick, tMod);if(h<0.002||t>25.0)break;t+=h;}
    vec3 p=ro+rd*t, e=vec3(0.005,0,0);
    vec3 n=normalize(vec3(mapFlesh(p+e.xyy,kick, tMod)-mapFlesh(p-e.xyy,kick, tMod), mapFlesh(p+e.yxy,kick, tMod)-mapFlesh(p-e.yxy,kick, tMod), mapFlesh(p+e.yyx,kick, tMod)-mapFlesh(p-e.yyx,kick, tMod)));
    float wetSpec=pow(max(dot(n,normalize(ro-p-rd)),0.0),32.0)*(1.0+hihat*4.0);
    vec3 col=mix(vec3(0.4,0.1,0.05),vec3(0.05,0,0.01),t*0.08)+vec3(1,0.8,0.7)*wetSpec*0.5;
    return pow(col,vec3(0.4545));
}

vec3 applyMorph(vec3 colA, vec3 colB, float alpha, vec2 uv, float tMod) {
    float n = noise3d(vec3(uv * 3.5, tMod * 0.2));
    float mask = smoothstep(0.0, 1.0, alpha * 1.2 - 0.1 + (n - 0.5) * 0.4);
    return mix(colA, colB, mask);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float tMod = mod(iTime, 60.0);
    float kick = getKick();
    float hihat = getHihat();
    vec2 uv = fragCoord / iResolution.xy;
    
    vec3 cJ = (tMod < T_JULIA_END + T_MORPH) ? sceneJulia(fragCoord, kick, hihat, tMod) : vec3(0.0);
    vec3 cP = (tMod > T_JULIA_END - T_MORPH && tMod < T_PLASMA_END + T_MORPH) ? scenePlasma(fragCoord, kick, hihat, tMod) : vec3(0.0);
    vec3 cB = (tMod > T_PLASMA_END - T_MORPH && tMod < T_BLOB_END + T_MORPH) ? sceneBlob(fragCoord, kick, hihat, tMod) : vec3(0.0);
    vec3 cO = (tMod > T_BLOB_END - T_MORPH && tMod < T_ORGANIC_END + T_MORPH) ? sceneOrganic(fragCoord, kick, hihat, tMod) : vec3(0.0);
    vec3 cF = (tMod > T_ORGANIC_END - T_MORPH) ? sceneFlesh(fragCoord, kick, hihat, tMod) : vec3(0.0);
    
    vec3 col = vec3(0.0);
    if (tMod < T_JULIA_END + T_MORPH) col = (tMod > T_JULIA_END - T_MORPH) ? applyMorph(cJ, cP, smoothstep(T_JULIA_END-T_MORPH, T_JULIA_END+T_MORPH, tMod), uv, tMod) : cJ;
    else if (tMod < T_PLASMA_END + T_MORPH) col = (tMod > T_PLASMA_END - T_MORPH) ? applyMorph(cP, cB, smoothstep(T_PLASMA_END-T_MORPH, T_PLASMA_END+T_MORPH, tMod), uv, tMod) : cP;
    else if (tMod < T_BLOB_END + T_MORPH) col = (tMod > T_BLOB_END - T_MORPH) ? applyMorph(cB, cO, smoothstep(T_BLOB_END-T_MORPH, T_BLOB_END+T_MORPH, tMod), uv, tMod) : cB;
    else if (tMod < T_ORGANIC_END + T_MORPH) col = (tMod > T_ORGANIC_END - T_MORPH) ? applyMorph(cO, cF, smoothstep(T_ORGANIC_END-T_MORPH, T_ORGANIC_END+T_MORPH, tMod), uv, tMod) : cO;
    else col = cF;
    
    col += vec3(kick * 0.04 + hihat * 0.02);
    fragColor = vec4(clamp(col * (1.0 - dot(uv-0.5, uv-0.5) * 0.6), 0.0, 1.0), 1.0);
}
