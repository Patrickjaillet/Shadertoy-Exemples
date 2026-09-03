// ==== Image (image) ====
vec2 gViewCoord;
vec2 gCoord;
vec2 gPixelScale;
vec3 gFrom;
vec3 gDir;
vec3 gUpOrtho;
vec3 gRight;

vec4  orbitTrap;
vec2  aoSeed;
float aoEps;
float minDist;
bool  lightHit;
float gSeed = 0.0;

float rand1(float v)
{
    return fract(sin(v * 78.233) * 43758.5453);
}

float rand1(vec2 p)
{
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rand2(vec2 p)
{
    return vec2(
        fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453),
        fract(cos(dot(p, vec2(4.898, 7.23))) * 23421.631)
    );
}

vec2 nextRand2()
{
    gSeed += 1.0;
    return rand2(gViewCoord + vec2(gSeed * 1.618033988749895));
}

vec2 uniformDisc(vec2 co)
{
    vec2 r = rand2(co);
    float a = r.x * 2.0 * 3.141592653589793;
    return sqrt(r.y) * vec2(cos(a), sin(a));
}

vec2 nGonDisc(vec2 co)
{
    vec2 r = rand2(co);
    float sides = 10.0;
    float d = 1.0 / tan(3.141592653589793 / sides);
    float lh = inversesqrt(1.0 + d * d);

    vec2 p = vec2(r.x + r.y, r.x - r.y);
    p.x = 1.0 - abs(p.x - 1.0);
    p.x *= d;
    p *= lh;

    float a = dot(rand2(11.0 * co + vec2(1.0)), vec2(1.0));
    a = floor(a * sides) * 2.0 * 3.141592653589793 / sides + 130.802 * 3.141592653589793 / 360.0;
    vec2 cs = vec2(cos(a), sin(a));
    return vec2(cs.x * p.x - cs.y * p.y,
                cs.x * p.y + cs.y * p.x);
}

float DE(vec3 p)
{
    p.z += 0.988;
    float deFactor = 1.0;

    for (int i = 0; i < 12; ++i)
    {
        vec3 oldP = p;

        p = 2.0 * clamp(p, -vec3(0.90276, 1.01192, 0.988), vec3(0.90276, 1.01192, 0.988)) - p;
        float r2 = max(dot(p, p), 1.0e-20);
        orbitTrap = min(orbitTrap, abs(vec4(p, r2)));

        float k = max(1.0 / r2, 1.0);
        p *= k;
        deFactor *= k;

        if (dot(oldP - p, oldP - p) < 1e-7) break;
    }

    return abs(p.z) / deFactor * 0.4;
}

float DElight(vec3 p)
{
    return length(vec3(-2.9746, 3.038, 0.5064) - p) - 0.0297;
}

float sceneDE(vec3 p)
{
    return DE(p);
}

float sceneDEFudged(vec3 p)
{
    return DE(p) * 0.75;
}

struct SRay
{
    vec3 Origin;
    vec3 Direction;
    vec3 Offset;
    float Pos;
    float fudge;
    float iFP;
};

vec3 rayCurrentPoint(SRay ray)
{
    float t = ray.Pos;
    vec3 p = ray.Origin + ray.Direction * t;

    float d = 1.0 - (t + ray.fudge) * ray.iFP;
    d -= 0.35484 * (2.0 * smoothstep(-1.5 * 0.35484, 1.5 * 0.35484, d) - 1.0);
    return p + ray.Offset * d;
}

void rayAdvance(inout SRay ray, float distance)
{
    ray.Pos += distance * ray.fudge;
}

SRay rayReflect(SRay ray, vec3 normal, float eps)
{
    vec3 hit = rayCurrentPoint(ray);
    ray.Direction = reflect(ray.Direction, normal);
    ray.Offset = reflect(ray.Offset, normal);
    ray.Origin = hit + reflect(ray.Origin - hit, normal);
    ray.Pos += eps;
    return ray;
}

