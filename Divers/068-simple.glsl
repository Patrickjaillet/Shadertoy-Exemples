// ==== Image (image) ====
void mainImage(out vec4 k,in vec2 l){vec2 m=(l-.5*iResolution.xy)/iResolution.y;
vec3 n=vec3(cos(iTime*.2),sin(iTime*.3),-3.);
vec3 o=normalize(vec3(m,3.2));vec3 e=n;float b=0.;
vec3 f=vec3(0.);for(int g=0;g<65;g++){vec3 a=e;float h=.8;
for(int i=0;i<18;i++){a=abs(a)-vec3(.6,1.5,.5);float c=.3*iTime;a.xz*=mat2(cos(c),-sin(c),sin(c),cos(c));
float p=dot(a,a);float j=2./clamp(p,.2,1.);a*=j;h*=j;}float d=length(a.xz)/h-0.;
if(abs(d)<.0001||b>24.1)break;e+=o*d;b+=d;f+=vec3(1.,.4,.2)/(1.+b*b*.9);}k=vec4(f*exp(-.5*b),1.);}
