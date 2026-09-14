// ==== Image (image) ====
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù                       PATRICK JAILLET                        ù
ù - https://patrickjaillet.github.io/sandefjord-software       ù
ù - https://x.com/JailletPatrick                               ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/

vec4 qSq(vec4 q) {
    return vec4(
        q.x*q.x - dot(q.yzw, q.yzw),
        2.0*q.x*q.yzw
    );
}

float GetDist(vec3 p, inout vec3 glow) {
    vec4 c = vec4(
        -0.2 + 0.2*sin(iTime*0.3), 
        0.5 + 0.1*cos(iTime*0.4), 
        -0.3 + 0.1*sin(iTime*0.5), 
        0.15*cos(iTime*0.2)
    );
    
    vec4 z = vec4(p, 0.0);
    float md2 = 1.0;
    float mz2 = dot(z,z);

    for(int i=0; i<8; i++) {
        md2 *= 4.0 * mz2;
        z = qSq(z) + c;
        mz2 = dot(z,z);
        if(mz2 > 4.0) break;
    }
    
    float d = 0.25 * sqrt(mz2/md2) * log(mz2);
    
    vec3 bloomCol = 0.5 + 0.5*cos(iTime*0.5 + vec3(0,2,4) + p.y*0.5);
    glow += bloomCol * (0.015 / (0.01 + d*d)); 
    
    return d;
}

float noise(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

vec3 GetNebula(vec2 uv) {
    float n = 0.0;
    vec2 p = uv * 2.5;
    float amp = 0.5;
    for(int i=0; i<3; i++) {
        n += noise(vec3(p, iTime*0.02)) * amp;
        p *= 2.2; amp *= 0.5;
    }
    return mix(vec3(0.01, 0.005, 0.02), vec3(0.05, 0.02, 0.1), n);
}

vec3 GetNormal(vec3 p) {
    vec3 g;
    float d = GetDist(p, g);
    vec2 e = vec2(0.01, 0);
    return normalize(d - vec3(
        GetDist(p - e.xyy, g),
        GetDist(p - e.yxy, g),
        GetDist(p - e.yyx, g)
    ));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0, 0, -2.8);
    vec3 rd = normalize(vec3(uv, 1.5));
    
    vec3 col = vec3(0);
    vec3 glow = vec3(0);
    float d = 0.0;
    
    for(int i=0; i<100; i++) {
        vec3 p = ro + rd * d;
        float ds = GetDist(p, glow);
        d += ds * 0.8;
        if(d > 10.0 || ds < 0.001) break;
    }
    
    if(d < 10.0) {
        vec3 p = ro + rd*d;
        vec3 n = GetNormal(p);
        
        float diff = dot(n, normalize(vec3(1,2,-3))) * 0.5 + 0.5;
        vec3 rainbow = 0.5 + 0.5*cos(iTime + p.xyy + vec3(0,2,4));
        
        col = rainbow * diff;
        
        vec3 dummy;
        float occ = clamp(GetDist(p + n*0.1, dummy)*10.0, 0.0, 1.0);
        col *= occ;
    } else {
        col = GetNebula(uv);
    }
    
    col += glow * 0.12;
    col /= 1.0 + col; 
    col = pow(col, vec3(0.4545));
    
    fragColor = vec4(col, 1.0);
}
