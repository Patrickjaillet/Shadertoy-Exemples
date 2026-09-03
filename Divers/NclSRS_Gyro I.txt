// ==== Image (image) ====
#define SAMPLES 2.0
#define R iResolution.xy

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdGyroid(vec3 p, float scale, float thickness, float bias) {
    p *= scale;
    return abs(dot(sin(p), cos(p.zxy)) - bias) / scale - thickness;
}

float map(vec3 p) {
    float time = iTime * 0.2;
    float r2 = dot(p, p);
    p = p * 2.5 / r2;
    
    p.xz *= rot(time);
    p.yz *= rot(time * 0.5);
    
    float g1 = sdGyroid(p, 5.23, 0.03, 0.5);
    float g2 = sdGyroid(p, 10.76, 0.02, 0.3);
    
    return max(g1, -g2) * 0.4;
}
//*====================================================================================*//
//:: Processeur: AMD Ryzen 9 9950X3D2 ::                                                //
//:: RAM installée 256,0 Go DDR5      ::                                                //
//:: Stockage: Sabrent 16 TB SSD      ::                                                //
//:: Video: NVIDIA GeForce RTX 5090   ::                                                //
//:: Systeme: Kubuntu/Win11           ::                                                //
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  URL     : https://lside.xo.je                                                   //
//*====================================================================================*//
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 acc = vec3(0.0);
    float seed = fract(sin(dot(fragCoord, vec2(12.989, 78.233))) * 43758.545);

    for(float m = 0.0; m < SAMPLES; m++) {
        vec2 uv = (2.0 * (fragCoord + seed) - R) / R.y;
        vec3 rd = normalize(vec3(uv, 1.2));
        vec3 ro = vec3(0.0, 0.0, -1.5);
        
        float d = 0.2, tr = 1.0;
        vec3 col = vec3(0.0);

        for(float i = 0.0; i < 100.0; i++) {
            vec3 p = ro + rd * d;
            float s = map(p);
            
            float den = smoothstep(0.05, 0.0, abs(s)) * exp(-d * 0.2);
            
            if(den > 0.0) {
                float beam = pow(den, 4.0);
                vec3 lCol = mix(vec3(0.1, 0.4, 0.8), vec3(0.9, 0.2, 0.1), sin(d * 0.5 - iTime) * 0.5 + 0.5);
                
                col += lCol * beam * tr * 0.5;
                col += vec3(0.5, 0.7, 1.0) * den * tr * 0.02; 
                
                tr *= (1.0 - den * 0.6);
            }
            
            d += max(abs(s) * 0.5, 0.015);
            if(d > 15.0 || tr < 0.01) break;
        }
        acc += col;
    }
    
    vec3 final = acc / SAMPLES;
    
    final = pow(final, vec3(1.1));
    final *= 3.5;
    
    vec3 rgbShift = vec3(1.02, 1.0, 0.98);
    final = aces(final * rgbShift);
    
    final = pow(final, vec3(1.0 / 2.2));
    
    vec2 uv_norm = fragCoord / R;
    final *= smoothstep(1.5, 0.5, length((uv_norm - 0.5) * 2.0));
    final += (seed - 0.5) * 0.005;

    fragColor = vec4(final, 1.0);
}
