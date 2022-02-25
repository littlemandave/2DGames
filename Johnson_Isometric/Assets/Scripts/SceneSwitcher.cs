using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{

    public void Start(){
        if (SceneManager.GetActiveScene().name == "SampleScene"){
            GetComponent<Animator>().Play("FadeIn");
        }
    }

    public void PlayFadeOutAnimation(){
        GetComponent<Animator>().Play("FadeAndSwitchMap");
    }
    void SwitchToSampleScene(){
        SceneManager.LoadScene(1, LoadSceneMode.Single);
    }
}
