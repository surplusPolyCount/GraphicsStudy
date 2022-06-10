using UnityEngine;
using System.Collections.Generic;
using System.Collections;

public class MeshEditor1 : MonoBehaviour
{
    //number of quads to make
    public int quadCnt = 15;

    //vertices in world position
    public Vector3[] vw;

    //array of vertices
    private Vector3[] v;
    //array of vertices for edge collider2D
    private List<Vector2> ve; 

    //array of vector indices to build tris
    private int[] t;
    private Mesh m; 
    void Start()
    {
        //initialize arrays 
        int vSize = 4 + quadCnt * 2;
        v = new Vector3[vSize];
        int tSize = 6 * (quadCnt + 1);
        t = new int[tSize];

        vw = new Vector3[vSize];
        ve = new List<Vector2>();
        //set position 
        Debug.Log(Camera.main.orthographicSize);
        float height = 2f * Camera.main.orthographicSize;
        float width = height * Camera.main.aspect;
        Debug.Log(height + " " + width);


        transform.position = new Vector3(-width / 2, -height / 2, 0);
        m = new Mesh();
        transform.GetComponent<MeshFilter>();

        if (!transform.GetComponent<MeshFilter>() || !transform.GetComponent<MeshRenderer>()) //If you havent got any meshrenderer or filter
        {
            transform.gameObject.AddComponent<MeshFilter>();
            transform.gameObject.AddComponent<MeshRenderer>();
        }

        transform.GetComponent<MeshFilter>().mesh = m;

        m.name = "GroundMesh";

        //constructBaseMesh(m);
        //constructEdgeList();
        Debug.Log("called");

        m.vertices = v;
        m.triangles = t;

        gameObject.GetComponent<EdgeCollider2D>().SetPoints(ve); 
    }

    //src: https://answers.unity.com/questions/36480/how-do-you-make-mesh-in-unity.html
    public void constructBaseMesh(Mesh m) {
        quadCnt -= 1;
        if (quadCnt < 0) {
            Debug.Log("must request at least one quad");
            return;
        }
        int vSize = v.Length;
        int tSize = t.Length;

        //bottom left of quad
        Vector3 bl = Vector3.zero;
        v[0] = bl;
        v[1] = bl + Vector3.up;
        v[2] = bl + Vector3.right;
        v[3] = bl + Vector3.up + Vector3.right;
        bl = v[2];
        for (int i = 4; i+2 <= vSize; i+=2)
        {
            v[i] = bl + Vector3.right;
            v[i + 1] = bl + Vector3.right + Vector3.up;
            bl = v[i];
        }

        int tIdx = 0; 
        for(int j = 0; j+6 <= tSize; j+=6)
        {
            t[j] = tIdx;
            t[j+1] = tIdx + 3;
            t[j+2] = tIdx + 2;

            t[j+3] = tIdx;
            t[j+4] = tIdx + 1;
            t[j+5] = tIdx + 3;

            tIdx += 2;
        }
        for(int q = 0; q < vSize; q++)
        {
            vw[q] = transform.TransformPoint(v[q]);
        }
    }
    
    public void constructEdgeList()
    {
        ve.Clear();
        for (int i = 1; i+2 < v.Length; i+=2)
            ve.Add(new Vector2(v[i].x, v[i].y));
    }
    public void updatePosToMouse(Vector3 mousePos, int i)
    {
        v[i] = transform.InverseTransformPoint(mousePos);
        vw[i] = mousePos;
        ve[i/2] = new Vector2(v[i].x , v[i].y); 
        m.vertices = v;
        gameObject.GetComponent<EdgeCollider2D>().SetPoints(ve);
    }
}

