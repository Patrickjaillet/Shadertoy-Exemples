// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    vec4 scene = texture(iChannel0, uv);
    vec3 col = scene.rgb;
    
    vec3 bloom = vec3(0.0);
    for(float i = -2.0; i <= 2.0; i++) {
        for(float j = -2.0; j <= 2.0; j++) {
            bloom += texture(iChannel0, uv + vec2(i, j) * 0.004).rgb;
        }
    }
    col += (bloom / 25.0) * 0.6;
    
    col *= 1.2 - length(uv - 0.5) * 0.5;
    
    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
#define F4 0.309016994374947451
#define ITERATIONS 5

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
float permute(float x){return mod289(((x*34.0)+1.0)*x);}
vec4 permute(vec4 x) {return mod289(((x*34.0)+1.0)*x);}
float taylorInvSqrt(float r){return 1.79284291400159 - 0.85373472095314 * r;}
vec4 taylorInvSqrt(vec4 r) {return 1.79284291400159 - 0.85373472095314 * r;}

vec4 grad4(float j, vec4 ip){
    const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
    vec4 p,s;
    p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
    p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
    s = vec4(lessThan(p, vec4(0.0)));
    p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;
    return p;
}

float snoise4D(vec4 v){
    const vec4 C = vec4(0.138196601125011, 0.276393202250021, 0.414589803375032, -0.447213595499958);
    vec4 i = floor(v + dot(v, vec4(F4)) );
    vec4 x0 = v - i + dot(i, C.xxxx);
    vec4 i0;
    vec3 isX = step( x0.yzw, x0.xxx );
    vec3 isYZ = step( x0.zww, x0.yyz );
    i0.x = isX.x + isX.y + isX.z;
    i0.yzw = 1.0 - isX;
    i0.y += isYZ.x + isYZ.y;
    i0.zw += 1.0 - isYZ.xy;
    i0.z += isYZ.z;
    i0.w += 1.0 - isYZ.z;
    vec4 i3 = clamp( i0, 0.0, 1.0 );
    vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
    vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );
    vec4 x1 = x0 - i1 + C.xxxx;
    vec4 x2 = x0 - i2 + C.yyyy;
    vec4 x3 = x0 - i3 + C.zzzz;
    vec4 x4 = x0 + C.wwww;
    i = mod289(i);
    float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
    vec4 j1 = permute( permute( permute( permute (
               i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
             + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
             + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
             + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));
    vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;
    vec4 p0 = grad4(j0, ip);
    vec4 p1 = grad4(j1.x, ip);
    vec4 p2 = grad4(j1.y, ip);
    vec4 p3 = grad4(j1.z, ip);
    vec4 p4 = grad4(j1.w, ip);
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;
    p4 *= taylorInvSqrt(dot(p4,p4));
    vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
    vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)), 0.0);
    m0 = m0 * m0; m1 = m1 * m1;
    return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
                  + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;
}

float map(vec3 p) {
    vec4 p4 = vec4(p * 0.8, iTime * 0.2);
    float n = snoise4D(p4);
    n += 0.5 * snoise4D(p4 * 2.1);
    return clamp(abs(n) - 0.15, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -2.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    vec3 col = vec3(0.0);
    float t = dither * 0.1;
    float T = 1.0;
    
    for(int i = 0; i < 48; i++) {
        vec3 p = ro + rd * t;
        float den = map(p);
        if(den > 0.01) {
            vec3 lCol = 0.5 + 0.5 * cos(vec3(0,2,4) + p.z + iTime);
            float shadow = clamp((den - map(p + vec3(0.1, 0.2, 0.0))) * 2.0, 0.0, 1.0);
            lCol *= (1.0 + shadow);
            float alpha = den * 0.25;
            col += T * lCol * alpha;
            T *= (1.0 - alpha);
        }
        t += 0.12;
        if(T < 0.01) break;
    }
    fragColor = vec4(col, T);
}
