// ==== Image (image) ====
#define H(p) fract(sin(dot(p, vec3(12.989, 78.233, 45.164))) * 43758.545)
#define M(a) mat2(cos(a*0.5), -sin(a*0.8), sin(a*0.8), cos(a*0.5))

float N(vec3 x) {
    vec3 i = floor(x), f = fract(x);
    f *= f * (3.0 - 2.0 * f);
    return mix(mix(mix(H(i), H(i + vec3(1,0,0)), f.x), mix(H(i + vec3(0,1,0)), H(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(H(i + vec3(0,0,1)), H(i + vec3(1,0,1)), f.x), mix(H(i + vec3(0,1,1)), H(i + vec3(1,1,1)), f.x), f.y), f.z);
}

float F(vec3 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 6; i++) {
        v += a * N(p + sin(p.x * 0.5 + iTime * 1.2) * cos(p.z * 0.5 + iTime * 0.8));
        p = p * 2.4 + vec3(0.0, iTime * 0.04, iTime * -0.1);
        a *= 0.48;
    }
    return v;
}
float L(vec3 p, float fq) {
    float t = floor(iTime * 14.0), s = H(vec3(t, 1.0, 1.0)), b = 0.0;
    if (s > fq) return 0.0;
    vec3 c = vec3((H(vec3(t, 0.2, 0.5)) - 0.5) * 25.0, 18.0, 15.0 + (H(vec3(t, 0.9, 0.1)) - 0.5) * 10.0),
         e = vec3(c.x + (H(vec3(t, 0.3, 0.8)) - 0.5) * 10.0, -2.0, c.z + (H(vec3(t, 0.1, 0.4)) - 0.5) * 10.0);
    for (int i = 0; i < 6; i++) {
        vec3 n = mix(c, e, (float(i) + 1.0) / 6.0) + (vec3(H(c), H(c + 1.2), H(c + 2.4)) - 0.5) * 4.0;
        vec3 pa = p - c, ba = n - c;
        float d = length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
        b += exp(-d * 3.5) * 1.5 + exp(-d * 45.0) * 8.0;
        c = n;
    }
    return b * (sin(iTime * 80.0) * 0.5 + 0.5);
}

float map(vec3 p) {
    vec3 nP = p * 0.56; nP.z += iTime * 2.0;
    float m = sin(p.x * 0.4 + iTime) * 0.5 + cos(p.z * 0.3 + iTime * 1.5) * 0.5;
    return p.y + pow(F(nP + m * 0.2), 1.3) * 3.2 + m * 0.4;
}

void mainImage(out vec4 O, vec2 U) {
    vec2 u = (U - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 4.0, 0.0), rd = normalize(vec3(u.x, u.y - 0.4, 1.2)), col = vec3(0.0);
    rd.xy *= M(sin(iTime * 0.6) * 0.18);
 
    
    float t = 0.0, d, g = 0.0, sk = L(ro + rd * 20.0, 0.12);
    for(int i = 0; i < 80; i++) {
        d = map(ro + rd * t);
        g += exp(-max(d, 0.0) * 1.8);
        if(d < 0.01 || t > 40.0) break;
        t += d * 0.5;
    }

    if (t < 40.0) {
        vec3 p = ro + rd * t, e = vec3(0.02, 0.0, 0.0),
             n = normalize(vec3(map(p+e.xyy)-map(p-e.xyy), map(p+e.yxy)-map(p-e.yxy), map(p+e.yyx)-map(p-e.yyx)));
        float f = F(p * 0.35);
        vec3 alb = mix(mix(vec3(0.9, 0.05, 0.0), vec3(1.0, 0.35, 0.0), f * 1.8), vec3(1.0, 1.0, 0.6), pow(f, 4.0));
        vec3 lp = normalize(vec3(0.0, 10.0, 10.0) - p), h = normalize(-rd + lp);
        float pbr = 0.04 + 0.96 * pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        pbr *= ( 0.16 / (3.14159 * pow(max(dot(n, h), 0.0) * -0.84 + 1.0, 2.0)));
        col = alb * pbr * max(dot(n, lp), 0.0) + alb * pow(f, 2.0) * 6.0 + vec3(0.5, 0.8, 1.0) * L(p, 0.12) * 100.0;
        col *= exp(-0.04 * t);
    } else {
        vec3 brd = rd; 
        brd.yz *= M(sin(iTime * 0.1) * 0.4); 
        brd.xz *= M(iTime * 0.05);
        
        col = vec3(0.15, 0.03, 0.01) * F(brd * 1.5 + iTime * 0.05);
        
        for(float i = 1.0; i < 4.0; i++) {
            vec3 q = brd * (15.0 + i * 7.0);
            vec3 id = floor(q);
            vec3 fd = fract(q) - 0.5;
            float r = H(id);
            if(r > 0.92) {
                float pulse = sin(iTime * 3.0 * r) * 0.5 + 0.5;
                col += pulse * vec3(1.0, 0.9, 0.8) * smoothstep(0.15, 0.0, length(fd) - 0.005 * i);
            }
        }
        col += vec3(0.2, 0.05, 0.0) * pow(1.0 - max(rd.y + 0.4, 0.0), 3.0);
    }
    
    col += vec3(0.5, 0.8, 1.0) * sk * 35.0 + vec3(1.0, 0.4, 0.1) * g * 0.03;
    col = clamp((col * (2.51 * col + 0.03)) / (col * (2.43 * col + 0.59) + 0.14), 0.0, 1.0);
    O = vec4(pow(col * 0.85, vec3(0.4545)), 1.0);
    O = tan(O);
}
