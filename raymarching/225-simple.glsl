// ==== Image (image) ====
//======================================================================================//
//:: [ Optimized for NVIDIA GeForce GeForce GTX 1080 Ti ] ::                            //
//======================================================================================//
//  >>  Author  : Patrick JAILLET (Sandefjord)                                          //
//  >>  Email   : metashader@proton.me                                                  //
//  >>  Engine  : MetaShader                                                            //
//  >>  URL     : https://gotoy.xo.je                                                   //
//*====================================================================================*//
void mainImage(out vec4 o, vec2 u) {
    vec3 p, d = vec3((u + u - (p = iResolution).xy) / p.y, 1);
    float i, s, e, t = iTime * .3;
    for(o -= o; i++ < 40.; ) {
        p = d * i * .1; 
        p.xy *= mat2(cos(t), sin(t), -sin(t), cos(t));
        s = 1.;
        for(int j = 0; j < 6; j++) {
            p = abs(p - 1.) - 1.;
            e = 1.8 / clamp(dot(p, p), .1, 1.2);
            p *= e;
            s *= e;
        }
        o += (cos(t + i * .05 + vec4(0, 1, 2, 0)) + 1.) * 2e-5 * s;
    }
    o = smoothstep(0., 1., pow(o, vec4(.6)));
}
