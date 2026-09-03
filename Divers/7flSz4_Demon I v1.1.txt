// ==== Image (image) ====
#define RED vec3(1.0, 0.1, 0.05)
#define ORANGE vec3(1.0, 0.4, 0.1)
#define GOLD vec3(1.0, 0.8, 0.2)
#define BLACK vec3(0.01, 0.0, 0.0)
#define THICKNESS 0.004
#define GLOW 0.012

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 8; i++) {
        v += a * noise(p);
        p = p * 2.2 + vec2(10.0);
        a *= 0.5;
    }
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float time = iTime * 1.2;
    float cycle = mod(time, 24.0);
    
    vec2 camUV = uv;
    float angleCam = iTime * 0.2;
    if(cycle > 12.0) camUV *= rot(sin(time * 0.5) * 0.2);

    float impact = pow(abs(cos(time * 0.4)), 20.0);
    vec2 distortion = vec2(fbm(camUV * 2.5 + time * 0.8));
    camUV += (distortion - 0.5) * 0.04 * (1.0 + impact * 2.0);

    vec2 fireUV = camUV * 0.7;
    fireUV.y -= time * 0.6;
    float f1 = fbm(fireUV + time * 0.2);
    float f2 = fbm(fireUV * 1.5 - time * 0.4);
    float fireShape = smoothstep(0.2, 0.9, f1 * f2 + 0.25 - length(camUV) * 0.5);
    
    vec3 col = mix(BLACK, RED, fireShape);
    col = mix(col, ORANGE, smoothstep(0.4, 0.7, fireShape));
    col = mix(col, GOLD, smoothstep(0.7, 1.0, fireShape));

    float rotY = time * 0.9;
    float cosY = cos(rotY);
    float r = 0.45;
    vec2 p[5];
    for(int i = 0; i < 5; i++) {
        float a = (1.5 * 3.14159) + float(i) * 2.0 * 3.14159 / 5.0;
        vec2 base = vec2(cos(a), sin(a)) * r;
        p[i] = vec2(base.x * cosY, base.y);
    }
    
    float d = 1e10;
    d = min(d, sdSegment(camUV, p[0], p[2]));
    d = min(d, sdSegment(camUV, p[2], p[4]));
    d = min(d, sdSegment(camUV, p[4], p[1]));
    d = min(d, sdSegment(camUV, p[1], p[3]));
    d = min(d, sdSegment(camUV, p[3], p[0]));
    
    float ringDist = length(vec2(camUV.x / (abs(cosY) + 0.01), camUV.y));
    float rings = min(abs(ringDist - 0.48), abs(ringDist - 0.52));
    d = min(d, rings);

    float pulse = 1.0 + 0.3 * sin(time * 5.0);
    float d_glow = (GLOW * pulse + impact * 0.15) / max(d, 0.001);
    
    vec3 logoCol = mix(RED, GOLD, impact);
    col += logoCol * d_glow * 0.6;
    col += logoCol * smoothstep(THICKNESS * (1.0 + impact * 5.0), 0.0, d);
    
    vec2 partUV = camUV * 2.0;
    partUV.y -= time * 1.5;
    float particles = pow(fbm(partUV * 3.0), 12.0) * 50.0;
    particles *= smoothstep(0.2, -0.6, camUV.y);
    col += mix(RED, GOLD, noise(partUV)) * particles * (1.0 + impact * 10.0);

    col = mix(col, vec3(length(col)), -0.2); 
    col *= smoothstep(1.2, 0.4, length(uv)); 
    
    float chromatic = 0.005 + impact * 0.03;
    vec3 final;
    final.r = col.r;
    final.g = mix(col.g, fireShape, 0.1); 
    final.b = col.b; 
    
    if(impact > 0.8) {
        float flash = sin(time * 50.0) * 0.5 + 0.5;
        col += flash * impact * 0.2;
    }

    fragColor = vec4(pow(col, vec3(0.85)), 1.0);
}
