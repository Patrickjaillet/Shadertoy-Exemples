// ==== Image (image) ====
#define PI 3.14159265359
#define STEPS 20
#define SHADOW_STEPS 4

mat2 rot(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(c,-s,s,c);
}

vec3 hash33(vec3 p)
{
    p = fract(p * vec3(443.897,441.423,437.195));
    p += dot(p,p.yxz+19.19);
    return fract((p.xxy+p.yzz)*p.zyx);
}

float noise(vec3 p)
{
    vec3 i = floor(p);
    vec3 f = fract(p);

    f = f*f*(3.0-2.0*f);

    float n =
    mix(
        mix(
            mix(hash33(i+vec3(0,0,0)).x,
                hash33(i+vec3(1,0,0)).x,f.x),

            mix(hash33(i+vec3(0,1,0)).x,
                hash33(i+vec3(1,1,0)).x,f.x),f.y),

        mix(
            mix(hash33(i+vec3(0,0,1)).x,
                hash33(i+vec3(1,0,1)).x,f.x),

            mix(hash33(i+vec3(0,1,1)).x,
                hash33(i+vec3(1,1,1)).x,f.x),f.y),

        f.z);

    return n;
}

float fbm(vec3 p)
{
    float v = 0.0;
    float a = 0.5;

    mat3 m = mat3(
        0.00, 0.80, 0.60,
       -0.80, 0.36,-0.48,
       -0.60,-0.48, 0.64
    );

    for(int i=0;i<5;i++)
    {
        v += noise(p)*a;
        p = m*p*2.02;
        a *= 0.5;
    }

    return v;
}

float map(vec3 p)
{
    float r = length(p);

    float warp =
        fbm(p*0.45 + iTime*0.04);

    p += warp*1.5;

    float d =
        fbm(p*1.2);

    d += fbm(p*2.5)*0.35;

    d *= smoothstep(8.0,2.0,r);
    d *= smoothstep(0.6,1.8,r);

    return max(d-0.38,0.0);
}

vec3 nebula(float d)
{
    vec3 c1 = vec3(0.02,0.04,0.12);
    vec3 c2 = vec3(0.4,0.08,0.5);
    vec3 c3 = vec3(0.0,0.7,1.0);
    vec3 c4 = vec3(1.5,0.8,0.3);

    vec3 col = mix(c1,c2,smoothstep(0.0,0.4,d));
    col = mix(col,c3,smoothstep(0.4,0.8,d));

    col += c4*pow(d,6.0);

    return col;
}

vec3 stars(vec2 uv)
{
    vec3 col = vec3(0.0);

    for(float i=0.; i<4.; i++)
    {
        vec2 p = uv*(20.0+i*30.0);

        vec2 id = floor(p);
        vec2 gv = fract(p)-0.5;

        vec3 h = hash33(vec3(id,i));

        if(h.x > 0.93)
        {
            vec2 offs = (h.yz-0.5)*0.6;

            float d = length(gv-offs);

            float s = 0.002/(d*d+0.00002);

            float tw =
                sin(iTime*3.0+h.z*20.0)*0.5+0.5;

            vec3 c =
                mix(vec3(0.6,0.8,1.0),
                    vec3(1.0,0.8,0.6),
                    h.y);

            col += s*c*(0.3+tw);
        }
    }

    return col;
}

vec3 render(vec3 ro, vec3 rd, vec2 uv)
{
    vec3 col = vec3(0.0);

    float t = 0.8;
    float trans = 1.0;

    for(int i=0;i<STEPS;i++)
    {
        if(trans < 0.01 || t > 12.0) break;

        vec3 p = ro + rd*t;

        float d = map(p);

        if(d > 0.001)
        {
            vec3 ld =
                normalize(vec3(1.0,1.0,-1.0));

            float sh = 0.0;

            for(int j=1;j<=SHADOW_STEPS;j++)
            {
                sh += map(p + ld*float(j)*0.2);
            }

            vec3 l =
                nebula(d)*exp(-sh*0.7);

            float dens = d*0.18;

            col += l*dens*trans*5.0;

            trans *= exp(-dens*4.0);
        }

        float stepSize =
            mix(0.04,0.12,t/12.0);

        t += stepSize;
    }

    return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv =
        (fragCoord - iResolution.xy*0.5)
        / iResolution.y;

    vec3 ro =
        vec3(
            sin(iTime*0.12)*1.5,
            sin(iTime*0.07)*0.4,
            -6.0
        );

    vec3 ta = vec3(0.0);

    vec3 cw = normalize(ta-ro);
    vec3 cp = vec3(0.0,1.0,0.0);

    vec3 cu = normalize(cross(cw,cp));
    vec3 cv = normalize(cross(cu,cw));

    vec2 bhPos =
        vec2(
            sin(iTime*0.15)*0.3,
            cos(iTime*0.11)*0.15
        );

    vec2 dv = uv - bhPos;

    float dd = dot(dv,dv);

    vec2 lensUV =
        uv - dv*(0.035/(dd+0.03));

    vec3 rd =
        normalize(
            lensUV.x*cu +
            lensUV.y*cv +
            2.4*cw
        );

    vec3 col =
        vec3(0.001,0.002,0.006);

    col += stars(lensUV);

    col += render(ro,rd,uv);

    float core =
        0.0005/(dd+0.0001);

    float glow =
        0.015/(sqrt(dd)+0.04);

    vec3 bh =
        vec3(0.9,0.95,1.0)*core;

    bh +=
        vec3(0.2,0.5,1.2)*glow;

    vec2 rv = rot(iTime*0.12)*dv;

    float rays =
        pow(abs(rv.x*rv.y),-0.12)
        *0.0012;

    bh += rays*vec3(0.5,0.8,1.4)*glow;

    col += bh;

    col = col/(1.0+col);

    col = pow(col,vec3(0.4545));

    fragColor = vec4(col,1.0);
}
