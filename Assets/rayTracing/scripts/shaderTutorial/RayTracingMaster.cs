using UnityEngine;
using System.Collections.Generic;
public class RayTracingMaster : MonoBehaviour
{
    private struct Sphere
    {
        public Vector3 position;
        public float radius;
        public Vector3 albedo;
        public Vector3 specular;
    };

    public ComputeShader RayTracingShader; //shader that does the actual raytracing
    private RenderTexture _target; //final image to be rendered in game
    private Camera _camera; //camera to render image
    public Texture SkyboxTexture; //texture for skybox
    private uint _currentSample = 0; //
    private Material _addMaterial; //
    public Light DirectionalLight;
    public Vector2 SphereRadius = new Vector2(3.0f, 8.0f);
    public uint SpheresMax = 100;
    public float SpherePlacementRadius = 100.0f;
    public ComputeBuffer _sphereBuffer;
    float _startTime; 

    //get camera
    private void Awake()
    {

        _camera = GetComponent<Camera>(); //set camera
        _startTime = Time.time; 
        Debug.Log($"start at {_startTime}"); 
    }

    private void SetShaderParameters()
    {
        //dump variables into shader
        RayTracingShader.SetMatrix("_CameraToWorld", _camera.cameraToWorldMatrix); //matrix representing camera's position/orientation
        RayTracingShader.SetMatrix("_CameraInverseProjection", _camera.projectionMatrix.inverse); //matrix representing the inverse of camera's pos/orientation
        RayTracingShader.SetTexture(0, "_SkyboxTexture", SkyboxTexture);
        RayTracingShader.SetVector("_PixelOffset", new Vector2(Random.value, Random.value));

        Vector3 l = DirectionalLight.transform.forward;
        RayTracingShader.SetVector("_DirectionalLight", new Vector4(l.x, l.y, l.z, DirectionalLight.intensity));
        RayTracingShader.SetBuffer(0, "_Spheres", _sphereBuffer);
    }

    //automatically called by unity whenever the camera has finished rendering
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetShaderParameters();
        Render(destination);
        Debug.Log($"done taking: {Time.time - _startTime}");
        _startTime = Time.time; 
    }

    private void Render(RenderTexture destination)
    {
        // Make sure we have a current render target
        //create the texture to render raytracing (in this instance, the texture with dimensions of camera) 
        InitRenderTexture(); //stores result in target variable

        // Set the target and dispatch the compute shader
        RayTracingShader.SetTexture
            (0, "Result", _target); //after computing new tex, set that tex to be goal for shader
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        RayTracingShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        // Blit the result texture to the screen
        if (_addMaterial == null)
            _addMaterial = new Material(Shader.Find("Hidden/AddShader"));
        _addMaterial.SetFloat("_Sample", _currentSample);
        Graphics.Blit(_target, destination, _addMaterial);
        _currentSample++;
    }
    private void InitRenderTexture()
    {
        if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            // Release render texture if we already have one
            if (_target != null)
                _target.Release();
            // Get a render target for Ray Tracing
            _target = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _target.enableRandomWrite = true;
            _target.Create();
        }
    }

    private void Update()
    {
        if (transform.hasChanged)
        {
            _currentSample = 0;
            transform.hasChanged = false;
        }
    }

    private void OnEnable()
    {
        _currentSample = 0;
        SetUpScene();
    }
    private void OnDisable()
    {
        if (_sphereBuffer != null)
            _sphereBuffer.Release();
    }
    private void SetUpScene()
    {
        List<Sphere> spheres = new List<Sphere>();
        // Add a number of random spheres
        for (int i = 0; i < SpheresMax; i++)
        {
            Sphere sphere = new Sphere();
            // Radius and radius
            sphere.radius = SphereRadius.x + Random.value * (SphereRadius.y - SphereRadius.x);
            Vector2 randomPos = Random.insideUnitCircle * SpherePlacementRadius;
            sphere.position = new Vector3(randomPos.x, sphere.radius, randomPos.y);
            // Reject spheres that are intersecting others
            foreach (Sphere other in spheres)
            {
                float minDist = sphere.radius + other.radius;
                if (Vector3.SqrMagnitude(sphere.position - other.position) < minDist * minDist)
                    goto SkipSphere;
            }
            // Albedo and specular color
            Color color = Random.ColorHSV();
            bool metal = Random.value < 0.5f;
            sphere.albedo = metal ? Vector3.zero : new Vector3(color.r, color.g, color.b);
            sphere.specular = metal ? new Vector3(color.r, color.g, color.b) : Vector3.one * 0.04f;
            // Add the sphere to the list
            spheres.Add(sphere);
        SkipSphere:
            continue;
        }
        // Assign to compute buffer
        _sphereBuffer = new ComputeBuffer(spheres.Count, 40);
        _sphereBuffer.SetData(spheres);
    }
}