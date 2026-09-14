
void mainImage(out vec4 o, vec2 c) {
    vec3 r = iResolution, p = vec3(0, 0, -iTime);
      for(int i; i < 40; i++)      
        p += vec3((c+c-r.xy)/r.y, 1) * (length(sin(p) * cos(p.yzx)) - .4);
        o = sin(p + iTime).xyzz;
}
