Shader "Custom/Water" {
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaveSpeed("WaveSpeed", Range(0.0, 10.0)) = 4.0
        _Tess ("Tessellation", Range(1,32)) = 4
		_MinTessDistance("Min Dist Distance", Range(0.0, 1000.0)) = 5.0
		_MaxTessDistance("Max Dist Distance", Range(0.0, 1000.0)) = 25.0
        _HeightMap ("Height Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
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

        struct Input {
            float2 uv_HeightMap;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = _Color;
            o.Albedo = c.rgb;
            o.Specular = 0.2;
            o.Gloss = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
