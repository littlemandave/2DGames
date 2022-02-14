using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(GridPosition2d))]
public class GridMovement : MonoBehaviour
{
// All about the motion
bool isMoving = false; // True if moving in any direction

// Only one of these can be true at a time… I'm sure there's a better way to do this
bool isMovingLeft = false;
bool isMovingRight = false;
bool isMovingUp = false;
bool isMovingDown = false;

GridPosition2d gridPosition;
Vector2Int inputVector;
Vector3 goalPosition;
Vector3 oldPosition;
Vector3 leftScale;
float lerpTime = 1.0f;

    void Start()
    {
        goalPosition = new Vector3();
        oldPosition = new Vector3();
        inputVector = new Vector2Int();
        gridPosition = GetComponent<GridPosition2d>();
    }

    public void Move(InputAction.CallbackContext context){
        if(context.performed != true){ return;}
        if(isMoving){return;}
        inputVector.x = (int)context.ReadValue<Vector2>().normalized.x;
        if(inputVector.x < 0){isMovingLeft = true;} else if(inputVector.x > 0) {isMovingRight = true;}
        inputVector.y = (int)context.ReadValue<Vector2>().normalized.y;
        if(inputVector.y < 0){isMovingDown = true;} else if(inputVector.y > 0) {isMovingUp = true;}
      
      if(!GridUtilities.IsGridCellOccupied( gridPosition.ParentGrid, gridPosition.GridPosition + inputVector, gameObject)){
            isMoving = true;
            lerpTime = 1.0f;
            goalPosition.x = inputVector.x + gridPosition.GridPosition.x;
            goalPosition.y = inputVector.y + gridPosition.GridPosition.y;
            oldPosition.x = gridPosition.GridPosition.x;
            oldPosition.y = gridPosition.GridPosition.y;
        }
    }

    void Update(){
        // Update all the state booleans, and if mving along x just flip the renderer's x axis
        gameObject.GetComponentInChildren<Animator>().SetBool("isMoving", isMoving);
        gameObject.GetComponentInChildren<Animator>().SetBool("goLeft", isMovingLeft);
        gameObject.GetComponentInChildren<Animator>().SetBool("goRight", isMovingRight);
        gameObject.GetComponentInChildren<Animator>().SetBool("goUp", isMovingUp);
        gameObject.GetComponentInChildren<Animator>().SetBool("goDown", isMovingDown);
        if(isMovingLeft){gameObject.GetComponentInChildren<SpriteRenderer>().flipX = true;} else{ gameObject.GetComponentInChildren<SpriteRenderer>().flipX = false;}


        // Do the actual update, updating the elapsed time, and when it reaches zero, reset all the state and keep the current grid position
        if(isMoving){
            lerpTime -= (Time.deltaTime * 2.0f);
            gameObject.transform.position = Vector3.Lerp(goalPosition,oldPosition, lerpTime);
            if(lerpTime <= 0){
                // Stopping: reset all the state variables
                isMoving = false;
                isMovingLeft = false;
                isMovingRight = false;
                isMovingUp = false;
                isMovingDown = false;
                gridPosition.GridPosition = gridPosition.GridPosition + inputVector;
            }           
        }
    }
}
