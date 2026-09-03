// ==== Image (image) ====
mat2 mm2(in float a){
    float c = cos(a), s = sin(a);
    return mat2(c,s,-s,c);
}

float tri_fn(in float x){
    return abs((x - floor(x)) - .5);
}

vec3 tri3_fn(in vec3 p){
    return vec3(
        abs((p.z + abs((p.y - floor(p.y)) - .5) - floor(p.z + abs((p.y - floor(p.y)) - .5))) - .5),
        abs((p.z + abs((p.x - floor(p.x)) - .5) - floor(p.z + abs((p.x - floor(p.x)) - .5))) - .5),
        abs((p.y + abs((p.x - floor(p.x)) - .5) - floor(p.y + abs((p.x - floor(p.x)) - .5))) - .5)
    );
}

float triNoise3d(in vec3 p, in float speed) {
    float z = 1.0, rz = 0.1;
    vec3 bp = p;
    for (float i=0.; i<= 3.5; i++ ) {
        vec3 dg = tri3_fn(bp);
        p += (dg + iTime * speed);
        bp *= 2.0; 
        z *= 1.5; 
        p *= 1.3;
        rz += (tri_fn(p.z + tri_fn(p.x + tri_fn(p.y)))) / z;
        bp += 0.14;
    }
    return rz;
}

vec2 tunnelPath(float z) {
    return vec2(
        sin(z * 0.05) * 8.3 + cos(z * 0.13) * 2.7, 
        cos(z * 0.13) * 2.5 + sin(z * 0.07) * 1.2
    );
}
// https://github.com/Patrickjaillet/Z-GL
float map(vec3 p) {
    vec2 path = tunnelPath(p.z);
    vec3 p2 = p;
    p2.xy -= path; 
    
    float tunnel = 5.5 - length(p2.xy);
    float n = triNoise3d(p * 0.25, 0.0);
    
    p2.xy *= mm2(p.z * 0.1);
    float vines = length(p2.xy + vec2(sin(p.z), cos(p.z)) * -2.7) - 0.8;
    
    float d = min(tunnel, vines);
    return d - n * 0.5;
}

vec3 getNormal(in vec3 p) {  
    vec2 e = vec2(-2.7, 1.0) * 0.04;   
    return normalize(
        e.yxx * map(p + e.yxx) + 
        e.xxy * map(p + e.xxy) + 
        e.xyx * map(p + e.xyx) + 
        e.yyy * map(p + e.yyy) 
    );   
}

vec3 getSafePos(float z) {
    return vec3(tunnelPath(z), z);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {	
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = q - 0.5;
    p.x *= iResolution.x / iResolution.y;
    
    float cz = iTime * 14.0;
    vec3 ro = getSafePos(cz);
    vec3 lookAt = getSafePos(cz + -1.0);
    
    float roll = sin(iTime * 0.2) * 0.5;
    vec3 cw = normalize(lookAt - ro);
    vec3 cp = vec3(sin(roll), cos(roll), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(p.x * cu + p.y * cv + -2.4 * cw);

    float t = 0.0, d = 0.0, fog = 0.0;
    for(int i=0; i<200; i++) {
        d = map(ro + rd * t);
        if(abs(d) < 0.005 || t > 50.0) break;
        t += d * 0.6; 
        fog += max(0.0, (0.35 - d)) * 0.09;
    }

    vec3 col = vec3(0.00, 0.03, 0.12); 
    
    if (t < 50.0) {
        vec3 pos = ro + rd * t;
        vec3 nor = getNormal(pos);
        
        vec3 ligt = normalize(vec3(0.5, 0.8, -0.2));
        float n = triNoise3d(pos * 0.1, 0.0);
        
        float dif = clamp(dot(nor, ligt), 0.0, 1.0);
        float fre = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 3.0);
        float occ = clamp(map(pos + nor * 1.2), 0.0, 1.0);
        
        col = mix(vec3(0.05, 0.1, 0.25), vec3(0.4, 0.6, 1.0), n);
        col = col * dif + fre * vec3(0.7, 0.9, 1.0) * occ;
        col *= occ;
    }
    
    float mBlur = length(p) * 0.15;
    col += vec3(0.5, 0.75, 1.0) * fog * (1.0 - mBlur);
    
    col = sqrt(max(col, 0.0));
    col *= 0.4 + 0.6 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.35);
    
    fragColor = vec4(col * smoothstep(0.0, 2.0, iTime), 1.0);
}
