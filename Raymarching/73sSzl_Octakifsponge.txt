// ==== Image (image) ====
mat2 rot2D(float a)
{
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdOctahedron(vec3 p, float s)
{
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

float map(vec3 p, out vec3 w, out float matIdx)
{
    vec3 p_orig = p;
    float scale = 1.0;
    float d = 1e5;
    
    w = p;
    
    for(int i = 0; i < 8; i++)
    {
        p = abs(p) - vec3(0.38, 0.48, 0.33);
        
        if (p.x < p.y) p.xy = p.yx;
        if (p.x < p.z) p.xz = p.zx;
        if (p.y < p.z) p.yz = p.zy;
        
        p.xy *= rot2D(0.38 + sin(iTime * 0.03) * 0.05);
        p.xz *= rot2D(0.20 + cos(iTime * 0.02) * 0.02);
        
        float k = 1.65;
        p *= k;
        scale *= k;
        
        w = mix(w, cos(p * 1.1), 0.25);
        
        float kifs_sponge = (length(p.xy) - 0.54) / scale;
        d = min(d, kifs_sponge);
    }
    
    vec3 p_cry = p_orig;
    p_cry.y -= sin(iTime * 0.3) * 0.12;
    p_cry.xz *= rot2D(iTime * 0.4);
    p_cry.yx *= rot2D(iTime * 0.20);
    float cry = sdOctahedron(p_cry, 0.26) - 0.005;
    
    if(cry < d)
    {
        matIdx = 1.0;
        return cry;
    }
    
    matIdx = 0.0;
    return d * 0.75;
}

vec3 getNormal(vec3 p)
{
    vec3 w; float m;
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, w, m) - map(p - e.xyy, w, m),
        map(p + e.yxy, w, m) - map(p - e.yxy, w, m),
        map(p + e.yyx, w, m) - map(p - e.yyx, w, m)
    ));
}

float getAO(vec3 p, vec3 n)
{
    float occ = 0.0;
    float sca = 1.0;
    vec3 w; float m;
    for(int i = 0; i < 5; i++)
    {
        float hr = 0.01 + 0.15 * float(i) / 4.0;
        float d = map(p + n * hr, w, m);
        occ += (hr - d) * sca;
        sca *= 0.75;
    }
    return clamp(1.0 - 5.0 * occ, 0.0, 1.0);
}

vec3 getEnvironment(vec3 rd)
{
    vec3 bg = mix(vec3(0.001, 0.002, 0.005), vec3(0.01, 0.015, 0.03), rd.y * 0.5 + 0.5);
    
    vec3 lDir1 = normalize(vec3(1.5, 0.8, -0.5));
    bg += vec3(1.0, 0.75, 0.6) * pow(clamp(dot(rd, lDir1), 0.0, 1.0), 60.0);
    
    vec3 lDir2 = normalize(vec3(-1.5, -0.3, 0.8));
    bg += vec3(0.2, 0.4, 0.8) * pow(clamp(dot(rd, lDir2), 0.0, 1.0), 25.0);
    
    bg += vec3(0.15, 0.2, 0.3) * pow(max(0.0, 1.0 - abs(rd.y)), 12.0);
    
    return bg;
}

vec3 render(vec3 ro, vec3 rd)
{
    float t = 0.0;
    vec3 w = vec3(0.0);
    float matIdx = 0.0;
    bool hit = false;
    
    for(int i = 0; i < 100; i++)
    {
        vec3 p = ro + rd * t;
        float d = map(p, w, matIdx);
        if(d < 0.0015)
        {
            hit = true;
            break;
        }
        t += d;
        if(t > 30.0) break;
    }
    
    vec3 bg = getEnvironment(rd);
    if(!hit) return bg;
    
    vec3 p = ro + rd * t;
    vec3 n = getNormal(p);
    vec3 r = reflect(rd, n);
    
    float ao = getAO(p, n);
    vec3 refCol = getEnvironment(r);
    
    vec3 lDir1 = normalize(vec3(5.0, 8.0, -4.0) - p);
    float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 5.0);
    
    vec3 albedo = vec3(0.0);
    
    if(matIdx < 0.5)
    {
        vec3 chromeTint = mix(vec3(0.97, 0.98, 1.0), vec3(0.80, 0.88, 1.0), smoothstep(-0.3, 0.5, sin(w.x * 3.5) * cos(w.z * 3.5)));
        
        float spe = pow(clamp(dot(r, lDir1), 0.0, 1.0), 250.0);
        vec3 specColor = spe * vec3(1.5, 1.35, 1.1);
        
        albedo = refCol * chromeTint;
        albedo += specColor;
        albedo = mix(albedo, albedo * ao, 0.5);
        albedo += fre * vec3(0.5, 0.75, 1.0) * ao;
    }
    else
    {
        vec3 crystalBase = mix(vec3(0.95, 0.05, 0.35), vec3(0.02, 0.80, 0.95), sin(p.y * 12.0 + iTime * 0.8) * 0.5 + 0.5);
        float spe = pow(clamp(dot(r, lDir1), 0.0, 1.0), 180.0);
        
        albedo = mix(crystalBase, refCol, 0.4 + 0.6 * fre);
        albedo += spe * vec3(1.8) + fre * vec3(0.7, 0.9, 1.0);
        albedo *= (ao * 0.6 + 0.4);
    }
    
    vec3 finalColor = mix(albedo, bg, 1.0 - exp(-0.012 * t * t));
    return finalColor;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float tCam = iTime * 0.15;
    float radius = 3.6 + sin(iTime * 0.11) * 0.2;
    
    vec3 ro = vec3(
        radius * sin(tCam) * cos(tCam * 0.3), 
        radius * sin(tCam * 0.5), 
        radius * cos(tCam) * cos(tCam * 0.3)
    );
    vec3 ta = vec3(0.0, 0.0, 0.0);
    
    vec3 cz = normalize(ta - ro);
    vec3 up = vec3(sin(iTime * 0.1) * 0.1, 1.0, cos(iTime * 0.1) * 0.1);
    vec3 cx = normalize(cross(up, cz));
    vec3 cy = cross(cz, cx);
    mat3 camMat = mat3(cx, cy, cz);
    
    vec3 rd = camMat * normalize(vec3(uv, 2.2));
    
    vec3 color = render(ro, rd);
    
    color = pow(color, vec3(0.4545)); 
    
    color = mix(color, vec3(dot(color, vec3(0.2126, 0.7152, 0.0722))), -0.05);
    color = smoothstep(0.0, 1.0, color);
    color = color * color * (2.6 - 0.7 * color);
    
    vec2 d = fragCoord / iResolution.xy;
    color *= 0.65 + 0.35 * pow(16.0 * d.x * d.y * (1.0 - d.x) * (1.0 - d.y), 0.28);
    
    fragColor = vec4(color, 1.0);
}
