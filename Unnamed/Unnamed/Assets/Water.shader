Shader "Custom/Water" {
	Properties
    {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_HeightMap ("Height Map", 2D) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

			sampler2D _HeightMap;
			float4 _MainTex_ST;

            float4 _Color;
			float GetTime(float speed)
			{
				return sin(_Time.y * speed); // Time since level load (t/20, t, t*2, t*3), use to animate things inside the shaders. (Idk why they do it like this)
			}
            
            v2f vert (appdata v)
            {
                v2f o;

				// Try to do wave here
				// float speed = 3.0;
				// float wave = GetTime(speed);
				float wave = _Time.y;

				v.uv.x += wave / 2.0;
				v.uv.y += wave / 2.0;

				float4 texCoord = float4(v.uv.x, v.uv.y, .0, 0);
				float height = tex2Dlod (_HeightMap, texCoord).x;
				v.vertex.y += height;

				// Built in shit to apply the uv
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = _Color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
