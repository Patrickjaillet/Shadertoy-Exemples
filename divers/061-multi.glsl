// ==== Image (image) ====
//======================================================================================//
//  >>  Author  : Patrick JAILLET		                            					//
//  >>  Email   : metashader@proton.me		                        					//
//  >>  Engine  : MetaShader				                            				//
//  >>  URL     : https://0110110101110011.netlify.app	                				//
//*====================================================================================*//

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    float a = hash11(i.x + i.y*57.0);
    float b = hash11(i.x + 1.0 + i.y*57.0);
    float c = hash11(i.x + (i.y+1.0)*57.0);
    float d = hash11(i.x + 1.0 + (i.y+1.0)*57.0);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec3 getPos(float t) {
    return vec3(25.0 * sin(t * 0.4), 12.0 + 9.0 * cos(t * 0.4) + 5.0 * sin(t * 1.2), 18.0 * sin(t * 0.8));
}

float sdSegment(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return length(pa - ba*h) - r;
}

// Fix of the rails by iq - https://www.shadertoy.com/user/iq
float map(vec3 p)
{
    float d = p.y + 2.0;
    float t_cam = iTime * 0.4;
    float step_val = 0.15;
    float center_t = floor(t_cam / step_val) * step_val;
    
    for( int i=-10; i<17; i++ )
    {
        float t = center_t + float(i)*step_val;
        vec3 p1 = getPos(t + step_val*0.0);
        vec3 p2 = getPos(t + step_val*1.0);
        vec3 p3 = getPos(t + step_val*2.0);
        vec3 side1 = normalize(cross(p2-p1, vec3(0,1,0)));
        vec3 side2 = normalize(cross(p3-p2, vec3(0,1,0)));
        vec3 offset1 = side1 * 0.8;
        vec3 offset2 = side2 * 0.8;
        float r1 = sdSegment(p, p1+offset1, p2+offset2, 0.08);
        float r2 = sdSegment(p, p1-offset1, p2-offset2, 0.08);
        float sleepers = sdSegment(p, p1+offset1, p1-offset1, 0.04);
        d = min(d, min(min(r1, r2), sleepers));
        
        if(fract(t*1.5) < 0.1)
        {
            float posts = sdSegment(p, p1, vec3(p1.x, -2.0, p1.z), 0.15);
            d = min(d, posts);
        }
    }
    return d;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(map(p+e.xyy)-map(p-e.xyy), map(p+e.yxy)-map(p-e.yxy), map(p+e.yyx)-map(p-e.yyx)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float r2 = dot(uv, uv);
    uv *= (1.0 + 0.15 * r2);
    
    float camT = iTime * 0.4;
    vec3 ro = getPos(camT);
    vec3 target = getPos(camT + 0.1);
    vec3 tan = normalize(target - ro);
    vec3 side = normalize(cross(tan, vec3(0,1,0)));
    vec3 cam_up = normalize(cross(side, tan) + side * clamp(sin(camT)*0.6, -0.9, 0.9));
    vec3 cam_side = normalize(cross(cam_up, tan));
    
    ro += cam_up * 0.7;
    vec3 rd = normalize(uv.x*cam_side + uv.y*cam_up + 1.2*tan);
    
    vec3 sunDir = normalize(vec3(0.5, 0.7, -0.4));
    vec3 sky = mix(vec3(0.4, 0.6, 0.9), vec3(0.1, 0.3, 0.7), rd.y);
    float clouds = noise(rd.xz / (max(rd.y, 0.01)) * 0.4 + iTime * 0.03);
    sky = mix(sky, vec3(1.0), smoothstep(0.5, 0.8, clouds) * max(rd.y, 0.0));
    sky += pow(max(dot(rd, sunDir), 0.0), 200.0) * 0.6;
    
    vec3 col = sky;
    float t = 0.0;
    for(int i=0; i<70; i++) {
        float d = map(ro + rd*t);
        if(d < 0.006 || t > 70.0) break;
        t += d;
    }
    
    if(t < 70.0) {
        vec3 p = ro + rd*t;
        vec3 n = getNormal(p);
        float diff = max(dot(n, sunDir), 0.0);
        float spec = pow(max(dot(reflect(-sunDir, n), -rd), 0.0), 32.0);
        vec3 matCol = (p.y < 0.5) ? vec3(0.1, 0.15, 0.08) : vec3(0.7, 0.72, 0.75);
        if(p.y > 0.5 && fract(p.y*2.0) > 0.9) matCol = vec3(0.8, 0.1, 0.1);
        col = matCol * (diff + 0.2) + spec * 0.4;
        col = mix(col, sky, 1.0 - exp(-0.015 * t));
    }
    
    col *= 1.0 - smoothstep(0.4, 1.4, r2);
    fragColor = vec4(pow(max(col, 0.0), vec3(0.4545)), 1.0);
}

// ==== Sound (sound) ====
float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 getPos(float t) {
    float x = 25.0 * sin(t * 0.4);
    float z = 15.0 * sin(t * 0.8);
    float y = 10.0 + 8.0 * cos(t * 0.4) + 4.0 * sin(t * 1.2);
    return vec3(x, y, z);
}
//======================================================================================//
//  >>  Author  : Patrick JAILLET		                            					//
//  >>  Email   : metashader@proton.me		                        					//
//  >>  Engine  : MetaShader				                            				//
//  >>  URL     : https://0110110101110011.netlify.app	                				//
//*====================================================================================*//
vec2 mainSound(int samp, float time) {
    vec3 p1 = getPos(time * 0.4);
    vec3 p2 = getPos(time * 0.4 + 0.01);
    float vel = length(p2 - p1) * 100.0;
    
    float n1 = hash11(time * 44100.0);
    float n2 = hash11(time * 22050.0);
    
    float rumble = sin(6.2831 * 60.0 * time * (1.0 + vel * 0.05));
    rumble *= n1 * 0.3;
    
    float click = step(0.98, fract(time * vel * 0.2)) * n2 * 0.5;
    
    float wind = n1 * pow(vel * 0.02, 2.0);
    float flt = sin(time * 10.0) * 0.1;
    wind *= (0.5 + flt);
    
    float final = (rumble + click + wind * 0.2) * 0.3;
    
    return vec2(final);
}
