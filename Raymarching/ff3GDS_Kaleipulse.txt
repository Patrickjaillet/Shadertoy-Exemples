// ==== Image (image) ====
/* GOLFED CODE
void mainImage(out vec4 b,vec2 p){
    vec2 m=iResolution.xy,n=(p-.5*m)/m.y;
    b=vec4(0.);
    float r=iTime*.15,g=sin(iTime*2.5)*.5+.5,d=sin(iTime*8.+cos(iTime*4.))*.5+.5,h=mix(g,d,.35),j=0.,i=0.,e,v,q;
    for(;i++<110.&&j<14.;){
        vec3 a=vec3(n.x,11.-j,n.y);
        float o=r+g*.04,s=sin(o),c=cos(o);
        a.xz*=mat2(c,-s,s,c);
        e=.3;
        v=1.6+h*.25;
        for(int f=0;f<11;f++){
            q=dot(a,a)+8e-4;
            v/=q;
            a/=q;
            a.y=(1.8+d*.08)-a.y;
            if(f>3){
                float t=sin(float(f)*1.5+iTime*5.)*.5+.5;
                e=min(e,length(a.xz)/v-(.004+t*.005));
                a.xz=abs(a.xz)-(.2+h*.03);
            }
            else a=abs(a)-(.23+g*.02);
        }
        j+=max(e,8e-4);
        vec3 k=vec3(.25-log(v)*.65+h*.1,.85+d*.15,1.),K=vec3(1.,.33333,.66667),rgb=k.z*mix(K.xxx,clamp(abs(fract(k.xxx+vec3(0.,K.yz))*6.-3.)-K.xxx,0.,1.),k.y);
        float u=.025*exp(-e*(180.-d*40.));
        b.rgb+=rgb*u*(1.+d*.5);
    }
    vec3 l=b.rgb/(1.+b.rgb);
    l=pow(l,vec3(.4545));
    b=vec4(l,1.);
}
*/
void mainImage(out vec4 O, vec2 C) {
    vec2 r = iResolution.xy;
    vec2 u = (C - 0.5 * r) / r.y;
    O = vec4(0.0);
    
    float t = iTime * 0.15;
    float pulseBase = sin(iTime * 2.5) * 0.5 + 0.5;
    float pulseFast = sin(iTime * 8.0 + cos(iTime * 4.0)) * 0.5 + 0.5;
    float pulseComplex = mix(pulseBase, pulseFast, 0.35);
    
    float g = 0.0, i = 0.0, e, v, q;
    for (; i++ < 110.0 && g < 14.0;) {
        vec3 p = vec3(u.x, 11.0 - g, u.y);
        float a = t + pulseBase * 0.04, s = sin(a), c = cos(a);
        p.xz *= mat2(c, -s, s, c);
        
        e = 0.3;
        v = 1.6 + pulseComplex * 0.25;
        
        for (int j = 0; j < 11; j++) {
            q = dot(p, p) + 0.0008;
            v /= q;
            p /= q;
            p.y = (1.8 + pulseFast * 0.08) - p.y;
            
            if (j > 3) {
                float pulseMod = sin(float(j) * 1.5 + iTime * 5.0) * 0.5 + 0.5;
                e = min(e, length(p.xz) / v - (0.004 + pulseMod * 0.005));
                p.xz = abs(p.xz) - (0.2 + pulseComplex * 0.03);
            } else {
                p = abs(p) - (0.23 + pulseBase * 0.02);
            }
        }
        
        g += max(e, 0.0008);
        
        vec3 h = vec3(0.25 - log(v) * 0.65 + pulseComplex * 0.1, 0.85 + pulseFast * 0.15, 1.0),
             K = vec3(1.0, 0.33333, 0.66667),
             rgb = h.z * mix(K.xxx, clamp(abs(fract(h.xxx + vec3(0.0, K.yz)) * 6.0 - 3.0) - K.xxx, 0.0, 1.0), h.y);
             
        float accum = 0.025 * exp(-e * (180.0 - pulseFast * 40.0));
        O.rgb += rgb * accum * (1.0 + pulseFast * 0.5);
    }
    
    vec3 color = O.rgb / (1.0 + O.rgb);
    color = pow(color, vec3(0.4545));
    O = vec4(color, 1.0);
}
