// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 col = vec3(0.1);
    float g = 0.0;
    float t = iTime;
    float stepSize = 1.0 / 30000.0;

    for (int i = 1; i <= 87; i++) {
        vec2 uv = (fragCoord - 0.6 * iResolution.xy) / iResolution.y;
        vec3 p = vec3(uv * g, 1.1 * g) - float(i) * stepSize;

        float c1 = cos(t / 1.5);
        float s1 = sin(t / 2.2);
        p.yz = mat2(c1, -s1, s1, c1) * p.yz;

        p.x += t / (0.6 * 3.14159265);
        p = mod(p, 2.0) - 1.0;
        vec3 z = p;

        float power = 32.0;
        float bailout = 2.6;
        int maxIter = 3;
        float dr = 1.0;

        for (int j = 0; j < maxIter; j++) {
            float r = length(z);
            if (r > bailout) break;

            dr = power * pow(r, power - 1.0) * dr + 1.0;

            float theta = acos(z.z / r);
            float phi = atan(z.y, z.x);
            float rp = pow(r, power);
            float thetap = theta * power;
            float phip = phi * power;
            vec3 zp = rp * vec3(
                sin(thetap) * cos(phip),
                sin(thetap) * sin(phip),
                cos(thetap)
            );
            z = zp + p;
        }

        float R = length(z);
        float e = 0.3 * log(R) * R / dr;
        g += e;
        col += 0.005 / exp(e * e * 2e7 - sin(R / vec3(3.0, 6.1, 5.0)));
    }

    fragColor = vec4(col, 0.0);
}
