// ==== Image (image) ====
void mainImage(out vec4 O, in vec2 I) {
    vec2 uv = (I - 0.5 * iResolution.xy) / iResolution.y;
    float rayon_cam = 11.5 + 1.5 * sin(iTime * 0.1);
    float angle_cam = iTime * 0.2;
    vec3 ro = vec3(rayon_cam * sin(angle_cam), 1.5 * cos(iTime * 0.15), -rayon_cam * cos(angle_cam));
    vec3 cible = vec3(0.0, 0.0, 0.0);
    vec3 cw = normalize(cible - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(uv.x * cu + uv.y * cv + 1.5 * cw);
    float x_p = sin(iTime * 0.35) * 7.0;
    float mf = ((9.869604401089358 * x_p) / (4.0 + sqrt(34.0 + 39.47841760435743 * x_p * x_p)) / 1.5707963267948966) * 0.5 + 0.5;
    float a_k = sin(iTime * 0.2) * 2.5;
    float ang_k = (9.869604401089358 * a_k) / (4.0 + sqrt(34.0 + 39.47841760435743 * a_k * a_k));
    float c1 = cos(ang_k * 0.3), s1 = sin(ang_k * 0.3);
    float c2 = cos(ang_k * 0.2), s2 = sin(ang_k * 0.2);
    mat2 r_k1 = mat2(c1, -s1, s1, c1);
    mat2 r_k2 = mat2(c2, -s2, s2, c2);
    mat2 r_g = mat2(0.70710678118, -0.70710678118, 0.70710678118, 0.70710678118);

    vec3 couleur_fond = vec3(0.002, 0.004, 0.01);
    vec3 p_fond = rd * 12.0;
    float torsion_fond = ((9.869604401089358 * (p_fond.y * 0.08)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_fond.y * p_fond.y * 0.0064))) * 1.5;
    float sb = sin(torsion_fond + iTime * 0.04), cb = cos(torsion_fond + iTime * 0.04);
    p_fond.xz = mat2(cb, -sb, sb, cb) * p_fond.xz;
    float echelle_fond_boucle = 1.0;
    mat2 r_fond_fixe = mat2(0.93937271, -0.34289780, 0.34289780, 0.93937271);
    for(int i = 0; i < 4; i++) {
        p_fond = abs(p_fond) - vec3(1.6, 2.2, 1.9);
        p_fond.xy = r_fond_fixe * p_fond.xy;
        p_fond = p_fond * 1.38 - vec3(0.4, 0.6, 0.3);
        echelle_fond_boucle *= 1.38;
        float g = dot(sin(p_fond * 0.25), cos(p_fond.zxy * 0.25));
        couleur_fond += vec3(0.012, 0.022, 0.038) * (abs(g) / echelle_fond_boucle);
    }
    float aurore = sin(rd.x * 2.8 + iTime * 0.15) * cos(rd.y * 2.2 - iTime * 0.08);
    couleur_fond += vec3(0.95, 0.38, 0.1) * max(0.0, aurore) * 0.04;
    couleur_fond += vec3(0.03, 0.52, 0.88) * max(0.0, -aurore) * 0.04;
    vec3 l_fond = normalize(vec3(1.5, 2.5, -1.0));
    float dome = pow(max(0.0, dot(rd, l_fond)), 6.0);
    couleur_fond += vec3(0.85, 0.45, 0.25) * dome * 0.12;

    float d = 0.0;
    vec3 caracteristiques_principales = vec3(0.0);
    vec3 lueur = vec3(0.0);
    float ds = 0.0;

    for(int i = 0; i < 160; i++) {
        vec3 p = ro + rd * d;
        vec3 p_sc = p;
        float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2;
        float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf));
        p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
        vec3 p_k = p_sc;
        float s_k = 1.0;
        vec3 tr_k = vec3(0.0);
        for(int k = 0; k < 5; k++) {
            p_k = abs(p_k) - vec3(1.2, 0.9, 1.2);
            p_k.xy = r_k1 * p_k.xy;
            p_k.xz = r_k2 * p_k.xz;
            p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4);
            s_k *= 1.55;
            tr_k = max(tr_k, abs(p_k));
        }
        vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8);
        float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
        vec3 p_g = p_sc;
        float s_g = 1.0;
        float d_g = length(p_g) - 4.5;
        vec3 tr_g = vec3(0.0);
        for(int g = 0; g < 4; g++) {
            p_g.xy = r_g * p_g.xy;
            vec3 q_g = p_g * s_g;
            float gyr = (abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g;
            d_g = max(d_g, -gyr);
            tr_g = max(tr_g, abs(sin(q_g)));
            s_g *= 1.75;
        }
        float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0);
        ds = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        caracteristiques_principales = mix(tr_g, tr_k, h);

        float g1 = 0.012 / (0.015 + ds * ds);
        float g2 = 0.006 / (0.008 + abs(ds));
        lueur += vec3(0.95, 0.35, 0.1) * g1 * (0.5 + 0.5 * sin(p.z * 0.5 + iTime));
        lueur += vec3(0.05, 0.55, 0.9) * g2 * (0.5 + 0.5 * cos(p.x * 0.3 - iTime));

        if(ds < 0.0001 || d > 35.0) break;
        d += ds * 0.85;
    }

    vec3 couleur = vec3(0.002, 0.004, 0.008);

    if(d < 35.0) {
        vec3 p = ro + rd * d;
        vec2 e = vec2(0.0005, -0.0005);
        
        float d_t1; {
            vec3 p_sc = p + e.xyy;
            float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2;
            float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
            vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
            vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
            vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
            float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_t1 = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        }
        float d_t2; {
            vec3 p_sc = p + e.yyx;
            float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2;
            float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
            vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
            vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
            vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
            float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_t2 = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        }
        float d_t3; {
            vec3 p_sc = p + e.yxy;
            float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2;
            float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
            vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
            vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
            vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
            float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_t3 = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        }
        float d_t4; {
            vec3 p_sc = p + e.xxx;
            float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2;
            float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
            vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
            vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
            vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
            float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_t4 = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        }
        vec3 n = normalize(e.xyy * d_t1 + e.yyx * d_t2 + e.yxy * d_t3 + e.xxx * d_t4);

        vec3 l = normalize(vec3(1.5, 2.5, -1.0));
        vec3 v = normalize(-rd);
        vec3 h_vec = normalize(l + v);
        vec3 couleur_base = 0.5 + 0.5 * cos(vec3(0.0, 1.2, 2.4) + caracteristiques_principales * 0.12 + iTime * 0.1);
        float diff = clamp(dot(n, l), 0.0, 1.0);

        float ao = 0.0;
        float sca = 1.0;
        for(int i_ao = 0; i_ao < 5; i_ao++) {
            float hr = 0.01 + 0.14 * float(i_ao) / 4.0;
            vec3 p_ao = p + n * hr;
            float d_ao; {
                vec3 p_sc = p_ao; float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2; float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
                vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
                vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
                vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
                float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_ao = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
            }
            ao += (hr - d_ao) * sca;
            sca *= 0.9;
        }
        ao = clamp(1.0 - 3.0 * ao, 0.0, 1.0);

        float sh = 1.0;
        float t_sh = 0.04;
        for(int i_sh = 0; i_sh < 24; i_sh++) {
            vec3 p_sh = p + l * t_sh;
            float d_sh; {
                vec3 p_sc = p_sh; float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2; float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
                vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
                vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
                vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
                float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_sh = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
            }
            if(d_sh < 0.0001) { sh = 0.0; break; }
            sh = min(sh, 16.0 * d_sh / t_sh);
            t_sh += clamp(d_sh, 0.02, 0.15);
            if(t_sh > 6.0) break;
        }
        sh = clamp(sh, 0.0, 1.0);

        float spec = pow(clamp(dot(n, h_vec), 0.0, 1.0), 120.0);
        float fres = pow(1.0 - clamp(dot(v, n), 0.0, 1.0), 5.0);

        float d_sss; {
            vec3 p_sc = p + l * 0.25; float torsion = ((9.869604401089358 * (p_sc.z * 0.18)) / (4.0 + sqrt(34.0 + 39.47841760435743 * p_sc.z * p_sc.z * 0.0324))) * 1.2; float sa = sin(torsion * (1.0 - mf)), ca = cos(torsion * (1.0 - mf)); p_sc.xy = mat2(ca, -sa, sa, ca) * p_sc.xy;
            vec3 p_k = p_sc; float s_k = 1.0; for(int k = 0; k < 5; k++) { p_k = abs(p_k) - vec3(1.2, 0.9, 1.2); p_k.xy = r_k1 * p_k.xy; p_k.xz = r_k2 * p_k.xz; p_k = p_k * 1.55 - vec3(0.5, 0.7, 0.4); s_k *= 1.55; }
            vec3 q_k = abs(p_k) - vec3(1.0, 1.3, 0.8); float d_k = (length(max(q_k, 0.0)) + min(max(q_k.x, max(q_k.y, q_k.z)), 0.0)) / s_k;
            vec3 p_g = p_sc; float s_g = 1.0; float d_g = length(p_g) - 4.5; for(int g = 0; g < 4; g++) { p_g.xy = r_g * p_g.xy; vec3 q_g = p_g * s_g; d_g = max(d_g, -(abs(dot(sin(q_g), cos(q_g.zxy))) - 0.12) / s_g); s_g *= 1.75; }
            float h = clamp(0.5 + 0.5 * (d_g - d_k) / 0.3, 0.0, 1.0); d_sss = mix(d_g, d_k, h) - 0.3 * h * (1.0 - h);
        }
        float sss = clamp(1.0 - d_sss * 4.0, 0.0, 1.0);

        couleur = couleur_base * diff * sh * ao;
        couleur += vec3(1.0, 0.95, 0.85) * spec * sh * ao * 1.8;
        couleur += couleur_base * fres * ao * 0.7;
        couleur += vec3(0.9, 0.2, 0.05) * sss * ao * 0.35;
        couleur += vec3(0.02, 0.05, 0.1) * clamp(0.5 + 0.5 * n.y, 0.0, 1.0) * ao;
    } else {
        couleur = couleur_fond;
    }

    couleur += lueur * 0.025;
    couleur = mix(couleur, couleur_fond, 1.0 - exp(-0.003 * d * d));

    couleur *= 1.4;
    couleur = clamp((couleur * (2.51 * couleur + 0.03)) / (couleur * (2.43 * couleur + 0.59) + 0.14), 0.0, 1.0);
    couleur = pow(couleur, vec3(0.4545));

    O = vec4(couleur, 1.0);
}
