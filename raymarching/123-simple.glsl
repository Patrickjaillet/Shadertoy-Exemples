// ==== Image (image) ====
float WaterIor;
float WaterTurbulence;
float WaterAbsorption;
vec3 WaterColor;

float hash1( float n )
{
    return fract( n*17.0*fract( n*0.3183099 ) );
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    
    float n = p.x + 317.0*p.y + 157.0*p.z;
    
    float a = hash1(n+0.0);
    float b = hash1(n+1.0);
    float c = hash1(n+317.0);
    float d = hash1(n+318.0);
    float e = hash1(n+157.0);
    float f = hash1(n+158.0);
    float g = hash1(n+474.0);
    float h = hash1(n+475.0);

    float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   e - a;
    float k4 =   a - b - c + d;
    float k5 =   a - c - e + g;
    float k6 =   a - b - e + f;
    float k7 = - a + b + c - d + e - f - g + h;

    return -1.0+2.0*(k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z);
}

const mat3 m3 = mat3( 0.00,  0.80,  0.60,
                     -0.80,  0.36, -0.48,
                     -0.60, -0.48,  0.64 );

float fbm( in vec3 x, int iterations )
{
    float f = 2.0;
    float s = 0.5;
    float a = 0.0;
    float b = 0.5;
    for( int i=min(0, iFrame); i<iterations; i++ )
    {
        float n = noise(x);
        a += b*n;
        b *= s;
        x = f*m3*x;
    }
    return a;
}

float fbm_4( in vec3 x )
{
    return fbm(x, 4);
}

float sdPlane( vec3 p )
{
    return p.y;
}

float sdSmoothUnion( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); 
}

float sdSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); 
}

vec3 sdTranslate(vec3 pos, vec3 translate)
{
    return pos - translate;
}

float sdSphere( vec3 p, vec3 origin, float s )
{
    p = sdTranslate(p, origin);
    return length(p)-s;
}

struct Sphere
{
    vec3 origin;
    float radius;
};
    
void GetSphere(int index, out vec3 origin, out float radius)
{
    Sphere spheres[5];
    spheres[0] = Sphere(vec3(38, 0.0, 32), 12.0);
    spheres[1] = Sphere(vec3(33, 0.0 - 2.0, 20), 8.5);
    spheres[2] = Sphere(vec3(-25, 0.0 - 32.0, 55), 40.0);
    spheres[3] = Sphere(vec3(-40, 0.0, 25), 12.0);
    spheres[4] = Sphere(vec3(45, 0.0, 10), 12.0);

    origin = spheres[index].origin;
    radius = spheres[index].radius;
}

float GetWaterWavesDisplacement(vec3 position, float time)
{
    return 7.0 * sin(position.x / 15.0 + time * 1.3) +
           6.0 * cos(position.z / 15.0 + time / 1.1);
}

float GetWaterNoise(vec3 position, float time)
{
    return WaterTurbulence * fbm_4(position / 15.0 + time / 3.0);
}

float QueryOceanDistanceField( in vec3 pos, float time)
{   
    return GetWaterWavesDisplacement(pos, time) + GetWaterNoise(pos, time) + sdPlane(pos - vec3(0, 22.0, 0));
}

float QueryVolumetricDistanceField( in vec3 pos, float time)
{   
    float minDist = QueryOceanDistanceField(pos, time);
    minDist = sdSmoothSubtraction(sdSphere(pos, vec3(0.0, 20.0, 0), 35.0) + 5.0 * fbm_4(pos / vec3(12, 20, 12) - time / 5.0), minDist, 12.0);   
    minDist = sdSmoothUnion(minDist, sdPlane(pos - vec3(0, 0.0 - 1.0, 0)), 13.0);

    return minDist;
}

