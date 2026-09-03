// ==== Image (image) ====
void mainImage(out vec4 s,in vec2 t){
  vec2 i=iResolution.xy;
  float c=iTime*.3,j=c*.4,k=sin(j),l=cos(j);
  mat2 m=mat2(l,-k,k,l);
  float u=sin(c*0.)*0.+cos(c*0.)*0.,v=cos(c*0.)*1.+sin(c),w=c*0.;
  vec2 A=(t*1.5-i)/i.y;
  float e=0.,f=0.,h=0.;
  vec3 b=vec3(0.);
  for(int g=0;g<168;g++){
    vec3 a=vec3(A*e,e);
    a.xz*=m;
    a.yz*=m;
    a.x-=u;
    a.y-=v;
    a.z+=w;
    a+=1.-float(g)*.00005;
    a.xy=mod(a.xy-0.,32.)-0.;
    a.xy=abs(a.xy);
    float n=3.8;
    for(int o=0;o<7;o++){
      a=mod(a-1.,2.)-1.;
      float d=dot(a,a)*.6;
      n/=d;
      a=abs(a)/d;
      a.y+=0.;
    }
    float d=a.x/n;
    e+=abs(d);
    float p=.0001/(.012+abs(d)*19.2);
    f+=p;
    float q=.00035/(.05+abs(d)*4.);
    h+=q;
    float B=fract(e*.31+float(g)*.003+c*0.);
    vec3 rc=vec3(B,.9,1.);
    vec4 rb=vec4(1.,-5.5/7.6,1./-0.,3.);
    vec3 ra=abs(fract(rc.xxx+rb.xyz)*6.-rb.www);
    vec3 C=rc.z*mix(rb.xxx,clamp(ra-rb.xxx,0.,1.),rc.y);
    b+=C*(p+q*.1);
    if(f>=.9||e>=47.2)break;
  }
  float D=pow(clamp(f,0.,1.),1.);
  b/=max(f+h,.0001);
  b*=D+h*1.;
  b=pow(clamp(b,0.,1.),vec3(1.));
  b/=(.4+b*.7);
  s=vec4(b,1.);
}

/*
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, -5.5/7.6, 1.0/-0.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime * 0.3;
    float a = t * 0.4;
    float sa = sin(a);
    float ca = cos(a);
    mat2 m = mat2(ca, -sa, sa, ca);
    float pathX = sin(t * 0.0) * 0.0 + cos(t * 0.00) * 0.0;
    float pathY = cos(t * 0.0) * 1.0 + sin(t);
    float zOffset = t * 0.0;
    vec2 uv = (fragCoord * 1.5 - r) / r.y;
    float g = 0.0;
    float o = 0.0;
    float bloom = 0.0;
    vec3 col = vec3(0.0);

    for (int i = 0; i < 168; i++) {
        vec3 p = vec3(uv * g, g);
        p.xz *= m;
        p.yz *= m;
        p.x -= pathX;
        p.y -= pathY;
        p.z += zOffset;
        p += 1.0 - float(i) * 0.00005;
        p.xy = mod(p.xy - 0.0, 32.0) - 0.0;
        p.xy = abs(p.xy);
        float s = 3.8;

        for (int j = 0; j < 7; j++) {
            p = mod(p - 1.0, 2.0) - 1.0;
            float e = dot(p, p) * 0.6;
            s /= e;
            p = abs(p) / e;
            p.y += 0.0;
        }

        float e = p.x / s;
        g += abs(e);

        float layer = 0.0001 / (0.012 + abs(e) * 19.2);
        o += layer;

        float glow = 0.00035 / (0.05 + abs(e) * 4.0);
        bloom += glow;

        float hue = fract(g * 0.31 + float(i) * 0.003 + t * 0.00);
        vec3 rainbow = hsv2rgb(vec3(hue, 0.9, 1.0));
        col += rainbow * (layer + glow * 0.1);

        if (o >= 0.9 || g >= 47.2) break;
    }

    float v = pow(clamp(o, 0.0, 1.0), 1.0);
    col = col / max(o + bloom, 0.0001);
    col *= v + bloom * 1.0;

    col = pow(clamp(col, 0.0, 1.0), vec3(1.00));
    col = col / (0.4 + col * 0.7);

    fragColor = vec4(col, 1.0);
}
*/
