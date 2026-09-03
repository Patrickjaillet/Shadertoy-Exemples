// ==== Image (image) ====
//*====================================================================================*//
//  											//
//  _______ _______ _______ _______ _______ _______ _______ _____  _______ ______ 	//
// |   |   |    ___|_     _|   _   |     __|   |   |   _   |     \|    ___|   __ \	//
// |       |    ___| |   | |       |__     |       |       |  --  |    ___|      <	//
// |__|_|__|_______| |___| |___|___|_______|___|___|___|___|_____/|_______|___|__|	//
//											//
//======================================================================================//
//:: [ GLSL / HLSL / WGSL / MSL / SPIR-V ] ::						//
//======================================================================================//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░▒░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒░░░░░░░░░░░░░░░░ ░░░▒░░░░░░░░░░░░░░░▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒░░░░░░░░░░░░░░░▒░░░░▒░░▒░░░░░░░░░▒▒░░░░░▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒░░░░░░░░░░░░░░░░░░░░▒▒▒░░▒▒▒░░▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░   ░░░░░░░░░▒▒▒░▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒░░░░░░░░░ ░▒▒▒▒▒░ ░░░░░░░▒░░░░▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ░ ▒░░░░░░░░░▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒░░░░░ ▒▒▓▒▓▒▒▒▒░░ ░░░░░░░▒▒░░░░░░░░░░░ ▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▓▓ ░░░ ▒▒▒▓▓▒▒░▓▒░░ ░░░░░░░▒▒▒▒░░░░░░░░░░░ ▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▓▒▒░░░▒▒▒▒▓▓▓░▓▓ ░░░░░░░░░▒▒▒▒▒▒░░░░░░░ ░░░░▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▓▒▓▓░▒▒▓▓▓▓▓▓░▓▓ ░ ░░░░░░▒▒▒▒▒▒▒▒░░░▒▒▒▒░░░░░▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▓▒▓▓▒▓▓▓▓▓▓▓▒▒▓▓ ░▒░░░░░░▒▒▒▒▒▒▒▒░▒▒▒▒▒░ ░░░░░▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▓░░░░▒░▓▓▓▓▓▓▓▓▒▒▒░░ ░░░░ ░▒▒▒▒▒▒▒▒░▓▒▒░░░▒▒▒▒▒░░▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▓▓▓▓▓▓▓▒░░▒▒▒▒▒▒░░▒▒▒░  ▒ ░▒▒▒▒▒▒░▒▒░ ▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░   ░▒▒▒▒▒▒▒▒▒▒▒▒░ ░░ ▒ ▒▒░ ░▒▒▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░    ░▒▒▒▒▒▒▒▒░ ░░░░░▒ ▒▒░░▒▒░░░  ▒▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░   ░░░░░░░░░░  ░░▒▒▒▒░░ ▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░ ░    ░░▒▒▒▒▒▒░▒░░░░▒▒▒▒▒  ░░▒▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░ ░░     ░░░░░░░░ ░▒▒▒░ ░▒░░░▒░░░ ▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░ ░▒▒▒▒▒▒░░░░░░░░░ ░░ ▒▒▒░░▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒//
//▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒░░░░  ░ ░ ░▒▒░░░░░░░░▒▒▒░░░ ▒▒▒▒▒▒▒▒//
//======================================================================================//
//:: [ CREDITS ] ::									//
//======================================================================================//
//  >>  Author  : Patrick JAILLET							//
//  >>  Email   : metashader@proton.me							//
//  >>  Engine  : MetaShader								//
//  >>  URL     : https://0110110101110011.netlify.app					//
//*====================================================================================*//
//  SONIC THE HEDGEHOG
//   · Normales tétraèdre 4-tap (vs 6-tap)
//   · Over-relaxation raymarching (sphere tracing Keinert)
//   · Bounding-sphere hierarchy par partie
//   · Soft shadows analytiques
//   · AO 5-tap SDF
//   · PBR Fresnel + GGX
//   · ACES filmic tonemapping
// ============================================================

#define TEMPS iTime
#define RES   iResolution.xy

float sdSphere(vec3 p, float s) { return length(p) - s; }

float sdEllipsoid(vec3 p, vec3 r) {
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCone(vec3 p, vec2 c, float h) {
    float q = length(p.xz);
    return max(dot(c.xy,vec2(q,p.y)), -h-p.y);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa=p-a, ba=b-a;
    return length(pa - ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0)) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
    return mix(b,a,h) - k*h*(1.0-h);
}

