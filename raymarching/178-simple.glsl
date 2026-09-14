
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