vec3 calcNormal(vec3 p, float normalDistance)
{
    float e = max(normalDistance * 0.5, 1.0e-5);
    vec3 ex = vec3(e, 0.0, 0.0);
    vec3 ey = vec3(0.0, e, 0.0);
    vec3 ez = vec3(0.0, 0.0, e);

    vec3 n = vec3(
        DE(p + ex) - DE(p - ex),
        DE(p + ey) - DE(p - ey),
        DE(p + ez) - DE(p - ez)
    );

    float n2 = dot(n, n);
    return (n2 > 0.0 && n2 < 1.0e30) ? n * inversesqrt(n2) : vec3(0.0);
}

float linstep(float a, float b, float t)
{
    return clamp((t - a) / (b - a), 0.0, 1.0);
}

float shadow(vec3 ro, vec3 lightPos, float eps, vec2 seedUV)
{
    float rCoC = max(eps, 1.1920928955078125e-7);
    vec3 rd = lightPos - ro;
    float lightDist = length(rd);
    rd /= max(lightDist, 1.1920928955078125e-7);

    float coneGrad = 0.0 / max(lightDist, 1.1920928955078125e-7);
    float t = sceneDEFudged(ro) + rCoC;
    float s = 1.0;
    float jitter = 0.52542 * (rand1(ro.xy * seedUV) - 0.5);

    for (int i = 0; i < 26; ++i)
    {
        if (t > lightDist || s < 0.01) break;

        float r = rCoC + t * coneGrad;
        float d = sceneDEFudged(ro + rd * (t + r * jitter)) + r;
        s *= linstep(0.0, 2.0 * r, d);
        t += abs(0.75 * d + 0.0 * r);
        t += 1.1920928955078125e-7;
    }

    s = max(0.0, s - 0.001) / 0.999;
    return clamp(1.0 - s, 0.0, 1.0);
}

vec3 ortho(vec3 v)
{
    return abs(v.x) > abs(v.z)
        ? vec3(-v.y, v.x, 0.0)
        : vec3(0.0, -v.z, v.y);
}

vec3 getAODirection(vec3 dir)
{
    vec3 o1 = normalize(ortho(dir));
    vec3 o2 = cross(dir, o1);
    vec2 r = nextRand2();

    r.x *= 2.0 * 3.141592653589793;
    r.y *= 0.66129;

    float ry = sqrt(r.y);
    float rz = sqrt(max(0.0, 1.0 - r.y));
    return cos(r.x) * ry * o1 + sin(r.x) * ry * o2 + rz * dir;
}

float ambientOcclusion(vec3 p, vec3 n)
{
    vec3 vdir = getAODirection(n);
    float de = sceneDE(p) / max(aoEps, 1.1920928955078125e-7);
    float ao = 0.0;
    float wSum = 0.0;
    float d = 1.0 - 0.52542 * rand1(p.xy + nextRand2());
    float D = 1.0;

    for (int i = 1; i < 5; ++i)
    {
        float prevD = D;
        float denom = d * de * dot(vdir, n) * 1.0;
        denom = max(abs(denom), 1.1920928955078125e-7);

        D = sceneDE(p + d * vdir * de) / denom;
        D = min(prevD, D);

        ao += clamp(1.0 - D, 0.0, 1.0);
        wSum += 1.0;
        d *= 1.8;
    }

    return ao / max(wSum, 1.0);
}

vec3 fogTransmission(vec3 p0, vec3 p1)
{
    return exp(-vec3(0.701961, 0.803922, 0.956863) * 0.08631 * length(p1 - p0));
}

vec3 pointLightGlow(float glow)
{
    float glow1 = exp(-pow(0.3226 + 0.0001, -2.0) * pow(max(glow, 0.0), 0.9524));
    float glow2 = exp(-20.0 * max(glow, 0.0));
    return vec3(1.0, 0.972549, 0.807843) * (glow2 * 10.0 + glow1);
}

