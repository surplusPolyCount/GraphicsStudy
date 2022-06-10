using UnityEngine;
using System.Collections.Generic;
using System.Collections;

/*okay so we no officially have a way to generate edges appropriatley 
 * uhhh what do we do now? 
 * piss, then come back to this 
 * 
 * OBJECTIVES: 
 *  - get a "line" to be drawn between points, 
 *      take array of top y points and use it to build the lines 
 *  - get a curve to be drawn based off of points
 */

public class EdgeEditor : MonoBehaviour
{
    private List<Vector3> edgeV;
    private float dist = 3.0f;
    private int edgeVCnt = 0;
    private int edgeVMax = 30; 
    [SerializeField]
    private GameObject vertSprite;
    public bool editMade;
    public Material edgeMaterial;
    public Material terrainMaterial;

    public GameObject[] collidables;
    private Camera mCam; 
    private void Awake()
    {
        collidables = GameObject.FindGameObjectsWithTag("collidable");
        edgeV = new List<Vector3>();
        mCam = Camera.main; 
    }

    private bool CheckIfColliding(Vector3 mousePos)
    {
        foreach(GameObject col in collidables)
        {
            //Debug.Log("found collider at: " + mCam.ScreenToWorldPoint(col.GetComponent<Collider>().bounds.center));
        }
        return false; 
    }
    public int AddEdgeV(Vector3 mousePos){
        if (CheckIfColliding(mousePos))
        {
            return -1; 
        }
        if (edgeVCnt < edgeVMax) {
            if (edgeVCnt == 0) {
                edgeV.Add(mousePos);
                edgeVCnt += 1;
                return 0;
            }
            else if (Vector3.Distance(mousePos, edgeV[edgeVCnt - 1]) < dist) {
                edgeV.Add(mousePos);
                edgeVCnt += 1;
                return edgeVCnt - 1;
            } 
        }
        return -1;
    }

    public void RemoveEdgeV(Vector3 mousePos)
    {
        int ind = isOnEdgeV(mousePos);
        if (ind == -1) { return; }
        else { 
            edgeV.Remove(edgeV[ind]);
            Destroy(GameObject.Find("vert" + ind)); 
            edgeVCnt--;
        }
        for (int i = 0; i < edgeV.Count; i++)
            Debug.Log(edgeV[i]);
    }
    public void UpdateEdgeV(int i, Vector3 mousePos){ 
      //  if(i == 0 || Vector3.Distance(edgeV[i-1], mousePos) < dist)
            edgeV[i] = mousePos;
    }

    public int isOnEdgeV(Vector3 mousePos){
        for(int  i = 0; i < edgeVCnt; i++){
            float distanceFromPnt = Vector3.Distance(edgeV[i], mousePos);
            if (distanceFromPnt < 0.3f)
                return i; 
        }
        return -1; 
    }
    
    public int isNearEdgeV(Vector3 mousePos)
    {
        for (int i = 0; i < edgeVCnt; i++)
        {
            float distanceFromPnt = Vector3.Distance(edgeV[i], mousePos);
            if (distanceFromPnt < dist)
                return i;
        }
        return -1;
    }

    public bool vertExists() { return edgeVCnt != 0; }

    public void DrawEdge()
    {
        int i = 0;
        foreach (Vector3 vert in edgeV)
        {
            string name = "vert" + i;
            Destroy(GameObject.Find(name));
            GameObject vertViz = Instantiate(vertSprite, vert, Quaternion.Euler(Vector3.right * -90));
            vertViz.name = name; 
            i++;  
        }
    }

    public void ConstructEdgeMesh(Mesh m, List<Vector3> edge = null)
    {
        if (edge == null) { cem(m, edgeV, 0.075f); }
        else{cem(m, edge, 0.35f); }
    }

