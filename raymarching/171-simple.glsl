// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
// I use the 2 shaders below for the background:
//-------------------------------------------------------------
// Star Nest by Pablo Roman Andrioli
// - https://www.shadertoy.com/view/XlfGRj
// Starship by @XorDev
// - https://www.shadertoy.com/view/l3cfW4
// ------------------------------------------------------------
// To avoid using iChannel0, the texture noise in the second
// shader was replaced by direct procedural noise.
float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 getStarfield(vec2 fragCoord, vec2 resolution, float timeVal, vec4 mouseVal) {
    vec2 uv = fragCoord / resolution.xy - .5;
    uv.y *= resolution.y / resolution.x;
    vec3 dir = vec3(uv * 0.800, 1.);
    float time = timeVal * 0.010 + .25;

    float a1 = .5 + mouseVal.x / resolution.x * 2.;
    float a2 = .8 + mouseVal.y / resolution.y * 2.;
    mat2 rot1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
    mat2 rot2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
    dir.xz *= rot1;
    dir.xy *= rot2;
    
    vec3 from = vec3(1., .5, 0.5);
    from += vec3(time * 2., time, -2.);
    from.xz *= rot1;
    from.xy *= rot2;
    
    float s = 0.1, fade = 1.;
    vec3 v = vec3(0.);
    for (int r = 0; r < 20; r++) {
        vec3 p = from + s * dir * .5;
        p = abs(vec3(0.850) - mod(p, vec3(1.700)));
        float pa, a = pa = 0.;
        for (int i = 0; i < 17; i++) { 
            p = abs(p) / dot(p, p) - 0.53;
            a += abs(length(p) - pa);
            pa = length(p);
        }
        float dm = max(0., 0.300 - a * a * .001);
        a *= a * a;
        if (r > 6) fade *= 1. - dm;
        v += fade;
        v += vec3(s, s * s, s * s * s * s) * a * 0.0015 * fade;
        fade *= 0.730;
        s += 0.1;
    }
    v = mix(vec3(length(v)), v, 0.850);
    return v * .01;
}

vec3 getWaveLayer(vec2 I, vec2 r, float t) {
    vec2 p = (I + I - r) / r.y * mat2(3, 4, 4, -3) / 1e2;
    vec4 S = vec4(0), C = vec4(1, 2, 3, 0), W;
    float T = .1 * t + p.y;
    
    for(float i = 0.; i++ < 50.;) {
        W = sin(i) * C;
        float noiseVal = hash21(p / exp(W.x) + vec2(i, t) / 8.);
        
        S += (cos(W) + 1.)
           * exp(sin(i + i * T))
           / length(max(p, p / vec2(2, noiseVal * 40.))) 
           / 1e4;
           
        p += .02 * cos(i * (C.xz + 8. + i) + T + T);
    }
    
    return tanh(p.x * (--C).rgb + (S * S).rgb);
}

void mainImage(out vec4 S, vec2 T) {
    vec3 u = vec3(0);
    
    vec3 bgStars = getStarfield(T, iResolution.xy, iTime, iMouse);
    vec3 bgWaves = getWaveLayer(T, iResolution.xy, iTime);
    
    vec3 background = bgWaves + bgStars;

    for(float h = 0.; h < 4.; h++) {
        float v = iTime + (h * .25 - .5) * .03, 
              i = v / 3., 
              c = floor(mod(i, 20.)), 
              d = floor(mod(i + 1., 20.)), 
              
              progress = fract(i),
              e = smoothstep(0.6, 1.0, progress), 
              
              w = c * 2.4, 
              z = 2.2 + 1.2 * sin(c * 1.7), 
              A = d * 2.4, 
              B = 2.2 + 1.2 * sin(d * 1.7), 
              k = 0., 
              G = v * .2, 
              H = sin(G), 
              cR = cos(G), 
              ac = mix(2.4 + .2 * cos(c * 1.5), 2.4 + .2 * cos(d * 1.5), e);

        vec3 C = mix(vec3(cos(w) * z, .3 + cos(c * 2.3), sin(w) * z), vec3(cos(A) * B, .3 + cos(d * 2.3), sin(A) * B), progress),
             j = normalize(mix(vec3(sin(c * 1.1) * .4, cos(c * .9) * .3, 0), vec3(sin(d * 1.1) * .4, cos(d * .9) * .3, 0), progress) - C),
             D = normalize(cross(j, vec3(0, 1, 0))), 
             Z = cross(D, j),
             _ = normalize(vec3((T - .5 * iResolution.xy) / iResolution.y, 1.2) * mat3(D, Z, j)),
             F = C, 
             l = vec3(0), 
             J = mix(vec3(1, 0, .8 + .2 * sin(c)), vec3(1, 0, .8 + .2 * sin(d)), e);

        mat2 aa = mat2(cR, -H, H, cR), 
             ab = mat2(.995, -.1, .1, .995);

        bool hit = false;

        for(int n = 0; n < 80; n++) {
            vec3 a = F; 
            a.zx *= ab; 
            a.yz *= aa;
            float K = 1., L = 1e2; 
            int M = 0;
            
            for(int p = 0; p < 8; p++) {
                a = ac * clamp(a, -J, J) - a;
                float q = dot(a, a);
                if(q < L) L = q, M = p;
                float N = 1.2 / clamp(q, 0., 1.);
                a *= N; 
                K *= N;
            }
            
            float g = length(a) / K, 
                  s = abs(k - 2.8) * .12, 
                  P = .005 + s * .05, 
                  Q = 1. + s * 8., 
                  R = max(g * .3, .005 + s * .02);
            vec3 O = cos(vec3(M) * 1.1 + vec3(0, 2, 4)) * .35 + .6;
            
            if(g < P) {
                l += mix(vec3(1), O, .35) * (1. - float(n) / 80.) * 1.4 * smoothstep(P, 0., g);
                hit = true;
                break;
            }
            l += O * (.045 / Q) * exp(-g * (1.8 / Q));
            k += R; 
            F += _ * R;
            if(k > 7.7) break;
        }
        
        vec3 foreground = min(l * 1.2, vec3(1));
        u += hit ? foreground : background;
    }
    S = vec4(u * .25, 1);
}
