// ==== Image (image) ====
// Cubic [@xordev], Cubic [@xordev], Untitled 10 [@Zozuar], Untitled 10 [@Zozuar] - worldbreeder.io

#define FC gl_FragCoord

const float PI = 3.141592653589793;
const float PI2 = PI * 2.0;
const float F4 = 4.0;

vec3 hsv(float h, float s, float v) {
  vec4 t = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(vec3(h) + t.xyz) * 6.0 - vec3(t.w));
  return v * mix(vec3(t.x), clamp(p - vec3(t.x), 0.0, 1.0), s);
}

mat2 rotate2D(float r) {
  return mat2(cos(r), sin(r), -sin(r), cos(r));
}

mat3 rotate3D(float angle, vec3 axis) {
  vec3 a = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float r = 1.0 - c;
  return mat3(
    a.x * a.x * r + c,
    a.y * a.x * r + a.z * s,
    a.z * a.x * r - a.y * s,
    a.x * a.y * r - a.z * s,
    a.y * a.y * r + c,
    a.z * a.y * r + a.x * s,
    a.x * a.z * r + a.y * s,
    a.y * a.z * r - a.x * s,
    a.z * a.z * r + c
  );
}

float mod289(float x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute3(vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }
float permute4(float x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 permute4(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
float taylorInvSqrt(float r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise2D(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                      -0.577350269189626, 0.024390243902439);
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289(i);
  vec3 p = permute3(permute3(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float snoise3D(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;
  i = mod289(i);
  vec4 p = permute4(permute4(permute4(
    i.z + vec4(0.0, i1.z, i2.z, 1.0))
    + i.y + vec4(0.0, i1.y, i2.y, 1.0))
    + i.x + vec4(0.0, i1.x, i2.x, 1.0));
  float n_ = 0.142857142857;
  vec3 ns = n_ * D.wyz - D.xzx;
  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_);
  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);
  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);
  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));
  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);
  vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

vec4 grad4(float j, vec4 ip) {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p, s;
  p.xyz = floor(fract(vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz * 2.0 - 1.0) * s.www;
  return p;
}

float snoise4D(vec4 v) {
  const vec4 C = vec4(0.138196601125011, 0.276393202250021, 0.414589803375032, -0.447213595499958);
  vec4 i = floor(v + dot(v, vec4(0.309016994374947451)));
  vec4 x0 = v - i + dot(i, C.xxxx);
  vec4 i0;
  vec3 isX = step(x0.yzw, x0.xxx);
  vec3 isYZ = step(x0.zww, x0.yyz);
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;
  vec4 i3 = clamp(i0, 0.0, 1.0);
  vec4 i2 = clamp(i0 - 1.0, 0.0, 1.0);
  vec4 i1 = clamp(i0 - 2.0, 0.0, 1.0);
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;
  i = mod289(i);
  float j0 = permute4(permute4(permute4(permute4(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute4(permute4(permute4(permute4(
    i.w + vec4(i1.w, i2.w, i3.w, 1.0))
    + i.z + vec4(i1.z, i2.z, i3.z, 1.0))
    + i.y + vec4(i1.y, i2.y, i3.y, 1.0))
    + i.x + vec4(i1.x, i2.x, i3.x, 1.0));
  vec4 ip = vec4(1.0 / 294.0, 1.0 / 49.0, 1.0 / 7.0, 0.0);
  vec4 p0_ = grad4(j0, ip);
  vec4 p1_ = grad4(j1.x, ip);
  vec4 p2_ = grad4(j1.y, ip);
  vec4 p3_ = grad4(j1.z, ip);
  vec4 p4_ = grad4(j1.w, ip);
  vec4 norm_ = taylorInvSqrt(vec4(dot(p0_, p0_), dot(p1_, p1_), dot(p2_, p2_), dot(p3_, p3_)));
  p0_ *= norm_.x;
  p1_ *= norm_.y;
  p2_ *= norm_.z;
  p3_ *= norm_.w;
  p4_ *= taylorInvSqrt(dot(p4_, p4_));
  vec3 m0 = max(0.6 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3, x3), dot(x4, x4)), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * (dot(m0 * m0, vec3(dot(p0_, x0), dot(p1_, x1), dot(p2_, x2)))
    + dot(m1 * m1, vec2(dot(p3_, x3), dot(p4_, x4))));
}

float fsnoise(vec2 c) {
  return fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453);
}


const float SAFE_EPS = 0.0001;
const float SAFE_DIV_EPS = 0.01;
const float SAFE_EXP_MAX = 40.0;
const float SAFE_TAN_LIMIT = 1.35;

float slog(float x) { return log(max(abs(x), SAFE_EPS)); }
vec2 slog(vec2 x) { return log(max(abs(x), vec2(SAFE_EPS))); }
vec3 slog(vec3 x) { return log(max(abs(x), vec3(SAFE_EPS))); }
vec4 slog(vec4 x) { return log(max(abs(x), vec4(SAFE_EPS))); }

float ssqrt(float x) { return sqrt(max(x, 0.0)); }
vec2 ssqrt(vec2 x) { return sqrt(max(x, vec2(0.0))); }
vec3 ssqrt(vec3 x) { return sqrt(max(x, vec3(0.0))); }
vec4 ssqrt(vec4 x) { return sqrt(max(x, vec4(0.0))); }

float sexp(float x) { return exp(clamp(x, -SAFE_EXP_MAX, SAFE_EXP_MAX)); }
vec2 sexp(vec2 x) { return exp(clamp(x, vec2(-SAFE_EXP_MAX), vec2(SAFE_EXP_MAX))); }
vec3 sexp(vec3 x) { return exp(clamp(x, vec3(-SAFE_EXP_MAX), vec3(SAFE_EXP_MAX))); }
vec4 sexp(vec4 x) { return exp(clamp(x, vec4(-SAFE_EXP_MAX), vec4(SAFE_EXP_MAX))); }

float stan(float x) { return tan(clamp(x, -SAFE_TAN_LIMIT, SAFE_TAN_LIMIT)); }
vec2 stan(vec2 x) { return tan(clamp(x, vec2(-SAFE_TAN_LIMIT), vec2(SAFE_TAN_LIMIT))); }
vec3 stan(vec3 x) { return tan(clamp(x, vec3(-SAFE_TAN_LIMIT), vec3(SAFE_TAN_LIMIT))); }
vec4 stan(vec4 x) { return tan(clamp(x, vec4(-SAFE_TAN_LIMIT), vec4(SAFE_TAN_LIMIT))); }

float sasin(float x) { return asin(clamp(x, -1.0 + SAFE_EPS, 1.0 - SAFE_EPS)); }
vec2 sasin(vec2 x) { return asin(clamp(x, vec2(-1.0 + SAFE_EPS), vec2(1.0 - SAFE_EPS))); }
vec3 sasin(vec3 x) { return asin(clamp(x, vec3(-1.0 + SAFE_EPS), vec3(1.0 - SAFE_EPS))); }
vec4 sasin(vec4 x) { return asin(clamp(x, vec4(-1.0 + SAFE_EPS), vec4(1.0 - SAFE_EPS))); }

float sacos(float x) { return acos(clamp(x, -1.0 + SAFE_EPS, 1.0 - SAFE_EPS)); }
vec2 sacos(vec2 x) { return acos(clamp(x, vec2(-1.0 + SAFE_EPS), vec2(1.0 - SAFE_EPS))); }
vec3 sacos(vec3 x) { return acos(clamp(x, vec3(-1.0 + SAFE_EPS), vec3(1.0 - SAFE_EPS))); }
vec4 sacos(vec4 x) { return acos(clamp(x, vec4(-1.0 + SAFE_EPS), vec4(1.0 - SAFE_EPS))); }

float spow(float a, float b) { return pow(max(abs(a), SAFE_EPS), b); }
vec2 spow(vec2 a, vec2 b) { return pow(max(abs(a), vec2(SAFE_EPS)), b); }
vec3 spow(vec3 a, vec3 b) { return pow(max(abs(a), vec3(SAFE_EPS)), b); }
vec4 spow(vec4 a, vec4 b) { return pow(max(abs(a), vec4(SAFE_EPS)), b); }
vec2 spow(vec2 a, float b) { return pow(max(abs(a), vec2(SAFE_EPS)), vec2(b)); }
vec3 spow(vec3 a, float b) { return pow(max(abs(a), vec3(SAFE_EPS)), vec3(b)); }
vec4 spow(vec4 a, float b) { return pow(max(abs(a), vec4(SAFE_EPS)), vec4(b)); }

float sdiv(float a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
vec2 sdiv(vec2 a, vec2 b) { return a / max(abs(b), vec2(SAFE_DIV_EPS)); }
vec3 sdiv(vec3 a, vec3 b) { return a / max(abs(b), vec3(SAFE_DIV_EPS)); }
vec4 sdiv(vec4 a, vec4 b) { return a / max(abs(b), vec4(SAFE_DIV_EPS)); }
vec2 sdiv(vec2 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
vec3 sdiv(vec3 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
vec4 sdiv(vec4 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
vec2 sdiv(float a, vec2 b) { return vec2(a) / max(abs(b), vec2(SAFE_DIV_EPS)); }
vec3 sdiv(float a, vec3 b) { return vec3(a) / max(abs(b), vec3(SAFE_DIV_EPS)); }
vec4 sdiv(float a, vec4 b) { return vec4(a) / max(abs(b), vec4(SAFE_DIV_EPS)); }
mat2 sdiv(mat2 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
mat3 sdiv(mat3 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }
mat4 sdiv(mat4 a, float b) { return a / max(abs(b), SAFE_DIV_EPS); }

float smod(float a, float b) { return mod(a, max(abs(b), SAFE_DIV_EPS)); }
vec2 smod(vec2 a, vec2 b) { return mod(a, max(abs(b), vec2(SAFE_DIV_EPS))); }
vec3 smod(vec3 a, vec3 b) { return mod(a, max(abs(b), vec3(SAFE_DIV_EPS))); }
vec4 smod(vec4 a, vec4 b) { return mod(a, max(abs(b), vec4(SAFE_DIV_EPS))); }
vec2 smod(vec2 a, float b) { return mod(a, max(abs(b), SAFE_DIV_EPS)); }
vec3 smod(vec3 a, float b) { return mod(a, max(abs(b), SAFE_DIV_EPS)); }
vec4 smod(vec4 a, float b) { return mod(a, max(abs(b), SAFE_DIV_EPS)); }

vec2 snormalize(vec2 v) { float l = length(v); return l > SAFE_EPS ? v / l : vec2(0.0); }
vec3 snormalize(vec3 v) { float l = length(v); return l > SAFE_EPS ? v / l : vec3(0.0); }
vec4 snormalize(vec4 v) { float l = length(v); return l > SAFE_EPS ? v / l : vec4(0.0); }

struct WB_CoordOut_e5aae421b099772a08d19408d3d19d21_coordinate_0_2_3faf5780 {
  highp vec3 coordinate;
};
WB_CoordOut_e5aae421b099772a08d19408d3d19d21_coordinate_0_2_3faf5780 WB_evalCoord_e5aae421b099772a08d19408d3d19d21_coordinate_0_2_3faf5780(highp vec3 wb_v_POS, highp float wb_v_t) {
  /*__WB_SCOPED_DONATION_SAFE_MATH__*/
  wb_v_POS.yz-=wb_v_t;
  WB_CoordOut_e5aae421b099772a08d19408d3d19d21_coordinate_0_2_3faf5780 wb_result;
  wb_result.coordinate = wb_v_POS;
  return wb_result;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 r = iResolution.xy;
  float t = iTime;
  vec4 o = vec4(0);

  vec3 RAY,POS,QPOS,ORI,V0,V1,P0;vec2 UV,UV2;float R0,S0,S1,EM,ED;vec4 VO;float II,DEP,STP;float s=0.;float i,a,x,g,h;for(;i++<90.;){vec3 p=vec3(sdiv((FC.xy-.5*r),r.y)*g+2.,g);p=mix(p,WB_evalCoord_e5aae421b099772a08d19408d3d19d21_coordinate_0_2_3faf5780(p,t).coordinate,1.00);p.zy*=rotate2D(.5);DEP=p.y;h=DEP+p.x*.3;p.z+=t;for(a=.6;a>.001;a*=.7)p.xz*=rotate2D(5.),x=sdiv((p.x+p.z),a)+t+t,DEP-=STP=sexp(sin(x)-3.)*a,h+=abs(dot(sin(sdiv(p.xz,a)*.3)*a,sdiv(r,r)));g+=DEP=min(DEP,h*.5-1.);o+=vec4(.01-sdiv(sdiv(.02,sexp(max(s,DEP)*3e3)),h));}

  fragColor = o;
}
