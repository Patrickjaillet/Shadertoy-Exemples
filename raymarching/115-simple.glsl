// ==== Image (image) ====
mat3 getRotation(float angleX, float angleY) {
    float cx = cos(angleX), sx = sin(angleX);
    float cy = cos(angleY), sy = sin(angleY);
    return mat3(
        cy, 0.0, sy,
        sy * sx, cx, -cy * sx,
        -sy * cx, sx, cy * cx
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 res = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * res) / min(res.y, res.x);
    
    float pathTime = iTime * 0.52;
    vec3 ro = vec3(
        sin(pathTime) * 1.2,
        cos(pathTime * 0.7) * 0.3,
        -1.2 + sin(pathTime * 0.5) * 0.5
    );
    
    vec3 lookAt = vec3(0.0, 0.0, 0.0);
    vec3 forward = normalize(lookAt - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);
    
    mat3 rot = getRotation(sin(iTime * 0.1) * 0.1, cos(iTime * 0.1) * 0.1);
    rd *= rot;

    float t = -ro.z / rd.z;
    vec3 pos = ro + rd * t;
    
    vec2 z = pos.xy * 0.51;
    vec2 c = vec2(-0.76, 0.15) + 0.02 * cos(iTime * 0.15);
    
    float iter = 0.0;
    const float maxIter = 192.0;
    vec2 dz = vec2(0.1, 0.1);
    
    for(float i = 0.0; i < maxIter; i++)
    {
        dz = 2.0 * vec2(z.x * dz.x - z.y * dz.y, z.x * dz.y + z.y * dz.x);
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if(dot(z, z) > 161.3) break;
        iter++;
    }
    
    float dist = 0.2 * length(z) * log(length(z)) / length(dz);
    float f = pow(iter / maxIter, 0.4);
    
    vec3 col = 0.5 + 0.5 * cos(6.0 + f * 12.0 + vec3(0.0, 0.6, 1.0));
    col *= smoothstep(0.0, 0.01, dist * 50.0);
    col += vec3(0.05, 0.1, 0.2) * (1.0 - f);
    
    vec2 vignette = fragCoord / res;
    col *= 26.4 * vignette.x * vignette.y * (1.0 - vignette.x) * (1.0 - vignette.y);
    
    col = pow(col, vec3(0.8));
    col += (fract(sin(dot(fragCoord, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.05;
    
    fragColor = vec4(col, 1.0);
}
