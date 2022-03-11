using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class PlayerControls : MonoBehaviour
{
    BufferInput[] bufferArray;
    public Text bufferDisplay;
    public Text inputDisplay;
    Vector2 moveInputVector;

    public PauseMenu pauseMenu;
    BrawlerCharacter brawlerCharacter;
   

    // Start is called before the first frame update
    void Start()
    {
        brawlerCharacter = GetComponent<BrawlerCharacter>();
        brawlerCharacter.OnNextInput.AddListener(handleNextInput);
    }

    // Update is called once per frame
    void Update()
    {  
        bufferArray = brawlerCharacter.inputBuffer.ToArray();
        bufferDisplay.text = "";
        foreach (BufferInput i in bufferArray){
        bufferDisplay.text += i.type +"\n";
        }
    }

    void handleNextInput(){
        inputDisplay.text = "";
        if(brawlerCharacter.displayInput != null){
                    inputDisplay.text += brawlerCharacter.displayInput.Value.type; //displayInput is nullable, so .Value is needed here
        }

    }

    public void OnMove(InputValue value){
        moveInputVector = value.Get<Vector2>();
        brawlerCharacter.isMoving = moveInputVector.magnitude > 0 ? true : false;
        brawlerCharacter.moveDirection.x = moveInputVector.x;
        brawlerCharacter.moveDirection.z = moveInputVector.y;
    }

    public void OnPunch(InputValue value){
        if(value.Get<float>() != 0){
        brawlerCharacter.Punch();
        }
    }
    public void OnKick(InputValue value){
        
        if(value.Get<float>() != 0){
            brawlerCharacter.Kick();
        }
    }
    void OnPause(InputValue value){
        if(value.Get<float>() != 0){
            pauseMenu.isPaused = !pauseMenu.isPaused;       
            if(pauseMenu.isPaused){
                Time.timeScale = 0f;
                pauseMenu.pauseVisuals.SetActive(true);
            }else{
                Time.timeScale = 1f;
                pauseMenu.pauseVisuals.SetActive(false);
            }
        }
    }
    


}


