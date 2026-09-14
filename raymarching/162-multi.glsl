// ==== Image (image) ====
#define P(z) vec3(cos((z)*0.01)*25.+cos((z)*0.008)*35., cos((z)*0.007)*10., z)
#define R(a) mat2(cos(a + vec4(0,33,11,0)))
#define N normalize

vec4 lgs;

vec3 hsv_vers_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float dessiner_ui(vec2 uv, vec2 pos, float valeur, vec3 col) {
    float h = 0.0015, l = 0.14, r = 0.01;
    vec2 p = uv - pos;
    float rail = smoothstep(h, 0.0, abs(p.y)) * step(abs(p.x), l * 0.5);
    float xp = (valeur - 0.5) * l;
    float d = length(p - vec2(xp, 0.0));
    return (rail * 0.1 + smoothstep(r, r*0.5, d) + exp(-d * 70.0) * 0.8);
}

float eponge(vec3 p, float iter, float modif) {
    vec3 f = abs(mod(p, vec3(50.0)) - vec3(25.0));
    float s = 1.0;
    for(int i = 0; i < 4; i++) {
        f = abs(f) - (4.0 + modif);
        if (f.x < f.y) f.xy = f.yx;
        if (f.x < f.z) f.xz = f.zx;
        if (f.y < f.z) f.yz = f.zy;
        f = iter * f - modif;
        s *= iter;
    }
    return length(f.xy) / s;
}

float map(vec3 p, float teinte) {
    vec3 c = P(p.z);
    float tun = 80.0 - length(p.xy - c.xy);
    
    float cycle = iTime / 5.0;
    int id1 = int(mod(floor(cycle), 10.0));
    int id2 = int(mod(float(id1) + 1.0, 10.0));
    float f = smoothstep(0.0, 1.0, fract(cycle));
    
    float params[10];
    params[0]=1.5; params[1]=1.8; params[2]=2.1; params[3]=2.4; params[4]=1.3;
    params[5]=1.6; params[6]=2.0; params[7]=2.2; params[8]=1.9; params[9]=1.7;
    
    float offsets[10];
    offsets[0]=1.0; offsets[1]=0.5; offsets[2]=2.0; offsets[3]=0.2; offsets[4]=3.0;
    offsets[5]=0.8; offsets[6]=1.5; offsets[7]=1.2; offsets[8]=0.4; offsets[9]=2.5;
    
    float d1 = eponge(p, params[id1], offsets[id1]);
    float d2 = eponge(p, params[id2], offsets[id2]);
    float d = max(mix(d1, d2, f), -tun);
    
    lgs += vec4(hsv_vers_rgb(vec3(teinte + p.z * 0.0005, 0.7, 1.0)), 0) / (0.05 + abs(d) * 15.0);
    return d;
}

void mainImage(out vec4 o, in vec2 u) {
    vec2 res = iResolution.xy;
    float v_zoom = texelFetch(iChannel0, ivec2(0,0), 0).r;
    float v_vol  = texelFetch(iChannel0, ivec2(1,0), 0).r;
    float v_tint = texelFetch(iChannel0, ivec2(2,0), 0).r;
    float v_blur = texelFetch(iChannel0, ivec2(3,0), 0).r;
    float v_spd  = texelFetch(iChannel0, ivec2(4,0), 0).r;

    vec2 uv_n = (u - 0.5 * res) / res.y;
    o = vec4(0);
    
    int nb = (v_blur > 0.05) ? 6 : 1;
    for(int j = 0; j < nb; j++) {
        vec2 jit = (nb > 1) ? vec2(cos(float(j)*2.1), sin(float(j)*2.1)) * v_blur * 0.15 : vec2(0.0);
        lgs = vec4(0);
        vec2 uv = uv_n + jit;
        float t = iTime * 40.0;
        vec3 pc = P(t), Z = N(P(t + 5.0) - pc), X = N(vec3(Z.z, 0.0, -Z.x)),
             D = N(vec3(R(sin(iTime * mix(0.1, 2.0, v_spd)) * 0.2) * uv, mix(0.4, 2.5, v_zoom)) * mat3(-X, cross(X, Z), Z));
        float d = 0.0, s;
        for(int i = 0; i < 90; i++) {
            s = map(pc + D * d, v_tint) * 0.6;
            d += s;
            if(s < 0.001 || d > 180.0) break;
        }
        o.rgb += (lgs.rgb * 0.015) + (pow(max(0.0, dot(D, Z)), 8.0) * 0.2);
    }
    o.rgb /= float(nb);
    o.rgb *= (v_vol * 2.5 + 0.1);
    o.rgb = smoothstep(-0.05, 1.1, o.rgb);
    o.rgb *= 1.2 - length(uv_n) * 0.7;

    vec2 uv_ui = u / res;
    vec3 c_ui = hsv_vers_rgb(vec3(v_tint, 0.8, 1.0));
    float ui = 0.0;
    ui += dessiner_ui(uv_ui, vec2(0.1, 0.08), v_zoom, c_ui);
    ui += dessiner_ui(uv_ui, vec2(0.3, 0.08), v_vol, c_ui);
    ui += dessiner_ui(uv_ui, vec2(0.5, 0.08), v_tint, c_ui);
    ui += dessiner_ui(uv_ui, vec2(0.7, 0.08), v_blur, c_ui);
    ui += dessiner_ui(uv_ui, vec2(0.9, 0.08), v_spd, c_ui);
    o.rgb = mix(o.rgb, c_ui, ui * 0.8);
    o = tanh(o);
}

// ==== Sound (sound) ====
#define PHASE_DURATION 5.0 

float hash(float n) { return fract(sin(n) * 43758.5453123); }

float lowpass(float signal, float prev, float cutoff) {
    return mix(prev, signal, cutoff);
}

vec2 mainSound(int samp, float time) {
    float t_fract = fract(time / PHASE_DURATION);
    float morph = smoothstep(0.0, 0.5, t_fract) * smoothstep(1.0, 0.5, t_fract);
    float f = 26.0 + sin(time * 0.1) * 2.0; 
    float sub = sin(6.2831 * f * time);
    float breath = hash(time) * hash(time + 0.1); breath = pow(breath, 3.0) * 0.2; 
    float pulse = step(0.98, hash(time * (5.0 + morph * 20.0)));
    float thud = sin(6.28 * 40.0 * time) * pulse * morph * 0.3;
    float signal = sub * 0.4 + breath * 0.15 + thud; signal = tanh(signal * 0.8); 
    float L = signal * (0.9 + 0.1 * sin(time * 0.5));
    float R = signal * (0.9 + 0.1 * cos(time * 0.5));
    
    return vec2(L, R) * 0.30;
}

// ==== Buffer A (buffer) ====
void mainImage(out vec4 o, in vec2 u) {
    if (u.y > 1.0 || u.x > 5.0) discard;
    int id = int(u.x);
    float v = texelFetch(iChannel0, ivec2(id, 0), 0).r;
    if (iFrame < 5 || (iMouse.z <= 0.0 && v == 0.0)) {
        float def[5];
        def[0] = 0.5; def[1] = 0.6; def[2] = 0.15; def[3] = 0.0; def[4] = 0.3;
        v = def[id];
    }
    vec2 s = iMouse.xy / iResolution.xy;
    if (iMouse.z > 0.0 && s.y < 0.25) {
        float z = 0.2;
        float d = float(id) * z;
        if (s.x > d && s.x < d + z) v = clamp((s.x - d - 0.02) / 0.16, 0.0, 1.0);
    }
    o = vec4(v, 0, 0, 1);
}
