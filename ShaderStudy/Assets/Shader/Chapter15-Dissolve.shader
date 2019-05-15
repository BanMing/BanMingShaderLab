// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BanMing/Dissolve"
{
    Properties
    {
        // 消融程度控制 0为正常效果 1为消融
        _BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
        // 控制模拟烧焦效果的线宽 值越大火焰边缘蔓延月光
        _LineWidth ("Burn Line Width" Range(0.0, 0.2)) = 0.1
        _MainTex("Base (RGB)", 2D) = "wihite" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BurnFirstColor ("Burn First Color", Color) = (1, 0, 0, 1)
        _BurnSecondColor ("Burn Second Color", Color) = (1, 0, 0, 1)
        // 噪声纹理
        _BurnMap ("Burn Map", 2D) = "wihte" { }
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Off
            
            CGPROGRAM
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uvMainTex: TEXCOORD0;
                float2 uvBumpMap: TEXCOORD1;
                float2 uvBurnMap: TEXCOORD2;
                float3 lightDir: TEXCOORD3;
                float3 worldPos: TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex)

                // 获得三个纹理对应的纹理坐标
                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                
                //  小于0会被剔除
                clip(burn.r - _BurnAmount);

                float3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));
                // 获得漫反射，反射率
                float3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);

                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 finalColor = lerp(ambient * diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));
                return fixed4(finalColor, 1)
            }
            ENDCG
            
        }
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uvBurnMap: TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                return o;
            }

            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
            
        }
    }
    FallBack "Diffuse"
}