// ==== Image (image) ====
// variant of https://shadertoy.com/view/7cdGRf

 
#define H(D)  fract(1e3*sin(1e3*D*mat2(R,79.-R)))   // hash

void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy,
         U = 10.*( u+u - R ) / R.y, D, P;     // normalized coordinates
    float l = 1.;
    
    for (int k; k<25; k++ ) {                 // check closest in 3x3 neighborhood
        P = floor(U) + vec2(k%5,k/5)-2.;      // neighbor cell id
        D = U-P - H(P);                       // distance to seed point
        l = min(l, length( ( D * mat2(cos( .3*length(P) + iTime + vec4(0,11,33,0)))) / vec2(10,1) )); // elliptic distance
    }
    O = vec4(1.-l);
}
