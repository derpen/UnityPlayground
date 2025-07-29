Shader "Custom/Water" {
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaveSpeed("WaveSpeed", Range(0.0, 10.0)) = 4.0
        _Tess ("Tessellation", Range(1,32)) = 4
		_MinTessDistance("Min Dist Distance", Range(0.0, 1000.0)) = 5.0
		_MaxTessDistance("Max Dist Distance", Range(0.0, 1000.0)) = 25.0
        _HeightMap ("Height Map", 2D) = "white" {}
		_Metallic ("Metallic", Range(0, 1)) = 0.0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
        #pragma target 4.6
        #include "Tessellation.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;
		float _MinTessDistance;
		float _MaxTessDistance;

        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinTessDistance, _MaxTessDistance, _Tess);
        }

        sampler2D _HeightMap;
        float4 _HeightMap_ST;
		float _WaveSpeed;

        void disp (inout appdata v)
        {
			// Wave ?
			// float timeScale = sin(_Time.y * _WaveSpeed); // Time since level load (t/20, t, t*2, t*3), use to animate things inside the shaders. (Idk why they do it like this)
			float timeScale = _Time.y * _WaveSpeed;
			v.texcoord.x += timeScale / 2.0;
			v.texcoord.y += timeScale / 2.0;

            float4 texCoord = float4(v.texcoord.xy, 0, 0); // what even is this lol
            float height = tex2Dlod(_HeightMap, texCoord).x;
            v.vertex.y += height;
        }

        fixed4 _Color;
		half _Metallic;
        half _Smoothness;

		struct Input {
			// Not sure what is this for
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = _Color;
            o.Albedo = c.rgb;

			// float4 texCoord = fixed4(IN.uv_MainTex.x, IN.uv_MainTex.y, 0, 0);
			float4 normal = tex2D(_HeightMap, IN.uv_MainTex);

			o.Normal = normal.rgb;

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
