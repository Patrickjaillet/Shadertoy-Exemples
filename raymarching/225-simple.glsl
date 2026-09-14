// ==== Image (image) ====
float hash(vec2 p) {
  p = fract(p * vec2(234.34, 435.345));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i),         hash(i + vec2(1,0)), u.x),
    mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), u.x),
    u.y
  );
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  mat2 m = mat2(0.8, 0.6, -0.6, 0.8);
  for (int i = 0; i < 6; i++) {
    v += a * noise(p);
    p = m * p * 2.02 + vec2(1.7, 9.2);
    a *= 0.48;
  }
  return v;
}

vec2 fbm2(vec2 p) {
  return vec2(fbm(p), fbm(p + vec2(7.3, 4.1)));
}

float sdCircle(vec2 p, float r) { 
  return length(p) - r; 
}

vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.263, 0.416, 0.557);
  return a + b * cos(6.2831853 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;

  vec2 mouse = iMouse.z > 0.0 ? (iMouse.xy * 2.0 - iResolution.xy) / iResolution.y : vec2(0.0);
  float mouseDist = length(uv - mouse);
  vec2 mouseDir = (uv - mouse) / (mouseDist + 1e-5);
  uv += mouseDir * (0.25 / (mouseDist * mouseDist + 0.04)) * smoothstep(1.5, 0.0, mouseDist) * step(0.0, iMouse.z);

  float t = iTime * 0.25;
  vec2 q = fbm2(uv + vec2(t * 0.1, t * 0.15));
  vec2 r = fbm2(uv + 1.0 * q + vec2(t * 0.2, t * 0.05));
  vec2 warped = uv + 0.5 * r;

  float f = fbm(warped * 2.5 + t * 0.1);

  float dist = length(uv0);
  vec3 col = palette(f + dist * 0.35 + t * 0.05);

  float ringFrequency = 1.0 + fbm(uv0 * 1.5 + t * 0.2) * 0.5;
  float ringRadius = 0.45 + 0.12 * sin(iTime * 1.2 + f * 4.0);
  float ring = sdCircle(uv0, ringRadius);
  
  float glow = exp(-abs(ring) * (12.0 - 4.0 * sin(iTime * 2.0)));
  vec3 glowColor = mix(vec3(0.48, 0.42, 0.98), vec3(0.98, 0.35, 0.68), sin(iTime * 0.5) * 0.5 + 0.5);
  col += glow * glowColor * 1.8;

  float inner = sdCircle(uv0, 0.08 + 0.015 * sin(iTime * 4.0));
  vec3 innerColor = mix(vec3(0.24, 0.93, 0.67), vec3(0.95, 0.88, 0.31), f);
  col = mix(col, innerColor, smoothstep(0.015, 0.0, inner));

  float edgeGlow = exp(-abs(inner) * 24.0);
  col += edgeGlow * innerColor * 0.6;

  float vignette = smoothstep(1.6, 0.4, dist);
  col *= mix(0.15, 1.0, vignette);

  float pulse = 0.97 + 0.03 * sin(float(iFrame) * 0.07 + iTimeDelta);
  col *= pulse;

  float hour = iDate.w / 86400.0;
  vec2 corner = smoothstep(vec2(0.4), vec2(1.1), fragCoord / iResolution.xy);
  col = mix(col, palette(hour + f * 0.2), corner.x * corner.y * 0.35);

  col = pow(col, vec3(0.4545));

  fragColor = vec4(col, 1.0);
}
