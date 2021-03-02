Texture2D<float4> ImageTexture : register(t0);
SamplerState _ImageTexture_sampler : register(s0);

static float3 wnormal;
static float2 texCoord;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 wnormal : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

float3 brightcontrast(float3 col, float bright, float contr)
{
    float a = 1.0f + contr;
    float b = bright - (contr * 0.5f);
    return max((col * a) + b.xxx, 0.0f.xxx);
}

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

float packFloatInt16(float f, uint i)
{
    return (0.06248569488525390625f * f) + (0.06250095367431640625f * float(i));
}

float packFloat2(float f1, float f2)
{
    return floor(f1 * 255.0f) + min(f2, 0.9900000095367431640625f);
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float4 ImageTexture_texread_store = ImageTexture.Sample(_ImageTexture_sampler, texCoord);
    float3 _104 = pow(ImageTexture_texread_store.xyz, 2.2000000476837158203125f.xxx);
    ImageTexture_texread_store = float4(_104.x, _104.y, _104.z, ImageTexture_texread_store.w);
    float3 ImageTexture_Color_res = ImageTexture_texread_store.xyz;
    float3 Bright_Contrast_Color_res = brightcontrast(ImageTexture_Color_res, 0.0f, -0.2999999821186065673828125f);
    float RGBCurves0_ys[3];
    RGBCurves0_ys[0] = 0.0f;
    RGBCurves0_ys[1] = 0.781250655651092529296875f;
    RGBCurves0_ys[2] = 1.0f;
    float RGBCurves0_fac = Bright_Contrast_Color_res.x;
    int RGBCurves0_i = (0 + int(RGBCurves0_fac > 0.4045455455780029296875f)) + int(RGBCurves0_fac > 1.0f);
    float RGBCurves0_xs[3];
    RGBCurves0_xs[0] = 0.0f;
    RGBCurves0_xs[1] = 0.4045455455780029296875f;
    RGBCurves0_xs[2] = 1.0f;
    float RGBCurves1_ys[3];
    RGBCurves1_ys[0] = 0.0f;
    RGBCurves1_ys[1] = 0.55624973773956298828125f;
    RGBCurves1_ys[2] = 1.0f;
    float RGBCurves1_fac = Bright_Contrast_Color_res.y;
    int RGBCurves1_i = (0 + int(RGBCurves1_fac > 0.368182003498077392578125f)) + int(RGBCurves1_fac > 1.0f);
    float RGBCurves1_xs[3];
    RGBCurves1_xs[0] = 0.0f;
    RGBCurves1_xs[1] = 0.368182003498077392578125f;
    RGBCurves1_xs[2] = 1.0f;
    float RGBCurves2_ys[2];
    RGBCurves2_ys[0] = 0.0f;
    RGBCurves2_ys[1] = 1.0f;
    float RGBCurves2_fac = Bright_Contrast_Color_res.z;
    int RGBCurves2_i = 0 + int(RGBCurves2_fac > 1.0f);
    float RGBCurves2_xs[2];
    RGBCurves2_xs[0] = 0.0f;
    RGBCurves2_xs[1] = 1.0f;
    float RGBCurves3a_ys[2];
    RGBCurves3a_ys[0] = 0.0f;
    RGBCurves3a_ys[1] = 1.0f;
    float RGBCurves3a_fac = Bright_Contrast_Color_res.x;
    int RGBCurves3a_i = 0 + int(RGBCurves3a_fac > 1.0f);
    float RGBCurves3a_xs[2];
    RGBCurves3a_xs[0] = 0.0f;
    RGBCurves3a_xs[1] = 1.0f;
    float RGBCurves3b_ys[2];
    RGBCurves3b_ys[0] = 0.0f;
    RGBCurves3b_ys[1] = 1.0f;
    float RGBCurves3b_fac = Bright_Contrast_Color_res.y;
    int RGBCurves3b_i = 0 + int(RGBCurves3b_fac > 1.0f);
    float RGBCurves3b_xs[2];
    RGBCurves3b_xs[0] = 0.0f;
    RGBCurves3b_xs[1] = 1.0f;
    float RGBCurves3c_ys[2];
    RGBCurves3c_ys[0] = 0.0f;
    RGBCurves3c_ys[1] = 1.0f;
    float RGBCurves3c_fac = Bright_Contrast_Color_res.z;
    int RGBCurves3c_i = 0 + int(RGBCurves3c_fac > 1.0f);
    float RGBCurves3c_xs[2];
    RGBCurves3c_xs[0] = 0.0f;
    RGBCurves3c_xs[1] = 1.0f;
    float3 RGBCurves_Color_res = sqrt(float3(lerp(RGBCurves0_ys[RGBCurves0_i], RGBCurves0_ys[RGBCurves0_i + 1], (RGBCurves0_fac - RGBCurves0_xs[RGBCurves0_i]) * (1.0f / (RGBCurves0_xs[RGBCurves0_i + 1] - RGBCurves0_xs[RGBCurves0_i]))), lerp(RGBCurves1_ys[RGBCurves1_i], RGBCurves1_ys[RGBCurves1_i + 1], (RGBCurves1_fac - RGBCurves1_xs[RGBCurves1_i]) * (1.0f / (RGBCurves1_xs[RGBCurves1_i + 1] - RGBCurves1_xs[RGBCurves1_i]))), lerp(RGBCurves2_ys[RGBCurves2_i], RGBCurves2_ys[RGBCurves2_i + 1], (RGBCurves2_fac - RGBCurves2_xs[RGBCurves2_i]) * (1.0f / (RGBCurves2_xs[RGBCurves2_i + 1] - RGBCurves2_xs[RGBCurves2_i])))) * float3(lerp(RGBCurves3a_ys[RGBCurves3a_i], RGBCurves3a_ys[RGBCurves3a_i + 1], (RGBCurves3a_fac - RGBCurves3a_xs[RGBCurves3a_i]) * (1.0f / (RGBCurves3a_xs[RGBCurves3a_i + 1] - RGBCurves3a_xs[RGBCurves3a_i]))), lerp(RGBCurves3b_ys[RGBCurves3b_i], RGBCurves3b_ys[RGBCurves3b_i + 1], (RGBCurves3b_fac - RGBCurves3b_xs[RGBCurves3b_i]) * (1.0f / (RGBCurves3b_xs[RGBCurves3b_i + 1] - RGBCurves3b_xs[RGBCurves3b_i]))), lerp(RGBCurves3c_ys[RGBCurves3c_i], RGBCurves3c_ys[RGBCurves3c_i + 1], (RGBCurves3c_fac - RGBCurves3c_xs[RGBCurves3c_i]) * (1.0f / (RGBCurves3c_xs[RGBCurves3c_i + 1] - RGBCurves3c_xs[RGBCurves3c_i]))))) * 1.0f;
    float3 basecol = RGBCurves_Color_res;
    float roughness = 0.281818211078643798828125f;
    float metallic = 0.35454547405242919921875f;
    float occlusion = 1.0f;
    float specular = 0.5f;
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _395;
    if (n.z >= 0.0f)
    {
        _395 = n.xy;
    }
    else
    {
        _395 = octahedronWrap(n.xy);
    }
    n = float3(_395.x, _395.y, n.z);
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, 0u));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    texCoord = stage_input.texCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
