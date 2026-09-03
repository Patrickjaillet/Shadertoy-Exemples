// ==== Image (image) ====
#define M_STEPS 120
#define S_DIST 0.001
#define M_DIST 60.0

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float scratchNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    return mix(mix(hash21(i), hash21(i+vec2(1.0,0.0)),f.x),
               mix(hash21(i+vec2(0.0,1.0)), hash21(i+vec2(1.0,1.0)),f.x),f.y);
}

mat2 Rot(float a) { 
    float s = sin(a), c = cos(a); 
    return mat2(c, -s, s, c); 
}

vec3 gOrbitTrap = vec3(0.0);

float sdSierpinski(vec3 p, float s) {
    float scale = 2.1;
    int iterations = 5;
    vec3 v1 = vec3(1.0, 1.0, 1.0);
    gOrbitTrap = vec3(10.0); 
    p /= s;
    for(int n = 0; n < iterations; n++) {
        if(p.x + p.y < 0.0) p.xy = -p.yx;
        if(p.x + p.z < 0.0) p.xz = -p.zx;
        if(p.y + p.z < 0.0) p.yz = -p.zy;
        p = p * scale - v1 * (scale - 1.0);
        gOrbitTrap.y = min(gOrbitTrap.y, length(p.xy));
    }
    return (length(p) - 1.4) * pow(scale, -float(iterations)) * s;
}

float sdMenger(vec3 p, float s) {
    p /= s;
    vec3 d = abs(p) - 1.0;
    float res = min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
    float scale = 3.0;
    for(int n = 0; n < 4; n++) {
        vec3 a = mod(p * scale, 2.0) - 1.0;
        scale *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        res = max(res, (min(da, min(db, dc)) - 1.0) / scale);
        gOrbitTrap.y = min(gOrbitTrap.y, length(a.xy) * 0.5);
    }
    return res * s;
}

float GetDist(vec3 p) {
    float time = iTime * 0.15;
    p.xy *= Rot(p.z * 0.05 + time);
    float repeatZ = 8.0;
    float zId = floor((p.z + repeatZ * 0.5) / repeatZ);
    vec3 p_local = p;
    p_local.z = mod(p_local.z + repeatZ * 0.5, repeatZ) - (repeatZ * 0.5);
    vec3 p_obj = p_local;
    p_obj.xz *= Rot(time * 1.5 + zId);
    p_obj.xy *= Rot(time * 0.8);
    float obj = (mod(zId, 2.0) == 0.0) ? sdSierpinski(p_obj, 1.2) : sdMenger(p_obj, 1.0);
    float hole = length(p.xy) - 1.0;
    return max(obj, -hole); 
}

vec3 GetNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(GetDist(p) - vec3(GetDist(p-e.xyy), GetDist(p-e.yxy), GetDist(p-e.yyx)));
}

vec3 applyCRT(vec3 col, vec2 uv) {
    float scanline = sin(uv.y * iResolution.y * 1.5) * 0.1 + 0.9;
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 15.0;
    return col * scanline * pow(vignette, 0.25);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float timeJump = floor(iTime * 12.0); 
    vec2 shake = vec2(hash11(timeJump), hash11(timeJump + 1.1)) - 0.5;
    shake *= 0.005; 
    
    if(hash11(timeJump * 0.5) > 0.95) shake.y += (hash11(iTime) - 0.5) * 0.05;

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    uv += shake; 
    
    vec2 crtUV = (fragCoord / iResolution.xy) + shake;
    
    vec3 ro = vec3(0.0, 0.0, iTime * 3.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    rd.xy *= Rot(sin(iTime * 0.1) * 0.2);
    
    vec3 finalCol = vec3(0.0);
    float t = 0.0;
    
    for(int i = 0; i < 90; i++) {
        vec3 p = ro + rd * t;
        float d = GetDist(p);
        vec3 col = vec3(1.0);
        
        float rat = scratchNoise(p.xy * 3.0 + p.z);
        col *= (1.0 - smoothstep(0.4, 0.5, rat) * 0.5);
        
        col += exp(-gOrbitTrap.y * 10.0) * 1.5; 
        
        if(d < 0.005) {
            vec3 n = GetNormal(p);
            finalCol += col * max(dot(n, -rd), 0.0) * 0.1;
            d = 0.15; 
        }
        finalCol += col * exp(-d * 3.0) * 0.15;
        t += max(d * 1.5, 0.06);
        if(t > M_DIST) break;
    }

    float gray = dot(finalCol, vec3(0.299, 0.587, 0.114));
    gray = pow(gray, 0.5);
    gray *= 0.85 + 0.15 * hash11(iTime * 15.0);

    float scratch = hash11(floor(crtUV.x * 400.0 + iTime * 20.0));
    if(scratch > 0.98) gray = mix(gray, 0.8, hash11(crtUV.y + iTime));

    gray += (hash21(uv + iTime) - 0.5) * 0.15;

    vec3 sepiaCol = vec3(gray) * vec3(1.2, 1.0, 0.8);
    vec3 col = applyCRT(sepiaCol, crtUV);
    
    fragColor = vec4(col, 1.0);
}

// ==== Sound (sound) ====
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}
vec2 mainSound(int samp, float time) {
    float speed = 3.0;          
    float repeatZ = 8.0;        
    float period = repeatZ / speed; 
    float localTime = mod(time, period);
    float envelope = smoothstep(0.0, 0.5, localTime) * smoothstep(period, period - 1.2, localTime);
    envelope *= exp(-2.0 * abs(localTime - 0.1));
    float noise = 0.0;
    for(float i = 1.0; i < 4.0; i++) {
        float filterFreq = mix(1200.0, 400.0, localTime / period) * i;
        noise += sin(time * filterFreq + hash(time + i) * 6.28);
    }
    float grain = hash(time * 44100.0) * 0.2;
    float wish = (noise * 0.3 + grain) * envelope;
    return vec2(wish * 0.5);
}
