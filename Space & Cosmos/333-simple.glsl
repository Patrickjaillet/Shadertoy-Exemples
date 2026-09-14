// ==== Image (image) ====
// Credits : Patrick JAILLET

#define MAX_STEPS 80
#define MAX_DIST  60.0
#define SURF_DIST 0.001
#define PI 3.14159265

float hash(float n){return fract(sin(n)*43758.5453);}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5);}
float noise3(vec3 p){vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.-2.*f);float n=i.x+i.y*57.+i.z*113.;return mix(mix(mix(hash(n),hash(n+1.),f.x),mix(hash(n+57.),hash(n+58.),f.x),f.y),mix(mix(hash(n+113.),hash(n+114.),f.x),mix(hash(n+170.),hash(n+171.),f.x),f.y),f.z);}

// ─── Opérateurs de fusion douce ─────────────────────────────
float smin(float a,float b,float k){float h=max(k-abs(a-b),0.)/k;return min(a,b)-h*h*k*.25;}
float smax(float a,float b,float k){return -smin(-a,-b,k);}

// ─── Mandelbulb SDF (ordre 6) ────────────────────────────────
vec2 mandelbulbDE(vec3 pos, float t){
    vec3 z=pos; float dr=1., r=0.;
    float power=6.+sin(t*.07)*2.;
    for(int i=0;i<10;i++){
        r=length(z);
        if(r>2.) break;
        float theta=acos(z.z/r)*power;
        float phi=atan(z.y,z.x)*power;
        float zr=pow(r,power);
        dr=pow(r,power-1.)*power*dr+1.;
        z=zr*vec3(sin(theta)*cos(phi),sin(phi)*sin(theta),cos(theta));
        z+=pos;
    }
    return vec2(.5*log(r)*r/dr, r);
}

// ─── IFS (Iterated Function System) sphères ─────────────────
float ifsDE(vec3 p, float t){
    float scale=2.+sin(t*.11)*.4;
    float d=MAX_DIST;
    vec3 pp=p;
    for(int i=0;i<8;i++){
        // fold
        pp=abs(pp)-vec3(.8+sin(t*.07+float(i)*.4)*.15);
        float r2=dot(pp,pp);
        pp=pp*(scale/min(r2,1.))-vec3(1.,1.,1.)*(scale-1.);
    }
    return length(pp)*pow(scale,-8.);
}

// ─── Sphère miroir ───────────────────────────────────────────
float sdSphere(vec3 p,float r){return length(p)-r;}

// ─── Tunnel de données ───────────────────────────────────────
float dataTunnel(vec3 p, float t){
    vec3 pp=p;
    // Répétition angulaire
    float angle=atan(pp.y,pp.x);
    float segments=12.;
    angle=mod(angle+PI/segments,2.*PI/segments)-PI/segments;
    float r=length(pp.xy);
    pp=vec3(cos(angle)*r,sin(angle)*r,pp.z);
    // SDF tube avec bandes
    float tube=abs(length(pp.xy)-2.)-.08;
    float bands=abs(fract(pp.z*.5+t*.3)-.5)-.4;
    return max(tube,-bands+.05);
}

vec2 map(vec3 p, float t){
    // Phase d'évolution (0-20s: mandelbulb, 20-40s: IFS, 40-60s: tunnel)
    float phase1=smoothstep(0.,5.,t)*smoothstep(25.,20.,t);
    float phase2=smoothstep(18.,23.,t)*smoothstep(45.,40.,t);
    float phase3=smoothstep(38.,43.,t);

    float d=MAX_DIST; float mat=0.;

    if(phase1>0.01){
        vec2 mb=mandelbulbDE(p*.5,t);
        float d1=mb.x;
        if(d1*phase1<d){d=mix(d,d1,phase1);mat=1.+mb.y*.5;}
    }
    if(phase2>0.01){
        float d2=ifsDE(p*.4,t);
        d=smin(d,mix(MAX_DIST,d2,phase2),.3);
        if(d2<MAX_DIST*.5) mat=2.;
    }
    if(phase3>0.01){
        float d3=dataTunnel(p,t);
        d=smin(d,mix(MAX_DIST,d3,phase3),.2);
        // Sphères miroir flottantes
        for(int k=0;k<5;k++){
            float fk=float(k);
            vec3 sp=p-vec3(sin(fk*2.+t*.3)*3.,cos(fk*1.7+t*.25)*2.,sin(fk*1.3+t*.2)*3.);
            float sd=sdSphere(sp,.4+sin(fk+t*.5)*.1);
            d=smin(d,mix(MAX_DIST,sd,phase3),.2);
            if(sd<d+.3) mat=3.+fk*.2;
        }
    }
    return vec2(d,mat);
}

vec3 getNormal(vec3 p,float t){
    vec2 e=vec2(.0008,0.);
    return normalize(vec3(map(p+e.xyy,t).x-map(p-e.xyy,t).x,
                          map(p+e.yxy,t).x-map(p-e.yxy,t).x,
                          map(p+e.yyx,t).x-map(p-e.yyx,t).x));
}

