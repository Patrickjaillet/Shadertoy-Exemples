// ==== Image (image) ====
void mainImage(out vec4 o, vec2 u) {
    vec3 R = iResolution, 
         D = normalize(vec3((u + u - R.xy) / R.y, 0.5)),
         p, q, n, col;
    float i, d = 0.0, s, a, t = iTime, 
          iter = 150.,
          glow = 0.0;

    o = vec4(0);

    for(i = 0.; i < iter; i++) {
        p = D * d;
        p.z -= t * 25.;
        
        float angle = t * .1 + p.z * .1;
        float c = cos(angle), sh = sin(angle);
        p.xy *= mat2(c, -sh, sh, c);

        q = mod(p, 50.) - 25.;
        s = length(q) - 20.;

        float freq = 0.8;
        float amp = 1.2;
        for(int j = 0; j < 6; j++) {
            vec3 v = p / freq + t * 0.8;
            s += abs(dot(sin(v), cos(v.yzx * 1.15))) * amp;
            freq *= 1.8;
            amp *= 0.45;
        }

        s = max(abs(s), 0.0015 * (1.0 + d * 0.1));
        
        if(d > 400.0) break;

        float weight = exp(-0.02 * d);
        vec3 spectral = .5 + .5 * cos(log2(1.0 + d) * .6 + vec3(0, 2, 4) - t);
        o.rgb += spectral * (0.012 / s) * weight;
        
        glow += 0.005 / (s * (1.0 + d * 2.05));
        
        d += s * 0.55;
    }

    o.rgb += glow * vec3(0.2, 0.5, 0.9);
    
    o.rgb = 1.0 - exp(-o.rgb * 1.8);
    o.rgb = pow(o.rgb, vec3(0.4545));
    
    vec2 uv = u / R.xy;
    o.rgb *= 0.5 + 0.5 * pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.15);
    o.a = 1.0;
}
