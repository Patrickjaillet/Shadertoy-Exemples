// ==== Image (image) ====
void mainImage(out vec4 fragColor,in vec2 fragCoord){

    vec2 uv=fragCoord/iResolution.xy;

    vec3 scene=texture(iChannel0,uv).rgb;

    vec3 bloom=texture(iChannel1,uv).rgb;

    vec3 col=scene + bloom*1.6;

    col=col/(1.+col);

    col=pow(col,vec3(.4545));

    fragColor=vec4(col,1.);
}

// ==== Buffer A (buffer) ====
#define MAX_STEPS 160
#define SURF_DIST .001
#define MAX_DIST 80.

float sdBox(vec3 p, vec3 b){
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

vec3 spectrum(float t){
    return .55+.45*cos(6.28318*(t+vec3(0,.33,.67)));
}

float GetDist(vec3 p){

    float d=p.y+1.;

    float z=p.z+5.;

    if(z>0.1){

        float logPos=log(z);

        float id=floor(logPos*5.);

        float ribZ=exp(id/5.);

        vec3 ribP=p;

        ribP.z-=ribZ;

        float h=log(ribZ+1.)*1.5;

        float rib=sdBox(ribP,vec3(4.,h,.08));

        float hallway=length(p.xy-vec2(0,h*.5))-1.6;

        rib=max(rib,-hallway);

        d=min(d,rib);
    }

    return d*.6;
}

float RayMarch(vec3 ro,vec3 rd){

    float dO=0.;

    for(int i=0;i<MAX_STEPS;i++){

        vec3 p=ro+rd*dO;

        float dS=GetDist(p);

        dO+=dS;

        if(dO>MAX_DIST||abs(dS)<SURF_DIST) break;
    }

    return dO;
}

vec3 GetNormal(vec3 p){

    vec2 e=vec2(.002,0);

    float d=GetDist(p);

    vec3 n=d-vec3(
    GetDist(p-e.xyy),
    GetDist(p-e.yxy),
    GetDist(p-e.yyx)
    );

    return normalize(n);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){

    vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;

    float speed=iTime*3.;

    float camZ=-4.+speed;

    float targetY=log(max(.1,camZ+5.))*.75;

    vec3 ro=vec3(0,targetY,camZ);

    float lookZ=camZ+4.;

    float lookY=log(max(.1,lookZ+5.))*.75;

    vec3 lookat=vec3(0,lookY,lookZ);

    vec3 f=normalize(lookat-ro);

    vec3 r=normalize(cross(vec3(0,1,0),f));

    vec3 u=cross(f,r);

    vec3 rd=normalize(f+uv.x*r+uv.y*u);

    float d=RayMarch(ro,rd);

    vec3 col=vec3(0);

    if(d<MAX_DIST){

        vec3 p=ro+rd*d;

        vec3 n=GetNormal(p);

        vec3 ld=normalize(vec3(1,4,-2));

        float dif=max(dot(n,ld),0.);

        float spe=pow(max(dot(reflect(rd,n),ld),0.),32.);

        vec3 mat=spectrum(p.z*.2+iTime*.3);

        float pulse=sin(p.z*8.-iTime*12.)*.5+.5;

        mat*=1.+pulse*2.;

        col=mat*(dif+.25)+spe*2.;
    }

    fragColor=vec4(col,1.);
}

// ==== Buffer B (buffer) ====
void mainImage(out vec4 fragColor,in vec2 fragCoord){

    vec2 uv=fragCoord/iResolution.xy;

    vec3 col=vec3(0.);

    float w[5];
    w[0]=0.227027;
    w[1]=0.1945946;
    w[2]=0.1216216;
    w[3]=0.054054;
    w[4]=0.016216;

    col+=texture(iChannel0,uv).rgb*w[0];

    for(int i=1;i<5;i++){

        col+=texture(iChannel0,uv+vec2(i,0)/iResolution.xy).rgb*w[i];
        col+=texture(iChannel0,uv-vec2(i,0)/iResolution.xy).rgb*w[i];
    }

    fragColor=vec4(col,1.);
}

// ==== Buffer C (buffer) ====
void mainImage(out vec4 fragColor,in vec2 fragCoord){

    vec2 uv=fragCoord/iResolution.xy;

    vec3 col=vec3(0.);

    float w[5];
    w[0]=0.227027;
    w[1]=0.1945946;
    w[2]=0.1216216;
    w[3]=0.054054;
    w[4]=0.016216;

    col+=texture(iChannel0,uv).rgb*w[0];

    for(int i=1;i<5;i++){

        col+=texture(iChannel0,uv+vec2(0,i)/iResolution.xy).rgb*w[i];
        col+=texture(iChannel0,uv-vec2(0,i)/iResolution.xy).rgb*w[i];
    }

    fragColor=vec4(col,1.);
}