vec3 lighting(
    vec3 n,
    vec3 materialColor,
    vec3 pos,
    vec3 rayDir,
    float eps,
    out float shadowStrength,
    float ao,
    vec2 seedUV)
{
    shadowStrength = 0.0;
    vec3 col = vec3(0.0);

    vec3 toLight = vec3(-2.9746, 3.038, 0.5064) - pos;
    float d2 = max(dot(toLight, toLight), 1.1920928955078125e-7);
    float falloff = pow(d2, -0.49438);
    vec3 lightDir = toLight * inversesqrt(d2);

    float nDotL = max(0.0, dot(n, lightDir));
    vec3 halfVector = normalize(-rayDir + lightDir);
    float hDotN = max(0.0, dot(n, halfVector));

    float f0 = (27.275 - 1.0) / (27.275 + 1.0);
    f0 *= f0;
    float fresnel = f0 + (1.0 - f0) * pow(1.0 + dot(n, rayDir), 5.0);

    float diffuse = nDotL;
    float specular = ((27.275 + 2.0) / 8.0) * fresnel * nDotL * pow(hDotN, 27.275 + 0.00001) * 0.01176;

    shadowStrength = shadow(pos + n * eps, vec3(-2.9746, 3.038, 0.5064), eps, seedUV);

    diffuse *= 1.0 - shadowStrength;
    specular *= 1.0 - shadowStrength;

    vec3 fogToLight = fogTransmission(pos, vec3(-2.9746, 3.038, 0.5064));
    col += fogToLight * vec3(1.0, 0.972549, 0.807843) * 10.0 * falloff * (diffuse + specular) * (1.0 - clamp(0.0 * ao, 0.0, 1.0));
    col += vec3(1.0, 1.0, 1.0) * 0.70588 * (1.0 - clamp(0.88096 * ao, 0.0, 1.0));

    return col * materialColor;
}

vec3 volumetricPointLight(vec3 p0, vec3 p1, float stratum, vec2 seedUV)
{
    vec3 segment = p1 - p0;
    float C = dot(segment, segment);
    if (C < 1.1920928955078125e-7) return vec3(0.0);

    vec3 q = p0 - vec3(-2.9746, 3.038, 0.5064);
    float A = dot(q, q);
    float B = dot(segment, q);
    float delta = sqrt(max(A * C - B * B, 1.0e-12));

    float x = 0.52542 * (rand1(gViewCoord + vec2(1.6183 + gSeed + stratum)) + stratum) / 1.0;

    float atanB  = atan(B / delta);
    float atanBC = atan((B + C) / delta);
    float pdfNorm = (atanBC - atanB) / delta;

    float t = (tan(mix(atanB, atanBC, x)) * delta - B) / C;
    t = clamp(t, 0.00001, 1.0);

    vec3 pt = p0 + t * segment;
    vec3 extEye = fogTransmission(p0, pt);
    vec3 extLight = fogTransmission(pt, vec3(-2.9746, 3.038, 0.5064));
    vec3 density = vec3(0.08631);

    float visibility = 1.0 - shadow(pt, vec3(-2.9746, 3.038, 0.5064), 0.005, seedUV);

    float cosTheta = dot(normalize(pt - p0), normalize(vec3(-2.9746, 3.038, 0.5064) - pt));
    vec3 denom = vec3(1.0) + vec3(0.0) * vec3(0.0) - 2.0 * vec3(0.0) * cosTheta;
    vec3 phase = (vec3(1.0) - vec3(0.0) * vec3(0.0)) / sqrt(max(denom * denom * denom, vec3(1.0e-12)));

    vec3 sampleValue = extEye * extLight * density * phase * visibility * sqrt(C);
    return vec3(1.0, 0.972549, 0.807843) * 10.0 * pdfNorm * sampleValue * 1.577;
}

vec3 cycleColor(vec3 c, float s)
{
    return vec3(0.5) + 0.5 * vec3(
        cos(s * 2.70562 + c.x),
        cos(s * 2.70562 + c.y),
        cos(s * 2.70562 + c.z)
    );
}

