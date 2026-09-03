// ==== Image (image) ====
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy - 0.5;
	p.x *= iResolution.x / iResolution.y;
	p *= 1.0;
	
	vec2 z = p;
	vec2 c = vec2(-0.74543, 0.11301) + vec2(cos(iTime * 0.1 * 5.0) * 0.005, sin(iTime * 0.1 * 5.0) * 0.005);
	
	float julia = 0.0;
	for(int i = 0; i < 58; i++)
	{
		z = vec2(z.x * z.x - z.y * z.y, -1.8 * z.x * z.y) + c;
		julia += exp(-length(z));
	}
	julia /= 12.0;
	
	p *= mix(0.5, 1.5, julia);
	
	float rz = 0.0;
	vec2 flowP = p;
	float fpZ = 2.0;
	vec2 bp = flowP;
	
	mat2 m2 = mat2(0.6, 0.60, -0.60, 0.5);
	
	for (float i = 1.0; i < 7.0; i++)
	{
		bp += (iTime * 0.1) * 1.5;
		
		vec2 gr = vec2(sin(flowP.x * 2.5 - (iTime * 0.1) * 2.0) * cos(flowP.y * 3.0 - (iTime * 0.1) * 2.0), sin(flowP.x * 3.0 + 4.0 - (iTime * 0.1) * 2.0) * cos(flowP.y * 3.0 + 4.0 - (iTime * 0.1) * 2.0)) * 0.4;
		gr = normalize(gr) * 0.4;
		
		float theta = (flowP.x + flowP.y) * 0.3 + (iTime * 0.1) * 10.0;
		float cosT = cos(theta);
		float sinT = sin(theta);
		gr = gr * mat2(cosT, -sinT, sinT, cosT);
		
		flowP += gr * 0.5;
		
		float noiseP = dot(flowP * 0.05, vec2(127.1, 311.7));
		float noiseVal = fract(sin(noiseP) * 43758.5453);
		
		rz += (sin(noiseVal * 32.0) * 0.2 + 0.0) / fpZ;
		
		flowP = mix(bp, flowP, 0.5);
		fpZ *= 2.1;
		flowP *= 4.5;
		flowP *= m2;
		bp *= 0.0;
		bp *= m2;
	}
	
	p /= exp(mod((iTime * 0.1) * 3.0, 2.1));
	
	float spirR = log(length(p));
	float spirA = atan(p.y, p.x);
	float spirVal = abs(mod(15.0 * (spirR - 2.0 / 15.0 * spirA), 6.2831853) - 1.0) * 2.0;
	
	rz *= (1.0 - spirVal) * 1.0;
	
	vec3 col = vec3(0.2, 0.07, 0.01) / rz;
	col = pow(abs(col), vec3(5.03));
	
	fragColor = vec4(col, 1.0);
}
