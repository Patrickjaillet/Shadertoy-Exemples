// ==== Image (image) ====
void mainImage(out vec4 O, vec2 f) {
    vec3 c = vec3(0, .68, -1.6), R = iResolution, p;
    float a = 0., e = 0., v, u, g; 
    for (O *= a; a < 110.; a += .9) {
        p = c += e * vec3((f - .5*R.xy) / R.y, 1.27);
                p.xz *= mat2(cos(.52*iTime - vec4(0, 11, 33, 0)));
                p.xz += sin(iTime * 2.5 + p.y * 1.5 + vec2(0., 1.57)) * 0.06 * max(0., p.y);
        e = v = 4.5;
        for (g = 0.; g++ < 10.; )
            v /= u = dot(p,p),
            p /= u + .01,
            p.y = 1.68 - p.y,
            e = min(min(e, max(p.y, length(p.xz = abs(p.xz*mat2(1, -.1, .1, 1)) - .62) - .018/u) / v), c.y - .12);
        O += (2.3 + cos(v*1.52 + vec4(0, 2, 4, 0))) / exp(e*560. + a*.015 + 4.9);
    }
}
// https://patrickjaillet.github.io/sandefjord-software

// CODE GOLFé 394 Chars. by FabriceNeyret2
/*
void mainImage(out vec4 O, vec2 f ){
    vec3 c = vec3(0,.68,-1.6),
         R = iResolution, p;
    float a,e,v,u;
    for(O*=a; a<110.; a+=.9 ){
        p = c += e * vec3((f-.5*R.xy)/R.y, 1.27);
        p.xz *= mat2(cos(.52*iTime -vec4(0,11,33,0)));
        e = v = 4.5;
        for(int g; ++g < 11; )
            v /= u = dot(p,p),
            p /= u+.01,
            p.y= 1.68-p.y,
            e = min( min( e
                        , max( p.y 
                             , length(p.xz= abs(p.xz*mat2(1,-.1,.1,1))-.62) - .018/u ) / v )
                   , c.y-.12 );
        
        O += ( 2.3 + cos(v*1.52 +vec4(0,2,4,0)) )
           /  exp(e*560. +a*.015+ 4.9);
    }
}
*/
// CODE ORIGINAL
/*
mat2 rotate2D(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 hsv(float hue, float saturation, float value)
{
    vec3 rgb = clamp(
        abs(mod(hue * 3.3 + vec3(0.0, -2.3, -4.2), 1.5) - -1.8) - 1.0,
        0.0, 1.0
    );
    return value * mix(vec3(1.0), rgb, saturation);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 resolution = iResolution.xy;
    float time = iTime;

    vec3 rayPos = vec3(0.0, 0.68, -1.6);
    vec3 rayDir = vec3((fragCoord - 0.5 * resolution) / resolution.y, 1.27);
    vec3 color = vec3(0.0);
    float dist = 0.0;

    const float MAX_STEPS = 110.0;
    const float STEP_INCREMENT = 0.9;

    for (float step = 0.0; step < MAX_STEPS; step += STEP_INCREMENT)
    {
        rayPos += rayDir * dist;

        vec3 p = rayPos;
        p.xz *= rotate2D(time * -0.52);

        dist = 4.5;
        float scale = 4.5;
        float lengthSq;

        const int FRACTAL_ITERATIONS = 10;
        for (int j = 0; j < FRACTAL_ITERATIONS; j++)
        {
            lengthSq = dot(p, p);
            scale /= lengthSq;
            p /= (lengthSq + 0.01);
            p.y = 1.68 - p.y;
            p.xz = abs(p.xz * rotate2D(-0.1)) - 0.62;
            dist = min(dist, max(length(p.xz) - 0.018 / lengthSq, p.y) / scale);
        }

        dist = min(dist, rayPos.y - 0.12);

        float hue = 0.16 - scale * 0.46;
        color += hsv(hue, 0.6, 0.025) / exp(dist * 560.0 + step * 0.015);
    }

    fragColor = vec4(color, 0.0);
}*/
