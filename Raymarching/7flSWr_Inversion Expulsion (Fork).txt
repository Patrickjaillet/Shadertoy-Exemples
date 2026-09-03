// ==== Image (image) ====
//======================================================================================//
//  >>  Original: Diatribes * https://www.shadertoy.com/user/diatribes                  //
//  >>  Fork    : Sandefjord                                                            //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//

#define R iResolution.xy

vec3 aces(vec3 x) {
    float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / R;
    vec2 p = (2.0 * fragCoord - R) / R.y;
    vec4 raw = texture(iChannel0, uv);
    vec4 col = mix(raw.zyxw, raw, smoothstep(0.2, 1.0, length(p) / 2.25));
    vec3 finalCol = (col.rgb * col.rgb) / (40.0 * 4e7 * length(p));
    finalCol = tanh(finalCol);
    finalCol = aces(finalCol * 1.2);
    finalCol = pow(finalCol, vec3(1.0 / 2.2));
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    finalCol += (dither - 0.5) * 0.005;
    fragColor = vec4(finalCol, 1.0);
}

// ==== Buffer A (buffer) ====
//======================================================================================//
//  >>  Original: Diatribes * https://www.shadertoy.com/user/diatribes                  //
//  >>  Fork    : Sandefjord                                                            //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://0110110101110011.netlify.app                                  //
//*====================================================================================*//
#define SAMPLES 4.0
#define R iResolution.xy

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float map(vec3 p) {
    p.z -= 40.0;
    p = p * 900.0 / dot(p, p);
    float s;
    for(s = 0.01; s < 2.0; s += s) {
        p.z -= abs(dot(sin(p.z + iTime + p / s), vec3(s + s)));
    }
    p.xy /= 4.0;
    return 0.05 + 0.5 * abs(length(p) - 7.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 col = vec4(0);
    for(float m = 0.0; m < SAMPLES; m++) {
        vec2 seed = fragCoord + m * 13.123;
        vec2 jitter = vec2(fract(sin(seed.x) * 43758.5), fract(sin(seed.y) * 22578.1)) - 0.5;
        vec2 uv = (2.0 * (fragCoord + jitter) - R) / R.y;
        vec3 rd = normalize(vec3(uv, 0.5));
        mat2 r = mat2(cos(iTime/4. + vec4(0, 33, 11, 0)));
        rd.xz *= r;
        rd.yz *= r;
        float d = 0.0, s = 0.0;
        for(float i = 0.0; i < 100.0; i++) {
            vec3 p = rd * d;
            s = map(p);
            d += s;
            col += vec4(3.8, 1.8, 1.0, 0.0) / s * d + 10.0 * (1.0 + cos(i * 0.4 + vec4(2, 1, 0, 0))) / s;
            if(d > 100.0) break;
        }
    }
    fragColor = col / SAMPLES;
}
