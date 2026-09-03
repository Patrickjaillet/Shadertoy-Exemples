// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    // courbure d'écran façon tube cathodique
    vec2 cc = uv - 0.5;
    float dist = dot(cc,cc);
    vec2 uvCurved = uv + cc * dist * 0.06;

    vec3 col;
    if (uvCurved.x < 0.0 || uvCurved.x > 1.0 || uvCurved.y < 0.0 || uvCurved.y > 1.0)
    {
        col = vec3(0.0);
    }
    else
    {
        col = texture(iChannel0, uvCurved).rgb;
    }

    // tonemap
    col = 1.0 - exp(-col * 1.3);

    // scanlines
    float scan = sin(uvCurved.y * iResolution.y * 3.14159) * 0.04;
    col -= scan;

    // vignette
    float vig = smoothstep(0.9, 0.25, dist);
    col *= vig;

    // grain léger
    float grain = fract(sin(dot(fragCoord, vec2(12.9898,78.233))) * 43758.5453 + iTime);
    col += (grain - 0.5) * 0.015;

    fragColor = vec4(col, 1.0);
}

// ==== Buffer A (buffer) ====
bool keyDown(int code)
{
    return texelFetch(iChannel1, ivec2(code, 0), 0).x > 0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ivec2 p = ivec2(fragCoord);
    vec4 ball = texelFetch(iChannel0, ivec2(0,0), 0);
    vec4 pad  = texelFetch(iChannel0, ivec2(1,0), 0);

    float dt = iTimeDelta > 0.0 ? min(iTimeDelta, 0.033) : 0.0166;

    if (iFrame < 1)
    {
        ball = vec4(0.5, 0.5, BALL_SPEED_START, BALL_SPEED_START*0.6);
        pad  = vec4(0.5, 0.5, 0.0, 0.0);
    }

    float p1 = pad.x;
    float p2 = pad.y;
    float s1 = pad.z;
    float s2 = pad.w;

    // Joueur 1 : clavier (flèches ou W/S)
    float move1 = 0.0;
    if (keyDown(KEY_UP) || keyDown(KEY_W)) move1 += 1.0;
    if (keyDown(KEY_DOWN) || keyDown(KEY_S)) move1 -= 1.0;
    p1 += move1 * PADDLE_SPEED * dt;
    p1 = clamp(p1, PADDLE_H*0.5, 1.0 - PADDLE_H*0.5);

    // Joueur 2 : souris (position Y directe)
    float my = iMouse.y / iResolution.y;
    if (iMouse.y > 0.0) {
        p2 = clamp(my, PADDLE_H*0.5, 1.0 - PADDLE_H*0.5);
    }

    vec2 bpos = ball.xy;
    vec2 bvel = ball.zw;
    bpos += bvel * dt;

    if (bpos.y <= BALL_SIZE*0.5) { bpos.y = BALL_SIZE*0.5; bvel.y = abs(bvel.y); }
    if (bpos.y >= 1.0 - BALL_SIZE*0.5) { bpos.y = 1.0 - BALL_SIZE*0.5; bvel.y = -abs(bvel.y); }

    // collision raquette gauche
    if (bvel.x < 0.0 && bpos.x - BALL_SIZE*0.5 <= P1_X + PADDLE_W*0.5 && bpos.x + BALL_SIZE*0.5 >= P1_X - PADDLE_W*0.5)
    {
        if (abs(bpos.y - p1) <= PADDLE_H*0.5 + BALL_SIZE*0.5)
        {
            bpos.x = P1_X + PADDLE_W*0.5 + BALL_SIZE*0.5;
            float rel = (bpos.y - p1) / (PADDLE_H*0.5);
            float speed = min(length(bvel) * 1.06, BALL_SPEED_MAX);
            vec2 dir = normalize(vec2(1.0, rel*1.2 + 0.001));
            bvel = dir * speed;
        }
    }
    // collision raquette droite
    if (bvel.x > 0.0 && bpos.x + BALL_SIZE*0.5 >= P2_X - PADDLE_W*0.5 && bpos.x - BALL_SIZE*0.5 <= P2_X + PADDLE_W*0.5)
    {
        if (abs(bpos.y - p2) <= PADDLE_H*0.5 + BALL_SIZE*0.5)
        {
            bpos.x = P2_X - PADDLE_W*0.5 - BALL_SIZE*0.5;
            float rel = (bpos.y - p2) / (PADDLE_H*0.5);
            float speed = min(length(bvel) * 1.06, BALL_SPEED_MAX);
            vec2 dir = normalize(vec2(-1.0, rel*1.2 + 0.001));
            bvel = dir * speed;
        }
    }

    // score
    if (bpos.x < -0.05)
    {
        s2 += 1.0;
        bpos = vec2(0.5, 0.5);
        bvel = vec2(BALL_SPEED_START, BALL_SPEED_START*0.5);
    }
    if (bpos.x > 1.05)
    {
        s1 += 1.0;
        bpos = vec2(0.5, 0.5);
        bvel = vec2(-BALL_SPEED_START, BALL_SPEED_START*0.5);
    }

    if (p.x == 0 && p.y == 0) fragColor = vec4(bpos, bvel);
    else if (p.x == 1 && p.y == 0) fragColor = vec4(p1, p2, s1, s2);
    else fragColor = vec4(0.0);
}

