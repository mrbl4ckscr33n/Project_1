Texture2D<float4> gbufferD : register(t0);
SamplerState _gbufferD_sampler : register(s0);
uniform float3 eye;
uniform float3 eyeLook;
uniform float2 cameraProj;
uniform float time;
Texture2D<float4> sdetail : register(t1);
SamplerState _sdetail_sampler : register(s1);
Texture2D<float4> sbase : register(t2);
SamplerState _sbase_sampler : register(s2);
Texture2D<float4> tex : register(t3);
SamplerState _tex_sampler : register(s3);
uniform float3 ld;
Texture2D<float4> sfoam : register(t4);
SamplerState _sfoam_sampler : register(s4);
uniform float envmapStrength;

static float2 texCoord;
static float4 fragColor;
static float3 viewRay;

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 viewRay : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

float3 getPos(float3 eye_1, float3 eyeLook_1, float3 viewRay_1, float depth, float2 cameraProj_1)
{
    float linearDepth = cameraProj_1.y / (((depth * 0.5f) + 0.5f) - cameraProj_1.x);
    float viewZDist = dot(eyeLook_1, viewRay_1);
    float3 wposition = eye_1 + (viewRay_1 * (linearDepth / viewZDist));
    return wposition;
}

void frag_main()
{
    float gdepth = (gbufferD.SampleLevel(_gbufferD_sampler, texCoord, 0.0f).x * 2.0f) - 1.0f;
    if (gdepth == 1.0f)
    {
        fragColor = 0.0f.xxxx;
        return;
    }
    if (eye.z < (-0.5f))
    {
        fragColor = 0.0f.xxxx;
        return;
    }
    float3 vray = normalize(viewRay);
    float3 p = getPos(eye, eyeLook, vray, gdepth, cameraProj);
    float speed = (time * 2.0f) * 1.0f;
    p.z += (((sin(((p.x * 10.0f) / 1.0f) + speed) * cos(((p.y * 10.0f) / 1.0f) + speed)) / 50.0f) * 1.0f);
    if (p.z > (-0.5f))
    {
        fragColor = 0.0f.xxxx;
        return;
    }
    float3 v = normalize(eye - p);
    float t = (-(dot(eye, float3(0.0f, 0.0f, 1.0f)) - (-0.5f))) / dot(v, float3(0.0f, 0.0f, 1.0f));
    float3 hit = eye + (v * t);
    float2 _149 = hit.xy * 1.0f;
    hit = float3(_149.x, _149.y, hit.z);
    hit.z += (-0.5f);
    float2 tcnor0 = hit.xy / 3.0f.xx;
    float3 n0 = sdetail.SampleLevel(_sdetail_sampler, tcnor0 + float2(speed / 60.0f, speed / 120.0f), 0.0f).xyz;
    float2 tcnor1 = (hit.xy / 6.0f.xx) + (n0.xy / 20.0f.xx);
    float3 n1 = sbase.SampleLevel(_sbase_sampler, tcnor1 + float2(speed / 40.0f, speed / 80.0f), 0.0f).xyz;
    float3 n2 = normalize((((n1 + n0) / 2.0f.xxx) * 2.0f) - 1.0f.xxx);
    float ddepth = (gbufferD.SampleLevel(_gbufferD_sampler, texCoord + ((n2.xy * n2.z) / 40.0f.xx), 0.0f).x * 2.0f) - 1.0f;
    float3 p2 = getPos(eye, eyeLook, vray, ddepth, cameraProj);
    float2 _239;
    if (p2.z > (-0.5f))
    {
        _239 = texCoord;
    }
    else
    {
        _239 = texCoord + (((n2.xy * n2.z) / 30.0f.xx) * 1.0f);
    }
    float2 tc = _239;
    float fresnel = 1.0f - max(dot(n2, v), 0.0f);
    fresnel = pow(fresnel, 30.0f) * 0.449999988079071044921875f;
    float3 r = reflect(-v, n2);
    float3 refracted = tex.SampleLevel(_tex_sampler, tc, 0.0f).xyz;
    float3 _282 = lerp(refracted, 0.5f.xxx, (fresnel * 1.0f).xxx);
    fragColor = float4(_282.x, _282.y, _282.z, fragColor.w);
    float3 _290 = fragColor.xyz * float3(0.60000002384185791015625f, 0.769999980926513671875f, 1.0f);
    fragColor = float4(_290.x, _290.y, _290.z, fragColor.w);
    float3 _308 = fragColor.xyz + clamp((pow(max(dot(r, ld), 0.0f), 200.0f) * 208.0f) / 25.1327419281005859375f, 0.0f, 2.0f).xxx;
    fragColor = float4(_308.x, _308.y, _308.z, fragColor.w);
    float3 _322 = fragColor.xyz * (1.0f - clamp((-(p.z - (-0.5f))) * 0.20000000298023223876953125f, 0.0f, 0.89999997615814208984375f));
    fragColor = float4(_322.x, _322.y, _322.z, fragColor.w);
    fragColor.w = clamp(abs(p.z - (-0.5f)) * 5.0f, 0.0f, 1.0f);
    float fd = abs(p.z - (-0.5f));
    if (fd < 0.100000001490116119384765625f)
    {
        float3 foamMask0 = sfoam.SampleLevel(_sfoam_sampler, tcnor0 * 10.0f, 0.0f).xyz;
        float3 foamMask1 = sfoam.SampleLevel(_sfoam_sampler, tcnor1 * 11.0f, 0.0f).xyz;
        float3 foam = (1.0f.xxx - foamMask0.xxx) - foamMask1.zzz;
        float fac = 1.0f - (fd * 10.0f);
        float3 _380 = lerp(fragColor.xyz, clamp(foam, 0.0f.xxx, 1.0f.xxx), clamp(fac, 0.0f, 1.0f).xxx);
        fragColor = float4(_380.x, _380.y, _380.z, fragColor.w);
    }
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    texCoord = stage_input.texCoord;
    viewRay = stage_input.viewRay;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
