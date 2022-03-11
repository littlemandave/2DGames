using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class hitbox : MonoBehaviour
{
    public CameraShaker shaker;
    public GameObject owner;
    public ParticleSystem hitSparks;
    public float AttackStrength = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        shaker = GameObject.Find("Main Camera").GetComponent<CameraShaker>();
    }

    void OnTriggerEnter(Collider other){
        if(other.gameObject != owner){
            other.gameObject.SendMessage("ApplyDamage", AttackStrength, SendMessageOptions.DontRequireReceiver);
            hitSparks.Emit(45);
            shaker.shakeTime = 0.15f;
        }
    }
}
