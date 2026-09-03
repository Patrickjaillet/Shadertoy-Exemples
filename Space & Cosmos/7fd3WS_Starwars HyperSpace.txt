// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software

const float z=3.1415927e0;
mat2 A(float g){
    float a=cos(g);
    float c=sin(g);
    return mat2(a,-c,c,a);
}
float b(float a){
    return fract(sin(a*127.1)*43758.5453);
}
void mainImage(out vec4 B,in vec2 C){
    vec2 n=iResolution.xy;
    float i=iTime;
    vec2 e=(C.xy-.5*n)/n.y;
    e*=A(.05*sin(i*.3));
    float o=length(e);
    float D=15.;
    float c=mod(i,D);
    float E=1.-smoothstep(6.,7.4,c);
    float F=smoothstep(6.,7.4,c)*(1.-smoothstep(7.4,8.8,c));
    float j=smoothstep(7.,8.6,c)*(1.-smoothstep(13.2,14.6,c));
    float h=smoothstep(6.,8.6,c);
    vec3 d=vec3(.01,.02,.05);
    d+=vec3(.15,.35,.9)*exp(-o*3.5)*.6*j;
    d+=vec3(.4,.6,1.)*exp(-o*12.)*(.04+.96*j);
    for(float k=0.;k<220.;k++){
        float a=k*1.113;
        vec2 p=(vec2(b(a),b(a+3.))-.5)*2.6;
        float q=length(p);
        vec2 l=p/max(q,1e-3);
        float r=q+h*h*2.6;
        float G=.005+h*.9;
        float s=dot(e,l);
        float H=dot(e,vec2(-l.y,l.x));
        float I=smoothstep(.0035+h*.01,0.,abs(H));
        float t=(r-s)/G;
        float J=clamp(1.-t,0.,1.)*step(0.,t)*step(s,r);
        float K=.6+.4*sin(i*3.+a*40.);
        vec3 L=mix(vec3(.6,.8,1.),vec3(1.,1.,1.),b(a+7.));
        d+=I*J*K*L*max(E,F)*1.5;
        float g=b(a)*2.*z;
        float M=.5+b(a+2.);
        float f=fract(b(a+5.)+(c-7.)*M*.5);
        float u=f*f*2.2;
        float N=.12+f*.8;
        vec2 m=vec2(cos(g),sin(g));
        float v=dot(e,m);
        float O=dot(e,vec2(-m.y,m.x));
        float line=smoothstep(.003+f*.012,0.,abs(O));
        float w=(u-v)/N;
        float P=clamp(1.-w,0.,1.)*step(0.,w)*step(v,u);
        float Q=smoothstep(0.,.12,f);
        float R=smoothstep(1.,.75,f);
        vec3 S=mix(vec3(.55,.75,1.),vec3(1.,1.,1.),b(a+7.));
        d+=line*P*Q*R*S*j*1.3;
    }
    d=pow(d,vec3(.85));
    B=vec4(d,1.);
}

// ==== Sound (sound) ====
// https://patrickjaillet.github.io/sandefjord-software

float hash(float n) {
    return fract(sin(n * 127.1) * 43758.5453);
}

float noise(float p) {
    float fl = floor(p);
    float fr = fract(p);
    return mix(hash(fl), hash(fl + 1.0), smoothstep(0.0, 1.0, fr));
}

vec2 mainSound(in int samples, float time) {
    float c = mod(time, 15.0);
    
    float enginePrep = smoothstep(0.0, 6.0, c) * (1.0 - smoothstep(6.0, 6.5, c));
    float hyperJump = smoothstep(6.0, 7.4, c) * (1.0 - smoothstep(13.2, 14.6, c));
    float tunnelSteady = smoothstep(7.4, 13.2, c) * (1.0 - smoothstep(13.2, 14.8, c));
    
    float sound = 0.0;
    
    if (c < 6.5) {
        float rff = 25.0 + pow(c / 6.0, 3.0) * 55.0;
        float rpm = sin(6.2831 * rff * c + 1.5 * sin(6.2831 * 8.0 * c));
        float subLow = sin(6.2831 * 32.0 * c + 0.5 * noise(c * 120.0));
        float engineNoise = noise(c * 8000.0) * (0.15 + 0.35 * noise(c * 15.0));
        
        float cutoff = 150.0 + pow(c / 6.0, 4.0) * 1200.0;
        float nMod = noise(c * cutoff);
        
        sound += (rpm * 0.4 + subLow * 0.5 + engineNoise * 0.3 + nMod * 0.4) * enginePrep;
    }
    
    if (c >= 6.0 && c < 14.8) {
        float jumpProgress = smoothstep(6.0, 8.6, c);
        
        float flashFreq = 800.0 - smoothstep(6.0, 6.5, c) * 600.0;
        float flashInt = exp(-(c - 6.0) * 8.0) * sin(6.2831 * flashFreq * (c - 6.0));
        
        float rumbleFreq = 35.0 + jumpProgress * 25.0;
        float rumble = sin(6.2831 * rumbleFreq * c + noise(c * 90.0) * 4.0);
        
        float screamFreq = 1200.0 + pow(jumpProgress, 2.0) * 2200.0;
        float scream = sin(6.2831 * screamFreq * c + sin(6.2831 * 140.0 * c) * 0.3);
        
        float whiss = noise(c * 12000.0);
        float wFilter = noise(c * (2000.0 + jumpProgress * 5000.0));
        
        sound += flashInt * 0.7;
        sound += (rumble * 0.45 + scream * 0.15 + wFilter * 0.25) * hyperJump;
        sound += (sin(6.2831 * 3400.0 * c) * 0.04 + rumble * 0.3 + whiss * 0.1) * tunnelSteady;
    }
    
    sound = clamp(sound, -1.0, 1.0);
    return vec2(sound);
}