float IntersectVolumetric(in vec3 rayOrigin, in vec3 rayDirection, float maxT, float time, int sceneType, out bool intersectFound)
{
    float t = 0.0;
    float sdfValue = 0.0;
    float stepSize = 1.5;
    float stepIncrement = (8.0 - 1.5) / 20.0;
    for(int i=0; i<20; i++ )
    {
        sdfValue = (sceneType == 1) ?
            QueryVolumetricDistanceField(rayOrigin+rayDirection*t, time) :
            QueryOceanDistanceField(rayOrigin+rayDirection*t, time);
        stepSize += stepIncrement;
        
        if( sdfValue < 0.0 || t>maxT ) break;
        t += max(sdfValue, stepSize);
    }
    
    if(sdfValue < 0.0)
    {
        float start = 0.0;
        float end = stepSize;
        t -= stepSize;
        
        for(int j = 0; j < 6; j++)
        {
            float midPoint = (start + end) * 0.5;
            vec3 nextMarchPosition = rayOrigin + (t + midPoint) * rayDirection;
            float sdfVal = (sceneType == 1) ?
                QueryVolumetricDistanceField(nextMarchPosition, time) :
                QueryOceanDistanceField(nextMarchPosition, time);
            
            midPoint = clamp(midPoint + sdfVal, start, end);
            if(sdfVal < 0.0)
            {
                end = midPoint;
            }
            else
            {
                start = midPoint;
            }
        }
        t += end;
    }
    
    intersectFound = t<maxT && sdfValue < 0.0;
    return t;
}

vec3 GetVolumeNormal( in vec3 pos, float time, int sceneType )
{
    vec3 n = vec3(0.0);
    for( int i=min(0, iFrame); i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e*
            ((sceneType == 1) ?
                QueryVolumetricDistanceField(pos+0.5*e, time) :
                QueryOceanDistanceField(pos+0.5*e, time));
    }
    return normalize(n);
}

struct CameraDescription
{
    vec3 Position;
    vec3 LookAt;    

    float LensHeight;
    float FocalDistance;
};
    
CameraDescription Camera = CameraDescription(
    vec3(0, 10, -20),
    vec3(0, 10, 0),
    2.0,
    1.6
);

struct Material
{
    vec3 albedo;
    float shininess;
};

Material GetMaterial(int objectID)
{
    if(objectID == 0)
    {
        return Material(0.9 * vec3(1.0, 1.0, 0.8), 50.0);
    }
    else
    {
        return Material(vec3(0.3, 0.4, 0.2), 3.0);
    }
}

float PlaneIntersection(vec3 rayOrigin, vec3 rayDirection, vec3 planeOrigin, vec3 planeNormal) 
{ 
    float t = -1.0;
    float denom = dot(-planeNormal, rayDirection); 
    if (denom > 0.0001) { 
        vec3 rayToPlane = planeOrigin - rayOrigin; 
        return dot(rayToPlane, -planeNormal) / denom; 
    } 
 
    return t; 
} 
    
float SphereIntersection(
    in vec3 rayOrigin, 
    in vec3 rayDirection, 
    in vec3 sphereCenter, 
    in float sphereRadius)
{
    vec3 eMinusC = rayOrigin - sphereCenter;
    float dDotD = dot(rayDirection, rayDirection);

    float discriminant = dot(rayDirection, eMinusC) * dot(rayDirection, eMinusC)
       - dDotD * (dot(eMinusC, eMinusC) - sphereRadius * sphereRadius);

    if (discriminant < 0.0) 
       return -1.0;

    float firstIntersect = (dot(-rayDirection, eMinusC) - sqrt(discriminant)) / dDotD;
    return firstIntersect;
}

void UpdateIfIntersected(
    inout float t,
    in float intersectionT, 
    in int intersectionObjectID,
    out int objectID)
{    
    if(intersectionT > 0.0001 && intersectionT < t)
    {
        objectID = intersectionObjectID;
        t = intersectionT;
    }
}

float SandHeightMap(vec3 position)
{
    float sandGrainNoise = 0.1 * fbm(position * 10.0, 2);
    float sandDuneDisplacement = 0.7 * sin(10.0 * fbm_4(10.0 + position / 40.0));
    return sandGrainNoise + sandDuneDisplacement;
}

float QueryOpaqueDistanceField(vec3 position, int objectID)
{
    if(objectID == 0)
    {
        return sdPlane(position) + SandHeightMap(position);
    }
    else
    {
        vec3 origin;
        float radius;
        GetSphere(objectID - 1, origin, radius);
        return sdSphere(position, origin, radius) + fbm_4(position);
    }
}

