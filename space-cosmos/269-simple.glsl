
#define PI 3.14159265359

vec3 phaseToRGB(float phase) {

    return 0.5 + 0.5 * cos(phase + vec3(0.0, 2.0 * PI / 3.0, 4.0 * PI / 3.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float t = iTime * 0.5;
    vec3 finalColor = vec3(0.0);

    for(float i = 1.0; i <= 3.0; i++) {

        float energy = i * i * 0.2; 
        float phase = energy * t;

        float radius = length(uv) * (2.0 + i);
        float angle = atan(uv.y, uv.x);

        float psi = exp(-radius * radius * 0.5) * sin(radius * i - phase);

        float prob = psi * psi;

        vec3 color = phaseToRGB(angle + phase);

        finalColor += color * prob;
    }

    finalColor = pow(finalColor, vec3(0.8)); 

    finalColor *= 1.2 - length(uv); 

    fragColor = vec4(finalColor, 1.0);
}
