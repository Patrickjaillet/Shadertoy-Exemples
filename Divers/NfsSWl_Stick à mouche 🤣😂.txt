// ==== Image (image) ====
#define ITR 120
#define FAR 150.
#define time iTime
#define MOD3 vec3(.1031, .11369, .13787)
#define SUN_COLOUR vec3(1.0, 0.9, 0.7)
#define BIOLUM_COLOUR vec3(0.2, 0.8, 0.6)

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,s,-s,c);}
float tri(in float x){return abs(fract(x)-.5);}
vec3 tri3(in vec3 p){return vec3(tri(p.z+tri(p.y)), tri(p.z+tri(p.x)), tri(p.y+tri(p.x)));}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float Noise3d(in vec3 p) {
    float z=1.4;
    float rz = 0.;
    vec3 bp = p;
    for (float i=0.; i<= 3.; i++ ) {
        vec3 dg = tri3(bp);
        p += (dg);
        bp *= 1.1;
        z *= 1.5;
        p *= 1.3;
        rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
        bp += 0.14;
    }
    return rz;
}

float ridged(float h) {
    return 1.0 - abs(h - 0.5) * 2.0;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}

float tendril(vec3 p, float seed) {
    p.xz *= mm2(p.y * 0.2 + seed);
    p.x += sin(p.y * 0.4) * 2.0;
    float d = length(p.xz) - (0.5 + sin(p.y * 2.0 + time) * 0.1);
    return d;
}

float map(vec3 p) {
    vec2 uv = p.xz * 0.05;
    float h = 0.0;
    float amp = 1.5;
    float freq = 0.6;
    for(int i=0; i<6; i++) {
        h += ridged(Noise3d(vec3(uv * freq, 0.0).xyz)) * amp;
        uv *= mm2(0.8);
        freq *= 1.9;
        amp *= 0.45;
    }
    float terrain = p.y + h * 4.0;
    float structures = tendril(p - vec3(5.0, 0.0, 10.0), 1.0);
    structures = smin(structures, tendril(p + vec3(8.0, 2.0, -5.0), 4.5), 2.0);
    float disp = Noise3d(p * 0.5) * 0.3;
    return smin(terrain, structures, 1.5) + disp;
}

vec3 getNormal(in vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(map(p+e.xyy)-map(p-e.xyy), 
                          map(p+e.yxy)-map(p-e.yxy), 
                          map(p+e.yyx)-map(p-e.yyx)));
}

float volumetric(vec3 ro, vec3 rd, float max_d) {
    float d = 0.0;
    float res = 0.0;
    for(int i=0; i<30; i++) {
        vec3 p = ro + rd * d;
        if(d > max_d) break;
        res += Noise3d(p * 0.2 + time * 0.1) * smoothstep(1.0, 0.0, p.y * 0.1);
        d += max_d / 30.0;
    }
    return res * 0.08;
}

float shadow(in vec3 ro, in vec3 rd) {
    float res = 1.0;
    float t = 0.1;
    for(int i=0; i<16; i++) {
        float h = map(ro + rd * t);
        res = min(res, 8.0 * h / t);
        t += clamp(h, 0.02, 0.5);
        if(h < 0.001 || t > 10.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float camPath = time * 0.2;
    vec3 ro = vec3(cos(camPath)*15.0, 8.0 + sin(time*0.3)*2.0, sin(camPath)*15.0);
    vec3 lookAt = vec3(0.0, 2.0, 0.0);
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x * r + uv.y * u);
    
    float t = 0.0;
    for(int i=0; i<ITR; i++) {
        float d = map(ro + rd * t);
        if(abs(d) < 0.001 * t || t > FAR) break;
        t += d * 0.6;
    }
    
    vec3 col = vec3(0.8, 0.9, 1.0);
    vec3 sunDir = normalize(vec3(0.5, 0.8, -0.5));
    
    if(t < FAR) {
        vec3 pos = ro + rd * t;
        vec3 nor = getNormal(pos);
        vec3 ref = reflect(rd, nor);
        float occ = clamp(map(pos + nor * 1.5), 0.0, 1.0);
        float sha = shadow(pos, sunDir);
        float dif = clamp(dot(nor, sunDir), 0.0, 1.0);
        float spe = pow(clamp(dot(ref, sunDir), 0.0, 1.0), 32.0);
        float fre = pow(1.0 + dot(rd, nor), 4.0);
        vec3 baseCol = mix(vec3(0.9, 0.85, 0.8), vec3(0.7, 0.9, 1.0), nor.y * 0.5 + 0.5);
        vec3 irid = 0.5 + 0.5 * cos(time + pos.y + vec3(0, 2, 4));
        baseCol = mix(baseCol, irid, fre * 0.5);
        col = baseCol * (dif * sha + 0.2);
        col += SUN_COLOUR * spe * sha;
        col += BIOLUM_COLOUR * fre * (0.5 + 0.5 * sin(pos.y * 0.5 - time * 2.0));
        col *= occ;
    }
    
    float vol = volumetric(ro, rd, min(t, FAR));
    col = mix(col, SUN_COLOUR, 1.0 - exp(-0.0002 * t * t));
    col += BIOLUM_COLOUR * vol;
    col = smoothstep(-0.05, 1.05, col);
    col = pow(col, vec3(2.0));
    vec2 q = fragCoord.xy / iResolution.xy;
    col *= 0.5 + 0.5 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.1);
    fragColor = vec4(col, 1.0);
}
