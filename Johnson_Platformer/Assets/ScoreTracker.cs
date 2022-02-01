using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ScoreTracker : MonoBehaviour
{
    int score = 0;
    public void AddScore(){
        score +=1;
        GetComponent<Text>().text = "Score: "+ score;
    }
}
