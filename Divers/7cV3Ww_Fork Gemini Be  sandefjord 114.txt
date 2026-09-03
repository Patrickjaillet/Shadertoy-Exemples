// ==== Image (image) ====
// Image Pass - Final Composite & Anamorphic Flare Pass
// Fully Controlled via Define Knobs for EVERYTHING!

#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================================================
// 🎛️ IMAGE PASS POST-PROCESSING DEFINE CONTROL PANEL
// ============================================================================

// --- FILM GRAIN & DITHER RETRO KNOBS ---
#define GRAIN_ENABLE        1.0    // 1.0 = Enable Film Grain & Dither, 0.0 = Disable
#define GRAIN_INTENSITY       0.170  // User Value: 0.270 analog grain & dither
#define DITHER_SCALE          0.361  // User Value: 0.001 dither scale

// --- CRT SCANLINE & RETRO KNOBS ---
#define SCANLINE_ENABLE       1.0    // 1.0 = Enable CRT Scanlines, 0.0 = Disable
#define SCANLINE_DENSITY      450.0  // User Value: 450 scanlines normalized to 1080p
#define SCANLINE_INTENSITY    2.75   // User Value: 0.65 scanline darkness
#define SCANLINE_SPEED        10.0   // User Value: 10.0 scroll speed

// --- BLOOM & GLOW MULTIPLIER KNOBS ---
#define BLOOM_ENABLE          1.0    // 1.0 = Enable Bloom Glow, 0.0 = Disable
#define BLOOM_INTENSITY       0.60   // User Value: 0.60 bloom glow strength

// --- ANAMORPHIC LENS FLARE STREAK KNOBS ---
#define STREAK_ENABLE         1.0    // 1.0 = Enable horizontal streak flares
#define STREAK_INTENSITY      6.65   // User Value: 1.65 horizontal streak flares
#define STREAK_LENGTH         0.45   // Decay factor for streak length
#define STREAK_TINT           vec3(0.2, 0.7, 1.1)*0.75 // Color tint of horizontal flares

// --- LENS GLINT & STARBURST KNOBS ---
#define GLINT_ENABLE          0.0    // 1.0 = Enable center starburst glint
#define GLINT_INTENSITY       0.08   // User Value: 0.05 starburst glint

// --- CAMERA & ATMOSPHERIC KNOBS ---
#define VIGNETTE_STRENGTH     1.12   // User Value: 1.12 edge darkening
#define GAMMA_CURVE           0.80   // User Value: 0.90 gamma curve
// ============================================================================

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float filmGrain(vec2 uv, float time) {
    vec2 p = uv * iResolution.xy * DITHER_SCALE;
    float n1 = hash21(p + vec2(time * 117.0, time * 43.0));
    float n2 = hash21(p * 1.3 - vec2(time * 83.0, time * 151.0));
    return (n1 + n2) * 0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    float time = iTime;
    
    // Resolution-independent scanline density scaling
    float physicalDensity = SCANLINE_DENSITY * (iResolution.y / 1080.0);
    
    // 1. Sample Raw Scene from Buffer A (iChannel0)
    vec3 scene = texture(iChannel0, uv).rgb;
    scene = clamp(scene, vec3(0.0), vec3(1.8));
    
    // 2. Apply Film Grain & Dither Noise
    if (GRAIN_ENABLE > 0.5) {
        float grain = filmGrain(uv, time);
        vec3 grainNoise = (vec3(grain) - 0.5) * GRAIN_INTENSITY;
        scene = clamp(scene + grainNoise, vec3(0.0), vec3(1.8));
    }
    
    // 3. Apply CRT Scanlines
    if (SCANLINE_ENABLE > 0.5) {
        float scanline = sin((uv.y + time * SCANLINE_SPEED * 0.0005) * physicalDensity * PI);
        scanline = 0.5 + 0.5 * scanline;
        scanline = pow(scanline, 1.6);
        scene *= mix(1.0, scanline, SCANLINE_INTENSITY);
    }
    
    // 4. Sample TRUE SEPARABLE GAUSSIAN BLOOM BUFFER from Buffer B (iChannel1)
    vec3 bloom = vec3(0.0);
    if (BLOOM_ENABLE > 0.5) {
        bloom = texture(iChannel1, uv).rgb;
    }
    
    // 5. Anamorphic Horizontal Streak Flares (Sampled from Bloom Buffer B!)
    vec3 anamorphicStreak = vec3(0.0);
    if (STREAK_ENABLE > 0.5) {
        vec2 texel = 1.0 / iResolution.xy;
        for (int j = -12; j <= 12; j++) {
            float hOffset = float(j) * 2.0;
            vec3 sH = texture(iChannel1, uv + vec2(hOffset * texel.x, 0.0)).rgb;
            float streakWeight = exp(-abs(float(j)) * STREAK_LENGTH);
            anamorphicStreak += sH * streakWeight;
        }
        anamorphicStreak *= STREAK_TINT;
    }
    
    // 6. Lens Glint & Starburst
    vec3 glintColor = vec3(0.0);
    if (GLINT_ENABLE > 0.5) {
        vec2 pCenter = uv - 0.5;
        float dist = length(pCenter);
        float angle = atan(pCenter.y, pCenter.x);
        float starburst = pow(abs(sin(angle * 4.0)), 12.0) * exp(-dist * 4.0);
        glintColor = vec3(1.0, 0.85, 0.4) * starburst * GLINT_INTENSITY;
    }
    
    // 7. Composite Final Image (Base Scanlined Scene + True Buffer B Bloom + Anamorphic Streaks)
    vec3 finalCol = scene + bloom * BLOOM_INTENSITY + anamorphicStreak * STREAK_INTENSITY + glintColor;
    
    // Tone mapping
    finalCol = finalCol / (1.0 + finalCol * 0.15);
    finalCol = pow(finalCol, vec3(GAMMA_CURVE));
    
    // Vignette
    vec2 q = uv;
    finalCol *= pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), VIGNETTE_STRENGTH);
    
    fragColor = vec4(finalCol, 1.0);
}

