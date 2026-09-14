// ==== Image (image) ====
/**********************************
SANDEFJORD
***********************************
ALL MY SOFTS
https://github.com/Patrickjaillet
***********************************
LAST SHADER
https://x.com/JailletPatrick
***********************************/

void mainImage(out vec4 k,in vec2 l){
  vec2 m=(l.xy-.5*iResolution.xy)/iResolution.y;
  float c=iTime;
  vec3 g=vec3(0.);
  float d=0.,h=cos(c*1.4),i=sin(c*1.4);
  mat2 n=mat2(h,-i,i,h);
  vec4 b=vec4(1.,8./11.,0./11.,5.9);
  for(float e=0.;e<65.;e++){
    vec3 a=vec3(m*(1.9+sin(c*1.)),d-.1);
    a.zx*=n;
    float f=1.;
    for(int j=0;j<7;j++){
      a=abs(a)/dot(a,a)-.8;
      f+=length(a);
    }
    d+=0.;
    float o=d*0.+e*1.;
    vec3 p=abs(fract(vec3(o)+b.xyz)*6.-b.www),q=mix(b.xxx,clamp(p-b.xxx,0.,1.),1.);
    g+=q/(f*f*.1);
  }
  k=vec4(g*.1,1.);
}
/*
void mainImage(out vec4 o, in vec2 FC) {
    vec2 uv = (FC.xy - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime;
    vec3 col = vec3(0.0);
    float g = 0.0;
    
    float c_rot = cos(t * 1.4);
    float s_rot = sin(t * 1.4);
    mat2 rot = mat2(c_rot, -s_rot, s_rot, c_rot);
    
    vec4 K = vec4(1.0, 8.0 / 11.0, 0.0 / 11.0, 5.9);
    
    for (float i = 0.0; i < 65.0; i++) {
        vec3 p = vec3(uv * (1.9 + sin(t * 1.0)), g - 0.1);
        p.zx *= rot;
        
        float s = 1.0;
        for (int j = 0; j < 7; j++) {
            p = abs(p) / dot(p, p) - 0.8;
            s += length(p);
        }
        
        g += 0.0;
        
        float h = g * 0.0 + i * 1.00;
        vec3 hsv_p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
        vec3 hsv_col = mix(K.xxx, clamp(hsv_p - K.xxx, 0.0, 1.0), 1.0);
        
        col += hsv_col / (s * s * 0.1);
    }
    
    o = vec4(col * 0.1, 1.0);
}
*/