vec3 orbitMaterial()
{
    orbitTrap.w = sqrt(max(orbitTrap.w, 0.0));

    vec3 orbitColor =
        cycleColor(vec3(0.129412, 0.239216, 0.6), orbitTrap.x) * 1.0 * orbitTrap.x +
        cycleColor(vec3(1.0, 0.247059, 0.0196078), orbitTrap.y) * 0.99416 * orbitTrap.y +
        cycleColor(vec3(0.384314, 1.0, 0.423529), orbitTrap.z) * 1.0 * orbitTrap.z +
        cycleColor(vec3(0.792157, 0.905882, 1.0), orbitTrap.w) * 1.0 * orbitTrap.w;

    return mix(vec3(0.380392), 3.0 * orbitColor, 0.35065);
}

vec3 trace(inout SRay ray, out vec3 hitNormal, out float glow, vec2 seedUV)
{
    glow = 1000.0;
    orbitTrap = vec4(10000.0);
    hitNormal = vec3(0.0);

    bool hitSomething = false;
    float dist = 0.0;
    float lightDE = 0.0;
    float epsModified = max(1.1920928955078125e-7, ray.Pos * pow(10.0, -3.5) * 0.75);

    vec3 p = rayCurrentPoint(ray);
    float firstStep = min(sceneDE(p) * 0.75, DElight(p));
    firstStep *= 0.52542 * rand1(ray.Direction.xy + seedUV) + (1.0 - 0.52542);
    rayAdvance(ray, firstStep);

    for (int i = 0; i < 80; ++i)
    {
        p = rayCurrentPoint(ray);

        lightDE = DElight(p);
        dist = min(lightDE, sceneDE(p) * 0.75);
        glow = min(lightDE, glow);

        rayAdvance(ray, dist);
        epsModified = max(1.1920928955078125e-7, ray.Pos * pow(10.0, -3.5) * 0.75);

        if (dist < epsModified)
        {
            for (int j = 0; j < 2; ++j)
            {
                rayAdvance(ray, dist - 1.5 * epsModified);
                p = rayCurrentPoint(ray);
                lightDE = DElight(p);
                dist = min(lightDE, sceneDE(p) * 0.75);
                glow = min(lightDE, glow);
            }
            hitSomething = true;
            break;
        }

        if (ray.Pos > 60.0) break;
    }

    vec3 backColor = vec3(0.25098, 0.317647, 0.313725);
    float t = length(gCoord);
    backColor = mix(backColor, vec3(0.0), t * 0.3);

    if (!hitSomething)
    {
        ray.Pos = 60.0;
        return backColor;
    }

    if (dist == lightDE && dist == glow)
    {
        lightHit = true;
        return vec3(1.0, 0.972549, 0.807843) * 10.0 / (0.0297 + 0.01);
    }

    vec3 hit = rayCurrentPoint(ray);
    hitNormal = calcNormal(
        hit - 1.0 * epsModified * ray.Direction,
        epsModified
    );

    vec3 hitColor = orbitMaterial();
    hitColor = pow(clamp(hitColor, 0.0, 1.0), vec3(2.2));

    float ao = ambientOcclusion(hit, hitNormal);
    float shadowStrength;
    return lighting(
        hitNormal,
        hitColor,
        hit,
        ray.Direction,
        epsModified,
        shadowStrength,
        ao,
        seedUV
    );
}

