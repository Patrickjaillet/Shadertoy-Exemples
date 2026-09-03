// ==== Image (image) ====
void mainImage(out vec4 l,in vec2 m){
  vec2 n=iResolution.xy;
  float b=iTime*.3;
  const float o=1./3.14159265359;
  float h=b*.1,i=sin(h),ka=cos(h);
  mat2 j=mat2(ka,-i,i,ka);
  float p=sin(b*.5)*.4+cos(b*.25)*.2,q=cos(b*.4)*.3+sin(b*1.)*.1,r=b*o,e=0.,c=0.,d=0.,f=0.;
  const int s=117;
  for(int g=0;g<s;g++){
    float t=float(g);
    vec3 a=vec3(m/n.y*e,e);
    a.xz*=j;
    a.yz*=j;
    a.x-=p;
    a.y-=q;
    a.z+=r;
    a+=.9-t/20000.;
    a.xy=mod(a.xy-1.,8.)-1.;
    d=4.;
    for(int k=0;k<5;k++){
      a=mod(a-.9,2.)-1.;
      c=length(a*a)*.8;
      d/=c;
      a=abs(a)/c;
      a.y+=.2;
    }
    c=a.x/d;
    e+=abs(c);
    f+=.0001/(.012+abs(c)*4.8);
    if(f>=1.)break;
  }
  vec3 u=pow(clamp(vec3(f),0.,1.),vec3(3.3));
  l=vec4(u,1.);
}
/*
void mainImage(out vec4 o, in vec2 p){
    vec2 g = iResolution.xy;
    float b = iTime * 0.3;
    const float TAU_INV = 1.0/3.14159265359;

    float ia = b*0.1;
    float ja = sin(ia), ka = cos(ia);
    mat2 rot = mat2(ka,-ja,ja,ka);
    float sOff = sin(b*0.5)*0.4 + cos(b*0.25)*0.2;
    float tOff = cos(b*0.4)*0.3 + sin(b*1.0)*0.1;
    float zAdd = b*TAU_INV;

    float e=0.0, c=0.0, d=0.0;
    float h=0.0;

    const int MAX_STEPS = 117;
    for(int f=0; f<MAX_STEPS; f++){
        float r = float(f);
        vec3 a = vec3(p/g.y*e, e);

        a.xz *= rot;
        a.yz *= rot;

        a.x -= sOff;
        a.y -= tOff;
        a.z += zAdd;
        a += 0.9 - r/20000.0;

        a.xy = mod(a.xy-1.0,8.0)-1.0;

        d = 4.0;
        for(int n=0; n<5; n++){
            a = mod(a-0.9,2.0)-1.0;
            c = length(a*a)*0.8;
            d /= c;
            a = abs(a)/c;
            a.y += 0.2;
        }

        c = a.x/d;
        e += abs(c);

        h += 0.0001/(0.012+abs(c)*4.8);

        if(h >= 1.0) break; 
    }

    vec3 v = pow(clamp(vec3(h),0.,1.), vec3(3.3));
    o = vec4(v,1.0);
}
*/