// ==== Sound (sound) ====
// Dark Minimal Techno Audio Synthesizer - Extended 64-Bar Edition
// 130 BPM GLSL Audio Engine

#define PI 3.14159265359
#define TAU 6.28318530718

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise(float t) {
    return hash11(t) * 2.0 - 1.0;
}

float saturate(float x) {
    return clamp(x, -1.0, 1.0);
}

float softClip(float x) {
    return tanh(x);
}

vec2 softClipVec(vec2 x) {
    return vec2(tanh(x.x), tanh(x.y));
}

float noteToFreq(float note) {
    return 440.0 * pow(2.0, (note - 69.0) / 12.0);
}

vec2 mainSound( in int samp, in float time )
{
    // --- 1. CLOCK & TIMING ENGINE (130 BPM) ---
    float bpm = 130.0;
    float secPerBeat = 60.0 / bpm;          // ~0.4615s
    float secPer16th = secPerBeat * 0.25;    // ~0.1154s
    
    float totalBeats = time / secPerBeat;
    float currentBar = floor(totalBeats / 4.0);
    float step16 = floor(time / secPer16th);
    float stepInBar = mod(step16, 16.0);
    
    float tBeat = mod(time, secPerBeat);
    float tStep = mod(time, secPer16th);
    
    // --- 2. EXTENDED 64-BAR ARRANGEMENT STRUCTURE ---
    float loopBar = mod(currentBar, 64.0);
    
    float isDubStab   = (loopBar >= 24.0 && loopBar < 48.0) ? 1.0 : 0.0;
    float isAcidB     = (loopBar >= 32.0 && loopBar < 48.0) ? 1.0 : 0.0;
    float isPreDrop   = (loopBar >= 44.0 && loopBar < 48.0) ? 1.0 : 0.0;
    float isPeakDrop  = (loopBar >= 48.0 && loopBar < 56.0) ? 1.0 : 0.0;
    float isOutro     = (loopBar >= 56.0) ? 1.0 : 0.0;
    
    float kickEnable = (isPreDrop > 0.5) ? 0.0 : 1.0;
    if (isOutro > 0.5 && mod(loopBar, 2.0) == 1.0) kickEnable = 0.0;
    
    float bassEnable = (loopBar >= 4.0 && isPreDrop < 0.5) ? 1.0 : 0.0;
    float hatEnable   = (loopBar >= 8.0) ? 1.0 : 0.0;
    float acidEnable = (loopBar >= 16.0 && loopBar < 56.0) ? 1.0 : 0.0;
    float percEnable = (loopBar >= 12.0 && loopBar < 56.0) ? 1.0 : 0.0;
    float stabEnable = (isDubStab > 0.5) ? 1.0 : 0.0;

    // --- INSTRUMENT 1: SUB KICK & GHOST KICKS ---
    float kick = 0.0;
    if (kickEnable > 0.5) {
        float fEnv = exp(-85.0 * tBeat);
        float phase = TAU * (44.0 * tBeat - (190.0 / 85.0) * fEnv);
        
        float body = sin(phase);
        body = saturate(body * 1.6);
        float ampEnv = exp(-6.2 * tBeat);
        float click = noise(time * 1400.0) * exp(-190.0 * tBeat) * 0.25;
        
        kick = (body * ampEnv + click) * 1.15;
        
        if (isPeakDrop > 0.5 && stepInBar == 14.0) {
            float gEnv = exp(-7.0 * tStep);
            kick += sin(TAU * 48.0 * tStep) * gEnv * 0.5;
        }
        
        kick = softClip(kick * 1.25);
    }
    
    float sidechain = smoothstep(0.0, 0.22, tBeat);

    // --- INSTRUMENT 2: ROLLING SUB-BASS ---
    float subBass = 0.0;
    if (bassEnable > 0.5) {
        float isBeat0 = (stepInBar == 0.0 || stepInBar == 4.0 || stepInBar == 8.0 || stepInBar == 12.0) ? 0.0 : 1.0;
        float bassEnv = exp(-16.0 * tStep) * isBeat0;
        
        float baseFreq = 36.71;
        if (mod(loopBar, 8.0) >= 4.0) baseFreq = 43.65;
        if (loopBar >= 48.0 && mod(loopBar, 4.0) >= 2.0) baseFreq = 49.0;
        
        float bPhase = TAU * baseFreq * time;
        float saw = fract(bPhase / TAU) * 2.0 - 1.0;
        float subSine = sin(bPhase);
        float rawBass = mix(subSine, saw, 0.45);
        
        subBass = rawBass * bassEnv * sidechain;
        subBass = softClip(subBass * 1.6) * 0.7;
    }

    // --- INSTRUMENT 3: DUAL-PATTERN ACID 303 SYNTH ---
    float acid = 0.0;
    if (acidEnable > 0.5) {
        float notesA[16] = float[16](38.0, 50.0, 38.0, 53.0,  38.0, 55.0, 56.0, 50.0,  38.0, 60.0, 53.0, 38.0,  55.0, 50.0, 38.0, 53.0);
        float notesB[16] = float[16](50.0, 62.0, 50.0, 65.0,  50.0, 67.0, 70.0, 62.0,  50.0, 72.0, 65.0, 50.0,  67.0, 62.0, 50.0, 65.0);
        float accents[16]= float[16](1.0,  0.3,  0.0,  1.0,   0.0,  0.8,  1.0,  0.0,   0.3,  1.0,  0.0,  0.6,   1.0,  0.3,  0.0,  0.9);
        
        int idx = int(stepInBar);
        float midiNote = (isAcidB > 0.5 || isPeakDrop > 0.5) ? notesB[idx] : notesA[idx];
        float accent = accents[idx];
        
        float aFreq = noteToFreq(midiNote);
        float aPhase = TAU * aFreq * time;
        float aSaw = fract(aPhase / TAU) * 2.0 - 1.0;
        
        float envDecay = mix(16.0, 7.0, accent);
        float aEnv = exp(-envDecay * tStep);
        
        float sweepLFO = 0.5 + 0.5 * sin(time * 0.12);
        float filterBase = 350.0 + 1400.0 * sweepLFO;
        if (isPeakDrop > 0.5) filterBase = 1200.0 + 1600.0 * sin(time * 0.4);
        
        float cutoff = filterBase + (1600.0 + 3000.0 * accent) * aEnv;
        float q = 0.88 + 0.08 * accent;
        
        float filtered = aSaw * aEnv;
        filtered = sin(filtered * (1.0 + q * 3.5));
        
        acid = softClip(filtered * (2.2 + 3.5 * accent)) * (0.32 + 0.48 * accent);
        acid *= sidechain;
    }

    // --- INSTRUMENT 4: DUB TECHNO CHORD STAB ---
    float dubStab = 0.0;
    if (stabEnable > 0.5) {
        float stabBeat = mod(totalBeats, 8.0);
        float tStab = mod(time, secPerBeat * 2.0);
        
        if (stabBeat > 2.0 && stabBeat < 4.0) {
            float sEnv = exp(-4.5 * tStab);
            
            float f1 = noteToFreq(50.0);
            float f2 = noteToFreq(53.0);
            float f3 = noteToFreq(57.0);
            float f4 = noteToFreq(60.0);
            
            float c1 = fract(f1 * time) * 2.0 - 1.0;
            float c2 = fract(f2 * time * 1.002) * 2.0 - 1.0;
            float c3 = fract(f3 * time * 0.998) * 2.0 - 1.0;
            float c4 = fract(f4 * time * 1.001) * 2.0 - 1.0;
            
            float rawStab = (c1 + c2 + c3 + c4) * 0.25;
            float stabCutoff = 300.0 + 2200.0 * sEnv;
            dubStab = rawStab * sEnv * (stabCutoff / 2500.0);
            dubStab = softClip(dubStab * 1.4) * 0.4;
            dubStab *= sidechain;
        }
    }

    // --- INSTRUMENT 5: HI-HATS & SHAKERS ---
    float hats = 0.0;
    if (hatEnable > 0.5) {
        float isOffbeat = (stepInBar == 2.0 || stepInBar == 6.0 || stepInBar == 10.0 || stepInBar == 14.0) ? 1.0 : 0.0;
        float is16th = (mod(stepInBar, 2.0) == 1.0) ? 0.45 : 0.0;
        
        float hatEnv = exp(-36.0 * tStep) * (isOffbeat + is16th);
        
        if ((isPeakDrop > 0.5 || isAcidB > 0.5) && isOffbeat > 0.5) {
            hatEnv = exp(-9.0 * tStep);
        }
        
        float hNoise = noise(time * 19340.0) - noise(time * 8400.0);
        hats = hNoise * hatEnv * 0.38;
    }

    // --- INSTRUMENT 6: INDUSTRIAL PERCUSSION & SNARE BUILD ---
    float perc = 0.0;
    if (percEnable > 0.5) {
        if (stepInBar == 4.0 || stepInBar == 12.0) {
            float pEnv = exp(-24.0 * tStep);
            float pTone = sin(TAU * 430.0 * time + sin(TAU * 1150.0 * time) * 2.0);
            float pNoise = noise(time * 12500.0);
            perc += (pTone * 0.55 + pNoise * 0.45) * pEnv * 0.42;
        }
        
        if (stepInBar == 3.0 || stepInBar == 7.0 || stepInBar == 11.0) {
            float cEnv = exp(-40.0 * tStep);
            float cTone = sin(TAU * 1450.0 * time) * cEnv;
            perc += cTone * 0.2;
        }
        
        if (isPreDrop > 0.5) {
            float rollEnv = exp(-18.0 * tStep) * (loopBar - 44.0) * 0.25;
            float rollNoise = noise(time * 9000.0) * rollEnv;
            perc += rollNoise * 0.45;
        }
    }

    // --- INSTRUMENT 7: NOISE RISER TENSION ---
    float riser = 0.0;
    if (isPreDrop > 0.5) {
        float rTime = mod(time, secPerBeat * 16.0);
        float rEnv = pow(rTime / (secPerBeat * 16.0), 2.5);
        riser = noise(time * 15000.0) * rEnv * 0.35;
    }

    // --- INSTRUMENT 8: DARK DRONE ---
    float drone = 0.0;
    float d1 = sin(TAU * 73.41 * time);
    float d2 = sin(TAU * 87.31 * time * 1.003);
    float d3 = sin(TAU * 110.00 * time * 0.997);
    float padLFO = 0.5 + 0.5 * sin(time * 0.18);
    drone = (d1 + d2 + d3) * 0.07 * padLFO * sidechain;

    // --- STEREO PING-PONG DELAY & SPATIALIZATION ---
    float delayTimeL = secPer16th * 3.0;
    float delayTimeR = secPer16th * 4.0;
    
    float center = kick + subBass;
    float left = center + hats * 0.8 + acid * 0.7 + dubStab * 0.8 + perc * 0.6 + riser + drone;
    float right = center + hats * 0.4 + acid * 0.5 + dubStab * 0.4 + perc * 0.8 + riser + drone;
    
    float delayL = sin(TAU * 220.0 * (time - delayTimeL)) * exp(-2.5 * mod(time - delayTimeL, secPer16th)) * (acid + dubStab) * 0.18;
    float delayR = sin(TAU * 330.0 * (time - delayTimeR)) * exp(-2.5 * mod(time - delayTimeR, secPer16th)) * (acid + dubStab) * 0.18;
    
    left += delayL;
    right += delayR;

    // --- MASTER LIMITER & SOFT CLIPPING ---
    vec2 stereoOut = vec2(left, right);
    stereoOut = softClipVec(stereoOut * 1.18);

    return stereoOut;
}

