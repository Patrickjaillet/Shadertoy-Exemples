// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software
/* GOLFED VERSION
float d(vec2 a){
    a=fract(a*vec2(123.34,456.21));
    a+=dot(a,a+45.32);
    return fract(a.x*a.y);
}
float Q(vec3 a){
    vec2 b=fract(a.xz*vec2(123.34,456.21)+a.y*33.33);
    b+=dot(b,b+45.32);
    return fract(b.x*b.y);
}
float y(vec2 a){
    vec2 b=floor(a),c=fract(a),e=c*c*(3.-2.*c);
    float f=d(b),h=d(b+vec2(1.,0.)),i=d(b+vec2(0.,1.)),j=d(b+vec2(1.)),k=mix(f,h,e.x),l=mix(i,j,e.x);
    return mix(k,l,e.y);
}
float g(vec2 a){
    float b=0.,c=1.;
    vec2 e=a*.03;
    for(int f=0;f<5;f++){
        b+=c*y(e);
        e*=2.;
        c*=.5;
    }
    float h=y(a*.008);
    return floor(b*16.+h*h*26.);
}
bool R(vec3 a){
    return a.y<g(a.xz);
}
float S(float b){
    float c=floor(b),a=fract(b);
    a=a*a*(3.-2.*a);
    return mix(d(vec2(c,17.1)),d(vec2(c+1.,17.1)),a);
}
float p(vec2 a){
    return (d(a*1.1+11.11)>.9925&&(a.x>8.||abs(a.y)>3.))?g(a):-1e3;
}
float A(vec2 a){
    return (d(a*1.33+77.7)>.982&&p(a)<-5e2&&(a.x>8.||abs(a.y)>3.))?g(a):-1e3;
}
vec2 B(float b){
    float m=b*3.5,n=(S(b*.05)*2.-1.)*12.+sin(b*.1)*5.;
    vec2 c=vec2(m,n),r=floor(c);
    float h=0.;
    for(int i=-3;i<=3;i++)for(int j=-3;j<=3;j++){
        vec2 a=r+vec2(float(i),float(j));
        vec2 s=a+.5,o=c-s;
        float q=length(o);
        float k=smoothstep(3.2,0.,q),l=o.y>=0.?1 me:-1.;
        if(p(a me)>-5e2&&q<3.2)h+=l*k*3.5;
        k=smoothstep(2.5,0.,q);
        if(A(a me)>-5e2&&q<2.5)h+=l*k*2.8;
    }
    return vec2(m,n+h);
}
bool T(vec3 a,out int c){
    vec2 b=floor(a.xz);
    float e=p(b);
    if(e>-5e2){
        int h=int(4.+floor(d(b*1.7+22.22)*3.));
        if(a.y>=e&&a.y<e+float(h)&&floor(a.xz)==b)return c=1,true;
        if(a.y>=e+float(h-2)&&a.y<=e+float(h+2)){
            vec3 i=a-vec3(b.x,e+float(h),b.y);
            if(max(abs(i.x),max(abs(i.y),abs(i.z)))<=2.&&d(floor(a.xz*2.2+33.33)+a.y)>.12)return c=2,true;
        }
    }
    float f=A(b);
    if(f>-5e2&&a.y>=f&&a.y<f+float(1+int(floor(d(b*2.4+55.5)*2.)))&&d(floor(a.xz*1.5+88.8)+a.y)>.05)return c=3,true;
    return false;
}
vec3 U(vec3 a,vec3 h,int c){
    float e=d(a.xz+vec2(a.y*1.7));
    if(c==1)return vec3(.35,.22,.12);
    if(c==2)return vec3(.15,.45,.12);
    if(c==3)return mix(vec3(.42,.43,.46),vec3(.52,.53,.56),e);
    float f=g(a.xz)-1.,b=.85+.3*e;
    return (a.y>f-.5?mix(vec3(.32,.55,.2),vec3(.42,.68,.28),d(a.xz)):a.y>f-4.5?vec3(.42,.3,.18):vec3(.44,.44,.47))*b;
}
float V(int c,vec2 e){
    if(e.x<0.||e.x>5.||e.y<0.||e.y>5.)return 0.;
    ivec2 i=ivec2(floor(e));
    int b=i.x,a=4-i.y;
    uint[8] U0=uint[](14u,14u,17u,30u,14u,30u,31u,31u),
            U1=uint[](17u,17u,25u,17u,17u,17u,16u,4u),
            U2=uint[](14u,31u,21u,17u,16u,30u,30u,4u),
            U3=uint[](1u,17u,19u,17u,17u,20u,16u,4u),
            U4=uint[](30u,17u,17u,30u,14u,17u,16u,4u);
    uint h=a==0?U0[c]:a==1?U1[c]:a==2?U2[c]:a==3?U3[c]:U4[c];
    return float((h>>uint(4-b))&1u);
}
float C(vec2 e){
    e+=vec2(18.,2.5);
    if(e.y<0.||e.y>5.||e.x<0.||e.x>36.)return 0.;
    int a=int(floor(e.x/3.6));
    vec2 b=vec2(mod(e.x,3.6),e.y);
    if(b.x>3.||a>8)return 0.;
    int[9] G=int[](0,1,2,3,4,5,1,6,7);
    return V(G[a],b*(5./3.));
}
void mainImage(out vec4 W,in vec2 X){
    vec2 m=iResolution.xy;
    float b=iTime;
    vec2 j=(X.xy-.5*m)/m.y;
    float D=3.5,E=1.2,q=max(0.,b-D+.5);
    vec2 r=B(q),Y=B(q+.08),F=Y-r;
    vec3 f=vec3(r.x,0.,r.y);
    float G=g(f.xz),H=g(f.xz+normalize(F)*.3),Z=H-G,s=q*11.,_=clamp(sin(s)*1.75,-1.,1.)*.5+.5,aa=mix(G,H,_),ab=abs(sin(s))*.18;
    f.y=aa+2.6+ab;
    vec2 I=normalize(F);
    float ac=-.14-Z*.08-.04*cos(s);
    vec3 t=normalize(vec3(I.x,ac,I.y)),J=normalize(cross(t,vec3(0.,1.,0.))),ad=cross(J,t),a=normalize(t+J*j.x+ad*j.y);
    a+=step(abs(a),vec3(1e-4))*1e-4;
    vec3 h=floor(f),K=sign(a),L=abs(1./a),i=(h+step(0.,a)-f)/a,k=vec3(0.);
    float u=0.;
    int c=0;
    for(int e=0;e<150;e++){
        if(R(h)){
            u=1.;
            break;
        }
        if(T(h,c)){
            u=2.;
            break;
        }
        k=step(i,i.yzx)*step(i,i.zxy);
        i+=k*L;
        h+=k*K;
    }
    vec3 M=normalize(vec3(.5,.75,.35)),v=mix(vec3(.62,.78,.98),vec3(.16,.38,.8),clamp(a.y*1.6+.25,0.,1.));
    v+=vec3(1.,.92,.72)*pow(max(dot(a,M),0.),2e2);
    vec3 n=v;
    if(u>.5){
        float N=dot(k,i-L);
        vec3 w=f+a*N,e=-K*k,O=U(h,e,c);
        vec2 l=abs(e.y)>.5?w.xz:abs(e.x)>.5?w.zy:w.xy;
        vec2 ae=floor(fract(l)*4.);
        float af=d(floor(l)*1.3+ae*.27+vec2(h.y));
        O*=.85+.26*af;
        float o=e.y>.5?1.:e.y<-.5?.35:abs(e.x)>.5?.55:.7;
        float ag=max(dot(e,M),0.);
        vec3 ah=O*(.35+.65*ag)*o;
        float ai=exp(-N*.006);
        n=mix(v,ah,ai);
    }
    n=pow(clamp(n,0.,1.),vec3(.85));
    vec2 P=j*28.;
    float aj=C(P);
    vec3 ak=vec3(.35,.85,.25),al=vec3(.1,.05,.02);
    float am=C(P-vec2(.6,-.6));
    vec3 an=vec3(.08,.12,.18)+.02*Q(vec3(j*12.,b)),x=mix(an,al,am*.7);
    x=mix(x,ak,aj);
    float ao=clamp((b-(D-E))/E,0.,1.);
    vec2 ap=floor(j*vec2(32.,32.*m.y/m.x));
    float aq=d(ap)*.35,ar=clamp((ao-aq)/.65,0.,1.),as=smoothstep(0.,1.,ar);
    vec3 at=mix(x,n,as);
    W=vec4(at,1.);
}
*/

