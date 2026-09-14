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


// GOLFED CODE 380 CHARS by GregRostami - https://www.shadertoy.com/user/GregRostami
void mainImage(out vec4 O, vec2 C)
{
    vec3 R = iResolution, p;
    float d, s, S, i, j, E = 1e-4;

    for (O = vec4(.3, .2, .24, 0); i++ < 36.; O += .05 * s * s) {
        p = vec3((C - R.xy / 2.) / R.x, d - 1.);
        p.y += 1.5;
        p.zx *= mat2(cos(iTime * .4 + vec4(0, 33, 11, 0)));
        S = 2.3;

        for (j=0.; j++ < 11.;
            p = vec3(0, 3.9, .8) - abs(abs(p * s) - vec3(1.9 - d, 3.83, 5.4)))
            S *= s = 7.9 / (dot(p, p) * .6 + E);

        d += p.y / (S + E);
        s = fract(1. / (p.y + E));
    }

    O = pow(O, O-O + 2.2);
    O *= (O/.57 + .03) / (.9 * O + .71);
}

/* TWIGL.APP GEEKEST 300ES - 348 CHARS
#define V vec3
#define R(a) mat2(cos(a+vec4(0,33,11,0)))
V p;float d,s,S,i,j,E=1e-4;for(o=vec4(.3,.2,.24,0);i++<36.;
o+=.05*s*s){p=V((FC.xy-r/2.)/r.x,d-1.);p.y+=1.5;p.zx*=R(t*.4);S=2.3;for(j=0.;
j++<11.;p=V(0,3.9,.8)-abs(abs(p*s)-V(1.9-d,3.83,5.4)))S*=s=7.9/(dot(p,p)*.6+E);
d+=p.y/(S+E);s=fract(1./(p.y+E));}o=pow(o,o-o+2.2);o*=(o/.57+.03)/(.9*o+.71);

// ==== -- ====
NON GOLFED CODE
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = vec4(0.30, 0.2, 0.24, 0.0);

    vec2 resolution = iResolution.xy;
    vec2 baseUv = (fragCoord - 0.5 * resolution) / resolution.x + vec2(0.0, 1.5);

    float angle = iTime * 0.4;
    mat2 rotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

    float RayDistance = 0.0;
    float EPSILON = 1e-4;

    for (int stepIndex = 3; stepIndex < 39; stepIndex++)
    {
        vec3 position = vec3(baseUv, RayDistance - 1.0);
        position.zx *= rotationMatrix;

        float accumulatedScale = 2.3;

        for (int fractalIter = 0; fractalIter < 11; fractalIter++)
        {
            float scaleFactor = 7.9 / max(dot(position, position) * 0.6, EPSILON);
            accumulatedScale *= scaleFactor;

            vec3 foldOffset = vec3(1.9 - RayDistance, 3.83, 5.4);
            position = vec3(0.0, 3.9, 0.8) - abs(abs(position) * scaleFactor - foldOffset);
        }

        RayDistance += position.y / max(accumulatedScale, EPSILON);

        float safeY = (abs(position.y) < EPSILON) ? sign(position.y) * EPSILON : position.y;
        float structureDetail = fract(1.0 / safeY);

        fragColor.rgb += 0.05 * structureDetail * structureDetail;
    }

    fragColor.rgb = pow(fragColor.rgb, vec3(2.2));

    vec3 x = fragColor.rgb;
    fragColor.rgb = clamp((x * (1.75 * x + 0.03)) / (0.90 * x + 0.71), 0.0, 1.0);
}
*/
