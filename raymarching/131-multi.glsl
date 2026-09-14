// ==== Image (image) ====
#define R(a) mat2(cos(a), -sin(a), sin(a), cos(a))

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = iResolution.xy;
    float t = iTime * 0.2;
    vec2 uv = (fragCoord * 2.0 - res) / res.y;
// All my Soft for Windows
// https://github.com/Patrickjaillet    
    vec2 p = uv * 0.8;
    vec2 state = vec2(0.0);
    float d = dot(p, p);
    float accum = 0.0;
    float freq = 2.2;
    float iter = 90.0;

    for (float i = 0.0; i < iter; i++) {
        p *= R(0.83);
        state = state * (R(1.1) + R(t) * 0.05) + sin(p * freq + t);
        vec2 q = p * freq + state;
        accum += (dot(sin(q), cos(q.yx)) / freq) * 3.5;
        state += cos(q + vec2(1.3, 0.7));
        freq *= 1.06;
    }

    vec3 col = vec3(0.0);
    col.r = sin(accum * 0.4 + 0.0) * 0.5 + 0.5;
    col.g = sin(accum * 0.3 + 1.5) * 0.5 + 0.5;
    col.b = sin(accum * 0.2 + 3.0) * 0.5 + 0.5;
    
    col *= max(0.0, 1.0 - d * 0.2);
    col += vec3(0.2, 0.03, 0.25) * (1.0 / (0.5 + d * 4.0));
    col = pow(col, vec3(1.2));
    
    fragColor = vec4(col, 1.0);
}

// ==== Sound (sound) ====
#define R(a) mat2(cos(a), -sin(a), sin(a), cos(a))

vec2 mainSound(in int sampleRate, in float time) {
    float t = time * 0.2;
    vec2 state = vec2(0.0);
    float accum = 0.0;
    float freq = 2.2;
    float iter = 90.0;

    vec2 baseP = vec2(sin(time * 0.5), cos(time * 0.3)) * 0.4;

    for (float i = 0.0; i < iter; i++) {
        baseP *= R(0.83);
        state = state * (R(1.1) + R(t) * 0.05) + sin(baseP * freq + t);
        vec2 q = baseP * freq + state;
        accum += (dot(sin(q), cos(q.yx)) / freq) * 3.5;
        state += cos(q + vec2(1.3, 0.7));
        freq *= 1.06;
    }

    float signalLeft = sin(accum * 0.4 + time * 440.0 * 3.141592);
    float signalRight = sin(accum * 0.3 + time * 442.0 * 3.141592 + 1.5);

    return vec2(signalLeft, signalRight) * 0.15;
}
