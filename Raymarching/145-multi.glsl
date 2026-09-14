// ==== Image (image) ====
vec3 getBloom(vec2 uv, vec2 res) {
    vec3 blur = vec3(0.0);
    float totalWeight = 0.0;
    for(float i = 0.0; i < 32.0; i++) {
        float angle = i * GOLDEN_ANGLE;
        float radius = sqrt(i) * 2.5;
        vec2 offset = vec2(cos(angle), sin(angle)) * radius / res;
        vec4 samp = texture(iChannel0, uv + offset);
        float weight = 1.0 / (radius + 1.0);
        blur += samp.rgb * samp.a * weight;
        totalWeight += weight;
    }
    return (blur / totalWeight) * BLOOM_INTENSITY;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 sceneData = texture(iChannel0, uv);
    
    vec3 sceneColor = sceneData.rgb;
    vec3 bloom = getBloom(uv, iResolution.xy);
    
    vec3 color = sceneColor + bloom;
    
    color = Tonemap_ACES(color);
    color = pow(color, vec3(1.0 / 2.2));
    color *= 1.4 - length(uv - 0.5) * 1.7;
    
    fragColor = vec4(color + (hash12(fragCoord + iTime) - 0.5) * 0.005, 1.0);
}

// ==== Common (common) ====
#define SAMPLES 1
#define FRACTAL_ITER 14
#define MARCH_STEPS 80
#define GOLDEN_ANGLE 2.3999632
#define BLOOM_THRESHOLD 0.6
#define BLOOM_SOFT_KNEE 0.1
#define BLOOM_INTENSITY 1.8

vec3 Tonemap_ACES(vec3 x) {
    float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// ==== Buffer A (buffer) ====
float map(vec3 q, float t) {
    float R = length(q);
    vec3 p = vec3(log2(R) - t * 0.4, exp(-q.z / R), atan(q.x, q.y));
    float e = p.y - 1.0; 
    float s = 1.0;
    for(int j = 0; j < FRACTAL_ITER; j++) {
        vec3 s_p = p * s;
        e += abs(dot(sin(s_p.zxy), cos(s_p))) / s * 0.17;
        s *= 1.85; 
        if(s > 1200.0) break;
    }
    return e;
}

vec3 getNormal(vec3 p, float t) {
    // fix: runtimeterror - https://www.shadertoy.com/user/runtimeterror
    vec2 eps = vec2(0.0002, 0.0);
    return normalize(vec3(
        map(p + eps.xyy, t) - map(p - eps.xyy, t),
        map(p + eps.yxy, t) - map(p - eps.yxy, t),
        map(p + eps.yyx, t) - map(p - eps.yyx, t)
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 r = iResolution.xy;
    float t = iTime;
    vec2 uv = (fragCoord * 2.0 - r) / r.y;
    // fix: runtimeterror - https://www.shadertoy.com/user/runtimeterror
    vec3 d = normalize(vec3(uv * 1.5 + vec2(1.0, 1.0), 1.8));
    vec3 q = vec3(-1.0, -1.0, -1.0);
    float e = 0.0, R = 0.0, dTotal = 0.0;
    
    vec3 col = vec3(0.0);
    for(int i = 0; i < MARCH_STEPS; i++) {
        R = length(q);
        e = map(q, t);
        if(e < 0.001) break;
        q += d * e * R * 0.25;
        dTotal += e;
    }

    vec3 n = getNormal(q, t);
    vec3 ref = reflect(d, n);
    
    vec3 cubeAlbedo = texture(iChannel1, n).rgb;
    vec3 cubeReflect = texture(iChannel1, ref).rgb;

    float fresnel = pow(1.0 + dot(d, n), 5.0);
    vec3 lighting = cubeAlbedo * 0.5 + cubeReflect * fresnel * 5.0;

    vec3 finalScene = lighting * (1.0 - exp(-dTotal * 0.2));

    float br = max(finalScene.r, max(finalScene.g, finalScene.b));
    float soft = clamp(br - BLOOM_THRESHOLD + BLOOM_SOFT_KNEE, 0.0, 2.0 * BLOOM_SOFT_KNEE);
    float extract = max(soft * soft / (4.0 * BLOOM_SOFT_KNEE + 1e-4), br - BLOOM_THRESHOLD);
    
    fragColor = vec4(finalScene, extract / max(br, 1e-4));
}
