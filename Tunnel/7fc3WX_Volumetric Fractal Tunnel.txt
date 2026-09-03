// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
/***********************************************************************
To generate these colorful volumetric fractals, 
the core technique is **Raymarching / Volumetric Accumulation**:

1. Space Fold & Domain Warping:
Rays are projected into a custom logarithmic/spherical coordinate 
space `(log(r), exp(-z/r), atan(y,x))`

2. FBM Harmonics: 
A dense scalar field is constructed by accumulating multi-scale 
trigonometric waves (`sin(a.zxx * b) * cos(...)`).

3. Density Accumulation & Palette:
Rays step continuously through space, accumulating local density while 
mapping depth and time to a smooth pastel color array.
************************************************************************/
// v1.1 - 8 Pastel Colors
void mainImage(out vec4 k, in vec2 l) {
    vec2 m = l / iResolution.xy * .6 - vec2(.4, -.6);
    vec3 n = vec3(m, .3), f = vec3(.7, -8., -2.7), g = vec3(0.);
    float c = 0., d = 0., b = 0.;
    vec3 h[8] = vec3[8](
        vec3(.98, .7, .75), vec3(.98, .82, .65),
        vec3(.99, .96, .68), vec3(.72, .93, .78),
        vec3(.67, .88, .95), vec3(.73, .76, .96),
        vec3(.88, .72, .95), vec3(.95, .75, .87)
    );
    for (float e = 0.; e < 90.; ++e) {
        float o = clamp(min(c * b, .6) / 41.3, 0., 1.), i = mod(e * .15 + c * 2. + iTime * .2, 8.);
        int j = int(i), p = (j + 1) & 7;
        g += o * mix(h[j], h[p], smoothstep(0., 1., fract(i)));
        b = .7;
        f += n * c * d * .4 + 1e-4;
        vec3 a = f;
        d = max(length(a), 1e-4);
        a = vec3(log(d) - iTime * .7, exp(-a.z / d) + .23, atan(a.y, a.x));
        a.y -= 1.;
        c = a.y;
        for (; b < 1603.; b += b) {
            c += dot(sin(a.zxx * b), .9 - cos(a.yzy * b)) / b * .28;
        }
    }
    k = vec4(g, 1.);
}
/* v1.0 - B&W
void mainImage(out vec4 h,in vec2 i){
    vec2 j=i.xy/iResolution.xy*.6-vec2(.4,-.6);
    vec3 k=vec3(j,.3);
    vec3 e=vec3(.7,-8.,-2.7);
    vec3 f=vec3(0.);
    float c=0.;
    float d=0.;
    float b=0.;
    for(float g=0.;g<90.;g+=1.){
        float l=clamp(min(c*b,.6)/41.3,0.,1.);
        f+=vec3(l);
        b=.7;
        e+=k*c*d*.4+1e-4;
        vec3 a=e;
        d=max(length(a),1e-4);
        a=vec3(log(d)-iTime*.7,exp(-a.z/d)+.23,atan(a.y,a.x));
        a.y-=1.;
        c=a.y;
        for(;b<1603.;b+=b){
            vec3 m=a.zxx*b;
            vec3 n=a.yzy*b;
            c+=dot(sin(m),.9-cos(n))/b*.28;
        }
    }
    h=vec4(f,0.);
}
*/
/*
ORIGINAL:
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy * 0.6 - vec2(0.4, -0.6);
    
    vec3 rayDirection = vec3(uv, 0.3);
    vec3 rayPosition = vec3(0.7, -8.0, -2.7);
    vec3 accumulatedColor = vec3(0.0);
    
    float density = 0.0;
    float currentDistance = 0.0;
    float octaveFrequency = 0.0;

    vec3 pastelPalette[8] = vec3[8](
        vec3(0.98, 0.70, 0.75),
        vec3(0.98, 0.82, 0.65),
        vec3(0.99, 0.96, 0.68),
        vec3(0.72, 0.93, 0.78),
        vec3(0.67, 0.88, 0.95),
        vec3(0.73, 0.76, 0.96),
        vec3(0.88, 0.72, 0.95),
        vec3(0.95, 0.75, 0.87)
    );

    for (float stepIndex = 0.0; stepIndex < 90.0; ++stepIndex) {
        float opacity = clamp(min(density * octaveFrequency, 0.6) / 41.3, 0.0, 1.0);
        
        float paletteIndex = mod(stepIndex * 0.15 + density * 2.0 + iTime * 0.2, 8.0);
        int baseIndex = int(paletteIndex);
        int nextIndex = (baseIndex + 1) & 7;
        float interpolationFactor = fract(paletteIndex);
        
        vec3 currentColor = mix(
            pastelPalette[baseIndex], 
            pastelPalette[nextIndex], 
            smoothstep(0.0, 1.0, interpolationFactor)
        );
        
        accumulatedColor += opacity * currentColor;

        octaveFrequency = 0.7;
        rayPosition += rayDirection * density * currentDistance * 0.4 + 1e-4;
        
        vec3 samplePosition = rayPosition;
        currentDistance = max(length(samplePosition), 1e-4);
        
        vec3 domainWarped = vec3(
            log(currentDistance) - iTime * 0.7,
            exp(-samplePosition.z / currentDistance) + 0.23,
            atan(samplePosition.y, samplePosition.x)
        );
        
        domainWarped.y -= 1.0;
        density = domainWarped.y;

        for (; octaveFrequency < 1603.0; octaveFrequency += octaveFrequency) {
            vec3 harmonicPositionX = domainWarped.zxx * octaveFrequency;
            vec3 harmonicPositionY = domainWarped.yzy * octaveFrequency;
            
            density += dot(sin(harmonicPositionX), 0.9 - cos(harmonicPositionY)) / octaveFrequency * 0.28;
        }
    }

    fragColor = vec4(accumulatedColor, 1.0);
}
*/
