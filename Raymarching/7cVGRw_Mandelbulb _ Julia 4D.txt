// ==== Image (image) ====
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù                       PATRICK JAILLET                        ù
ù - https://patrickjaillet.github.io/sandefjord-software       ù
ù - https://x.com/JailletPatrick                               ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/

// Code golf 
#define R iResolution.xy
#define M(p) f=1., z=p; for(int i=0; i<12; i++) { r=length(z); if(r>4.) break; a=8.*acos(clamp(z.z/r,-1.,1.)); h=8.*atan(z.y,z.x); f=pow(r,7.)*8.*f+1.; z=pow(r,8.)*vec3(sin(a)*vec2(cos(h),sin(h)),cos(a))+p; } j=.5*log(r)*r/f;

void mainImage(out vec4 A, vec2 s) {
    vec2 B = (s + s - R) / R.y;
    float T = iTime, a = .3 * T, d = 0., g, t, r, h, f, j, mc, l;
    vec3 q = vec3(2.2 * sin(a), 1.2 * sin(1.1 * T), 2.2 * cos(a)),
         v = q - vec3(2.2 * sin(a - .05), 1.2 * sin(1.1 * (T - .05)), 2.2 * cos(a - .05)),
         c = vec3(0), b = c, pos, rd, z, n, oo, w, u;

    for (int step = 0; step < 8; step++) {
        g = t = 0.;
        oo = step == 0 ? q : q + v * (float(step) / 3.5 - 1.);
        w = normalize(-oo);
        u = normalize(cross(w, vec3(sin(1.), cos(1.), 0.)));
        rd = mat3(u, cross(u, w), w) * normalize(vec3(B, 8.));

        for (int o = 0; o < 128; o++) {
            pos = oo + rd * t;
            M(pos)
            g += exp(-2. * abs(j));
            t += j;
            if (j < .001 || t > 2.4) break;
        }

        vec3 p = vec3(0);
        if (t < 2.4) {
            vec2 e = vec2(.001, 0);
            M(pos - e.xyy) float o = j;
            M(pos - e.yxy) float C = j;
            M(pos - e.yyx) float D = j;
            M(pos)
            n = normalize(j - vec3(o, C, D));
            float E = max(0., dot(n, normalize(vec3(1, 8, -1)))),
                  m = clamp(.6 + .8 * n.y, 0., .6);
            mc = 1. + cos(4.9 - length(pos) * 2.8 + T * .2);
            l = E * 4.3 + m * .3;
            p = pow(vec3(mc * l), vec3(.4545));
        }
        p += g * .000625;
        if (step == 0) { c = p; d = t; }
        else b += p;
    }
    A = vec4(mix(c, b / 7., smoothstep(0., .8, abs(d - 1.2))), 1.);
}
/* Code original
#define MAX_STEPS 128
#define MAX_DIST 2.4
#define SURF_DIST 0.001

float mandelbulbSDF(vec3 pos) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;
    
    for(int i = 0; i < 12; i++) {
        r = length(z);
        if(r > 4.0) break;
        
        float theta = acos(clamp(z.z / r, -1.0, 1.0));
        float phi = atan(z.y, z.x);
        dr = pow(r, 7.0) * 8.0 * dr + 1.0;
        
        float zr = pow(r, 8.0);
        theta = theta * 8.0;
        phi = phi * 8.0;
        
        z = zr * vec3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
        z += pos;
    }
    return 0.5 * log(r) * r / dr;
}

float rayIntersect(vec3 ro, vec3 rd, out float glow) {
    float dO = 0.0;
    glow = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = mandelbulbSDF(p);
        glow += exp(-2.0 * abs(dS));
        dO += dS;
        if(dS < SURF_DIST || dO > MAX_DIST) break;
    }
    
    return dO;
}

vec3 calcNormal(vec3 p) {
    float d = mandelbulbSDF(p);
    vec2 e = vec2(0.001, 0.0);
    vec3 n = d - vec3(
        mandelbulbSDF(p - e.xyy),
        mandelbulbSDF(p - e.yxy),
        mandelbulbSDF(p - e.yyx)
    );
    return normalize(n);
}

mat3 setCamera(vec3 ro, vec3 ta, float cr) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    return mat3(cu, cv, cw);
}

vec3 render(vec3 ro, vec3 rd, out float outD) {
    float glow = 0.0;
    float d = rayIntersect(ro, rd, glow);
    outD = d;
    
    vec3 col = vec3(0.0);
    
    if(d < MAX_DIST) {
        vec3 pos = ro + rd * d;
        vec3 nor = calcNormal(pos);
        vec3 light1 = normalize(vec3(1.0, 8.0, -1.0));
        vec3 light2 = normalize(vec3(5.6, -1.0, 2.0));
        
        float dif1 = clamp(dot(nor, light1), 0.0, 1.0);
        float dif2 = clamp(dot(nor, light2), 0.0, 0.0);
        float amb = clamp(0.6 + 0.8 * nor.y, 0.0, 0.6);
        float fre = pow(clamp(0.0 + dot(nor, rd), 0.0, 0.0), 3.0);
        
        float matCol = 1.0 + 1.0 * cos(4.9 + length(pos) * -2.8 + iTime * 0.2);
        
        float lin = 0.0;
        lin += dif1 * 4.3;
        lin += dif2 * 0.5;
        lin += amb * 0.3;
        lin += fre * 8.0;
        
        col = vec3(matCol * lin);
        col = pow(col, vec3(0.4545));
    }
    
    col += glow * vec3(0.08) * (1.0 / float(MAX_STEPS));
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    
    float an = 0.3 * iTime;
    vec3 ro = vec3(2.2 * sin(an), 1.2 * sin(1.1 * iTime), 2.2 * cos(an));
    vec3 ta = vec3(0.0, 0.0, 0.0);
    
    vec3 prevRo = vec3(2.2 * sin(an - 0.05), 1.2 * sin(1.1 * (iTime - 0.05)), 2.2 * cos(an - 0.05));
    vec3 camVel = ro - prevRo;
    
    mat3 ca = setCamera(ro, ta, 1.0);
    vec3 rd = ca * normalize(vec3(p, 8.0));
    
    float d = 0.0;
    vec3 col = render(ro, rd, d);
    
    vec3 blurCol = vec3(0.0);
    int samples = 8;
    for(int i = 1; i < 8; i++) {
        float t = float(i) / float(samples - 1) - 0.5;
        vec3 offsetRo = ro + camVel * t * 2.0;
        mat3 offsetCa = setCamera(offsetRo, ta, 1.0);
        vec3 offsetRd = offsetCa * normalize(vec3(p, 8.0));
        float dummyD = 0.0;
        blurCol += render(offsetRo, offsetRd, dummyD);
    }
    blurCol /= float(samples - 1);
    
    float focalDist = 1.2;
    float blurAmount = smoothstep(0.0, 0.8, abs(d - focalDist));
    
    col = mix(col, blurCol, blurAmount);
    
    fragColor = vec4(col, 1.0);
}
*/
