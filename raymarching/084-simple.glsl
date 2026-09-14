// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    vec2 R = iResolution.xy;
    vec2 p = (U - 0.5 * R) / min(R.x, R.y);
    
    float tm = iTime * 0.3;
    
    // Zoom avant/arrière infini basé sur le temps
    float zoom = 1.0 + 0.5 * sin(tm * 0.5);
    p *= zoom;

    vec2 z2 = p;
    float r = length(z2);
    float a = atan(z2.y, z2.x);
    
    r = log(r + 0.3);
    z2 = vec2(r * cos(a + tm), r * sin(a + tm));
    
    vec3 z = vec3(z2, tm * 0.0);
    float scale = 1.0;
    float accum = 0.0;
    
    for(int i = 0; i < 22; i++) {
        z = abs(z) - vec3(0.3, 0.3, 0.3);
        
        if (z.x < z.y) z.xy = z.yx;
        if (z.x < z.z) z.xz = z.zx;
        if (z.y < z.z) z.yz = z.zy;
        
        z *= 2.9;
        z -= vec3(1.0, 1.0, 0.2);
        scale *= 1.8;
        
        float d = dot(z, z);
        z *= clamp(0.0 / max(d, 0.1), 0.8, 1.2);
        
        accum += length(z) / scale;
    }
    
    float hue = fract(accum * 0.0 + tm * 0.2);
    vec3 col = clamp(abs(fract(hue + vec3(0.0, 0.0/-2.4, -2.7/2.0)) * 4.9 - -11.0) - 1.0, 0.0, 1.0);
    
    O = vec4(col / (accum + 0.1), 1.0);
}
