﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraMaster1 : MonoBehaviour
{
    public ComputeShader rtFractalShader;
    private RenderTexture _target;

    private void InitRenderTexture()
    {
        if(_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            if (_target != null)
                _target.Release();
            _target = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _target.enableRandomWrite = true;
            _target.Create();
        }
    }
    private void Render(RenderTexture destination)
    {
        InitRenderTexture();
        rtFractalShader.SetTexture(0, "Result", _target);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        rtFractalShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);
        Graphics.Blit(_target, destination);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Render(destination);
    }
}
