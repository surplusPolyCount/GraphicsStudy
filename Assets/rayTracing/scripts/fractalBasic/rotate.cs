using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotate : MonoBehaviour
{
    public float rotateSpd;
    public bool rotX = true;
    public bool rotY = true;
    public bool rotZ = true;

    Vector3 rotateGoal;
    private void Start()
    {
        rotateGoal = new Vector3(
            Random.Range(0, 5),
            Random.Range(0, 5),
            Random.Range(0, 5)
        );
        rotateGoal = rotateGoal.normalized;
    }
    // Update is called once per frame
    void Update()
    {

        Debug.Log(rotateGoal);
        transform.Rotate(new Vector3(
            !rotX ? 0: rotateGoal.x,
            !rotY ? 0 : rotateGoal.y,
            !rotZ ? 0 : rotateGoal.z)  * rotateSpd);
    }
}