// ==== Buffer A (buffer) ====
// Buffer A - 3D Raymarched Scene Pass
// Restored Original Center Top Key Light & Signature Lighting

#define PI 3.14159265359
#define TAU 6.28318530718

// ============================================================================
// 🎛️ BUFFER A SCENE & LIGHTING DEFINE CONTROL PANEL
// Adjust any of these values to tweak every aspect of the 3D scene & audio reactivity!
// ============================================================================

// --- TUNNEL & SPEED CONFIGS ---
#define TUNNEL_TRAVEL_SPEED   8.0   // World units traveled per 4/4 musical bar (e.g. 2.0, 4.0, 8.0, 16.0)
#define CORE_BAR_SPEED_BARS   1.5   // Number of 4/4 bars per central core bar travel cycle
#define WALL_CHASE_SPEED      20.0  // Speed of wall column light chase pulses

// --- KEY LIGHTING & AMBIENT KNOBS ---
#define TOP_KEYLIGHT_BRIGHT   -0.06   // Restored Original Top Center Key Light Intensity
#define SCENE_AMBIENT_BASE    0.15  // Restored Original Base Ambient Fill

// --- CORE BAR GEOMETRY & DISSOLVE CONFIGS ---
#define CORE_BASE_RADIUS      0.55  // Base thickness radius of central core cylinders
#define CORE_FLUTING_COUNT    12.0  // Number of longitudinal fluted grooves around core
#define CORE_SPIN_SPEED       1.6   // Rotation speed of central reactor core
#define CORE_DISSOLVE_FRONT  -4.5   // Z position near camera where dissolve begins
#define CORE_DISSOLVE_BACK   -6.5   // Z position where core bar completely dissolves