vec3 rotX(vec3 p, float a) {
    float c=cos(a),s=sin(a);
    return vec3(p.x, c*p.y-s*p.z, s*p.y+c*p.z);
}
vec3 rotY(vec3 p, float a) {
    float c=cos(a),s=sin(a);
    return vec3(c*p.x+s*p.z, p.y, -s*p.x+c*p.z);
}
vec3 rotZ(vec3 p, float a) {
    float c=cos(a),s=sin(a);
    return vec3(c*p.x-s*p.y, s*p.x+c*p.y, p.z);
}

float sdMain(vec3 p) {
    p = rotX(p, 3.14159);
    p = rotY(p, -1.57);
    float paume = length(p*vec3(1.0,1.1,1.2)) - 0.12;
    float d1 = sdCapsule(p, vec3(0.06,0.05,0.0),  vec3(0.07,0.22,0.02),  0.035);
    float d2 = sdCapsule(p, vec3(0.0,0.06,0.0),   vec3(0.0,0.25,0.0),    0.038);
    float d3 = sdCapsule(p, vec3(-0.06,0.05,0.0), vec3(-0.07,0.21,-0.01),0.035);
    float d4 = sdCapsule(p, vec3(-0.08,-0.02,0.05),vec3(-0.18,0.05,0.22),0.045);
    float doigts = min(min(d1,d2),min(d3,d4));
    float corps  = smin(paume, doigts, 0.05);
    float collerette = length(vec2(length(p.xz)-0.11, p.y+0.15)) - 0.05;
    return min(corps, collerette);
}

vec2 opU(vec2 a, vec2 b) { return (a.x < b.x) ? a : b; }

vec2 map(vec3 p) {
    float vib = sin(TEMPS*50.0)*0.004;
    p.y += vib;

    vec2 res = vec2(1e9, 0.0);
    float bsHead = length(p - vec3(0.0,0.65,0.0)) - 0.98;
    if(bsHead < 0.02) {
        vec3 ph = p - vec3(0.0,0.65,0.0);
        float teteBase = sdSphere(ph, 0.48);
        float pic1 = sdEllipsoid(ph-vec3( 0.0, 0.25,0.55), vec3(0.10,0.12,1.0));
        float pic2 = sdEllipsoid(ph-vec3( 0.32,0.05,0.50), vec3(0.10,0.12,0.9));
        float pic3 = sdEllipsoid(ph-vec3(-0.32,0.05,0.50), vec3(0.10,0.12,0.9));
        float pics = smin(pic1, smin(pic2,pic3,0.2), 0.2);
        float tete = smin(teteBase, pics, 0.08);
        float oD = sdCone(p-vec3( 0.35,1.0,0.1), vec2(0.6,0.8), 0.25);
        float oG = sdCone(p-vec3(-0.35,1.0,0.1), vec2(0.6,0.8), 0.25);
        tete = smin(tete, min(oD,oG), 0.05);
        res = opU(res, vec2(tete, 1.0));
    } else res.x = min(res.x, bsHead);

    float bsFace = length(p - vec3(0.0,0.55,-0.3)) - 0.65;
    if(bsFace < 0.02) {
        float museau     = sdEllipsoid(p-vec3(0.0, 0.5,-0.35),  vec3(0.32,0.22,0.30));
        float nez        = sdSphere   (p-vec3(0.0, 0.58,-0.63), 0.07);
        float masqueYeux = sdEllipsoid(p-vec3(0.0, 0.72,-0.35), vec3(0.32,0.22,0.12));
        float pupD = sdEllipsoid(p-vec3( 0.10,0.72,-0.45), vec3(0.05,0.12,0.04));
        float pupG = sdEllipsoid(p-vec3(-0.10,0.72,-0.45), vec3(0.05,0.12,0.04));
        res = opU(res, vec2(museau,     2.0));
        res = opU(res, vec2(nez,        3.0));
        res = opU(res, vec2(masqueYeux, 4.0));
        res = opU(res, vec2(min(pupD,pupG), 3.0));
    } else res.x = min(res.x, bsFace);

    float bsBody = length(p - vec3(0.0,0.0,0.0)) - 0.92;
    if(bsBody < 0.02) {
        float corps = sdEllipsoid(p-vec3(0.0,0.05,0.0), vec3(0.32,0.42,0.32));
        float brasD = sdEllipsoid(p-vec3( 0.38,0.15,-0.1), vec3(0.06,0.25,0.06));
        float brasG = sdEllipsoid(p-vec3(-0.38,0.15,-0.1), vec3(0.06,0.25,0.06));
        corps = smin(corps, min(brasD,brasG), 0.1);

        vec3 pmD = rotZ(p-vec3( 0.45,-0.15,-0.15), -0.05);
        float mainD = sdMain(vec3(-pmD.x, pmD.yz));
        float mainG = sdMain(rotZ(p-vec3(-0.45,-0.15,-0.15), 0.4));

        float jamD = sdCylinder(p-vec3( 0.15,-0.35,0.0), 0.25, 0.07);
        float jamG = sdCylinder(p-vec3(-0.15,-0.35,0.0), 0.25, 0.07);
        corps = smin(corps, min(jamD,jamG), 0.05);

        float chD = sdEllipsoid(p-vec3( 0.18,-0.65,-0.1), vec3(0.15,0.12,0.28));
        float chG = sdEllipsoid(p-vec3(-0.18,-0.65,-0.1), vec3(0.15,0.12,0.28));

        res = opU(res, vec2(corps,          1.0));
        res = opU(res, vec2(min(mainD,mainG),4.0));
        res = opU(res, vec2(min(chD,chG),    5.0));
    } else res.x = min(res.x, bsBody);

    float sol = p.y + 0.80 + sin(p.x*1.5 + TEMPS*5.0)*0.10;
    res = opU(res, vec2(sol, 6.0));

    return res;
}


