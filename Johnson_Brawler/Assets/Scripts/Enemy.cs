using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    BrawlerCharacter brawlerCharacter;
    Vector3 enemyMoveDirection;
    GameObject player;

    public float punchDelay = 0.5f;

    void Start(){
        brawlerCharacter = GetComponent<BrawlerCharacter>();
        player = GameObject.FindGameObjectWithTag("Player");
        brawlerCharacter.isMoving = true;
    }

    void FixedUpdate(){

        if(player == null){
            return;
        }

        if(Vector3.Distance(gameObject.transform.position, player.transform.position) > 1.5f){
            if(player.gameObject.transform.position.x < gameObject.transform.position.x){
                enemyMoveDirection.x = -1;
            }else{
                enemyMoveDirection.x = 1;
            }

            if(player.gameObject.transform.position.z < gameObject.transform.position.z){
                enemyMoveDirection.z = -1;
            }else{
                enemyMoveDirection.z = 1;
            }
        }
        else
        {
            enemyMoveDirection = Vector3.zero;
            if(punchDelay <= 0){
                brawlerCharacter.Punch();
                punchDelay = 0.5f;
            }else{
                punchDelay -= Time.fixedDeltaTime;
            }

        }

        brawlerCharacter.moveDirection = enemyMoveDirection;
    }


}