float hash2D(vec2 position) {
    position = fract(position * vec2(123.34, 456.21));
    position += dot(position, position + 45.32);
    return fract(position.x * position.y);
}

float hash3D(vec3 position) {
    vec2 pseudoRandom = fract(position.xz * vec2(123.34, 456.21) + position.y * 33.33);
    pseudoRandom += dot(pseudoRandom, pseudoRandom + 45.32);
    return fract(pseudoRandom.x * pseudoRandom.y);
}

float valueNoise2D(vec2 position) {
    vec2 cellIndex = floor(position);
    vec2 cellFraction = fract(position);
    
    vec2 smoothStepFactor = cellFraction * cellFraction * (3.0 - 2.0 * cellFraction);
    
    float cornerBottomLeft  = hash2D(cellIndex);
    float cornerBottomRight = hash2D(cellIndex + vec2(1.0, 0.0));
    float cornerTopLeft     = hash2D(cellIndex + vec2(0.0, 1.0));
    float cornerTopRight    = hash2D(cellIndex + vec2(1.0, 1.0));
    
    float interpolateBottom = mix(cornerBottomLeft, cornerBottomRight, smoothStepFactor.x);
    float interpolateTop    = mix(cornerTopLeft, cornerTopRight, smoothStepFactor.x);
    
    return mix(interpolateBottom, interpolateTop, smoothStepFactor.y);
}

