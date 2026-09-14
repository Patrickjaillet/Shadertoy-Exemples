// ==== Image (image) ====
mat2 rotate2D(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 hsv(float h, float s, float v)
{
    vec3 c = clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return v * mix(vec3(1.0), c, s);
}

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float smin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdPetal(vec3 p, float scale)
{
    p /= scale;
    float curl = p.x * p.x * 0.45 - p.y * 0.15;
    p.z += curl;
    
    float wave = sin(p.x * 22.0) * 0.015 * smoothstep(0.1, 0.8, p.x);
    p.z += wave;

    vec3 sp = p * vec3(1.1, 4.0, 3.5);
    sp.x -= 0.35;
    float d = length(sp) - 0.38;
    
    d = max(d, abs(p.z) - 0.012 * (1.0 - p.x * 0.7));
    return d * scale;
}

float sdStamen(vec3 p, out float isTip)
{
    float angle = atan(p.z, p.x);
    float r = length(p.xz);
    
    float sector = 6.283185 / 24.0;
    angle = mod(angle + sector * 0.5, sector) - sector * 0.5;
    
    vec3 q = vec3(cos(angle) * r, p.y, sin(angle) * r);
    q.x -= 0.08 + sin(p.y * 15.0) * 0.01;
    
    float stem = length(q.xz) - 0.004;
    stem = max(stem, abs(q.y - 0.12) - 0.12);
    
    float tip = length(q - vec3(0.01, 0.24, 0.0)) - 0.015;
    
    isTip = (tip < stem) ? 1.0 : 0.0;
    return min(stem, tip);
}

float map(vec3 p, out vec4 matInfo)
{
    float d = 1e5;
    matInfo = vec4(0.0);

    float stemCurve = sin(p.y * 1.2) * 0.08;
    vec3 pStem = p;
    pStem.x += stemCurve;
    
    float stem = length(pStem.xz) - (0.035 - pStem.y * 0.005);
    stem = max(stem, -pStem.y - 1.6);
    stem = max(stem, pStem.y - 0.05);

    vec3 pCalyx = pStem - vec3(0.0, 0.02, 0.0);
    float calyx = length(pCalyx * vec3(1.0, 0.6, 1.0)) - 0.12;
    stem = smin(stem, calyx, 0.08);

    if (stem < d)
    {
        d = stem;
        matInfo = vec4(1.0, pStem.y, length(pStem.xz), 0.0);
    }

    float isTip = 0.0;
    vec3 pCenter = p - vec3(-stemCurve, 0.02, 0.0);
    float stamens = sdStamen(pCenter, isTip);
    if (stamens < d)
    {
        d = stamens;
        matInfo = vec4(2.0, isTip, 0.0, 0.0);
    }

    vec3 pFlower = pCenter;
    pFlower.y -= 0.04;

    for (int l = 0; l < 5; l++)
    {
        float layer = float(l);
        float count = 5.0 + layer * 2.0;
        float sector = 6.283185 / count;
        float layerScale = 0.75 + layer * 0.22;
        
        mat2 rotLayer = rotate2D(layer * 0.45);

        vec3 q = pFlower;
        q.xz = rotLayer * q.xz;
        
        float a = atan(q.z, q.x);
        a = mod(a + sector * 0.5, sector) - sector * 0.5;
        
        float r = length(q.xz);
        vec3 pPetal = vec3(cos(a) * r, q.y, sin(a) * r);
        
        float droop = 0.2 + layer * 0.12;
        pPetal.yz *= rotate2D(-droop);
        pPetal.y += layer * 0.03;
        
        float petalDist = sdPetal(pPetal, layerScale);
        
        if (petalDist < d)
        {
            d = petalDist;
            matInfo = vec4(3.0, layer, pPetal.x / layerScale, length(pPetal.zy));
        }
    }

    return d;
}

vec3 calcNormal(vec3 p)
{
    vec4 dummy;
    vec2 e = vec2(0.0008, 0.0);
    return normalize(vec3(
        map(p + e.xyy, dummy) - map(p - e.xyy, dummy),
        map(p + e.yxy, dummy) - map(p - e.yxy, dummy),
        map(p + e.yyx, dummy) - map(p - e.yyx, dummy)
    ));
}

float calcAO(vec3 p, vec3 n)
{
    float occ = 0.0;
    float sca = 1.0;
    vec4 dummy;
    for (int i = 0; i < 5; i++)
    {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = map(p + h * n, dummy);
        occ += (h - d) * sca;
        sca *= 0.92;
    }
    return clamp(1.0 - 2.5 * occ, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;

    vec3 ro = vec3(0.0, 0.5, -2.3);
    vec3 rd = normalize(vec3(uv, 1.3));

    mat2 camRot = rotate2D(t * 0.2);
    ro.xz *= camRot;
    rd.xz *= camRot;

    ro.yz *= rotate2D(-0.1);
    rd.yz *= rotate2D(-0.1);

    float depth = 0.0;
    vec4 matInfo = vec4(0.0);
    vec4 hitMat = vec4(0.0);
    bool hit = false;

    for (int i = 0; i < 160; i++)
    {
        vec3 p = ro + rd * depth;
        float d = map(p, matInfo);
        if (d < 0.0008)
        {
            hit = true;
            hitMat = matInfo;
            break;
        }
        depth += d * 0.5;
        if (depth > 5.5) break;
    }

    vec3 bg = mix(vec3(0.02, 0.015, 0.03), vec3(0.003, 0.002, 0.005), length(uv) * 1.2);

    if (hit)
    {
        vec3 p = ro + rd * depth;
        vec3 n = calcNormal(p);
        vec3 lightDir = normalize(vec3(1.2, 2.2, -1.4));
        vec3 lightCol = vec3(1.0, 0.95, 0.88) * 1.4;

        float ao = calcAO(p, n);
        float diff = max(dot(n, lightDir), 0.0);
        float spec = pow(max(dot(reflect(-lightDir, n), -rd), 0.0), 32.0);
        float fresnel = pow(1.0 - max(dot(-rd, n), 0.0), 4.0);

        vec3 albedo = vec3(0.0);
        float translucency = 0.0;

        if (hitMat.x == 1.0)
        {
            albedo = mix(vec3(0.05, 0.35, 0.08), vec3(0.15, 0.45, 0.1), smoothstep(-1.0, 0.0, hitMat.y));
            translucency = 0.15;
        }
        else if (hitMat.x == 2.0)
        {
            albedo = (hitMat.y > 0.5) ? vec3(1.0, 0.82, 0.1) : vec3(0.8, 0.7, 0.3);
            translucency = 0.4;
        }
        else if (hitMat.x == 3.0)
        {
            float layer = hitMat.y;
            float petalPos = hitMat.z;
            
            float hue = 0.92 - layer * 0.02 + petalPos * 0.05;
            albedo = hsv(hue, 0.82, 0.98);
            
            vec3 coreGlow = vec3(1.0, 0.4, 0.05) * (1.0 - smoothstep(0.0, 0.4, petalPos));
            albedo = mix(albedo, coreGlow, 0.6);

            float vein = sin(hitMat.w * 180.0) * 0.05 + 0.95;
            albedo *= vein;
            
            translucency = 0.75 - layer * 0.1;
        }

        vec3 backLight = lightDir * vec3(-1.0, 1.0, -1.0);
        float sss = pow(max(dot(-rd, backLight), 0.0), 2.0) * translucency;
        vec3 sssCol = albedo * vec3(1.2, 0.4, 0.2) * sss * 2.2;

        vec3 ambient = albedo * vec3(0.12, 0.1, 0.18) * ao;
        vec3 direct = albedo * lightCol * diff * ao;
        vec3 specular = vec3(1.0) * spec * 0.4 * ao;
        vec3 rim = vec3(0.8, 0.5, 0.9) * fresnel * 0.5;

        bg = direct + ambient + specular + sssCol + rim;
    }

    bg = bg / (1.0 + bg);
    bg = pow(bg, vec3(0.4545));

    fragColor = vec4(bg, 1.0);
}