vec3 GetOpaqueNormal( in vec3 pos, int objectID )
{
    vec3 n = vec3(0.0);
    for( int i=min(0, iFrame); i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e*QueryOpaqueDistanceField(pos+0.5*e, objectID);
    }
    return normalize(n);
}

float IntersectOpaqueScene(in vec3 rayOrigin, in vec3 rayDirection, out int objectID)
{
    float t = 1e20;
    objectID = -1;

    for(int i = min(0, iFrame); i < 5; i++)
    {
        vec3 origin;
        float radius;
        GetSphere(i, origin, radius);
        UpdateIfIntersected(
            t,
            SphereIntersection(rayOrigin, rayDirection, origin, radius),
            1 + i,
            objectID);
    }
    
    UpdateIfIntersected(
        t,
        PlaneIntersection(rayOrigin, rayDirection, vec3(0, 0.0, 0), vec3(0, 1, 0)),
        0,
        objectID);
    
    UpdateIfIntersected(
        t,
        PlaneIntersection(rayOrigin, rayDirection, vec3(0, 22.0 + 15.0, 0), vec3(0, 1, 0)),
        -1,
        objectID);

    return t;
}

float Specular(in vec3 reflection, in vec3 lightDirection, float shininess)
{
    return 0.05 * pow(max(0.0, dot(reflection, lightDirection)), shininess);
}

vec3 Diffuse(in vec3 normal, in vec3 lightVec, in vec3 diffuse)
{
    float nDotL = dot(normal, lightVec);
    return clamp(nDotL * diffuse, 0.0, 1.0);
}

vec3 BeerLambert(vec3 absorption, float dist)
{
    return exp(-absorption * dist);
}

vec3 GetShadowFactor(in vec3 rayOrigin, in vec3 rayDirection, in int maxSteps, in float minMarchSize)
{
    float t = 0.0;
    vec3 shadowFactor = vec3(1.0);
    float signedDistance = 0.0;
    bool enteredVolume = false;
    for(int i = min(0, iFrame); i < maxSteps; i++)
    {         
        float marchSize = max(minMarchSize, abs(signedDistance));
        t += marchSize;

        vec3 position = rayOrigin + t*rayDirection;

        signedDistance = QueryVolumetricDistanceField(position, iTime);
        if(signedDistance < 0.0)
        {
            float softEdgeMultiplier = min(abs(signedDistance / 5.0), 1.0);
            shadowFactor *= BeerLambert(WaterAbsorption * softEdgeMultiplier / WaterColor, marchSize);
            enteredVolume = true;
        }
        else if(enteredVolume)
        {
            break;
        }
    }
    return shadowFactor;
}

float GetApproximateIntersect(vec3 position, vec3 rayDirection)
{
    float distanceToPlane;
    
    if(abs(rayDirection.y) < 0.01)
    {
        distanceToPlane = 1e20;
    }
    else if(position.y < 0.0 || position.y > 22.0)
    {
        distanceToPlane = 0.0;
    }
    else if(rayDirection.y > 0.0)
    {
        distanceToPlane = (22.0 - position.y) / rayDirection.y;
        distanceToPlane = max(0.0, distanceToPlane);
    }
    else
    {
        distanceToPlane = (position.y - 0.0) / abs(rayDirection.y);
    }
    return distanceToPlane;
}

vec3 GetApproximateShadowFactor(vec3 position, vec3 rayDirection)
{
    float distanceToPlane = GetApproximateIntersect(position, rayDirection);
    return BeerLambert(WaterAbsorption / WaterColor, distanceToPlane);
}

float seed = 0.0;
float rand() { return fract(sin(seed++ + iTime)*43758.5453123); }

float smoothVoronoi( in vec2 x )
{
    ivec2 p = ivec2(floor( x ));
    vec2  f = fract( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        ivec2 b = ivec2( i, j );
        vec2  r = vec2( b ) - f + noise( vec3(vec2(p + b), 0.0) );
        float d = length( r );

        res += exp( -32.0*d );
    }
    return -(1.0/32.0)*log( res );
}

vec3 GetSunLightDirection()
{
    return normalize(vec3(0.3, 1.0, 1.65));
}

