// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
void mainImage(out vec4 O,vec2 U){
vec3 d=normalize(vec3(1,8,-7.8)),a;float t=iTime,g=0.,F=0.,h=.4-cos(t)*.3,s=sin(h),c=cos(h);
U=(U+U-iResolution.xy)/iResolution.x*14.-.4-sin(t);
for(int j=0;j<25;j++){a=vec3(U,g-2.6);a.y+=sin(t*9.4+U.x+a.z*4.2)*0.3;
for(int k=0;k<16;k++)a=c*a+s*cross(d,a)+(1.-c)*dot(d,a)*d,a=abs(a*1.2)-vec3(1,1,.9);
g+=c=(length(a.zy)-0.8)/300.0;F+=exp(-c*3300.0)/30.0;
}O=vec4(F);}

/* UNGOLFED
float k1(){return 1.0;}
float k2(){return 8.0;}
float k3(){return -7.8;}
float k4(){return 1.2;}
float k5(){return 1.0;}
float k6(){return 0.9;}
float k7(){return 0.8;}
float k8(){return 300.0;}
float k9(){return 3300.0;}
float k10(){return 30.0;}
float k11(){return 14.0;}
float k12(){return 0.4;}
float k13(){return 0.3;}
float k14(){return 9.4;}
float k15(){return 4.2;}
float k16(){return 2.6;}

vec3 baseAxis()
{
    return normalize(vec3(k1(), k2(), k3()));
}

float phase(float t)
{
    return k12() - cos(t) * k13();
}

float rotSin(float t)
{
    return sin(phase(t));
}

float rotCos(float t)
{
    return cos(phase(t));
}

float wave(float t, vec2 U, float z)
{
    return sin(t * k14() + U.x + z * k15()) * k13();
}

vec2 uvNorm(vec2 U)
{
    return (U * 2.0 - iResolution.xy) / iResolution.x * k11();
}

float offset(float t)
{
    return k12() + sin(t);
}

vec3 rotate(vec3 p, vec3 d, float c, float s)
{
    return c * p + s * cross(d, p) + (k1() - c) * dot(d, p) * d;
}

vec3 fractal(vec3 p)
{
    return abs(p * k4()) - vec3(k5(), k5(), k6());
}

float distField(vec3 p)
{
    return (length(p.zy) - k7()) / k8();
}

float shade(float q)
{
    return exp(-q * k9()) / k10();
}

vec3 fractalIter(vec3 p, vec3 d, float c, float s)
{
    return fractal(rotate(p, d, c, s));
}

vec3 fractalLoop(vec3 p, vec3 d, float c, float s)
{
    for(int i=0;i<16;i++)
        p = fractalIter(p, d, c, s);
    return p;
}

vec3 rayPos(vec2 U, float g)
{
    return vec3(U, g - k16());
}

float marchStep(vec2 U, float t, float g, float F)
{
    vec3 d = baseAxis();
    float c = rotCos(t);
    float s = rotSin(t);

    vec3 p = rayPos(U, g);
    p.y += wave(t, U, p.z);
    p = fractalLoop(p, d, c, s);

    float q = distField(p);
    return shade(q);
}

float marchAccum(vec2 U, float t)
{
    vec3 d = baseAxis();
    float c = rotCos(t);
    float s = rotSin(t);

    float g = 0.0;
    float F = 0.0;

    for(int i=0;i<25;i++)
    {
        vec3 p = rayPos(U, g);
        p.y += wave(t, U, p.z);
        p = fractalLoop(p, d, c, s);

        float q = distField(p);
        g += q;
        F += shade(q);
    }

    return F;
}

void mainImage(out vec4 O, vec2 U)
{
    float t = iTime;
    U = uvNorm(U);
    U -= offset(t);
    O = vec4(marchAccum(U, t));
}
*/