float rawLandscapeHeight(vec2 worldPosXZ) {
    float octaveSum = 0.0;
    float amplitude = 1.0;
    vec2 sampleFrequency = worldPosXZ * 0.03;
    
    for (int octave = 0; octave < 5; octave++) {
        octaveSum += amplitude * valueNoise2D(sampleFrequency);
        sampleFrequency *= 2.0;
        amplitude *= 0.5;
    }
    
    float macroMacroNoise = valueNoise2D(worldPosXZ * 0.008);
    return octaveSum * 16.0 + macroMacroNoise * macroMacroNoise * 26.0;
}

float landscapeHeight(vec2 worldPosXZ) {
    return floor(rawLandscapeHeight(worldPosXZ));
}

bool isLandscapeVoxel(vec3 voxelPosition) {
    float height = landscapeHeight(voxelPosition.xz);
    return voxelPosition.y < height;
}

float noise1D(float value) {
    float index = floor(value);
    float fraction = fract(value);
    
    fraction = fraction * fraction * (3.0 - 2.0 * fraction);
    
    float sampleStart = hash2D(vec2(index, 17.1));
    float sampleEnd   = hash2D(vec2(index + 1.0, 17.1));
    
    return mix(sampleStart, sampleEnd, fraction);
}

float treeMap(vec2 cellPosition) {
    float spawnNoise = hash2D(cellPosition * 1.1 + 11.11);
    
    if (spawnNoise > 0.9925) {
        float height = landscapeHeight(cellPosition);
        if (cellPosition.x > 8.0 || abs(cellPosition.y) > 3.0) {
            return height;
        }
    }
    return -1000.0;
}

float rockMap(vec2 cellPosition) {
    float spawnNoise = hash2D(cellPosition * 1.33 + 77.7);
    
    if (spawnNoise > 0.982) {
        float height = landscapeHeight(cellPosition);
        if (treeMap(cellPosition) < -500.0 && (cellPosition.x > 8.0 || abs(cellPosition.y) > 3.0)) {
            return height;
        }
    }
    return -1000.0;
}

vec2 computeCameraPath(float time) {
    float forwardMotion = time * 3.5;
    float rawLateralMotion = (noise1D(time * 0.05) * 2.0 - 1.0) * 12.0 + sin(time * 0.1) * 5.0;
    
    vec2 currentPosition = vec2(forwardMotion, rawLateralMotion);
    vec2 currentGridCell = floor(currentPosition);
    
    float obstacleAvoidanceOffset = 0.0;
    
    for (int offsetX = -3; offsetX <= 3; offsetX++) {
        for (int offsetY = -3; offsetY <= 3; offsetY++) {
            vec2 neighbourCell = currentGridCell + vec2(float(offsetX), float(offsetY));
            
            float treeBaseHeight = treeMap(neighbourCell);
            if (treeBaseHeight > -500.0) {
                vec2 treeCenterPosition = neighbourCell + 0.5;
                vec2 vectorToTree = currentPosition - treeCenterPosition;
                float distanceToTree = length(vectorToTree);
                
                if (distanceToTree < 3.2) {
                    float avoidanceForce = smoothstep(3.2, 0.0, distanceToTree);
                    float sideSign = (vectorToTree.y >= 0.0 ? 1.0 : -1.0);
                    obstacleAvoidanceOffset += sideSign * avoidanceForce * 3.5;
                }
            }
            
            float rockBaseHeight = rockMap(neighbourCell);
            if (rockBaseHeight > -500.0) {
                vec2 rockCenterPosition = neighbourCell + 0.5;
                vec2 vectorToRock = currentPosition - rockCenterPosition;
                float distanceToRock = length(vectorToRock);
                
                if (distanceToRock < 2.5) {
                    float avoidanceForce = smoothstep(2.5, 0.0, distanceToRock);
                    float sideSign = (vectorToRock.y >= 0.0 ? 1.0 : -1.0);
                    obstacleAvoidanceOffset += sideSign * avoidanceForce * 2.8;
                }
            }
        }
    }
    
    return vec2(forwardMotion, rawLateralMotion + obstacleAvoidanceOffset);
}

