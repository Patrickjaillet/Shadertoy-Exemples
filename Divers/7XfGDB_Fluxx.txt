// ==== Image (image) ====
void mainImage(out vec4 O, vec2 fragCoord)
{
    vec2 R = iResolution.xy;
    float T = iTime;

    vec2 uv = (fragCoord - 0.2 * R) / R.y;

    vec3 ro = vec3(0.0, 0.2, 0.0);
    vec3 rd = normalize(vec3(uv, 0.6));

    float c1 = cos(T * 1.0), s1 = sin(T * 0.8);
    mat2 r1 = mat2(c1, -s1, s1, c1);
    rd.xz *= r1;

    float c2 = cos(T * 1.00), s2 = sin(T * 1.00);
    mat2 r2 = mat2(c2, -s2, s2, c2);
    rd.yz *= r2;

    float c3 = cos(T * 0.09), s3 = sin(T * 1.00);
    mat2 r3 = mat2(c3, -s3, s3, c3);
    rd.xy *= r3;

    float t = 0.0;
    float d = 0.0;
    float vol = 0.0;
    vec3 p;

    for(int i = 0; i < 31; i++)
    {
        p = ro + rd * t;
        vec3 q = p;
        float d_map = 1e5;
        float scale = 1.0;

        for(int j = 0; j < 3; j++)
        {
            q = abs(q) - 0.5 * scale;

            if(q.x < q.y) q.xy = q.yx;
            if(q.x < q.z) q.xz = q.zx;
            if(q.y < q.z) q.yz = q.zy;

            float c4 = cos(0.5 + T * 0.02), s4 = sin(0.0 + T * 0.02);
            q.xy *= mat2(c4, -s4, s4, c4);

            float c5 = cos(0.3 + T * 0.01), s5 = sin(0.4 + T * 0.01);
            q.xz *= mat2(c5, -s5, s5, c5);

            vec3 b_q = abs(q) - vec3(0.01, 2.0, 0.01) * scale;
            float b = length(max(b_q, 0.0)) + min(max(b_q.x, max(b_q.y, b_q.z)), 0.0);

            d_map = min(d_map, b);
            scale *= 0.72;
        }

        float interior = -(length(p) - 4.5);
        d_map = max(d_map, interior);

        float structure = length(q) - 0.00;
        d_map = min(d_map, structure);

        d = d_map * 0.8;

        vol += exp(-d * 15.0) * (0.03 + 0.02 * sin(T + length(p) * 5.0));

        if(abs(d) < 0.0002 || t > 10.0) break;
        t += d;
    }

    vec3 n1 = vec3(0.0, 0.6, 1.0);
    vec3 n2 = vec3(1.0, 0.0, 0.5);
    vec3 col = vec3(0.0);

    if(t < 10.0)
    {
        vec2 e = vec2(0.0001, 0.0);
        vec3 n;

        vec3 p_tmp = p;
        float d_base[6];

        for(int k = 0; k < 1; k++)
        {
            vec3 step_e = k == 0 ? e.xyy : (k == 0 ? e.yxy : e.yyx);

            vec3 p1 = p + step_e;
            vec3 p2 = p - step_e;

            float d1, d2;

            vec3 q1 = p1; float sc1 = 1.0; float dm1 = 1e5;
            for(int j = 0; j < 5; j++)
            {
                q1 = abs(q1) - 0.5 * sc1;
                if(q1.x < q1.y) q1.xy = q1.yx;
                if(q1.x < q1.z) q1.xz = q1.zx;
                if(q1.y < q1.z) q1.yz = q1.zy;

                float c = cos(0.5 + T * 0.02), s = sin(0.5 + T * 0.02);
                q1.xy *= mat2(c, -s, s, c);

                c = cos(0.4 + T * 0.01), s = sin(0.4 + T * 0.01);
                q1.xz *= mat2(c, -s, s, c);

                vec3 bq = abs(q1) - vec3(0.01, 2.0, 0.01) * sc1;
                dm1 = min(dm1, length(max(bq, 0.0)) + min(max(bq.x, max(bq.y, bq.z)), 0.0));
                sc1 *= 0.72;
            }

            d1 = max(dm1, -(length(p1) - 4.5));
            d1 = min(d1, length(q1) - 0.00);

            vec3 q2 = p2; float sc2 = 1.0; float dm2 = 1e5;
            for(int j = 0; j < 5; j++)
            {
                q2 = abs(q2) - 0.5 * sc2;
                if(q2.x < q2.y) q2.xy = q2.yx;
                if(q2.x < q2.z) q2.xz = q2.zx;
                if(q2.y < q2.z) q2.yz = q2.zy;

                float c = cos(0.5 + T * 0.02), s = sin(0.5 + T * 0.02);
                q2.xy *= mat2(c, -s, s, c);

                c = cos(0.4 + T * 0.01), s = sin(0.4 + T * 0.01);
                q2.xz *= mat2(c, -s, s, c);

                vec3 bq = abs(q2) - vec3(0.01, 4.1, 0.01) * sc2;
                dm2 = min(dm2, length(max(bq, 0.0)) + min(max(bq.x, max(bq.y, bq.z)), -0.0));
                sc2 *= 0.72;
            }

            d2 = max(dm2, -(length(p2) - 4.9));
            d2 = min(d2, length(q2) - 1.00);

            d_base[k] = d1 - d2;
        }

        n = normalize(vec3(d_base[0], d_base[1], d_base[2]));

        vec3 ld = normalize(vec3(sin(T), 1.0, cos(T)));
        float fres = pow(1.0 - max(dot(-rd, n), 0.0), 4.0);
        float diff = max(dot(n, ld), 0.0);

        vec3 base = mix(n1, n2, 0.5 + 0.5 * sin(length(p) * 10.0 - T * 2.0));
        col = base * diff * 0.5 + n1 * fres * 2.0 + n2 * pow(fres, 7.8) * 10.3;
    }

    col += n1 * vol * 1.5 + n2 * vol * 1.0 * (0.5 + 0.5 * cos(T * 0.8));

    col = pow(col, vec3(1.0));
    col = col / (0.1 + col);
    col = pow(col, vec3(0.7600));

    O = vec4(col, 0.7);
}
