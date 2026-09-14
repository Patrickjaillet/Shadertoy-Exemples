
#define H(D)  fract(1e3*sin(1e3*D*mat2(R,79.-R)))

void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy,
         U = 10.*( u+u - R ) / R.y, D, P;
    float l = 1.;

    for (int k; k<25; k++ ) {
        P = floor(U) + vec2(k%5,k/5)-2.;
        D = U-P - H(P);
        l = min(l, length( ( D * mat2(cos( .3*length(P) + iTime + vec4(0,11,33,0)))) / vec2(10,1) ));
    }
    O = vec4(1.-l);
}
