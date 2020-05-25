Shader "Cg basic shader" { // defines the name of the shader
    Properties{
        // _xPos ("_xPos", Float) = 0.5 
    }
   SubShader { // Unity chooses the subshader that fits the GPU best
      Pass { // some shaders require multiple passes
         CGPROGRAM // here begins the part in Unity's Cg

         
         #pragma vertex vert 
            // this specifies the vert function as the vertex shader 
         #pragma fragment frag
            // this specifies the frag function as the fragment shader
         uniform float _roll;
         uniform float _pitch;
         uniform float _yaw;
         uniform float _temp;

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
        
         float4 vert(float4 vertexPos : POSITION) : SV_POSITION 
            // vertex shader 
         {
            
            return UnityObjectToClipPos(RotateAroundInDegrees(vertexPos, float3(_yaw, _pitch, _roll)));
              // this line transforms the vertex input parameter 
              // and returns it as a nameless vertex output parameter 
              // (with semantic SV_POSITION)
         }

         float4 frag(void) : COLOR // fragment shader
         {
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

            
            return float4(red, green, 0.0, 1.0); 
               // this fragment shader returns a nameless fragment
               // output parameter (with semantic COLOR) that is set to
               // opaque red (red = 1, green = 0, blue = 0, alpha = 1)
         }

         ENDCG // here ends the part in Cg 
      }
   }
}