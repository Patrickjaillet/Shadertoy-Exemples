// ==== Image (image) ====
void mainImage(out vec4 ab,in vec2 ac){
  vec2 l=iResolution.xy;
  if(l.y<1.)l.y=1080.;
  if(l.x<1.)l.x=1920.;
  float e=iTime,C=e*.15,ad=sin(C)*cos(C*.6)*1.5,h=e*1.+(sin(e*.8)*.8+.5*sin(e*1.7))*1.2+ad,D=e*.7+sin(e*.4)*.5,ae=floor(e*.25),E=fract(e*.25),m=fract(ae*781.23*.1031);
  m*=m+33.33;
  m*=m+m;
  float F=fract(m),G=0.;
  if(F>.4){
    float af=smoothstep(0.,.4,E)*(1.-smoothstep(.4,1.,E));
    G=af*(15.+F*15.);
  }
  vec2 ag=(ac-.7*l)/l.y;
  vec3 ah=normalize(vec3(ag,.6)),ai=vec3(0.,0.,-h+G);
  vec4 b=vec4(0.);
  float p=.05,H=0.,I=0.,J=0.,K=0.;
  for(int L=0;L<103;L++){
    vec3 q=ai+ah*p,c=q;
    {
      float f=D,g=cos(f),s=sin(f);
      c.xy*=mat2(g,-s,s,g);
    }
    float M=max(length(c.xy),.001);
    c=vec3(log(M)-h*.3,atan(c.y,c.x)/3.14159265359,c.z*.2);
    c=abs(fract(c)-.5);
    float t=length(c.xy)*M*.5;
    vec3 a=q;
    {
      float f=-D*.1,g=cos(f),s=sin(f);
      a.xy*=mat2(g,-s,s,g);
    }
    a.z=mod(a.z,2.)-1.;
    float N=1.3,O=1.;
    for(int P=0;P<5;P++){
      a=abs(a)-vec3(.8,.3,.3);
      if(a.x<a.y)a.xy=a.yx;
      if(a.x<a.z)a.xz=a.zx;
      if(a.y<a.z)a.yz=a.zy;
      a=a*N-vec3(.6,.2,.2);
      O*=N;
    }
    float u=(length(a)-.1)/max(O,.001);
    vec3 d=q;
    {
      float f=.5,g=cos(f),s=sin(f);
      d.yz*=mat2(g,-s,s,g);
    }
    float Q=max(length(d.xy),.001);
    d=vec3(log2(Q)-h*.4,atan(d.y,d.x)/3.14159265359,d.z*.1);
    d.xy=abs(fract(d.xy*0.)-.5);
    float v=(length(d.xy)-.1)*Q*.5,i=1e5,aj=floor(h*3.);
    for(int j=0;j<6;j++){
      float w=aj-float(j),n=fract(w*541.17*.1031);
      n*=n+33.33;
      n*=n+n;
      float ak=fract(n);
      if(ak>.3){
        float R=w*(1./3.),A=h-R;
        if(A>0.&&A<2.){
          float al=mod(w,2.)*2.-1.;
          vec2 S=vec2(al*.18,-.08);
          float am=-R,an=24.,T=am+A*an;
          vec3 U=vec3(S,T),ao=vec3(S,T-3.5),V=q-U,baL=ao-U;
          float ap=clamp(dot(V,baL)/dot(baL,baL),0.,1.),aq=length(V-baL*ap)-.004;
          i=min(i,aq);
        }
      }
    }
    float k=1e5,ar=floor(h*4.2);
    for(int j=0;j<5;j++){
      float W=ar-float(j),o=fract(W*913.43*.1031);
      o*=o+33.33;
      o*=o+o;
      float as=fract(o);
      if(as>.45){
        float X=W*(1./4.2),B=h-X;
        if(B>0.&&B<1.8){
          vec2 Y=vec2(0.);
          float at=-X,au=32.,Z=at+B*au;
          vec3 _=vec3(Y,Z),av=vec3(Y,Z-4.5),aa=q-_,baR=av-_;
          float aw=clamp(dot(aa,baR)/dot(baR,baR),0.,1.),ax=length(aa-baR*aw)-.006;
          k=min(k,ax);
        }
      }
    }
    H+=1./(1.+i*i*1200.);
    I+=1./(1.+i*i*45000.);
    J+=1./(1.+k*k*1000.);
    K+=1./(1.+k*k*35000.);
    float r=min(t,min(u,min(v,min(i,k))));
    r=clamp(r,.002,.24);
    vec4 ay=vec4(.6,.25,.05,1.)/(1.+t*t*400.),az=vec4(.05,.5,.6,0.)/(0.+u*u*200.),aA=vec4(0.,.1,0.,1.)/(1.+v*v*300.);
    float aB=exp(-p*.12);
    b+=(ay*.7+az*.2+aA*0.)*aB*(r*1.);
    p+=r*1.;
    if(p>48.)break;
  }
  vec3 aC=vec3(0.,.45,1.)*H*.045,aD=vec3(.75,.92,1.)*I*.12,aE=vec3(1.,.02,.05)*J*.055,aF=vec3(1.,.85,.8)*K*.14,aG=aC+aD+aE+aF;
  b=clamp(b,0.,1.);
  b.rgb=pow(b.rgb,vec3(.61));
  b.rgb=mix(b.rgb,vec3(0.),clamp(1.-exp(-.04*p),0.,1.));
  b.rgb+=aG;
  ab=vec4(b.rgb,1.);
}
/*
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = iResolution.xy;
    if (r.y < 1.0) r.y = 1080.0;
    if (r.x < 1.0) r.x = 1920.0;
    
    float t = iTime;
    
    float speedPhase = t * 0.15;
    float speedVar = sin(speedPhase) * cos(speedPhase * 0.6) * 1.5;
    float tTunnel = t * 1.0 + (sin(t * 0.8) * 0.8 + 0.5 * sin(t * 1.7)) * 1.2 + speedVar;
    float tRotation = t * 0.7 + sin(t * 0.4) * 0.5;
    
    float pulseCycle = floor(t * 0.25);
    float pulseTime = fract(t * 0.25);
    
    float pHash = fract(pulseCycle * 781.23 * .1031);
    pHash *= pHash + 33.33;
    pHash *= pHash + pHash;
    float pulseRand = fract(pHash);
    
    float pulseZ = 0.0;
    if (pulseRand > 0.4) {
        float pulseAnim = smoothstep(0.0, 0.4, pulseTime) * (1.0 - smoothstep(0.4, 1.0, pulseTime));
        pulseZ = pulseAnim * (15.0 + pulseRand * 15.0);
    }
    
    vec2 uv = (fragCoord - 0.7 * r) / r.y;
    
    vec3 dir = normalize(vec3(uv, 0.6));
    vec3 q = vec3(0.0, 0.0, -tTunnel + pulseZ);

    vec4 o = vec4(0.0);
    float depth = 0.05;

    float laserGlowAccum = 0.0;
    float laserCoreAccum = 0.0;
    
    float redLaserGlowAccum = 0.0;
    float redLaserCoreAccum = 0.0;

    for(int i = 0; i < 103; i++){
        vec3 p = q + dir * depth;

        vec3 pa = p;
        {
            float a = tRotation;
            float c = cos(a), s = sin(a);
            pa.xy *= mat2(c, -s, s, c);
        }
        float va = max(length(pa.xy), 0.001);
        pa = vec3(log(va) - tTunnel * 0.3, atan(pa.y, pa.x) / 3.14159265359, pa.z * 0.2);
        pa = abs(fract(pa) - 0.5);
        
        float distA = length(pa.xy) * va * 0.5;

        vec3 pb = p;
        {
            float a = -tRotation * 0.1;
            float c = cos(a), s = sin(a);
            pb.xy *= mat2(c, -s, s, c);
        }
        pb.z = mod(pb.z, 2.0) - 1.0;
        
        float scale = 1.3;
        float dr = 1.0;
        for(int k = 0; k < 5; k++) {
            pb = abs(pb) - vec3(0.8, 0.3, 0.3);
            if (pb.x < pb.y) pb.xy = pb.yx;
            if (pb.x < pb.z) pb.xz = pb.zx;
            if (pb.y < pb.z) pb.yz = pb.zy;
            pb = pb * scale - vec3(0.6, 0.2, 0.2);
            dr *= scale;
        }
        float distB = (length(pb) - 0.1) / max(dr, 0.001);

        vec3 pc = p;
        {
            float a = 0.5;
            float c = cos(a), s = sin(a);
            pc.yz *= mat2(c, -s, s, c);
        }
        float vc = max(length(pc.xy), 0.001);
        pc = vec3(log2(vc) - tTunnel * 0.4, atan(pc.y, pc.x) / 3.14159265359, pc.z * 0.1);
        pc.xy = abs(fract(pc.xy * 0.0) - 0.5);
        float distC = (length(pc.xy) - 0.1) * vc * 0.5;

        float dLaser = 1e5;
        float tBase = floor(tTunnel * 3.0);
        for (int l = 0; l < 6; l++) {
            float laserId = tBase - float(l);
            
            float h1 = fract(laserId * 541.17 * .1031);
            h1 *= h1 + 33.33;
            h1 *= h1 + h1;
            float shootRand = fract(h1);
            
            if (shootRand > 0.3) {
                float spawnTime = laserId * (1.0 / 3.0);
                float age = tTunnel - spawnTime;
                if (age > 0.0 && age < 2.0) {
                    float side = mod(laserId, 2.0) * 2.0 - 1.0;
                    vec2 laserOffset = vec2(side * 0.18, -0.08);
                    
                    float zStart = -spawnTime;
                    float zSpeed = 24.0;
                    float laserZ = zStart + age * zSpeed;
                    
                    vec3 laserPosA = vec3(laserOffset, laserZ);
                    vec3 laserPosB = vec3(laserOffset, laserZ - 3.5);
                    
                    vec3 paL = p - laserPosA, baL = laserPosB - laserPosA;
                    float hL = clamp(dot(paL, baL) / dot(baL, baL), 0.0, 1.0);
                    float dCaps = length(paL - baL * hL) - 0.004;
                    
                    dLaser = min(dLaser, dCaps);
                }
            }
        }

        float dRedLaser = 1e5;
        float tBaseRed = floor(tTunnel * 4.2);
        for (int l = 0; l < 5; l++) {
            float rLaserId = tBaseRed - float(l);
            
            float h2 = fract(rLaserId * 913.43 * .1031);
            h2 *= h2 + 33.33;
            h2 *= h2 + h2;
            float rShootRand = fract(h2);
            
            if (rShootRand > 0.45) {
                float rSpawnTime = rLaserId * (1.0 / 4.2);
                float rAge = tTunnel - rSpawnTime;
                if (rAge > 0.0 && rAge < 1.8) {
                    vec2 rLaserOffset = vec2(0.0, 0.0);
                    float rZStart = -rSpawnTime;
                    float rZSpeed = 32.0;
                    float rLaserZ = rZStart + rAge * rZSpeed;
                    
                    vec3 rLaserPosA = vec3(rLaserOffset, rLaserZ);
                    vec3 rLaserPosB = vec3(rLaserOffset, rLaserZ - 4.5);
                    
                    vec3 paR = p - rLaserPosA, baR = rLaserPosB - rLaserPosA;
                    float hR = clamp(dot(paR, baR) / dot(baR, baR), 0.0, 1.0);
                    float dCapsRed = length(paR - baR * hR) - 0.006;
                    
                    dRedLaser = min(dRedLaser, dCapsRed);
                }
            }
        }

        laserGlowAccum += 1.0 / (1.0 + dLaser * dLaser * 1200.0);
        laserCoreAccum += 1.0 / (1.0 + dLaser * dLaser * 45000.0);
        
        redLaserGlowAccum += 1.0 / (1.0 + dRedLaser * dRedLaser * 1000.0);
        redLaserCoreAccum += 1.0 / (1.0 + dRedLaser * dRedLaser * 35000.0);

        float e = min(distA, min(distB, min(distC, min(dLaser, dRedLaser))));
        e = clamp(e, 0.002, 0.24);

        vec4 colA = vec4(0.6, 0.25, 0.05, 1.0) / (1.0 + distA * distA * 400.0);
        vec4 colB = vec4(0.05, 0.5, 0.6, 0.0) / (0.0 + distB * distB * 200.0);
        vec4 colC = vec4(0.0, 0.1, 0.0, 1.0) / (1.0 + distC * distC * 300.0);

        float atten = exp(-depth * 0.12);
        o += (colA * 0.7 + colB * 0.2 + colC * 0.0) * atten * (e * 1.0);

        depth += e * 1.0;
        if (depth > 48.0) break;
    }

    vec3 laserGlowColor = vec3(0.0, 0.45, 1.0) * laserGlowAccum * 0.045;
    vec3 laserCoreColor = vec3(0.75, 0.92, 1.0) * laserCoreAccum * 0.12;
    
    vec3 redLaserGlowColor = vec3(1.0, 0.02, 0.05) * redLaserGlowAccum * 0.055;
    vec3 redLaserCoreColor = vec3(1.0, 0.85, 0.8) * redLaserCoreAccum * 0.14;
    
    vec3 laserTotal = laserGlowColor + laserCoreColor + redLaserGlowColor + redLaserCoreColor;

    o = clamp(o, 0.0, 1.0);
    o.rgb = pow(o.rgb, vec3(0.6100));
    o.rgb = mix(o.rgb, vec3(0.0), clamp(1.0 - exp(-0.04 * depth), 0.0, 1.0));
    
    o.rgb += laserTotal;
    
    fragColor = vec4(o.rgb, 1.0);
}
*/
