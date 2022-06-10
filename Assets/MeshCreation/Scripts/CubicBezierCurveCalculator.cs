using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

    /*
    This class calculates Cubic Bezier Curves based on a given set of four (x,y) coordinate points. 
    */
    public class CubicBezierCurveCalculator 
    {
        /*
        This function takes in a given set of four points (PointD's) as well as the degree of accuracy we want 
        (that is, the number of output points to calculate), and calculates the bezier curve for those given points.
        Returns a list of numPointsToCalulate number of points, which is, in essence, our Bezier curve.
        */
        public static List<Vector3> CalculateCubicBezierCurve(List<Vector3> givenPoints, int numPointsToCalulate)
        {
            //More info on this algorithm can be found at https://www.geeksforgeeks.org/cubic-bezier-curve-implementation-in-c/
            float x_zero = givenPoints[0].x;
            float y_zero = givenPoints[0].y;
            float x_one = givenPoints[1].x;
            float y_one = givenPoints[1].y;
            float x_two = givenPoints[2].x;
            float y_two = givenPoints[2].y;
            float x_three = givenPoints[3].x;
            float y_three = givenPoints[3].y;

            float amountToIncrement = 1.0f / numPointsToCalulate;
            List<Vector3> bezierPointCalculations = new List<Vector3>();

            for (int u = 0; u < numPointsToCalulate; u++)
            {
                float current_u = u * amountToIncrement;
                float one_minus_current_u = 1.0f - current_u;
            Debug.Log(current_u);
            Debug.Log(one_minus_current_u);

            float xAnalysis = 
                    Mathf.Pow(one_minus_current_u, 3.0f) * x_zero + 
                    3f * current_u * Mathf.Pow(one_minus_current_u, 2.0f) * x_one + 
                    3f * one_minus_current_u * Mathf.Pow(current_u, 2.0f) * x_two + 
                    Mathf.Pow(current_u, 3.0f) * x_three;
         
            float yAnalysis = 
                    Mathf.Pow(one_minus_current_u, 3.0f) * y_zero + 
                    3f * current_u * Mathf.Pow(one_minus_current_u, 2.0f) * y_one + 
                    3f * one_minus_current_u * Mathf.Pow(current_u, 2.0f) * y_two + 
                    Mathf.Pow(current_u, 3.0f) * y_three;

            bezierPointCalculations.Add(new Vector3(xAnalysis, yAnalysis, 0.0f));
            }
            return bezierPointCalculations;
        }
    }



