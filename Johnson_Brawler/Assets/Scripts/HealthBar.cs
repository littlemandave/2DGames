using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{

    public BrawlerCharacter brawlerCharacter;

    void Update(){
        if(brawlerCharacter){
            GetComponent<Slider>().value = brawlerCharacter.health / brawlerCharacter.maxHealth;
        }

    }

}
