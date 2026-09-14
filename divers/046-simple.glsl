// ==== Image (image) ====
// https://github.com/Patrickjaillet/Z-GL-Shadertoy
#define R iResolution.xy
#define T iTime
#define WEB_DENSITY 14.0
#define SNAP_THRESHOLD 0.35
#define ELASTIC_RECOIL 0.6
#define LINE_WIDTH 0.004

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash12(i), hash12(i + vec2(1, 0)), f.x),
               mix(hash12(i + vec2(0, 1)), hash12(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 3; i++) {
        v += a * noise(p);
        p *= 2.1; a *= 0.5;
    }
    return v;
}

float sdLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

float checkTear(vec2 p1, vec2 p2, vec2 m, float isDown) {
    vec2 mid = mix(p1, p2, 0.5);
    float d = length(mid - m);
    float fragility = fbm(mid * 8.0 + 44.0);
    float stress = exp(-d * 4.5) * isDown;
    return step(SNAP_THRESHOLD + fragility * 0.4, stress);
}

vec2 elasticDeform(vec2 p, vec2 m, float isDown, float broken) {
    float d = length(p - m);
    float force = exp(-d * 4.0) * isDown * ELASTIC_RECOIL * (1.0 - broken);
    return p + normalize(p - m) * force;
}

void mainImage(out vec4 O, vec2 C) {
    vec2 uv = (2.0 * C - R) / R.y;
    vec2 m = (2.0 * iMouse.xy - R) / R.y;
    float isDown = step(0.01, iMouse.z);
    
    float d = 1e10;
    float dDew = 1e10;
    float aStep = 6.2831 / WEB_DENSITY;

    for(float i = 0.0; i < WEB_DENSITY; i++) {
        float a = i * aStep;
        vec2 dir = vec2(cos(a), sin(a));
        vec2 p1 = vec2(0);
        vec2 p2 = dir * 2.2;
        
        float broken = checkTear(p1, p2, m, isDown);
        if(broken < 0.5) {
            vec2 dP1 = elasticDeform(p1, m, isDown, broken);
            vec2 dP2 = elasticDeform(p2, m, isDown, broken);
            d = min(d, sdLine(uv, dP1, dP2));
        }
    }

    for(float r = 0.15; r < 1.6; r += 0.09) {
        for(float i = 0.0; i < WEB_DENSITY; i++) {
            float a1 = i * aStep;
            float a2 = (i + 1.0) * aStep;
            
            vec2 p1 = vec2(cos(a1), sin(a1)) * r;
            vec2 p2 = vec2(cos(a2), sin(a2)) * r;
            
            float broken = checkTear(p1, p2, m, isDown);
            
            float naturalHole = step(0.12, hash12(vec2(r, i)));
            
            if(broken < 0.5 && naturalHole > 0.5) {
                vec2 dP1 = elasticDeform(p1, m, isDown, broken);
                vec2 dP2 = elasticDeform(p2, m, isDown, broken);
                
                vec2 mid = mix(dP1, dP2, 0.5);
                mid -= normalize(mid) * (0.03 * r);
                
                float segment = min(sdLine(uv, dP1, mid), sdLine(uv, mid, dP2));
                d = min(d, segment);
                
                if(hash12(vec2(r, i + 13.0)) > 0.94) {
                    dDew = min(dDew, length(uv - mid));
                }
            }
        }
    }

    vec3 col = vec3(0.005, 0.008, 0.012);
    
    float thread = smoothstep(LINE_WIDTH, 0.0, d);
    float sheen = pow(max(0.0, 1.0 - d * 60.0), 20.0) * 0.4;
    vec3 silkCol = vec3(0.7, 0.85, 1.0) * (0.5 + sheen);
    
    col = mix(col, silkCol, thread);
    col += vec3(0.4, 0.6, 1.0) * 0.0012 / (d + 0.004);
    
    float drop = smoothstep(0.012, 0.0, dDew);
    float dropSpec = pow(max(0.0, 1.0 - dDew * 80.0), 50.0);
    col = mix(col, vec3(0.9, 0.95, 1.0), drop);
    col += dropSpec * 0.6;

    O.rgb = pow(col * 1.6, vec3(0.4545));
    O.rgb *= smoothstep(1.6, 0.5, length(uv));
    O.a = 1.0;
}
