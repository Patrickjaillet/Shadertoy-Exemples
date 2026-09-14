// ==== Image (image) ====
#define MAX_STEPS 180
#define MIN_DIST 0.0005
#define MAX_DIST 100.0

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 hash33(vec3 p) {
    p = fract(p * vec3(.1031, .1030, .0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float triplanar(sampler2D tex, vec3 p, vec3 n) {
    vec3 m = pow(abs(n), vec3(10.0));
    m /= (m.x + m.y + m.z);
    float x = texture(tex, p.yz).r;
    float y = texture(tex, p.zx).r;
    float z = texture(tex, p.xy).r;
    return x * m.x + y * m.y + z * m.z;
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 3; i++) {
        v += a * texture(iChannel0, p.xz * 0.1).r;
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

float matID = 0.0;
float globalExplo = 0.0;

float map(vec3 p) {
    float d = 1e10;
    matID = 0.0;
    
    float speed = iTime * 4.0;
    float turretAngle = sin(iTime * 0.5) * 0.7;
    
    vec3 hp = p - vec3(0.0, 0.7, 0.0);
    float hullBump = triplanar(iChannel0, p * 0.5, vec3(0,1,0)) * 0.04;
    float hull = sdBox(hp, vec3(1.4, 0.25, 2.8)) - hullBump;
    hull = min(hull, sdBox(hp - vec3(0.0, 0.15, 1.2), vec3(1.4, 0.4, 1.5)) - hullBump);
    
    vec3 tp = p - vec3(0.0, 1.45, -0.2);
    tp.xz *= rot(turretAngle);
    float turretRing = sdCylinder(tp + vec3(0.0, 0.2, 0.0), 0.1, 0.8);
    float turret = sdBox(tp, vec3(1.0, 0.3, 1.2)) - hullBump;
    
    vec3 bp = tp - vec3(0.0, 0.0, 1.4);
    float barrel = sdCylinder(bp.xzy, 2.2, 0.14);
    
    float tankBody = min(hull, min(turretRing, min(turret, barrel)));
    d = tankBody;
    matID = 1.0;
    
    vec3 cp = p;
    cp.x = abs(cp.x) - 1.45;
    float trackUV = (p.z * 0.2) + (speed * 0.1); 
    float chainBump = texture(iChannel1, vec2(trackUV, cp.x)).r * 0.05;
    float tracks = sdBox(cp - vec3(0.0, 0.45, 0.0), vec3(0.35, 0.4, 3.0)) - chainBump;
    
    if(tracks < d) {
        d = tracks;
        matID = 2.0;
    }
    
    vec3 wp = cp;
    float wheels = 1e10;
    for(int i = 0; i < 6; i++) {
        float zOff = float(i) * 0.9 - 2.2;
        vec3 wheelP = wp - vec3(0.0, 0.38, zOff);
        wheelP.yz *= rot(speed); 
        wheels = min(wheels, sdCylinder(wheelP.zyx, 0.15, 0.38));
    }
    
    if(wheels < d) {
        d = wheels;
        matID = 1.0;
    }
    
    float groundBase = p.y;
    float groundTex = texture(iChannel0, vec2(p.x * 0.1, (p.z + speed) * 0.1)).r * 0.05;
    
    float trail = 0.0;
    if(abs(abs(p.x) - 1.45) < 0.35 && p.z < -1.0) {
        float trackPattern = texture(iChannel1, vec2(p.x * 2.0, (p.z + speed) * 0.2)).r;
        float fade = smoothstep(-1.0, -3.0, p.z);
        trail = -0.06 * trackPattern * fade;
    }
    
    float ground = groundBase + groundTex + trail;
    
    if(ground < d) {
        d = ground;
        matID = 0.0;
    }

    for(int i = 0; i < 4; i++) {
        float tID = floor(iTime * 1.2 + float(i) * 2.1);
        float localT = fract(iTime * 1.2 + float(i) * 2.1);
        vec3 rand = hash33(vec3(tID, 45.6, 78.9));
        
        float side = sign(rand.x - 0.5);
        vec3 expPos = vec3(side * (8.0 + rand.y * 15.0), 0.0, (rand.z - 0.5) * 40.0);
        
        float radius = localT * 2.5;
        float noise = fbm(p * 3.0 - iTime * 2.0);
        float fireball = length(p - expPos) - radius - noise * (0.8 - localT);
        
        float intensity = exp(-4.0 * fireball) * (1.0 - localT);
        globalExplo += intensity;
        
        if(fireball < d) {
            d = fireball;
            matID = 4.0;
        }
    }
    
    return d;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

vec3 getSky(vec3 rd) {
    vec3 col = vec3(0.02, 0.04, 0.08); 
    vec3 sunPos = normalize(vec3(1.0, 1.5, 0.8));
    float sun = pow(max(dot(rd, sunPos), 0.0), 32.0);
    col += vec3(1.0, 0.6, 0.3) * sun * 0.5;
    col = mix(col, vec3(0.05, 0.06, 0.1), exp(-15.0 * max(rd.y, 0.0)));
    if(rd.y > 0.0) {
        float stars = pow(hash33(floor(rd * 300.0)).r, 20.0);
        col += stars * step(0.9, hash33(floor(rd * 300.0)).g);
    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float camTime = iTime * 0.3;
    float radX = 12.0;
    float radZ = 18.0;
    vec3 ro = vec3(radX * sin(camTime), 6.0 + sin(iTime * 0.5) * 2.0, radZ * cos(camTime));
    
    vec3 ta = vec3(0.0, 1.0, 0.0);
    vec3 cw = normalize(ta - ro);
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.8 * cw);

    float t = 0.0, id = 0.0;
    globalExplo = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        float h = map(ro + rd * t);
        if(abs(h) < MIN_DIST || t > MAX_DIST) break;
        t += h;
        id = matID;
    }

    vec3 col = getSky(rd);
    
    if(t < MAX_DIST) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        vec3 light = normalize(vec3(1.0, 1.5, 0.8));
        
        vec3 albedo;
        if(id < 0.5) {
            albedo = texture(iChannel0, vec2(p.x, p.z + iTime * 4.0) * 0.1).rgb * 0.15;
            if(abs(abs(p.x) - 1.45) < 0.35 && p.z < -1.0) albedo *= 0.4;
        }
        else if(id < 1.5) albedo = triplanar(iChannel0, p, n) * vec3(0.18, 0.2, 0.15);
        else if(id < 2.5) albedo = texture(iChannel1, vec2(p.z + iTime * 4.0, p.y)).rgb * 0.1;
        else albedo = vec3(1.0, 0.3, 0.05) * globalExplo;
        
        float diff = max(dot(n, light), 0.0);
        float amb = 0.1 * clamp(0.5 + 0.5 * n.y, 0.0, 1.0);
        vec3 render = albedo * (diff + amb);
        if(id == 4.0) render += vec3(3.0, 1.0, 0.2) * globalExplo;
        float fog = 1.0 - exp(-0.00002 * t * t * t);
        col = mix(render, col, fog);
    }
    
    col += vec3(1.0, 0.3, 0.1) * globalExplo * 0.15;
    col = pow(col, vec3(0.4545));
    col *= 1.0 - dot(uv, uv) * 0.5;
    fragColor = vec4(col, 1.0);
}