bool isObjectVoxel(vec3 voxelPosition, out int objectType) {
    vec2 cellIndex = floor(voxelPosition.xz);
    
    float treeBaseHeight = treeMap(cellIndex);
    if (treeBaseHeight > -500.0) {
        int trunkHeight = int(4.0 + floor(hash2D(cellIndex * 1.7 + 22.22) * 3.0));
        
        if (voxelPosition.y >= treeBaseHeight && voxelPosition.y < treeBaseHeight + float(trunkHeight)) {
            if (floor(voxelPosition.xz) == cellIndex) {
                objectType = 1;
                return true;
            }
        }
        
        if (voxelPosition.y >= treeBaseHeight + float(trunkHeight - 2) && 
            voxelPosition.y <= treeBaseHeight + float(trunkHeight + 2)) {
            
            vec3 relativeLeavesPosition = voxelPosition - vec3(cellIndex.x, treeBaseHeight + float(trunkHeight), cellIndex.y);
            
            if (max(abs(relativeLeavesPosition.x), max(abs(relativeLeavesPosition.y), abs(relativeLeavesPosition.z))) <= 2.0) {
                if (hash2D(floor(voxelPosition.xz * 2.2 + 33.33) + voxelPosition.y) > 0.12) {
                    objectType = 2;
                    return true;
                }
            }
        }
    }
    
    float rockBaseHeight = rockMap(cellIndex);
    if (rockBaseHeight > -500.0) {
        int rockHeight = 1 + int(floor(hash2D(cellIndex * 2.4 + 55.5) * 2.0));
        
        if (voxelPosition.y >= rockBaseHeight && voxelPosition.y < rockBaseHeight + float(rockHeight)) {
            float rockNoise = hash2D(floor(voxelPosition.xz * 1.5 + 88.8) + voxelPosition.y);
            if (rockNoise > 0.05) {
                objectType = 3;
                return true;
            }
        }
    }
    
    return false;
}

vec3 getVoxelAlbedo(vec3 voxelPosition, vec3 normal, int objectType) {
    float surfaceNoise = hash2D(voxelPosition.xz + vec2(voxelPosition.y * 1.7));
    
    if (objectType == 1) return vec3(0.35, 0.22, 0.12);
    if (objectType == 2) return vec3(0.15, 0.45, 0.12);
    if (objectType == 3) return mix(vec3(0.42, 0.43, 0.46), vec3(0.52, 0.53, 0.56), surfaceNoise);
    
    float topTerrainHeight = landscapeHeight(voxelPosition.xz) - 1.0;
    float noiseVariation = 0.85 + 0.3 * surfaceNoise;
    
    if (voxelPosition.y > topTerrainHeight - 0.5) {
        return mix(vec3(0.32, 0.55, 0.20), vec3(0.42, 0.68, 0.28), hash2D(voxelPosition.xz)) * noiseVariation;
    }
    
    if (voxelPosition.y > topTerrainHeight - 4.5) {
        return vec3(0.42, 0.30, 0.18) * noiseVariation;
    }
    
    return vec3(0.44, 0.44, 0.47) * noiseVariation;
}

