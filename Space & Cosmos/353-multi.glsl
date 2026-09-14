// ==== Image (image) ====
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 hash2(vec2 p) {
    float n = hash(p);
    return vec2(n, hash(p + n));
}

vec3 star(vec2 uv, float scale, float density) {
    vec3 col = vec3(0);
    vec2 g = floor(uv * scale);
    vec2 f = fract(uv * scale) - 0.5;
    float h = hash(g);
    if (h > density) {
        vec2 p = f - (hash2(g) - 0.5) * 0.9;
        float d = length(p);
        float t = pow(sin(iTime * (h * 15.0) + h * 6.28) * 0.5 + 0.5, 12.0);
        float m = 0.0006 / d;
        float rays = max(0.0, 1.0 - abs(p.x * p.y * 8000.0));
        col += m * vec3(0.9, 0.95, 1.0) * (0.1 + t);
        col += rays * 0.2 * t * vec3(0.8, 0.9, 1.0);
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv_n = fragCoord / iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float chroma = 0.004;
    vec3 col;
    col.r = texture(iChannel0, uv_n + vec2(chroma, 0)).r;
    col.g = texture(iChannel0, uv_n).g;
    col.b = texture(iChannel0, uv_n - vec2(chroma, 0)).b;
    
    vec3 bloom = vec3(0);
    float samples = 8.0;
    for(float i=0.0; i<samples; i++) {
        float a = i * (6.2831 / samples);
        bloom += texture(iChannel0, uv_n + vec2(cos(a), sin(a)) * 0.015).rgb;
    }
    col += (bloom / samples) * 0.35;
    
    col += star(uv, 35.0, 0.982);
    col += star(uv * 1.5, 70.0, 0.997);
    
    col *= 1.0 - length(uv) * 0.25;
    
    fragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.4545)), 1.0);
}

// ==== Buffer A (buffer) ====
#define OCTAVES 10

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(1.6, 1.2, -1.2, 1.6);
    for (int i = 0; i < OCTAVES; i++) {
        v += a * noise(p);
        p = rot * p + iTime * 0.02;
        a *= 0.5;
    }
    return v;
}

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.1, 0.4, 0.7);
    return a + b * cos(6.28318 * (c * t + d + iTime * 0.05));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.1;
    
    vec2 p = uv * 1.8;
    vec2 q = vec2(fbm(p + vec2(0.0, 0.0)), fbm(p + vec2(5.2, 1.3)));
    vec2 r = vec2(fbm(p + 4.0 * q + vec2(1.7, 9.2) + t), fbm(p + 4.0 * q + vec2(8.3, 2.8) - t));
    
    float f = fbm(p + 4.0 * r);
    
    vec2 z = uv * 1.3;
    float rot = t * 0.5;
    z *= mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
    vec2 c_julia = vec2(-0.78, 0.15) + q * 0.1;
    
    float iter = 0.0;
    for(int i = 0; i < 80; i++) {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c_julia;
        if(dot(z,z) > 4.0) break;
        iter++;
    }
    
    float f_frac = iter / 80.0;
    float mask = smoothstep(0.8, 0.0, length(uv * vec2(1.0, 2.5)));
    
    vec3 col = palette(f + length(q) * 0.4);
    col *= pow(f, 3.0) * 2.5;
    col += palette(f_frac + t) * f_frac * mask * 2.0;
    
    fragColor = vec4(col, 1.0);
}