vec3 GetSunLightColor()
{
    return 0.9 * vec3(0.9, 0.75, 0.7);
}

vec3 GetBaseSkyColor(vec3 rayDirection)
{
    return mix(
        vec3(0.2, 0.5, 0.8),
        vec3(0.7, 0.75, 0.9),
        max(rayDirection.y, 0.0));
}

vec3 GetAmbientSkyColor()
{
    return 0.1 * GetBaseSkyColor(vec3(0, 1, 0));
}

vec3 GetAmbientShadowColor()
{
    return vec3(0, 0, 0.2);
}

float GetCloudDenity(vec3 position)
{
    float time = iTime * 0.25;
    vec3 noisePosition = position + vec3(0.0, 0.0, time);
    float noiseVal = fbm_4(noisePosition);
    float noiseCutoff = -0.3;
    return max(0.0, 3.0 * (noiseVal - noiseCutoff));
}

vec4 GetCloudColor(vec3 position)
{
    float cloudDensity = GetCloudDenity(position);
    vec3 cloudAlbedo = vec3(1, 1, 1);
    float cloudAbsorption = 0.6;
    float marchSize = 0.25;

    vec3 lightFactor = vec3(1, 1, 1);
    {
        vec3 marchPosition = position;
        int selfShadowSteps = 4;
        for(int i = 0; i < selfShadowSteps; i++)
        {
            marchPosition += GetSunLightDirection() * marchSize;
            float density = cloudAbsorption * GetCloudDenity(marchPosition);
            lightFactor *= BeerLambert(vec3(density), marchSize);
        }
    }

    return vec4(
        cloudAlbedo * 
            (mix(GetAmbientShadowColor(), 1.3 * GetSunLightColor(), lightFactor) +
             GetAmbientSkyColor()), 
        min(cloudDensity, 1.0));
}

vec3 GetSkyColor(in vec3 rayDirection)
{
    vec3 skyColor = GetBaseSkyColor(rayDirection);
    vec4 cloudColor = GetCloudColor(rayDirection * 4.0);
    skyColor = mix(skyColor, cloudColor.rgb, cloudColor.a);

    return skyColor;
}

float FresnelFactor(
    float CurrentIOR,
    float NewIOR,
    vec3 Normal,
    vec3 RayDirection)
{
    float ReflectionCoefficient = 
        ((CurrentIOR - NewIOR) / (CurrentIOR + NewIOR)) *
        ((CurrentIOR - NewIOR) / (CurrentIOR + NewIOR));
    return 
        clamp(ReflectionCoefficient + (1.0 - ReflectionCoefficient) * pow(1.0 - dot(Normal, -RayDirection), 5.0), 0.0, 1.0); 
}

vec3 SandParallaxOcclusionMapping(vec3 position, vec3 view)
{
    int pomCount = 6;
    float marchSize = 0.3;
    for(int i = 0; i < pomCount; i++)
    {
        if(position.y < 0.0 - SandHeightMap(position)) break;
        position += view * marchSize;
    }
    return position;
}

