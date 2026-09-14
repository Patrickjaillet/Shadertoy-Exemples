// ==== Image (image) ====
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù                       PATRICK JAILLET                        ù
ù - https://patrickjaillet.github.io/sandefjord-software       ù
ù - https://x.com/JailletPatrick                               ù
ù - https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/
void mainImage(out vec4 c, vec2 u){
    vec3 R = iResolution;
    u = (u - 0.5 * R.xy) / R.y;
    
    float zoom = 1.0 + 0.5 * sin(iTime * 1.5);
    u *= zoom;
    
    float a = atan(u.y, u.x);
    float d = length(u);
    
    vec2 p = u + vec2(sin(a * 4.0 + iTime * 3.0) * 0.05, cos(a * 5.0 - iTime * 4.0) * 0.05);
    float d2 = length(p);
    
    vec3 col = 0.5 + 0.5 * cos(vec3(0.0, 1.0, 2.0) + a + d2 * 4.0 - iTime * 2.0);
    
    c = vec4(col * (1.0 - u.y), 1.0) * step(0.0, sin(d2 * 60.0 - iTime * 8.0 + a * 3.0));
}
/* GOLFED ORIGINAL
void mainImage(out vec4 c, vec2 u){
    vec3 R = iResolution;
    u = (u - 0.5 * R.xy) / R.y;
    c = vec4(1.0 - u.y) * step(length(u), sin(length(u) * 3e2 * iTime));
}*/

/* ORIGINAL CODE
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 resolution = iResolution.xy;
    
    vec2 normalizedCoord = (fragCoord - 0.5 * resolution) / resolution.y;
    
    float radialDistance = length(normalizedCoord);
    
    float waveFrequency = 300.0;
    float temporalFactor = iTime;
    
    float waveFunction = sin(radialDistance * waveFrequency * temporalFactor);
    
    float pixelWidth = fwidth(radialDistance);
    float boundaryMask = smoothstep(0.0, pixelWidth * 2.0, waveFunction - radialDistance);
    
    vec3 baseGradient = vec3(1.0 - normalizedCoord.y);
    
    vec3 finalColorRGB = baseGradient * boundaryMask;
    
    fragColor = vec4(finalColorRGB, 1.0);
}
*/
