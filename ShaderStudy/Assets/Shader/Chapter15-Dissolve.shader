// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BanMing/Dissolve"
{
    Properties
    {
        // 溶解程度
        _BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
        // 溶解渐变宽度
        _LineWidth ("Burn Line Width", Range(0.0, 0.2)) = 0.1
        _MainTex ("Base (RGB)", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        // 溶解外层颜色
        _BurnFirstColor ("Burn First Color", Color) = (1, 0, 0, 1)
        // 溶解内层颜色
        _BurnSecondColor ("Burn Second Color", Color) = (1, 0, 0, 1)
        // 噪声贴图
        _BurnMap ("Burn Map", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Off
            
            CGPROGRAM
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag
            
            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
            sampler2D _BumpMap;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;
            
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float4 _BurnMap_ST;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 tangent: TANGENT;
                float4 texcoord: TEXCOORD0;
            };
            
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
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
                
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                TRANSFER_SHADOW(o);
                
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                // 根据r通道裁剪 是否显示
                clip(burn.r - _BurnAmount);
                
                float3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));
                // 反射率
                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 获得漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                // 渐变
                // smoothstep(a,b,x),x大于a,b中最大值返回1，x小于a,b中最小值返回0，介于其间返回x
                // https://blog.csdn.net/u010333737/article/details/82859246
                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                // step(a,x) x >= a ? 1 : 0
                fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));
                
                return fixed4(finalColor, 1);
            }
            
            ENDCG
            
        }
        
        // Pass to render object as a shadow caster
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"
            
            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            
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
            
            fixed4 frag(v2f i): SV_Target
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
