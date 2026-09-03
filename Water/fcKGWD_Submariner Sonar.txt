// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 R = iResolution.xy, uv = fragCoord / R, crt = uv - .5;
    crt *= 1. + .15 * dot(crt, crt) + .05 * pow(dot(crt, crt), 2.);
    vec2 p = crt * vec2(R.x / R.y, 1.);
    
    float d = length(p), a = atan(p.y, p.x), t = iTime * 1.5,
          beam = mod(t, 6.283185) - 3.141592,
          diff = mod(a - beam + 3.141592, 6.283185) - 3.141592,
          fade = exp(-1.1 * mod(-diff, 6.283185)),
          sweepLine = smoothstep(.015, 0., abs(diff)),
          
          noise = mix(mix(fract(sin(dot(floor(p * 12.), vec2(12.9898, 78.233))) * 43758.5453),
                          fract(sin(dot(floor(p * 12.) + vec2(1, 0), vec2(12.9898, 78.233))) * 43758.5453),
                          smoothstep(0., 1., fract(p * 12.)).x),
                      mix(fract(sin(dot(floor(p * 12.) + vec2(0, 1), vec2(12.9898, 78.233))) * 43758.5453),
                          fract(sin(dot(floor(p * 12.) + 1., vec2(12.9898, 78.233))) * 43758.5453),
                          smoothstep(0., 1., fract(p * 12.)).x),
                      smoothstep(0., 1., fract(p * 12.)).y),
                      
          grid = clamp(smoothstep(.05, 0., abs(fract(d * 12.) - .5)) +
                       smoothstep(.003, 0., abs(p.x)) + smoothstep(.003, 0., abs(p.y)) +
                       smoothstep(.003, 0., abs(mod(a + .392699, .785398) - .392699)) * smoothstep(.1, .4, d), 0., 1.);

    vec3 texColor = texture(iChannel0, uv).rgb,
         sonarCol = vec3(0, .1 + smoothstep(.6, 1., noise) * .2, .02) * fade
                  + vec3(.05, .3, .1) * grid * (.2 + .8 * fade)
                  + vec3(.5, 1, .6) * sweepLine * 1.5;

    vec2 p1 = vec2(.25 * cos(iTime * .2), .25 * sin(iTime * .3)),
         p2 = vec2(.35 * cos(iTime * .1 + 2.), .15 * sin(iTime * .15 - 1.)),
         p3 = vec2(.15 * cos(iTime * -.15), .3 * sin(iTime * -.05 + 4.));

    float a1 = mod(atan(p1.y, p1.x) - beam + 3.141592, 6.283185) - 3.141592,
          a2 = mod(atan(p2.y, p2.x) - beam + 3.141592, 6.283185) - 3.141592,
          a3 = mod(atan(p3.y, p3.x) - beam + 3.141592, 6.283185) - 3.141592;

    sonarCol += vec3(.8, 1, .8) * (smoothstep(.015, 0., length(p - p1)) + smoothstep(.04, 0., length(p - p1)) * .5) * exp(-1.2 * mod(-a1, 6.283185)) * 2.
              + vec3(.8, 1, .8) * (smoothstep(.01, 0., length(p - p2)) + smoothstep(.03, 0., length(p - p2)) * .5) * exp(-1.2 * mod(-a2, 6.283185)) * 2.
              + vec3(.8, 1, .8) * (smoothstep(.008, 0., length(p - p3)) + smoothstep(.02, 0., length(p - p3)) * .5) * exp(-1.2 * mod(-a3, 6.283185)) * 2.;

    sonarCol *= (.85 + .15 * (.5 + .5 * sin(uv.y * R.y * 2.))) * smoothstep(1.5, .3, length(crt));
    sonarCol += vec3(.01, .06, .02) * fract(sin(dot(uv, vec2(12.9898, 78.233)) + iTime) * 43758.5453);
    sonarCol.rb += vec2(fract(sin(dot(uv + vec2(.005, 0), vec2(12.9898, 78.233)) + iTime) * 43758.5453),
                        fract(sin(dot(uv - vec2(.005, 0), vec2(12.9898, 78.233)) + iTime) * 43758.5453)) * .015;

    vec3 finalBg = texColor * smoothstep(1.2, .2, length(uv - .5)) * (.3 + .7 * smoothstep(.45, .6, d)),
         bezelColor = texColor * .2 + vec3(.15) * smoothstep(.48, .46, d) * smoothstep(.44, .46, d);

    fragColor = vec4(mix(mix(finalBg, bezelColor, smoothstep(.52, .5, d) * smoothstep(.44, .46, d)), sonarCol, smoothstep(.455, .445, d)), 1.);
}
/*%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£%*
ù  ____    _    _   _ ____  _____ _____   _  ___  ____  ____   ù
ù / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \  ù
ù \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | | ù
ù  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| | ù
ù |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/  ù
ù            PATRICK JAILLET-VAN DEN BEEMT [PJVDB]             ù
ù**************************************************************ùùùùùùùùùùùùùùùù
ù - Logiciels:     https://patrickjaillet.github.io/sandefjord-software       ù
ù - réseau social: https://x.com/JailletPatrick                               ù
ù - Musiques:      https://www.youtube.com/channel/UCKcQ3eeBWioM-tE2TBWsL_g   ù
ù**************************************************************ùùùùùùùùùùùùùùùù
ù Logiciels utilisés pour la création de shaders GLSL:         ù
ù                -----------------------------                 ù
ù Conception de shaders GLSL et modification des valeurs       ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ù - Sliders-GL v1.0.1: https://patrickjaillet.github.io/sandefjord-software/software.html?id=sliders-gl ù
ù Golfing Code 100% safe                                                                                ù
ù - µShader v3.0.1: https://patrickjaillet.github.io/sandefjord-software/software.html?id=microshader   ù
ù Formatage & Mise en page                                                                              ù
ù - ShaderFmt v1.0.0: https://patrickjaillet.github.io/sandefjord-software/software.html?id=shaderfmt   ù
$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*£*ù£%*^¨*£$*¨^£%^%*£$^%ù£%%^*¨µù*£ùù£ù%%*ù¨¨%µ^$µ%ù^¨%$$^ù^ùµ*/

