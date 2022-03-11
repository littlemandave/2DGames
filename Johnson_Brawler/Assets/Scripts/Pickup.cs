using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    
    void OnTriggerEnter(Collider other){
        if(other.gameObject.CompareTag("Player")){
           BrawlerCharacter character = other.gameObject.GetComponent<BrawlerCharacter>();
           character.health = Mathf.Clamp(character.health + 5, 0, character.maxHealth);
           Destroy(gameObject);
        }
    }
}