    public void sortByX(List<Vector3> e)
    {
        for (int i = 0; i < e.Count; i++)
        {
            for (int j = i + 1; j < e.Count; j++)
            {
                if(e[i].x > e[j].x)
                {
                    Vector3 tmp = e[i];
                    e[i] = e[j];
                    e[j] = tmp;
                }
            }
        }
    }
    public void cem(Mesh m, List<Vector3> e, float eWidth)
    {
        if (transform.gameObject.name == "edge")
        {
            transform.gameObject.GetComponent<MeshRenderer>().material = edgeMaterial;
        }
        int quadCnt = e.Count - 1;

        //quadCnt -= 1;
        if (quadCnt - 1 < 0)
        {
            Debug.Log("must request at least one quad");
            return;
        }
        int vSize = 4 + (quadCnt-1) * 2;
        //int tSize = 6 * (quadCnt + 1);
        int tSize = 6 * (quadCnt);
        //Debug.Log(vSize + " compared to: " + e.Count);

        Vector3[] v = new Vector3[vSize];
        int[] t = new int[tSize];

        //top left of quad
        /*v[0] = bottom left
        *v[1] = top left 
        *v[2] = bottom right
        *v[3] = top right
        */

        Vector3 tl = transform.InverseTransformPoint(e[0]);
        Vector3 tr = transform.InverseTransformPoint(e[1]);
        Vector3 bi = Vector3.zero;

        /*
        if (e.Count > 3)
        {
            
            bi = ((tl-tr).normalized + (transform.InverseTransformPoint(e[3]) - tr).normalized).normalized;
            Debug.Log("tl-tr: " + (tl - tr).normalized);
            Debug.Log("e2-tr: " + (transform.InverseTransformPoint(e[3]) - tr).normalized);

        }
        else
        {*/
            bi.x = -(tr.y - tl.y);
            bi.y = (tr.x - tl.x);
        //}
        if (m.name == "edge")
        {
            //Debug.Log("material now b: ");
        }

        bi = bi.normalized;
        if (bi != Vector3.zero)
        {
            bi *= eWidth / Mathf.Sqrt(bi.x * bi.x + bi.y * bi.y);
        } else {Debug.Log("ZERO DIVISION?");}

        //origin = tl - bi/2 
        /*v[0] = bottom left
         *   origin - bi/2
         *v[1] = top left 
         *   origin + bi/2
         *v[2] = bottom right
         *   origin -bi/2
         *v[3] = top right
         *   origin + bi/2
         */
        v[0] = tl - bi/2;
        v[1] = tl + bi/2;

        v[2] = tr - bi/2;
        v[3] = tr + bi/2;

        Debug.DrawRay(transform.TransformPoint(tr), bi, Color.green);

        tr = transform.TransformPoint(tl);
        /* DEBUG */
        if (bi.y > 0)
        {
            if (bi.x > 0) { Debug.DrawRay((tl - bi / 2), bi, Color.red); }
            else { Debug.DrawRay((tl - bi / 2), bi, Color.yellow); }
        }
        else
        {
            if (bi.x > 0) { Debug.DrawRay((tl - bi / 2), bi, Color.blue); }
            else { Debug.DrawRay((tl - bi / 2), bi, Color.green); }
        }

        int q = 1; 
        for (int i = 4; i + 2 <= vSize; i += 2)
        {
            q += 1;
            tr = transform.InverseTransformPoint(e[q]);
            tl = transform.InverseTransformPoint(e[q - 1]);
            /*
            if (q + 1 < e.Count && false){
                bi = ((tl - tr).normalized + (transform.InverseTransformPoint(e[q + 1]) - tr).normalized);
            }
            else {*/
                bi.x = -(tl.y - tr.y);
                bi.y = (tl.x - tr.x);
            //}
            bi = bi.normalized;
            bi *= eWidth / Mathf.Sqrt(bi.x * bi.x + bi.y * bi.y);

            v[i + 1] = tr + bi/2;
            v[i] = tr - bi/2;

            /* DEBUG */

            float k = i;
            float d = vSize;
            Color custom = new Color(i % 4, 0.0f, 1.0f);
            
            if (m.name != "edge" && (q/10)%2 == 1)
            {

                //Debug.Log(q / 10);

                Debug.DrawLine(tl + Vector3.up, tr + Vector3.up, custom);
            }

            Debug.DrawLine(tl, tr, custom);

            if (bi.y > 0) {
                if (bi.x > 0) { Debug.DrawRay((tr - bi/2), bi, Color.red); }
                else { Debug.DrawRay((tr - bi / 2), bi, Color.yellow); }
            }
            else {
                if (bi.x > 0) { Debug.DrawRay((tr - bi/2), bi, Color.blue); }
                else { Debug.DrawRay((tr - bi / 2), bi, Color.green); }
            }
        }

        //SORT INDEXES FOR VERTICES TO MAKE TRIANGLES
        int tIdx = 0;
        for (int j = 0; j + 6 <= tSize; j += 6)
        {

            int[] ind = new int[] { tIdx, tIdx + 1, tIdx + 2, tIdx + 3 };

         

            for (int s = 0; s < 2; s++){
                for(int r = s+1; r < 4; r++){
                    if(v[ind[s]].x > v[ind[r]].x){
                        int tmp = ind[s];
                        ind[s] = ind[r];
                        ind[r] = tmp; 
                    }
                }
            }

            if(v[ind[0]].y > v[ind[1]].y){
                int tmp = ind[0];
                ind[0] = ind[1];
                ind[1] = tmp;
            }

            if (v[ind[2]].y > v[ind[3]].y){
                int tmp = ind[2];
                ind[2] = ind[3];
                ind[3] = tmp;
            }

            //lower left triangle
            t[j    ] = ind[0];
            t[j + 1] = ind[1];
            t[j + 2] = ind[2];

            //upper right 
            t[j + 3] = ind[1];
            t[j + 4] = ind[3];
            t[j + 5] = ind[2];

            tIdx += 2;
        }

        Vector3[] n = new Vector3[vSize]; 
        for(int i = 0; i < vSize; i++)
            n[i] = Vector3.forward; 
        

        m.vertices = v;
        m.triangles = t;
        //m.normals = n;
    }

