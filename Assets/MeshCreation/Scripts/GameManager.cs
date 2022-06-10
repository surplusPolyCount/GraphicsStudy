using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public bool canEditTerrain = true;
    public GameObject terrain; 
    public GameObject ball;
    public GameObject goal;
    public GameObject stars; 
    bool isPlaying = false;

    public GameObject StarExplosion; 

    private void Start()
    {
        ball = GameObject.Find("player");
        terrain = GameObject.Find("terrainCtrl");
        goal = GameObject.Find("Goal");
    }

    private void Update()
    {
        if (isPlaying)
        {
            Debug.Log("distance: " + Vector3.Distance(ball.transform.position, goal.transform.position));
            if(Vector3.Distance(ball.transform.position, goal.transform.position) < 1.5f && (ball.transform.position.y - goal.transform.position.y) > 0)
            {
                Debug.Log("Did it!");
                if(GameObject.Find("stars") == null && GameObject.Find("stars(Clone)") == null)
                    Instantiate(stars, goal.transform.position, Quaternion.identity);
                GameObject.Destroy(GameObject.Find("berry"));
               
            }
        }
    }
    public void Play()
    {
        terrain.GetComponent<CursorTerrainEditor>().CanEdit = false;
        ball.GetComponent<Rigidbody2D>().bodyType = RigidbodyType2D.Dynamic;
        isPlaying = true; 
    }

    public void ZoomIn()
    {
        if (Camera.main.orthographicSize >= 4.5)
            Camera.main.orthographicSize -= 0.5f; 
    }

    public void ZoomOut()
    {
        if (Camera.main.orthographicSize <= 6.5)
            Camera.main.orthographicSize += 0.5f;
    }

    public void Edge()
    {
        terrain.GetComponent<CursorTerrainEditor>().CanEdit = true;
        terrain.GetComponent<CursorTerrainEditor>().CanDelete = false;

    }

    public void Delete()
    {
        terrain.GetComponent<CursorTerrainEditor>().CanEdit = false;
        terrain.GetComponent<CursorTerrainEditor>().CanDelete = true;
    }

    public void Booster()
    {
        terrain.GetComponent<CursorTerrainEditor>().CanEdit = false;
        terrain.GetComponent<CursorTerrainEditor>().CanDelete = false;
    }
}