float drawChar5x5(int id, vec2 p) {
    if (p.x < 0.0 || p.x > 5.0 || p.y < 0.0 || p.y > 5.0) return 0.0;
    ivec2 ip = ivec2(floor(p));
    int x = ip.x;
    int y = 4 - ip.y;
    
    uint r0=0u, r1=0u, r2=0u, r3=0u, r4=0u;
    
    if (id == 0) { r0=14u; r1=17u; r2=14u; r3=1u;  r4=30u; }  
    else if (id == 1) { r0=14u; r1=17u; r2=31u; r3=17u; r4=17u; }  
    else if (id == 2) { r0=17u; r1=25u; r2=21u; r3=19u; r4=17u; } 
    else if (id == 3) { r0=30u; r1=17u; r2=17u; r3=17u; r4=30u; } 
    else if (id == 4) { r0=14u; r1=17u; r2=16u; r3=17u; r4=14u; }  
    else if (id == 5) { r0=30u; r1=17u; r2=30u; r3=20u; r4=17u; }  
    else if (id == 6) { r0=31u; r1=16u; r2=30u; r3=16u; r4=16u; }  
    else if (id == 7) { r0=31u; r1=4u;  r2=4u;  r3=4u;  r4=4u;  }  
    
    uint row = 0u;
    if (y == 0) row = r0;
    else if (y == 1) row = r1;
    else if (y == 2) row = r2;
    else if (y == 3) row = r3;
    else if (y == 4) row = r4;
    
    return float((row >> uint(4 - x)) & 1u);
}

