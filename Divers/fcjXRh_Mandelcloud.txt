// ==== Image (image) ====
#define R iResolution.xy

vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 getScene(vec2 uv, float offset) {
    vec2 dir = normalize(uv - 0.5);
    vec3 col;
    col.r = texture(iChannel0, uv + dir * offset).r;
    col.g = texture(iChannel0, uv).g;
    col.b = texture(iChannel0, uv - dir * offset).b;
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / R;
    
    vec3 col = getScene(uv, 0.008);
    
    vec3 bloom = vec3(0.0);
    for(float i = -3.0; i <= 3.0; i++) {
        for(float j = -3.0; j <= 3.0; j++) {
            bloom += texture(iChannel0, uv + vec2(i, j) * 0.005).rgb;
        }
    }
    col += (bloom / 49.0) * 1.2;

    vec2 distort = (uv - 0.5) * 1.1 + 0.5;
    float vign = smoothstep(0.8, 0.2, length(uv - 0.5));
    col *= mix(0.4, 1.2, vign);

    col = aces(col * 2.8);
    col = pow(col, vec3(1.0 / 2.2));
    
    float noise = fract(sin(dot(uv + iTime, vec2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.04;

    col = mix(vec3(dot(col, vec3(0.2126, 0.7152, 0.0722))), col, 1.4);
    col = col * 1.1 - 0.05;

    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
#define SAMPLES 16.0
#define ITERATIONS 160.0
#define R iResolution.xy

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    float time = iTime * 0.12;
    float r2 = dot(p, p);
    p = p * 2.2 / clamp(r2, 0.05, 2.5);
    
    for(int i = 0; i < 10; i++) {
        p = abs(p) - vec3(0.3, 0.7, 0.4);
        p.xy *= rot(time * 0.4);
        p.xz *= rot(time * 0.2);
        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;
        p = p * 1.75 - vec3(0.05, 0.3, 0.1);
    }
    return length(p) * pow(1.75, -10.0);
}

float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 accumulation = vec3(0.0);
    float dither = hash(vec3(fragCoord, iFrame));

    for(float m = 0.0; m < SAMPLES; m++) {
        vec2 offs = vec2(hash(vec3(m, m + 1.2, iFrame)), hash(vec3(m + 2.1, m, iFrame)));
        vec2 uv = (2.0 * (fragCoord + offs) - R) / R.y;
        
        vec3 ro = vec3(0.0, 0.0, -2.2);
        vec3 rd = normalize(vec3(uv, 2.5));
        
        float t_rot = iTime * 0.05;
        ro.xz *= rot(t_rot);
        rd.xz *= rot(t_rot);
        rd.yz *= rot(t_rot * 0.5);

        float d = 0.01 + 0.05 * dither;
        vec3 col = vec3(0.0);
        float transmission = 1.0;

        for(float i = 0.0; i < ITERATIONS; i++) {
            vec3 p = ro + rd * d;
            float s = map(p);
            float density = smoothstep(0.2, 0.0, s);
            
            if(density > 0.0) {
                vec3 lCol = 0.5 + 0.5 * cos(vec3(0.0, 0.4, 0.8) + d * 0.4 + iTime * 0.3);
                lCol *= 1.5;
                
                float weight = density * transmission;
                col += lCol * weight * 0.6;
                transmission *= (1.0 - density * 0.85);
            }
            
            d += max(s * 0.25, 0.003);
            if(d > 15.0 || transmission < 0.0005) break;
        }
        accumulation += col;
    }
    
    vec3 current = accumulation / SAMPLES;
    vec3 history = texture(iChannel0, fragCoord / R).rgb;
    fragColor = vec4(mix(current, history, 0.92), 1.0);
}
