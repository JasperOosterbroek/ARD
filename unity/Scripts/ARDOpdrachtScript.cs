using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using System.IO.Ports;

public class ARDOpdrachtScript : MonoBehaviour
{   
    SerialPort stream = new SerialPort("COM4", 115200);  
    private string receivedString;
    // Start is called before the first frame update
    void Start()
    {
        try{
            stream.Open();  
        }catch(System.IO.IOException ex){
            Debug.Log(ex);
        }
        stream.ReadTimeout = 100;
    }

    // Update is called once per frame
    void Update()
    {
        
        try{
            receivedString = stream.ReadLine();
            // stream.BaseStream.Flush();
            string[] data = receivedString.Split(',');
            if(data[0] != "" && data[1] != "" && data[2] != "" && data[3] != ""){
                float temp = float.Parse(data[0], CultureInfo.InvariantCulture.NumberFormat);
                float roll = float.Parse(data[1], CultureInfo.InvariantCulture.NumberFormat);
                float pitch = float.Parse(data[2], CultureInfo.InvariantCulture.NumberFormat);
                float yaw = float.Parse(data[3], CultureInfo.InvariantCulture.NumberFormat);
                Debug.Log("roll: " +roll);
                Debug.Log("pitch: "+ pitch);
                Debug.Log("yaw: "+ yaw);
                Debug.Log("temp: "+ temp);
                Shader.SetGlobalFloat("_roll", roll);
                Shader.SetGlobalFloat("_pitch", pitch);
                Shader.SetGlobalFloat("_yaw", yaw);
                Shader.SetGlobalFloat("_temp", temp);
            }
            
            stream.BaseStream.Flush();
        }catch(System.IO.IOException ex){
            Debug.Log(ex);
        }
        
    }
}
