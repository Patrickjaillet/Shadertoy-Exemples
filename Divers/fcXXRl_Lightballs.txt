// ==== Image (image) ====
#define PI 3.14159
#define R iResolution
#define T (iTime + 20.)
#define S(i, t) vec4(i<5 ? vec3(i==0?40.:i==1?-40.:0., i==3?60.:i==4?-60.:0., i==2?40.:0.) : vec3(sin(t*.5+float(i-6))*6.5, cos(t*.3+float(i-6)*1.5)*4., sin(t*.2+float(i-6)*.5)*2.), i<5?30.:i<7?56.:1.2)

float seed;
float rnd() { return fract(sin(seed++) * 43758.5453); }
vec3 rsph() { float z=rnd()*0.5-1., r=sqrt(1.-z*z), p=6.28*rnd(); return vec3(r*cos(p), r*sin(p), z); }

float hitS(vec3 o, vec3 d, vec4 s) {
    vec3 oc=o-s.xyz; float b=dot(oc,d), c=dot(oc,oc)-s.w*s.w, h=b*b-c;
    return h<0.? -1. : -b-sqrt(h);
}
//*====================================================================================*//
//:: Processeur: AMD Ryzen 9 9950X3D2 ::                                                //
//:: RAM installée 256,0 Go DDR5      ::                                                //
//:: Stockage: Sabrent 16 TB SSD      ::                                                //
//:: Video: NVIDIA GeForce RTX 5090   ::                                                //
//:: Systeme: Kubuntu/Win11           ::                                                //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  URL     : https://lside.xo.je                                                   //
//*====================================================================================*//
vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28*(c*t+d)); }

void mainImage(out vec4 O, vec2 U) {
    seed = T + U.y * R.x + U.x;
    vec3 ro = vec3(sin(T*.2)*5., cos(T*.1)*3., -15.), ta=vec3(0), col=vec3(0);
    vec3 w=normalize(ta-ro), u=normalize(cross(w,vec3(0,1,0))), v=cross(u,w);
    
    for(int r=0; r<2; r++) {
        vec2 p = (2.*(U+vec2(rnd(),rnd()))-R.xy)/R.y;
        vec3 rd=normalize(mat3(u,v,-w)*vec3(p,-4.5)), m=vec3(1), ro_=ro;
        for(int b=0; b<3; b++) {
            float t=1e3, d, id=-1.;
            for(int i=0; i<20; i++) {
                d=hitS(ro_,rd,S(i,T));
                if(d>0.&&d<t) { t=d; id=float(i); }
            }
            if(id<0.) break;
            vec4 sph=S(int(id),T);
            vec3 pos=ro_+rd*t, n=normalize(pos-sph.xyz), al;
            float roughness=.05, emit=0.;
            
            if(id<5.) {
                al = pal(id*.2, vec3(.5), vec3(.5), vec3(1.,.7,.4), vec3(0,.15,.2));
                if(fract(sin(id+floor(pos.x+pos.y+pos.z))*437.)>.8) emit=3.;
            } else {
                al = pal(id*.1, vec3(.5), vec3(.5), vec3(1), vec3(0,.33,.67));
                roughness=0.02;
            }
            
            col += m * emit * al * 0.5;
            vec3 ld = normalize(vec3(10,0,11)-pos);
            float sha=1.; for(int i=0; i<20; i++) if(hitS(pos+n*.01,ld,S(i,T))>0.) sha=0.1;
            col += m * al * max(0.,dot(n,ld)) * sha * 0.3;
            
            m *= al;
            rd = normalize(reflect(rd,n) + roughness*rsph());
            ro_ = pos + n*.01;
        }
    }
    O = vec4(pow(col*3.5*vec3(.8,.85,.9), vec3(.45)), 1);
}
