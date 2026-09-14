// ==== Image (image) ====
float h12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float digit(int n, vec2 p) {
    if (p.x < 0.0 || p.x > 3.0 || p.y < 0.0 || p.y > 5.0) return 0.0;
    ivec2 ip = ivec2(p);
    int b = (4 - ip.y) * 3 + ip.x;
    int m = 0;
    if (n == 1) m = 18724;
    else if (n == 4) m = 23586;
    return float((m >> b) & 1);
}

vec3 palette(int idx) {
    if (idx == 0) return vec3(0.08, 0.01, 0.01);
    if (idx == 1) return vec3(0.22, 0.04, 0.02);
    if (idx == 2) return vec3(0.42, 0.10, 0.03);
    if (idx == 3) return vec3(0.62, 0.20, 0.05);
    if (idx == 4) return vec3(0.82, 0.38, 0.10);
    if (idx == 5) return vec3(0.95, 0.58, 0.25);
    if (idx == 6) return vec3(0.98, 0.78, 0.42);
    if (idx == 7) return vec3(0.12, 0.32, 0.52);
    if (idx == 8) return vec3(0.28, 0.58, 0.82);
    if (idx == 9) return vec3(0.18, 0.82, 0.32);
    if (idx == 10) return vec3(0.88, 0.18, 0.12);
    if (idx == 11) return vec3(0.92, 0.92, 0.96);
    if (idx == 12) return vec3(0.48, 0.50, 0.56);
    return vec3(0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = vec2(320.0, 200.0);
    vec2 p = floor(fragCoord.xy / iResolution.xy * res);

    vec3 col = mix(palette(3), palette(5), clamp(p.y / 180.0, 0.0, 1.0));
    if (mod(p.y, 2.0) < 1.0) col *= 0.92;

    float farH = 45.0 + floor(sin(floor(p.x / 8.0) * 12.3) * 15.0);
    if (p.y < farH) {
        col = palette(2);
        if (mod(p.x, 2.0) < 1.0 && mod(p.y, 3.0) < 1.0 && h12(floor(p / vec2(2.0, 3.0))) > 0.4) {
            col = palette(5);
        }
    }

    float midBld = floor(p.x / 24.0);
    float midH = 65.0 + floor(h12(vec2(midBld, 3.14)) * 75.0);
    float inBldX = mod(p.x, 24.0);
    if (p.y < midH && inBldX > 0.0 && inBldX < 23.0) {
        col = (inBldX > 12.0) ? palette(1) : palette(2);
        if (mod(p.x, 3.0) < 1.0 && mod(p.y, 5.0) < 2.0) {
            if (h12(floor(p / vec2(3.0, 5.0))) > 0.35) {
                col = palette(4);
            }
        }
    }

    if (p.x > 220.0 && p.x < 315.0 && p.y < 85.0) {
        col = palette(1);
        if (p.y < 55.0) {
            col = (p.x > 265.0) ? palette(0) : palette(1);
            if (mod(p.x, 3.0) < 1.0 && mod(p.y, 4.0) < 2.0) {
                col = palette(4);
            }
        }
        if (p.y >= 55.0 && p.y <= 68.0) {
            vec2 hp = p - vec2(265.0, 61.0);
            if (abs(hp.x) < 30.0 && abs(hp.y) < 6.0) {
                col = palette(2);
                float r = length(hp * vec2(1.0, 2.2));
                if (abs(r - 10.0) < 1.2 || (abs(hp.x) < 2.0 && abs(hp.y) < 4.0) || (abs(hp.x) < 5.0 && abs(hp.y) < 1.2)) {
                    col = palette(5);
                }
            }
        }
    }

    if (p.x > 130.0 && p.x < 200.0 && p.y < 165.0) {
        col = (p.x > 165.0) ? palette(0) : palette(1);
        if (mod(p.x, 3.0) < 1.0 && mod(p.y, 4.0) < 2.0) {
            col = palette(3);
        }
    }

    if (p.x > 80.0 && p.x < 145.0 && p.y < 200.0) {
        col = (p.x > 110.0) ? palette(0) : palette(1);
        if (mod(p.x, 2.0) < 1.0) col *= 1.15;
        if (mod(p.y, 2.0) < 1.0) col *= 0.85;
    }

    if (abs(p.x - 104.0) < 1.0 || abs(p.x - 216.0) < 1.0) {
        col = palette(8);
    }

    vec2 plat = p - vec2(100.0, 42.0);
    if (plat.x >= 0.0 && plat.x <= 120.0) {
        if (plat.y >= 0.0 && plat.y <= 3.0) {
            col = palette(6);
        }
        if ((plat.y >= 3.0 && plat.y <= 22.0) && (plat.x <= 2.0 || plat.x >= 118.0 || abs(plat.x - 60.0) <= 1.0)) {
            col = palette(8);
        }
        if ((abs(plat.y - 12.0) <= 1.0 || abs(plat.y - 22.0) <= 1.0) && plat.y <= 22.0) {
            col = palette(8);
        }
        if (plat.x >= 12.0 && plat.x <= 26.0 && plat.y >= 4.0 && plat.y <= 10.0) {
            col = palette(12);
            if (plat.x >= 14.0 && plat.x <= 17.0 && plat.y >= 7.0) col = palette(10);
            if (plat.x >= 20.0 && plat.x <= 23.0 && plat.y >= 7.0) col = palette(9);
        }
        if (plat.x >= 92.0 && plat.x <= 112.0 && plat.y >= 4.0 && plat.y <= 16.0) {
            col = palette(11);
            if (plat.x >= 94.0 && plat.x <= 110.0 && plat.y >= 6.0 && plat.y <= 14.0) {
                col = palette(7);
                float d1 = digit(1, plat - vec2(96.0, 7.0));
                float d2 = digit(4, plat - vec2(102.0, 7.0));
                if (d1 + d2 > 0.5) col = palette(9);
            }
        }
        if (plat.x >= 54.0 && plat.x <= 66.0 && plat.y >= 3.0 && plat.y <= 28.0) {
            vec2 cp = plat - vec2(60.0, 3.0);
            if (cp.y >= 0.0 && cp.y <= 6.0 && abs(cp.x) <= 3.0) col = palette(7);
            if (cp.y >= 6.0 && cp.y <= 18.0 && abs(cp.x) <= 2.0) col = palette(11);
            if (cp.y >= 18.0 && cp.y <= 22.0 && abs(cp.x) <= 4.0) col = palette(11);
            if (cp.y >= 22.0 && cp.y <= 26.0 && abs(cp.x) <= 3.0) col = palette(11);
        }
        if (plat.x >= 68.0 && plat.x <= 76.0 && plat.y >= -4.0 && plat.y <= 3.0) {
            col = palette(11);
            if (plat.y < 0.0 && mod(plat.x + plat.y, 2.0) < 1.0) col = palette(8);
        }
    }

    vec2 grid = mod(p, vec2(32.0, 32.0));
    if (grid.x < 2.0 || grid.y < 2.0) {
        col *= 0.25;
    }

    fragColor = vec4(col, 1.0);
}
