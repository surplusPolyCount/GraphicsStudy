using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotationScript : MonoBehaviour
{
    public float rotation_spd = 1.0f; 
    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0,1 * rotation_spd * Time.deltaTime,0);       
    }
}
