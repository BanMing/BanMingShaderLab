using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Translating : MonoBehaviour
{
    public Transform aTrans;
    public Transform bTrans;
    public Transform cTrans;

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        aTrans.Rotate(Vector3.up * Time.deltaTime * 300);

        bTrans.Rotate(aTrans.position, Time.deltaTime * 300);

        if (cTrans.position.x > 4)
        {
            cTrans.position = new Vector3(-10, 1.8f, -7.1f);
        }
        aTrans.Translate(Vector3.left * Time.deltaTime * 3);
        bTrans.Translate(Vector3.up * Time.deltaTime * 3);
        cTrans.Translate(Vector3.right * Time.deltaTime * 5);
    }
}