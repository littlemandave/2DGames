using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PuppetPlayerControl : MonoBehaviour
{
    Animator anim;
    CapsuleCollider2D coll;
    bool isOnGround;
    bool hasDoubleJumped = false;
    public float moveForce = 25;
    public float maxMoveSpeed = 6.0f;
    public float jumpForce = 2.0f;
    bool isFacingRight = true;
    Rigidbody2D rb;
    Vector2 inputVector;
    Vector3 movementVector;
    public GameObject projectile;
    public GameObject characterVisuals;
    Vector3 flippedScale;

    LayerMask mask;

    Vector3 gravity;
    // Start is called before the first frame update
    void Start()
    {
        flippedScale = new Vector3(-1,1,1);
        anim= GetComponent<Animator>();
        Physics2D.IgnoreLayerCollision(LayerMask.NameToLayer("PlayerProjectile"), LayerMask.NameToLayer("PlayerProjectile"));
        mask =~LayerMask.GetMask("Player");
        coll = GetComponent<CapsuleCollider2D>();
        inputVector = new Vector2();
        movementVector = new Vector3();
        rb = gameObject.GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        //GetComponent<SpriteRenderer>().flipX = !isFacingRight;
        if(!isFacingRight){
            characterVisuals.transform.localScale = flippedScale;
        }else{
            characterVisuals.transform.localScale = Vector3.one;
        }

        isOnGround = Physics2D.CircleCast(gameObject.transform.position, 0.2f, Vector2.down, coll.size.y/2, mask);

        if(anim!=null){GetComponent<Animator>().SetBool("isFalling", !isOnGround);}
        
        if(isOnGround)
        {
            hasDoubleJumped = false;           
        }

        movementVector.x = inputVector.x * moveForce;

        if(inputVector.magnitude != 0 && isOnGround && (anim!= null)){GetComponent<Animator>().SetBool("isRunning", true);} else if(anim!=null){GetComponent<Animator>().SetBool("isRunning", false);}

        if(inputVector.magnitude == 0 && isOnGround){
                rb.AddForce((rb.velocity * Vector3.right) * (-1 * moveForce * Time.deltaTime) ); //Brakes.
            }


        if(Mathf.Abs(rb.velocity.x) < maxMoveSpeed){
            rb.AddForce(movementVector * moveForce * Time.deltaTime);
        }

    }

    public void OnMove (InputValue value){
        inputVector = value.Get<Vector2>();
        if(inputVector.x > 0){
            isFacingRight = true;
        }else if (inputVector.x < 0){
            isFacingRight = false;
        }
    }

    public void OnJump(InputValue value){
        if(isOnGround){
            rb.AddForce(Vector3.up * jumpForce,ForceMode2D.Impulse);
            if(anim != null){GetComponent<Animator>().Play("Jump",0);}

        }else if(hasDoubleJumped == false){
             rb.velocity = rb.velocity.magnitude * inputVector.x * Vector3.right;
             rb.AddForce(Vector3.up * jumpForce,ForceMode2D.Impulse);
             if(anim != null){GetComponent<Animator>().Play("DoubleJump",0);}
             hasDoubleJumped = true;
             
        }
    }

    public void OnFire(InputValue value){
        Vector3 spawnDir = new Vector3();
        if(isFacingRight){
            spawnDir.x = 1.0f;
        }else{
            spawnDir.x = -1.0f;
        }

        GameObject newProjectile = Instantiate(projectile, spawnDir * 1f + gameObject.transform.position, Quaternion.identity);
        newProjectile.SendMessage("SetFacing", isFacingRight);
        newProjectile.SendMessage("LaunchProjectile", Mathf.Clamp(Mathf.Abs(rb.velocity.x),10,15));
    }
}