void CalculateLighting(vec3 position, vec3 view, int objectID, inout vec3 color, bool useFastLighting)
{   
    Material material = GetMaterial(objectID);
    float sdfValue = QueryVolumetricDistanceField(position, iTime);
    bool bUnderWater = sdfValue < 0.0;

    float wetnessFactor = 0.0;
    if(objectID == 0 && !useFastLighting)
    {
        float wetSandDistance = 0.7;
        if(sdfValue <= wetSandDistance)
        {
            float fadeEdge = 0.2;
            wetnessFactor = 1.0 - max(0.0, (sdfValue - (wetSandDistance - fadeEdge)) / fadeEdge);
            material.albedo *= material.albedo * mix(1.0, 0.5, wetnessFactor);
        }
        
        position = SandParallaxOcclusionMapping(position, view);
    }

    vec3 normal = GetOpaqueNormal(position, objectID);
    vec3 reflectionDirection = reflect(view, normal);
   
    int shadowObjectID = -1;
    if(!useFastLighting)
    {
        IntersectOpaqueScene(position, GetSunLightDirection(), shadowObjectID);
    }
    
    vec3 shadowFactor = vec3(0.0);
    if(shadowObjectID == -1)
    {
        shadowFactor = useFastLighting ? 
                GetApproximateShadowFactor(position, GetSunLightDirection()) :
                GetShadowFactor(position, GetSunLightDirection(), 10, 7.0);
        
        color += shadowFactor * material.albedo * mix(0.4 * GetAmbientShadowColor(), GetSunLightColor(), max(0.0, dot(normal, GetSunLightDirection())));
        color += shadowFactor * GetSunLightColor() * Specular(reflectionDirection, GetSunLightDirection(), material.shininess);
        
        if(!useFastLighting)
        {
            float waterNoise = fract(GetWaterNoise(position, iTime));
            float causticMultiplier = bUnderWater ? 7.0 : (1.0 - shadowFactor.r);
            color += material.albedo * causticMultiplier * 0.027 * pow(
                smoothVoronoi(position.xz / 4.0 + 
                          vec2(iTime, iTime + 3.0) + 
                          3.0 * vec2(cos(waterNoise), sin(waterNoise))), 5.0);
        }
    }
    
    if(!useFastLighting && wetnessFactor > 0.0)
    {
        vec3 wetNormal = vec3(0, 1, 0);
        vec3 refDir = reflect(view, wetNormal);
        float fresnel = FresnelFactor(1.0, WaterIor, wetNormal, view);
        color += shadowFactor * wetnessFactor * fresnel * GetSkyColor(refDir);
    }
    
    color += GetAmbientSkyColor() * material.albedo;
}

