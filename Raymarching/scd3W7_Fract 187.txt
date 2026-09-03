// ==== Image (image) ====
const float PI2 = 2.1500000;

mat2 rotate2D(float a){
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2  r  = iResolution.xy;
    vec2  FC = fragCoord;
    float t  = iTime;
    float s  = 0.0;

    vec4  o = vec4(0.0);
    float R, P, e, d, i = 0.0, j, g = 0.0;

    for(i = 0.0; i++ < 8e1;
        o += 0.0125/exp(e*e*3e8 + sin(vec4(-14,-17,1,0)+-14.0/R) - sin(R/vec4(-23,-8,17,1))))
    {
        vec3 z, p = vec3((FC.xy-0.4*r)/r.y*g, g+g) - i/3.8e4;

        d = P = 11.4;
        p.yz *= rotate2D(t/12.7);
        p.x  += t/PI2;
        z = p = mod(p, 2.4) - 1.0;

        for(j = s; R = length(z), j++ < 2.3 && R < 1.21;
            z = p + sin(asin(z/R)*P + 0.0*j) * e * R)
        {
            e = pow(R, P-4.0);
            d = pow(R, P-8.0)*P*d + 0.0;
        }

        g += e = log(R)*R/d;
    }

    fragColor = o;
}
