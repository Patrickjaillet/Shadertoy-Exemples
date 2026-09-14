// ==== Image (image) ====
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec3 hash33(vec3 p) {
    p = fract(p * vec3(.1031, .1030, .0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = dot(hash33(i), vec3(1.0));
    float b = dot(hash33(i + vec3(1.0, 0.0, 0.0)), vec3(1.0));
    float c = dot(hash33(i + vec3(0.0, 1.0, 0.0)), vec3(1.0));
    float d = dot(hash33(i + vec3(1.0, 1.0, 0.0)), vec3(1.0));
    float e = dot(hash33(i + vec3(0.0, 0.0, 1.0)), vec3(1.0));
    float _f = dot(hash33(i + vec3(1.0, 0.0, 1.0)), vec3(1.0));
    float g = dot(hash33(i + vec3(0.0, 1.0, 1.0)), vec3(1.0));
    float h = dot(hash33(i + vec3(1.0, 1.0, 1.0)), vec3(1.0));
    return mix(mix(mix(a, b, f.x), mix(c, d, f.x), f.y), mix(mix(e, _f, f.x), mix(g, h, f.x), f.y), f.z) * 0.125;
}
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  URL     : https://lside.xo.je                                                   //
//*====================================================================================*//
float fbm(vec3 p) {
    float v = 0.0, a = 0.5;
    mat2 r = rot(0.37);
    for (int i = 0; i < 6; i++) {
        v += a * noise(p);
        p *= 2.02;
        p.xy *= r;
        a *= 0.5;
    }
    return v;
}

vec2 getPath(float z) {
    return vec2(sin(z * 0.12) * 3.2 + cos(z * 0.31) * 1.1, cos(z * 0.18) * 2.4);
}

float map(vec3 p) {
    vec2 offset = getPath(p.z);
    vec3 q = p;
    q.xy -= offset;
    float tunnel = 4.2 - length(q.xy);
    float d = fbm(q * 0.8 + vec3(0, 0, iTime * 0.1));
    return (tunnel - d * 1.4) * 0.5;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.005, 0.0);
    return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy), map(p + e.yyx) - map(p - e.yyx)));
}

float caustics(vec2 uv, float t) {
    vec2 p = uv * 3.0;
    vec2 i = p;
    float c = 1.0;
    float inten = 0.005;
    for (int n = 0; n < 5; n++) {
        float t_val = t * (1.0 - (3.5 / float(n + 1)));
        i = p + vec2(cos(t_val - i.x) + sin(t_val + i.y), sin(t_val - i.y) + cos(t_val + i.x));
        c += 1.0 / length(vec2(p.x / (sin(i.x + t_val) / inten), p.y / (cos(i.y + t_val) / inten)));
    }
    c /= 5.0;
    return pow(clamp(1.2 - sqrt(c), 0.0, 1.0), 4.0) * 5.0;
}

vec3 triplanar(sampler2D tex, vec3 p, vec3 n) {
    vec3 w = abs(n);
    w /= (w.x + w.y + w.z);
    return (texture(tex, p.yz).rgb * w.x + texture(tex, p.zx).rgb * w.y + texture(tex, p.xy).rgb * w.z);
}

vec3 ACESFilm(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime * 1.5;
    
    vec3 ro = vec3(getPath(time), time);
    vec3 target = vec3(getPath(time + 2.0), time + 2.0);
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0, 1, 0), fwd));
    vec3 up = cross(fwd, right);
    vec3 rd = normalize(fwd * 1.2 + right * uv.x + up * uv.y);

    float t = 0.0, d = 0.0, vol = 0.0;
    for (int i = 0; i < 120; i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        vol += caustics(p.xy * 0.1, time * 0.5) * exp(-t * 0.15) * 0.04;
        if (abs(d) < 0.001 || t > 50.0) break;
        t += d;
    }

    vec3 col = vec3(0.01, 0.04, 0.06);
    if (t < 50.0) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p);
        vec3 lp = ro + fwd * 8.0;
        vec3 l = normalize(lp - p);
        vec3 v = -rd;
        vec3 r = reflect(-l, n);
        
        vec3 tex = triplanar(iChannel1, p * 0.2, n);
        float diff = max(dot(n, l), 0.0);
        float spec = pow(max(dot(r, v), 0.0), 64.0);
        float fres = pow(1.0 - max(dot(n, v), 0.0), 5.0);
        
        float cau = caustics(p.xy * 0.2 + p.z * 0.1, time);
        vec3 waterCol = vec3(0.1, 0.6, 0.8);
        
        col = tex * waterCol * (diff + 0.1);
        col += cau * waterCol * diff * 2.0;
        col += spec * vec3(0.8, 1.0, 1.0) * 0.5;
        col += waterCol * fres * 0.3;
        
        vec3 ext = exp(-t * vec3(0.4, 0.15, 0.1));
        col *= ext;
        col = mix(col, vec3(0.0, 0.02, 0.04), 1.0 - exp(-t * 0.08));
    }

    col += vec3(0.2, 0.7, 0.9) * vol;
    col = ACESFilm(col * 1.5);
    col = pow(col, vec3(0.4545));
    
    vec2 vuv = fragCoord / iResolution.xy;
    col *= pow(16.0 * vuv.x * vuv.y * (1.0 - vuv.x) * (1.0 - vuv.y), 0.15);
    
    fragColor = vec4(col, 1.0);
}