float renderText(vec2 p) {
    p.x += 18.0;
    p.y += 2.5;
    
    if (p.y < 0.0 || p.y > 5.0 || p.x < 0.0 || p.x > 36.0) return 0.0;
    
    int charIdx = int(floor(p.x / 3.6));
    vec2 charPos = vec2(mod(p.x, 3.6), p.y);
    
    if (charPos.x > 3.0) return 0.0;
    
    int id = 0;
    if (charIdx == 0) id = 0;      
    else if (charIdx == 1) id = 1;  
    else if (charIdx == 2) id = 2;  
    else if (charIdx == 3) id = 3;  
    else if (charIdx == 4) id = 4;  
    else if (charIdx == 5) id = 5;  
    else if (charIdx == 6) id = 1;  
    else if (charIdx == 7) id = 6;  
    else if (charIdx == 8) id = 7;  
    else return 0.0;
    
    return drawChar5x5(id, charPos * (5.0 / 3.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    float time = iTime;
    
    vec2 screenUV = (fragCoord.xy - 0.5 * resolution) / resolution.y;
    
    float introDuration = 3.5;
    float transitionDuration = 1.2;
    float gameTime = max(0.0, time - introDuration + 0.5);
    
    vec2 cameraPathPosCurrent = computeCameraPath(gameTime);
    vec2 cameraPathPosNext    = computeCameraPath(gameTime + 0.08);
    vec2 movementDirection    = cameraPathPosNext - cameraPathPosCurrent;
    
    vec3 rayOrigin = vec3(cameraPathPosCurrent.x, 0.0, cameraPathPosCurrent.y);
    
    float heightAtOrigin    = rawLandscapeHeight(rayOrigin.xz);
    float heightAlongTarget = rawLandscapeHeight(rayOrigin.xz + normalize(movementDirection) * 0.8);
    float terrainSlope      = heightAlongTarget - heightAtOrigin;
    
    float headBobbingPhase  = gameTime * 11.0;
    float stepInterpolation = clamp(sin(headBobbingPhase) * 1.75, -1.0, 1.0) * 0.5 + 0.5;
    float interpolatedBaseHeight = mix(heightAtOrigin, heightAlongTarget, stepInterpolation);
    float headBobbingOffset      = abs(sin(headBobbingPhase)) * 0.18;
    
    rayOrigin.y = interpolatedBaseHeight + 2.6 + headBobbingOffset;

    vec2 forward2D = normalize(movementDirection);
    float cameraPitch = -0.14 - terrainSlope * 0.04 - 0.04 * cos(headBobbingPhase);
    
    vec3 forwardVector = normalize(vec3(forward2D.x, cameraPitch, forward2D.y));
    vec3 rightVector   = normalize(cross(forwardVector, vec3(0.0, 1.0, 0.0)));
    vec3 upVector      = cross(rightVector, forwardVector);
    
    vec3 rayDirection = normalize(forwardVector + rightVector * screenUV.x + upVector * screenUV.y);
    rayDirection += step(abs(rayDirection), vec3(0.0001)) * 0.0001;
    
    vec3 currentVoxel = floor(rayOrigin);
    vec3 stepDirection = sign(rayDirection);
    vec3 deltaRayVector = abs(1.0 / rayDirection);
    vec3 sideDistances = (currentVoxel + step(0.0, rayDirection) - rayOrigin) / rayDirection;
    
    vec3 hitNormal = vec3(0.0);
    float hitType = 0.0;
    int objectType = 0;
    
    for (int stepIndex = 0; stepIndex < 150; stepIndex++) {
        if (isLandscapeVoxel(currentVoxel)) { 
            hitType = 1.0; 
            break; 
        }
        if (isObjectVoxel(currentVoxel, objectType)) { 
            hitType = 2.0; 
            break; 
        }
        
        hitNormal = step(sideDistances, sideDistances.yzx) * step(sideDistances, sideDistances.zxy);
        sideDistances += hitNormal * deltaRayVector;
        currentVoxel  += hitNormal * stepDirection;
    }
    
    vec3 sunDirection = normalize(vec3(0.5, 0.75, 0.35));
    vec3 skyColor = mix(vec3(0.62, 0.78, 0.98), vec3(0.16, 0.38, 0.80), clamp(rayDirection.y * 1.6 + 0.25, 0.0, 1.0));
    skyColor += vec3(1.0, 0.92, 0.72) * pow(max(dot(rayDirection, sunDirection), 0.0), 200.0);
    
    vec3 sceneColor3D = skyColor;
    
    if (hitType > 0.5) {
        float distanceToHit = dot(hitNormal, sideDistances - deltaRayVector);
        vec3 hitWorldPosition = rayOrigin + rayDirection * distanceToHit;
        vec3 surfaceNormal = -stepDirection * hitNormal;
        
        vec3 albedo = getVoxelAlbedo(currentVoxel, surfaceNormal, objectType);
        
        vec2 planeUV;
        if (abs(surfaceNormal.y) > 0.5)      planeUV = hitWorldPosition.xz;
        else if (abs(surfaceNormal.x) > 0.5) planeUV = hitWorldPosition.zy;
        else                                 planeUV = hitWorldPosition.xy;
        
        vec2 subGridUV = floor(fract(planeUV) * 4.0);
        float microTextureNoise = hash2D(floor(planeUV) * 1.3 + subGridUV * 0.27 + vec2(currentVoxel.y));
        albedo *= 0.85 + 0.26 * microTextureNoise;
        
        float faceShading = 0.7;
        if (surfaceNormal.y > 0.5)        faceShading = 1.0;
        else if (surfaceNormal.y < -0.5)  faceShading = 0.35;
        else if (abs(surfaceNormal.x) > 0.5) faceShading = 0.55;
        
        float diffuseIllumination = max(dot(surfaceNormal, sunDirection), 0.0);
        vec3 litColor = albedo * (0.35 + 0.65 * diffuseIllumination) * faceShading;
        
        float fogFactor = exp(-distanceToHit * 0.006);
        sceneColor3D = mix(skyColor, litColor, fogFactor);
    }
    
    sceneColor3D = pow(clamp(sceneColor3D, 0.0, 1.0), vec3(0.85));

    vec2 textSpace = screenUV * 28.0;
    float textMask = renderText(textSpace);
    
    vec3 textColor = vec3(0.35, 0.85, 0.25);
    vec3 textShadow = vec3(0.1, 0.05, 0.02);
    
    float textShadowMask = renderText(textSpace - vec2(0.6, -0.6));
    
    vec3 introBgColor = vec3(0.08, 0.12, 0.18) + 0.02 * hash3D(vec3(screenUV * 12.0, time));
    
    vec3 introColor = mix(introBgColor, textShadow, textShadowMask * 0.7);
    introColor = mix(introColor, textColor, textMask);
    
    float progress = clamp((time - (introDuration - transitionDuration)) / transitionDuration, 0.0, 1.0);
    
    vec2 voxelGrid = floor(screenUV * vec2(32.0, 32.0 * resolution.y / resolution.x));
    float voxelDelay = hash2D(voxelGrid) * 0.35;
    float adjustedProgress = clamp((progress - voxelDelay) / 0.65, 0.0, 1.0);
    float voxelDissolve = smoothstep(0.0, 1.0, adjustedProgress);
    
    vec3 finalColor = mix(introColor, sceneColor3D, voxelDissolve);
    
    fragColor = vec4(finalColor, 1.0);
}
