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
void mainImage(out vec4 B, in vec2 C) {
    vec3 q = vec3(0.);
    const int n = 8;
    float D = .015;

    for(int p = 0; p < n; p++) {
        float s = (float(p) / float(n) - .5);
        float t = (iTime + s * D) * 1.5;
        float E = 1. + s * .08;

        vec2 uv = (C - .5 * iResolution.xy) / iResolution.y;

        vec3 ro = vec3(0., 0., -2.0);
        vec3 rd = normalize(vec3(uv * E, 1.0));

        float pitch = sin(t * 0.2) * 0.4;
        float yaw = cos(t * 0.15) * 0.4;
        mat2 rotX = mat2(cos(pitch), -sin(pitch), sin(pitch), cos(pitch));
        mat2 rotY = mat2(cos(yaw), -sin(yaw), sin(yaw), cos(yaw));
        rd.yz *= rotX;
        rd.xz *= rotY;

        vec3 u = vec3(0.);

        for(float c = 1.; c <= 6.; c++) {
            float zPlane = c * 0.8;
            vec2 F = rd.xy * (zPlane / max(rd.z, 0.01));

            vec2 a = F * (1.5 + c * .3);
            a = abs(a);
            if(a.x < a.y) a = a.yx;
            a = a * 1.5 - vec2(.6, .4);

            float v = cos(t * .3 + c), w = sin(t * .3 + c);
            a = vec2(a.x * v - a.y * w, a.x * w + a.y * v);
            a = abs(a);
            if(a.x < a.y) a = a.yx;
            a = a * 1.3 - vec2(.3, .5);

            vec2 i = floor(a + vec2(t * .4 + c, c * 10.)), e = fract(a + vec2(t * .4 + c, c * 10.));
            e = e * e * (3. - 2. * e);
            float G = fract(sin(dot(i, vec2(127.1, 311.7))) * 4.3758547e4);
            float H = fract(sin(dot(i + vec2(1., 0.), vec2(127.1, 311.7))) * 4.3758547e4);
            float I = fract(sin(dot(i + vec2(0., 1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float J = fract(sin(dot(i + vec2(1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float K = mix(mix(G, H, e.x), mix(I, J, e.x), e.y) - .5;

            vec2 j = floor(a + vec2(c * 5., t * .3 + c)), g = fract(a + vec2(c * 5., t * .3 + c));
            g = g * g * (3. - 2. * g);
            float L = fract(sin(dot(j, vec2(127.1, 311.7))) * 4.3758547e4);
            float M = fract(sin(dot(j + vec2(1., 0.), vec2(127.1, 311.7))) * 4.3758547e4);
            float N = fract(sin(dot(j + vec2(0., 1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float O = fract(sin(dot(j + vec2(1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float P = mix(mix(L, M, g.x), mix(N, O, g.x), g.y) - .5;

            float k = abs(a.y + K * .8) * abs(a.x + P * .8);
            k = pow(k, .6);

            vec2 z = a * 3. + t, l = floor(z), h = fract(z);
            h = h * h * (3. - 2. * h);
            float Q = fract(sin(dot(l, vec2(127.1, 311.7))) * 4.3758547e4);
            float R = fract(sin(dot(l + vec2(1., 0.), vec2(127.1, 311.7))) * 4.3758547e4);
            float S = fract(sin(dot(l + vec2(0., 1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float T = fract(sin(dot(l + vec2(1.), vec2(127.1, 311.7))) * 4.3758547e4);
            float U = mix(mix(Q, R, h.x), mix(S, T, h.x), h.y);

            float A = smoothstep(.4, 0., abs(sin(t * 2. + c * 1.5 + U * 4.)));
            
            float dof = abs(zPlane - 2.2) * 0.01;
            float V = (.025 / (k + .001 + dof)) * A;
            float W = (.060 / (k + .02 + dof)) * A;

            vec3 X = .6 + .4 * cos(vec3(0., 2., 4.) + c * 1.2 + t);

            float fog = exp(-zPlane * 0.15);
            u += X * (V + W) * fog;
        }
        q += u;
    }

    vec3 d = q / float(n);
    d += vec3(1.) * pow(clamp(d.r * .4, 0., 1.), 2.0);
    vec3 Y = max(d - vec3(.2), vec3(0.));
    d += Y * 2.2;
    d /= (1. + d * .1);

    B = vec4(d, 1.);
}
