// ==== Image (image) ====
/**************************************************************
*  ____    _    _   _ ____  _____ _____   _  ___  ____  ____  *
* / ___|  / \  | \ | |  _ \| ____|  ___| | |/ _ \|  _ \|  _ \ *
* \___ \ / _ \ |  \| | | | |  _| | |_ _  | | | | | |_) | | | |*
*  ___) / ___ \| |\  | |_| | |___|  _| |_| | |_| |  _ <| |_| |*
* |____/_/   \_\_| \_|____/|_____|_|  \___/ \___/|_| \_\____/ *
***************************************************************
*                 https://x.com/JailletPatrick                *
***************************************************************
*                     Le Petit Editeur GLSL                   *
*   https://github.com/Patrickjaillet/Le-Petit-Editeur-GLSL   *
**************************************************************/
vec4 clr(float x){
    vec4 c = vec4(x,.25-x,x-.25,0);
    c=fract(clamp(fract(c+.75),.25,1.)+.25);
    c=.5+.5*cos(6.28*c*(2.-floor(c+c)));
    c.x=1.-c.x;
    return c;
}

mat2 rot(float a){
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float getVal(vec2 U) {
    vec2 R = iResolution.xy,
         u = (U+U +.1- R) / R.y ;
    vec2 pxl = u * .3 + vec2(.4, -.7),
         c = pxl/2e2+vec2(-.5585395, .5424), z = vec2(0.);

    float oc = length(pxl-c*0.) * length(c),
          zc, low, sum = 0., sum2 = 0., n = 0.,
          rr, B=1e13, vlu = 0., f = 0.;

    for(float k=0.; k<256.; k++){
        float u_val = dot(z,z) + 0.001;
        float wind = sin(1.0 / u_val + iTime) * 0.00002 * k;
        vec2 c_wind = rot(wind) * c;

        z = mat2(z, -z.y, z)*z + c_wind;
        
        rr = dot(z,z);
        if(rr>B) break;

        zc = length(z - pxl + c);
        low = abs(zc-oc);
        if(zc + oc - low != 0.){
            sum2 = sum;
            sum += (length(z)-low)/(zc+oc-low);
            n++;
        }
    }

    if(n>0.){
        sum = sum / n;
        sum2 = sum2 /(n-1.);
        if(rr>0.){
            rr = abs(log(rr)/2.);
            if(rr>0.) f = (log(abs(log(B))/ 2.)-log(rr))/log(2.);
        }
        vlu = sum2 +(sum-sum2)*(f+1.);
        vlu = vlu *2.7/1.8+.5;
    }
    return vlu;
}

void mainImage(out vec4 O, vec2 U)
{
    float val = getVal(U);
    
    vec2 e = vec2(1.5, 0.0);
    float valX = getVal(U + e.xy);
    float valY = getVal(U + e.yx);
    
    vec3 normal = normalize(vec3((val - valX) * 2.5, (val - valY) * 2.5, 0.2));
    
    vec3 lightDir = normalize(vec3(-0.4, 0.6, 0.8));
    
    float diff = max(dot(normal, lightDir), 0.0);
    float spec = pow(max(dot(reflect(-lightDir, normal), vec3(0.0, 0.0, 1.0)), 0.0), 24.0);
    
    vec4 baseColor = clr(val);
    
    float lighting = mix(0.7, 1.35, diff);
    
    O = baseColor * lighting + vec4(spec * 0.45);
}
