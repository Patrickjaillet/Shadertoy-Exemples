// ==== Image (image) ====
mat2 a(in float b) {
  float c=cos(b),d=sin(b);
  return mat2(c,d,-d,c);
}

float e(in float f) {
  return abs((f-floor(f))-0.5);
}

vec3 g(in vec3 h) {
  return vec3(
    abs((h.z+abs((h.y-floor(h.y))-0.5)-floor(h.z+abs((h.y-floor(h.y))-0.5)))-0.5),
    abs((h.z+abs((h.x-floor(h.x))-0.5)-floor(h.z+abs((h.x-floor(h.x))-0.5)))-0.5),
    abs((h.y+abs((h.x-floor(h.x))-0.5)-floor(h.y+abs((h.x-floor(h.x))-0.5)))-0.5)
  );
}

float i(in vec3 h,in float j) {
  float t=iTime*0.64;
  float k=1.0,l=0.1;
  vec3 m=h;
  for(float n=0.;n<=4.;n++) {
    vec3 o=g(m);
    h+=(o+t*j);
    m*=2.0;
    k*=1.5;
    h*=1.3;
    l+=(e(h.z+e(h.x+e(h.y))))/k;
    m+=0.14;
  }
  return l;
}

float sdHexagon(in vec2 p, in float r) {
  const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
  p = abs(p);
  p -= 2.0*min(dot(k.xy, p), 0.0)*k.xy;
  p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
  return length(p)*sign(p.y);
}

float sdOctahedron(vec3 p, float s) {
  p = abs(p);
  return (p.x + p.y + p.z - s) * 0.57735027;
}

vec4 getMorphWeights(out float w5) {
  float cycle = mod(iTime, 75.0);
  float m1 = (1.0 - smoothstep(12.0, 15.0, cycle)) + smoothstep(72.0, 75.0, cycle);
  float m2 = smoothstep(12.0, 15.0, cycle) - smoothstep(27.0, 30.0, cycle);
  float m3 = smoothstep(27.0, 30.0, cycle) - smoothstep(42.0, 45.0, cycle);
  float m4 = smoothstep(42.0, 45.0, cycle) - smoothstep(57.0, 60.0, cycle);
  float m5 = smoothstep(57.0, 60.0, cycle) - smoothstep(72.0, 75.0, cycle);
  
  vec4 w1 = clamp(vec4(m1, m2, m3, m4), 0.0, 1.0);
  w5 = clamp(m5, 0.0, 1.0);
  
  float s = w1.x + w1.y + w1.z + w1.w + w5;
  if(s > 0.0001) {
    w1 /= s;
    w5 /= s;
  } else {
    w1 = vec4(1.0, 0.0, 0.0, 0.0);
    w5 = 0.0;
  }
  return w1;
}

vec2 p(float k) {
  float w5;
  vec4 w1 = getMorphWeights(w5);
  vec2 p1 = vec2(sin(k*0.12)*3.5+cos(k*0.04)*1.5, cos(k*0.09)*2.5+sin(k*0.13)*1.2);
  vec2 p2 = vec2(sin(k*0.06)*8.0+cos(k*0.12)*4.0, cos(k*0.04)*7.0+sin(k*0.09)*3.5);
  vec2 p3 = vec2(sin(k*0.11)*2.2+cos(k*0.05)*1.8, cos(k*0.08)*2.0+sin(k*0.14)*1.3);
  vec2 p4 = vec2(sin(k*0.15)*6.0+cos(k*0.07)*3.0, cos(k*0.11)*5.0+sin(k*0.03)*2.5);
  vec2 p5 = vec2(sin(k*0.08)*4.5+cos(k*0.14)*2.2, cos(k*0.06)*3.8+sin(k*0.11)*2.8);
  return p1*w1.x + p2*w1.y + p3*w1.z + p4*w1.w + p5*w5;
}

vec3 getOrbPos(float ab) {
  float orbZ = ab + 18.0 + sin(iTime*0.7)*5.0 + cos(iTime*1.3)*3.0;
  vec2 tunnelCenter = p(orbZ);
  vec2 randomOffset = vec2(
    sin(iTime*1.9)*1.2 + cos(iTime*3.1)*0.6,
    cos(iTime*2.3)*1.0 + sin(iTime*4.2)*0.5
  );
  return vec3(tunnelCenter + randomOffset, orbZ);
}

