// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 m = iMouse.xy / iResolution.xy;
    
    if(iMouse.z <= 0.0) {
        m = vec2(0.5 + 0.5 * sin(iTime * 0.2), 0.5 + 0.5 * cos(iTime * 0.3));
    }

    vec3 couleur_accumulee = vec3(0.0);
    vec2 p = uv * 2.0;
    float temps = iTime * 0.1;
    
    float a = 1.0 + 3.0 * m.x;
    float b = 1.0 + 3.0 * m.y;
    float c = 0.5 + m.x;
    float d = 0.5 + m.y;

    for(int i = 0; i < 16; i++)
    {
        float p_x = p.x;
        float p_y = p.y;
        
        p.x = sin(a * p_y) + c * cos(a * p_x);
        p.y = sin(b * p_x) + d * cos(b * p_y);
        
        float dist = length(p - uv);
        float intensite = exp(-2.5 * dist);
        
        vec3 col = 0.5 + 0.5 * cos(temps + float(i) * 0.4 + vec3(0, 2, 4));
        couleur_accumulee += col * intensite * 0.70;
    }

    couleur_accumulee = smoothstep(0.0, 1.0, couleur_accumulee);
    
    if(uv.y < -0.45) {
        float barre = step(abs(uv.x) - 0.4, 0.0);
        float curseur = step(length(vec2(uv.x - (m.x - 0.5) * 0.8, uv.y + 0.47)), 0.01);
        couleur_accumulee += vec3(barre * 0.2) + vec3(curseur);
    }

    fragColor = vec4(couleur_accumulee, 1.0);
}
