// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
float e(vec2 a){
    a=fract(a*vec2(123.34,456.21)),a+=dot(a,a+55.4);
    return fract(a.x*a.y);
}
float j(vec2 a){
    vec2 c=floor(a),f=fract(a),g=f*f*(3.-2.*f);
    float h=e(c),b=e(c+vec2(1.,0.)),i=e(c+vec2(0.,1.)),k=e(c+vec2(1.));
    return mix(mix(h,b,g.x),mix(i,k,g.x),g.y);
}
float d(vec2 a){
    float g=0.,h=.6,i=1.;
    for(int c=0;c<6;c++)g+=h*j(a*i),i*=2.2,h*=.5;
    return g;
}
void mainImage(out vec4 h,in vec2 i){
    vec2 c=(i-.5*iResolution.xy)/min(iResolution.x,iResolution.y);
  // line by msm01 - https://www.shadertoy.com/user/msm01
  //--------------------------
    c=vec2(abs(c.x),-1.0*c.y);
  //--------------------------
    c*=4.8;
    float t=iTime*.2;
    vec2 g=vec2(0.);
    g.x=d(c+vec2(0.)),g.y=d(c+vec2(1.));
    vec2 r=vec2(0.);
    r.x=d(c+g+vec2(1.7,9.2)+.15*t),r.y=d(c+g+vec2(26.9,10.4)+t);
    float f=d(c+r);
    vec3 a=vec3(0.);
    a=mix(vec3(.1,0.,0.),vec3(.2,.05,.05),clamp(f*f*4.4,0.,.4)),a=mix(a,vec3(1.,.2,0.),clamp(pow(f,3.)*3.5,0.,1.)),a=mix(a,vec3(1.,1.,.6),clamp(pow(f,5.)*4.3,0.,1.)),a=a*a*2.6;
    float k=1.-dot(c,c)*.05;
    a*=clamp(k,0.,1.),h=vec4(a,1.);
}
