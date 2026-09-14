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
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/

void mainImage(out vec4 a,vec2 b){
    vec3 c=iResolution,p;
    for(float e,g,d;e++<99.;a+=vec4(1,.5,1,1)*exp(-d*6.)){
        a=e<2.?vec4(0):a,p=vec3((b+b-c.xy)/c.y*g,g-3.),p.xz*=mat2(cos(iTime*.4+vec4(0,11,33,0))),p.yz*=mat2(cos(iTime*.2+vec4(0,11,33,0)));
        g+=max(abs(d=length(cos(p)+sin(p.zxy))-.6)*.2,.02);
    }
    a=tanh(a*.03);
}
/* ORIGINAL VERSION
void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    vec3 colorAccumulator = vec3(0.0);
    float rayDistance = 0.0;
    
    float angleXZ = iTime * 0.4;
    float sinXZ = sin(angleXZ);
    float cosXZ = cos(angleXZ);
    mat2 rotXZ = mat2(cosXZ, -sinXZ, sinXZ, cosXZ);
    
    float angleYZ = iTime * 0.2;
    float sinYZ = sin(angleYZ);
    float cosYZ = cos(angleYZ);
    mat2 rotYZ = mat2(cosYZ, -sinYZ, sinYZ, cosYZ);
    
    const float maxSteps = 99.0;
    const vec3 glowColor = vec3(1.0, 0.5, 1.0);
    
    for (float stepIndex = 0.0; stepIndex < maxSteps; stepIndex++) {
        vec3 p = vec3(uv * rayDistance, rayDistance - 3.0);
        
        p.xz *= rotXZ;
        p.yz *= rotYZ;
        
        float distanceToSurface = length(cos(p) + sin(p.zxy)) - 0.6;
        
        colorAccumulator += glowColor * exp(-distanceToSurface * 6.0);
        
        rayDistance += max(abs(distanceToSurface) * 0.2, 0.02);
    }
    
    vec3 finalColor = tanh(colorAccumulator * 0.03);
    
    fragColor = vec4(finalColor, 1.0);
}
*/
