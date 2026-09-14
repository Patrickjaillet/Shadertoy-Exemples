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
ù - https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£*/
const int CLOUDS_NUMBER = 4;
const vec3 DAY_COLOR = vec3(0.294, 0.729, 0.980);
const vec3 NIGHT_COLOR = vec3(0.086, 0.184, 0.339);
const vec3 CLOUD_COLOR = vec3(0.769, 0.886, 0.961);
const vec3 SUN_COLOR = vec3(0.941, 0.906, 0.435);
const vec3 MOON_COLOR = vec3(1.000, 1.000, 0.835);
const vec3 STAR_COLOR = vec3(1.000, 0.980, 0.820);
const float DAY_INTERVAL = 5.0;
// https://patrickjaillet.github.io/sandefjord-software/
const int PARALLAX_LAYERS = 2;
const vec3 SEA_COLOR_TOP_DAY = vec3(0.20, 0.68, 0.88);
const vec3 SEA_COLOR_BOT_DAY = vec3(0.03, 0.15, 0.38);
const vec3 SEA_COLOR_TOP_NIGHT = vec3(0.05, 0.14, 0.28);
const vec3 SEA_COLOR_BOT_NIGHT = vec3(0.01, 0.03, 0.10);
const vec3 TILE_BORDER_COLOR = vec3(0.85, 0.95, 1.00);

const vec3 MOUNTAIN_FAR_DAY = vec3(0.42, 0.52, 0.72);
const vec3 MOUNTAIN_NEAR_DAY = vec3(0.28, 0.38, 0.58);
const vec3 MOUNTAIN_FAR_NIGHT = vec3(0.12, 0.16, 0.28);
const vec3 MOUNTAIN_NEAR_NIGHT = vec3(0.08, 0.10, 0.20);

float inverseLerp(in float value, in float from, in float to)
{
    return (value - from) / (to - from);
}

float remap(in float value, in float from1, in float to1, in float from2, in float to2)
{
    float t = inverseLerp(value, from1, to1);
    return mix(from2, to2, t);
}

float hash(in vec2 seed)
{
    return fract(sin(dot(seed, vec2(103.14245, 31.5324))) * 14113.4631);
}

float sdfUnion(in float a, in float b)
{
    return min(a, b);
}

float opSubtraction(float a, float b)
{
    return max(-a, b);
}

float sdfCircle(in vec2 uv, in float r)
{
    return length(uv) - r;
}

float sdfCloud(in vec2 uv)
{
    float circle1 = sdfCircle(uv + vec2(75.0, 25.0), 75.0);
    float circle2 = sdfCircle(uv, 100.0);
    float circle3 = sdfCircle(uv + vec2(-85.0, 50.0), 50.0);
    
    return sdfUnion(circle1, sdfUnion(circle2, circle3));
}

float sdfSun(in vec2 uv)
{
    float circle = sdfCircle(uv, 150.0);
    return circle;
}

float sdfMoon(in vec2 uv)
{
    float circle1 = sdfCircle(uv, 150.0);
    float circle2 = sdfCircle(uv + vec2(50.0, -50.0), 150.0);
    return opSubtraction(circle2, circle1);
}

float sdfStar(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.80901699437, -0.58778525229);
    const vec2 k2 = vec2(-0.80901699437, 0.58778525229);
    p.x = abs(p.x);
    p -= 2.0 * max(dot(k1, p), 0.0) * k1;
    p -= 2.0 * max(dot(k2, p), 0.0) * k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.0, 1.0);
    float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
    float d = length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
    return max(d, length(p + vec2(0.0, r)) - r * 1.2);
}

vec2 cycledUv(in vec2 uv)
{
    return mod(uv, vec2(1280.0, 720.0)) - vec2(1280.0, 720.0) * 0.5;
}

vec2 simpleUv(in vec2 uv)
{
    return uv - vec2(1280.0, 720.0) * 0.5;
}

float easeInOutQuart(in float x) {
    return x < 0.5 ? 8.0 * x * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 4.0) / 2.0;
}

