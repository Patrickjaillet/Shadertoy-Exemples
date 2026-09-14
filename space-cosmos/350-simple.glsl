// ==== Image (image) ====
/***************************************************************************
https://patrickjaillet.github.io/sandefjord-software
/***************************************************************************
Fractal raymarching utilizing logarithmic-spherical space folding. 
Continuous domain traversal via modular tiling, iterative sphere inversions, 
and fixed YZ orthogonal rotations.
***************************************************************************/
mat2 g(float c){
    float a=sin(c),b=cos(c);
    return mat2(b,-a,a,b);
}

void mainImage(out vec4 i,in vec2 q){
    vec2 r=(q-.5*iResolution.xy)/iResolution.y;
    float b=iTime;
    vec3 s=vec3(0.,0.,-3.),d=vec3(r,.8);
    d.xz*=g(b*.2);
    d.yz*=g(b*.25);
    d=normalize(d);
    float h=.001,j,e,k;
    vec3 a;
    vec4 f=vec4(0.);
    for(int l=0;l<110;l++){
        a=s+d*h;
        k=length(a);
        float m=max(k,.001);
        vec2 p2=a.xz/m;
        float c_cos=p2.x*cos(b*.4)-p2.y*sin(b*.4);
        float c_sin=p2.x*sin(b*.4)+p2.y*cos(b*.4);
        vec2 freq=vec2(cos(3.0*atan(c_sin,c_cos)),sin(3.0*atan(c_sin,c_cos)));
        a=vec3(log(m)+b*.2,a.y/m,freq.x);
        a=fract(a)-.5;
        e=1.;
        float orbit=0.;
        for(int n=0;n<8;n++){
            a=mod(a+1.,2.3)-1.;
            a.yz*=g(.785398);
            float o=dot(a,a)+1e-4;
            a/=o;
            e/=o;
            orbit+=dot(a,a);
        }
        float p=length(a.xz)/e;
        j=p;
        h+=max(j,1e-4);
        float u=min(1.,e*.02);
        
        float color_index=floor(mod(orbit*0.125+b*0.5,8.0));
        vec3 v;
        if(color_index<1.)      v=vec3(1.0,0.1,0.1);
        else if(color_index<2.) v=vec3(1.0,0.5,0.0);
        else if(color_index<3.) v=vec3(1.0,0.9,0.0);
        else if(color_index<4.) v=vec3(0.1,0.9,0.2);
        else if(color_index<5.) v=vec3(0.0,0.8,0.9);
        else if(color_index<6.) v=vec3(0.1,0.3,1.0);
        else if(color_index<7.) v=vec3(0.6,0.1,0.9);
        else                    v=vec3(1.0,0.2,0.6);
        
        f+=.015/exp(p*414.6)*vec4(v*u,0.);
        if(h>40.)break;
    }
    i=clamp(f,0.,1.);
    i.w=0.;
}
