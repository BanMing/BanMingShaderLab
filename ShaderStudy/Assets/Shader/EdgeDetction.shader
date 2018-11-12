Shader "BanMing/EdgeDetction"
{
    Properties {
        _MainTex("Base(RGB)", 2D) = "white" {}
        _EdgeOnly("Edge Only", Float) = 1.0
        _EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor("Backhroung", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags {"RenderType" = "Opaque"}
        Pass {
            
            CGPROGRAM
            
            #include "UnityCG.cginc"
                #pragma vertex vert
                #pragma fragment frag
                sampler2D _MainTex; 
            float4 _MainTex_ST; 
            //一个像素的大小
            half4 _MainTex_TexelSize; 
            fixed4 _EdgeOnly; 
            fixed4 _EdgeColor; 
            fixed4 _BackgroundColor; 
            
            struct v2f {
                float4 pos : SV_POSITION; 
                half2 uv[9] : TEXCOORD0; 
            }; 
            
            //计算亮度
            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7254 * color.g + 0.0721 * color.b; 
            }

            //计算出当前像素梯度值
            half Sobel(v2f i) {
                const half Gx[9] = { - 1, - 2, - 1, 
                        0, 0, 0, 
                        1, 2, 1}; 
                const half Gy[9] = { - 1, 0, 1, 
                        - 2, 0, 2, 
                        - 1, 0, 1}; 

                half texColor; 
                half edgeX = 0; 
                half edgeY = 0; 
                for(int it = 0; it < 9; it++ ) 
                {      
                    texColor = luminance(tex2D(_MainTex, i.uv[it])); 
                    edgeX += texColor * Gx[it]; 
                    edgeY += texColor * Gy[it]; 
                }
        
                half edge = 1 - abs(edgeX) - abs(edgeY); 
                
                return edge; 
            }
            v2f vert(appdata_img v) {
                v2f o; 
                o.pos = UnityObjectToClipPos(v.vertex); 
                
                half2 uv = v.texcoord; 
                //使用Sobel算子采样时需要9个 
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2( - 1, - 1); 
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, - 1); 
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, - 1); 
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2( - 1, 0); 
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0); 
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0); 
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2( - 1, 1); 
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1); 
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1); 
                
                return o; 
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                half edge = Sobel(i); 
                
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge); 
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge); 
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly); 
            }
            
            
            
            ENDCG
        }
        
    }
    Fallback Off
}