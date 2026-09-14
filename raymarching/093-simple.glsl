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
void mainImage(out vec4 o, in vec2 FC) {
    vec2 r = iResolution.xy;
    float t = iTime;
    o = vec4(0);
    vec3 p, q = vec3(0.0, 0.4, -2.0);
    for (float j, i = 0.0, e = 0.0, v; i++ < 130.0; 
         o += 0.007 / exp(3e3 / (v * vec4(9, 5, 4, 4) + e * 4e6))) {
        p = q += vec3((FC - 0.5 * r) / r.y, 1.0) * e;
        
        float globalWind = sin(t * 1.2 + p.y * 0.5) * 0.05 + sin(t * 2.5) * 0.02;
        vec3 ap = p;
        ap.x += globalWind * max(0.0, ap.y + 0.7);

        float ground = ap.y + 0.7;
        vec3 gp = ap;
        gp.xz *= 20.0;
        gp.xz = abs(mod(gp.xz + 0.5, 1.0) - 0.5);
        float h_noise = sin(ap.x * 30.0 + ap.z * 20.0) * 0.1;
        float h = 0.15 + h_noise;
        gp.y = gp.y + 0.7;
        gp.xy *= mat2(cos(sin(ap.x * 10.0 + ap.z * 10.0 + t * 2.0) * 0.2), -sin(sin(ap.x * 10.0 + ap.z * 10.0 + t * 2.0) * 0.2), sin(sin(ap.x * 10.0 + ap.z * 10.0 + t * 2.0) * 0.2), cos(sin(ap.x * 10.0 + ap.z * 10.0 + t * 2.0) * 0.2));
        float blade = length(gp.xz) - 0.01 * (1.0 - clamp(gp.y / h, 0.0, 1.0));
        blade = max(blade, gp.y);
        blade = max(blade, gp.y - h);
        ground = min(ground, blade / 20.0);
        
        float trunk = length(ap.xz) - 0.012;
        trunk = max(trunk, max(-ap.y - 0.7, ap.y + 0.1));
        float treeSDF = trunk;
        v = 1.0;
        vec3 tp = ap + vec3(0.0, 0.1, 0.0);
        
        for (j = 0.0; j++ < 4.0;) {
            tp.x = abs(tp.x);
            float branchWind = (sin(t * 1.5 + j * 0.8) * 0.03 + 0.02) * j;
            float a = 0.36 - j * 0.04 + branchWind;
            tp.xy *= mat2(cos(a), -sin(a), sin(a), cos(a));
            float branch = length(tp.xz) - 0.009 * v;
            branch = max(branch, max(-tp.y, tp.y - 0.55 * v));
            treeSDF = min(treeSDF, branch);
            tp.y -= 0.5 * v;
            v *= 0.72;
        }
        
        vec3 lp = tp;
        float palmLeaves = 100.0;
        for (float k = 0.0; k < 6.0; k++) {
            vec3 frondP = lp;
            
            float rnd1 = sin(k * 12.9898 + tp.x * 78.233) * 0.5 + 0.5;
            float rnd2 = cos(k * 45.164 + tp.z * 31.415) * 0.5 + 0.5;
            
            float ang = k * 0.785 + (rnd1 - 0.5) * 0.3 + sin(t * 2.0 + k) * 0.05;
            frondP.xz *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
            
            float pitch = 0.5 + (rnd2 - 0.5) * 0.3;
            frondP.yz *= mat2(cos(pitch), -sin(pitch), sin(pitch), cos(pitch));
            float frondLen = (0.65 + rnd1 * 0.35) * v;
            float rachis = length(frondP.xz) - (0.01 + rnd2 * 0.006) * (1.0 - frondP.y / frondLen);
            rachis = max(rachis, max(-frondP.y, frondP.y - frondLen));
            float freq = 15.0 + rnd1 * 12.0;
            float leaflets = length(vec2(abs(frondP.x) - (0.1 + rnd2 * 0.07) * sin(frondP.y * freq), frondP.z)) - (0.007 + rnd1 * 0.004);
            leaflets = max(leaflets, max(-frondP.y, frondP.y - frondLen));
            
            palmLeaves = min(palmLeaves, min(rachis, leaflets));
        }
        
        treeSDF = min(min(treeSDF, palmLeaves), ground);
        
        vec3 cp = p - vec3(0.0, 0.8, 8.0);
        cp.x += t * 0.2;
        float cloudNoise = sin(cp.x * 0.8) * cos(cp.y * 1.2) + sin(cp.x * 2.0 + cp.y * 1.5) * 0.4;
        float cloudSDF = length(cp.y - cloudNoise * 0.4) - 0.6;
        
        e = min(treeSDF, max(cloudSDF, 0.02));
        if (p.z > 3.0 && cloudSDF < 0.2) {
            v += max(0.0, 0.2 - cloudSDF) * 8.0;
        }
    }
}
