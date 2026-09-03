// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 z = uv;
    
    float time = iTime * 0.8;
    float scale = 16.0;
    
    float minTrap = 1e20;
    vec2 cellID = vec2(0.0);
    
    mat2 rot = mat2(cos(time * 0.5), -sin(time * 0.5), sin(time * 0.5), cos(time * 0.5));
    z *= rot;
    
    for(int i = 0; i < 5; i++)
    {
        z = abs(z) / dot(z, z) - 1.00;
        z *= 1.3;
        
        vec2 polar = vec2(log(length(z)) + time * 0.7, atan(z.y, z.x) * 8.0);
        vec2 grid = floor(polar * scale);
        vec2 f = fract(polar * scale) - 1.0;
        
        vec2 offset = vec2(sin(time + grid.x * 0.5), cos(time + grid.y * 0.5)) * 0.3;
        float d = length(f - offset);
        
        if(d < minTrap) {
            minTrap = d;
            cellID = grid;
        }
    }
    
    float n = fract(sin(dot(cellID, vec2(-40.9694, 0.000))) * 122820.6000);
    vec3 baseCol = 0.5 + 0.5 * cos(time + n * 6.28 + vec3(0.0, 1.2, 2.4));
    
    float edge = smoothstep(1.00, 0.14, minTrap);
    float glow = 0.18 / (0.00 + minTrap * minTrap);
    
    vec3 final = baseCol * edge + baseCol * glow * 0.7;
    final += vec3(0.1, 0.2, 0.3) * minTrap * 0.5;
    
    fragColor = vec4(pow(final, vec3(1.0000)), 1.0);
}