// ==== Common (common) ====
#define PADDLE_W 0.015
#define PADDLE_H 0.22
#define BALL_SIZE 0.018
#define PADDLE_SPEED 0.9
#define BALL_SPEED_START 0.55
#define BALL_SPEED_MAX 1.4
#define P1_X 0.06
#define P2_X 0.94
#define KEY_UP 38
#define KEY_DOWN 40
#define KEY_W 87
#define KEY_S 83

// ==== Buffer B (buffer) ====
float sdBox(vec2 p, vec2 b)
{
    vec2 d = abs(p) - b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdCircle(vec2 p, float r)
{
    return length(p) - r;
}

vec3 phosphor(float d, float width, vec3 col)
{
    float glow = width / (abs(d) + 0.0015);
    glow = pow(glow, 1.4);
    return col * glow * 0.02;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy;
    float scale = min(res.x, res.y);
    vec2 uv = fragCoord / res;

    vec4 ball = texelFetch(iChannel0, ivec2(0,0), 0);
    vec4 pad  = texelFetch(iChannel0, ivec2(1,0), 0);
    float p1 = pad.x, p2 = pad.y, s1 = pad.z, s2 = pad.w;

    vec2 fp = fragCoord;
    vec3 col = vec3(0.0);
    vec3 green = vec3(0.35, 1.0, 0.55);

    // ligne centrale pointillée
    float cx = 0.5 * res.x;
    float dashY = mod(fp.y, 28.0);
    if (abs(fp.x - cx) < 3.0 && dashY < 14.0)
    {
        col += phosphor(abs(fp.x - cx), 1.2, green*0.5);
    }

    // raquette 1
    vec2 pad1c = vec2(P1_X*res.x, p1*res.y);
    vec2 halfP = vec2(PADDLE_W*scale*0.5, PADDLE_H*res.y*0.5);
    col += phosphor(sdBox(fp - pad1c, halfP), 1.5, green);

    // raquette 2
    vec2 pad2c = vec2(P2_X*res.x, p2*res.y);
    col += phosphor(sdBox(fp - pad2c, halfP), 1.5, green);

    // balle
    vec2 ballc = ball.xy * res;
    float ballR = BALL_SIZE*scale*0.5;
    col += phosphor(sdCircle(fp - ballc, ballR), 1.8, vec3(0.7,1.0,0.8));

    // score (pastilles)
    for (int i = 0; i < 9; i++)
    {
        float fi = float(i);
        if (fi < s1)
        {
            vec2 pc = vec2(res.x*0.5 - 20.0 - fi*18.0, res.y - 30.0);
            col += phosphor(sdCircle(fp-pc, 3.0), 1.0, green);
        }
        if (fi < s2)
        {
            vec2 pc = vec2(res.x*0.5 + 20.0 + fi*18.0, res.y - 30.0);
            col += phosphor(sdCircle(fp-pc, 3.0), 1.0, green);
        }
    }

    // rémanence phosphore (trainée façon tube cathodique)
    vec3 prev = texture(iChannel1, uv).rgb;
    col = col + prev * 0.82;

    fragColor = vec4(col, 1.0);
}