vec3 calcNormal(vec3 p) {
    const float h = 0.0005;
    const vec2  k = vec2(1.0,-1.0);
    return normalize(
        k.xyy * map(p + k.xyy*h).x +
        k.yyx * map(p + k.yyx*h).x +
        k.yxy * map(p + k.yxy*h).x +
        k.xxx * map(p + k.xxx*h).x
    );
}


float softShadow(vec3 ro, vec3 rd, float tmin, float tmax, float k) {
    float res = 1.0;
    float t   = tmin;
    float ph  = 1e10;
    for(int i=0; i<24; i++) {
        float h = map(ro + rd*t).x;
        if(h < 0.001) return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h - y*y);
        res = min(res, k*d/max(0.0, t-y));
        ph  = h;
        t  += h;
        if(res < 0.005 || t > tmax) break;
    }
    return clamp(res, 0.0, 1.0);
}


float calcAO(vec3 pos, vec3 nor) {
    float occ = 0.0;
    float sca  = 1.0;
    for(int i=0; i<5; i++) {
        float hr = 0.01 + 0.15*float(i)/4.0;
        float dd = map(pos + hr*nor).x;
        occ += (hr - dd)*sca;
        sca *= 0.85;
    }
    return clamp(1.0 - 3.0*occ, 0.0, 1.0);
}


float GGX(float NoH, float rough) {
    float a  = rough*rough;
    float a2 = a*a;
    float d  = (NoH*a2 - NoH)*NoH + 1.0;
    return a2 / (3.14159*d*d);
}

float schlick(float cosTheta, float F0) {
    return F0 + (1.0-F0)*pow(1.0-cosTheta, 5.0);
}


vec3 ACESFilm(vec3 x) {
    float a=2.51, b=0.03, c=2.43, d=0.59, e=0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}


