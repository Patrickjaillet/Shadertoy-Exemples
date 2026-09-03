// ==== Image (image) ====
// https://patrickjaillet.github.io/sandefjord-software

vec3 rotate(vec3 p, vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return p * c + cross(axis, p) * s + axis * dot(axis, p) * oc;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float map(vec3 p) {
    float d = 1e5;
    vec3 p_rot = rotate(p, vec3(0.57735), iTime * 0.5);
    
    for(int i = 0; i < 4; i++) {
        p_rot = abs(p_rot) - vec3(0.7, 0.0, 0.5);
        p_rot = rotate(p_rot, vec3(0.0, 1.0, 0.0), iTime * 0.2 + float(i));
        float box = sdBox(p_rot, vec3(0.5, 0.3, 0.1));
        d = min(d, box);
    }
    
    return max(d, -length(p));
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.002, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

float getAO(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 4; i++) {
        float hr = 0.06 + 0.12 * float(i);
        vec3 aopos = n * hr + p;
        float dd = map(aopos);
        occ += -(dd - hr) * sca;
        sca *= 0.85;
    }
    return clamp(1.0 - occ * 1.5, 0.0, 1.0);
}

float getShadow(vec3 ro, vec3 rd, float mint, float maxt) {
    float res = 1.0;
    float t = mint;
    for(int i = 0; i < 24; i++) {
        float h = map(ro + rd * t);
        if(h < 0.001) return 0.0;
        res = min(res, 16.0 * h / t);
        t += clamp(h, 0.04, 0.2);
        if(t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

vec3 getBgColor(vec3 rd, vec2 uv) {
    vec3 bg = mix(vec3(0.005, 0.01, 0.025), vec3(0.02, 0.04, 0.08), rd.y * 0.5 + 0.5);
    bg += vec3(0.03, 0.05, 0.12) * pow(max(0.0, 1.0 - length(uv)), 3.0);
    float pulse = 0.5 + 0.5 * sin(iTime * 0.2);
    bg += vec3(0.12, 0.06, 0.2) * abs(sin(rd.x * 2.0 + rd.z * 2.0 + iTime * 0.1)) * 0.25 * pulse;
    return bg;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, -4.5);
    vec3 rd = normalize(vec3(uv, 2.7));
    
    vec3 orbPos = vec3(
        sin(iTime * 1.3) * cos(iTime * 0.7) * 1.8,
        sin(iTime * 0.9 + 1.0) * 1.4,
        cos(iTime * 1.1) * sin(iTime * 0.5) * 1.8
    );
    
    float t = 0.0;
    float d = 0.0;
    bool hit = false;
    
    for(int i = 0; i < 80; i++) {
        vec3 p = ro + rd * t;
        d = map(p);
        if(d < 0.001) {
            hit = true;
            break;
        }
        if(t > 8.0) break;
        t += d * 0.95;
    }
    
    vec3 col = getBgColor(rd, uv);
    
    if(hit) {
        vec3 p = ro + rd * t;
        vec3 n = getNormal(p);
        
        vec3 l = normalize(vec3(2.5, 1.5, -3.5));
        vec3 l2 = normalize(vec3(-2.5, -1.0, 2.0));
        vec3 lOrb = orbPos - p;
        float dOrb = length(lOrb);
        lOrb /= dOrb;
        
        float diff = max(dot(n, l), 0.0);
        float diff2 = max(dot(n, l2), 0.0) * 0.4;
        float diffOrb = max(dot(n, lOrb), 0.0) * (2.5 / (1.0 + dOrb * dOrb));
        
        float spec = pow(max(dot(reflect(-l, n), -rd), 0.0), 40.0);
        float specOrb = pow(max(dot(reflect(-lOrb, n), -rd), 0.0), 16.0) * (1.5 / (1.0 + dOrb * dOrb));
        
        float ao = getAO(p, n);
        float sh = getShadow(p + n * 0.01, l, 0.02, 4.0);
        sh = mix(0.2, 1.0, sh);
        float shOrb = getShadow(p + n * 0.01, lOrb, 0.02, dOrb);
        
        vec3 reflectRd = reflect(rd, n);
        vec3 reflectPos = p + n * 0.01;
        float rt = 0.0;
        float rd_dist = 0.0;
        bool rHit = false;
        
        for(int j = 0; j < 32; j++) {
            vec3 rp = reflectPos + reflectRd * rt;
            rd_dist = map(rp);
            if(rd_dist < 0.002) {
                rHit = true;
                break;
            }
            if(rt > 4.0) break;
            rt += rd_dist;
        }
        
        vec3 reflectCol = getBgColor(reflectRd, uv);
        if(rHit) {
            vec3 rp = reflectPos + reflectRd * rt;
            vec3 rn = getNormal(rp);
            float rDiff = max(dot(rn, l), 0.0);
            vec3 rBase = 1.0 + 0.5 * cos(iTime * 0.7 + rp.xyx * 1.2 + vec3(0.0, 2.0, 4.0));
            reflectCol = rBase * (rDiff * 0.8 + 0.2) * 1.3;
            reflectCol = mix(reflectCol, vec3(0.005, 0.01, 0.025), 1.0 - exp(-0.3 * rt * rt));
        }
        
        vec3 baseCol = vec3(0.08, 0.12, 0.18);
        vec3 specColor = 1.0 + 0.5 * cos(iTime * 0.7 + p.xyx * 1.2 + vec3(0.0, 2.0, 4.0));
        vec3 orbCol = vec3(1.0, 0.4, 0.1) * (0.8 + 0.4 * sin(iTime * 8.0));
        
        float fresnel = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 3.5);
        float reflectionStrength = 0.25 + 0.75 * fresnel;
        
        vec3 metalLighting = baseCol * (diff * sh * 1.2 + diff2 * ao + 0.15 * ao);
        metalLighting += orbCol * diffOrb * shOrb * ao;
        metalLighting += specColor * spec * sh * 2.2;
        metalLighting += orbCol * specOrb * shOrb * 1.5;
        metalLighting += vec3(0.5, 0.8, 1.0) * pow(fresnel, 2.0) * 1.5 * ao;
        
        col = mix(metalLighting, reflectCol, reflectionStrength * ao);
        col = mix(col, vec3(0.005, 0.01, 0.025), 1.0 - exp(-0.15 * t * t));
    }
    
    vec3 rayDirOrb = orbPos - ro;
    float projection = dot(rayDirOrb, rd);
    projection = clamp(projection, 0.0, hit ? t : 8.0);
    float distToOrb = length(ro + rd * projection - orbPos);
    
    float orbPulse = 0.08 + 0.03 * sin(iTime * 8.0);
    vec3 glowColor = vec3(1.0, 0.5, 0.15);
    col += glowColor * (orbPulse / (distToOrb * distToOrb + 0.005));
    col += vec3(1.0, 0.9, 0.8) * (0.005 / (distToOrb + 0.001));
    
    col = mix(col, vec3(dot(col, vec3(0.2126, 0.7152, 0.0722))), -0.25);
    col = col * 1.4 / (col + vec3(1.0));
    col = pow(col, vec3(1.0 / 2.2));
    
    fragColor = vec4(col, 1.0);
}
