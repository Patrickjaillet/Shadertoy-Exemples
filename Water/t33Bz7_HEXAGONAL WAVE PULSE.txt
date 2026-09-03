// ==== Image (image) ====
// *** KYMATIX STUDIO ***
// *** https://kymatix.netlify.app ***

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.001

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}
vec4 HexCoords(vec2 uv) {
    vec2 r = vec2(1, 1.73);
    vec2 h = r * 0.5;
    
    vec2 a = mod(uv, r) - h;
    vec2 b = mod(uv - h, r) - h;
    
    vec2 gv = dot(a, a) < dot(b, b) ? a : b;
    vec2 id = uv - gv;
    return vec4(gv.x, gv.y, id.x, id.y);
}
float sdHexPrism(vec3 p, vec2 h) {
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0 * min(dot(k.xy, p.xy), 0.0) * k.xy;
    vec2 d = vec2(
       length(p.xy - vec2(clamp(p.x, -k.z*h.x, k.z*h.x), h.x)) * sign(p.y - h.x),
       p.z - h.y
    );
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}
float GetDist(vec3 p) {

    float curve = p.z * 0.15;
    p.y -= -2.0 + curve * curve * 0.5; 
    p.y += p.z * 0.2; 
    p.z += iTime * 2.0;
    
    vec4 hc = HexCoords(p.xz); 
    
    float d = length(hc.zw);
    float wave = sin(d * 0.5 - iTime * 1.5) * 0.5 + sin(hc.z * 0.8 + hc.w * 0.2 + iTime) * 0.3; 
    float height = 0.5 + wave * 0.4;

    vec3 pHex = vec3(hc.x, p.y - height + 1.0, hc.y);

    float hex = sdHexPrism(pHex.xzy, vec2(0.45, height)) - 0.05;
    
    return hex * 0.7;
}
vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.001, 0);
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx)
    );
    return normalize(n);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    vec3 ro = vec3(0, 3.0, -4.0);
    vec3 rd = normalize(vec3(uv.x, uv.y - 0.4, 1.0));

    float d = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        float dS = GetDist(p);
        d += dS;
        if(d > MAX_DIST || dS < SURF_DIST) break;
    }

    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n); 
        vec3 lightPos = vec3(2.0, 6.0, -3.0 + iTime * 2.0); 
        vec3 l = normalize(lightPos - p);

        float dif = clamp(dot(n, l), 0.0, 1.0);
        float spec = pow(max(dot(r, l), 0.0), 32.0);
        float edgeFactor = 1.0 - smoothstep(0.8, 0.98, n.y);
        
        vec3 colBlue = vec3(0.02, 0.1, 0.18);
        vec3 colGold = vec3(1.0, 0.7, 0.2);   
        vec3 albedo = mix(colBlue, colGold, edgeFactor);
        vec3 specColor = mix(vec3(1.0), colGold, edgeFactor); 
        
        col = albedo * (dif + 0.1); 
        col += spec * specColor * 2.0; 

        float fresnel = pow(1.0 - max(dot(n, -rd), 0.0), 5.0);
        col += fresnel * vec3(0.0, 0.5, 1.0) * 0.5 * (1.0 - edgeFactor);
        col *= 1.0 / (1.0 + d * d * 0.01);
    }
    
    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
