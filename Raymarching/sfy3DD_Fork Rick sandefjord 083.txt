// ==== Image (image) ====
// The completed Rick shader from my article 
// https://danielchasehooper.com/posts/code-animated-rick/
// Written for readability, not size or speed

vec2 rotateAt(vec2 p, float angle, vec2 origin) {
    float s = sin(angle), c = cos(angle);
    return (p-origin)*mat2( c, -s, s, c ) + origin;
}
float map(float value, float inMin, float inMax, float outMin, float outMax) {
  value = clamp(value, inMin, inMax);
  return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}
vec2 grad(ivec2 z)  {
    int n = z.x+z.y*11111;
    n = (n<<13)^n;
    n = (n*(n*n*15731+789221)+1376312589)>>16;
    n &= 7;
    vec2 gr = vec2(n&1,n>>1)*2.0-1.0;
    return ( n>=6 ) ? vec2(0.0,gr.x) : 
           ( n>=4 ) ? vec2(gr.x,0.0) :
                              gr;                            
}
float noise(vec2 p) {
    ivec2 i = ivec2(floor(p));
    vec2  f =       fract(p);
    vec2 u = f*f*(3.0-2.0*f); 
    return mix( mix( dot( grad( i+ivec2(0,0) ), f-vec2(0.0,0.0) ), 
                     dot( grad( i+ivec2(1,0) ), f-vec2(1.0,0.0) ), u.x),
                mix( dot( grad( i+ivec2(0,1) ), f-vec2(0.0,1.0) ), 
                     dot( grad( i+ivec2(1,1) ), f-vec2(1.0,1.0) ), u.x), u.y);
}
vec2 warp(vec2 p, float scale, float strength) {
    float offsetX = noise(p * scale + vec2(0.0, 100.0));
    float offsetY = noise(p * scale + vec2(100.0, 0.0));
    return p + vec2(offsetX, offsetY) * strength;
}
float bezier(vec2 p, vec2 v0, vec2 v1, vec2 v2) {
    vec2 i = v0 - v2;
    vec2 j = v2 - v1;
    vec2 k = v1 - v0;
    vec2 w = j-k;

    v0-= p; v1-= p; v2-= p;
    
    float x = v0.x*v2.y-v0.y*v2.x;
    float y = v1.x*v0.y-v1.y*v0.x;
    float z = v2.x*v1.y-v2.y*v1.x;

    vec2 s = 2.0*(y*j+z*k)-x*i;

    float r =  (y*z-x*x*0.25)/dot(s,s);
    float t = clamp( (0.5*x+y+r*dot(s,w))/(x+y+z),0.0,1.0);
    
    vec2 d = v0+t*(k+k+t*w);
    vec2 outQ = d + p;
    return length(d);
}
float parabola(vec2 pos, float k) {
    // from https://www.shadertoy.com/view/ws3GD7
    pos.x = abs(pos.x);
    float ik = 1.0/k;
    float p = ik*(pos.y - 0.5*ik)/3.0;
    float q = 0.25*ik*ik*pos.x;
    float h = q*q - p*p*p;
    float r = sqrt(abs(h));
    float x = (h>0.0) ? 
        pow(q+r,1.0/3.0) - pow(abs(q-r),1.0/3.0)*sign(r-q) :
        2.0*cos(atan(r,q)/3.0)*sqrt(p);
    return length(pos-vec2(x,k*x*x)) * sign(pos.x-x);
}
float round_rect(vec2 p, vec2 b, vec4 r) {
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}
float star(vec2 p, float r, float points, float ratio) {
    float an = 3.141593/points;
    float en = 3.141593/(ratio*(points-2.) + 2.); 
    vec2  acs = vec2(cos(an),sin(an));
    vec2  ecs = vec2(cos(en),sin(en));

    float bn = mod(atan(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return length(p)*sign(p.x);
}
#define H(i,j) fract(sin(dot(ceil(P+vec2(i,j)), iResolution.xy )) * 4e3)
float N( vec2 P) {
    float s,i,w = .5;
    for (; i < 3. ; i++, w *= .4, P *= 1.9 ) {
        vec2 F = fract( P *= mat2(.866,-.5,.5,.866) ); 
        F *= F*(3.-F-F);
        s += w* mix( mix(H(0,0) , H(1,0), F.x),
                     mix(H(0,1) , H(1,1), F.x),
                     F.y );
    }
    return s;
}
vec3 portal(vec2 pixel, float time) {
    // from https://www.shadertoy.com/view/l3f3zM
    float l = length( pixel ), 
          a = atan(pixel.y, pixel.x) / 6.28 + .5,
          k = 10.;
     
    a = fract(a + l*.3 - time*.01 );
    vec2 U = vec2( l+time*.3, a );
     
    return vec3[]( vec3(.18, .53, .09),
                    vec3(.56, .89, .16),
                    vec3(.35, .84, .11),
                    vec3(.92, .98, .85)
                  ) [ int( 4.* pow( mix( N(U*k), N(U*k-vec2(0,k)), U.y) * 1.5, 2.5))];
}

vec3 color_for_pixel(vec2 pixel, float time) { 
    
    // rotate the whole drawing
    pixel = rotateAt(pixel, sin(time*2.)*.1, vec2(0,-.6));
    pixel.y += .1;


    // Blink eyes
    if (mod(time, 2.) > 1.91) {
        // closed eyes
        float d = round_rect(pixel+vec2(.07,-.16), vec2(.24,0), vec4(0));
        if (d < .008) return vec3(0);      
    } 
    else { 
        // move pupils randomly
        vec2 pupil_warp = pixel + vec2(.095,-.18);
        pupil_warp.x -= noise(vec2(round(time)*7.+.5, 0.5))*.1;
        pupil_warp.y -= noise(vec2(round(time)*9.+.5, 0.5))*.1;
        pupil_warp.x = abs(pupil_warp.x) - .16;
        float d = star(pupil_warp, 0.019, 6., .9);
        if (d < 0.007) {
            return vec3(.1);
        }

        // Eyeballs
        vec2 eye = vec2(abs(pixel.x+.1)-.17, pixel.y*.93 - .16);
        d = length(eye) - .16;
        if (d < 0.) return vec3(step(.013, -d));

        // under eye lines
        bool should_show = pixel.y < 0.25 && 
        (abs(pixel.x+.29) < .05 || 
         abs(pixel.x-.12) < .085);
        if (abs(d - .04) < .0055 && should_show) return vec3(0);
    }


    // Mouth
    float d = bezier(pixel,  
                     vec2(-.26, -.28), 
                     vec2(-.05,-.42), 
                     vec2(.115, -.25));
    if (d < .11) {
        // Teeth
        float width = .065;
        vec2 teeth = pixel;
        teeth.x = mod(teeth.x, width)-width*.5;
        teeth.y -= pow(pixel.x+.09, 2.) * 1.5 - .34;
        teeth.y = abs(teeth.y)-.06;
        d = parabola(teeth, 38.);
        if (d < 0. && abs(pixel.x+.06) < .194) 
        return vec3(0.902, 0.890, 0.729)*step(d, -.01);

        // Tongue
        // `map()` is used to change the thickness of 
        // the tongue along the x axis
        vec2 tongue = rotateAt(pixel, sin(time*2.-1.5)*.15+.1, vec2(0,-.5));
        float tongue_thickness = map(tongue.x, -.16, .01, .02, .045);
        d = bezier(tongue,  
                   vec2(-.16, -.35), 
                   vec2(.001,-.33), 
                   vec2(.01, -.5)) - tongue_thickness;
        if (d < 0.0) 
        return vec3(0.816, 0.302, 0.275)*step(d, -0.01);

        // mouth fill color
        return vec3(.42, .147, .152); 
    } 

    // lip outlines
    if (d < .12 || (abs(d-.16) < .005 
                    && (pixel.x*-6.4 > -pixel.y+1.6 
                        || pixel.x*1.7 > -pixel.y+.1 
                        || pixel.y < -0.49))) 
    return vec3(0); 

    // lips
    if (d < .16) return vec3(.838, .799, 0.76);



    // Nose  
    d = min(
            bezier(pixel, 
                   vec2(-.15, -.13), 
                   vec2(-.21,-.14), 
                   vec2(-.14, .08)),
            bezier(pixel, 
                   vec2(-.085, -.01), 
                   vec2(-.12, -.13),
                   vec2(-.15,-.13)));
    if (d < 0.0055) return vec3(0);


    // Eyebrow
    d = bezier(pixel,  
               vec2(-.34, .38), 
               // NEW animate the middle up and down
               vec2(-.05, 0.5 + cos(time)*.1),
               vec2(.205, .36)) - 0.035;
    if (d < 0.0) 
    return vec3(.71, .839, .922)*step(d, -.013);

    d = min(
            // Head
            round_rect(
                       pixel, 
                       vec2(.36, .6385), 
                       vec4(.34, .415, .363, .315)),

            // Ear
            round_rect(
                       pixel + vec2(-.32, .15), 
                       vec2(.15, 0.12), 
                       vec4(.13,.1,.13,.13))
            );

    if (d < 0.) return vec3(.838, .799, .76)*step(d, -.01);


    // Hair     
    float twist = sin(time*2.-length(pixel)*2.1)*.12;
    vec2 hair = rotateAt(pixel, twist, vec2(0.,.1));
    hair -= vec2(.08,.15);
    hair.x *= 1.3;
    hair = warp(hair, 4.0, 0.07);
    d = star(hair, 0.95, 11., .28);
    if (d < 0.) {
        return vec3(0.682, 0.839, 0.929)*step(d, -0.012);
    }
    
    return portal(pixel, time);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {    
    int sample_count = 3;     
    vec3 sum = vec3(0);
    for( int m=0; m<sample_count; m++ ) {
        for( int n=0; n<sample_count; n++ ) {
            vec2 o = (vec2(m,n) + 0.5) / float(sample_count);
            vec2 st = (2.0*(gl_FragCoord.xy+o)-iResolution.xy)/iResolution.y;
            sum += color_for_pixel(st, iTime);
        }
    }

    fragColor = vec4(sum / float(sample_count*sample_count), 1); 
}
