// ==== Image (image) ====
void mainImage(out vec4 O, vec2 I) {
    vec4 sceneAccum = vec4(0.0);
    vec2 invRes = 1.0 / iResolution.xy;
    
    for(int m = 0; m < 2; ++m) {
        for(int n = 0; n < 2; ++n) {
            vec2 jitter = vec2(float(m), float(n)) * 0.5 - 0.25;
            vec2 uv = ((I + jitter) + (I + jitter) - iResolution.xy) * invRes.y;
            
            vec3 ro = vec3(0.0, 0.0, 0.0);
            vec3 rd = normalize(vec3(uv, 1.45));
            
            float tm1 = iTime * 0.05;
            float c1 = cos(tm1), s1 = sin(tm1);
            mat2 r1 = mat2(c1, -s1, s1, c1);
            
            float tm2 = iTime * 0.03;
            float c2 = cos(tm2), s2 = sin(tm2);
            mat2 r2 = mat2(c2, -s2, s2, c2);
            
            vec3 offset = vec3(
                cos(iTime * 0.15) * 2.5,
                sin(iTime * 0.22) * 2.5,
                -iTime * 2.5
            );
            
            vec4 accum = vec4(0.0);
            float t = 0.04;
            float max_dist = 28.0;
            
            for (int i = 0; i < 64; ++i) {
                vec3 p = ro + rd * t;
                
                p.xy *= r1;
                p.xz *= r2;
                
                float rt = t * 0.06;
                float crt = cos(rt), srt = sin(rt);
                p.xy *= mat2(crt, -srt, srt, crt);
                
                p += offset;
                
                vec3 id = floor((p + 1.95) * 0.25641);
                p = (fract((p + 1.95) * 0.25641) * 3.9) - 1.95;
                
                float d1 = length(p) - 0.3;
                float d2 = length(p.xz) - 0.08;
                
                float h = clamp(0.5 + 1.25 * (d2 - d1), 0.0, 1.0);
                float d_box = mix(d2, d1, h) - 0.4 * h * (1.0 - h);
                
                float h2 = clamp(0.5 + 0.5 * sin(iTime * 0.2 + dot(id, vec3(0.15))), 0.0, 1.0);
                float d = mix(abs(d1), d2, h2) + 0.008;
                
                if (t > max_dist) break;
                
                float edge = smoothstep(0.0, 0.12, d_box);
                
                vec3 baseCol = sin(t * 0.35 + id * 0.25 + vec3(0.0, 2.0, 4.0)) * 0.5 + 0.5;
                vec4 col = vec4(baseCol * (1.0 + 5.0 * (1.0 - edge)), 1.0);
                
                float weight = exp(-t * 0.05);
                accum += col * (weight / (d * d * 180.0 + 1.0)) * 0.85;
                
                t += max(d * 0.55, 0.035);
            }
            
            accum *= (1.0 - exp(-t * 0.12));
            sceneAccum += accum;
        }
    }
    
    O = sceneAccum * 0.25;
    
    vec4 bloom = vec4(0.0);
    vec2 stepVal = 3.5 * invRes;
    O += bloom * 0.08;
    
    O.rgb = mix(O.rgb, vec3(dot(O.rgb, vec3(0.2126, 0.7152, 0.0722))), -0.15);
    O.rgb *= 1.3;
    
    O.rgb = O.rgb / (O.rgb + vec3(1.0));
    O = pow(O, vec4(0.4545));
}