float easeOutBounce(in float x) {
    const float n1 = 7.5625;
    const float d1 = 2.75;

    if (x < 1.0 / d1) {
        return n1 * x * x;
    } else if (x < 2.0 / d1) {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
}

float sdfSquare(in vec2 p, in float size)
{
    vec2 d = abs(p) - vec2(size);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdfBox(in vec2 p, in vec2 b)
{
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdfTrapezoid(in vec2 p, in float r1, in float r2, in float he)
{
    vec2 k1 = vec2(r2, he);
    vec2 k2 = vec2(r2 - r1, 2.0 * he);
    p.x = abs(p.x);
    vec2 ca = vec2(p.x - min(p.x, (p.y < 0.0) ? r1 : r2), abs(p.y) - he);
    vec2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / dot(k2, k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot(ca, ca), dot(cb, cb)));
}

float sdfTriangle(in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2)
{
    vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
    vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
                     vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
                 vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
    return -sqrt(d.x) * sign(d.y);
}

float sdfCapsule(in vec2 p, in vec2 a, in vec2 b, in float r)
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

float sdfBird(in vec2 p, in float flap)
{
    p.x = abs(p.x);
    vec2 w1 = vec2(0.0, 0.0);
    vec2 w2 = vec2(4.0, 2.0 + flap * 3.0);
    vec2 w3 = vec2(7.0, flap * 1.5);
    
    vec2 d1 = p - w1 - (w2 - w1) * clamp(dot(p - w1, w2 - w1) / dot(w2 - w1, w2 - w1), 0.0, 1.0);
    vec2 d2 = p - w2 - (w3 - w2) * clamp(dot(p - w3, w3 - w2) / dot(w3 - w2, w3 - w2), 0.0, 1.0);
    
    return min(length(d1), length(d2)) - 0.75;
}

float mountainProfile(in float x, in float seed)
{
    float p1 = sin(x * 0.0035 + seed) * 120.0;
    float p2 = sin(x * 0.008 + seed * 2.3) * 60.0;
    float p3 = abs(sin(x * 0.015 + seed * 4.1)) * -40.0;
    float p4 = sin(x * 0.03 + seed * 1.7) * 15.0;
    return p1 + p2 + p3 + p4;
}

vec3 renderStars(in vec2 uv, in vec3 color, in float intensity)
{
    if (intensity <= 0.001) return color;

    vec2 starUv = uv;
    starUv.x += iTime * 3.0;

    float gridSize = 90.0;
    vec2 gridId = floor(starUv / gridSize);
    vec2 localUv = mod(starUv, gridSize) - gridSize * 0.5;

    float h1 = hash(gridId);
    float h2 = hash(gridId + vec2(11.3, 37.1));
    float h3 = hash(gridId + vec2(73.7, 19.5));

    if (h1 < 0.35) return color;

    vec2 offset = vec2(h1 - 0.5, h2 - 0.5) * gridSize * 0.7;
    localUv -= offset;

    float radius = mix(5.0, 12.0, h3);
    float innerRatio = mix(0.35, 0.45, h2);
    
    float sparkle = sin(iTime * (2.5 + h1 * 4.0) + h2 * 6.283185) * 0.5 + 0.5;
    sparkle = pow(sparkle, 3.0);

    float starDist = sdfStar(localUv, radius, innerRatio);
    float starAlpha = (1.0 - smoothstep(-0.8, 0.8, starDist)) * intensity * mix(0.4, 1.0, sparkle);

    return mix(color, STAR_COLOR, clamp(starAlpha, 0.0, 1.0));
}

vec3 renderMountains(in vec2 uv, in vec3 color, in float dayFactor)
{
    float horizon = 240.0;
    
    vec3 farColor = mix(MOUNTAIN_FAR_NIGHT, MOUNTAIN_FAR_DAY, dayFactor);
    float farX = uv.x + iTime * 8.0;
    float farHeight = horizon + 70.0 + mountainProfile(farX, 12.34);
    
    if (uv.y < farHeight)
    {
        color = farColor;
        if (uv.y > farHeight - 45.0 + sin(farX * 0.05) * 8.0)
        {
            color = mix(color, vec3(0.92, 0.95, 0.98), 0.85);
        }
    }
    
    vec3 nearColor = mix(MOUNTAIN_NEAR_NIGHT, MOUNTAIN_NEAR_DAY, dayFactor);
    float nearX = uv.x + iTime * 20.0;
    float nearHeight = horizon + 30.0 + mountainProfile(nearX, 87.65);
    
    if (uv.y < nearHeight)
    {
        color = nearColor;
        if (uv.y > nearHeight - 35.0 + sin(nearX * 0.08) * 6.0)
        {
            color = mix(color, vec3(0.88, 0.92, 0.96), 0.75);
        }
    }
    
    return color;
}

vec3 renderClouds(in vec2 uv, in vec3 color)
{
    for (int i = 0; i < CLOUDS_NUMBER; ++i)
    {
        float hashValue1 = hash(vec2(i, 0.0));
        float hashValue2 = hash(vec2(0.0, i));
        
        float speed = remap(hashValue1, 0.0, 1.0, 100.0, 300.0) * iTime;
        float xOffset = remap(hashValue1, 0.0, 1.0, 100.0, 1000.0) + speed;
        float yOffset = remap(hashValue2, 0.0, 1.0, 50.0, 300.0);
    
        vec2 cloudUv = cycledUv(uv - vec2(xOffset, yOffset));
        vec2 shadowUv = cycledUv(uv - vec2(xOffset, yOffset) - vec2(-10.0, -20.0));
        float cloud = sdfCloud(cloudUv);
        float cloudShadow = sdfCloud(shadowUv);
        color = mix(color, vec3(0.3), smoothstep(0.0, -50.0, cloudShadow) * 0.25);
        color = mix(color, CLOUD_COLOR, smoothstep(0.0, -1.0, cloud) * 0.85);
    }
    
    return color;
}

vec3 renderSinglePlane(in vec2 planeUv, in vec3 color, in vec3 planeColor, in vec3 wingColor)
{
    float body = sdfCapsule(planeUv, vec2(-20.0, 0.0), vec2(20.0, 0.0), 7.0);
    float nose = sdfCircle(planeUv - vec2(20.0, 0.0), 6.5);
    float tail = sdfTriangle(planeUv, vec2(-20.0, 0.0), vec2(-28.0, 0.0), vec2(-24.0, 12.0));
    float mainWing = sdfTrapezoid(planeUv - vec2(2.0, -2.0), 5.0, 18.0, 4.0);
    float windshield = sdfCircle(planeUv - vec2(14.0, 3.0), 4.0);
    
    float propAngle = iTime * 45.0;
    mat2 propRot = mat2(cos(propAngle), -sin(propAngle), sin(propAngle), cos(propAngle));
    vec2 propUv = propRot * (planeUv - vec2(26.0, 0.0));
    float prop = sdfBox(propUv, vec2(1.5, 10.0));
    
    float shadow = sdfCapsule(planeUv + vec2(-4.0, 6.0), vec2(-20.0, 0.0), vec2(20.0, 0.0), 7.0);
    color = mix(color, vec3(0.01, 0.02, 0.05), (1.0 - smoothstep(0.0, 8.0, shadow)) * 0.35);
    
    color = mix(color, planeColor, 1.0 - smoothstep(-0.5, 0.5, body));
    color = mix(color, planeColor, 1.0 - smoothstep(-0.5, 0.5, nose));
    color = mix(color, wingColor, 1.0 - smoothstep(-0.5, 0.5, tail));
    color = mix(color, wingColor, 1.0 - smoothstep(-0.5, 0.5, mainWing));
    color = mix(color, vec3(0.85, 0.95, 1.0), 1.0 - smoothstep(-0.5, 0.5, windshield));
    color = mix(color, vec3(0.2, 0.2, 0.25), 1.0 - smoothstep(-0.5, 0.5, prop));
    
    return color;
}

vec3 renderPlanes(in vec2 uv, in vec3 color)
{
    vec3[4] bodyColors = vec3[4](
        vec3(0.92, 0.25, 0.20),
        vec3(0.95, 0.75, 0.15),
        vec3(0.20, 0.60, 0.90),
        vec3(0.88, 0.88, 0.92)
    );
    
    vec3[4] wingColors = vec3[4](
        vec3(0.95, 0.95, 0.95),
        vec3(0.85, 0.20, 0.20),
        vec3(0.95, 0.95, 0.20),
        vec3(0.20, 0.75, 0.35)
    );
    
    for (int i = 0; i < 4; ++i)
    {
        float fi = float(i);
        float h1 = hash(vec2(fi * 18.19, 91.23));
        float h2 = hash(vec2(fi * 43.11, 27.84));
        float h3 = hash(vec2(fi * 67.45, 53.12));
        float h4 = hash(vec2(fi * 12.89, 84.61));
        
        float scale = mix(0.35, 1.1, h1);
        float speed = mix(180.0, 420.0, scale);
        float cycleLength = 2400.0;
        
        float currentProgress = iTime * speed + h2 * cycleLength;
        float cycleId = floor(currentProgress / cycleLength);
        float passProgress = mod(currentProgress, cycleLength);
        
        float loopSeed = hash(vec2(fi * 3.14, cycleId * 7.89));
        bool doesLoop = (loopSeed > 0.4);
        
        float basePosX = passProgress - 400.0;
        float basePosY = mix(420.0, 670.0, h3) + sin(iTime * 1.2 + h1 * 6.28) * 15.0;
        
        vec2 planePos = vec2(basePosX, basePosY);
        float planeAngle = 0.0;
        
        if (doesLoop)
        {
            float loopTriggerX = mix(400.0, 1400.0, h4);
            float loopRadius = mix(50.0, 110.0, h1);
            float loopDurationX = loopRadius * 6.283185;
            
            if (basePosX >= loopTriggerX && basePosX < loopTriggerX + loopDurationX)
            {
                float loopT = (basePosX - loopTriggerX) / loopDurationX;
                float angle = loopT * 6.283185;
                
                planePos.x = loopTriggerX + sin(angle) * loopRadius;
                planePos.y = basePosY - (1.0 - cos(angle)) * loopRadius;
                planeAngle = -angle;
            }
            else if (basePosX >= loopTriggerX + loopDurationX)
            {
                planePos.x = basePosX - loopDurationX + loopRadius * 0.0;
            }
        }
        
        vec2 planeUv = uv - planePos;
        mat2 loopRot = mat2(cos(-planeAngle), -sin(-planeAngle), sin(-planeAngle), cos(-planeAngle));
        planeUv = loopRot * planeUv;
        planeUv /= scale;
        
        color = renderSinglePlane(planeUv, color, bodyColors[i], wingColors[i]);
    }
    
    return color;
}

vec3 renderBirds(in vec2 uv, in vec3 color)
{
    vec3 birdColor = vec3(0.08, 0.10, 0.15);
    
    for (int i = 0; i < 6; ++i)
    {
        float fi = float(i);
        float h1 = hash(vec2(fi * 12.3, 45.6));
        float h2 = hash(vec2(fi * 78.9, 12.3));
        float h3 = hash(vec2(fi * 34.1, 89.2));
        
        float speed = mix(120.0, 220.0, h1);
        float cycleLength = 1600.0;
        
        float xPos = mod(iTime * speed + h2 * cycleLength, cycleLength) - 200.0;
        float yPos = mix(380.0, 680.0, h3) + sin(iTime * 1.5 + h1 * 6.28) * 20.0;
        
        vec2 birdUv = uv - vec2(xPos, yPos);
        
        float scale = mix(0.7, 1.3, h2);
        birdUv /= scale;
        
        float flap = sin(iTime * (12.0 + h1 * 6.0) + h2 * 6.28);
        
        float birdSdf = sdfBird(birdUv, flap);
        
        color = mix(color, birdColor, 1.0 - smoothstep(-0.5, 0.5, birdSdf));
    }
    
    return color;
}

vec3 renderSteamBoat(in vec2 uv, in vec3 color)
{
    vec2 boatPos = uv - vec2(640.0, 180.0);
    
    float waveBob = sin(iTime * 3.0) * 18.0;
    float waveTilt = sin(iTime * 2.0) * 0.12;
    
    boatPos.y -= waveBob;
    
    mat2 rot = mat2(cos(waveTilt), -sin(waveTilt), sin(waveTilt), cos(waveTilt));
    boatPos = rot * boatPos;
    
    float hull = sdfTrapezoid(boatPos - vec2(0.0, -10.0), 90.0, 50.0, 30.0);
    float cabin = sdfBox(boatPos - vec2(-10.0, 45.0), vec2(35.0, 25.0));
    float chimney = sdfBox(boatPos - vec2(15.0, 80.0), vec2(8.0, 15.0));
    float porthole1 = sdfCircle(boatPos - vec2(-25.0, 45.0), 7.0);
    float porthole2 = sdfCircle(boatPos - vec2(5.0, 45.0), 7.0);
    
    float smokeTime = mod(iTime * 1.5, 1.0);
    vec2 smokeUv = boatPos - vec2(15.0 + smokeTime * 30.0, 100.0 + smokeTime * 60.0);
    float smoke = sdfCircle(smokeUv, 6.0 + smokeTime * 16.0);
    
    float boatShadow = sdfTrapezoid(boatPos + vec2(-15.0, 5.0), 90.0, 50.0, 30.0);
    
    color = mix(color, vec3(0.01, 0.02, 0.05), (1.0 - smoothstep(0.0, 15.0, boatShadow)) * 0.5);
    color = mix(color, vec3(0.85, 0.18, 0.18), 1.0 - smoothstep(-0.5, 0.5, hull));
    color = mix(color, vec3(0.95, 0.95, 0.90), 1.0 - smoothstep(-0.5, 0.5, cabin));
    color = mix(color, vec3(0.20, 0.20, 0.25), 1.0 - smoothstep(-0.5, 0.5, chimney));
    color = mix(color, vec3(0.95, 0.80, 0.15), 1.0 - smoothstep(-0.5, 0.5, porthole1));
    color = mix(color, vec3(0.95, 0.80, 0.15), 1.0 - smoothstep(-0.5, 0.5, porthole2));
    color = mix(color, CLOUD_COLOR, (1.0 - smoothstep(0.0, 3.0, smoke)) * (1.0 - smokeTime));
    
    return color;
}

vec3 renderSailBoat(in vec2 uv, in vec3 color)
{
    vec2 boatPos = uv - vec2(220.0, 100.0);
    
    float waveBob = sin(iTime * 2.5 + 1.2) * 10.0;
    float waveTilt = sin(iTime * 1.8 + 0.5) * 0.15;
    
    boatPos.y -= waveBob;
    
    mat2 rot = mat2(cos(waveTilt), -sin(waveTilt), sin(waveTilt), cos(waveTilt));
    boatPos = rot * boatPos;
    
    float hull = sdfTrapezoid(boatPos - vec2(0.0, -5.0), 40.0, 20.0, 15.0);
    float mast = sdfBox(boatPos - vec2(0.0, 35.0), vec2(2.0, 25.0));
    float mainSail = sdfTriangle(boatPos, vec2(3.0, 15.0), vec2(30.0, 20.0), vec2(3.0, 58.0));
    float frontSail = sdfTriangle(boatPos, vec2(-3.0, 18.0), vec2(-22.0, 20.0), vec2(-3.0, 52.0));
    
    float boatShadow = sdfTrapezoid(boatPos + vec2(-8.0, 4.0), 40.0, 20.0, 15.0);
    
    color = mix(color, vec3(0.01, 0.02, 0.05), (1.0 - smoothstep(0.0, 10.0, boatShadow)) * 0.4);
    color = mix(color, vec3(0.55, 0.35, 0.18), 1.0 - smoothstep(-0.5, 0.5, hull));
    color = mix(color, vec3(0.30, 0.20, 0.10), 1.0 - smoothstep(-0.5, 0.5, mast));
    color = mix(color, vec3(0.95, 0.95, 0.95), 1.0 - smoothstep(-0.5, 0.5, mainSail));
    color = mix(color, vec3(0.85, 0.85, 0.88), 1.0 - smoothstep(-0.5, 0.5, frontSail));
    
    return color;
}

vec3 renderCargoShip(in vec2 uv, in vec3 color)
{
    vec2 boatPos = uv - vec2(1040.0, 220.0);
    
    float waveBob = sin(iTime * 1.5 + 2.5) * 6.0;
    float waveTilt = sin(iTime * 1.0 + 1.8) * 0.04;
    
    boatPos.y -= waveBob;
    
    mat2 rot = mat2(cos(waveTilt), -sin(waveTilt), sin(waveTilt), cos(waveTilt));
    boatPos = rot * boatPos;
    
    float hull = sdfTrapezoid(boatPos - vec2(0.0, -10.0), 120.0, 100.0, 20.0);
    float cabin = sdfBox(boatPos - vec2(-80.0, 30.0), vec2(20.0, 20.0));
    float container1 = sdfBox(boatPos - vec2(-30.0, 20.0), vec2(25.0, 10.0));
    float container2 = sdfBox(boatPos - vec2(25.0, 20.0), vec2(25.0, 10.0));
    
    float boatShadow = sdfTrapezoid(boatPos + vec2(-12.0, 6.0), 120.0, 100.0, 20.0);
    
    color = mix(color, vec3(0.01, 0.02, 0.05), (1.0 - smoothstep(0.0, 12.0, boatShadow)) * 0.4);
    color = mix(color, vec3(0.15, 0.20, 0.28), 1.0 - smoothstep(-0.5, 0.5, hull));
    color = mix(color, vec3(0.90, 0.90, 0.85), 1.0 - smoothstep(-0.5, 0.5, cabin));
    color = mix(color, vec3(0.20, 0.60, 0.30), 1.0 - smoothstep(-0.5, 0.5, container1));
    color = mix(color, vec3(0.80, 0.40, 0.10), 1.0 - smoothstep(-0.5, 0.5, container2));
    
    return color;
}

vec3 renderSquareParallaxSea(in vec2 uv, in vec3 color, in float dayFactor)
{
    vec3 currentSeaTop = mix(SEA_COLOR_TOP_NIGHT, SEA_COLOR_TOP_DAY, dayFactor);
    vec3 currentSeaBot = mix(SEA_COLOR_BOT_NIGHT, SEA_COLOR_BOT_DAY, dayFactor);

    float seaHorizon = 240.0;
    
    for (int i = PARALLAX_LAYERS - 1; i >= 0; --i)
    {
        float fi = float(i);
        float depth = fi / float(PARALLAX_LAYERS - 1);
        
        float tileSize = mix(28.0, 110.0, depth);
        float speed = mix(50.0, 450.0, pow(depth, 1.5));
        float layerY = seaHorizon - depth * 280.0;
        
        vec2 layerUv = uv;
        layerUv.x += iTime * speed;
        layerUv.y -= layerY;
        
        float gridIndex = floor(layerUv.x / tileSize);
        float h1 = hash(vec2(gridIndex, fi * 17.13));
        float h2 = hash(vec2(gridIndex + 31.4, fi * 5.71));
        
        float yBobbing = sin(iTime * (2.0 + h1 * 2.5) + h2 * 6.2831) * (tileSize * 0.25);
        
        vec2 tileCenter = vec2((gridIndex + 0.5) * tileSize, yBobbing);
        vec2 localUv = layerUv - tileCenter;
        
        float tileSdf = sdfSquare(localUv, tileSize * 0.48);
        
        float dropSdf = min(tileSdf, layerUv.y - yBobbing);
        
        vec3 tileColor = mix(currentSeaTop, currentSeaBot, depth);
        
        float shadowOffset = mix(3.0, 14.0, depth);
        vec2 shadowLocalUv = localUv - vec2(-shadowOffset, -shadowOffset * 1.2);
        float shadowSdf = sdfSquare(shadowLocalUv, tileSize * 0.48);
        
        color = mix(color, vec3(0.01, 0.02, 0.05), (1.0 - smoothstep(0.0, 6.0, shadowSdf)) * 0.5);
        
        color = mix(color, tileColor, 1.0 - smoothstep(-0.5, 0.5, dropSdf));
        
        float borderThickness = mix(1.5, 4.0, depth);
        float borderMask = (1.0 - smoothstep(0.0, 0.8, abs(tileSdf))) * smoothstep(-borderThickness, 0.0, tileSdf);
        color = mix(color, TILE_BORDER_COLOR, borderMask * mix(0.5, 0.9, depth));
    }
    
    color = renderCargoShip(uv, color);
    color = renderSailBoat(uv, color);
    color = renderSteamBoat(uv, color);
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;
    uv *= vec2(720.0, 720.0);
    
    vec3 color = DAY_COLOR;
    
    float currentDayTime = mod(iTime, DAY_INTERVAL * 2.0);
    float dayFactor = 0.0;
    
    if (currentDayTime <= DAY_INTERVAL)
    {
        dayFactor = smoothstep(0.0, DAY_INTERVAL, currentDayTime);
        color = mix(NIGHT_COLOR, DAY_COLOR, dayFactor);
        
        float t = remap(currentDayTime, 0.0, DAY_INTERVAL, 0.0, 1.0);
        float t1 = clamp(remap(t, 0.0, 0.1, 0.0, 1.0), 0.0, 1.0);
        float t2 = clamp(remap(t, 0.9, 1.0, 1.0, 0.0), 0.0, 1.0);
        float offsetX = 300.0;
        float offsetY = remap(easeOutBounce(t1) * easeInOutQuart(t2), 0.0, 1.0, -600.0, -150.0);
        float sun = sdfSun(simpleUv(uv + vec2(offsetX, offsetY)));
        float cloudShadow = sdfSun(simpleUv(uv + vec2(offsetX, offsetY) + vec2(10.0, 20.0)));
        color = mix(color, vec3(0.3), smoothstep(0.0, -50.0, cloudShadow));
        color = mix(color, SUN_COLOR, smoothstep(0.0, -1.0, sun));
    }
    else 
    {
        dayFactor = 1.0 - smoothstep(DAY_INTERVAL, DAY_INTERVAL * 2.0, currentDayTime);
        color = mix(DAY_COLOR, NIGHT_COLOR, 1.0 - dayFactor);
    
        float t = remap(currentDayTime, DAY_INTERVAL, DAY_INTERVAL * 2.0, 0.0, 1.0);
        float t1 = clamp(remap(t, 0.0, 0.1, 0.0, 1.0), 0.0, 1.0);
        float t2 = clamp(remap(t, 0.9, 1.0, 1.0, 0.0), 0.0, 1.0);
        float offsetX = -300.0;
        float offsetY = remap(easeOutBounce(t1) * easeInOutQuart(t2), 0.0, 1.0, -600.0, -150.0);
        float moon = sdfMoon(simpleUv(uv + vec2(offsetX, offsetY)));
        float moonShadow = sdfMoon(simpleUv(uv + vec2(offsetX, offsetY) - vec2(-10.0, -20.0)));
        color = mix(color, vec3(0.3), smoothstep(0.0, -50.0, moonShadow));
        color = mix(color, MOON_COLOR, smoothstep(0.0, -1.0, moon));
    }
    
    color = renderStars(uv, color, 1.0 - dayFactor);
    color = renderMountains(uv, color, dayFactor);
    color = renderClouds(uv, color);

    color = renderBirds(uv, color);
    color = renderPlanes(uv, color);

    color = renderSquareParallaxSea(uv, color, dayFactor);

    fragColor = vec4(color, 1.0);
}
