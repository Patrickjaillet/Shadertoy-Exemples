// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rd = normalize(vec3(uv, -1.0));
    vec3 ro = vec3(0, 0, 25.0);
    
    vec3 col = vec3(0);
    
    for(float i = 0.0; i < 40.0; i++) {
        for(float j = 0.0; j < 40.0; j++) {
            vec4 data = texture(iChannel0, vec2(i, j) / iResolution.xy);
            vec3 p = data.xyz;
            float life = data.w;
            if(life <= 0.0) continue;
            
            vec3 lp = p - ro;
            float t = dot(lp, rd);
            if(t < 0.0) continue;
            
            float d2 = dot(lp - rd*t, lp - rd*t);
            float s = 0.01 + life * 0.04;
            
            if(d2 < s * 6.0) {
                vec3 pCol = mix(vec3(1.0, 0.2, 0.0), vec3(0.0, 0.8, 1.0), life/3.0);
                col += pCol * exp(-d2/s) * 0.3;
            }
        }
    }
    
    col = 1.0 - exp(-col * 2.0);
    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}

// ==== Buffer A (buffer) ====
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;
    i = mod289(i);
    vec4 p = permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y + vec4(0.0, i1.y, i2.y, 1.0)) + i.x + vec4(0.0, i1.x, i2.x, 1.0));
    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x); vec3 p1 = vec3(a0.zw, h.y); vec3 p2 = vec3(a1.xy, h.z); vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    if (fragCoord.x > 100. || fragCoord.y > 100.) discard;
    vec2 uv = fragCoord / 100.0;
    vec4 data = texture(iChannel0, fragCoord / iResolution.xy);
    vec3 pos = data.xyz;
    float life = data.w;
    vec3 vel = texture(iChannel0, (fragCoord + vec2(0, 50.0)) / iResolution.xy).xyz;
    
    vec2 mUV = iMouse.xy / iResolution.xy;
    if(iMouse.z <= 0.0) mUV = vec2(0.5 + 0.3*cos(iTime), 0.5 + 0.3*sin(iTime));
    vec3 target = vec3((mUV - 0.5) * vec2(24.0 * (iResolution.x/iResolution.y), 24.0), 0.0);

    if (iFrame < 5 || life <= 0.0) {
        float r = fract(sin(dot(fragCoord, vec2(12.98, 78.23))) * 437.5);
        pos = target + (vec3(r, fract(r*10.), fract(r*100.)) - 0.5) * 2.0;
        vel = (pos - target) * 5.0;
        life = 1.0 + r * 2.0;
    } else {
        vec3 force = target - pos;
        vel += normalize(force) * 0.5 + vec3(snoise(pos*0.2), snoise(pos*0.2+7.0), snoise(pos*0.2+13.0)) * 0.2;
        vel *= 0.96;
        pos += vel * 0.15;
        life -= 0.016;
    }

    fragColor = (fragCoord.y < 50.0) ? vec4(pos, life) : vec4(vel, 1.0);
}
