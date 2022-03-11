using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

public class BrawlerCharacter : MonoBehaviour
{
    public UnityEvent OnNextInput;
    bool canWalk = true;
    public Queue<BufferInput> inputBuffer;
    Animator animator;
    Facing facing = Facing.right;
     public Vector3 moveDirection;
    public bool isMoving;
    CharacterController control;
    SpriteRenderer[] sprites;
    public float Speed = 2.5f;
    public BufferInput? displayInput;

    bool canBeDamaged = true;
    public float health = 10;
    public float maxHealth = 10.0f;
    public GameObject healthPickup;
    void Start(){
        control = gameObject.GetComponent<CharacterController>();
        sprites = GetComponentsInChildren<SpriteRenderer>();
        inputBuffer = new Queue<BufferInput>();
        animator = GetComponent<Animator>();
    }

    void Update(){
        if(moveDirection.x > 0 || moveDirection.x < 0){
            facing = moveDirection.x > 0 ? Facing.right : Facing.left;
        }

            foreach (SpriteRenderer r in sprites){
                r.flipX = facing == Facing.right ? false : true;
            }
        
    }

    void FixedUpdate(){
        if(isMoving){
            
            moveDirection = moveDirection.normalized;
            if(canWalk){
                control.Move(moveDirection * Speed * Time.deltaTime);
                animator.SetBool("isWalking", true);
            }
            else
            {
                animator.SetBool("isWalking", false);
            }
        }
        else
        {
            animator.SetBool("isWalking", false);
        }
    }

    public void Punch(){
            animator.SetBool("isWalking", false);
            BufferInput punchInput;
            punchInput.type = BrawlerInput.punch;
            inputBuffer.Enqueue(punchInput);
    }
    public void Kick(){
        animator.SetBool("isWalking", false);
        BufferInput kickInput;
        kickInput.type = BrawlerInput.kick;
        inputBuffer.Enqueue(kickInput);
    }


    void SetAnimatorProperties(BufferInput input){
            switch (input.type){
                case BrawlerInput.punch:
                    animator.SetBool("punchInput", true);
                    animator.SetBool("kickInput", false);
                    break;
                case BrawlerInput.kick:
                    animator.SetBool("kickInput", true);
                    animator.SetBool("punchInput", false);
                    break;
                default:
                    break;
            }
        }

    void SetAllAnimPropertiesFalse(){
        animator.SetBool("punchInput", false);
        animator.SetBool("kickInput",false);
    }

    public void NextInput(){
        
        if(inputBuffer.Count > 0){
            BufferInput currentInput = inputBuffer.Dequeue();
            displayInput = currentInput;
            SetAnimatorProperties(currentInput);
        }else{
            SetAllAnimPropertiesFalse();
            displayInput = null;
        }
        OnNextInput.Invoke();
    }

    public void EnableWalk(){
        canWalk = true;
    }

    public void DisableWalk(){
        canWalk = false;
    }

    void ApplyDamage(float damage){
        if(!canBeDamaged){
            return;
        }
        GetComponent<Animator>().Play("HitStun");
        health -= damage;

        if(health <= 0){
            GetComponent<Animator>().Play("KO");
            if(Random.Range(1,3) < 2){
                Instantiate(healthPickup, gameObject.transform.position + Vector3.up, gameObject.transform.rotation);
            }
            canBeDamaged = false;
        }
    }

    public void destroyAnimationComplete(){
        Destroy(gameObject);
        //Add points
    }
}

public enum Facing{left, right}

public enum BrawlerInput{punch, kick}

public struct BufferInput{
    public BrawlerInput type;
}