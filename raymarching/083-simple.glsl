// ==== Image (image) ====
void mainImage(out vec4 N, in vec2 O) {
    vec2 uv = (O - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(2.8 * cos(iTime * 0.3), 1.5 + 0.8 * sin(iTime * 0.2), 2.8 * sin(iTime * 0.3));
    vec3 ww = normalize(-ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = cross(uu, ww);
    vec3 rd = normalize(uv.x * uu + uv.y * vv + 1.2 * ww);

    float morphCycle = iTime * 0.25;
    float curId = floor(morphCycle);
    float morphPhase = smoothstep(0.15, 0.85, fract(morphCycle));
    int idA = int(mod(curId, 4.0));
    int idB = int(mod(curId + 1.0, 4.0));

    vec3 off[4];
    off[0] = vec3(1.2, 1.2, 1.2);
    off[1] = vec3(1.5, 1.5, 1.5);
    off[2] = vec3(1.0, 1.3, 1.0);
    off[3] = vec3(1.4, 0.8, 1.4);
    
    float scl[4];
    scl[0] = 2.0;
    scl[1] = 2.2;
    scl[2] = 2.0;
    scl[3] = 2.4;

    vec3 curOff = mix(off[idA], off[idB], morphPhase);
    float curScl = mix(scl[idA], scl[idB], morphPhase);

    float t = 0.0;
    float max_t = 20.0;
    float d = 0.0;
    float glow = 0.0;
    
    float a1 = iTime * 0.35;
    float a2 = iTime * 0.45;
    mat2 m1 = mat2(cos(a1), -sin(a1), sin(a1), cos(a1));
    mat2 m2 = mat2(cos(a2), -sin(a2), sin(a2), cos(a2));

    for(int i = 0; i < 150; i++) {
        vec3 q = ro + t * rd;
        q.xz = m1 * q.xz;
        q.yz = m2 * q.yz;
        
        vec3 p = q;
        float s = 1.0;
        for(int k = 0; k < 6; k++) {
            p = abs(p);
            if(p.x < p.y) p.xy = p.yx;
            if(p.x < p.z) p.xz = p.zx;
            if(p.y < p.z) p.yz = p.zy;
            
            p = p * curScl - curOff * (curScl - 1.0);
            s *= curScl;
        }
        d = (length(p) - 0.8) / s;
        
        glow += 0.004 / (0.01 + d * d);
        
        if(d < 0.001 || t > max_t) break;
        t += d * 0.6;
    }

    vec3 col = vec3(0.01, 0.015, 0.02) * (1.0 - length(uv) * 0.5);
    col += vec3(0.98, 0.4, 0.15) * glow * 0.03;
    
    vec3 bg_p = rd * 15.0;
    float stars = pow(clamp(sin(bg_p.x * 25.0) * sin(bg_p.y * 25.0) * sin(bg_p.z * 25.0), 0.0, 1.0), 45.0);
    col += vec3(0.9, 0.95, 1.0) * stars * clamp(1.0 - (t / max_t), 0.0, 1.0) * 1.5;

    if(t < max_t) {
        vec3 q = ro + t * rd;
        q.xz = m1 * q.xz;
        q.yz = m2 * q.yz;

        vec3 n_q = vec3(0.0);
        vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.002;
        for(int j = 0; j < 4; j++) {
            vec3 e_vec = j==0 ? e.xyy : j==1 ? e.yyx : j==2 ? e.yxy : e.xxx;
            vec3 p_in = q + e_vec;
            
            float s = 1.0;
            for(int k = 0; k < 6; k++) {
                p_in = abs(p_in);
                if(p_in.x < p_in.y) p_in.xy = p_in.yx;
                if(p_in.x < p_in.z) p_in.xz = p_in.zx;
                if(p_in.y < p_in.z) p_in.yz = p_in.zy;
                
                p_in = p_in * curScl - curOff * (curScl - 1.0);
                s *= curScl;
            }
            float d_n = (length(p_in) - 0.8) / s;
            n_q += e_vec * d_n;
        }
        n_q = normalize(n_q);
        
        vec3 nor = n_q;
        nor.yz = mat2(cos(a2), sin(a2), -sin(a2), cos(a2)) * nor.yz;
        nor.xz = mat2(cos(a1), sin(a1), -sin(a1), cos(a1)) * nor.xz;

        vec3 abs_n = abs(n_q);
        vec2 faceUV = abs_n.x > abs_n.y && abs_n.x > abs_n.z ? q.yz : 
                      abs_n.y > abs_n.x && abs_n.y > abs_n.z ? q.xz : q.xy;

        vec3 fId = step(abs_n.yzx, abs_n) * step(abs_n.zxy, abs_n) * sign(n_q);
        float fVal = dot(fId, vec3(1.1, 2.3, 3.7));

        vec2 c2 = faceUV * 1.5;
        float j2 = dot(c2, c2);
        float d2 = iTime * 0.35;
        vec2 e2_vec = vec2(0.0);
        float k2 = 0.7, i2 = 0.7;
        mat2 l2 = mat2(0.540302, -0.841470, 0.841470, 0.540302);
        
        for(int g = 0; g < 13; g++) {
            c2 = l2 * c2;
            e2_vec = l2 * e2_vec;
            vec2 a_uv = c2 * i2 + e2_vec + vec2(d2 * 0.7, d2 * 0.2 + float(g) * 0.73);
            float m2_val = sin(a_uv.x * 1.4 + d2) + cos(a_uv.y * 3.6 - j2 * 4.0);
            e2_vec += vec2(cos(a_uv.y + m2_val - d2), sin(a_uv.x - m2_val + d2)) * 0.63;
            k2 += (dot(cos(a_uv), sin(a_uv.yx)) + 0.5) / i2;
            i2 *= 1.19;
        }
        
        float h2 = k2 * 0.4;
        vec3 c1 = 0.5 + 0.5 * cos(fVal * 1.5 + vec3(0.0, 2.0, 4.0));
        vec3 c3 = 0.5 + 0.5 * cos(fVal * 1.5 + vec3(1.0, 3.0, 5.0));
        vec3 c4 = 0.5 + 0.5 * cos(fVal * 1.5 + vec3(2.0, 4.0, 6.0));

        vec3 texCol = c1 * (cos(h2 * 2.5 + 1.57) * 0.5 + 0.5) + 
                      c3 * (sin(h2 * 12.0) + 0.9) + 
                      c4 * (cos(h2 * 1.5 + 4.71) * 0.5 + 0.5);
                      
        texCol *= exp(-j2 * 1.1);
        texCol = clamp(texCol, 0.0, 1.0);

        vec3 lig = normalize(vec3(0.7, 1.0, -0.8));
        float dif = max(dot(nor, lig), 0.0);
        vec3 ref = reflect(rd, nor);
        float spe = pow(max(dot(ref, lig), 0.0), 48.0);
        float fre = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 3.0);

        col = texCol * 2.0; 
        col += texCol * dif * 0.6;
        col += vec3(1.0, 0.95, 0.9) * spe * 1.5; 
        col += texCol * fre * 2.5; 
        col *= clamp(1.2 - length(faceUV) * 0.5, 0.0, 1.0); 
    }

    col = col / (1.0 + col);
    col = pow(col, vec3(0.4545));
    
    N = vec4(col, 1.0);
}
/***********************************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____                       *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \                      *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |                     *
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |                     *
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/                      *
*            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]                                 *
************************************************************************************
* - Software:       https://patrickjaillet.github.io/sandefjord-software           *
* - Social Network: https://x.com/JailletPatrick                                   *
* - Music:          https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g       *
************************************************************************************
*           Software used for GLSL shader creation:                                *
*                ******************************                                    *
* GLSL shader design and value tweaking                                            *
* - Sliders-GL v1.0.1:                                                             *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl *
*                                                                                  *
* 100% safe Code Golfing                                                           *
* - µShader v3.0.1:                                                                *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader*
*                                                                                  *
* Formatting & Layout                                                              *
* - ShaderFmt v1.0.0:                                                              *
* https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt  *
***********************************************************************************/
