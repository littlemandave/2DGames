using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyScript : MonoBehaviour
{
    public float jumpForce = 10.0f;
    public float bulletSpeed = 3.0f;
    public GameObject projectile;

    public float jumpDelay = 5;
    public float shootDelay = 3;
    float timeUntilShoot = 3;
    float timeUntilJump = 5;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        timeUntilJump -= Time.deltaTime;
        timeUntilShoot -= Time.deltaTime;
        if(timeUntilJump <= 0){
            Jump();
            timeUntilJump = jumpDelay;
        }
        if(timeUntilShoot<= 0){
            Fire();
            timeUntilShoot = shootDelay;
        }

    }

    void OnDamage(float damage){
        Destroy(gameObject);
    }


        void Jump(){
            GetComponent<Rigidbody2D>().AddForce(Vector2.up*jumpForce, ForceMode2D.Impulse);
        }

        public void Fire(){
        Vector3 spawnDir = new Vector3();
        if(GetComponent<SpriteRenderer>().flipX){
            spawnDir.x = -1.0f;
        }else{
            spawnDir.x = 1.0f;
        }

        GameObject newProjectile = Instantiate(projectile, spawnDir * 2.0f + gameObject.transform.position, Quaternion.identity);
        newProjectile.SendMessage("SetFacing", !GetComponent<SpriteRenderer>().flipX);
        newProjectile.SendMessage("LaunchProjectile", bulletSpeed);
    }

}
