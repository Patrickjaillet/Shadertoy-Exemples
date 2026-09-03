// ==== Image (image) ====
#define FAR 20.

#define PI 3.14159265358979
#define TAU 6.28318530718

mat2 r2(in float a){ float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

float hash31(vec3 p){
    float n = dot(p, vec3(13.163, 157.247, 7.951)); 
    return fract(sin(mod(n, 6.2831))*43758.5453); 
}

float smax(float a, float b, float s){
    float h = clamp( 0.5 + 0.5*(a-b)/s, 0., 1.);
    return mix(b, a, h) + h*(1.0-h)*s;
}

vec3 tex3D(sampler2D tex, in vec3 p, in vec3 n){    
    n = max(n*n - .2, .001);
    n /= dot(n, vec3(1)); 
    
    vec3 tx = texture(tex, p.zy).xyz;
    vec3 ty = texture(tex, p.xz).xyz;
    vec3 tz = texture(tex, p.xy).xyz;
    
    return mat3(tx*tx, ty*ty, tz*tz)*n;
} 

vec3 gP;
float gSc;

float Apollonian3D(vec3 p){
    float scale = 1., r;
    float d = 1e5;
    
    for(int i = 0; i<4; i++) {
        p = mod(p - 1., 2.) - 1.;
        r = dot(p, p)*.75;
        p /= r;
        scale /= r;
        if(i<=3){ gP = p; gSc = scale; }
    }
    
    return .25*min(abs(p.y), length(p.xz))/scale - .0015;
}

vec3 glow;
int gFlS = 0;

float m(vec3 p) {
    float fl = p.y + .015;
    float d = Apollonian3D(p);
    float ball = length(mod(p - 1., 2.) - 1.) - .175;

    float sD = d;
    float lnN = 10.;
    float le = length(gP)/sqrt(3.);

    float pat = smoothstep(0., .02, (abs(fract(le*lnN + .5) - .5) - .5*.33)/lnN);
    d -= pat*.01/gSc;

    gFlS = pat==0.? 0 : 1;

    if(ball<d + .5) glow += vec3(1, .08, .02)*.02/(.01 + ball*ball*128.);

    d = min(d, ball);
    return d;
}

vec3 nr(in vec3 p) {
    float sgn = 1.;
    vec3 e = vec3(.001, 0, 0), mp = e.zzz;
    for(int i = min(iFrame, 0); i<6; i++){
        mp.x += m(p + sgn*e)*sgn;
        sgn = -sgn;
        if((i&1)==1){ mp = mp.yzx; e = e.zxy; }
    }
    return normalize(mp);
}

float softShadow(vec3 ro, vec3 rd, vec3 n, float lDist, float k){
    float shade = 1.;
    float t = 0.;
    
    ro += n*.0015 + rd*hash31(ro + rd + n)*.005;

    for (int i = min(0, iFrame); i<64; i++){
        float d = m(ro + rd*t);
        shade = min(shade, k*d/t);
        if (d<0. || t>lDist) break;        
        t += clamp(d, .01, .15); 
    }

    return max(shade, 0.); 
}

float calcAO(in vec3 p, in vec3 n){
    float sca = 2., occ = 0.;
    for( int i = 0; i<5; i++ ){
        float hr = float(i + 1)*.2/5.;        
        float d = m(p + n*hr);
        occ += (hr - d)*sca;
        sca *= .75;
    }
    return clamp(1. - occ, 0., 1.);  
}

float curve(in vec3 p, in float spr, in float amp, in float offs){
    spr /= 450.;
    float sgn = 1.;
    vec3 e = vec3(spr, 0, 0); 
    float d = -m(p)*6.;
    for(int i = min(iFrame, 0); i<6; i++){
        d += m(p + sgn*e);
        sgn = -sgn;
        if((i&1)==1){ e = e.zxy; }
    }
    return clamp(d/e.x/e.x*amp/16. + offs, -1., 1.)*.5 + .5;
}

float trace(in vec3 ro, in vec3 rd){
    glow = vec3(0);    
    float d, t = hash31(fract(ro*89.567)*7. + rd)*.5;
    
    for(int i = min(0, iFrame); i<160; i++){
        d = m(ro + rd*t);
        if(abs(d)<.001 || t>FAR) break;
        t += min(d*.8, .2);
    }

    return min(t, FAR);
}

vec3 getSpec(vec3 F0, float nh, float nr, float nl, float rough) {
    float a = rough * rough;
    float a2 = a * a;
    float d = (nh * a2 - nh) * nh + 1.0;
    float D = a2 / (PI * d * d + 1e-5);
    
    float k = (rough + 1.0) * (rough + 1.0) / 8.0;
    float G1L = nl / (nl * (1.0 - k) + k);
    float G1V = nr / (nr * (1.0 - k) + k);
    float G = G1L * G1V;
    
    return (D * G * F0) / max(4.0 * nl * nr, 0.001);
}

vec3 getDiff(vec3 F0, float nl, float rough, float metallic) {
    vec3 kD = (vec3(1.0) - F0) * (1.0 - metallic);
    return kD * nl / PI;
}

void mainImage(out vec4 fCol, vec2 fCoor){
    vec2 uv = (fCoor - iResolution.xy*.5)/iResolution.y;

    float tm = iTime/2. + 5.48;
    vec3 r = normalize(vec3(uv, 1)), 
         o = vec3(0, .5 + sin(tm)*.15, -1);
         o.xz = r2(tm)*o.xz;        
    vec3 l = vec3(0, 1, -1);
    l.xz = r2(tm)*l.xz;
    
    r.yz *= r2(-.35);
    r.xz *= r2(-tm);
    r.xy *= r2(-.25);

    float t = trace(o, r);

    vec3 c = vec3(0);
    int flS = gFlS;    
    vec3 svP = gP;
    vec3 svGlow = glow;
      
    if(t<FAR){
        vec3 p = o + r*t, n = nr(p);

        l -= p;
        float lDist = max(length(l), 0.001);
        l /= lDist;
        
        float atten = 1./(1. + lDist*lDist*.25);
            
        float ao = calcAO(p, n);
        float sh = softShadow(p, l, n, lDist, 12.); 
         
        float spr = 2.5, ampC = 1., offs = .0;
        float crv = curve(p, spr, ampC, offs);
        
        svGlow = glow; 
        
        vec3 tx = tex3D(iChannel0, p, n);
        float gr = dot(tx, vec3(.299, .587, .114));

        c = vec3(.66);
        if(flS==0) c *= .4;
        c *= tx;
        
        float fresRef = .7;
        float type = .9;
        float rough = min(gr*2., 1.);
        
        vec3 h = normalize(l - r);
        float ndl = dot(n, l);
        float nrVal = clamp(dot(n, -r), 0., 1.);
        float nl = clamp(ndl, 0., 1.);
        float nh = clamp(dot(n, h), 0., 1.);
        float vh = clamp(dot(-r, h), 0., 1.);  

        vec3 f0 = vec3(.16*(fresRef*fresRef)); 
        f0 = mix(f0, c, type);
        vec3 FS = f0 + (1. - f0)*pow(1. - vh, 5.);
        
        vec3 spec = getSpec(FS, nh, nrVal, nl, rough);
        vec3 diff = getDiff(FS, nl, rough, type);
       
        float amb = length(sin(n*2.)*.5 + .5)/sqrt(3.)*smoothstep(-1., 1., n.y); 
        
        float bl = max(dot(-normalize(vec3(l.x, 0, l.z)), n), 0.);
        c = c + c*vec3(1, .4, .2)*bl*8.;
        
        c = c*(diff*sh + spec*sh*8. + amb*(sh*.5 + .5)*.3);
        c *= crv*1.33 + .333;
        c *= ao*atten;

    }
    
    svGlow = mix(svGlow, svGlow.yzx, smoothstep(0., .7, r.y)*.2);
    c += (c*4. + .5)*svGlow;
    
    c = mix(c, vec3(0), smoothstep(0., .9, t/FAR));
    
    c = sqrt(max(c, 0.));
    
    fCol = vec4(c, t);    
}
