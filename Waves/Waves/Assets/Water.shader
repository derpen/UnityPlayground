Shader "Custom/Water" {
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_WaveSpeed("WaveSpeed", Range(0.0, 10.0)) = 4.0
		_HeightScale("Height Scale", Range(0.0, 32.0)) = 1.0
		_MainTex("Height map texture", 2D) = "" {}
		_Octaves("Num. of octaves", Range(1, 32)) = 6.0
        _Tess ("Tessellation", Range(1,32)) = 4
		_MinTessDistance("Min Dist Distance", Range(0.0, 1000.0)) = 5.0
		_MaxTessDistance("Max Dist Distance", Range(0.0, 1000.0)) = 25.0
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

		// FRACTAL BROWNIAN MOTION START
		//
		//
		float hash (float2 n)
		{
			return frac(sin(dot(n, float2(123.456789, 987.654321))) * 54321.9876 );
		}

		float noise(float2 p)
		{
			float2 i = floor(p);
			float2 u = smoothstep(0.0, 1.0, frac(p));
			float a = hash(i + float2(0,0));
			float b = hash(i + float2(1,0));
			float c = hash(i + float2(0,1));
			float d = hash(i + float2(1,1));
			float r = lerp(lerp(a, b, u.x),lerp(c, d, u.x), u.y);
			return r * r;
		}

		float fbm(float2 p, int octaves)
		{
			float value = 0.0;
			float amplitude = 0.5;
			float e = 3.0;
			for (int i = 0; i < octaves; ++ i)
			{
				value += amplitude * noise(p); 
				p = p * e; 
				amplitude *= 0.5; 
				e *= 0.95;
			}
			return value;
		}
		//
		//
		// FRACTAL BROWNIAN MOTION END

		float _WaveSpeed;
		float _Octaves;
		float _HeightScale;

        void disp (inout appdata v)
        {
			float timeScale = _Time.y * _WaveSpeed;
            float height = fbm(v.texcoord + float2(timeScale, timeScale), _Octaves);
            v.vertex.y += height * _HeightScale;
		}


		sampler2D _MainTex;
        fixed4 _Color;
		half _Metallic;
        half _Smoothness;

		struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
			float timeScale = _Time.y * _WaveSpeed;
			float fbm_color = fbm(IN.uv_MainTex + float2(timeScale, timeScale), _Octaves);
			o.Normal = UnpackNormal(fixed4(fbm_color, fbm_color, fbm_color, 0.0));

			o.Albedo = _Color.rgb;

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