// --- AUDIO REACTIVITY & TRANSIENT CONFIGS ---
#define KICK_PULSE_DECAY      8.0   // Sharpness decay rate of 4/4 sub-kick hits
#define BASS_RAIL_BOOST       1.8   // Sub-bass intensity multiplier on floor rails
#define TREBLE_RAIL_BOOST     4.5   // High-frequency hi-hat intensity multiplier on front rails
#define RAIL_NODE_DENSITY     4.45  // Distance spacing between physical LED equalizer rail nodes

// --- LIGHTING INTENSITIES & EMBEDDED LIGHTS ---
#define CEIL_BEAM_BRIGHTNESS  0.701   // Brightness intensity of ceiling light beams
#define WALL_BAR_BRIGHTNESS   1.8   // Brightness intensity of forward-facing wall light bars
#define CORE_EMISSIVE_BRIGHT  1.05   // Base emissive glow intensity of reactor core
// ============================================================================

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float hash12(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdCylinder(vec3 p, float r, float h) {
    vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec2 map(vec3 p, float time, float loopBar, float kickPulse, float acidPulse) {
    float bpm = 130.0;
    float secPerBeat = 60.0 / bpm;
    float barDuration = secPerBeat * 4.0;
    
    float tunnelSpeed = TUNNEL_TRAVEL_SPEED / barDuration;
    
    vec3 pos = p;
    pos.z = mod(pos.z + time * tunnelSpeed + 800.0, 8.0) - 4.0;
    
    // 1. Base Tunnel Box
    float tunnelWidth = (loopBar >= 44.0 && loopBar < 48.0) ? 4.8 : 5.5;
    float tunnel = -sdBox(p, vec3(tunnelWidth, 4.0, 100.0));
    
    // 2. Wall Columns
    vec3 pRib = pos;
    pRib.z = mod(pRib.z + 800.0, 2.0) - 1.0;
    
    vec3 pWallRib = pRib;
    pWallRib.x = abs(pWallRib.x) - (tunnelWidth - 0.35);
    float wallRibs = sdBox(pWallRib, vec3(0.35, 3.8, 0.4));
    
    // 3. PROMINENT FORWARD-FACING WALL LIGHT BARS
    vec3 pNicheLight = pRib;
    pNicheLight.x = abs(pNicheLight.x) - (tunnelWidth - 0.42);
    pNicheLight.y = mod(pNicheLight.y + 3.0, 1.4) - 0.7;
    float wallNicheLights = sdBox(pNicheLight, vec3(0.12, 0.45, 0.5));
    
    // 4. Floor Panels & Seams
    vec3 pFloorGrate = pos;
    pFloorGrate.x = mod(abs(pFloorGrate.x), 1.2) - 0.6;
    pFloorGrate.z = mod(pFloorGrate.z + 800.0, 1.0) - 0.5;
    float floorGrate = sdBox(vec3(pFloorGrate.x, p.y + 3.75, pFloorGrate.z), vec3(0.55, 0.08, 0.45));
    
    // Floor Energy Channels along Z
    vec3 pConduit = pos;
    pConduit.x = abs(pConduit.x) - 2.4;
    pConduit.y = pConduit.y + 3.75;
    float floorConduits = sdBox(pConduit, vec3(0.2, 0.12, 4.0));
    
    // Ceiling Light Beams / Rails
    vec3 pCeilBeam = pos;
    pCeilBeam.x = abs(pCeilBeam.x) - 1.8;
    pCeilBeam.y = pCeilBeam.y - 3.8;
    float ceilBeams = sdBox(pCeilBeam, vec3(0.15, 0.1, 4.0));
    
    // Floor Rails
    vec3 pRail = pos;
    pRail.x = abs(pRail.x) - 1.5;
    pRail.y = pRail.y + 3.65;
    float rails = sdBox(pRail, vec3(0.12, 0.18, 4.0));
    
    // 5. CENTRAL AUDIO REACTOR CORE
    float travelDist = 16.0;
    float coreSyncSpeed = travelDist / (barDuration * CORE_BAR_SPEED_BARS);
    
    vec3 pCore = p;
    pCore.z = mod(pCore.z + time * coreSyncSpeed + 800.0, travelDist) - (travelDist * 0.5);
    
    float dissolveFactor = smoothstep(CORE_DISSOLVE_BACK, CORE_DISSOLVE_FRONT, pCore.z);
    
    float spinSpeed = (loopBar >= 48.0 && loopBar < 56.0) ? CORE_SPIN_SPEED * 3.0 : CORE_SPIN_SPEED;
    pCore.xy *= rot(pCore.z * 0.35 + time * spinSpeed);
    
    float angleCore = atan(pCore.y, pCore.x);
    float fluting = sin(angleCore * CORE_FLUTING_COUNT) * 0.06 * (0.8 + 0.6 * acidPulse);
    float ringNotch = sin(pCore.z * 6.0 + time * 8.0) * 0.05 * kickPulse;
    
    float acidWave = (loopBar >= 16.0 && loopBar < 56.0) ? sin(pCore.y * 3.0 + time * 6.0) * 0.12 * acidPulse : 0.0;
    float baseRadius = (CORE_BASE_RADIUS + 0.28 * kickPulse + 0.18 * acidPulse + acidWave) * dissolveFactor;
    
    float coreInner = sdCylinder(pCore, max(baseRadius + fluting + ringNotch, 0.001), 3.5);
    
    vec3 pCage = pCore;
    pCage.xy *= rot(pCore.z * -0.5);
    float cageRadius = baseRadius + 0.32 * dissolveFactor;
    float cageCylinder = sdCylinder(pCage, max(cageRadius, 0.001), 3.5);
    float cageWindows = sin(angleCore * 8.0) * sin(pCage.z * 4.0);
    float coreCage = max(cageCylinder, -cageWindows + 0.15);
    
    float core = min(coreInner, coreCage);
    
    vec3 pRing1 = pCore;
    pRing1.z = mod(pRing1.z + 800.0, 2.0) - 1.0;
    float ring1 = sdCylinder(pRing1, max(baseRadius + 0.52 * dissolveFactor, 0.001), 0.08);
    
    vec3 pRing2 = pCore;
    pRing2.z = mod(pRing2.z + 800.0 + 1.0, 2.0) - 1.0;
    pRing2.xy *= rot(PI * 0.5);
    float ring2 = sdCylinder(pRing2, max(baseRadius + 0.42 * dissolveFactor, 0.001), 0.06);
    
    float ring = min(ring1, ring2);
    
    // Combine scene
    float d = min(tunnel, wallRibs);
    d = min(d, floorGrate);
    d = min(d, floorConduits);
    d = min(d, ceilBeams);
    d = min(d, wallNicheLights);
    d = min(d, rails);
    d = min(d, core);
    d = min(d, ring);
    
    // Camera Safe Subtraction Corridor
    float camClear = -sdCylinder(vec3(p.xy, 0.0), 1.4, 100.0);
    if (p.z < -3.0) {
        d = max(d, camClear);
    }
    
    float matID = 1.0;
    if (d == floorGrate)      matID = 1.2;
    if (d == rails)           matID = 1.5;
    if (d == ceilBeams)       matID = 1.6;
    if (d == wallNicheLights) matID = 1.8;
    if (d == floorConduits)   matID = 1.9;
    if (d == core)            matID = 2.0;
    if (d == ring)            matID = 3.0;
    
    return vec2(d, matID);
}

vec3 calcNormal(vec3 p, float time, float loopBar, float kick, float acid) {
    vec2 e = vec2(0.004, 0.0);
    return normalize(vec3(
        map(p + e.xyy, time, loopBar, kick, acid).x - map(p - e.xyy, time, loopBar, kick, acid).x,
        map(p + e.yxy, time, loopBar, kick, acid).x - map(p - e.yxy, time, loopBar, kick, acid).x,
        map(p + e.yyx, time, loopBar, kick, acid).x - map(p - e.yyx, time, loopBar, kick, acid).x
    ));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float time = iTime;
    
    // --- 130 BPM TIMING & 64-BAR SEQUENCE TRACKER ---
    float bpm = 130.0;
    float secPerBeat = 60.0 / bpm;
    float secPer16th = secPerBeat * 0.25;
    float totalBeats = time / secPerBeat;
    float currentBar = floor(totalBeats / 4.0);
    float loopBar = mod(currentBar, 64.0);
    
    float step16 = floor(time / secPer16th);
    float stepInBar = mod(step16, 16.0);
    float tBeat = mod(time, secPerBeat);
    float tStep = mod(time, secPer16th);
    
    // --- AUDIO TRANSIENT ANALYZER ENGINE ---
    // Sub-Bass Transient Tracker (Blue)
    float bassEnable = (loopBar >= 4.0 && loopBar < 44.0) ? 1.0 : (loopBar >= 48.0 ? 1.0 : 0.0);
    float isBeat0 = (stepInBar == 0.0 || stepInBar == 4.0 || stepInBar == 8.0 || stepInBar == 12.0) ? 0.0 : 1.0;
    float bassEnv = exp(-16.0 * tStep) * isBeat0 * bassEnable;
    float kickPulse = exp(-KICK_PULSE_DECAY * tBeat);
    float subBassTrig = clamp(bassEnv * 1.5 + kickPulse * 0.8, 0.0, 1.0);
    
    // Hi-Hat Transient Tracker (Red)
    float hatEnable = (loopBar >= 8.0) ? 1.0 : 0.0;
    float isOffbeat = (stepInBar == 2.0 || stepInBar == 6.0 || stepInBar == 10.0 || stepInBar == 14.0) ? 1.0 : 0.0;
    float is16th = (mod(stepInBar, 2.0) == 1.0) ? 0.45 : 0.0;
    float hatTrig = exp(-36.0 * tStep) * (isOffbeat + is16th) * hatEnable;
    
    // Snare / Industrial Percussion Transient Tracker (Purple)
    float percEnable = (loopBar >= 12.0 && loopBar < 56.0) ? 1.0 : 0.0;
    float snareEnv = (stepInBar == 4.0 || stepInBar == 12.0) ? exp(-24.0 * tStep) : 0.0;
    float rollEnv = (loopBar >= 44.0 && loopBar < 48.0) ? exp(-18.0 * tStep) * (loopBar - 44.0) * 0.25 : 0.0;
    float snareTrig = clamp((snareEnv + rollEnv) * percEnable, 0.0, 1.0);
    
    float acidPulse = 0.5 + 0.5 * sin(time * 2.8 + sin(time * 0.7));
    
    // Color Assignment: Sub-Bass -> Blue, Hi-Hat -> Red, Snare -> Purple
    vec3 colBass  = vec3(0.02, 0.45, 1.0);
    vec3 colHat   = vec3(1.0, 0.05, 0.12);
    vec3 colSnare = vec3(0.75, 0.05, 1.0);

    vec3 colPrimary = mix(colBass, colHat, hatTrig);
    colPrimary = mix(colPrimary, colSnare, snareTrig);

    vec3 colSecondary = mix(colHat, colSnare, snareTrig);
    vec3 colAccent = mix(colSnare, colBass, subBassTrig);

    // Camera roll & motion
    float isAcidB = (loopBar >= 32.0 && loopBar < 48.0) ? 1.0 : 0.0;
    float isPeakDrop = (loopBar >= 48.0 && loopBar < 56.0) ? 1.0 : 0.0;
    float cameraRoll = (isAcidB > 0.5 || isPeakDrop > 0.5) ? sin(time * 0.25) * 0.15 : 0.0;
    vec2 shake = vec2(hash12(vec2(time, 0.0)) - 0.5, hash12(vec2(time, 1.0)) - 0.5) * kickPulse * ((isPeakDrop > 0.5) ? 0.07 : 0.035);
    
    vec3 ro = vec3(0.0 + shake.x, 0.1 + shake.y + sin(time * 0.4) * 0.1, -7.5);
    vec3 lookAt = vec3(sin(time * 0.2) * 0.4, -0.1 + cos(time * 0.15) * 0.2, 5.0);
    
    vec3 fwd = normalize(lookAt - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
    vec3 up = cross(fwd, right);
    
    right.xy *= rot(cameraRoll);
    up.xy *= rot(cameraRoll);
    
    vec3 rd = normalize(uv.x * right + uv.y * up + 1.15 * fwd);
    rd.xy *= rot(kickPulse * 0.02);
    
    // Raymarching Loop
    float t = 0.0;
    float matID = 0.0;
    float hit = 0.0;
    float coreGlow = 0.0;
    
    for (int i = 0; i < 96; i++) {
        vec3 p = ro + rd * t;
        vec2 res = map(p, time, loopBar, kickPulse, acidPulse);
        
        if (res.y >= 2.0 && res.x < 1.5) {
            float glowStep = exp(-res.x * 2.5) * 0.035 * (0.6 + 0.8 * kickPulse);
            coreGlow += min(glowStep, 0.04);
        }
        
        if (res.x < 0.001) {
            hit = 1.0;
            matID = res.y;
            break;
        }
        if (t > 45.0) break;
        t += max(res.x * 0.65, 0.012);
    }
    
    vec3 bgVoid = mix(vec3(0.01, 0.01, 0.03), colBass * 0.15, subBassTrig);
    bgVoid += colHat * 0.08 * hatTrig;
    bgVoid += colSnare * 0.12 * snareTrig;
    
    vec3 col = bgVoid;
    
    if (hit > 0.5) {
        vec3 p = ro + rd * t;
        vec3 n = calcNormal(p, time, loopBar, kickPulse, acidPulse);
        
        // Key lights
        vec3 lightPos1 = vec3(0.0, 2.5, p.z + 4.0);
        vec3 lightPos2 = vec3(cos(time * 1.5) * 3.0, -2.5, p.z - 1.0);
        vec3 lightPos3 = vec3(0.0, 0.0, p.z + 8.0);
        
        vec3 l1 = normalize(lightPos1 - p);
        vec3 l2 = normalize(lightPos2 - p);
        vec3 l3 = normalize(lightPos3 - p);
        
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0);
        float diff3 = max(dot(n, l3), 0.0);
        
        float ao = clamp(map(p + n * 0.2, time, loopBar, kickPulse, acidPulse).x / 0.2, 0.0, 1.0);
        
        vec3 matColor = mix(vec3(0.08, 0.09, 0.14), colBass * 0.3, subBassTrig * 0.5);
        float specPower = 32.0;
        float specStrength = 0.5;
        vec3 specColor = vec3(1.0);
        
        if (matID == 1.2) {
            matColor = mix(vec3(0.12, 0.14, 0.2), colBass * 0.4, subBassTrig);
            specPower = 64.0;
            specStrength = 1.4;
            specColor = colBass;
        } else if (matID == 1.5) {
            // Front Rails -> Hi-Hat Flash (Red) & Sub-Bass Flash (Blue)
            float zDepth = clamp((p.z + 7.5) / 22.0, 0.0, 1.0);
            float railNode = smoothstep(0.0, 0.08, abs(mod(p.z + 800.0, RAIL_NODE_DENSITY) - (RAIL_NODE_DENSITY * 0.5)));
            
            vec3 railCol = mix(colBass * (0.3 + 2.5 * subBassTrig), colHat * (0.5 + 4.0 * hatTrig), smoothstep(0.6, 0.0, zDepth));
            matColor = railCol * (0.45 + 0.95 * railNode);
        } else if (matID == 1.9) {
            // Floor Energy Channels -> Sub-Bass (Blue)
            matColor = colBass * (0.8 + 3.2 * subBassTrig);
            specPower = 128.0;
        } else if (matID == 1.6) {
            // Ceiling Beams -> Hi-Hat Flash (Red)
            matColor = colHat * (0.4 + 2.8 * hatTrig * CEIL_BEAM_BRIGHTNESS);
            specPower = 96.0;
        } else if (matID == 1.8) {
            // Wall Light Bars -> Snare Flash (Purple)
            float zIndex = floor((p.z + time * WALL_CHASE_SPEED + 800.0) / 2.0);
            float chaseWave = sin(zIndex * 0.8 - time * WALL_CHASE_SPEED) * 0.5 + 0.5;
            float segId = floor((p.y + 3.0) / 1.4);
            float vuActive = (snareTrig * 4.0 > segId) ? 1.0 : 0.2;
            
            matColor = colSnare * (vuActive * (WALL_BAR_BRIGHTNESS + WALL_BAR_BRIGHTNESS * chaseWave) + 1.5 * snareTrig);
        } else if (matID == 2.0) {
            // Reactor Core -> Sub-Bass Pulse (Blue) & Snare Flare (Purple)
            vec3 coreCol = mix(colBass, colSnare, snareTrig);
            matColor = coreCol * CORE_EMISSIVE_BRIGHT * (0.8 + 2.2 * subBassTrig + 1.5 * snareTrig);
            specPower = 128.0;
        } else if (matID == 3.0) {
            // Reactor Rings -> Snare Hit Ring (Purple)
            matColor = colSnare * (1.0 + 3.5 * snareTrig);
            specPower = 128.0;
        }
        
        vec3 ambient = matColor * SCENE_AMBIENT_BASE * ao;
        vec3 diffuse = matColor * (diff1 * 0.6 + diff2 * 0.25 + diff3 * 0.15) * ao;
        
        vec3 vDir = -rd;
        vec3 h1 = normalize(l1 + vDir);
        float spec1 = pow(max(dot(n, h1), 0.0), specPower);
        vec3 specular = specColor * spec1 * specStrength * diff1 * ao;
        
        col = ambient + diffuse + specular;
        
        // Volumetric Distance Fog synchronized to sub-bass (Blue) and snare (Purple)
        float fogDist = clamp(t / 40.0, 0.0, 1.0);
        vec3 fogColor = mix(bgVoid, colBass * 0.2, subBassTrig * 0.6);
        fogColor += colSnare * 0.15 * snareTrig;
        col = mix(col, fogColor, fogDist);
    }
    
    // Core volumetric glow additive pass
    col += colBass * coreGlow * (1.0 + 2.0 * subBassTrig);
    col += colSnare * coreGlow * 1.5 * snareTrig;
    
    fragColor = vec4(col, 1.0);
}

// ==== Buffer B (buffer) ====
// Buffer B - Dedicated Multi-Tap Gaussian Blur & Bloom Pass
// Fully Controlled via Define Knobs for EVERYTHING!

#define PI 3.14159265359

// ============================================================================
// 🎛️ BUFFER B BLOOM & BLUR DEFINE CONTROL PANEL
// ============================================================================
#define BLOOM_THRESHOLD       0.15  // Threshold brightness before pixels bleed into bloom
#define BLOOM_RADIUS          4.14   // Multi-tap Gaussian blur spread radius
// ============================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    
    // Multi-tap 9x9 Separable Gaussian Blur Kernel Weights
    float weights[5] = float[5](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
    
    // 1. High-Pass Threshold Extract from Buffer A (iChannel0)
    vec3 centerSample = texture(iChannel0, uv).rgb;
    vec3 bloomCol = max(centerSample - BLOOM_THRESHOLD, vec3(0.0)) * weights[0];
    
    // 2. Horizontal & Vertical Multi-Tap Gaussian Blur Taps across Buffer A
    for (int i = 1; i < 5; i++) {
        float offset = float(i) * BLOOM_RADIUS;
        
        vec3 sH1 = texture(iChannel0, uv + vec2(offset * texel.x, 0.0)).rgb;
        vec3 sH2 = texture(iChannel0, uv - vec2(offset * texel.x, 0.0)).rgb;
        vec3 sV1 = texture(iChannel0, uv + vec2(0.0, offset * texel.y)).rgb;
        vec3 sV2 = texture(iChannel0, uv - vec2(0.0, offset * texel.y)).rgb;
        
        vec3 bH1 = max(sH1 - BLOOM_THRESHOLD, vec3(0.0));
        vec3 bH2 = max(sH2 - BLOOM_THRESHOLD, vec3(0.0));
        vec3 bV1 = max(sV1 - BLOOM_THRESHOLD, vec3(0.0));
        vec3 bV2 = max(sV2 - BLOOM_THRESHOLD, vec3(0.0));
        
        bloomCol += (bH1 + bH2 + bV1 + bV2) * weights[i] * 0.5;
    }
    
    fragColor = vec4(bloomCol, 1.0);
}
