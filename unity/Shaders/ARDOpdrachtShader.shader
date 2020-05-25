Shader "Cg basic shader" { // defines the name of the shader
    Properties{
    }
   SubShader { // Unity chooses the subshader that fits the GPU best
      Pass { // some shaders require multiple passes
         Tags { "LightMode" = "ForwardBase" } 
         CGPROGRAM // here begins the part in Unity's Cg

         
         #pragma vertex vert 
         #pragma fragment frag
         #include "UnityCG.cginc"
 
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         uniform float4 _Color; // define shader property for shaders

         uniform float _roll;
         uniform float _pitch;
         uniform float _yaw;
         uniform float _temp;
         
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
         };
        float4 RotateAroundInDegrees (float4 vertex, float3 degrees){
                     degrees[0] = (degrees[0] * -1) * 3.14159265359 / 180.0;  // yaw, a
                     degrees[1] = degrees[1] * 3.14159265359 / 180.0;  // pitch, b
                     degrees[2] = (degrees[2] * -1) * 3.14159265359 / 180.0;  // roll, g
                     float3 sin, cos;
                     sincos(degrees, sin, cos);
                     float3x3 m = float3x3(  cos[0] * cos[1],  cos[0] * sin[1] * sin[2] - sin[0] * cos[2],  cos[0] * sin[1] * cos[2] + sin[0] * sin[2],
                                             sin[0] * cos[1],  sin[0] * sin[1] * sin[2] + cos[0] * cos[2],  sin[0] * sin[1] * cos[2] - cos[0] * sin[2],
                                            -sin[1],           cos[1] * sin[2],                             cos[1] * cos[2]
                     );
                     return float4(mul(m, vertex.xyz), vertex.w).xyzw;
                 }
        
         vertexOutput vert(vertexInput input) 
            // vertex shader 
         {
            vertexOutput output;
            // color has to be calculated here so that it can be applied in the deffuse lighting
            float red = 0;
            float green = 0;
            float middleTemp = 25;
            float highTemp = 35;
            float scaledValue = (_temp - middleTemp) / (highTemp - middleTemp);
            if (_temp > middleTemp){
                green = 1.0 - scaledValue;
                red = 1.0;
            }
            else{
                red = scaledValue;
                green = 1.0;
            }

            float4 _Color = float4(red, green, 0.0, 1.0);

            float4 rotation = RotateAroundInDegrees(input.vertex, float3(_yaw, _pitch, _roll));
            output.pos = UnityObjectToClipPos(rotation);
            float4 normal = RotateAroundInDegrees(float4(input.normal, 0.0), float3(_yaw, _pitch, _roll));
            
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float3 normalDirection = normalize(
               mul(normal, modelMatrixInverse).xyz);
            // alternative: 
            // float3 normalDirection = UnityObjectToWorldNormal(input.normal);
            float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 
            float3 diffuseReflection = _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            output.col = float4(diffuseReflection, 1.0);
            
            return output;
              // this line transforms the vertex input parameter 
              // and returns it as a nameless vertex output parameter 
              // (with semantic SV_POSITION)
         }

         float4 frag(vertexOutput input) : COLOR // fragment shader
         {
            return input.col;
               // this fragment shader returns a nameless fragment
               // output parameter (with semantic COLOR) that is set to
               // opaque red (red = 1, green = 0, blue = 0, alpha = 1)
         }

         ENDCG // here ends the part in Cg 
      }
   }
   Fallback "Diffuse"
}