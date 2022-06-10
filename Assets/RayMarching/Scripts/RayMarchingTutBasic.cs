using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Effects/Raymarch (Generic)")]
public class RayMarchingTutBasic : SceneViewFilter
{
    [SerializeField]
    private Shader _EffectShader;

    public Material EffectMaterial
    {
        get
        {
            if(!_EffectMaterial && _EffectShader)
            {
                _EffectMaterial = new Material(_EffectShader);
                _EffectMaterial.hideFlags = HideFlags.HideAndDontSave;
            }

            return _EffectMaterial; 
        }
    }
    private Material _EffectMaterial; 

    public Camera CurrentCamera
    {
        get
        {
            if (!_CurrentCamera)
                _CurrentCamera = GetComponent<Camera>();
            return _CurrentCamera;
        }
    }
    private Camera _CurrentCamera; 

    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!EffectMaterial)
        {
            Graphics.Blit(source, destination);
            return; 
        }

        EffectMaterial.SetMatrix("_FrustumCornersES", GetFrustumCorners(CurrentCamera));
        EffectMaterial.SetMatrix("_CameraInvViewMatrix", CurrentCamera.cameraToWorldMatrix);
        EffectMaterial.SetVector("_CameraWS", CurrentCamera.transform.position);

        Matrix4x4 MatSphere = Matrix4x4.TRS(
            Vector3.right * Mathf.Sin(Time.time) * 3.5f,
            Quaternion.identity,
            Vector3.one);

        Matrix4x4 MatSphere1 = Matrix4x4.TRS(
            Vector3.right * Mathf.Sin(Time.time) * 1.5f,
           Quaternion.identity,
           Vector3.one);

        Matrix4x4 MatSphere2 = Matrix4x4.TRS(
           Vector3.up * Mathf.Sin(Time.time) * 2.5f,
           Quaternion.identity,
           Vector3.one);
        EffectMaterial.SetMatrix("_MatSphere_M", MatSphere.inverse);
        EffectMaterial.SetMatrix("_MatSphere_M1", MatSphere1.inverse);
        EffectMaterial.SetMatrix("_MatSphere_M2", MatSphere2.inverse);

        CustomGraphicsBlit(source, destination, EffectMaterial, 0); //use shader as given img effect
    }

    private Matrix4x4 GetFrustumCorners(Camera cam)
    {
        float camFov = cam.fieldOfView;
        float camAspect = cam.aspect;

        Matrix4x4 frustumCorners = Matrix4x4.identity;

        float fovWHalf = camFov * 0.5f;

        float tan_fov = Mathf.Tan(fovWHalf * Mathf.Deg2Rad);

        Vector3 toRight = Vector3.right * tan_fov * camAspect;
        Vector3 toTop = Vector3.up * tan_fov;

        Vector3 topLeft = (-Vector3.forward - toRight + toTop);
        Vector3 topRight = (-Vector3.forward + toRight + toTop);
        Vector3 bottomLeft = (-Vector3.forward - toRight - toTop);
        Vector3 bottomRight = (-Vector3.forward + toRight - toTop);

        frustumCorners.SetRow(0, topLeft);
        frustumCorners.SetRow(1, topRight);
        frustumCorners.SetRow(2, bottomRight);
        frustumCorners.SetRow(3, bottomLeft);

        return frustumCorners;
    }

    static void CustomGraphicsBlit(RenderTexture source, RenderTexture dest, Material fxMaterial, int passNr)
    {
        RenderTexture.active = dest;

        fxMaterial.SetTexture("_MainTex", source);

        GL.PushMatrix();
        GL.LoadOrtho();

        fxMaterial.SetPass(passNr);

        GL.Begin(GL.QUADS);

        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);

        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);

        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);

        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }
}
