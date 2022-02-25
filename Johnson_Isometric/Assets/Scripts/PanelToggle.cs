using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PanelToggle : MonoBehaviour
{
    public GameObject panel;
    Animator anim;
    bool isOpen = true;
   

    public void Start(){
        anim = panel.GetComponent<Animator>();
        anim.StopPlayback();
    }
    public void OnTogglePanel(){
            if (isOpen){
                anim.Play("Close");
                isOpen = false;
            }else{
                anim.Play("Open");
                isOpen = true;
            }
    }

}
