using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour
{
    public GameObject explosion;
    float age;
    float maxAge = 10.0f;
    public Vector3 direction;
    public float initialSpeed = 7.0f;
    void Start()
    {
        direction = new Vector3();
    }

    void Update(){
        age += Time.deltaTime;
        if(age > maxAge){
            Destroy(gameObject);
        }
    }

    void OnCollisionEnter2D(Collision2D coll) {
        coll.gameObject.SendMessage("OnDamage",2.0f, SendMessageOptions.DontRequireReceiver);
        if(!coll.gameObject.CompareTag("Projectile")){
            Instantiate(explosion,gameObject.transform.position,Quaternion.identity);
            Destroy(gameObject);
        }

    }

    public void SetFacing(bool isFacingRight){
        if(isFacingRight){
            direction.x = 1.0f;
        }else{
            direction.x = -1.0f;
        }
    }
    public void LaunchProjectile(float momentum){
        gameObject.GetComponent<Rigidbody2D>().velocity = direction * Mathf.Clamp((initialSpeed+momentum), 2,15);  
    }
}
