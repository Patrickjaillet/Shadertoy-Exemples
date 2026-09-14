// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
* - X: https://x.com/JailletPatrick                           *
***************************************************************
* https://patrickjaillet.github.io/sandefjord-software        *
* GLSL shader design and value tweaking - Sliders-GL v1.0.1:  *
* 100% safe Code Golfing - µShader v3.0.1:                    *
**************************************************************/
float hash31(vec3 p3) {
p3 = fract(p3 * vec3(.6031, .5030, .4973));
p3 += dot(p3, p3.zyx + 43.527);
return fract((p3.x + p3.y) * p3.z);
}

float mapMandelbulb(vec3 p) {
float power = 4.0 + 1.5 * sin(iTime * 0.05);
vec3 w = p;
float m = dot(w, w);
float dz = 1.0;

for (int i = 0; i < 7; i++) {
    float r = length(w);
    if (r < 1e-6) break;
    
    dz = power * pow(r, power - 1.0) * dz + 1.0;
    
    float b = power * acos(clamp(w.y / r, -1.0, 1.0));
    float a = power * atan(w.x, w.z);
    
    w = p + pow(r, power) * vec3(sin(b) * sin(a), cos(b), sin(b) * cos(a));
    
    m = dot(w, w);
    if (m > 150.0) break;
}

return 0.25 * log(m) * sqrt(m) / dz;
}

float mapScene(vec3 p) {
float t = iTime * 0.1;
float c = cos(t), s = sin(t);
p.xz *= mat2(c, s, -s, c);

return mapMandelbulb(p);
}

vec3 computeLighting(vec3 ro, vec3 rd, float t) {
vec3 sp = ro + rd * t;
vec3 lp = ro + vec3(1.0, 1.5, 1.0);

vec2 e = vec2(0.001, 0.0);
vec3 sn = normalize(vec3(
    mapScene(sp + e.xyy) - mapScene(sp - e.xyy),
    mapScene(sp + e.yxy) - mapScene(sp - e.yxy),
    mapScene(sp + e.yyx) - mapScene(sp - e.yyx)
));

vec3 ld = lp - sp;
float lDist = max(length(ld), 0.001);
ld /= lDist;

float shade = 1.0;
vec3 ro_sh = sp + sn * 0.002;
float t_sh = 0.01;

for(int i = 0; i < 16; i++) {
    vec3 p_sh = ro_sh + ld * t_sh;
    float d_sh = mapScene(p_sh);
    shade = min(shade, 16.0 * d_sh / t_sh);
    if(d_sh < 0.001 || t_sh > lDist) break;
    t_sh += clamp(d_sh, 0.01, 0.1);
}
float sh = max(shade, 0.0);

float sca = 2.0, occ = 0.0;
for(int i = 0; i < 5; i++) {
    float hr = 0.01 + float(i) * 0.1 / 5.0;
    float d_ao = mapScene(sp + sn * hr);
    occ += (hr - d_ao) * sca;
    sca *= 0.75;
}
float ao = clamp(1.0 - occ, 0.0, 1.0);

vec3 texCol = vec3(0.85, 0.65, 0.45);
float rough = 0.25 + hash31(floor(sp * 16.0)) * 0.1;
float amb = length(sin(sn * 2.0) * 0.5 + 0.5) / 1.73205 * smoothstep(-1.0, 1.0, sn.y);

vec3 h = normalize(ld - rd);
float nr = clamp(dot(sn, -rd), 0.0, 1.0);
float nl = clamp(dot(sn, ld), 0.0, 1.0);
float nh = clamp(dot(sn, h), 0.0, 1.0);
float vh = clamp(dot(-rd, h), 0.0, 1.0);

vec3 f0 = mix(vec3(0.04), texCol, 0.8);
vec3 FS = f0 + (1.0 - f0) * pow(1.0 - vh, 5.0);

float alpha = pow(rough, 4.0);
float b_ggx = (nh * nh * (alpha - 1.0) + 1.0);
float D = alpha / (3.14159265 * b_ggx * b_ggx);

float r_sch = 0.5 + 0.5 * rough;
float k_sch = (r_sch * r_sch) / 2.0;
float g1_l = max(nl, 0.001) / (nl * (1.0 - k_sch) + k_sch);
float g1_v = max(nr, 0.001) / (nr * (1.0 - k_sch) + k_sch);
float G = g1_l * g1_v;

vec3 spec = FS * D * G / (4.0 * max(nr, 0.001)) * 3.14159265;
vec3 diff = nl * (1.0 - FS) * 0.2;

vec3 col = texCol * (diff * sh + spec * sh + amb * (sh * 0.5 + 0.5));
return col * (ao / (1.0 + lDist * 0.1));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;

float cameraZ = 1.70 - sin(iTime * 0.5) * 0.2; 
vec3 ro = vec3(0.0, 0.0, cameraZ);
vec3 lk = vec3(0.0, 0.0, 0.0);

float FOV = 1.1;
vec3 fwd = normalize(lk - ro);
vec3 rgt = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
vec3 up = cross(fwd, rgt);

vec3 rd = normalize(uv.x * rgt + uv.y * up + fwd / FOV);

vec3 p3_jitter = fract((ro + rd) * vec3(0.6031, 0.5030, 0.4973));
p3_jitter += dot(p3_jitter, p3_jitter.zyx + 43.527);
float t = fract((p3_jitter.x + p3_jitter.y) * p3_jitter.z) * 0.005;

float d = 0.0;
for(int i = 0; i < 96; i++) {
    vec3 p = ro + rd * t;
    d = mapScene(p);
    if(abs(d) < 0.0008 || t > 10.0) break;
    t += d * 0.65;
}

vec3 col = vec3(0.0);

if(t < 10.0) {
    vec3 colC = computeLighting(ro, rd, t);

    float offset = 0.006 * (1.70 / cameraZ);
    vec3 rdL = normalize((uv.x - offset) * rgt + uv.y * up + fwd / FOV);
    vec3 rdR = normalize((uv.x + offset) * rgt + uv.y * up + fwd / FOV);

    float tL = t * dot(rd, rdL);
    float tR = t * dot(rd, rdR);

    vec3 colL = computeLighting(ro, rdL, tL);
    vec3 colR = computeLighting(ro, rdR, tR);

    col = vec3(colL.r, colC.g, colR.b);
}

vec2 uv_vignette = fragCoord / iResolution.xy;
float vignette = uv_vignette.x * uv_vignette.y * (1.0 - uv_vignette.x) * (1.0 - uv_vignette.y);
vignette = clamp(pow(16.0 * vignette, 0.2), 0.0, 1.0);
col *= vignette;

col = tanh(col);
fragColor = vec4(pow(max(col, 0.0), vec3(1.0 / 2.2)), 1.0);}