vec2 castRay(vec3 ro, vec3 rd) {
    float t    = 0.02;
    float prev = 0.0;
    float candidate = 0.0;
    float omega = 1.3;     
    bool  relax = true;

    for(int i=0; i<96; i++) {
        vec2  res = map(ro + rd*t);
        float h   = res.x;

        if(relax) {
            float step = h * omega;
            if(prev + h < candidate) {
              
                t         -= candidate;
                candidate  = 0.0;
                relax      = false;
                continue;
            }
            candidate = step;
            prev      = h;
            t        += step;
        } else {
            t    += h;
            relax = true;
        }

        if(h < 0.0005 || t > 14.0) {
            if(h < 0.0005) return vec2(t, res.y);
            return vec2(-1.0, 0.0);
        }
    }
    return vec2(-1.0, 0.0);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5*RES) / RES.y;

    vec2 jitter = (fract(sin(vec2(fragCoord.x*127.1, fragCoord.y*311.7))*43758.5453) - 0.5) / RES;
    uv += jitter * 0.5;

    float shake = pow(sin(TEMPS*10.0), 0.0)*0.015;
    vec3 ro = vec3(0.5*sin(TEMPS*0.5), 0.5+shake, 2.5*cos(TEMPS*0.5));
    vec3 target = vec3(0.0, 0.1, 0.0);
    vec3 ww = normalize(target - ro);
    vec3 uu = normalize(cross(ww, vec3(0,1,0)));
    vec3 vv = cross(uu, ww);
    vec3 rd = normalize(uv.x*uu + uv.y*vv + 1.2*ww);

    float starField = step(0.998, fract(sin(dot(floor(rd.xy*120.0), vec2(127.1,311.7)))*43758.5));
    vec3 sky = mix(vec3(0.02,0.04,0.12), vec3(0.05,0.08,0.22), clamp(-rd.y*0.5+0.5,0.0,1.0));
    sky += starField * 0.8;
    vec3 col = sky;

    vec2 h = castRay(ro, rd);

    if(h.x > 0.0) {
        vec3 pos = ro + rd*h.x;
        vec3 nor = calcNormal(pos);

        vec3 albedo = vec3(0);
        float rough = 0.5;
        float metal = 0.0;
        if(h.y < 1.5)  { albedo=vec3(0.0,0.18,0.95);  rough=0.35; metal=0.0; }
        if(h.y > 1.5 && h.y < 2.5) { albedo=vec3(1.0,0.82,0.65); rough=0.6; metal=0.0; }
        if(h.y > 2.5 && h.y < 3.5) { albedo=vec3(0.02,0.02,0.02);rough=0.8; metal=0.0; }
        if(h.y > 3.5 && h.y < 4.5) { albedo=vec3(0.97,0.97,0.97);rough=0.15;metal=0.0; }
        if(h.y > 4.5 && h.y < 5.5) { albedo=vec3(1.0,0.02,0.02); rough=0.4; metal=0.0; }
        if(h.y > 5.5) {
            vec2 tile = floor(pos.xz);
            float checker = mod(tile.x+tile.y, 2.0);
            albedo = mix(vec3(0.06,0.32,0.06), vec3(0.12,0.48,0.10), checker);
            rough  = 0.9;
        }

        vec3 sunDir = normalize(vec3(1.0,2.0,1.0));
        vec3 skyDir = normalize(vec3(0.0,1.0,0.0));
        vec3 V = -rd;
        vec3 H = normalize(sunDir + V);
        float NoL   = max(dot(nor, sunDir), 0.0);
        float NoV   = max(dot(nor, V),      0.0);
        float NoH   = max(dot(nor, H),      0.0);
        float VoH   = max(dot(V, H),        0.0);

        float sha = softShadow(pos+nor*0.002, sunDir, 0.005, 6.0, 18.0);

        float ao = calcAO(pos, nor);

        float skyLight = 0.5 + 0.5*nor.y;

        vec3 diffuse = albedo * (NoL*sha + skyLight*ao*0.25);

        float F0  = mix(0.04, 0.9, metal);
        float fre = schlick(VoH, F0);
        float D   = GGX(NoH, rough);
        vec3  spec= vec3(fre*D) * sha * NoL * (1.0/(4.0*NoL*NoV+0.001));

        float rim = pow(max(0.0, 1.0+dot(nor,rd)), 3.0);
        vec3 rimCol = rim * vec3(0.3,0.55,1.0) * ao * 0.4;

        col = diffuse + spec + rimCol;

        float fog = 1.0 - exp(-0.04*h.x*h.x);
        col = mix(col, sky, fog);
    }

    float speedLines = pow(max(0.0, 1.0 - length(uv*vec2(0.18,1.0))), 12.0);
    col += speedLines * vec3(0.3,0.6,1.0) * abs(sin(TEMPS*28.0)) * 0.5;

    float vignette = smoothstep(0.0, 1.0, 1.0 - length(uv)*0.85);
    col *= vignette;

    float ca = 0.0015;
    vec2 caUV = uv * ca;
    col.r = mix(col.r, col.r + dot(caUV, vec2(1.0)), 0.3);
    col.b = mix(col.b, col.b - dot(caUV, vec2(1.0)), 0.3);

    col = ACESFilm(col * 1.1);
    col = pow(col, vec3(1.0/2.2));

    fragColor = vec4(col, 1.0);
}