float q(vec3 h, vec4 w1, float w5) {
  vec2 r = p(h.z);
  vec3 s = h;
  s.xy -= r;

  float q1 = 0.0;
  if(w1.x > 0.001) {
    float t1 = 5.5 - length(s.xy);
    float u1 = i(h*0.25, 0.0);
    vec3 s1 = s;
    s1.xy *= a(h.z*0.1);
    float v1 = length(s1.xy + vec2(sin(h.z), cos(h.z))*1.5) - 0.8;
    q1 = min(t1, v1) - u1*0.5;
  }

  float q2 = 0.0;
  if(w1.y > 0.001) {
    vec3 s2 = s;
    s2.xy *= a(h.z*0.15 + sin(h.z*0.08)*1.2);
    float hexOuter = -sdHexagon(s2.xy, 8.5 + sin(h.z*0.3)*1.2);
    vec3 pFractal = vec3(s2.xy*0.4, h.z*0.15);
    float fVal = i(pFractal, 0.2);
    float ribs = sin(s2.x*1.5)*sin(s2.y*1.5)*sin(h.z*1.2);
    vec3 corePos = s2;
    corePos.xy *= a(h.z*0.4);
    vec2 coreGrid = abs(mod(corePos.xy, 3.2) - 1.6);
    float corePillars = length(coreGrid) - 0.35;
    q2 = min(hexOuter, corePillars) - fVal*0.9 + ribs*0.2;
  }

  float q3 = 0.0;
  if(w1.z > 0.001) {
    vec3 s3 = s;
    s3.xy *= a(h.z*0.2 + sin(h.z*0.4)*0.5);
    float angle = atan(s3.y, s3.x);
    float radius = length(s3.xy);
    float bioCavity = (4.5 + sin(angle*5.0 + h.z*0.8)*0.8 + cos(angle*3.0 - h.z*0.5)*0.6) - radius;
    vec3 bioNoisePos = vec3(s3.xy*0.35, h.z*0.25);
    float bioFBM = i(bioNoisePos, 0.15);
    float organicFolds = sin(radius*2.5 + h.z*1.5)*sin(angle*8.0)*0.25;
    q3 = bioCavity - bioFBM*0.8 + organicFolds;
  }

  float q4 = 0.0;
  if(w1.w > 0.001) {
    vec3 s4 = s;
    s4.xy *= a(h.z*0.1 + cos(h.z*0.08)*0.4);
    float crystBound = 7.5 - length(s4.xy);
    float ringRadius = 4.8 + sin(h.z*0.2)*0.8;
    float angle = atan(s4.y, s4.x);
    float sector = 3.14159265 / 4.0;
    float aSector = floor((angle + sector*0.5) / sector) * sector;
    vec2 octCenter = ringRadius * vec2(cos(aSector), sin(aSector));
    vec3 octPos = s4;
    octPos.xy -= octCenter;
    octPos.z = mod(octPos.z + 3.0, 6.0) - 3.0;
    float octNodes = sdOctahedron(octPos, 0.95);
    vec3 latticePos = vec3(s4.xy*0.3, h.z*0.15);
    float crystFBM = i(latticePos, 0.1);
    q4 = min(crystBound, octNodes) - crystFBM*0.3;
  }

  float q5 = 0.0;
  if(w5 > 0.001) {
    vec3 s5 = s;
    s5.xy *= a(h.z*0.12 + sin(h.z*0.15)*0.8);
    float ang = atan(s5.y, s5.x);
    float rad = length(s5.xy);
    float peristalsis = sin(h.z*0.8 - iTime*2.5)*0.65;
    float sphincter = sin(ang*6.0 + h.z*0.4)*sin(ang*3.0 - h.z*0.2)*0.55;
    float lumen = (5.2 + peristalsis + sphincter) - rad;
    
    vec3 bioPos = vec3(s5.xy*0.45, h.z*0.3);
    float bioNoise = i(bioPos, 0.25);
    q5 = lumen - bioNoise*0.85;
  }

  float baseTunnel = q1*w1.x + q2*w1.y + q3*w1.z + q4*w1.w + q5*w5;

  float ab = iTime*0.64*14.0;
  vec3 orbCenter = getOrbPos(ab);
  float orbRadius = 1.0 + 0.35*sin(iTime*9.0 + sin(iTime*3.0)*2.0);
  float orbSDF = length(h - orbCenter) - orbRadius;

  return mix(baseTunnel, min(baseTunnel, orbSDF), w1.z + w1.w*0.5 + w5*0.8);
}

