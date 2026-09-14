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
    vec3 p, R = iResolution, D = vec3((u+u-R.xy)/R.y, 1);
    o -= o;
    for(float i, d=.5, s, h, a, j; i++ < 1e2; o += (0.5+0.5*cos(i*.15+iTime+vec4(0,1,2,0))) * .06/(h+.01)) {
        p = D * d;
        p.z = mod(p.z + iTime*2., 4.) - 2.;
        a = p.z*.2 + iTime*.1;
        p.xy *= mat2(cos(a), sin(a), -sin(a), cos(a));
        for(j=0., s=1.1; j++ < 7.; s *= 1.12)
            p = abs(p)/dot(p,p) - .75,
            p.yz *= mat2(.9, .4, -.4, .9);
        d += max(h = length(p.xy)*s, .15) * .1;
    }
    o = tanh(mix(o, o.zyxw, length(u/R.y)) * o / 40.);
}