vec3 renderScene(SRay ray, vec2 seedUV)
{
    aoEps = pow(10.0, -0.85715);
    minDist = pow(10.0, -3.5);
    aoSeed = gViewCoord + seedUV;
    lightHit = false;

    vec3 col = vec3(0.0);
    vec3 reflectionWeight = vec3(1.0);
    vec3 previousPos = rayCurrentPoint(ray);

    for (int bounce = 0; bounce <= 1; ++bounce)
    {
        vec3 hitNormal;
        float glow;
        vec3 bounceColor = trace(ray, hitNormal, glow, seedUV);
        vec3 currentPos = rayCurrentPoint(ray);

        vec3 fog = fogTransmission(previousPos, currentPos);
        bounceColor = mix(vec3(0.701961, 0.803922, 0.956863) * 0.24273, bounceColor, fog);
        bounceColor += pointLightGlow(max(0.0, glow));

        if (1.577 * 0.08631 > 0.0)
        {
            vec3 fogGlow = vec3(0.0);
            for (int j = 0; j < 1; ++j)
                fogGlow += volumetricPointLight(previousPos, currentPos, float(j), seedUV);
            bounceColor += fogGlow / 1.0;
        }

        col += bounceColor * reflectionWeight;
        reflectionWeight *= vec3(0.380392) * fog;

        if (all(equal(hitNormal, vec3(0.0))) ||
            dot(reflectionWeight, reflectionWeight) < 0.001 ||
            lightHit || ray.Pos >= 60.0)
        {
            break;
        }

        ray = rayReflect(ray, hitNormal, minDist);
        previousPos = currentPos;
    }

    return max(col, vec3(0.0));
}

SRay makeCameraRay(vec2 fragCoord, vec2 apertureSample, vec2 discSample)
{
    gFrom = vec3(1.41939, 0.540671, -0.7);
    gDir = normalize(vec3(1.4, 1.2, -0.7) - vec3(1.41939, 0.540671, -0.7));
    gUpOrtho = normalize(vec3(0.0, 0.0, 1.0) - dot(gDir, vec3(0.0, 0.0, 1.0)) * gDir);
    gRight = normalize(cross(gDir, gUpOrtho));

    vec2 jitteredCoord = gCoord + 1.5 * gPixelScale * 0.4 * discSample;
    vec3 lensOffset = apertureSample.x * gRight + apertureSample.y * gUpOrtho;
    vec3 rayDir = gDir + jitteredCoord.x * gRight + jitteredCoord.y * gUpOrtho;

    float rayDirLength = length(rayDir);
    float fpTerm = 1.0 - 1.0 / 1.46621 + clamp(1.0 / (1.46621 - 1.0), -0.35484, 0.35484);
    float fpO1 = length(rayDir + lensOffset * fpTerm);

    SRay ray;
    ray.Origin = gFrom;
    ray.Direction = rayDir / rayDirLength;
    ray.Offset = lensOffset;
    ray.Pos = 0.0;
    ray.fudge = 1.0 / max(1.0, fpO1);
    ray.iFP = 1.0 / 1.46621;
    return ray;
}

float syntopiaSigmoid(float t)
{
    float k = 1.0 - 1.0 / (1.0 + exp(-0.5 * 1.0 * 5.0));
    t -= 0.5;
    float x = 1.0 / (1.0 + exp(-t * 1.0 * 5.0)) - k;
    return x / (1.0 - 2.0 * k);
}

vec3 syntopiaToneMap(vec3 c)
{
    c = c * 1.0 + vec3(1.0 - 1.0);
    return vec3(
        syntopiaSigmoid(c.r),
        syntopiaSigmoid(c.g),
        syntopiaSigmoid(c.b)
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    gViewCoord = uv * 2.0 - 1.0;
    gCoord = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    gPixelScale = 2.0 / iResolution.xy;
    gCoord *= 0.4;

    gSeed = float(iFrame) * 0.01666;
    vec2 seedUV = rand2(gViewCoord + vec2(gSeed));

    vec2 apertureSample = 0.00619 * nGonDisc(seedUV * 2.1);
    vec2 discSample = uniformDisc(seedUV * 3.7);

    SRay ray = makeCameraRay(fragCoord, apertureSample, discSample);
    vec3 color = renderScene(ray, seedUV);

    color = syntopiaToneMap(color);
    color = pow(max(color, vec3(0.0)), vec3(1.0 / 2.2));

    fragColor = vec4(color, 1.0);
}
