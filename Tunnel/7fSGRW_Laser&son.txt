// ==== Image (image) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Demovideos:
// https://www.youtube.com/watch?v=YUYbXfiL-mI

void mainImage(out vec4 couleur, in vec2 coordonnes) {
    vec2 uv = coordonnes / iResolution.xy;
    vec2 dist = (uv - 0.5) * 1.2;
    float deplacement = dot(dist, dist) * 0.02;
    
    float r = texture(iChannel0, uv + deplacement).r;
    float g = texture(iChannel0, uv).g;
    float b = texture(iChannel0, uv - deplacement).b;
    
    vec3 col = vec3(r, g, b);
    col = smoothstep(-0.05, 1.1, col * 1.3);
    col *= 1.2 - length(dist);
    
    couleur = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Demovideos:
// https://www.youtube.com/watch?v=YUYbXfiL-mI

void mainImage(out vec4 couleur, in vec2 coordonnes) {
    if (coordonnes.y > 1.0) discard;
    
    float t = iTime * 0.05;
    
    float cycle = mod(iTime, 4.0);
    float flash = smoothstep(3.8, 4.0, cycle);
    
    vec4 flux;
    flux.x = t; 
    flux.y = sin(t * 0.3) * 0.2; 
    flux.z = cos(t * 0.2) * 0.2; 
    flux.w = flash;
    
    couleur = flux;
}

// ==== Buffer B (buffer) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Demovideos:
// https://www.youtube.com/watch?v=YUYbXfiL-mI

mat3 rotation_z(float a) {
    float s = sin(a), c = cos(a);
    return mat3(c, -s, 0, s, c, 0, 0, 0, 1);
}

mat2 rotation_2d(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float bruit_v(vec3 p) {
    vec3 i = floor(p); vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 57.0 + i.z * 113.0;
    return mix(mix(mix(fract(sin(n + 0.0) * 43758.5), fract(sin(n + 1.0) * 43758.5), f.x),
               mix(fract(sin(n + 57.0) * 43758.5), fract(sin(n + 58.0) * 43758.5), f.x), f.y),
           mix(mix(fract(sin(n + 113.0) * 43758.5), fract(sin(n + 114.0) * 43758.5), f.x),
               mix(fract(sin(n + 114.0) * 43758.5), fract(sin(n + 115.0) * 43758.5), f.x), f.y), f.z);
}

float carte(vec3 p, float ex) {
    float paroi = -(length(p.xy) - 1.8);
    vec3 q = p;
    q.z = mod(q.z + 0.5, 1.0) - 0.5;
    float a = atan(p.y, p.x) * 3.0;
    q.xy *= rotation_2d(a);
    float bulbes = length(mod(q + 0.2, 0.4) - 0.2) - 0.02 - sin(ex + p.z * 5.0) * 0.01;
    return min(paroi, bulbes);
}

void mainImage(out vec4 couleur, in vec2 coordonnes) {
    vec2 uv = (coordonnes - 0.5 * iResolution.xy) / iResolution.y;
    vec4 d = texelFetch(iChannel0, ivec2(0,0), 0);
    
    vec3 ro = vec3(0, 0, d.x * 10.0);
    vec3 rd = normalize(vec3(uv + vec2(d.y, d.z), 1.0));
    
    rd.xy *= rotation_2d(d.x * 0.2);

    float t = 0.0;
    vec3 col = vec3(0.0);
    
    for(int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float dist = carte(p, d.w);
        if(dist < 0.002) {
            vec2 e = vec2(0.001, 0);
            vec3 n = normalize(vec3(carte(p+e.xyy, d.w)-carte(p-e.xyy, d.w),
                                    carte(p+e.yxy, d.w)-carte(p-e.yxy, d.w),
                                    carte(p+e.yyx, d.w)-carte(p-e.yyx, d.w)));
            float rim = pow(1.0 - max(0.0, dot(n, -rd)), 4.0);
            vec3 pal = 0.5 + 0.5 * cos(vec3(0, 1, 2) + p.z * 0.3);
            col = pal * rim * 2.5 * exp(-t * 0.15);
            break;
        }
        t += dist * 0.6;
        if(t > 30.0) break;
    }
    
    float f = bruit_v(rd * 5.0 + d.x) * exp(-t * 0.1);
    col += mix(vec3(0.01, 0.02, 0.05), vec3(0.1, 0.04, 0.02), f) * (1.0 - exp(-t * 0.1));
    
    couleur = vec4(col, 1.0);
    
    vec4 flux_a = texelFetch(iChannel0, ivec2(0,0), 0);
    col += vec3(0.8, 0.9, 1.0) * flux_a.w;
}

// ==== Buffer C (buffer) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Demovideos:
// https://www.youtube.com/watch?v=YUYbXfiL-mI

void mainImage(out vec4 couleur, in vec2 coordonnes) {
    vec2 uv = coordonnes / iResolution.xy;
    vec3 s = texture(iChannel0, uv).rgb;
    vec3 b = vec3(0.0);
    for(float i = 1.0; i < 5.0; i++) {
        float off = i * 2.5;
        b += texture(iChannel0, uv + vec2(off, 0) / iResolution.xy).rgb;
        b += texture(iChannel0, uv - vec2(off, 0) / iResolution.xy).rgb;
        b += texture(iChannel0, uv + vec2(0, off) / iResolution.xy).rgb;
        b += texture(iChannel0, uv - vec2(0, off) / iResolution.xy).rgb;
    }
    vec3 m = texture(iChannel1, uv).rgb;
    couleur = vec4(mix(s + (b * 0.1), m, 0.88), 1.0);
}

// ==== Sound (sound) ====
// Par : Patrick JAILLET (Sandefjord)
// ---------------------------------------------
// Demovideos:
// https://www.youtube.com/watch?v=YUYbXfiL-mI

vec2 mainSound(int echantillon, float temps) {
    float cycle_total = 3.0;
    float t = mod(temps, cycle_total);
    float enveloppe = 0.0;
    float frequence = 0.0;

    if(t < 1.0) {
        enveloppe = sin(t * 3.14159);
        frequence = 800.0 * enveloppe;
    } 
    else if(t < 3.0) {
        float t2 = t - 1.0;
        enveloppe = sin(t2 * 1.5707);
        frequence = 400.0 * enveloppe;
    }

    float bruit = fract(sin(temps * 12345.67) * 43758.54) * 2.0 - 1.0;
    float onde = sin(6.2831 * (frequence * temps));
    
    float signal = mix(bruit, onde, 0.4) * enveloppe;
    
    return vec2(signal) * 0.25;
}
