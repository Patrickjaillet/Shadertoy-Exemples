
vec3 getMassPos(float t) {
    return vec3(sin(t * 0.8) * 2.5, cos(t * 0.4) * 1.0, cos(t * 0.8) * 2.5);
}

vec3 warpSpace(vec3 p, vec3 massPos) {
    vec3 toMass = massPos - p;
    float dist = length(toMass);

    float strength = 1.2 / (dist * dist + 0.2);

    return p + normalize(toMass) * strength;
}

float map(vec3 p) {
    vec3 massPos = getMassPos(iTime);

    float lambda = 0.03 * sin(iTime * 0.5);
    vec3 pGrid = p * (1.0 + lambda);

    pGrid = warpSpace(pGrid, massPos);

    vec3 q = fract(pGrid) - 0.5;
    float thickness = 0.02;

    float gridX = length(q.yz) - thickness;
    float gridY = length(q.xz) - thickness;
    float gridZ = length(q.xy) - thickness;
    float grid = min(min(gridX, gridY), gridZ);

    float massSphere = length(p - massPos) - 0.3;

    return min(grid, massSphere);
}

float raymarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i=0; i<128; i++) {
        vec3 p = ro + rd * dO;
        float dS = map(p);
        dO += dS;
        if(dO > 30.0 || dS < 0.001) break;
    }
    return dO;
}

vec3 getNormal(vec3 p) {
    float d = map(p);
    vec2 e = vec2(0.005, 0.0);
    vec3 n = d - vec3(
        map(p-e.xyy),
        map(p-e.yxy),
        map(p-e.yyx));
    return normalize(n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float camTime = iTime * 0.2;
    vec3 ro = vec3(5.0 * sin(camTime), 3.0, 5.0 * cos(camTime));
    vec3 lookAt = vec3(0.0, 0.0, 0.0);

    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 rd = normalize(f + uv.x*r + uv.y*u);

    float d = raymarch(ro, rd);
    vec3 col = vec3(0.01, 0.02, 0.05);

    if(d < 30.0) {
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 massPos = getMassPos(iTime);
        float distToMass = length(p - massPos);

        vec3 lightDir = normalize(vec3(1.0, 2.0, -1.0));
        float diff = max(dot(n, lightDir), 0.1);

        vec3 objCol = vec3(0.1, 0.6, 0.9) * diff;
        if(distToMass < 0.31) {
            objCol = vec3(1.0, 0.9, 0.7);
        }

        float energyGlow = 1.5 / (distToMass * distToMass * 5.0 + 0.1);
        objCol += vec3(1.0, 0.6, 0.2) * energyGlow;

        col = mix(objCol, col, 1.0 - exp(-0.05 * d));
    }

    col = pow(col, vec3(0.4545));
    fragColor = vec4(col, 1.0);
}