vec3 Render( in vec3 rayOrigin, in vec3 rayDirection)
{
    vec3 accumulatedColor = vec3(0.0);
    vec3 accumulatedColorMultiplier = vec3(1.0);
    
    int materialID = -1;
    float t = IntersectOpaqueScene(rayOrigin, rayDirection, materialID);
    vec3 opaquePosition = rayOrigin + t*rayDirection;
    
    bool outsideVolume = true;
    for(int entry = 0; entry < 1; entry++) 
    { 
        if(!outsideVolume) break;
        
        bool firstEntry = (entry == 0);
        bool intersectFound = false;
        float volumeStart = 
            IntersectVolumetric(
                rayOrigin,
                rayDirection, 
                t, 
                iTime,
                (firstEntry ? 1 : 2),
                intersectFound);
        
        if(!intersectFound) break;
        else
        {
            outsideVolume = false;
            rayOrigin = rayOrigin + rayDirection * volumeStart;
            vec3 volumeNormal = GetVolumeNormal(rayOrigin, iTime, 1);
            vec3 reflection = reflect( rayDirection, volumeNormal);
            float fresnelFactor = FresnelFactor(1.0, WaterIor, volumeNormal, rayDirection);
            float waterShininess = 100.0;

            float whiteWaterFactor = 0.0;
            float whiteWaterMaxHeight = 5.0;
            float groundBlendFactor = min(1.0, (rayOrigin.y - 0.0) * 0.75);
            if(firstEntry && rayOrigin.y <= whiteWaterMaxHeight)
            {
                WaterIor = mix(1.0, WaterIor, groundBlendFactor);
                
                vec3 voronoisePosition = rayOrigin / 1.5 + vec3(0, -iTime * 2.0, sin(iTime));
                float noiseValue = abs(fbm(voronoisePosition, 2));
                voronoisePosition += 1.0 * vec3(cos(noiseValue), 0.0, sin(noiseValue));
                
                float heightLerp = (whiteWaterMaxHeight - rayOrigin.y) / whiteWaterMaxHeight;
                whiteWaterFactor = abs(smoothVoronoi(voronoisePosition.xz)) * heightLerp;
                whiteWaterFactor = clamp(whiteWaterFactor, 0.0, 1.0);
                whiteWaterFactor = pow(whiteWaterFactor, 0.2) * heightLerp;
                whiteWaterFactor *= mix(abs(fbm(rayOrigin + vec3(0, -iTime * 5.0, 0), 2)), 1.0, heightLerp);
                whiteWaterFactor *= groundBlendFactor;
                
                vec3 shadowFactor = GetShadowFactor(rayOrigin, GetSunLightDirection(), 10, 7.0);
                vec3 diffuse = 0.5 * shadowFactor * GetSunLightColor() + 
                    0.7 * shadowFactor * mix(GetAmbientShadowColor(), GetSunLightColor(), max(0.0, dot(volumeNormal, GetSunLightDirection())));
                accumulatedColor += vec3(whiteWaterFactor) * (
                    diffuse +
                    shadowFactor * Specular(reflection, GetSunLightDirection(), 30.0) * GetSunLightColor() +
                    GetAmbientSkyColor());
            }
            accumulatedColorMultiplier *= (1.0 - whiteWaterFactor);
            rayDirection = refract(rayDirection, volumeNormal, 1.0 / WaterIor);
            
            accumulatedColor += accumulatedColorMultiplier * Specular(reflection, GetSunLightDirection(), waterShininess) * GetSunLightColor();
            accumulatedColor += accumulatedColorMultiplier * fresnelFactor * GetSkyColor(reflection);
            accumulatedColorMultiplier *= (1.0 - fresnelFactor);
            
            t = IntersectOpaqueScene(rayOrigin, rayDirection, materialID);
            if( materialID != -1 )
            {
                opaquePosition = rayOrigin + t*rayDirection;
            }

            float volumeDepth = 0.0;
            float signedDistance = 0.0;
            int i = 0;
            vec3 marchPosition = vec3(0);
            float minStepSize = 1.5;
            float minStepIncrement = (8.0 - 1.5) / 20.0;
            for(; i < 20; i++)
            {
                float marchSize = max(minStepSize, signedDistance);
                minStepSize += minStepIncrement;
                
                vec3 nextMarchPosition = rayOrigin + (volumeDepth + marchSize) * rayDirection;
                signedDistance = QueryOceanDistanceField(nextMarchPosition, iTime);
                if(signedDistance > 0.0)
                {
                    float start = 0.0;
                    float end = marchSize;

                    for(int j = 0; j < 6; j++)
                    {
                        float midPoint = (start + end) * 0.5;
                        vec3 nextPos = rayOrigin + (volumeDepth + midPoint) * rayDirection;
                        float sdfValue = QueryVolumetricDistanceField(nextPos, iTime);

                        midPoint = clamp(midPoint - sdfValue, start, end);
                        if(sdfValue > 0.0)
                        {
                            end = midPoint;
                        }
                        else
                        {
                            start = midPoint;
                        }
                    }
                    marchSize = end;
                }

                volumeDepth += marchSize;
                marchPosition = rayOrigin + volumeDepth*rayDirection;

                if(volumeDepth > t)
                {
                    intersectFound = true;
                    volumeDepth = min(volumeDepth, t);
                    break;
                }

                vec3 previousLightFactor = accumulatedColorMultiplier;
                accumulatedColorMultiplier *= BeerLambert(vec3(WaterAbsorption) / WaterColor, marchSize);
                vec3 absorptionFromMarch = previousLightFactor - accumulatedColorMultiplier;

                accumulatedColor += accumulatedColorMultiplier * WaterColor * absorptionFromMarch * 
                    GetSunLightColor() * GetApproximateShadowFactor(marchPosition, GetSunLightDirection());
                accumulatedColor += accumulatedColorMultiplier * absorptionFromMarch * GetAmbientSkyColor();

                if(signedDistance > 0.0)
                {
                    intersectFound = true;
                    outsideVolume = true;
                    break;
                }
            }

            if(intersectFound && outsideVolume)
            {
                vec3 exitNormal = -GetVolumeNormal(marchPosition, iTime, 2);                    

                float fresnelFactorSec = max(0.2, FresnelFactor(WaterIor, 1.0, exitNormal, rayDirection));
                vec3 reflectionSec = reflect(rayDirection, exitNormal);
                int reflectedMaterialID;
                float reflectionT = IntersectOpaqueScene(marchPosition, reflectionSec, reflectedMaterialID);
                if( reflectedMaterialID != -1 )
                {
                    vec3 pos = marchPosition + reflectionSec*reflectionT;
                    vec3 col = vec3(0);
                    CalculateLighting(pos, reflectionSec, reflectedMaterialID, col, true);
                    accumulatedColor += accumulatedColorMultiplier * fresnelFactorSec * col;
                }
                else
                {
                    accumulatedColor += fresnelFactorSec * accumulatedColorMultiplier * GetSkyColor(rayDirection);
                }
                accumulatedColorMultiplier *= (1.0 - fresnelFactorSec);
                
                rayDirection = refract(rayDirection, exitNormal, WaterIor / 1.0);
                rayOrigin = marchPosition;
                t = IntersectOpaqueScene(marchPosition, rayDirection, materialID);
                if( materialID != -1 )
                {
                    opaquePosition = rayOrigin + t*rayDirection;
                }
                outsideVolume = true;
            }

            if(!intersectFound)
            {
                float approxT = GetApproximateIntersect(marchPosition, rayDirection);
                float halfT = approxT / 2.0;
                vec3 halfwayPosition = marchPosition + rayDirection * halfT;
                vec3 shadowFactor = GetApproximateShadowFactor(halfwayPosition, GetSunLightDirection());

                vec3 previousLightFactor = accumulatedColorMultiplier;
                accumulatedColorMultiplier *= BeerLambert(WaterAbsorption / WaterColor, approxT);
                vec3 absorptionFromMarch = previousLightFactor - accumulatedColorMultiplier;
                accumulatedColor += accumulatedColorMultiplier * WaterColor * shadowFactor * absorptionFromMarch * GetSunLightColor();
                accumulatedColor += accumulatedColorMultiplier * WaterColor * GetAmbientSkyColor() * absorptionFromMarch;

                volumeDepth += approxT;
                rayOrigin = rayOrigin + volumeDepth*rayDirection;
            }
        }
    }
    
    vec3 opaqueColor = vec3(0.0);
    if(materialID != -1)
    {
        CalculateLighting(opaquePosition,
                          rayDirection,
                          materialID, opaqueColor,
                          false);
    }
    else
    {
        opaqueColor = GetSkyColor(rayDirection);
    }
    
    return accumulatedColor + accumulatedColorMultiplier * opaqueColor;
}