// ==== Sound (sound) ====
vec2 mainSound( int samp, float time )
{
    float period = 3.5;
    float tPing = mod(time, period);
    
    float carrierFreq = 1800.0;
    float fmMod = sin(6.28318530718 * 6.0 * tPing) * 45.0;
    float pingEnv = exp(-4.5 * tPing) * (1.0 - exp(-180.0 * tPing));
    
    float mainPing = sin(6.28318530718 * (carrierFreq + fmMod) * tPing) * pingEnv;
    
    float pingHarmonic = sin(6.28318530718 * (carrierFreq * 2.0) * tPing) * exp(-12.0 * tPing) * 0.25;
    float masterPing = (mainPing + pingHarmonic) * 0.7;
    
    float beam = mod(time * 1.5, 6.28318530718) - 3.14159265359;
    
    vec2 p1 = vec2(0.25 * cos(time * 0.2), 0.25 * sin(time * 0.3));
    vec2 p2 = vec2(0.35 * cos(time * 0.1 + 2.0), 0.15 * sin(time * 0.15 - 1.0));
    vec2 p3 = vec2(0.15 * cos(time * -0.15), 0.3 * sin(time * -0.05 + 4.0));
    
    float a1 = mod(atan(p1.y, p1.x) - beam + 3.14159265359, 6.28318530718) - 3.14159265359;
    float a2 = mod(atan(p2.y, p2.x) - beam + 3.14159265359, 6.28318530718) - 3.14159265359;
    float a3 = mod(atan(p3.y, p3.x) - beam + 3.14159265359, 6.28318530718) - 3.14159265359;
    
    float dt1 = mod(-a1, 6.28318530718) / 1.5;
    float dt2 = mod(-a2, 6.28318530718) / 1.5;
    float dt3 = mod(-a3, 6.28318530718) / 1.5;
    
    float d1 = length(p1);
    float d2 = length(p2);
    float d3 = length(p3);
    
    float echoEnv1 = exp(-8.0 * dt1) * (1.0 - exp(-120.0 * dt1));
    float echoEnv2 = exp(-9.0 * dt2) * (1.0 - exp(-120.0 * dt2));
    float echoEnv3 = exp(-10.0 * dt3) * (1.0 - exp(-120.0 * dt3));
    
    float echo1 = sin(6.28318530718 * 1650.0 * dt1) * echoEnv1 * (1.0 - d1 * 0.7) * 0.35;
    float echo2 = sin(6.28318530718 * 1500.0 * dt2) * echoEnv2 * (1.0 - d2 * 0.7) * 0.25;
    float echo3 = sin(6.28318530718 * 1750.0 * dt3) * echoEnv3 * (1.0 - d3 * 0.7) * 0.30;
    
    float pan1 = clamp(p1.x / 0.5, -0.75, 0.75);
    float pan2 = clamp(p2.x / 0.5, -0.75, 0.75);
    float pan3 = clamp(p3.x / 0.5, -0.75, 0.75);
    
    float echoL = echo1 * (0.5 - 0.5 * pan1) + echo2 * (0.5 - 0.5 * pan2) + echo3 * (0.5 - 0.5 * pan3);
    float echoR = echo1 * (0.5 + 0.5 * pan1) + echo2 * (0.5 + 0.5 * pan2) + echo3 * (0.5 + 0.5 * pan3);
    
    float rumble = (sin(6.28318530718 * 38.0 * time) * 0.7 + sin(6.28318530718 * 76.0 * time) * 0.3) * 0.02;
    float waterNoise = (fract(sin(time * 117.432) * 43758.5453) - 0.5) * 0.005;
    
    float mixL = masterPing * 0.6 + echoL + rumble + waterNoise;
    float mixR = masterPing * 0.6 + echoR + rumble + waterNoise;
    
    return clamp(vec2(mixL, mixR), -1.0, 1.0);
}
