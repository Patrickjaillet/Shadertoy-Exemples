// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
// https://x.com/JailletPatrick

/* GOLFED VERSION */
void mainImage(out vec4 o, vec2 u){
    vec2 R = iResolution.xy;
    float t = iTime, a = 8., d;
    vec3 b = vec3((u+u - R)/R.y * (1. + sin(t*.3)) * -4.75, cos(t*.4)),
         c = vec3(log(d = length(b)), exp(-b.y/d), atan(b.x, b.z));
    
    for(d = c.y - 1.; a < 1e3; a *= 2.)
        d -= abs(dot(sin(c.yzx*a), 1. - cos(c*a))) / a * .6;

    o = vec4(smoothstep(0., 1., abs(d)*5.));
    o.a = 0.;
}
/* ORIGINAL
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    float time = iTime;
    
    vec2 normalizedCoord = (fragCoord * 2.0 - resolution) / resolution.y;
    float zoomFactor = (1.0 + sin(time * 0.3)) * -4.75;
    
    vec3 rayVector = vec3(normalizedCoord * zoomFactor, cos(time * 0.4));
    float vectorLength = length(rayVector);
    
    vec3 transformedCoords = vec3(
        log(vectorLength),
        exp(-rayVector.y / vectorLength),
        atan(rayVector.x, rayVector.z)
    );
    
    float accumDistance = transformedCoords.y - 1.0;
    
    for (float frequency = 8.0; frequency < 1000.0; frequency *= 2.0) {
        vec3 sineComponent = sin(transformedCoords.yzx * frequency);
        vec3 cosineComponent = 1.0 - cos(transformedCoords * frequency);
        accumDistance -= abs(dot(sineComponent, cosineComponent)) / frequency * 0.6;
    }
    
    fragColor = vec4(vec3(smoothstep(0.0, 1.0, abs(accumDistance) * 5.0)), 0.0);
}
*/
