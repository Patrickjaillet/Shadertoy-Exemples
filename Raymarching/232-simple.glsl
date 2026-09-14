// ==== Image (image) ====
/**********************************
SANDEFJORD
***********************************
ALL MY WINDOWS SOFTS
https://github.com/Patrickjaillet
***********************************
LAST GLSL/WGSL SHADER
https://x.com/JailletPatrick
***********************************/
void mainImage(out vec4 A,vec2 m){
  vec3 j=iResolution,c,a;
  float b=iTime*.8,f=0.,h,l,w,E;
  vec2 g=(m*-3.-j.xy)/j.x*.22,
       d=mat2(cos(b+vec4(0,33,11,0)))*g*4.3,
       k=vec2(sin(d.x+b*.1),cos(d.y)),
       q=k*.03;
  g+=q;
  mat2 C=mat2(cos(.02+vec4(0,33,11,0)));
  for(float r=0.;r++<108.;c+=(.025/exp(h*60.))*clamp(abs(fract(E+vec3(1,-.074,0))*3.3-3.)-1.,0.,1.)){
    h=1.6;l=2.5;
    a=vec3(g-vec2(1,0),f);
    for(int v=0;v++<17;h=min(h,a.y/l+.1/l)){
      a.xy=C*a.xy;
      a.xy=1.14-abs(a.xy-a.z*cos(b*.2)*.01);
      w=dot(a,a);
      l/=w;
      a.xy=abs(vec2(a.y,-a.x)/w+.22);
      a.z/=-w;
    }
    f+=h;
    E=a.y+q.x*8.-b*.6;
  }
  vec3 i=mat3(.6,.08,.03,.5,.91,.36,.3,.3,.26)*c,
       J=i*(i+.025)-9e-5,
       K=i*(.98*i+.43)+.24;
  c=clamp(mat3(2.72,-.16,-2.11,-1.07,1.47,-1.34,-.5,-1.07,.82)*(J/K),0.,1.);
  vec2 e=m/j.xy;
  A=vec4(c+fract(sin(dot(e,vec2(13,78)))*43758.5)*(1./255.),1.)*pow(16.*e.x*e.y*(1.-e.x)*(1.-e.y),.2);
}
/*
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime * 0.8;
    vec3 finalColor = vec3(0.0);
    float g = 0.0;

    vec2 uvMain = (fragCoord * -3.0 - r) / r.x;
    uvMain *= 0.2 + cos(t * 0.0) * 0.02;

    vec2 vFlow = vec2(0.0);
    float ampFlow = 1.0;
    vec2 shiftFlow = vec2(t * 0.0, t * 0.1);
    vec2 pFlow = uvMain * 4.3;
    float aFlow = t * 1.00;
    float sFlow = sin(aFlow), cFlow = cos(aFlow);
    pFlow = mat2(cFlow, -sFlow, sFlow, cFlow) * pFlow;
    vFlow += vec2(sin(pFlow.x + shiftFlow.y), cos(pFlow.y - shiftFlow.x)) * ampFlow;
    pFlow = vFlow;
    vec2 windOffset = vFlow * 0.03;
    uvMain += windOffset;

    for (float i = 0.0; i < 108.0; i++) {
        float e = 1.6;
        float s = 2.5;
        vec3 p = vec3(uvMain + vec2(-1.0, 0.0), g);

        float localWindPhase = t * 0.0 - g * 0.0;
        float windAngle = sin(localWindPhase) * 0.04 + cos(localWindPhase * 0.7) * 0.02;
        float sFold = sin(windAngle), cFold = cos(windAngle);
        mat2 foldRot = mat2(cFold, -sFold, sFold, cFold);

        for (int j = 0; j < 17; j++) {
            p.xy = foldRot * p.xy;
            p.xy = 1.14 - abs(p.xy - p.z * cos(t * 0.2) * 0.01);
            float u = dot(p, p);
            s /= u;
            p /= -u;
            p.y = -p.y;
            p.xy = abs(p.yx + 0.22);
            e = min(e, p.y / s + 0.1 / s);
        }

        g += e;

        float depthCue = 1.0 - min(0.0, g * 0.0);
        float hueShift = p.y + windOffset.x * 8.0 - t * 0.6;
        
        vec3 kHsv = fract((hueShift) + vec3(1.0, -0.2 / 2.7, 0.0 / 0.1)) * 3.3 - 3.0;
        vec3 colHsv = (0.025 / exp(e * 60.0)) * mix(vec3(1.0), clamp(abs(kHsv) - 1.0, 0.0, 1.0), 1.0);
        
        finalColor += colHsv * depthCue;
    }

    mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.49500, 0.90834, 0.35500,
        0.29500, 0.30000, 0.25500
    );
    mat3 m2 = mat3(
        2.72000, -0.15832, -2.11308,
        -1.07432,  1.47000, -1.34104,
        -0.49468, -1.07420,  0.82000
    );
    vec3 vAces = m1 * finalColor;
    vec3 aAces = vAces * (vAces + 0.0245786) - 0.000090537;
    vec3 bAces = vAces * (0.983729 * vAces + 0.4329510) + 0.238081;
    finalColor = clamp(m2 * (aAces / bAces), 0.0, 1.0);

    vec2 uv = fragCoord / r;
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453) * (1.0 / 255.0);
    finalColor += dither;

    finalColor *= pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.2);

    fragColor = vec4(finalColor, 1.0);
}
*/