mat3 GetViewMatrix(float xRotationFactor)
{ 
   float xRotation = ((1.0 - xRotationFactor) - 0.5) * 3.14159265359 * 0.2;
   return mat3( cos(xRotation), 0.0, sin(xRotation),
                0.0,           1.0, 0.0,    
                -sin(xRotation),0.0, cos(xRotation));
}

float GetRotationFactor()
{
    return sin(iTime * 0.2) * 0.5 + 0.5;
}

void LoadConstants()
{
    WaterColor = vec3(0.1, 0.82, 1.0);
    WaterIor = 1.33;
    WaterTurbulence = 2.5;
    WaterAbsorption = 0.028;
}
     
vec3 GammaCorrect(vec3 color) 
{
    return pow(color, vec3(1.0/2.2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    LoadConstants();
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float aspectRatio = iResolution.x / iResolution.y; 
    float lensWidth = Camera.LensHeight * aspectRatio;
    
    vec3 NonNormalizedCameraView = Camera.LookAt - Camera.Position;
    float ViewLength = length(NonNormalizedCameraView);
    vec3 CameraView = NonNormalizedCameraView / ViewLength;

    vec3 lensPoint = Camera.Position;
    
    float rotationFactor = GetRotationFactor();
    mat3 viewMatrix = GetViewMatrix(rotationFactor);
    CameraView = CameraView * viewMatrix;
    lensPoint = Camera.LookAt - CameraView * ViewLength;
    
    vec3 CameraRight = cross(CameraView, vec3(0, 1, 0));    
    vec3 CameraUp = cross(CameraRight, CameraView);

    vec3 focalPoint = lensPoint - Camera.FocalDistance * CameraView;
    lensPoint += CameraRight * (uv.x * 2.0 - 1.0) * lensWidth / 2.0;
    lensPoint += CameraUp * (uv.y * 2.0 - 1.0) * Camera.LensHeight / 2.0;
    
    vec3 rayOrigin = focalPoint;
    vec3 rayDirection = normalize(lensPoint - focalPoint);
    
    vec3 color = Render(rayOrigin, rayDirection);
    fragColor = vec4(GammaCorrect(color), 1.0);
}
