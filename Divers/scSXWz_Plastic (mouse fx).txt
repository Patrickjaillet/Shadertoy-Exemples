// ==== Image (image) ====
#define R iResolution.xy
#define T iTime

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x * 34.0) + 10.0) * x); }

vec2 rgrad2(vec2 p, float rot) {
    float u = permute(permute(vec3(p.x)).x + vec3(p.y)).x * 0.0243902439 + rot;
    u = fract(u) * 6.28318530718;
    return vec2(cos(u), sin(u));
}

vec3 psrdnoise(vec2 pos, vec2 per, float rot) {
    pos.y += 0.01;
    vec2 uv = vec2(pos.x + pos.y * 0.5, pos.y);
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    vec3 xw = mod(vec3(p0.x, p1.x, p2.x), per.x);
    vec3 yw = mod(vec3(p0.y, p1.y, p2.y), per.y);
    vec3 iuw = xw + 0.5 * yw;
    vec3 ivw = yw;
    vec2 g0 = rgrad2(vec2(iuw.x, ivw.x), rot);
    vec2 g1 = rgrad2(vec2(iuw.y, ivw.y), rot);
    vec2 g2 = rgrad2(vec2(iuw.z, ivw.z), rot);
    vec2 d0 = pos - p0, d1 = pos - p1, d2 = pos - p2;
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    vec3 t = max(0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2)), 0.0);
    vec3 t2 = t * t, t4 = t2 * t2, t3 = t2 * t;
    float n = dot(t4, w);
    vec3 dtdx = -2.0 * vec3(d0.x, d1.x, d2.x), dtdy = -2.0 * vec3(d0.y, d1.y, d2.y);
    vec2 dn = t4.x * g0 + (vec2(dtdx.x, dtdy.x) * 4.0 * t3.x) * w.x +
              t4.y * g1 + (vec2(dtdx.y, dtdy.y) * 4.0 * t3.y) * w.y +
              t4.z * g2 + (vec2(dtdx.z, dtdy.z) * 4.0 * t3.z) * w.z;
    return 11.0 * vec3(n, dn);
}

vec3 ace(vec3 x) { return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0); }

void mainImage(out vec4 O, vec2 C) {
    vec2 p = (2.0 * C - R) / R.y;
    vec2 m = (2.0 * iMouse.xy - R) / R.y;
    vec2 m_click = (2.0 * abs(iMouse.zw) - R) / R.y;
    
    float isDown = step(0.0, iMouse.z);
    float timeSinceRelease = max(0.0, T - abs(iMouse.w / 1000.0));
    
    float jelly = mix(exp(-4.0 * timeSinceRelease) * cos(10.0 * timeSinceRelease), 1.0, isDown);
    
    vec2 pull = m - m_click;
    float d = length(p - m_click);
    float weight = exp(-d * 3.0);
    
    vec2 p_def = p - (pull * weight * jelly);
    
    vec3 noise = psrdnoise(p_def * 4.0, vec2(10.0), T * 0.1);
    vec3 n = normalize(vec3(-noise.yz * 0.5, 1.0));
    
    vec3 lp = vec3(1.0, 2.0, 3.0), l = normalize(lp - vec3(p_def, 0)), v = vec3(0,0,1), h = normalize(l+v);
    
    float diff = max(dot(n, l), 0.0);
    float spec = pow(max(dot(n, h), 0.0), 64.0);
    float fres = pow(1.0 - n.z, 3.0);
    
    vec3 base = 0.5 + 0.5 * cos(T * 0.1 + noise.x + vec3(0, 2, 4));
    vec3 albedo = mix(vec3(0.01), base, smoothstep(-0.5, 0.5, noise.x));
    
    vec3 col = albedo * (diff + 0.2) + spec * 0.6 + fres * albedo;
    
    float stress = length(pull * weight * jelly);
    col += vec3(0.8, 0.2, 0.5) * stress * 1.2;
    
    O = vec4(pow(ace(col), vec3(0.4545)), 1.0);
}
