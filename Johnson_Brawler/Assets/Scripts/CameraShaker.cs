using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraShaker : MonoBehaviour
{
    // Start is called before the first frame update

    public float shakeTime = 0.0f;
    public float shakePower = 0.3f;
    Vector3 originalPosition;
    Vector3 offset;

    void Start()
    {
        originalPosition = gameObject.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        if(shakeTime > 0 ){
            shakeTime -= Time.deltaTime;
            ShakeCamera();
        }


    }



    void ShakeCamera(){
        offset.x =  Random.Range(-shakePower, shakePower);
        offset.y = Random.Range(-shakePower, shakePower);
        gameObject.transform.position = originalPosition + offset;
    }

}
