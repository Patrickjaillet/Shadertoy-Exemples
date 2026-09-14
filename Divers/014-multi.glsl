// ==== Image (image) ====
// Original by diatribes : https://www.shadertoy.com/view/NcfXW7
// tinkering... i like the log polar stuff by @YoheiNishitsuji
// but too lazy to learn a new coord system atm :D
// inspo: https://fragcoord.xyz/s/cbbga4b9

/*

    on this line play with the "1" to zoom in and out:
         D = normalize(vec3(u = (u+u-p.xy)/p.y, 1));
         
         to zoom in
         D = normalize(vec3(u = (u+u-p.xy)/p.y, 2));

         to zoom out
         D = normalize(vec3(u = (u+u-p.xy)/p.y, .5));


    .8-2.9'ish looks cool to me :D
    
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord + fragCoord - R) / R.y;
    vec2 texUV = fragCoord / R;
    
    vec4 data = texture(iChannel0, texUV);
    vec3 colorBase = data.rgb;
    float glowAmount = data.a;
    
    vec3 col = colorBase + (glowAmount * vec3(1.0, 0.8, 0.5) * 0.5);
    
    vec3 inverted = col.bgr; 
    col = mix(inverted, col, smoothstep(0.0, 0.5, length(uv) * 0.5));
    
    if (abs(uv.y) > 0.8) { 
        fragColor = vec4(0); 
        return; 
    }
    
    float luv = dot(uv, uv);
    vec3 finalCol = tanh( (col * col) / (2e8 * luv) );
    
    fragColor = vec4(finalCol, 1.0);
}

// ==== Common (common) ====
#define R iResolution.xy
#define T iTime

struct Camera {
    vec3 ro; 
    vec3 rd;
};

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

Camera getShipPath(float t) {
    float shakeMask = smoothstep(0.7, 1.0, sin(t * 0.5) * cos(t * 0.3) * 0.5 + 0.5);
    vec3 shake = vec3(
        sin(t * 50.0) * 0.05, 
        cos(t * 43.0) * 0.05, 
        sin(t * 37.0) * 0.03
    ) * shakeMask;

    vec3 ro = vec3(15.0 * sin(t * 0.08), 4.0 * cos(t * 0.12), 20.0 * cos(t * 0.08)) + shake;
    vec3 target = vec3(5.0 * sin(t * 0.2), 2.0 * cos(t * 0.1), 0.0);
    
    vec3 cw = normalize(target - ro);
    vec3 cp = vec3(sin(t * 0.05), 1.0, 0.0); 
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    
    return Camera(ro, cw);
}

// ==== Buffer A (buffer) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord + fragCoord - R) / R.y;
    float i = 0., d = 0., s;
    
    Camera ship = getShipPath(iTime);
    float zoom = 2.5;
    float glowIntensity = 0.54;
    float glowRadius = 0.6;
    
    vec3 f = ship.rd;
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    float roll = sin(iTime * 0.2) * 0.3;
    r.xy *= rot(roll); u.xy *= rot(roll);
    
    vec3 D = normalize(uv.x * r + uv.y * u + f * zoom);
    vec3 p, q;
    vec4 col = vec4(0);
    float accGlow = 0.0;
    
    for(; i++ < 100.0;) {
        q = p = ship.ro + D * d;
        p.z -= 10.0; 
        
        for(s = 0.01; s < 3.0; s += s) {
            p += cos(iTime * 0.025 + p.yzx * 0.1);
            D += i * 1e-5; 
            p -= abs(dot(sin(0.02 * p.x + p.y * 0.06 + iTime * 0.05 + 0.1 * p.z + p / s / 3.2), vec3(s)));
        }
        
        p.xy *= 0.1;
        
        float surfaceDist = mix(0.3 + 0.7 * abs(4.0 * dot(sin(q * 0.125), cos(q.yzx * 0.027))), 
                               0.02 + 0.4 * abs(length(p) - 30.0), 0.96);
        
        accGlow += glowIntensity / (surfaceDist + glowRadius);
        d += surfaceDist;
        
        col += (vec4(3.3, 2.0, 1.0, 0.0) / surfaceDist * d) + 
               (10.0 * (1.0 + cos(i * 0.4 + vec4(2, 1, 0, 0))) / surfaceDist);
        
        if(d > 100.0) break;
    }
    
    fragColor = vec4(col.rgb, accGlow);
}
