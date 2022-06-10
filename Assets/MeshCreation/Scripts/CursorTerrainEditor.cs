using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CursorTerrainEditor : MonoBehaviour
{
    public MeshEditor1 customTerrain;
    
    public bool CanEdit = true;
    public bool CanDelete = false; 

    //terrain 
    [SerializeField]
    GameObject terrain;
    
    //edge
    [SerializeField]
    GameObject edge;
    //Edge Terrain 
    public EdgeEditor et;
    //edge Mesh 
    Mesh em; 
    //terrain Mesh
    Mesh tm; 


    //vertex index in edge list 
    int vi = -1;

    private void Start()
    {
        if (!edge.GetComponent<MeshFilter>() || !edge.GetComponent<MeshRenderer>()) //If you havent got any meshrenderer or filter
        {
            edge.gameObject.AddComponent<MeshFilter>();
            edge.gameObject.AddComponent<MeshRenderer>();
        }

        em = edge.GetComponent<MeshFilter>().mesh;

        if (!terrain.GetComponent<MeshFilter>() || !terrain.GetComponent<MeshRenderer>()) //If you havent got any meshrenderer or filter
        {
            terrain.gameObject.AddComponent<MeshFilter>();
            terrain.gameObject.AddComponent<MeshRenderer>();
        }

        tm = terrain.GetComponent<MeshFilter>().mesh;
    }
    void Update()
    {
        Vector3 mousePos = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0));
        mousePos = new Vector3(mousePos.x, mousePos.y, 0);
        

        if (CanEdit && Input.GetKey(KeyCode.Mouse0))
        {
            et.editMade = false;
            //if vi == -1 
            if (vi == -1)
            {
                int onVert = et.isOnEdgeV(mousePos);
                int nearVert = et.isNearEdgeV(mousePos);

                //if on vert, make it the point to edit
                if (onVert != -1) 
                    vi = onVert;

                //else if within distance of vert, or there are no verts
                //add vert 
                else if (nearVert != -1 || !et.vertExists())
                    vi = et.AddEdgeV(mousePos);
            }
            //if vi != -1, move the vert
            if (vi != -1)
            {
                et.UpdateEdgeV(vi, mousePos);
                et.editMade = true;
            }
            et.DrawEdge(); 
        }
        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            vi = -1;
            et.editMade = false;
        }

        et.ConstructEdgeMesh(em);
        et.calcCurve(tm, terrain);
        //vi = et.isOnEdgeV(mousePos);

        if (CanDelete && Input.GetKeyDown(KeyCode.Mouse0))
        {
            et.RemoveEdgeV(mousePos);
            et.DrawEdge();
            et.ConstructEdgeMesh(em);
            et.calcCurve(tm, terrain);
        }

    }
}