    private void CreateEdge(EdgeCollider2D c, List<Vector3> e)
    {
        List<Vector2> res = new List<Vector2>();
        for (int i = 0; i + 2 < e.Count; i += 2)
        {
            Vector3 pt = transform.InverseTransformPoint(e[i]);
            Vector2 p = new Vector2(pt.x, pt.y);
            res.Add(p);
        }
        c.SetPoints(res); 
    }

    public void calcCurve(Mesh m, GameObject terrain)
    {
        if(edgeVCnt <= 1 || !editMade) { return; }
        List<Vector3> ew = new List<Vector3>();
        //Debug.Log(edgeVCnt);
        for(int  q = 0; q < edgeVCnt; q++)
        {
            ew.Add(transform.TransformPoint(edgeV[q]));
        }
        List<Vector3> e = BezierCurveCalculator.calculateBezierCurve(ew, ew.Count * 10);
       
        ConstructEdgeMesh(m, e);

        //update the edge mesh collider: 
        if(terrain.name == "terrain")
        {
            //Debug.Log("got the terrain!"); 
            EdgeCollider2D ec = terrain.GetComponent<EdgeCollider2D>();
            CreateEdge(ec, e);
        }
    }

}



/*v[0] = bottom left
 *v[1] = top left 
 *v[2] = bottom right
 *v[3] = top right
 */

/*
t[j] = tIdx;
t[j + 1] = tIdx + 3;
t[j + 2] = tIdx + 2;

t[j + 3] = tIdx;
t[j + 4] = tIdx + 1;
t[j + 5] = tIdx + 3;
*/

//we need to procces the triangle vertecies before we do this bullshit 
/*
 0 = bottom left
 1 = top right
 2 = bottom right

 3 = bottom left 
 4 = top left 
 5 = top right

(array, offset)     
//sort by x value
for (int i = 0; i < 2; i++) 
   for(int j = i; i < 4; j++)
        if (v[i].x > v[j].x)
            swap (v, i, j)

//two left most
if(v[0].y > v[1].y)
    swap 

//two right most 
if(v[1].y > v[2].y) 
    swap 
*/
