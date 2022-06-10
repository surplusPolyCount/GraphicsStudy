using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class berryRotate : MonoBehaviour
{
    void Update()
    {
        transform.eulerAngles -= (Vector3.up * Time.deltaTime * 100.0f) ;
    }
}
