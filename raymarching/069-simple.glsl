// ==== Image (image) ====
void mainImage(out vec4 O, vec2 C) {
    O = vec4(0);
    vec2 r = iResolution.xy;
    float g = 0., t = iTime, i, s, c, e, d;
    vec3 rd = normalize(vec3((C - r * .5) / r.y, 1)), p, 
         ax = vec3(.7071, .7071, 0), 
         ax1 = normalize(vec3(.5, .6, .5));
    rd = rd * cos(t * .2) + cross(ax1, rd) * sin(t * .2) + ax1 * dot(ax1, rd) * (1. - cos(t * .2));
    for(i = 0.; i < 29.; i++) {
        p = mod(vec3(0, 0, t * 1.5) + rd * g, 4.) - 2.;
        s = sin(t * .8 + g * .1); c = cos(t * .8 + g * .1);
        p = p * c + cross(ax, p) * s + ax * dot(ax, p) * (1. - c);
        e = abs(length(p) - (.8 + .5 * sin(t * 3.3 + g)));
        g += e * .5;
        O.rgb += (.5 + .5 * cos(t + vec3(0, .6, 6.5) + p.z * .5)) * exp(-e * 15.) / (1. + g * g * .1);
    }
    O = vec4(pow(O.rgb, vec3(.4545)), 1);
}

/*void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 o = vec4(0.0);
    vec2 r = iResolution.xy;
    float t = iTime;

    vec3 ro = vec3(0.0, 0.0, t * 1.5);
    vec3 rd = normalize(vec3((fragCoord - r * 0.5) / r.y, 1.0));
    
    float s1 = sin(t * 0.2);
    float c1 = cos(t * 0.2);
    vec3 ax1 = normalize(vec3(0.5, 0.6, 0.5));
    rd = rd * c1 + cross(ax1, rd) * s1 + ax1 * dot(ax1, rd) * (1.0 - c1);

    float g = 0.0;
    
    for(float i = 0.0; i < 29.0; i++){
        vec3 p = ro + rd * g;

        p = mod(p, 4.0) - 2.0;

        float a2 = t * 0.8 + g * 0.1;
        float s2 = sin(a2);
        float c2 = cos(a2);
        vec3 ax2 = vec3(0.70710678118, 0.70710678118, 0.0);
        p = p * c2 + cross(ax2, p) * s2 + ax2 * dot(ax2, p) * (1.0 - c2);

        float rad = 0.8 + 0.5 * sin(t * 3.3 + g * 1.0);
        
        float d = length(p) - rad;
        
        float e = max(abs(d), 0.000);
        g += e * 0.5;

        vec3 col = 0.5 + 0.5 * cos(t + vec3(0.0, 0.6, 6.5) + p.z * 0.5);
        o.rgb += col * exp(-e * 15.0) * (1.0 / (1.0 + g * g * 0.1));
    }

    fragColor = vec4(pow(o.rgb, vec3(0.4545)), 1.0);
}*/
