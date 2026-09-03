// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 res = vec2(320.0, 200.0);
    vec2 st = floor(uv * res);
    
    vec3 greenST = vec3(0.0, 0.666, 0.0);
    vec3 black = vec3(0.0);
    vec3 white = vec3(1.0);
    vec3 red = vec3(0.9, 0.0, 0.0);
    
    vec3 col = greenST;
    
    float time = iTime;
    float bombCycle = floor(time * 0.8);
    float numBombs = mod(bombCycle, 8.0) + 1.0;
    
    float bombWidth = 16.0;
    float bombHeight = 16.0;
    float spacing = 20.0;
    
    float totalWidth = numBombs * spacing;
    float startX = floor((res.x - totalWidth) * 0.5);
    float startY = 100.0;
    
    for (float i = 0.0; i < 8.0; i += 1.0) {
        if (i >= numBombs) break;
        
        vec2 bPos = vec2(startX + i * spacing, startY);
        vec2 local = st - bPos;
        
        if (local.x >= 0.0 && local.x < bombWidth && local.y >= 0.0 && local.y < bombHeight) {
            float lx = local.x;
            float ly = local.y;
            
            float isBlack = 0.0;
            
            if (ly >= 2.0 && ly <= 11.0 && lx >= 3.0 && lx <= 12.0) isBlack = 1.0;
            if (ly >= 4.0 && ly <= 9.0 && lx >= 1.0 && lx <= 14.0) isBlack = 1.0;
            if (ly >= 1.0 && ly <= 12.0 && lx >= 5.0 && lx <= 10.0) isBlack = 1.0;
            
            if (ly == 12.0 && lx >= 7.0 && lx <= 8.0) isBlack = 1.0;
            if (ly == 13.0 && lx >= 6.0 && lx <= 9.0) isBlack = 1.0;
            
            if (ly == 14.0 && lx >= 9.0 && lx <= 11.0) isBlack = 1.0;
            if (ly == 15.0 && lx >= 11.0 && lx <= 13.0) isBlack = 1.0;
            
            if (ly == 8.0 && lx >= 5.0 && lx <= 6.0) isBlack = 0.0;
            if (ly == 7.0 && lx >= 6.0 && lx <= 7.0) isBlack = 0.0;

            float isWhite = 0.0;
            if (ly == 15.0 && lx == 14.0) isWhite = 1.0;
            if (ly == 14.0 && lx == 12.0) isWhite = 1.0;

            if (isWhite > 0.5) {
                col = white;
            } else if (isBlack > 0.5) {
                col = black;
            }
        }
    }
    
    float glitchTrigger = step(0.7, sin(time * 15.0));
    if (glitchTrigger > 0.5 && st.y < 30.0) {
        float shift = floor(sin(st.y * 50.0 + time * 20.0) * 10.0);
        float p = mod(st.x + shift, 4.0);
        col = (p < 2.0) ? red : black;
    }

    fragColor = vec4(col, 1.0);
}
