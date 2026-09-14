// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, -5.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    
    float t = iTime * 0.15;
    mat2 r2d = mat2(cos(t), -sin(t), sin(t), cos(t));
    ro.xy *= r2d;
    rd.xy *= r2d;
    ro.xz *= r2d;
    rd.xz *= r2d;
    
    vec3 accColor = vec3(0.0);
    float tDist = 0.01;
    
    for(int i = 0; i < 35; i++)
    {
        vec3 p = ro + rd * tDist;
        
        float scale = 1.0;
        for(int j = 0; j < 6; j++)
        {
            p = abs(p) - vec3(0.3, 0.8, 0.5);
            
            if (p.x < p.y) p.yx = p.xy;
            if (p.x < p.z) p.zx = p.xz;
            if (p.y < p.z) p.zy = p.yz;
            
            float r2 = dot(p, p);
            if(r2 < 0.01) r2 = 0.01;
            
            float k = 2.4 / r2;
            p = p * k - vec3(1.0, 1.8, 0.5);
            scale *= k;
        }
        
        float dS = length(p.xz) / abs(scale) - 0.0005;
        dS = max(dS, 0.008);
        tDist += dS * 0.65;
        
        if(tDist > 12.0) break;
        
        float expFalloff = exp(-tDist * 0.3);
        float density = 1.0 / (1.0 + dS * dS * 800.0);
        
        float hue = 0.15 + 1.00 * sin(tDist * 1.0 + iTime * 0.2);
        float sat = 0.4;
        float val = density * expFalloff * 0.18;
        
        vec3 hsv = val * mix(vec3(1.0), clamp(abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0), sat);
        
        accColor += hsv;
    }
    
    fragColor = vec4(pow(max(accColor, 0.0), vec3(0.4545)), 1.0);
}