vec3 x(in vec3 h, in vec4 w1, in float w5) {
  vec2 y = vec2(1.8, 0.2)*0.01;
  return normalize(y.yxx*q(h+y.yxx, w1, w5) + y.xxy*q(h+y.xxy, w1, w5) + y.xyx*q(h+y.xyx, w1, w5) + y.yyy*q(h+y.yyy, w1, w5));
}

vec3 z(float k) {
  return vec3(p(k), k);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  float t = iTime*0.64;
  float w5;
  vec4 w1 = getMorphWeights(w5);
  
  vec2 aa = fragCoord.xy / iResolution.xy;
  vec2 h = aa - 0.5;
  h.x *= iResolution.x / iResolution.y;

  float ab = t*14.0;
  vec3 ac = z(ab);
  vec3 ad = z(ab + dot(w1, vec4(8.0, 16.0, 10.0, 12.0)) + w5*11.0);
  
  float ae = sin(t*(dot(w1, vec4(0.2, 0.6, 0.4, 0.3)) + w5*0.5))*(dot(w1, vec4(0.5, 1.4, 0.8, 1.1)) + w5*1.2);
  vec3 af = normalize(ad - ac);
  vec3 ag = vec3(sin(ae), cos(ae), sin(t*0.5)*w1.y + cos(t*0.7)*w5);
  vec3 ah = normalize(cross(af, ag));
  vec3 ai = normalize(cross(ah, af));
  vec3 aj = normalize(h.x*ah + h.y*ai + (dot(w1, vec4(1.7, 0.85, 1.4, 1.1)) + w5*1.3)*af);

  float ak = 0.0, w = 0.0, al = 0.0;
  float maxDist = dot(w1, vec4(50.0, 80.0, 60.0, 70.0)) + w5*65.0;
  float stepFactor = dot(w1, vec4(0.75, 0.65, 0.68, 0.65)) + w5*0.62;
  
  for(int n = 0; n < 128; n++) {
    w = q(ac + aj*ak, w1, w5);
    if(abs(w) < 0.003 || ak > maxDist) break;
    ak += w * stepFactor;
    al += max(0.0, ((dot(w1, vec4(0.35, 0.7, 0.5, 0.6)) + w5*0.6) - w))*(dot(w1, vec4(0.09, 0.08, 0.12, 0.10)) + w5*0.14);
  }

  vec3 am = w1.x*vec3(0.002, 0.004, 0.008) + w1.y*vec3(0.001, 0.003, 0.008) + w1.z*vec3(0.008, 0.001, 0.004) + w1.w*vec3(0.006, 0.002, 0.008) + w5*vec3(0.009, 0.003, 0.001);
  
  vec3 orbCenter = getOrbPos(ab);
  float pulse = sin(iTime*9.0 + sin(iTime*3.0)*2.0);
  float orbRadius = 1.0 + 0.35*pulse;
  vec3 orbEmissive = mix(vec3(1.0, 0.15, 0.3), vec3(1.0, 0.6, 0.1), 0.5 + 0.5*pulse);

  if(ak < maxDist) {
    vec3 an = ac + aj*ak;
    vec3 ao = x(an, w1, w5);
    vec3 ap = normalize(w1.x*vec3(0.5, 0.8, -0.2) + w1.y*vec3(-0.2, 0.9, -0.4) + w1.z*vec3(-0.3, 0.7, -0.6) + w1.w*vec3(0.6, 0.6, -0.5) + w5*vec3(-0.4, 0.8, -0.4));
    float uVal = i(an*(dot(w1, vec4(0.1, 0.12, 0.15, 0.11)) + w5*0.18), 0.0);
    float aq = clamp(dot(ao, ap), 0.0, 1.0);
    float ar = pow(clamp(1.0 + dot(ao, aj), 0.0, 1.0), dot(w1, vec4(3.0, 4.0, 3.5, 5.0)) + w5*2.5);
    float as = clamp(q(an + ao*1.5, w1, w5), 0.0, 1.0);

    vec3 col1 = mix(vec3(0.05, 0.1, 0.25), vec3(0.4, 0.6, 0.8), uVal);
    vec3 col2 = mix(vec3(0.02, 0.2, 0.25), vec3(0.1, 0.8, 0.85), uVal);
    vec3 col3 = mix(vec3(0.2, 0.02, 0.08), vec3(0.85, 0.15, 0.35), uVal);
    vec3 col4 = mix(vec3(0.15, 0.02, 0.2), vec3(0.65, 0.25, 0.9), uVal);
    vec3 col5 = mix(vec3(0.25, 0.04, 0.01), vec3(0.95, 0.35, 0.05), uVal);
    
    am = col1*w1.x + col2*w1.y + col3*w1.z + col4*w1.w + col5*w5;
    vec3 specCol = w1.x*vec3(0.7, 0.9, 1.0) + w1.y*vec3(0.3, 1.0, 0.9) + w1.z*vec3(1.0, 0.4, 0.6) + w1.w*vec3(0.9, 0.5, 1.0) + w5*vec3(1.0, 0.6, 0.2);
    am = am*aq + ar*specCol*as;
    am *= as;

    float distToOrb = length(an - orbCenter);
    if(distToOrb < orbRadius + 0.15) {
      am = mix(am, orbEmissive*3.5, w1.z + w1.w*0.5 + w5*0.8);
    } else {
      vec3 orbDir = normalize(orbCenter - an);
      float orbDist = length(orbCenter - an);
      float orbDiff = max(0.0, dot(ao, orbDir));
      vec3 viewDir = -aj;
      vec3 reflDir = reflect(-orbDir, ao);
      float orbSpec = pow(max(0.0, dot(reflDir, viewDir)), 16.0);
      float atten = 1.0 / (1.0 + orbDist*0.15 + orbDist*orbDist*0.05);
      
      vec3 orbIllum = (orbEmissive * orbDiff * 2.5 + vec3(1.0, 0.8, 0.6) * orbSpec * 4.0) * atten;
      am += orbIllum * (w1.z + w1.w*0.5 + w5*0.8);

      if((w1.z + w1.w + w5) > 0.001) {
        vec3 rDir = reflect(aj, ao);
        float rk = 0.1;
        float hitOrb = 0.0;
        for(int rStep = 0; rStep < 18; rStep++) {
          vec3 rPos = an + rDir*rk;
          float dOrb = length(rPos - orbCenter) - orbRadius;
          if(dOrb < 0.02) { hitOrb = 1.0; break; }
          if(rk > 35.0) break;
          rk += dOrb;
        }
        if(hitOrb > 0.5) {
          float fresnel = pow(1.0 - clamp(dot(-aj, ao), 0.0, 1.0), 3.0);
          am = mix(am, orbEmissive * 2.5, (0.4 + 0.6 * fresnel) * (w1.z + w1.w*0.5 + w5*0.8));
        }
      }
    }
  }

  float at = length(h)*0.15;
  vec3 glowCol = w1.x*vec3(1.0, 0.75, 0.5) + w1.y*vec3(0.1, 0.95, 0.85) + w1.z*vec3(1.0, 0.2, 0.4) + w1.w*vec3(0.8, 0.3, 1.0) + w5*vec3(1.0, 0.4, 0.1);
  am += glowCol*al*(0.4 - at);

  float orbDistAlongRay = dot(orbCenter - ac, aj);
  if(orbDistAlongRay > 0.0) {
    vec3 closestPointOnRay = ac + aj*orbDistAlongRay;
    float orbGlowDist = length(closestPointOnRay - orbCenter);
    float pulseVal = 0.5 + 0.5*pulse;
    float orbGlow = (0.4 + 0.3*pulseVal) / (orbGlowDist*orbGlowDist + 0.08);
    am += orbEmissive * orbGlow * (w1.z + w1.w*0.5 + w5*0.8) * exp(-orbDistAlongRay*0.025);
  }
  
  vec3 fogCol = w1.x*vec3(0.001, 0.002, 0.005) + w1.y*vec3(0.0, 0.005, 0.015) + w1.z*vec3(0.008, 0.001, 0.003) + w1.w*vec3(0.005, 0.001, 0.008) + w5*vec3(0.01, 0.002, 0.001);
  float fogDensity = dot(w1, vec4(0.06, 0.025, 0.04, 0.035)) + w5*0.045;
  am = mix(am, fogCol, 1.0 - exp(-ak*fogDensity));
  am = sqrt(max(am, 0.0));
  am *= 0.4 + 0.6*pow(16.0*aa.x*aa.y*(1.0 - aa.x)*(1.0 - aa.y), 0.35);

  fragColor = vec4(am*smoothstep(0.0, 2.5, t), 1.0);
}
