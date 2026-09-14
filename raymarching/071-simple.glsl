// ==== Image (image) ====
// Par : Patrick JAILLET

float hsh(float n) { return fract(sin(n) * 43758.5453123); }

float nse(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix(hsh(n+0.0), hsh(n+1.0),f.x), mix(hsh(n+157.0), hsh(n+158.0),f.x),f.y),
               mix(mix(hsh(n+113.0), hsh(n+114.0),f.x), mix(hsh(n+270.0), hsh(n+271.0),f.x),f.y),f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5000 * nse(p); p *= 2.01;
    f += 0.2500 * nse(p); p *= 2.02;
    f += 0.1250 * nse(p);
    return f / 0.875;
}

float sdSponge(vec3 p) {
    float t = iTime * 0.2;
    p.xy *= mat2(cos(t * 0.3), -sin(t * 0.3), sin(t * 0.3), cos(t * 0.3));
    p.yz *= mat2(cos(t), -sin(t), sin(t), cos(t));
    float s = length(p) - 1.0;
    return s + fbm(p * 3.5) * 0.4 - fbm(p * 12.0 + 8.0) * 0.1;
}

float sdSand(vec3 p) {
    float d = p.y + 1.2;
    float r = length(p.xz);
    float a = atan(p.z, p.x);
    float waves = sin(r * 4.0 - a - iTime * 0.5) * 0.1;
    waves += sin(r * 8.0 + iTime) * 0.02;
    return d + waves;
}

float m(vec3 p) {
    return min(sdSponge(p), sdSand(p));
}

vec3 gN(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(m(p + e.xyy) - m(p - e.xyy), m(p + e.yxy) - m(p - e.yxy), m(p + e.yyx) - m(p - e.yyx)));
}

void mainImage(out vec4 O, vec2 v) {
    vec2 R = iResolution.xy;
    vec2 uv = (v + v - R) / R.y;
    
    float camT = iTime * 0.5;
    vec3 o = vec3(sin(camT) * 4.0, 1.0, cos(camT) * 4.0);
    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 ww = normalize(target - o);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    vec3 r = normalize(uv.x * uu + uv.y * vv + 2.0 * ww);
    
    vec3 sun = normalize(vec3(-1.0, 2.0, -2.0));
    float t = 0.0, d;
    
    for(int i = 0; i < 100; i++) {
        d = m(o + r * t);
        if(abs(d) < 0.001 || t > 15.0) break;
        t += d * 0.6;
    }

    vec3 col = vec3(0.005, 0.008, 0.015);
    float sH = hsh(floor(r.x * 500.0) + floor(r.y * 500.0) * 500.0 + floor(r.z * 500.0));
    if(sH < 0.002) {
        col += vec3(0.9, 0.9, 1.0) * pow(hsh(sH + iTime * 0.001), 10.0);
    }

    if(t < 15.0) {
        vec3 p = o + r * t;
        vec3 n = gN(p);
        if(sdSponge(p) < sdSand(p)) {
            vec3 sCol = mix(vec3(1.0, 0.8, 0.2), vec3(0.6, 0.4, 0.1), nse(p * 2.0));
            float diff = max(0.0, dot(n, sun));
            col = sCol * (diff + 0.2);
            float gl = pow(nse(p * 150.0 + iTime), 50.0) * 15.0;
            col += vec3(1.0, 0.9, 0.7) * gl * diff;
        } else {
            float grain = nse(p * 80.0) * 0.2;
            vec3 sand = mix(vec3(0.4, 0.25, 0.1), vec3(0.1, 0.05, 0.02), smoothstep(0.0, 4.0, length(p.xz)));
            float diff = max(0.0, dot(n, sun));
            col = sand * (diff + grain + 0.1);
            col *= smoothstep(0.0, 0.1, m(p + sun * 0.1));
        }
    }

    O.rgb = pow(col * 1.4, vec3(0.9));
    O.rgb += pow(max(0.0, col.r - 0.6), 2.0) * 2.0;
    O.rgb *= 1.0 - length(uv * 0.4);
}
