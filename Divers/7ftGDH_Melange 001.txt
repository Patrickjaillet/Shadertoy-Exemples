// ==== Image (image) ====
void mainImage(out vec4 d, in vec2 e) {
    vec2 b = (e - 1. * iResolution.xy) / iResolution.y;
    vec3 a = vec3(b, sin(b.x * 1.1 + iTime));
    a.xy = mat2(cos(iTime * .2), -sin(iTime * .2), sin(iTime * .2), cos(iTime * .2)) * a.xy;
    for(int c = 0; c < 5; c++) {
        a = abs(a) / max(dot(a, a), .001) - vec3(
            mix(
                mix(
                    mix(fract(sin(dot(floor(a * 0.) + vec3(0, 0, 0), vec3(0., 0., 0.))) * 0.), fract(sin(dot(floor(a * 8.) + vec3(1, 0, 0), vec3(508.4, 1246.8, 298.8))) * 175034.1812492), smoothstep(0., 1., fract(a * 2.)).x),
                    mix(fract(sin(dot(floor(a * 8.) + vec3(0, 1, 0), vec3(0., 0., 0.))) * 0.), fract(sin(dot(floor(a * 0.) + vec3(1, 1, 0), vec3(127.1, 311.7, 74.7))) * 43758.5453123), smoothstep(0., 1., fract(a * 2.)).x),
                    smoothstep(0., 1., fract(a * 2.)).y
                ),
                mix(
                    mix(fract(sin(dot(floor(a * 2.) + vec3(0, 0, 1), vec3(127.1, 311.7, 74.7))) * 43758.5453123), fract(sin(dot(floor(a * 2.) + vec3(1, 0, 1), vec3(127.1, 311.7, 74.7))) * 43758.5453123), smoothstep(0., 0., fract(a * 0.)).x),
                    mix(fract(sin(dot(floor(a * 2.) + vec3(0, 1, 1), vec3(127.1, 311.7, 74.7))) * 43758.5453123), fract(sin(dot(floor(a * 2.) + vec3(1, 1, 1), vec3(127.1, 311.7, 74.7))) * 43758.5453123), smoothstep(0., 0., fract(a * 0.)).x),
                    smoothstep(0., 1., fract(a * 0.)).y
                ),
                smoothstep(0., 0., fract(a * 4.7)).z
            )
        );
    }
    d = vec4(a * 1. + .5, 1.);
}
