// ==== Image (image) ====
#define F4 0.309016994374947451
#define ITERATIONS 8
#define QUALITY 1.0

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec2 mod289(vec2 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec3 mod289(vec3 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
float permute(float x){return mod289(((x*34.0)+1.0)*x);}
vec3 permute(vec3 x) {return mod289(((x*34.0)+1.0)*x);}
vec4 permute(vec4 x) {return mod289(((x*34.0)+1.0)*x);}
float taylorInvSqrt(float r){return 1.79284291400159 - 0.85373472095314 * r;}
vec4 taylorInvSqrt(vec4 r) {return 1.79284291400159 - 0.85373472095314 * r;}

vec4 grad4(float j, vec4 ip){
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;
  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;
  return p;
}

float snoise4D(vec4 v){
  const vec4 C = vec4( 0.138196601125011, 0.276393202250021, 0.414589803375032, -0.447213595499958);
  vec4 i = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v - i + dot(i, C.xxxx);
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;
  i = mod289(i);
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
               i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
             + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
             + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
             + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;
  vec4 p0 = grad4(j0, ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4) ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
                  + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;
}

float fbm(vec4 p) {
    float sum = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    mat3 rot = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
    for(int i = 0; i < ITERATIONS; i++) {
        sum += amp * abs(snoise4D(p * freq));
        amp *= 0.52;
        freq *= 2.01;
        p.xyz *= rot;
    }
    return sum;
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 mouse = (iMouse.xy - 0.5 * iResolution.xy) / iResolution.y;
    
    float mDist = length(uv - mouse);
    float mStrength = 0.35 / (mDist + 0.35);
    vec2 mDir = normalize(uv - mouse + 0.001);
    
    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.5));
    float t = iTime * 0.1;
    
    vec4 p = vec4(rd * 2.2, t);
    
    p.xy += mDir * mStrength * 0.85;
    p.z += mStrength * 0.4;
    
    float n1 = fbm(p + fbm(p + fbm(p)));
    float n2 = fbm(p + n1 + t);
    
    vec3 color = palette(n2 + length(uv) * 0.5);
    
    float lum = n1 * 2.2 + 0.2;
    color *= lum;
    
    vec3 glow = pow(max(0.0, n2), 4.0) * vec3(0.1, 0.4, 0.8);
    color += glow;
    
    color = mix(color, color * color * 1.8, n1);
    
    vec3 finalColor;
    finalColor.r = color.r;
    finalColor.g = palette(n2 + length(uv) * 0.51).g * lum;
    finalColor.b = palette(n2 + length(uv) * 0.52).b * lum;
    
    finalColor = mix(finalColor, finalColor * 1.2, glow);
    finalColor = pow(finalColor, vec3(0.4545));
    
    float mouseHighlight = exp(-mDist * 10.0);
    finalColor += mouseHighlight * vec3(0.1, 0.2, 0.5) * 0.5;
    
    fragColor = vec4(finalColor, 1.0);
}
