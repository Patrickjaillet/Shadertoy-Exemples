// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software/

/* GOLFED CODE
void mainImage(out vec4 j,vec2 l){
    vec2 g=iResolution.xy;
    vec3 e=vec3(0.,.45,-3.),o=vec3(0.),a;
    float b=0.,c,d,f,k,h=b;
    for(;h<1e2;++h){
        a=e+=vec3((l-.5*g)/g.y,1.6)*b;
        a.xz*=mat2(cos(iTime+vec4(0,1.57,-1.57,0)));
        b=9.7;
        c=2.6;
        f=29.6;
        for(int i=0;i<9;i++){
            a.xz*=mat2(cos(24.8+vec4(0,1.57,-1.57,0)));
            a.xz=abs(a.xz)-.5;
            d=dot(a,a);
            c/=d;
            a/=(d+.07);
            a.y=1.71-a.y;
            f=min(f,length(a.xz));
            b=min(b,max(length(a.xz),a.y)/c);
        }
        b=min(b,e.y);
        k=step(1.,e.y);
        o+=exp(-a.y/c-5.5)*mix(mix(vec3(2.8),vec3(-.4),k),vec3(0.,.15,0.),clamp((.43-f)/.3,0.,1.)*clamp(e.y/.31,0.,1.)*(1.-k));
    }
    j=vec4(o,1.);
}
*/
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = iResolution.xy;
    vec2 FC = fragCoord;
    float t = iTime;

    float sT = sin(t);
    float cT = cos(t);
    mat2 rotTime = mat2(cT, -sT, sT, cT);      
    
    float sS = sin(24.8);
    float cS = cos(24.8);
    mat2 rotStep = mat2(cS, -sS, sS, cS);

    vec3 q = vec3(0.0, 0.45, -3.0);
    vec3 o = vec3(0.0);

    float e = 0.0;
    float v;
    float u;

    for (float i = 0.0; i < 100.0; i += 1.0)
    {
        vec3 p = q += vec3((FC.xy - 0.5 * r) / r.y, 1.6) * e;

        p.xz *= rotTime;

        e = 9.7;
        v = 2.6;

        float radius = 29.6;

        for (int j = 0; j < 9; j++)
        {
            p.xz *= rotStep;
            p.xz = abs(p.xz) - 0.5;

            u = dot(p, p);
            v /= u;
            p /= (u + 0.07);
            p.y = 1.71 - p.y;

            radius = min(radius, length(p.xz));
            e = min(e, max(length(p.xz) - 0.00 / u, p.y) / v);
        }

        float stemDist = q.y;
        e = min(e, stemDist);

        float stemMask = step(1.0, stemDist); // MacOS Compat. by Chimel - https://www.shadertoy.com/user/Chimel
        float leafMask = smoothstep(0.43, 0.13, radius) * smoothstep(0.00, 0.31, stemDist) * (1.0 - stemMask);

        vec3 petalColor = vec3(2.8);          
        vec3 stemColor   = vec3(-0.4);         
        vec3 leafColor   = vec3(0.0, 0.15, 0.0); 

        vec3 mixedColor = mix(petalColor, stemColor, stemMask);
        mixedColor = mix(mixedColor, leafColor, leafMask);

        o += exp(-p.y / v - 5.5) * mixedColor;
    }

    fragColor = vec4(o, 1.0);
}