// ─── Palette onirique ────────────────────────────────────────
vec3 dreamPalette(float id, float t){
    float phase=t*.15;
    vec3 p1=.5+.5*cos(id*2.+phase+vec3(0.,2.1,4.2));
    vec3 p2=.5+.5*cos(id*3.7+phase*1.3+vec3(1.,3.3,5.5));
    return mix(p1,p2,sin(id+t*.1)*.5+.5);
}

// ─── Glow volumétrique ───────────────────────────────────────
vec3 volumeGlow(vec3 ro,vec3 rd,float t){
    vec3 col=vec3(0.);
    for(int i=0;i<24;i++){
        float s=float(i)/24.;
        vec3 p=ro+rd*s*20.;
        vec2 res=map(p,t);
        float dens=max(0.,-.5-res.x);
        col+=dreamPalette(res.y,t)*dens*.08;
    }
    return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
    float t=iTime;

    // ─── Caméra orbitale ────────────────────────────────────
    float phase1=smoothstep(0.,5.,t)*smoothstep(25.,20.,t);
    float phase2=smoothstep(18.,23.,t)*smoothstep(45.,40.,t);
    float phase3=smoothstep(38.,43.,t);

    float orbitR=mix(mix(6.,5.,phase2),3.,phase3);
    float orbitH=mix(mix(1.,0.,phase2),0.,phase3)*sin(t*.2);
    float orbitSpeed=mix(mix(.2,.15,phase2),.3,phase3);
    float angle=t*orbitSpeed;

    vec3 ro=vec3(cos(angle)*orbitR,orbitH,sin(angle)*orbitR);
    vec3 ta=vec3(0.);
    ta+=vec3(sin(t*.11),cos(t*.09),0.)*.3*phase3;

    vec3 fw=normalize(ta-ro);
    vec3 ri=normalize(cross(fw,vec3(0,1,0)));
    vec3 up=cross(ri,fw);
    float roll=sin(t*.17)*.08;
    ri=ri*cos(roll)+up*sin(roll);up=cross(ri,fw);
    float fov=mix(.9,.7,phase3);
    vec3 rd=normalize(uv.x*ri+uv.y*up+fov*fw);

    float depth=0.01;vec2 res=vec2(MAX_DIST);
    for(int i=0;i<MAX_STEPS;i++){
        vec3 p=ro+rd*depth;res=map(p,t);
        if(res.x<SURF_DIST)break;
        if(depth>MAX_DIST)break;
        depth+=res.x*.65;
    }

    vec3 col=vec3(0.);

    if(depth<MAX_DIST){
        vec3 p=ro+rd*depth;
        vec3 nor=getNormal(p,t);
        float mid=res.y;

        vec3 dc=dreamPalette(mid,t);
        vec3 light=vec3(.5,.6,.8)*max(0.,dot(nor,normalize(vec3(1.,1.,.5))))*0.5;
        vec3 ambient=dreamPalette(mid+1.,t)*.15;

        // Fresnel
        float fresnel=pow(1.-max(0.,dot(-rd,nor)),3.);

        if(mid>3.){
            // Sphères miroir — réflexion multiple approx
            vec3 reflDir=reflect(rd,nor);
            float rf=0.;
            for(int k=0;k<3;k++){
                vec3 rp=p+reflDir*float(k+1)*.8;
                rf+=noise3(rp*.5+t*.1)*.3;
            }
            col=mix(dc,dc*2.,fresnel)+vec3(rf);
            col*=1.5;
        } else {
            col=dc*(light+ambient);
            col+=dc*fresnel*.8;
        }
        // Emission interne
        col+=dc*max(0.,-.1*(depth-1.))*0.5;

        // Fog/haze onirique
        float fog=1.-exp(-depth*.08);
        vec3 fogCol=dreamPalette(0.,t)*.08;
        col=mix(col,fogCol,fog);
    } else {
        // Fond: gradient onirique
        col=dreamPalette(length(uv)*.5,t)*.05;
    }

    // Glow volumétrique
    col+=volumeGlow(ro,rd,t);

    // Particules
    float parts=0.;
    for(int k=0;k<20;k++){
        float fk=float(k);
        vec3 pp=ro+rd*(fk*2.+1.);
        parts+=pow(max(0.,noise3(pp*.8+t*.2)-.7),3.)*.15;
    }
    col+=dreamPalette(parts*3.,t)*parts;

    // Bloom
    float lum=dot(col,vec3(.299,.587,.114));
    col+=col*smoothstep(.6,1.5,lum)*1.5;

    // Aberration chromatique (renforcée)
    float ab=.006+sin(t*.3)*.003;
    col.r*=(1.+ab);col.b*=(1.-ab);

    // Vignette + letterbox
    col*=1.-smoothstep(.45,1.3,length(uv*vec2(1.1,1.)));
    float lb = smoothstep(0.0, 0.003, 0.35 - abs(fragCoord.y / iResolution.y - 0.5));col*=lb;

    col=col/(col+.5);
    col=pow(max(col,0.),vec3(.42,.45,.48));
    col+=(hash(fragCoord+t*8.)-.5)*.01;

    float fi=smoothstep(0.,3.,t),fo=1.-smoothstep(57.,60.,t);
    fragColor=vec4(col*fi*fo,1.);
}
