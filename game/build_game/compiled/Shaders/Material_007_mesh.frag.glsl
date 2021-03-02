#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec2 texCoord;
in vec3 wnormal;
out vec4 fragColor[2];
uniform sampler2D ImageTexture;

vec3 brightcontrast(const vec3 col, const float bright, const float contr) {
    float a = 1.0 + contr;
    float b = bright - contr * 0.5;
    return max(a * col + b, 0.0);
}

void main() {
	vec3 n = normalize(wnormal);
	vec4 ImageTexture_texread_store = texture(ImageTexture, texCoord.xy);
	ImageTexture_texread_store.rgb = pow(ImageTexture_texread_store.rgb, vec3(2.2));
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	vec3 ImageTexture_Color_res = ImageTexture_texread_store.rgb;
	vec3 Bright_Contrast_Color_res = brightcontrast(ImageTexture_Color_res, 0.0, -0.29999998211860657);
	float RGBCurves0_ys[3];
	RGBCurves0_ys[0] = 0.0;
	RGBCurves0_ys[1] = 0.7812506556510925;
	RGBCurves0_ys[2] = 1.0;
	float RGBCurves0_fac = Bright_Contrast_Color_res.x;
	int RGBCurves0_i = 0 + (RGBCurves0_fac > 0.40454554557800293 ? 1 : 0) + (RGBCurves0_fac > 1.0 ? 1 : 0);
	float RGBCurves0_xs[3];
	RGBCurves0_xs[0] = 0.0;
	RGBCurves0_xs[1] = 0.40454554557800293;
	RGBCurves0_xs[2] = 1.0;
	float RGBCurves1_ys[3];
	RGBCurves1_ys[0] = 0.0;
	RGBCurves1_ys[1] = 0.556249737739563;
	RGBCurves1_ys[2] = 1.0;
	float RGBCurves1_fac = Bright_Contrast_Color_res.y;
	int RGBCurves1_i = 0 + (RGBCurves1_fac > 0.3681820034980774 ? 1 : 0) + (RGBCurves1_fac > 1.0 ? 1 : 0);
	float RGBCurves1_xs[3];
	RGBCurves1_xs[0] = 0.0;
	RGBCurves1_xs[1] = 0.3681820034980774;
	RGBCurves1_xs[2] = 1.0;
	float RGBCurves2_ys[2];
	RGBCurves2_ys[0] = 0.0;
	RGBCurves2_ys[1] = 1.0;
	float RGBCurves2_fac = Bright_Contrast_Color_res.z;
	int RGBCurves2_i = 0 + (RGBCurves2_fac > 1.0 ? 1 : 0);
	float RGBCurves2_xs[2];
	RGBCurves2_xs[0] = 0.0;
	RGBCurves2_xs[1] = 1.0;
	float RGBCurves3a_ys[2];
	RGBCurves3a_ys[0] = 0.0;
	RGBCurves3a_ys[1] = 1.0;
	float RGBCurves3a_fac = Bright_Contrast_Color_res.x;
	int RGBCurves3a_i = 0 + (RGBCurves3a_fac > 1.0 ? 1 : 0);
	float RGBCurves3a_xs[2];
	RGBCurves3a_xs[0] = 0.0;
	RGBCurves3a_xs[1] = 1.0;
	float RGBCurves3b_ys[2];
	RGBCurves3b_ys[0] = 0.0;
	RGBCurves3b_ys[1] = 1.0;
	float RGBCurves3b_fac = Bright_Contrast_Color_res.y;
	int RGBCurves3b_i = 0 + (RGBCurves3b_fac > 1.0 ? 1 : 0);
	float RGBCurves3b_xs[2];
	RGBCurves3b_xs[0] = 0.0;
	RGBCurves3b_xs[1] = 1.0;
	float RGBCurves3c_ys[2];
	RGBCurves3c_ys[0] = 0.0;
	RGBCurves3c_ys[1] = 1.0;
	float RGBCurves3c_fac = Bright_Contrast_Color_res.z;
	int RGBCurves3c_i = 0 + (RGBCurves3c_fac > 1.0 ? 1 : 0);
	float RGBCurves3c_xs[2];
	RGBCurves3c_xs[0] = 0.0;
	RGBCurves3c_xs[1] = 1.0;
	vec3 RGBCurves_Color_res = (sqrt(vec3(mix(RGBCurves0_ys[RGBCurves0_i], RGBCurves0_ys[RGBCurves0_i + 1], (RGBCurves0_fac - RGBCurves0_xs[RGBCurves0_i]) * (1.0 / (RGBCurves0_xs[RGBCurves0_i + 1] - RGBCurves0_xs[RGBCurves0_i]) )), mix(RGBCurves1_ys[RGBCurves1_i], RGBCurves1_ys[RGBCurves1_i + 1], (RGBCurves1_fac - RGBCurves1_xs[RGBCurves1_i]) * (1.0 / (RGBCurves1_xs[RGBCurves1_i + 1] - RGBCurves1_xs[RGBCurves1_i]) )), mix(RGBCurves2_ys[RGBCurves2_i], RGBCurves2_ys[RGBCurves2_i + 1], (RGBCurves2_fac - RGBCurves2_xs[RGBCurves2_i]) * (1.0 / (RGBCurves2_xs[RGBCurves2_i + 1] - RGBCurves2_xs[RGBCurves2_i]) ))) * vec3(mix(RGBCurves3a_ys[RGBCurves3a_i], RGBCurves3a_ys[RGBCurves3a_i + 1], (RGBCurves3a_fac - RGBCurves3a_xs[RGBCurves3a_i]) * (1.0 / (RGBCurves3a_xs[RGBCurves3a_i + 1] - RGBCurves3a_xs[RGBCurves3a_i]) )), mix(RGBCurves3b_ys[RGBCurves3b_i], RGBCurves3b_ys[RGBCurves3b_i + 1], (RGBCurves3b_fac - RGBCurves3b_xs[RGBCurves3b_i]) * (1.0 / (RGBCurves3b_xs[RGBCurves3b_i + 1] - RGBCurves3b_xs[RGBCurves3b_i]) )), mix(RGBCurves3c_ys[RGBCurves3c_i], RGBCurves3c_ys[RGBCurves3c_i + 1], (RGBCurves3c_fac - RGBCurves3c_xs[RGBCurves3c_i]) * (1.0 / (RGBCurves3c_xs[RGBCurves3c_i + 1] - RGBCurves3c_xs[RGBCurves3c_i]) )))) * 1.0);
	basecol = RGBCurves_Color_res;
	roughness = 0.2818182110786438;
	metallic = 0.3545454740524292;
	occlusion = 1.0;
	specular = 0.5;
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	const uint matid = 0;
	fragColor[0] = vec4(n.xy, roughness, packFloatInt16(metallic, matid));
	fragColor[1] = vec4(basecol, packFloat2(occlusion, specular));
}
