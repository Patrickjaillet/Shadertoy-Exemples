// ==== Image (image) ====
// ==========================================================
// NAME : PASTEL MORPHING MEMBRANE
// ==========================================================
// DESCRIPTION : An organic scene featuring a raymarched blob 
// with complex trigonometric displacement. Includes a dynamic 
// fluid background, soft shadows, and a distance-based Depth 
// of Field (DoF) effect.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = texture(iChannel0, q).rgb;
    
    col = pow( col, vec3(0.4545) );
    col *= 1.05;
    col -= 0.03 * length(p);
    col *= pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
// ==========================================================
// NAME : PASTEL MORPHING MEMBRANE
// ==========================================================
// DESCRIPTION : An organic scene featuring a raymarched blob 
// with complex trigonometric displacement. Includes a dynamic 
// fluid background, soft shadows, and a distance-based Depth 
// of Field (DoF) effect.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

// --- BACKGROUND FLUID LOGIC ---

// Generates an animated fluid heightmap using nested sine/cosine waves.
float fluidH(vec2 uv)
{
    vec2 q = uv * 0.7;
    float t = iTime * 0.4;
    float n = sin(q.x + t) * cos(q.y - t);
    
    // Domain warping: the coordinates are shifted by their own trig values
    q.x += 0.5 * sin(t + q.y * 2.0);
    q.y += 0.5 * cos(t + q.x * 2.0);
    n += 0.5 * sin(q.x * 3.0 - t) * cos(q.y * 3.0 + t);
    return n;
}

// --- CORE GEOMETRY (SDF) ---

vec3 map( vec3 pos ) 
{
    // Apply time-based rotation to the entire space
    float an = 0.3 * iTime;
    float c = cos(an), s = sin(an);
    mat2 rot1 = mat2(c, -s, s, c);
    mat2 rot2 = mat2(cos(an*0.7), -sin(an*0.7), sin(an*0.7), cos(an*0.7));
    
    pos.xz *= rot1;
    pos.xy *= rot2;
    
    // Calculate multi-octave displacement (trigonometric noise)
    vec3 pb = pos * 1.5;
    float disp = sin(pb.x + iTime*1.3) * sin(pb.y + iTime*1.7) * sin(pb.z + iTime*2.1);
    disp += 0.7 * sin(2.0*pb.x - iTime*1.1) * sin(2.0*pb.y + iTime*0.5) * sin(2.0*pb.z - iTime*0.9);
    disp += 0.4 * sin(3.5*pb.x + iTime*2.0) * sin(3.5*pb.y) * sin(3.5*pb.z); 

    // Base geometry: A sphere deformed by the 'disp' value
    float radius = 1.1;
    float d = length(pos) - radius + disp * 0.25;

    // Helper values for shading: g = distance ratio, m = animation phase
    float g = length(pos) / (radius + 0.5); 
    float m = disp * 2.0 + iTime;    

    return vec3( d * 0.6, g, m );
}

// Tetrahedral normal calculation (optimized for accuracy)
vec3 calcNormal( in vec3 pos )
{
    const vec2 e = vec2(1.0,-1.0)*0.005; 
    return normalize( e.xyy*map( pos + e.xyy ).x + 
                      e.yyx*map( pos + e.yyx ).x + 
                      e.yxy*map( pos + e.yxy ).x + 
                      e.xxx*map( pos + e.xxx ).x );
}

// --- RAYMARCHING & LIGHTING ---

// Traditional raymarcher loop
vec4 intersect( in vec3 ro, in vec3 rd, float tmin, float tmax )
{
    float t = tmin;
    vec4 res = vec4(-1.0);
    for( int i=0; i<256; i++ ) 
    {
        vec3 d = map( ro + t*rd );
        if( d.x < 0.001 ) {
            res = vec4( t, d.yz, float(i)/256.0 );
            break;
        }
        t += d.x;
        if( t>tmax ) break;
    }
    return res;
}

// Ray-sphere intersection for bounding the raymarcher
vec2 iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - sph.w*sph.w;
    float h = b*b - c;
    if( h<0.0 ) return vec2(-1.0);
    h = sqrt(h);
    return vec2( -b - h, -b + h );
}

// Soft Shadow calculation for SDFs
float calcShadow(vec3 ro, vec3 rd, float mint, float maxt, float k)
{
    float res = 1.0;
    float t = mint;
    for(int i=0; i<32; i++)
    {
        float h = map(ro + rd*t).x;
        res = min(res, k*h/t); // Penumbra logic: narrower gaps create darker shadows
        if(res < 0.001) break;
        t += clamp(h, 0.02, 0.2);
    }
    return clamp(res, 0.0, 1.0);
}

