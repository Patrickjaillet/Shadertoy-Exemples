// ==== Image (image) ====
mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(
        mix(mix(fract(sin(n + 0.0) * 43758.5453), fract(sin(n + 1.0) * 43758.5453), f.x),
            mix(fract(sin(n + 157.0) * 43758.5453), fract(sin(n + 158.0) * 43758.5453), f.x), f.y),
        mix(mix(fract(sin(n + 113.0) * 43758.5453), fract(sin(n + 114.0) * 43758.5453), f.x),
            mix(fract(sin(n + 270.0) * 43758.5453), fract(sin(n + 271.0) * 43758.5453), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5000 * noise(p); p *= 2.02;
    f += 0.2500 * noise(p); p *= 2.03;
    f += 0.1250 * noise(p); p *= 2.01;
    f += 0.0625 * noise(p);
    return f;
}

vec2 iSphere(in vec3 ro, in vec3 rd, in vec4 sph) {
    vec3 oc = ro - sph.xyz;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sph.w * sph.w;
    float h = b * b - c;
    if(h < 0.0) return vec2(-1.0);
    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

// --- The Physics Engine (Ray Integration) ---

vec4 intersect(in vec3 ro, in vec3 rd, float tmin, float tmax, float gravityMass, float tilt) {
    float t = tmin;
    vec4 col = vec4(0.0);
    vec3 p = ro + rd * t;
    float dt = 0.05;

    for(int i = 0; i < 200; i++) {
        float r2 = dot(p, p); 
        
        // Event Horizon (scales with mass)
        float eh = 0.6 * (gravityMass / 0.8);
        if(r2 < eh) {
            col.xyz *= 0.0;
            col.w = 1.0; 
            break;
        }

        // Gravitational Lensing Physics
        vec3 gravity = -normalize(p) * (gravityMass / r2);
        rd = normalize(rd + gravity * dt);
        
        p += rd * dt;
        t += dt;

        // Apply Ctrl-Mouse tilt to the disk only
        vec3 diskP = p;
        diskP.yz *= rot(tilt);

        // Accretion Disk
        float r = length(diskP.xz);
        if(r > 1.2 && r < 4.5) {
            float d = abs(diskP.y);
            float h = 0.05 + 0.2 * (r - 1.2); 
            
            if(d < h) {
                float density = 1.0 - d / h;
                float n = fbm(diskP * 4.0 - vec3(0.0, iTime * 0.8, 0.0));
                density *= smoothstep(0.1, 0.9, n);
                
                float falloff = smoothstep(1.2, 1.5, r) * smoothstep(4.5, 3.0, r);
                density *= falloff;

                // Color shifts hotter (blue/white) if mass is high
                vec3 coldCol = vec3(0.8, 0.3, 0.05);
                vec3 hotCol = mix(vec3(1.0, 0.8, 0.5), vec3(0.5, 0.8, 1.0), gravityMass - 0.5);
                vec3 diskCol = mix(hotCol, coldCol, (r - 1.2) / 3.3);
                
                float alpha = density * 0.2;
                col.xyz += (1.0 - col.w) * diskCol * alpha * (4.0 / r2);
                col.w += (1.0 - col.w) * alpha; 
            }
        }

        if(col.w > 0.99 || t > tmax) break;
    }

    // Background Stars
    if(col.w < 1.0 && dot(p, p) > 0.6) {
        float starN = noise(rd * 200.0);
        float star = pow(starN, 25.0) * 2.5;
        vec3 bgCol = vec3(0.05, 0.1, 0.15) * fbm(rd * 3.0) + vec3(star) * vec3(1.0, 0.9, 0.8);
        col.xyz += (1.0 - col.w) * bgCol;
    }

    return col;
}

// --- Main Image Rendering & Interaction ---

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
    vec2 q = fragCoord.xy / iResolution.xy;

    // --- FETCH DATA FROM BUFFER A ---
    vec2 camPos    = texelFetch(iChannel0, ivec2(0,0), 0).xy;
    float slider   = texelFetch(iChannel0, ivec2(1,0), 0).x;
    float zoom     = texelFetch(iChannel0, ivec2(2,0), 0).x;
    float tilt     = texelFetch(iChannel0, ivec2(2,0), 0).y;

    // Map slider to physical gravity mass (0.2 to 1.7)
    float gravityMass = 0.2 + slider * 1.5;

    // Default orbit rotation if not moving WASD
    float yaw = iTime * 0.2;
    float pitch = 1.5;

    // WASD offsets the target point (pan)
    vec3 ta = vec3(camPos.x * 2.0, -camPos.y * 2.0, 0.0); 
    
    // Orbital radius
    vec3 ro = vec3(6.0 * cos(yaw), pitch, 6.0 * sin(yaw)) + ta;

    // View Matrix construction (LookAt) with Zoom modifier
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(vec3(0.0, 1.0, 0.0), ww));
    vec3 vv = normalize(cross(ww, uu));
    // Apply zoom (default is 1.0, higher = narrower FOV)
    vec3 rd = normalize(p.x * uu + p.y * vv + (2.0 * zoom) * ww);

    // Intersection with the active physics zone
    vec2 sp = iSphere(ro, rd, vec4(ta, 20.0));
    vec3 col = vec3(0.0);

    if(sp.y > 0.0) {
        vec4 res = intersect(ro, rd, max(sp.x, 0.0), sp.y, gravityMass, tilt);
        col = res.xyz;
    }

    // --- Post-Processing ---
    col = pow(col, vec3(0.4545)); // Gamma correction
    col *= vec3(1.1, 1.0, 0.9);   // Warm highlights
    col *= pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.1); // Vignette

    // --- DRAW UI SLIDER OVERLAY ---
    float sMinX = 0.1, sMaxX = 0.4;
    float sMinY = 0.05, sMaxY = 0.1;
    
    // Background of slider
    if (q.x > sMinX && q.x < sMaxX && q.y > sMinY && q.y < sMaxY) {
        col = mix(col, vec3(0.1), 0.7); // Dark semi-transparent box
        
        // Fill percentage of slider
        float fillPos = sMinX + (sMaxX - sMinX) * slider;
        if (q.x < fillPos) {
            // Hot orange UI color
            col = mix(col, vec3(1.0, 0.6, 0.1), 0.8); 
        }
        
        // Simple border
        if (abs(q.y - sMinY) < 0.005 || abs(q.y - sMaxY) < 0.005 || abs(q.x - sMinX) < 0.005 || abs(q.x - sMaxX) < 0.005) {
            col = vec3(0.8); 
        }
    }

    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    ivec2 px = ivec2(fragCoord);
    if (px.y > 0 || px.x > 2) { discard; return; }

    // Read previous state from Buffer A (Self-reference)
    vec4 camState    = texelFetch(iChannel1, ivec2(0,0), 0);
    vec4 sliderState = texelFetch(iChannel1, ivec2(1,0), 0);
    vec4 modState    = texelFetch(iChannel1, ivec2(2,0), 0);

    // Initial setup
    if (iFrame == 0) {
        camState = vec4(0.0);
        sliderState = vec4(0.5, 0.0, 0.0, 0.0); 
        modState = vec4(1.0, 0.0, 0.0, 0.0);    
    }

    // --- KEYBOARD INPUTS ---
    // Mapping: WASD + ARROWS
    bool w = texelFetch(iChannel0, ivec2(87,0), 0).x > 0.5 || texelFetch(iChannel0, ivec2(38,0), 0).x > 0.5;
    bool a = texelFetch(iChannel0, ivec2(65,0), 0).x > 0.5 || texelFetch(iChannel0, ivec2(37,0), 0).x > 0.5;
    bool s = texelFetch(iChannel0, ivec2(83,0), 0).x > 0.5 || texelFetch(iChannel0, ivec2(40,0), 0).x > 0.5;
    bool d = texelFetch(iChannel0, ivec2(68,0), 0).x > 0.5 || texelFetch(iChannel0, ivec2(39,0), 0).x > 0.5;
    
    bool shift = texelFetch(iChannel0, ivec2(16,0), 0).x > 0.5;
    bool ctrl  = texelFetch(iChannel0, ivec2(17,0), 0).x > 0.5;

    float speed = 0.05;
    if (w) camState.y -= speed;
    if (s) camState.y += speed;
    if (a) camState.x -= speed;
    if (d) camState.x += speed;

    // Mouse Interaction
    vec2 uv = iMouse.xy / iResolution.xy;
    vec2 mDelta = iMouse.xy - abs(iMouse.zw); 

    if (iMouse.z > 0.0) {
        if (shift) {
            // Zoom modifier
            modState.x -= (mDelta.y / iResolution.y) * 0.02;
            modState.x = clamp(modState.x, 0.3, 3.0);
        } else if (ctrl) {
            // Tilt modifier
            modState.y += (mDelta.x / iResolution.x) * 0.05;
        } else {
            // UI Slider interaction
            if (uv.x > 0.1 && uv.x < 0.4 && uv.y > 0.05 && uv.y < 0.1) {
                sliderState.x = clamp((uv.x - 0.1) / 0.3, 0.0, 1.0);
            }
        }
    }

    // Storage
    if (px.x == 0) fragColor = camState;
    if (px.x == 1) fragColor = sliderState;
    if (px.x == 2) fragColor = modState;
}
