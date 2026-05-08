float3 HUEtoRGB(float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}

float3 HSVtoRGB(float3 HSV)
{
    float3 RGB = HUEtoRGB(HSV.x);
    return ((RGB - 1) * HSV.y + 1) * HSV.z;
}

//uniform float Epsilon = 1e-10;
float3 RGBtoHCV(float3 RGB)
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6 * C + 1e-10) + Q.z);
    return float3(H, C, Q.x);
}
float3 RGBtoHSV(float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float S = HCV.y / (HCV.z + 1e-10);
    return float3(HCV.x, S, HCV.z);
}


float4 invertBrightness(float4 rgba) {
    float3 hsv = RGBtoHSV(rgba.rgb);
    hsv.z = 1 - hsv.z;
    float3 rgb = HSVtoRGB(hsv);
    float4 rgba_out;
    rgba.rgb = rgb;
    return rgba;
}


float4 mainImage(VertData v_in) : TARGET
{

    float4 rgba = image.Sample(textureSampler, v_in.uv);
    if (rgba.a > 0.0)
    {
        rgba = invertBrightness(rgba);
    }
    return rgba;
}
