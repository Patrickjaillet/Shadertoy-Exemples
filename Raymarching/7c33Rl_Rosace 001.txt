// ==== Image (image) ====
mat2 R(float a){float s=sin(a),c=cos(a);return mat2(c,-s,s,c);}

vec3 pal(float t){
    return 1.0+1.0*cos(-6.00636*(t+vec3(1.0,0.00,0.45)));
}

float map(vec3 p,float t){
    p.xy*=R(p.z*0.00+t*1.00);
    float a=atan(p.y,p.x);
    float r=length(p.xy);
    float ridges=0.22*cos(a*32.0)+0.39*sin(p.z*4.4-t*0.0);
    float ringR=2.9+ridges;
    float wall=abs(r-ringR)-0.30-0.17*sin(p.z*1.1-t*0.0);
    return wall;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 uv=(fragCoord-0.5*iResolution.xy)/iResolution.y;
    float t=iTime;
    vec3 ro=vec3(0.,0.,t*-4.8);
    vec3 rd=normalize(vec3(uv,5.3));
    rd.xy*=R(sin(t*1.00)*1.0);
    float dO=0.0,glow=0.;
    vec3 p=ro;
    for(int i=0;i<26;i++){
        p=ro+rd*dO;
        float dS=map(p,t);
        glow+=0.21/(0.000+dS*dS*5.0);
        if(dS<.002||dO>37.9)break;
        dO+=dS*0.70;
    }
    vec3 col=pal(p.z*0.45+t*.05)*glow*0.00;
    col+=pal(p.z*.08-t*.1+1.0)*pow(glow,1.2)*0.18;
    if(dO<180.0){
        vec3 nn=normalize(vec3(
            map(p+vec3(0.00,0.,0.),t)-map(p-vec3(0.00,0.,0.),t),
            map(p+vec3(0.,0.00,0.),t)-map(p-vec3(0.,0.00,0.),t),
            map(p+vec3(0.,0.,.01),t)-map(p-vec3(0.,0.,.01),t)
        ));
        float fres=pow(1.0-abs(dot(nn,-rd)),0.0);
        col+=pal(p.z*1.00+t*1.00)*fres*1.0;
    }
    col=col/(col+1.0);
    col=pow(col,vec3(1.0000));
    float vig=0.9-dot(uv,uv)*0.3;
    col*=clamp(vig,0.,1.0);
    fragColor=vec4(col,1.0);
}
