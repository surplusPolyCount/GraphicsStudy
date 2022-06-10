using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class furFuncs : MonoBehaviour
{
    public Texture2D base_ft;
    public float density; 
    private Texture2D FillFurTexture(Texture2D toCopy, float d)
    {
        //read the width and height of the texture
        Texture2D furMap = new Texture2D(toCopy.width, toCopy.height);
        int width = toCopy.width;
        int height = toCopy.height;
        int totalPixels = width * height;

        //an array to hold our pixels
        Color[] colors;
        colors = new Color[totalPixels];
        Debug.Log("total pixels: " + totalPixels);
        //random number generator

        //initialize all pixels to transparent black
       
        Color pix; 
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++) {
                pix = toCopy.GetPixel(x, y);
                colors[y * width + x] = new Color(0, 0, 0, 0);
                if(pix[0] > 0.05)
                {
                    colors[y * width + x][0] = pix[0];
                }
            }
        }

        //compute the number of opaque pixels = nr of hair strands
        
       int nrStrands = (int)(d * totalPixels);

       //fill texture with opaque pixels

       for (int i = 0; i < nrStrands; i++)
       {
           int x, y;
           //random position on the texture
           x = Random.Range(0,width);
           y = Random.Range(0,height);
           //put color (which has an alpha value of 255, i.e. opaque)
           colors[y * width + x] = toCopy.GetPixel(x, y);
       }
        /* 
        for (int y = 0; y < height; y++)
      {
          for (int x = 0; x < width; x+=2)
          {
              if (y%2 == 0 && x > 1 && x+1 < width)
              {
                  colors[y * width + x +1] = toCopy.GetPixel(x+1, y);
              }
              else
              {
                  colors[y * width + x] = toCopy.GetPixel(x, y);
              }
          }
      }
      */
        //set the pixels on the texture.
        furMap.SetPixels(colors);
        furMap.filterMode = FilterMode.Point;
        furMap.Apply();
        return furMap; 
    }
    private Texture2D GenFurHeightMap(Texture2D toCopy)
    {
        //read the width and height of the texture
        Texture2D furhm = new Texture2D(toCopy.width, toCopy.height);
        int width = toCopy.width;
        int height = toCopy.height;
        int totalPixels = width * height;

        //an array to hold our pixels
        Color[] colors;
        colors = new Color[totalPixels];
        Debug.Log("total pixels: " + totalPixels);
        //random number generator

        //initialize all pixels to transparent black
        for (int i = 0; i < totalPixels; i++)
            colors[i] = new Color(0, 0, 0, 1);

        //fill texture with opaque pixels
        //Color transp = new Color(0, 0, 0, 0);
        for (int y = 0; y< height; y++) {
            for (int x = 0; x < width; x++)
            {
                colors[y * width + x] = new Color((Random.Range(0.5f,1.0f)), 0, 0, 1.0f);
            }
        }

        //set the pixels on the texture.
        furhm.SetPixels(colors);
        furhm.Apply();
        return furhm;
    }
    private void Start()
    {
        //https://docs.unity3d.com/ScriptReference/Texture2D-ctor.html
        Renderer renderer = GetComponent<Renderer>();
        //create spots where fur won't exist
        Texture2D furMap = FillFurTexture(base_ft, density);
        //create random variation in the fur
        Texture2D furHeightMap = GenFurHeightMap(furMap);

        renderer.material.EnableKeyword("_FurTex");
        renderer.material.SetTexture("_FurTex", furMap);

        renderer.material.EnableKeyword("_FurRandomHM");
        renderer.material.SetTexture("_FurRandomHM", furHeightMap);

        //then Save To Disk as PNG
        
        byte[] bytes = furMap.EncodeToPNG();
        var dirPath = Application.dataPath + ".\\";
        File.WriteAllBytes(dirPath + "furM" + ".png", bytes);
        
    }
}