// --- MAIN RENDERING ---

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;
    vec2 q = fragCoord.xy/iResolution.xy;

    // Camera setup
    vec3 ta = vec3(0.0,0.0,0.0);
    vec3 ro = vec3(0.0,0.0,3.2);        
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize( cross( normalize(vec3(0.0,1.0,0.0)), ww ) );
    vec3 vv = normalize( cross(ww,uu) );
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.8*ww );
    
    // 1. BACKGROUND CALCULATION
    // The background is a "wall" in 3D space with a procedural fluid texture.
    float tWall = (-1.5 - ro.z) / rd.z;
    vec3 wallPos = ro + tWall * rd;
    
    float fh = fluidH(wallPos.xy);
    float tFluid = iTime * 0.4;
    vec3 c1 = vec3(0.95, 0.8, 0.85); // Pastel pink
    vec3 c2 = vec3(0.8, 0.85, 0.95); // Pastel blue
    vec3 c3 = vec3(0.95, 0.85, 0.8); // Pastel peach
    float m1 = smoothstep(-1.0, 1.0, fh);
    float m2 = smoothstep(-1.0, 1.0, sin(fh * 3.0 + tFluid));
    vec3 bgBaseCol = mix(mix(c1, c2, m1), c3, m2);
    
    // Calculate normal of the fluid heightmap for lighting the wall
    vec2 eNormal = vec2(0.03, 0.0);
    vec3 bgNor = normalize(vec3(
        fluidH(wallPos.xy - eNormal.xy) - fluidH(wallPos.xy + eNormal.xy),
        fluidH(wallPos.xy - eNormal.yx) - fluidH(wallPos.xy + eNormal.yx),
        0.15
    ));

    vec3 lig1 = normalize(vec3(0.6, 0.7, 0.5));
    float bgDif = max(dot(bgNor, lig1), 0.0);
    float bgAmb = 0.5 + 0.5 * bgNor.z;
    vec3 bgCol = bgBaseCol * (bgDif * 0.7 + bgAmb * 0.4);
    
    // Apply shadow cast by the blob onto the background wall
    float shadow = calcShadow(wallPos, lig1, 0.05, 5.0, 12.0);
    vec3 shadowColor = vec3(0.6, 0.65, 0.75);
    bgCol *= mix(shadowColor, vec3(1.0), shadow);
    
    vec3 col = bgCol;
    float finalT = tWall;
        
    // 2. BLOB INTERSECTION
    vec2 sp = iSphere( ro, rd, vec4(0.0,0.0,0.0,2.2) );
    if( sp.y>0.0 )
    {
        vec4 res = intersect( ro, rd, max(sp.x,0.0), sp.y );
        if( res.x>0.0 && res.x < tWall )
        {
            float tRes = res.x;
            finalT = tRes;
            vec3 pos = ro + tRes*rd;
            vec3 nor = calcNormal( pos );

            // Pastel Shading Logic
            float idBlob = 0.5 + 0.5*sin(res.z);
            vec3 pastelBase = 0.7 + 0.25 * cos(idBlob * 2.0 + vec3(0.0, 1.5, 3.0));
            
            vec3 lig2 = normalize(vec3(-0.6, -0.4, -0.5));
            float dif1 = max(dot(nor, lig1), 0.0);
            float dif2 = max(dot(nor, lig2), 0.0) * 0.5;
            float amb = 0.6 + 0.4 * nor.y;
            float rim = pow(clamp(1.0 - dot(nor, -rd), 0.0, 1.0), 2.5);
            
            vec3 blobCol = pastelBase * (dif1 * vec3(1.0, 0.95, 0.9) + dif2 * vec3(0.8, 0.85, 0.9) + amb * vec3(0.9, 0.92, 0.95));
            blobCol += rim * vec3(1.0, 0.9, 0.95) * 0.5; // Fresnel/Rim lighting
            
            blobCol *= 0.6 + 0.4 * smoothstep(0.2, 0.8, res.y);
            col = blobCol;
        }
    }
    
    // 3. DEPTH OF FIELD (DOF)
    // We simulate focus by mixing the current pixel with a "blurred" (background) version
    // based on the distance from the focus plane (2.7 units from camera).
    float focusDist = 2.7;
    float dofScale = 1.0;
    float distFromFocus = abs(finalT - focusDist);
    float dofFactor = smoothstep(0.0, 2.0, distFromFocus * dofScale);
    col = mix(col, bgCol, dofFactor);

    // 4. TEMPORAL BLENDING (Motion Blur/Anti-aliasing)
    vec3 prevCol = texture(iChannel0, q).rgb;
    float blendFactor = 0.75;
    if (iFrame > 0) {
        col = mix(col, prevCol, blendFactor);
    }
    
    fragColor = vec4( col, 1.0 );
}
