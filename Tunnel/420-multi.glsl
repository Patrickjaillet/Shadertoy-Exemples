// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    float horrorEffect = pow(abs(sin(iTime * 0.8)), 2.0);
    float shift = 0.006 * horrorEffect;
    
    vec3 col;
    col.r = texture(iChannel0, uv + vec2(shift, 0)).r;
    col.g = texture(iChannel0, uv).g;
    col.b = texture(iChannel0, uv - vec2(shift, 0)).b;
    
    vec3 glow = vec3(0);
    float lod = 3.5 + horrorEffect * 2.0;
    for(float x=-2.0; x<=2.0; x++) {
        for(float y=-2.0; y<=2.0; y++) {
            vec2 offset = vec2(x, y) * lod / iResolution.xy;
            glow += texture(iChannel0, uv + offset).rgb * exp(-(x*x+y*y)/4.0);
        }
    }
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//    
    col += (glow * 0.45);
    col *= 1.0 - length(uv - 0.5) * 0.0;
    col = col / (0.9 + col);
    
    fragColor = vec4(pow(col, vec3(0.4545)), 1.0);
}

// ==== Buffer A (buffer) ====
#define PI 3.14159265359

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 colorHash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

float perlin(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0,0)), hash(i + vec2(1,0)), u.x),
               mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * perlin(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

vec4 getHex(vec2 p) {
    vec2 s = vec2(1, 1.7320508);
    vec4 hC = floor(vec4(p, p - vec2(.5, 1))/s.xyxy) + .5;
    vec4 h = vec4(p - hC.xy*s, p - (hC.zw + .5)*s);
    return dot(h.xy, h.xy) < dot(h.zw, h.zw) ? vec4(h.xy, hC.xy) : vec4(h.zw, hC.zw + .5);
}

vec3 HexToSqr(vec2 st, inout vec2 uf) { 
    vec3 r;
    uf = vec2((st.x+st.y*1.73),(st.x-st.y*1.73))-.5;
    if (st.y > 0.-abs(st.x)*0.57777)
        if (st.x > 0.) r = vec3(fract(vec2(-st.x,(st.y+st.x/1.73)*0.86)*2.),2.);
        else r = vec3(fract(vec2(st.x,(st.y-st.x/1.73)*0.86)*2.),3.);
    else r = vec3(fract(uf+.5),1);
    return r;
} 
//======================================================================================//
//  >>  Author  : Patrick JAILLET                                                       //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
void pixel(vec2 st, vec2 s, float n, inout vec4 C, vec4 hx) {
    st = vec2(st.x, 1.-st.y);
    vec2 id = floor(st*10.) + s; 
    vec2 uniqueID = hx.zw + id * 0.01;
    vec3 pCol = colorHash(uniqueID);
    
    float noiseVal = fbm(uniqueID * 2.5 - iTime * 2.0);
    float light = pow(noiseVal, 12.0) * 60.0;
    light += smoothstep(0.2, 0.0, length(fract(st*10.0-0.5))) * 5.0;
    
    float glint = pow(hash(uniqueID + fract(iTime)), 20.0) * 40.0 * step(0.95, hash(uniqueID*1.5));
    
    vec4 P = vec4(pCol * ((4.0-n)*0.18) * (1.1 + light), 1.0);
    P.rgb += vec3(glint * smoothstep(0.5, 1.0, noiseVal));
    
    vec2 lc = 1.0 - fract(st*10.0);
    float sm = 15.0/iResolution.y;
    if (s == vec2(0)) C = mix(P*0.3, P*0.5, step(0.0, lc.x-lc.y));
    vec2 m = s*2.0-1.0;
    if (s.x != s.y) C = mix(C, mix(P*0.3, P*0.5, step(lc.x-lc.y, 0.0)), step(lc.x+lc.y, 0.8) * ((m.y==-1.)?step(lc.x-lc.y+1.,1.):step(1.,lc.x-lc.y+1.)));
    C = mix(C, P, smoothstep(0.5+sm, 0.5-sm, lc.x) * smoothstep(0.5+sm, 0.5-sm, lc.y));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float horrorPulse = pow(abs(sin(iTime * 0.8)), 4.0) * 2.2;
    float zoom = 1.0 + horrorPulse * 0.4;
    float r = length(uv) * zoom;
    float a = atan(uv.y, uv.x);
    
    float pShift = fbm(vec2(a * 0.8, iTime * 0.15)) * 0.5;
    float tunnelR = 4.0 / (r + pShift) - horrorPulse * 2.5; 
    
    vec2 tUV = vec2(a / (PI * 0.333), tunnelR + iTime * 2.5);
    vec4 hx = getHex(tUV);
    vec2 s;
    vec3 sqr = HexToSqr(hx.xy, s);
    vec4 C = vec4(0);
    
    pixel(sqr.xy, vec2(0), sqr.z, C, hx);
    pixel(sqr.xy, vec2(1,0), sqr.z, C, hx);
    pixel(sqr.xy, vec2(0,1), sqr.z, C, hx);
    pixel(sqr.xy, vec2(1,1), sqr.z, C, hx);
    
    C.rgb *= smoothstep(0.0, 1.8, r);
    fragColor = vec4(C.rgb * exp(-0.015 * tunnelR), 1.0);
}
